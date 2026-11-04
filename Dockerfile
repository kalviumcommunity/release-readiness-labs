FROM node:22-alpine

WORKDIR /app

COPY app/package*.json ./

RUN npm ci --omit=dev

COPY --chown=node:node app/ .

USER node

EXPOSE 3000

CMD ["npm", "start"]