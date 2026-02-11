# ---------- build frontend ----------
FROM node:18-alpine AS frontend-builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build


# ---------- runtime ----------
FROM node:18-alpine
WORKDIR /app

# install nginx
RUN apk add --no-cache nginx

# copy frontend build
COPY --from=frontend-builder /app/dist /usr/share/nginx/html

# copy backend
COPY backend ./backend

# install backend deps
WORKDIR /app/backend
RUN npm install --production

# copy nginx config
COPY nginx.conf /etc/nginx/http.d/default.conf

# ensure data dir exists
RUN mkdir -p /app/backend/data

EXPOSE 80

# start backend + nginx
CMD node server.js & nginx -g "daemon off;"
