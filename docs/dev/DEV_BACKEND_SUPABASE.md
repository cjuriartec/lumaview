## Supabase local y pipeline de datos

### Requisitos previos

- Docker y Docker Compose instalados.
- Supabase CLI instalado y autenticado.

### Comandos principales

- Arrancar Supabase local con todos los servicios:

```bash
supabase start
```

- Reiniciar completamente la base de datos local, aplicando migraciones y seeds:

```bash
supabase db reset
```

Esto ejecuta:
- Migraciones de `supabase/migrations/`.
- Seeds definidos en `supabase/seed.sql`.

- Aplicar solo migraciones (sin tocar datos de producción local ya existentes):

```bash
supabase db push
```

### Estructura relacionada

- `supabase/config.toml`: configuración del proyecto local.
- `supabase/migrations/`: migraciones versionadas (esquema y funciones).
- `supabase/seed.sql`: datos iniciales de ejemplo para desarrollo.

### Flujo para un nuevo desarrollador

1. Clonar el repositorio.
2. Instalar Supabase CLI.
3. Ejecutar:

```bash
supabase start
supabase db reset
```

4. Verificar en Supabase Studio que existen:
   - Tablas `places`, `place_images`, `place_types`, `tags`, `place_tags`, `favorites`.
   - Datos de ejemplo cargados desde `supabase/seed.sql`.

