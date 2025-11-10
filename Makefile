default:
	@echo "build all"
	podman compose build

up: default
	@echo "start locally with watch"
	podman compose up --watch

up_prod: default
	@echo "start locally but with remote images"
	podman compose -f compose.yml -f compose.prod.yml up -d

logs:
	podman compose logs -f

down:
	podman compose down

clean: down
	@echo "cleaning up"
	podman system prune -f
	podman volume prune -f