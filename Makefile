# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dmaestro <dmaestro@student.42madrid.con    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/16 17:29:19 by dmaestro          #+#    #+#              #
#    Updated: 2026/10/15 18:27:41 by dmaestro         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = inception

COMPOSE = docker compose -f srcs/docker-compose.yml


all: up

up:
	if [ ! -d /home/daniel-maestro-gomez/data/mysql ]; then \
		mkdir -p /home/daniel-maestro-gomez/data/mysql; \
	fi
	if [ ! -d /home/daniel-maestro-gomez/data/wordpress ]; then \
		mkdir -p /home/daniel-maestro-gomez/data/wordpress; \
	fi
	$(COMPOSE) up --build -d



down:
	$(COMPOSE) down

start:
	$(COMPOSE) start

stop:
	$(COMPOSE) stop

restart: down up

logs:
	$(COMPOSE) logs -f
uwu:
	echo "gracias por el huevo"
clean:
	$(COMPOSE) down -v --rmi all --remove-orphans
	

fclean: clean
	docker system prune -af --volumes
	sudo rm -rf /home/daniel-maestro-gomez/data/mysql
	sudo rm -rf /home/daniel-maestro-gomez/data/wordpress

re: fclean
	$(MAKE) all


.PHONY: all up down start stop restart logs clean fclean re uwu