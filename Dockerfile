FROM node:20-alpine
WORKDIR /app
ARG RELEASE_VERSION=2.3.0
ENV NODE_ENV=production
ENV RELEASE_VERSION=${RELEASE_VERSION}
COPY app/package*.json ./
RUN npm install --omit=dev --no-audit --no-fund && npm cache clean --force
COPY app/ ./
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"
CMD ["npm", "start"]
