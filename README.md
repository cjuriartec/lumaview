# Lumaview

Backend local (Supabase):

- Arrancar servicios locales:

```bash
supabase start
```

- Aplicar migraciones y seeds:

```bash
supabase db reset
```

Más detalles en `docs/dev/DEV_BACKEND_SUPABASE.md`.

## IDs de cliente de Google (OAuth)

Para que el login con Google funcione y sea fácil de replicar en otro entorno,
los OAuth Client ID de Google se usan en varios archivos y variables de
entorno. Cuando cambies de proyecto en Google Cloud o regeneres las
credenciales, revisa y actualiza:

- Android:
  - Variables en `.env` / `.env.example`:
    - `LUMAVIEW_ANDROID_CLIENT_ID`
    - `LUMAVIEW_ANDROID_SERVER_CLIENT_ID`
  - Estas variables se pasan a Flutter con `--dart-define` (por ejemplo desde
    scripts de desarrollo) y se consumen desde las constantes `_androidClientId`
    y `_androidServerClientId` en  
    `lib/features/auth/data/repositories/auth_repository_impl.dart` y desde
    `Env.config` en  
    `lib/config/env/env_config.dart`.
- Web:
  - Actualmente el login con Google en web no está habilitado (se lanza una
    excepción en `AuthRepositoryImpl` cuando `kIsWeb`), por lo que no se usa un
    `google-signin-client_id` en `web/index.html`. Si en el futuro habilitas
    login en web, deberás añadir el meta con el Client ID correspondiente.
- iOS:
  - Clave `GIDClientID` y esquema de URL (`CFBundleURLSchemes`) en
    `ios/Runner/Info.plist`, que deben apuntar al **iOS Client ID** que
    configures en Google Cloud Console.

Además, en Supabase debes habilitar el proveedor **Google** y configurar los
Client ID correspondientes en la sección de autenticación del panel.

### Ejecución con `.env` (como en VS Code)

El proyecto está preparado para leer las variables desde `.env` usando
`--dart-define-from-file=.env`, igual que en
`.vscode/launch.json`:

- `lumaview (debug)`
- `lumaview (profile)`
- `lumaview (release)`

Si quieres lanzar la app desde la terminal, el equivalente es:

```bash
flutter run --dart-define-from-file=.env
```
