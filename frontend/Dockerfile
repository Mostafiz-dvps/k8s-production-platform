FROM nginx:1.27.5-alpine

WORKDIR /usr/share/nginx/html

RUN apk add --no-cache gettext

COPY index.html ./
COPY styles.css ./
COPY app.js ./
COPY config.template.js ./
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 644 /usr/share/nginx/html/index.html \
    /usr/share/nginx/html/styles.css \
    /usr/share/nginx/html/app.js \
    /usr/share/nginx/html/config.template.js \
 && chmod +x /docker-entrypoint.sh

EXPOSE 80

CMD ["/docker-entrypoint.sh"]
