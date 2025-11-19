FROM nginx:alpine

COPY index.js index.css mypersonalwebsite/ /usr/share/nginx/html/

WORKDIR /usr/share/nginx/html

EXPOSE 80

