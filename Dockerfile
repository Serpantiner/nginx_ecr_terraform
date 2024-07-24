FROM --platform=\$BUILDPLATFORM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html