FROM nginx:stable

RUN apt -y update
RUN apt -y install certbot
