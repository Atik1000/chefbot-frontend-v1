# Multi-stage Dockerfile for Next.js (app router)
FROM node:18-alpine AS builder
WORKDIR /app

# Install deps
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy build output and necessary files
COPY --from=builder /app/.next .next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Install production deps
RUN npm ci --production

EXPOSE 3000
CMD ["npm", "run", "start"]
