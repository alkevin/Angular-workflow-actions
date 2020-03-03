### STAGE 1: Build ###

# We label our stage as builder
FROM node:13.3.0 AS builder
COPY package.json package-lock.json ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm ci --debug && mkdir /ng-app && mv ./node_modules ./ng-app
WORKDIR /ng-app
COPY . .

## Build the angular app in production mode and store the artifacts in dist folder
RUN npm run ng build -- --prod --output-path=dist
RUN ls -la .
RUN ls -la dist
### STAGE 2: Setup ###
FROM nginx:1.17.1-alpine

## Copy our default nginx config
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/nginx.conf /etc/nginx/nginx.conf

## Remove default nginx website
#RUN rm -rf /usr/share/nginx/html/*

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
