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