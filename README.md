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
los OAuth Client ID de Google se usan en varios archivos. Cuando cambies de
proyecto en Google Cloud o regeneres las credenciales, revisa y actualiza:

- Android:
  - IDs configurables por `--dart-define`:
    - `LUMAVIEW_ANDROID_CLIENT_ID`
    - `LUMAVIEW_ANDROID_SERVER_CLIENT_ID`
  - Se consumen desde las constantes `_androidClientId` y
    `_androidServerClientId` en  
    `lib/features/auth/data/repositories/auth_repository_impl.dart`.
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

Ejemplo de ejecución en desarrollo con IDs propios:

```bash
flutter run \
  --dart-define=LUMAVIEW_ANDROID_CLIENT_ID=TU_ANDROID_CLIENT_ID \
  --dart-define=LUMAVIEW_ANDROID_SERVER_CLIENT_ID=TU_ANDROID_SERVER_CLIENT_ID
```
