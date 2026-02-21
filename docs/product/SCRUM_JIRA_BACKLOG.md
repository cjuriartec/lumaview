# Backlog Detallado para Jira — Lumaview

Este documento detalla las **Épicas** y **Historias** del MVP de Lumaview en un formato listo para crear issues en Jira.

Para cada ítem se incluyen:
- Issue Type
- Summary
- Description (contexto + pasos)
- Acceptance Criteria
- Story Points
- Components
- Labels

---

## E1. Datos y Migraciones (Supabase) — Epic

- **Issue Type**: Epic  
- **Summary**: `E1: Datos y Migraciones (Supabase)`  
- **Description**:  
  - Objetivo: Definir, versionar y poblar el esquema de datos del MVP en Supabase, incluyendo `places`, `place_images`, `place_types`, `tags`, `place_tags`, `favorites`.  
  - Alcance:  
    - Diseño del esquema SQL (Historia E1-1).  
    - Migraciones reproducibles (Historia E1-2/E1-3).  
    - Seeds iniciales de datos (Historia E1-2).  
    - Supabase corriendo local con pipeline claro de migraciones (Historia E1-3).  
  - Resultado esperado: Un backend de datos estable para que el mapa y las demás features puedan consumir información real.  
- **Components**: `Supabase`  
- **Labels**: `dataschema`, `seeds`, `backend`  
- **Acceptance Criteria**:  
  - Todas las historias de E1 están en Done.  
  - El entorno local arranca con datos de ejemplo listos para usar.  

### E1-1 — Definir esquema SQL MVP

- **Issue Type**: Story  
- **Summary**: `Definir esquema SQL MVP`  
- **Description**:  
  - Contexto: Necesitamos un modelo relacional claro y normalizado para los lugares turísticos del MVP.  
  - Pasos sugeridos:  
    1. Diseñar tablas: `places`, `place_images`, `place_types`, `tags`, `place_tags`, `favorites`.  
    2. Definir tipos de datos (uuid, text, double, timestamp, etc.).  
    3. Definir PK y FK, incluyendo PK compuestas donde aplique.  
    4. Diseñar índices (lat/long, FKs, búsqueda por nombre).  
    5. Documentar el esquema final (diagrama o texto).  
- **Acceptance Criteria**:  
  - Existen tablas: `places`, `place_images`, `place_types`, `tags`, `place_tags`, `favorites`.  
  - PK/FK correctas, incluyendo:  
    - PK compuesta en `favorites` (`user_id`, `place_id`).  
    - PK compuesta en `place_tags` (`place_id`, `tag_id`).  
  - Índices básicos definidos para:  
    - lat/long.  
    - claves foráneas.  
    - búsqueda por nombre (por ejemplo, índice en `places.name`).  
- **Story Points**: `3`  
- **Components**: `Supabase`  
- **Labels**: `dataschema`  

Subtareas sugeridas:
- Task: Diseñar entidades y relaciones (borrador).
- Task: Definir tipos y constraints en SQL.
- Task: Documentar el esquema final (MD o diagrama).

---

### E1-2 — Migraciones y seeds iniciales

- **Issue Type**: Story  
- **Summary**: `Migraciones y seeds iniciales`  
- **Description**:  
  - Contexto: El esquema debe poder versionarse y levantarse en cualquier entorno desde cero.  
  - Pasos sugeridos:  
    1. Crear migraciones SQL (o equivalente de Supabase CLI) para todas las tablas definidas.  
    2. Crear scripts de seeds para:  
       - `place_types` base.  
       - `tags` base.  
       - Al menos 10 lugares de ejemplo (`places` + `place_images`).  
    3. Probar ejecutar las migraciones + seeds en un entorno limpio.  
- **Acceptance Criteria**:  
  - Las migraciones se pueden ejecutar desde cero sin errores.  
  - Los seeds insertan:  
    - `place_types` y `tags` base.  
    - Al menos 10 lugares de ejemplo con imágenes de prueba.  
  - El estado de la base después de migraciones+seeds es consistente y usable para desarrollo.  
- **Story Points**: `3`  
- **Components**: `Supabase`  
- **Labels**: `seeds`  

Subtareas sugeridas:
- Task: Crear migraciones de tablas.
- Task: Crear scripts/seeds de datos base.
- Task: Probar migraciones+seeds en base limpia.

---

### E1-3 — Supabase local y pipeline

- **Issue Type**: Story  
- **Summary**: `Supabase local y pipeline`  
- **Description**:  
  - Contexto: El equipo debe poder levantar Supabase localmente y aplicar migraciones y seeds de forma repetible.  
  - Pasos sugeridos:  
    1. Configurar proyecto Supabase local (CLI o Docker).  
    2. Definir comando o script para aplicar migraciones.  
    3. Definir comando o script para aplicar seeds.  
    4. Documentar pasos para desarrolladores.  
- **Acceptance Criteria**:  
  - Supabase corre localmente con el proyecto.  
  - Hay un comando/procedimiento documentado para:  
    - Aplicar migraciones.  
    - Aplicar seeds.  
  - Un nuevo desarrollador puede levantar el backend siguiendo la guía.  
- **Story Points**: `2`  
- **Components**: `Supabase`  
- **Labels**: `devops`  

Subtareas sugeridas:
- Task: Configurar Supabase local.
- Task: Crear scripts/commands para migraciones y seeds.
- Task: Documentar pasos en el repo.

---

## E2. Backend de Clustering y APIs — Epic

- **Issue Type**: Epic  
- **Summary**: `E2: Backend de Clustering y APIs`  
- **Description**:  
  - Objetivo: Exponer un RPC bbox+zoom que devuelva clusters o puntos individuales de lugares, eficiente para el MVP.  
  - Alcance:  
    - Diseño del contrato de entrada/salida.  
    - Implementación grid-based.  
    - Endpoint accesible desde Flutter con reglas de seguridad.  
- **Components**: `Backend`, `Supabase`  
- **Labels**: `clustering`, `api`  
- **Acceptance Criteria**:  
  - El cliente Flutter puede consultar el RPC con bbox+zoom.  
  - La respuesta cumple con los criterios de zoom (clusters vs puntos individuales) y rendimiento razonable.  

### E2-1 — Contrato de RPC bbox+zoom

- **Issue Type**: Story  
- **Summary**: `Contrato RPC bbox+zoom`  
- **Description**:  
  - Contexto: Necesitamos un contrato estable entre frontend y backend para clustering.  
  - Pasos sugeridos:  
    1. Definir entrada: NE, SW, nivel de zoom.  
    2. Definir estructura de salida:  
       - Tipo `Cluster` (lat, lng, count, bounds).  
       - Tipo `Lugar` (id, lat, lng, metadata mínima).  
    3. Documentar el contrato (ejemplos de request/response).  

  - Contrato propuesto:

    - Nombre del RPC en Supabase: `get_places_clusters`

    - Request (JSON desde Flutter):

      ```json
      {
        "ne": { "lat": 41.5, "lng": 2.5 },
        "sw": { "lat": 40.0, "lng": 1.0 },
        "zoom": 8,
        "maxItems": 500,
        "filters": {
          "placeTypes": ["beach", "mountain"],
          "tags": ["hiking", "family"]
        }
      }
      ```

      - `ne`: esquina noreste del bounding box visible.
      - `sw`: esquina suroeste del bounding box visible.
      - `zoom`: nivel de zoom actual del mapa.
      - `maxItems`: límite de elementos devueltos (protección rendimiento).
      - `filters.placeTypes`: lista opcional de slugs de `place_types`.
      - `filters.tags`: lista opcional de slugs de `tags`.

    - Firma prevista del RPC en Postgres (lado Supabase):

      - `get_places_clusters(ne_lat double precision, ne_lng double precision, sw_lat double precision, sw_lng double precision, zoom integer, place_type_slugs text[] default null, tag_slugs text[] default null)`

    - Response (JSON simplificado que verá Flutter):

      ```json
      [
        {
          "type": "cluster",
          "id": "cluster-41.2-1.7-z8",
          "lat": 41.2,
          "lng": 1.7,
          "count": 37,
          "bbox": {
            "ne": { "lat": 41.25, "lng": 1.75 },
            "sw": { "lat": 41.15, "lng": 1.65 }
          }
        },
        {
          "type": "place",
          "id": "f8a1c3b2-9d7e-4a56-8b21-123456789abc",
          "lat": 41.3874,
          "lng": 2.1686,
          "name": "Mirador del Valle",
          "placeType": "viewpoint",
          "tags": ["photography", "adventure"]
        }
      ]
      ```

      - `type`: `"cluster"` o `"place"`.

      - Para `cluster`:
        - `id`: identificador sintético del cluster.
        - `lat`, `lng`: centro del cluster.
        - `count`: número de lugares dentro del cluster.
        - `bbox`: bounds aproximados del cluster (útil para debug/zoom).

      - Para `place`:
        - `id`: `places.id` (uuid).
        - `lat`, `lng`: posición del lugar.
        - `name`: nombre legible del lugar.
        - `placeType`: slug de `place_types`.
        - `tags`: lista de slugs de `tags` asociados.

    - Ejemplo de request/response por nivel de zoom:

      - Zoom bajo (p.ej. `zoom = 4`):

        - Request: bbox grande (país/región).
        - Response: principalmente items `type = "cluster"` con `count` alto.

      - Zoom alto (p.ej. `zoom = 14`):

        - Request: bbox pequeño (ciudad/zona concreta).
        - Response: principalmente items `type = "place"` (lugares individuales).

- **Acceptance Criteria**:  
  - Documentación clara del request: campos NE, SW, zoom.  
  - Documentación clara del response: lista de elementos donde cada item es Cluster o Lugar.  
  - Hay ejemplos de JSON de entrada y salida.  
- **Story Points**: `2`  
- **Components**: `Backend`  
- **Labels**: `clustering`  

Subtareas sugeridas:
- Task: Diseñar modelos de datos de entrada/salida.
- Task: Escribir ejemplos de requests/responses.
- Task: Publicar documentación (MD o similar).

---

### E2-2 — Implementar RPC grid-based

- **Issue Type**: Story  
- **Summary**: `Implementar RPC grid-based`  
- **Description**:  
  - Contexto: Implementar la lógica de clustering basada en grid dentro de Supabase/PostgreSQL (SQL o RPC).  
  - Pasos sugeridos:  
    1. Implementar lógica de grid por nivel de zoom (tamaño de celda variable).  
    2. Condición: zoom bajo/medio → clusters; zoom alto → lugares individuales.  
    3. Probar con dataset de ~1000 lugares (seeds o datos sintéticos).  
    4. Medir y ajustar rendimiento básico (índices, filtros por bbox).  
- **Acceptance Criteria**:  
  - El RPC devuelve:  
    - Clusters en zoom bajo/medio.  
    - Lugares individuales en zoom alto.  
  - Funciona correctamente con ~1000 lugares sin tiempos de respuesta excesivos.  
  - Maneja correctamente el bounding box para no traer datos fuera de la vista.  
- **Story Points**: `5`  
- **Components**: `Backend`  
- **Labels**: `clustering`, `performance`  

Subtareas sugeridas:
- Task: Implementar lógica grid-based en SQL/RPC.
- Task: Crear dataset de prueba (~1000 filas).
- Task: Medir y ajustar índices/rendimiento.

---

### E2-3 — Endpoint y seguridad

- **Issue Type**: Story  
- **Summary**: `Endpoint y seguridad RPC bbox+zoom`  
- **Description**:  
  - Contexto: Exponer el RPC al cliente Flutter de forma segura.  
  - Pasos sugeridos:  
    1. Configurar llamada al RPC desde Supabase client (o API).  
    2. Definir reglas de lectura (RLS) según sea necesario.  
    3. Probar llamadas desde un cliente de ejemplo (Postman, Flutter dev).  
- **Acceptance Criteria**:  
  - El cliente Flutter puede invocar el RPC con parámetros válidos.  
  - Las reglas de seguridad evitan lecturas no autorizadas (cuando aplique).  
  - Errores del RPC están manejados (mensajes claros).  
- **Story Points**: `3`  
- **Components**: `Backend`, `Supabase`  
- **Labels**: `seguridad`, `api`  

Subtareas sugeridas:
- Task: Configurar acceso al RPC desde el cliente Supabase.
- Task: Definir reglas RLS necesarias.
- Task: Probar desde Flutter/Postman.

---

## E3. Mapa y UX Base (Flutter) — Epic

- **Issue Type**: Epic  
- **Summary**: `E3: Mapa y UX Base (Flutter)`  
- **Description**:  
  - Objetivo: Tener un mapa interactivo que envíe bbox+zoom al backend y renderice clusters/puntos de forma fluida.  
  - Alcance:  
    - Cámara y captura de bbox/zoom.  
    - Render de clusters y lugares.  
    - Interacciones básicas (tap cluster/lugar).  
- **Components**: `Frontend`, `Flutter`  
- **Labels**: `mapa`, `ux`  
- **Acceptance Criteria**:  
  - El usuario puede moverse por el mapa y ver clusters/puntos según zoom.  
  - Tap en cluster/lugar responde correctamente.  

### E3-1 — Mapa interactivo con cámara y bbox

- **Issue Type**: Story  
- **Summary**: `Mapa interactivo con cámara y bbox`  
- **Description**:  
  - Pasos sugeridos:  
    1. Integrar widget de mapa en Flutter (lib elegida).  
    2. Capturar eventos de movimiento/zoom de cámara.  
    3. Calcular bbox y nivel de zoom actual.  
    4. Llamar al RPC de clustering enviando bbox+zoom.  
    5. Renderizar resultados de forma básica (sin aún diseño final de markers).  
- **Acceptance Criteria**:  
  - Bbox y zoom se envían al backend cuando cambia la cámara.  
  - El mapa muestra resultados en pantalla.  
- **Story Points**: `3`  
- **Components**: `Frontend`, `Flutter`  
- **Labels**: `mapa`  

Subtareas sugeridas:
- Task: Integrar mapa y configurar permisos.
- Task: Implementar escucha de cambios de cámara.
- Task: Conectar con RPC y mostrar resultados.

---

### E3-2 — Render de clusters y puntos

- **Issue Type**: Story  
- **Summary**: `Render de clusters y puntos en el mapa`  
- **Description**:  
  - Pasos sugeridos:  
    1. Definir markers distintos para:  
       - Clusters (incluyendo count).  
       - Lugares individuales.  
    2. Dibujar markers en el mapa según la respuesta del backend.  
    3. Ajustar estilo básico de markers (colores, tamaño).  
- **Acceptance Criteria**:  
  - Clusters se ven claramente diferenciados de lugares.  
  - El marker de cluster muestra el conteo.  
- **Story Points**: `5`  
- **Components**: `Frontend`, `Flutter`  
- **Labels**: `mapa`, `ui`  

Subtareas sugeridas:
- Task: Diseñar widgets/markers para cluster y lugar.
- Task: Mapear datos del RPC a markers.
- Task: Ajustar estilos y verificar en varios niveles de zoom.

---

### E3-3 — Interacciones del mapa

- **Issue Type**: Story  
- **Summary**: `Interacciones del mapa (clusters y lugares)`  
- **Description**:  
  - Pasos sugeridos:  
    1. Manejar tap en marker de cluster:  
       - Calcular bounds del cluster.  
       - Hacer zoom a esa área.  
    2. Manejar tap en lugar:  
       - Navegar a la pantalla de detalle del lugar.  
- **Acceptance Criteria**:  
  - Tap en cluster → zoom automático al área del cluster.  
  - Tap en lugar → se abre la vista de detalle.  
- **Story Points**: `3`  
- **Components**: `Frontend`, `Flutter`  
- **Labels**: `mapa`, `ux`  

Subtareas sugeridas:
- Task: Implementar handler tap en cluster.
- Task: Implementar handler tap en lugar.
- Task: Conectar navegación a pantalla de lugar.

---

## E4. Vista de Lugar — Epic

- **Issue Type**: Epic  
- **Summary**: `E4: Vista de Lugar`  
- **Description**:  
  - Objetivo: Mostrar información detallada de un lugar, con imágenes y opción de favorito.  
- **Components**: `Frontend`, `Flutter`  
- **Labels**: `lugar`, `detalle`  
- **Acceptance Criteria**:  
  - Al abrir un lugar, se ve toda la info definida en el PLAN.  

### E4-1 — Pantalla de detalle

- **Issue Type**: Story  
- **Summary**: `Pantalla de detalle de lugar`  
- **Description**:  
  - Pasos sugeridos:  
    1. Crear pantalla que reciba `place_id`.  
    2. Consultar los datos del lugar (nombre, descripción, `best_season`, imágenes).  
    3. Implementar carrusel de imágenes.  
    4. Mostrar botón de favorito (habilitado sólo si el usuario está autenticado).  
- **Acceptance Criteria**:  
  - Se muestra: nombre, descripción corta, `best_season`.  
  - Carrusel de imágenes funcional.  
  - Botón de favorito visible si el usuario está autenticado.  
- **Story Points**: `5`  
- **Components**: `Frontend`, `Flutter`  
- **Labels**: `lugar`, `detalle`  

Subtareas sugeridas:
- Task: Implementar layout de detalle.
- Task: Integrar carrusel de imágenes.
- Task: Integrar estado de favorito (UI, sin persistencia si se hace en otra historia).

---

## E5. Autenticación y Favoritos — Epic

- **Issue Type**: Epic  
- **Summary**: `E5: Autenticación y Favoritos`  
- **Description**:  
  - Objetivo: Habilitar login con Google y manejo de favoritos persistentes por usuario.  
- **Components**: `Frontend`, `Backend`  
- **Labels**: `auth`, `favoritos`  
- **Acceptance Criteria**:  
  - Un usuario puede autenticarse con Google.  
  - Los favoritos se guardan por `user_id` y se pueden listar.  

### E5-1 — Configurar OAuth de Google (GCP + Supabase)

- **Issue Type**: Story  
- **Summary**: `Configurar OAuth de Google (GCP + Supabase)`  
- **Description**:  
  - Pasos sugeridos:  
    1. Crear proyecto en Google Cloud Console.  
    2. Configurar pantalla de consentimiento OAuth.  
    3. Crear credenciales OAuth (Client ID/Secret).  
    4. Configurar redirect URIs en Supabase para web/móvil.  
    5. Documentar variables de entorno necesarias.  
- **Acceptance Criteria**:  
  - Credenciales creadas en GCP.  
  - Redirect URIs correctas en Supabase.  
  - Variables de entorno documentadas para local/prod.  
- **Story Points**: `3`  
- **Components**: `Backend`  
- **Labels**: `auth`, `gcp`  

Subtareas sugeridas:
- Task: Crear proyecto y credenciales en GCP.
- Task: Configurar OAuth en Supabase.
- Task: Documentar env vars.

---

### E5-2 — Login con Google

- **Issue Type**: Story  
- **Summary**: `Login con Google (Supabase Auth)`  
- **Description**:  
  - Pasos sugeridos:  
    1. Integrar Supabase Auth con proveedor Google en Flutter.  
    2. Implementar flujo de login (botón, redirecciones, callback).  
    3. Persistir estado de sesión (token/usuario) entre reinicios de app.  
    4. Implementar logout y manejo de errores de login.  
- **Acceptance Criteria**:  
  - Login con Google funciona de extremo a extremo.  
  - La sesión persiste tras reiniciar la app.  
  - Existe opción de logout y errores se muestran de forma amigable.  
- **Story Points**: `3`  
- **Components**: `Frontend`, `Backend`  
- **Labels**: `auth`  

Subtareas sugeridas:
- Task: Integrar SDK de Supabase Auth en Flutter.
- Task: Implementar UI de login/logout.
- Task: Manejar persistencia de sesión y errores.

---

### E5-3 — Persistir favorito

- **Issue Type**: Story  
- **Summary**: `Favoritos: toggle y lista`  
- **Description**:  
  - Pasos sugeridos:  
    1. Implementar acción de toggle favorito:  
       - Si no existe registro en `favorites`, crearlo.  
       - Si existe, eliminarlo.  
    2. Conectar botón de favorito en la vista de lugar.  
    3. Crear una pantalla/lista simple de favoritos.  
    4. Proteger acciones de favoritos: requieren usuario autenticado.  
- **Acceptance Criteria**:  
  - Toggle guardar/quitar funciona con feedback de UI.  
  - Existe lista de favoritos accesible desde la app.  
  - No se pueden usar favoritos sin `user_id` autenticado.  
- **Story Points**: `5`  
- **Components**: `Frontend`, `Backend`  
- **Labels**: `favoritos`  

Subtareas sugeridas:
- Task: Implementar llamadas a tabla `favorites`.
- Task: Conectar botón de favorito en detalle.
- Task: Crear pantalla de lista de favoritos.

---

## E6. Gestión de Contenido (MVP) — Epic

- **Issue Type**: Epic  
- **Summary**: `E6: Gestión de Contenido (MVP)`  
- **Description**:  
  - Objetivo: Tener un flujo mínimo para gestionar contenido usando Supabase Table Editor y seeds.  
- **Components**: `Docs`, `Supabase`  
- **Labels**: `contenido`  
- **Acceptance Criteria**:  
  - Existe guía operativa clara para gestionar contenido.  

### E6-1 — Flujo operativo Supabase

- **Issue Type**: Story  
- **Summary**: `Flujo operativo Supabase para contenido`  
- **Description**:  
  - Pasos sugeridos:  
    1. Definir cómo usar Supabase Table Editor para CRUD de: `places`, `place_images`, `place_types`, `tags`, `place_tags`.  
    2. Definir si habrá scripts adicionales para cargas masivas.  
    3. Documentar el flujo paso a paso.  
- **Acceptance Criteria**:  
  - Guía de uso del Table Editor para CRUD de contenido.  
  - Script/seed para carga masiva inicial documentado.  
- **Story Points**: `2`  
- **Components**: `Docs`, `Supabase`  
- **Labels**: `contenido`  

Subtareas sugeridas:
- Task: Definir flujo manual con Table Editor.
- Task: Definir scripts para cargas masivas (si aplica).
- Task: Documentar en el repo.

---

## E7. Pulido y Performance — Epic

- **Issue Type**: Epic  
- **Summary**: `E7: Pulido y Performance`  
- **Description**:  
  - Objetivo: Mejorar la percepción de calidad con skeletons, manejo de errores y caché básico.  
- **Components**: `Frontend`  
- **Labels**: `ux`, `performance`  
- **Acceptance Criteria**:  
  - La app muestra loaders adecuados, mensajes de error útiles y reduce parpadeos en el mapa.  

### E7-1 — Skeleton loaders

- **Issue Type**: Story  
- **Summary**: `Skeleton loaders en mapa y detalle`  
- **Description**:  
  - Pasos sugeridos:  
    1. Implementar placeholders/skeletons para:  
       - Carga del mapa y markers.  
       - Carga de la vista de lugar.  
    2. Integrar los loaders con el estado de carga real (no hardcode).  
- **Acceptance Criteria**:  
  - Hay placeholders visibles mientras carga el mapa.  
  - Hay placeholders visibles mientras carga la vista de lugar.  
- **Story Points**: `2`  
- **Components**: `Frontend`  
- **Labels**: `ux`  

Subtareas sugeridas:
- Task: Diseñar skeletons para mapa.
- Task: Diseñar skeletons para vista de lugar.
- Task: Conectar con estados de carga.

---

### E7-2 — Manejo de errores

- **Issue Type**: Story  
- **Summary**: `Manejo de errores de red y autenticación`  
- **Description**:  
  - Pasos sugeridos:  
    1. Definir mensajes de error estándar para:  
       - Fallo de red.  
       - Fallo de autenticación.  
       - Errores del backend (RPC).  
    2. Mostrar mensajes claros en la UI.  
    3. Loguear errores críticos de forma controlada.  
- **Acceptance Criteria**:  
  - Mensajes amigables en fallas de red y autenticación.  
  - No se muestra texto técnico crudo al usuario final.  
- **Story Points**: `3`  
- **Components**: `Frontend`, `Backend`  
- **Labels**: `ux`, `errores`  

Subtareas sugeridas:
- Task: Definir catálogo de errores/mensajes.
- Task: Implementar manejo de errores en Flutter.
- Task: Ajustar logging en backend/frontend.

---

### E7-3 — Caching básico

- **Issue Type**: Story  
- **Summary**: `Caching básico de respuesta de clusters`  
- **Description**:  
  - Pasos sugeridos:  
    1. Implementar caché en cliente para última respuesta de clusters.  
    2. Usar caché para minimizar parpadeos cuando el zoom cambia poco.  
    3. Definir estrategia de expiración (tiempo o cambios de bbox significativos).  
- **Acceptance Criteria**:  
  - Menos parpadeos en el mapa al mover ligeramente la cámara.  
  - Caché se invalida correctamente cuando cambia mucho la vista.  
- **Story Points**: `3`  
- **Components**: `Frontend`  
- **Labels**: `performance`, `mapa`  

Subtareas sugeridas:
- Task: Implementar estructura de caché.
- Task: Conectar caché con lógica de mapa.
- Task: Probar con diferentes movimientos de cámara.

---

## E8. Open Source y Release — Epic

- **Issue Type**: Epic  
- **Summary**: `E8: Open Source y Release`  
- **Description**:  
  - Objetivo: Dejar el proyecto listo como pieza open source presentable, con documentación y licencia.  
- **Components**: `Docs`  
- **Labels**: `release`, `opensource`  
- **Acceptance Criteria**:  
  - Repositorio público con README, licencia y roadmap claros.  

### E8-1 — Documentación y licencia

- **Issue Type**: Story  
- **Summary**: `README y licencia`  
- **Description**:  
  - Pasos sugeridos:  
    1. Escribir README con:  
       - Descripción del proyecto.  
       - Requisitos.  
       - Pasos de instalación y ejecución (frontend + Supabase).  
       - Capturas de pantalla del mapa y vista de lugar.  
    2. Elegir licencia (MIT, Apache 2.0, etc.) y añadir archivo de licencia.  
- **Acceptance Criteria**:  
  - README claro con instrucciones y al menos una captura de pantalla.  
  - Licencia aplicada en el repositorio.  
- **Story Points**: `2`  
- **Components**: `Docs`  
- **Labels**: `release`  

Subtareas sugeridas:
- Task: Redactar README.
- Task: Añadir licencia.
- Task: Actualizar capturas de pantalla.

---

### E8-2 — Roadmap público

- **Issue Type**: Story  
- **Summary**: `Roadmap público`  
- **Description**:  
  - Pasos sugeridos:  
    1. Crear sección de roadmap (en README o docs).  
    2. Detallar:  
       - Alcance del MVP (lo que ya estás planificando).  
       - Evolución futura (features fuera del MVP).  
- **Acceptance Criteria**:  
  - Roadmap público que distingue MVP vs futuro.  
- **Story Points**: `2`  
- **Components**: `Docs`  
- **Labels**: `release`, `roadmap`  

Subtareas sugeridas:
- Task: Definir backlog futuro (alto nivel).
- Task: Redactar sección de roadmap.
- Task: Revisar coherencia con `SCRUM_PLAN.md`.

---

## Uso sugerido en Jira

- Crea primero las **Épicas** E1–E8 con sus Summary y Description.  
- Luego crea cada **Story** bajo su Epic correspondiente, copiando Summary, Description y Acceptance Criteria.  
- Usa **Story Points**, **Components** y **Labels** tal como se describen aquí para facilitar filtros y planificación.  
