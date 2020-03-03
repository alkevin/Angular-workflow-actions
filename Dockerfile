### STAGE 1: Build ###

# We label our stage as builder
FROM node:10.16.3 AS builder

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

COPY package.json package.json
COPY package-lock.json package-lock.json

# install and cache app dependencies
COPY package.json /app/package.json
RUN npm install -g @angular/cli@9.0.2
RUN npm ci  --debug

## Build the angular app in production
COPY . .
RUN ng build --prod
RUN ls -la .

### STAGE 2: Setup ###
FROM nginx:1.17.1-alpine

## Copy our default nginx config
COPY .nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY .nginx/nginx.conf /etc/nginx/nginx.conf

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From ‘builder’ stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /ng-app/dist /usr/share/nginx/html

CMD /bin/bash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'

#CMD ["nginx", "-g", "daemon off;"]

#COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
#COPY --from=compile-image /ng-app/dist/app-name /usr/share/nginx/html

#### STAGE 2: Setup ###
#
#FROM nginx:1.17.1-alpine
#
### Copy our default nginx config
#COPY nginx/default.conf /etc/nginx/conf.d/
#
### Remove default nginx website
#RUN rm -rf /usr/share/nginx/html/*
#
### From ‘builder’ stage copy over the artifacts in dist folder to default nginx public folder
#COPY --from=builder /ng-app/dist /usr/share/nginx/html
#
#CMD ["nginx", "-g", "daemon off;"]
#
