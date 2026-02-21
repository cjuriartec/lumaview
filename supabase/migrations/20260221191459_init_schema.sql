create table if not exists place_types (
  id uuid primary key default gen_random_uuid(), -- UUID único generado automáticamente
  slug text not null unique, -- Slug único en minúsculas; ej: beach, mountain
  name text not null, -- Nombre legible del tipo; ej: Playa, Montaña
  created_at timestamptz not null default now(), -- Fecha/hora de creación con zona horaria
  updated_at timestamptz not null default now(), -- Fecha/hora de última actualización
  created_by uuid, -- Usuario que creó (auth.users.id); opcional
  updated_by uuid, -- Usuario que actualizó (auth.users.id); opcional
  deleted boolean not null default false -- Borrado lógico (soft delete)
);

create table if not exists tags (
  id uuid primary key default gen_random_uuid(), -- UUID único generado automáticamente
  slug text not null unique, -- Slug único de la etiqueta; ej: hiking, photography
  name text not null, -- Nombre legible de la etiqueta; ej: Senderismo, Fotografía
  created_at timestamptz not null default now(), -- Fecha/hora de creación con zona horaria
  updated_at timestamptz not null default now(), -- Fecha/hora de última actualización
  created_by uuid, -- Usuario que creó (auth.users.id); opcional
  updated_by uuid, -- Usuario que actualizó (auth.users.id); opcional
  deleted boolean not null default false -- Borrado lógico (soft delete)
);

create table if not exists places (
  id uuid primary key default gen_random_uuid(), -- UUID único del lugar
  name text not null, -- Nombre del lugar; ej: "Playa Azul"
  description text not null, -- Descripción breve; ej: "Playa de arena clara"
  latitude double precision not null, -- Latitud (-90..90); ej: 40.4168
  longitude double precision not null, -- Longitud (-180..180); ej: -3.7038
  place_type_id uuid not null references place_types(id), -- Tipo de lugar (FK a place_types.id)
  best_season text, -- Época recomendada; ej: Verano / Todo el año
  created_at timestamptz not null default now(), -- Fecha/hora de creación del registro
  updated_at timestamptz not null default now(), -- Fecha/hora de última actualización
  created_by uuid, -- Usuario que creó (auth.users.id); opcional
  updated_by uuid, -- Usuario que actualizó (auth.users.id); opcional
  deleted boolean not null default false -- Borrado lógico (soft delete)
);

create table if not exists place_images (
  id uuid primary key default gen_random_uuid(), -- UUID único de la imagen
  place_id uuid not null references places(id) on delete cascade, -- FK al lugar; borra imágenes si se borra el lugar
  image_url text not null, -- URL pública de la imagen; ej: https://example.com/imagen.jpg
  "order" integer not null default 0, -- Orden en carrusel (0 por defecto)
  created_at timestamptz not null default now(), -- Fecha/hora de creación del registro
  updated_at timestamptz not null default now(), -- Fecha/hora de última actualización
  created_by uuid, -- Usuario que creó (auth.users.id); opcional
  updated_by uuid, -- Usuario que actualizó (auth.users.id); opcional
  deleted boolean not null default false -- Borrado lógico (soft delete)
);

create table if not exists favorites (
  user_id uuid not null, -- UUID del usuario autenticado (Supabase auth.users.id)
  place_id uuid not null references places(id) on delete cascade, -- Lugar favorito (FK a places.id)
  created_at timestamptz not null default now(), -- Fecha/hora en que se marcó como favorito
  updated_at timestamptz not null default now(), -- Fecha/hora de última actualización
  created_by uuid, -- Usuario que creó (auth.users.id); opcional (puede coincidir con user_id)
  updated_by uuid, -- Usuario que actualizó (auth.users.id); opcional
  deleted boolean not null default false, -- Borrado lógico (soft delete)
  primary key (user_id, place_id) -- PK compuesta para evitar duplicados por usuario/lugar
);

create table if not exists place_tags (
  place_id uuid not null references places(id) on delete cascade, -- Lugar (FK a places.id)
  tag_id uuid not null references tags(id) on delete cascade, -- Etiqueta (FK a tags.id)
  created_at timestamptz not null default now(), -- Fecha/hora de creación de la relación
  updated_at timestamptz not null default now(), -- Fecha/hora de última actualización
  created_by uuid, -- Usuario que creó (auth.users.id); opcional
  updated_by uuid, -- Usuario que actualizó (auth.users.id); opcional
  deleted boolean not null default false, -- Borrado lógico (soft delete)
  primary key (place_id, tag_id) -- PK compuesta N:M entre lugares y etiquetas
);

create index if not exists idx_places_latitude_longitude on places (latitude, longitude);
create index if not exists idx_places_name on places (name);
create index if not exists idx_places_place_type_id on places (place_type_id);
create index if not exists idx_place_images_place_id on place_images (place_id);
create index if not exists idx_favorites_user_id on favorites (user_id);
create index if not exists idx_favorites_place_id on favorites (place_id);
create index if not exists idx_place_tags_tag_id on place_tags (tag_id);

-- Trigger para mantener updated_at automáticamente en todas las tablas
create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create or replace function apply_updated_at_triggers() returns void language plpgsql as $$
declare r record;
begin
  for r in
    select table_schema, table_name
    from information_schema.columns
    where column_name = 'updated_at'
      and table_schema = 'public'
  loop
    execute format('drop trigger if exists %I on %I.%I',
      'tr_' || r.table_name || '_updated_at', r.table_schema, r.table_name);
    execute format('create trigger %I before update on %I.%I for each row execute function set_updated_at()',
      'tr_' || r.table_name || '_updated_at', r.table_schema, r.table_name);
  end loop;
end;
$$;

-- Nota: cada vez que crees una nueva tabla con columna updated_at,
-- ejecuta este comando para añadir/actualizar los triggers de updated_at:
--   select apply_updated_at_triggers();
select apply_updated_at_triggers();
