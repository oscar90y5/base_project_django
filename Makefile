include .env
export

up:
	docker compose -f docker-compose.yml up --build -d

down:
	docker compose -f docker-compose.yml down

downup:
	docker compose -f docker-compose.yml down; \
	docker compose -f docker-compose.yml up --build -d

shell:
	docker exec -it ${COMPOSE_PROJECT_NAME}_django bash

test:
	docker exec ${COMPOSE_PROJECT_NAME}_django bash -c "python -Wa manage.py test --keepdb"

migrate:
	docker exec -it ${COMPOSE_PROJECT_NAME}_django bash -c "python manage.py makemigrations && python manage.py migrate"

logs:
	docker logs -f --tail 200 ${COMPOSE_PROJECT_NAME}_django

restart:
	docker restart ${COMPOSE_PROJECT_NAME}_django

restart-nginx:
	docker restart ${COMPOSE_PROJECT_NAME}_nginx
