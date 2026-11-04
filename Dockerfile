FROM node:24-alpine
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev
COPY app/ .
ARG RELEASE_VERSION=2.3.0
ENV RELEASE_VERSION=${RELEASE_VERSION}
ENV NODE_ENV=production
USER 10001:10001
EXPOSE 3000
CMD ["node", "server.js"]
