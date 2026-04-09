FROM node:16.17.0-alpine as builder
WORKDIR /app
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install
COPY . .
ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"
RUN yarn build

FROM nginx:stable-alpine
RUN rm -rf /etc/nginx/conf.d/*
COPY nginx.conf /etc/nginx/nginx.conf
#RUN rm /etc/nginx/conf.d/default.conf
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
#COPY nginx.conf /etc/nginx/nginx.conf
#COPY nginx.conf /etc/nginx/conf.d/*.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]