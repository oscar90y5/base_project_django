# Configuración del proyecto

## Cosas a modificar:
* En el `.env` modificar el nombre del proyecto.
* Revisar las versiones de nginx y postgres en el `docker-compose.yml`.
* Revisar la versión de python en el Dockerfile.

## Añadir una nueva app:
1. mm
2. Añadir en `src/_setup/settings`, en el array `INSTALLED_APPS`, las el nombre de la nueva app.

## Añadir allauth (más configurar Google):
Se seguirá el [este tutorial](https://dev.to/mdrhmn/django-google-authentication-using-django-allauth-18f8). 

1. Configurción de Django:
   1. Añadir `django-allauth` en `requirements.pip`.
   2. En `src/_setup/settings`, en el array `INSTALLED_APPS`, añadir las siguientes apps:
       * `django.contrib.sites`
       * `allauth`
       * `allauth.account`
       * `allauth.socialaccount`
       * Además, añadir un provider por cada red social que quieras usar:
         * `allauth.socialaccount.providers.facebook`
         * `allauth.socialaccount.providers.google`
         * `allauth.socialaccount.providers.twitter`
   3. En `AUTHENTICATION_BACKENDS`, añadir las siguientes líneas:
      * `django.contrib.auth.backends.ModelBackend`,
      * `allauth.account.auth_backends.AuthenticationBackend`
   4. Añadimos `SITE_ID` y especificamos la URL a la que queremos que nos redirija. Además, podemos añadir alguna configuración extra:
   ```python
   SITE_ID = 1
   LOGIN_REDIRECT_URL = '/'
   
   # Additional configuration settings
   SOCIALACCOUNT_QUERY_EMAIL = True
   ACCOUNT_LOGOUT_ON_GET= True
   ACCOUNT_UNIQUE_EMAIL = True
   ACCOUNT_EMAIL_REQUIRED = True
   ```
   5. Añadimos un `SOCIALACCOUNT_PROVIDERS` por cada red social. Ejemplo de Google:
   ```python
   SOCIALACCOUNT_PROVIDERS = {
       'google': {
           'SCOPE': [
               'profile',
               'email',
           ],
           'AUTH_PARAMS': {
               'access_type': 'online',
           }
       }
   }
   ```
   6. En `urls.py`, añadimos el path `path('accounts/', include('allauth.urls'))`.
2. Configuramos Google APIs:
   1. Creamos un nuevo proyecto en Google APIs.
   2. Registramos la app en "Pantalla de consentimiento de Oauth".
   3. Creamos unos credenciales nuevos en "Credenciales":
      1. Origenes autorizados de JavaScript:
         * `http://localhost:8000`
         * `http://127.0.0.1:8000`
      2. URI de redireccionamiento autorizados:
         * `http://localhost:8000/accounts/google/login/callback`
         * `http://127.0.0.1:8000/accounts/google/login/callback/`
   4. En Django añadimos una `Social Application` con la sigueunte información:
      * Provider: Google
      * Name: `<APP_NAME>`
      * Client id: `<CLIENT_ID>`
      * Secret key: `<SECRET_KEY>`
      * Sites: Selecciona tu página.

Para probar que todo ha ido bien, accedemos a la url `http://localhost:8000/accounts/google/login/`.



## Añadir fixtures:
* Añadir la carpeta `src/fixtures/`.
* Meter en esa carpeta todos los archivos de las fixtures (.json).
* En el archivo `src/entry_points.sh`, añadir la línea `python manage.py loaddata ./fixtures/*` después de las migraciones.
* En el Makefile meter algo como esto: 
```yml
create-fixtures:
    docker exec -it ${COMPOSE_PROJECT_NAME}_django bash -c "python manage.py dumpdata <nombres de las clases> -o ./fixtures/<nombre_fichero>.json --natural-foreign"
```

## Añadir Swagger
* Instalar drf_spectacular:
  * Añadir `drf-spectacular==0.22.1` en `requirements.pip`.
  * En `INSTALLED_APPS` añadir `drf_spectacular`.
* Añadir el fichero `swagger-ui.html` a la carpeta `_setup/templates` con el siguiente contenido:
```html
<!DOCTYPE html>
<html>

<head>
    <title>Swagger</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3/swagger-ui.css">
</head>

<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@3/swagger-ui-bundle.js"></script>
    <script>
        const ui = SwaggerUIBundle({
            url: "{% url 'schema' %}",
            dom_id: '#swagger-ui',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIBundle.SwaggerUIStandalonePreset
            ],
            layout: "BaseLayout",
            requestInterceptor: (request) => {
                request.headers['X-CSRFToken'] = "{{ csrf_token }}"
                return request;
            }
        })
    </script>
</body>

</html>
```
* En el fichero `_setup/urls.py`, añadir las siguientes líneas:
```python
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
    path(
        "docs/",
        SpectacularSwaggerView.as_view(
            template_name="swagger-ui.html", url_name="schema"
        ),
        name="swagger-ui",
    ),
```
* En `settings.py`:
  * Añadir en `TEMPLATES` el elemento `f'{BASE_DIR}/_setup/templates'` dentro de la lista `'DIRS'`.
  * En el diccionario `REST_FRAMEWORK` añadir el elemento `'DEFAULT_SCHEMA_CLASS'` con valor `'drf_spectacular.openapi.AutoSchema'`.
  * Añadir ciertos metadatos a la API. Por ejemplo:
```python
SPECTACULAR_SETTINGS = {
    'TITLE': 'Your Project API',
    'DESCRIPTION': 'Your project description',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    # OTHER SETTINGS
}
```