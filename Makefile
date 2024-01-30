default:
	@echo "build all"
	docker compose build

up: default
	@echo "start locally"
	docker compose up -d

up_prod: default
	@echo "start locally but with remote images"
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

logs:
	docker-compose logs -f

down:
	docker-compose down

clean: down
	@echo "cleaning up"
	docker system prune -f
	docker volume prune -f