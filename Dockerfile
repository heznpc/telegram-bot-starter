FROM node:22-alpine

# The base image bundles vulnerable node-tar; retain npm with a patched toolchain.
RUN npm install --global npm@11.19.1 --ignore-scripts && npm cache clean --force

ENV NODE_ENV=production \
    HEALTH_PORT=3000

WORKDIR /app

COPY --chown=node:node package*.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY --chown=node:node . .

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider "http://localhost:${HEALTH_PORT:-3000}/health" || exit 1

CMD ["node", "src/index.js"]
