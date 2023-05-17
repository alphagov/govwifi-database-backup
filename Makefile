build:
	docker-compose down
	docker-compose up --build -d db fake-s3
	docker-compose exec -T fake-s3 awslocal s3 mb s3://backup-bucket &> /dev/null
	./mysql/wait_for_services & wait
	docker-compose up app

test: build
	./tests/test_backup_files_exist

destroy:
	docker-compose down --volumes

.PHONY: build test destroy
	
