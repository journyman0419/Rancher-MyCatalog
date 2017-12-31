version: '2'
services:

  mautic-lb:
    image: rancher/lb-service-haproxy:v0.7.9
    ports:
      - ${publish_port}:${publish_port}

{{- if eq .Values.MAUTIC_IMAGE_TYPE "fpm" }}
  web:
    image: nginx:1.13-alpine
    links:
        - mautic 
    volumes:
        - ./web/nginx/nginx.conf:/etc/nginx/nginx.conf
        - ./web/nginx/www.conf:/etc/nginx/conf.d/www.conf
        - ./web/nginx/mautic.conf:/etc/nginx/conf.d/mautic.conf
    volumes_from:
        - app
    networks:
        - mautic-networks
    expose:
        - 80
    labels:
        io.rancher.container.hostname_override: container_name
{{- end }}

  mautic:
    image: mautic/mautic:2.12-${mautic_image_type}
    environment:
      MAUTIC_DB_HOST: mautic-db
      MAUTIC_DB_NAME: ${mautic_db_name}
      MAUTIC_DB_USER: ${mautic_db_user}
      MAUTIC_DB_PASSWORD: ${mautic_db_password}
    volumes:
      - mautic-data:/var/www/html
    labels:
        io.rancher.container.hostname_override: container_name

  mautic-db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: ${mysql_root_password}
      MYSQL_DATABASE: ${mautic_db_name}
      MYSQL_USER: ${mautic_db_user}
      MYSQL_PASSWORD: ${mautic_db_password}
    volumes:
      - mautic-db:/var/lib/mysql
    labels:
      io.rancher.container.hostname_override: container_name

volumes:
  mautic-data:
    driver: ${volume_driver}
  mautic-db:
    driver: ${volume_driver}
