FROM debian:bullseye

RUN apt-get update

RUN apt-get install -y nginx

RUN rm -rf /var/lib/apt/lists/*

COPY site/ /var/www/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]