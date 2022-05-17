# Configuración del proyecto

## Cosas a modificar:
* En el `.env` modificar el nombre del proyecto.
* Revisar las versiones de nginx y postgres en el `docker-compose.yml`.
* Revisar la versión de python en el Dockerfile.

## Añadir una nueva app:
1. mm
2. Añadir en `src/_setup/settings`, en el array `INSTALLED_APPS`, las el nombre de la nueva app.

## Añadir fixtures:
* Añadir la carpeta `src/fixtures/`.
* Meter en esa carpeta todos los archivos de las fixtures (.json).
* En el archivo `src/entry_points.sh`, añadir la línea `python manage.py loaddata ./fixtures/*` después de las migraciones.
* En el Makefile meter algo como esto: 
```yml
create-fixtures:
    docker exec -it ${COMPOSE_PROJECT_NAME}_django bash -c "python manage.py dumpdata <nombres de las clases> -o ./fixtures/<nombre_fichero>.json --natural-foreign"
```