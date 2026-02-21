# Plan Scrum — Lumaview (Explorador Visual de Lugares Turísticos)

Este documento traduce el PLAN del MVP a un backlog Scrum accionable, con épicas, historias, criterios de aceptación y una guía paso a paso para crear y configurar el proyecto en Jira.

## 1. Enfoque y Cadencia
- Marco: Scrum enfocado a un MVP terminable.
- Sprint: 2 semanas.
- Estimación: Story Points (1, 2, 3, 5, 8, 13) basados en complejidad, no en horas.
- Prioridad: Entregar valor visible en mapa y exploración primero.
- Criterio: UX fluida y backend eficiente > cantidad de features.
- Requisito MVP: Autenticación con Google habilitada para gestionar favoritos.

Uso de IA y agentes:
- La IA acelera la implementación, pero los Story Points siguen midiendo esfuerzo relativo.
- Esperar más velocidad (más SP completados por sprint), no SP “más pequeños”.

## 2. Definiciones
- Definition of Ready (DoR):
  - Historia tiene contexto, alcance claro, criterios de aceptación y riesgos conocidos.
  - Dependencias identificadas (datos, endpoints, credenciales).
  - Prototipo o posturas técnicas alineadas cuando aplique.
- Definition of Done (DoD):
  - Criterios de aceptación verificados.
  - Sin errores críticos.
  - Código revisado, tipado y linteado.
  - Logs/errores manejados.
  - Documentación mínima para uso y despliegue.

## 3. Épicas
E1. Datos y Migraciones (Supabase)
- Objetivo: Esquema versionado y datos iniciales para places, place_types, tags, place_tags, place_images, favorites.

E2. Backend de Clustering y APIs
- Objetivo: RPC bbox+zoom que retorna clusters o lugares individuales, eficiente y probado.

E3. Mapa y UX Base (Flutter)
- Objetivo: Mapa interactivo con clustering visual, cámaras y animaciones básicas.

E4. Vista de Lugar
- Objetivo: Detalle de lugar con carrusel de imágenes, descripción, temporada y favorito.

E5. Autenticación y Favoritos (Indispensable)
- Objetivo: Login con Google y persistencia de favoritos con lista simple en la app.

E6. Gestión de Contenido (MVP)
- Objetivo: Flujo operativo con Supabase Table Editor + seeds SQL; guías mínimas.

E7. Pulido y Performance
- Objetivo: Skeleton loaders, manejo de errores y caching básico.

E8. Open Source y Release
- Objetivo: README claro, licencia, screenshots y roadmap público.

## 4. Historias por Épica (con criterios de aceptación)

E1. Datos y Migraciones
1) Definir esquema SQL MVP
- Aceptación:
  - Tablas: places, place_images, place_types, tags, place_tags, favorites.
  - Constraints y PK/FK correctas (incluye PK compuesta en favorites y place_tags).
  - Índices básicos en lat/long, FKs y búsqueda por nombre.
2) Migraciones y seeds iniciales
- Aceptación:
  - Migraciones reproducibles localmente (Supabase).
  - Seeds con place_types y tags base cargados.
  - 10+ lugares de ejemplo con imágenes de prueba.
3) Supabase local y pipeline
- Aceptación:
  - Proyecto corre con Supabase local.
  - Script o pasos documentados para aplicar migraciones y seeds.

E2. Backend de Clustering y APIs
1) Contrato de RPC bbox+zoom
- Aceptación:
  - Definida la entrada: NE, SW, nivel de zoom.
  - Definida la salida: lista de Cluster y Lugar con metadatos mínimos.
2) Implementar RPC grid-based
- Aceptación:
  - Responde clusters en zoom bajo/medio y lugares en zoom alto.
  - Pruebas con dataset de ejemplo.
  - Rendimiento razonable en ~1000 lugares.
3) Endpoint y seguridad
- Aceptación:
  - Cliente Flutter puede invocar RPC con parámetros válidos.
  - Reglas de lectura seguras (RLS cuando aplique).

E3. Mapa y UX Base (Flutter)
1) Mapa interactivo con cámara y bbox
- Aceptación:
  - Se captura y envía bbox y zoom al backend en cambios de cámara.
  - Render básico de resultados.
2) Render de clusters y puntos
- Aceptación:
  - Diferentes marcadores para cluster vs lugar.
  - Conteo visible en marker de cluster.
3) Interacciones del mapa
- Aceptación:
  - Tap en cluster acerca el zoom a su área.
  - Tap en lugar abre vista detallada.

E4. Vista de Lugar
1) Pantalla de detalle
- Aceptación:
  - Muestra nombre, descripción, best_season.
  - Carrusel de imágenes funcional.
  - Botón favorito visible si el usuario está autenticado.

E5. Autenticación y Favoritos
1) Configurar OAuth de Google (GCP + Supabase)
- Aceptación:
  - Credenciales creadas en Google Cloud (OAuth consent y Client ID).
  - Redirect URIs configuradas en Supabase para web y móvil.
  - Variables de entorno documentadas para entornos local/prod.
2) Login con Google
- Aceptación:
  - Flujo de autenticación funcionando con Supabase Auth (proveedor Google).
  - Estado de sesión persistente tras reiniciar la app.
  - Cierre de sesión disponible y manejo de errores de login.
3) Persistir favorito
- Aceptación:
  - Toggle guardar/quitar en favorites con feedback de UI.
  - Lista de favoritos accesible en un apartado simple.
  - Acciones de favoritos requieren usuario autenticado (user_id disponible).

E6. Gestión de Contenido (MVP)
1) Flujo operativo Supabase
- Aceptación:
  - Guía de uso del Table Editor para CRUD de contenido.
  - Script/seed para carga masiva inicial.

E7. Pulido y Performance
1) Skeleton loaders
- Aceptación:
  - Placeholders en mapa y vista de lugar mientras carga.
2) Manejo de errores
- Aceptación:
  - Mensajes amigables en fallas de red/autenticación.
3) Caching básico
- Aceptación:
  - Caché de última respuesta de clusters para minimizar parpadeos.

E8. Open Source y Release
1) Documentación y licencia
- Aceptación:
  - README con instrucciones de desarrollo y captura de pantalla.
  - Licencia elegida aplicada.
2) Roadmap público
- Aceptación:
  - Sección de roadmap con alcance del MVP y futuro.

## 5. Plan de Sprints (propuesta)
- Sprint 1:
  - E1: esquema, migraciones y seeds.
  - E2: contrato RPC + primera versión del clustering.
  - E3: mapa interactivo con bbox y render básico.
- Sprint 2:
  - E2: performance y seguridad de RPC.
  - E3: interacciones y markers de cluster.
  - E5: Login con Google (configuración OAuth + flujo básico).
  - E4: vista de lugar.
- Sprint 3:
  - E5: favoritos (toggle y lista).
  - E7: skeletons, errores, caché.
  - E8: documentación y release.

## 6. Jira: Paso a Paso (Team-managed recomendado para proyecto personal)
1) Crear proyecto
- En Jira, Create project → Software → Scrum → Team-managed.
- Nombre: “Lumaview”.
2) Issue types
- Habilitar: Epic, Story, Task, Bug.
- Estimación con “Story Points”.
3) Campos y etiquetas
- Activar campo “Story Points”.
- Usar Components: Frontend, Backend, Supabase, Flutter, Docs.
- Usar Labels para filtros adicionales (por ejemplo: mapa, clustering, favoritos, contenido).
4) Workflow y columnas
- Columnas: To Do → In Progress → In Review → Done.
- Regla: Done establece resolución “Done”.
5) Board settings
- Swimlanes por Epic.
- Quick filters por Component (Frontend, Backend, etc.).
6) Estimación y planificación
- Crear las Épicas (E1…E8) y sus Historias como Stories.
- Estimar en SP y priorizar por valor (mapa y clustering primero).
7) Automatizaciones (opcionales)
- Al mover a In Review, notificar en Slack/Email (si lo tienes).
- Al mergear a main (si conectas con VCS), mover a Done.

## 7. Backlog Inicial (lista resumida)
- E1: Definir esquema SQL MVP (3), Migraciones y seeds (3), Supabase local/pipeline (2)
- E2: Contrato RPC bbox+zoom (2), Implementar RPC grid-based (5), Endpoint y seguridad (3)
- E3: Mapa con cámara y bbox (3), Render clusters y puntos (5), Interacciones (3)
- E4: Pantalla de detalle (5)
- E5: Configurar OAuth Google (3), Login con Google (3), Persistir favorito y lista (5)
- E6: Flujo operativo Supabase (2)
- E7: Skeleton loaders (2), Manejo de errores (3), Caching básico (3)
- E8: README+licencia (2), Roadmap público (2)

## 8. Importación por CSV (opcional)
Usa la importación de issues de Jira. Ajusta nombres de columnas según tu instancia. Formato ejemplo:

Columnas: Issue Type, Summary, Epic Name, Parent, Description, Story Points, Components, Labels

Ejemplos:
- Epic, E1: Datos y Migraciones, E1,,, , Supabase
- Epic, E2: Backend de Clustering y APIs, E2,,, , Backend
- Epic, E3: Mapa y UX Base, E3,,, , Frontend
- Story, Definir esquema SQL MVP,,E1,Tablas y constraints según PLAN,3,Supabase,dataschema
- Story, Migraciones y seeds iniciales,,E1,Migraciones reproducibles y seeds base,3,Supabase,seeds
- Story, Contrato RPC bbox+zoom,,E2,Entrada/salida definidas y documentadas,2,Backend,clustering
- Story, Implementar RPC grid-based,,E2,Clusters por zoom y pruebas con dataset,5,Backend,clustering
- Story, Mapa con cámara y bbox,,E3,Enviar bbox+zoom y render básico,3,Frontend,mapa
- Story, Render clusters y puntos,,E3,Markers para clusters y lugares,5,Frontend,mapa
- Story, Interacciones del mapa,,E3,Tap cluster → zoom; tap lugar → detalle,3,Frontend,mapa
- Story, Pantalla de detalle,,E4,Nombre, imágenes, descripción, temporada,5,Frontend,lugar
- Story, Login con Google,,E5,Autenticación básica y estado,3,Frontend;Backend,auth
- Story, Favoritos: toggle y lista,,E5,Guardar/quitar y listar favoritos,5,Frontend;Backend,favoritos
- Story, Flujo operativo Supabase,,E6,Guía de Table Editor y seeds,2,Docs,contenido
- Story, Skeleton loaders,,E7,Placeholders en mapa y detalle,2,Frontend,ux
- Story, Manejo de errores,,E7,Mensajes amigables y rutas de fallo,3,Frontend;Backend,ux
- Story, Caching básico,,E7,Reducir parpadeos en mapa,3,Frontend,performance
- Story, README y licencia,,E8,Instrucciones y licencia aplicada,2,Docs,release
- Story, Roadmap público,,E8,Sección roadmap con alcance claro,2,Docs,release

Sugerencia: importa primero las Épicas, luego las Stories referenciando el nombre del Epic en “Parent” o “Epic Link” según tu plantilla.

## 9. Riesgos y Mitigaciones
- Clustering con datasets grandes: empezar con grid simple; optimizar índices; limitar bbox.
- Imágenes: usar tamaños razonables y carga diferida en carrusel.
- Autenticación: limitarse a Google para el MVP.
- Alcance: congelar historias fuera del MVP en el backlog futuro (no traerlas a sprint).

## 10. Siguientes pasos inmediatos
- Crear el proyecto en Jira y las épicas E1–E8.
- Poner en el primer Sprint: E1 y partes de E2/E3.
- Estimar y arrancar con DoR/DoD visibles en la descripción del proyecto.
