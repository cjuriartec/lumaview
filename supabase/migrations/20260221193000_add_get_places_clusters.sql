create or replace function public.get_places_clusters(
  ne_lat             double precision,
  ne_lng             double precision,
  sw_lat             double precision,
  sw_lng             double precision,
  zoom               double precision,
  place_type_slugs   text[]  default null,
  tag_slugs          text[]  default null
)
returns table (
  type          text,
  id            text,
  lat           double precision,
  lng           double precision,
  count         integer,
  bbox_ne_lat   double precision,
  bbox_ne_lng   double precision,
  bbox_sw_lat   double precision,
  bbox_sw_lng   double precision,
  name          text,
  place_type    text,
  tags          text[]
)
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  cell_size             double precision;
  min_lat               double precision;
  max_lat               double precision;
  min_lng               double precision;
  max_lng               double precision;
  crosses_antimeridian  boolean;
begin
  min_lat := least(sw_lat, ne_lat);
  max_lat := greatest(sw_lat, ne_lat);
  min_lng := least(sw_lng, ne_lng);
  max_lng := greatest(sw_lng, ne_lng);
  min_lat := greatest(-90.0, min_lat);
  max_lat := least(90.0, max_lat);
  crosses_antimeridian := (max_lng - min_lng) > 180.0;

  zoom := coalesce(zoom, 5.0);
  zoom := greatest(0.0, least(22.0, zoom));

  case
    when zoom <  3.0  then cell_size := 45.0;
    when zoom <  4.0  then cell_size := 20.0;
    when zoom <  5.0  then cell_size := 8.0;
    when zoom <  7.0  then cell_size := 2.5;
    when zoom <  9.0  then cell_size := 0.8;
    when zoom < 11.0  then cell_size := 0.18;
    when zoom < 12.0  then cell_size := 0.09;
    when zoom < 13.0  then cell_size := 0.045;
    when zoom < 14.0  then cell_size := 0.022;
    when zoom < 15.0  then cell_size := 0.011;
    when zoom < 16.0  then cell_size := 0.006;
    else                   cell_size := null;
  end case;

  if cell_size is null then
    return query
    with base as (
      select
        p.id,
        p.latitude,
        p.longitude,
        p.name,
        pt.slug as place_type,
        coalesce(
          (select array_agg(t2.slug order by t2.slug)
           from place_tags plt2
           join tags t2 on t2.id = plt2.tag_id and not t2.deleted
           where plt2.place_id = p.id and not plt2.deleted),
          '{}'::text[]
        ) as tags
      from places p
      join place_types pt on pt.id = p.place_type_id and not pt.deleted
      where
        not p.deleted
        and p.latitude between min_lat and max_lat
        and (
          (not crosses_antimeridian and p.longitude between min_lng and max_lng)
          or
          (crosses_antimeridian and (p.longitude >= min_lng or p.longitude <= max_lng))
        )
        and (
          place_type_slugs is null
          or coalesce(array_length(place_type_slugs, 1), 0) = 0
          or pt.slug = any(place_type_slugs)
        )
        and (
          tag_slugs is null
          or coalesce(array_length(tag_slugs, 1), 0) = 0
          or exists (
            select 1 from place_tags plt3
            join tags t3 on t3.id = plt3.tag_id and not t3.deleted
            where plt3.place_id = p.id and not plt3.deleted
              and t3.slug = any(tag_slugs)
          )
        )
      limit 1000
    )
    select
      'place'::text,
      base.id::text,
      base.latitude,
      base.longitude,
      1::integer,
      null::double precision,
      null::double precision,
      null::double precision,
      null::double precision,
      base.name,
      base.place_type,
      base.tags
    from base
    order by base.name nulls last;

  else
    return query
    with
    filtered as (
      select
        p.id,
        p.latitude,
        p.longitude,
        p.name,
        pt.slug as place_type,
        coalesce(
          (select array_agg(t2.slug order by t2.slug)
           from place_tags plt2
           join tags t2 on t2.id = plt2.tag_id and not t2.deleted
           where plt2.place_id = p.id and not plt2.deleted),
          '{}'::text[]
        ) as tags,
        floor(p.latitude  / cell_size) * cell_size as cell_lat,
        floor(p.longitude / cell_size) * cell_size as cell_lng
      from places p
      join place_types pt on pt.id = p.place_type_id and not pt.deleted
      where
        not p.deleted
        and p.latitude between min_lat and max_lat
        and (
          (not crosses_antimeridian and p.longitude between min_lng and max_lng)
          or
          (crosses_antimeridian and (p.longitude >= min_lng or p.longitude <= max_lng))
        )
        and (
          place_type_slugs is null
          or coalesce(array_length(place_type_slugs, 1), 0) = 0
          or pt.slug = any(place_type_slugs)
        )
        and (
          tag_slugs is null
          or coalesce(array_length(tag_slugs, 1), 0) = 0
          or exists (
            select 1 from place_tags plt3
            join tags t3 on t3.id = plt3.tag_id and not t3.deleted
            where plt3.place_id = p.id and not plt3.deleted
              and t3.slug = any(tag_slugs)
          )
        )
      limit 5000
    ),
    clusters as (
      select
        'cluster'::text as type,
        format(
          'cluster-%s-%s-z%s',
          round(cell_lat::numeric, 6),
          round(cell_lng::numeric, 6),
          round(zoom::numeric, 1)
        )::text as id,
        avg(latitude)::double precision  as lat,
        avg(longitude)::double precision as lng,
        count(*)::integer                as count,
        max(latitude)::double precision  as bbox_ne_lat,
        max(longitude)::double precision as bbox_ne_lng,
        min(latitude)::double precision  as bbox_sw_lat,
        min(longitude)::double precision as bbox_sw_lng,
        null::text                       as name,
        null::text                       as place_type,
        null::text[]                     as tags
      from filtered
      group by cell_lat, cell_lng
    )
    select
      c.type, c.id, c.lat, c.lng, c.count,
      c.bbox_ne_lat, c.bbox_ne_lng, c.bbox_sw_lat, c.bbox_sw_lng,
      c.name, c.place_type, c.tags
    from clusters c
    order by c.count desc, c.lat, c.lng;
  end if;
end;
$$;

grant execute on function public.get_places_clusters(
  double precision, double precision, double precision,
  double precision, double precision, text[], text[]
) to anon, authenticated;