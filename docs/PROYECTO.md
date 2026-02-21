# 🧭 Proyecto: Explorador Visual de Lugares Turísticos

## 1. Visión del Proyecto

Crear una aplicación móvil que permita **explorar lugares turísticos existentes de forma visual**, usando un mapa interactivo con clustering eficiente, priorizando **descubrimiento**, **fluidez** y **control técnico**.

No es una red social.
No es una app de reviews.
No depende de tendencias (IA, feeds, likes).

---

## 2. Problema a Resolver

Las personas que viajan o exploran nuevos lugares:
- no saben qué hay cerca
- dependen de redes sociales ruidosas
- pierden tiempo filtrando contenido irrelevante
- no tienen una visión espacial clara de los lugares

**Problema central**  
> “Quiero descubrir lugares turísticos reales cerca de mí, de forma visual, rápida y sin distracciones.”

---

## 3. Objetivo del MVP

> Permitir a cualquier usuario explorar lugares turísticos en un mapa, descubrir sitios cercanos mediante clustering visual y guardar favoritos.

Si el MVP no cumple esto, está fuera de alcance.

---

## 4. Principios Técnicos y de Producto (No Negociables)

1. Exploración visual primero, contenido después
2. Backend eficiente (no traer datos innecesarios)
3. Esquema de datos explícito y versionado
4. UX fluida > cantidad de features
5. Proyecto **terminable**
6. Open Source desde el inicio

---

## 5. Usuario Objetivo (MVP)

- Viajeros
- Mochileros
- Personas planificando viajes
- Exploradores locales

No hay segmentación avanzada en el MVP.

---

## 6. Alcance Funcional del MVP

### Incluye
- Mapa interactivo
- Clustering por nivel de zoom
- Vista de lugar con imágenes
- Guardado de favoritos
- Autenticación básica (Google)

### NO Incluye
- Comentarios
- Likes
- Seguidores
- IA
- Recomendaciones
- Monetización
- Social features

---

## 7. Arquitectura General

### Frontend
- Flutter
- Mapa interactivo
- Render de clusters y puntos
- UX fluida y animaciones suaves

### Backend
- Supabase
- PostgreSQL
- SQL puro + RPC
- Clustering backend basado en bbox + zoom

---

## 8. Modelo de Datos (MVP)

### 8.1 Places
- id (uuid)
- name (text)
- description (text)
- latitude (double)
- longitude (double)
 - place_type_id (uuid, FK place_types)
- best_season (text)
- created_at (timestamp)

### 8.2 Place Images
- id (uuid)
- place_id (uuid, FK)
- image_url (text)
- order (int)

### 8.3 Favorites
- user_id (uuid, FK)
- place_id (uuid, FK)
- created_at (timestamp)
- PK (user_id, place_id)

### 8.4 Place Types
- id (uuid)
- slug (text, único)
- name (text)
- created_at (timestamp)

### 8.5 Tags
- id (uuid)
- slug (text, único)
- name (text)
- created_at (timestamp)

### 8.6 Place Tags
- place_id (uuid, FK)
- tag_id (uuid, FK)
- created_at (timestamp)
- PK (place_id, tag_id)

No se crean tablas de clusters.

---

## 9. Clustering Backend (Diseño)

### Entrada desde el cliente
- Bounding box visible (NE / SW)
- Nivel de zoom

### Lógica
- Grid-based clustering según zoom
- Tamaño de celda variable por nivel
- Si el zoom es alto → devolver lugares individuales
- Si el zoom es bajo → devolver clusters

### Salida
- Lista de entidades:
  - Cluster (lat, lng, count, bounds)
  - Lugar individual (id, lat, lng, metadata mínima)

---

## 10. Comportamiento UX del Mapa

### Estados del mapa
| Zoom | Comportamiento |
|----|----|
| Bajo | Clusters grandes |
| Medio | Clusters pequeños |
| Alto | Lugares individuales |

### Interacciones
- Tap en cluster → zoom automático al área
- Tap en lugar → vista detallada
- Swipe → carrusel de imágenes

Un cluster **no muestra contenido final**.

---

## 11. Vista de Lugar

Incluye:
- Nombre
- Carrusel de imágenes
- Descripción corta
- Mejor época para visitar
- Botón de favorito

No incluye comentarios ni ratings.

---

## 12. Favoritos

- Guardar / quitar lugar
- Lista simple de favoritos
- Sin carpetas
- Sin orden avanzado

---

## 13. Roadmap de Implementación

### Fase 0 — Definición (1 día)
- Validar problema
- Congelar alcance del MVP

### Fase 1 — Datos (1–2 días)
- Esquema SQL
- Migraciones
- Supabase local

### Fase 2 — Backend (3 días)
- RPC de clustering
- Queries optimizadas
- Índices básicos

### Fase 3 — Mapa y UX (4–5 días)
- Render de clusters
- Animaciones
- Interacciones

### Fase 4 — Favoritos (1 día)
- Persistencia
- UI mínima

### Fase 5 — Pulido (2 días)
- Skeleton loaders
- Error handling
- Caching básico

### Fase 6 — Open Source (1 día)
- README claro
- Screenshots
- Licencia
- Roadmap público

---

## 14. Timeline Estimado

Duración total: **14–18 días**

- Semana 1: Backend + mapa base
- Semana 2: UX + favoritos + pulido
- Semana 3: Documentación + release

---

## 15. Criterios de Éxito del MVP

- El mapa se siente fluido
- No se cargan datos innecesarios
- El usuario entiende cómo explorar
- El proyecto está terminado
- El código es defendible en entrevistas

---

## 16. Evolución Futura (Fuera del MVP)

- PostGIS clustering avanzado
- Aportes de usuarios
- Moderación
- Perfiles
- Ranking visual
- Red social especializada

Nada de esto se implementa ahora.

---

## 17. Objetivo Profesional

Este proyecto debe demostrar:
- Criterio de arquitectura
- Pensamiento de producto
- Backend eficiente
- Capacidad de terminar sistemas reales

Este proyecto **no es un hobby**, es una pieza de carrera.

---
