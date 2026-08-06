FROM nginx:1.28-alpine

RUN rm -f /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY gzip.conf /etc/nginx/conf.d/gzip.conf
COPY security.conf /etc/nginx/conf.d/security.conf
COPY fastcgi.conf /etc/nginx/fastcgi.conf

WORKDIR /var/www/html