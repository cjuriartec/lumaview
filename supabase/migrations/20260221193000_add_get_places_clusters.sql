-- RPC get_places_clusters: devuelve clusters o lugares individuales segun zoom y filtros
create or replace function public.get_places_clusters(
  ne_lat double precision,
  ne_lng double precision,
  sw_lat double precision,
  sw_lng double precision,
  zoom integer,
  place_type_slugs text[] default null,
  tag_slugs text[] default null
)
returns table (
  -- tipo de resultado: 'cluster' o 'place'
  type text,
  -- identificador del cluster o lugar
  id text,
  -- latitud del punto o centro del cluster
  lat double precision,
  -- longitud del punto o centro del cluster
  lng double precision,
  -- numero de lugares dentro del cluster (1 en modo place)
  count integer,
  -- bbox noreste del cluster (solo en modo cluster)
  bbox_ne_lat double precision,
  bbox_ne_lng double precision,
  -- bbox suroeste del cluster (solo en modo cluster)
  bbox_sw_lat double precision,
  bbox_sw_lng double precision,
  -- nombre del lugar (solo en modo place)
  name text,
  -- slug del tipo de lugar (beach, mountain, etc.)
  place_type text,
  -- lista de slugs de tags asociados al lugar
  tags text[]
)
language plpgsql
as $$
declare
  -- tamano de celda de la grid segun zoom; null significa sin clustering
  cell_size double precision;
begin
  if zoom is null then
    zoom := 4;
  end if;

  if zoom <= 6 then
    cell_size := 1.0;
  elsif zoom <= 10 then
    cell_size := 0.25;
  else
    cell_size := null;
  end if;

  if cell_size is null then
    -- zoom alto: devolver lugares individuales dentro del bbox
    return query
      with base as (
        select
          p.id,
          p.latitude,
          p.longitude,
          p.name,
          pt.slug as place_type,
          coalesce(
            array_agg(distinct t.slug) filter (where t.slug is not null),
            '{}'::text[]
          ) as tags
        from places p
        join place_types pt on pt.id = p.place_type_id
        left join place_tags plt on plt.place_id = p.id and not plt.deleted
        left join tags t on t.id = plt.tag_id
        where
          not p.deleted
          and p.latitude between sw_lat and ne_lat
          and p.longitude between sw_lng and ne_lng
          and (
            place_type_slugs is null
            or cardinality(place_type_slugs) = 0
            or pt.slug = any(place_type_slugs)
          )
          and (
            tag_slugs is null
            or cardinality(tag_slugs) = 0
            or exists (
              select 1
              from place_tags plt2
              join tags t2 on t2.id = plt2.tag_id
              where
                plt2.place_id = p.id
                and not plt2.deleted
                and t2.slug = any(tag_slugs)
            )
          )
        group by p.id, p.latitude, p.longitude, p.name, pt.slug
        limit 1000
      )
      select
        'place'::text as type,
        base.id::text as id,
        base.latitude as lat,
        base.longitude as lng,
        1 as count,
        null::double precision as bbox_ne_lat,
        null::double precision as bbox_ne_lng,
        null::double precision as bbox_sw_lat,
        null::double precision as bbox_sw_lng,
        base.name,
        base.place_type,
        base.tags
      from base;
  else
    -- zoom bajo/medio: aplicar clustering por grid dentro del bbox
    return query
      with filtered as (
        select
          p.id,
          p.latitude,
          p.longitude,
          p.name,
          pt.slug as place_type,
          coalesce(
            array_agg(distinct t.slug) filter (where t.slug is not null),
            '{}'::text[]
          ) as tags
        from places p
        join place_types pt on pt.id = p.place_type_id
        left join place_tags plt on plt.place_id = p.id and not plt.deleted
        left join tags t on t.id = plt.tag_id
        where
          not p.deleted
          and p.latitude between sw_lat and ne_lat
          and p.longitude between sw_lng and ne_lng
          and (
            place_type_slugs is null
            or cardinality(place_type_slugs) = 0
            or pt.slug = any(place_type_slugs)
          )
          and (
            tag_slugs is null
            or cardinality(tag_slugs) = 0
            or exists (
              select 1
              from place_tags plt2
              join tags t2 on t2.id = plt2.tag_id
              where
                plt2.place_id = p.id
                and not plt2.deleted
                and t2.slug = any(tag_slugs)
            )
          )
        group by p.id, p.latitude, p.longitude, p.name, pt.slug
        limit 5000
      ),
      with_cells as (
        select
          *,
          floor(latitude / cell_size) * cell_size as cell_lat,
          floor(longitude / cell_size) * cell_size as cell_lng
        from filtered
      ),
      clusters as (
        select
          'cluster'::text as type,
          format(
            'cluster-%s-%s-z%s',
            cell_lat,
            cell_lng,
            zoom
          )::text as id,
          avg(latitude) as lat,
          avg(longitude) as lng,
          count(*)::integer as count,
          max(latitude) as bbox_ne_lat,
          max(longitude) as bbox_ne_lng,
          min(latitude) as bbox_sw_lat,
          min(longitude) as bbox_sw_lng,
          null::text as name,
          null::text as place_type,
          null::text[] as tags
        from with_cells
        group by cell_lat, cell_lng
      )
      select
        c.type,
        c.id,
        c.lat,
        c.lng,
        c.count,
        c.bbox_ne_lat,
        c.bbox_ne_lng,
        c.bbox_sw_lat,
        c.bbox_sw_lng,
        c.name,
        c.place_type,
        c.tags
      from clusters c;
  end if;
end;
$$;

-- exponer el RPC como security definer para controlar acceso solo via la funcion
alter function public.get_places_clusters(
  double precision,
  double precision,
  double precision,
  double precision,
  integer,
  text[],
  text[]
)
security definer;

-- permitir que los roles HTTP puedan ejecutar el RPC
grant execute on function public.get_places_clusters(
  double precision,
  double precision,
  double precision,
  double precision,
  integer,
  text[],
  text[]
)
to anon, authenticated;
