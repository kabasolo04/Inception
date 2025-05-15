NGINX_IMG_NAME	=	mynginx
NGINX_PATH		=	./srcs/nginx/
NGINX_DOC_PATH	=	$(NGINX_PATH)Dockerfile

built:
	docker build -t $(NGINX_IMG_NAME) -f $(NGINX_DOC_PATH) $(NGINX_PATH)
	docker run -p 8080:8080 $(NGINX_IMG_NAME)