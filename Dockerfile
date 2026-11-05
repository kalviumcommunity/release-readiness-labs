FROM node:18-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY app/package*.json ./
RUN npm ci --only=production || npm install --production
COPY app/ .
RUN chown -R node:node /app
USER node
EXPOSE 3000
CMD ["npm", "start"]
