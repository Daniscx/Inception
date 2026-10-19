FROM debian:bookworm
RUN apt-get update
RUN apt-get install -y nginx openssl

EXPOSE 443

COPY ./conf/default.conf /etc/nginx/sites-enabled/default.conf
COPY ./tools/nginx_start.sh /var/www

RUN chmod +x /var/www/nginx_start.sh

ENTRYPOINT ["bash", "var/www/nginx_start.sh" ]

CMD ["nginx", "-g", "daemon off;"]