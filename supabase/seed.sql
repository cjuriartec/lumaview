insert into place_types (id, slug, name)
values
  (gen_random_uuid(), 'beach', 'Playa'),
  (gen_random_uuid(), 'mountain', 'Montaña'),
  (gen_random_uuid(), 'city', 'Ciudad'),
  (gen_random_uuid(), 'viewpoint', 'Mirador'),
  (gen_random_uuid(), 'natural_park', 'Parque natural');

insert into tags (id, slug, name)
values
  (gen_random_uuid(), 'hiking', 'Senderismo'),
  (gen_random_uuid(), 'photography', 'Fotografía'),
  (gen_random_uuid(), 'family', 'Familiar'),
  (gen_random_uuid(), 'adventure', 'Aventura'),
  (gen_random_uuid(), 'cultural', 'Cultural');

with type_ids as (
  select slug, id from place_types
),
tag_ids as (
  select slug, id from tags
),
inserted_places as (
  insert into places (id, name, description, latitude, longitude, place_type_id, best_season)
  values
    (gen_random_uuid(), 'Playa Azul', 'Playa amplia de arena clara y aguas tranquilas.', 40.4168, -3.7038, (select id from type_ids where slug = 'beach'), 'Verano'),
    (gen_random_uuid(), 'Mirador del Valle', 'Mirador con vistas panorámicas a todo el valle.', 41.3874, 2.1686, (select id from type_ids where slug = 'viewpoint'), 'Otoño'),
    (gen_random_uuid(), 'Sendero del Bosque', 'Ruta de senderismo suave entre bosques y arroyos.', 43.2630, -2.9350, (select id from type_ids where slug = 'natural_park'), 'Primavera'),
    (gen_random_uuid(), 'Cascada Escondida', 'Pequeña cascada accesible tras una caminata corta.', 37.3891, -5.9845, (select id from type_ids where slug = 'natural_park'), 'Primavera'),
    (gen_random_uuid(), 'Pico del Águila', 'Cima con vistas espectaculares, requiere buena condición física.', 39.4699, -0.3763, (select id from type_ids where slug = 'mountain'), 'Verano'),
    (gen_random_uuid(), 'Centro Histórico', 'Zona histórica con arquitectura tradicional y plazas.', 36.7213, -4.4214, (select id from type_ids where slug = 'city'), 'Todo el año'),
    (gen_random_uuid(), 'Bahía Esmeralda', 'Bahía resguardada ideal para snorkel y kayak.', 39.8628, -4.0273, (select id from type_ids where slug = 'beach'), 'Verano'),
    (gen_random_uuid(), 'Parque de los Lagos', 'Parque natural con lagos pequeños y rutas circulares.', 42.2406, -8.7207, (select id from type_ids where slug = 'natural_park'), 'Primavera'),
    (gen_random_uuid(), 'Faro del Acantilado', 'Faro sobre acantilados con vistas al atardecer.', 43.3623, -8.4115, (select id from type_ids where slug = 'viewpoint'), 'Verano'),
    (gen_random_uuid(), 'Ruta de los Puentes', 'Itinerario urbano que recorre varios puentes emblemáticos.', 40.9650, -5.6640, (select id from type_ids where slug = 'city'), 'Todo el año')
  returning id, name
),
place_images_insert as (
  insert into place_images (id, place_id, image_url, "order")
  select gen_random_uuid(), id, 'https://example.com/images/' || replace(lower(name), ' ', '_') || '_1.jpg', 0
  from inserted_places
  returning place_id
)
insert into place_tags (place_id, tag_id)
select pi.place_id, t.id
from place_images_insert pi
join inserted_places p on p.id = pi.place_id
join tag_ids t
  on (
    (p.name like 'Playa%' and t.slug in ('beach', 'photography'))
    or (p.name like 'Mirador%' and t.slug in ('photography', 'adventure'))
    or (p.name like 'Sendero%' and t.slug in ('hiking', 'family'))
    or (p.name like 'Cascada%' and t.slug in ('hiking', 'photography'))
    or (p.name like 'Pico%' and t.slug in ('hiking', 'adventure'))
    or (p.name like 'Centro Histórico' and t.slug in ('cultural', 'family'))
    or (p.name like 'Bahía%' and t.slug in ('adventure', 'family'))
    or (p.name like 'Parque de los Lagos' and t.slug in ('family', 'photography'))
    or (p.name like 'Faro%' and t.slug in ('photography', 'adventure'))
    or (p.name like 'Ruta de los Puentes' and t.slug in ('cultural', 'family'))
  );

