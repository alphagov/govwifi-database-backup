build:
	docker-compose down
	docker-compose up -d db fake-s3
	docker-compose build
	./mysql/wait_for_services & wait
	docker-compose up app

test: build
	./tests/test_backup_files_exist

destroy:
	docker-compose down --volumes

.PHONY: build test destroy
	
