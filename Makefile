build:
	docker-compose down
	docker-compose up -d db fake-s3
	docker-compose build
	./mysql/wait_for_services & wait
	docker-compose up app

destroy:
	docker-compose down --volumes

.PHONY: build test destroy
	
