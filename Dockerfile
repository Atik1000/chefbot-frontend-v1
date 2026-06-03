# Multi-stage Dockerfile for Next.js (app router)
FROM node:20-alpine AS builder
WORKDIR /app

# Install deps
COPY package.json package-lock.json* ./
RUN npm install

# Public env vars are inlined at build time by Next.js, so they must be
# available during `npm run build`. Override at build via --build-arg if needed.
ARG NEXT_PUBLIC_BASEURL=https://api.chef-bot.de
ARG NEXT_PUBLIC_WEBSOCKETURL=wss://api.chef-bot.de
ENV NEXT_PUBLIC_BASEURL=$NEXT_PUBLIC_BASEURL
ENV NEXT_PUBLIC_WEBSOCKETURL=$NEXT_PUBLIC_WEBSOCKETURL

# Copy source and build
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy build output and necessary files
COPY --from=builder /app/.next .next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Install production deps
RUN npm install --omit=dev

EXPOSE 3000
CMD ["npm", "run", "start"]
