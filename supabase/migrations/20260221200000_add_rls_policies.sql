-- Habilitar RLS en tablas de catalogo y relaciones
alter table public.place_types enable row level security;
alter table public.tags enable row level security;
alter table public.places enable row level security;
alter table public.place_images enable row level security;
alter table public.place_tags enable row level security;
alter table public.favorites enable row level security;

-- Lectura publica de tipos de lugar
create policy place_types_select_public
on public.place_types
for select
to anon, authenticated
using (true);

-- Lectura publica de tags
create policy tags_select_public
on public.tags
for select
to anon, authenticated
using (true);

-- Lectura publica de lugares no borrados
create policy places_select_public
on public.places
for select
to anon, authenticated
using (not deleted);

-- Lectura publica de imagenes no borradas
create policy place_images_select_public
on public.place_images
for select
to anon, authenticated
using (not deleted);

-- Lectura publica de relaciones lugar-tag no borradas
create policy place_tags_select_public
on public.place_tags
for select
to anon, authenticated
using (not deleted);

-- Favorites: solo el usuario autenticado puede ver sus propios favoritos no borrados
create policy favorites_select_own
on public.favorites
for select
to authenticated
using (auth.uid() = user_id and not deleted);

-- Favorites: solo el usuario autenticado puede crear sus propios favoritos
create policy favorites_insert_own
on public.favorites
for insert
to authenticated
with check (auth.uid() = user_id and not deleted);

-- Favorites: solo el usuario autenticado puede borrar sus propios favoritos
create policy favorites_delete_own
on public.favorites
for delete
to authenticated
using (auth.uid() = user_id);
