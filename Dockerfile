# Stage 1: Install dependencies and compile TypeScript
FROM node:24-bookworm-slim AS build

WORKDIR /app

# Copy dependency manifests first to improve build caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy application source and configuration
COPY tsconfig.json ./
COPY src ./src

# Compile TypeScript into dist/
RUN npm run build


# Stage 2: Production runtime
FROM node:24-bookworm-slim AS production

ENV NODE_ENV=production

WORKDIR /app

# Install only production dependencies
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy compiled JavaScript from the build stage
COPY --from=build /app/dist ./dist

# The application listens on this port by default
EXPOSE 3000

# Run as the non-root user supplied by the Node image
USER node

CMD ["node", "dist/server.js"]
