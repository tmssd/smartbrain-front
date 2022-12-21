FROM node:18-alpine AS development
ENV NODE_ENV development
# Add a work directory
WORKDIR /usr/src/app
# Cache and Install dependencies
COPY package.json .
COPY package-lock.json .
RUN npm install
# Copy app files
COPY . .
# Expose port
EXPOSE 3001
# Start the app
CMD [ "npm", "run", "start:dev" ]

FROM node:18-alpine AS builder
ENV NODE_ENV production
# Add a work directory
WORKDIR /usr/src/app
# Cache and Install dependencies
COPY package.json .
COPY package-lock.json .
RUN npm install --omit=dev
# Copy app files
COPY . .
# Build the app
RUN npm run build

# Bundle static assets with nginx
FROM nginx:1.23.3-alpine as production
ENV NODE_ENV production
# Copy built assets from builder
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
# Add your nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Expose port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]
