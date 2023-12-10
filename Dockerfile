# Stage 1: Build
FROM node:14.17-alpine3.13 as builder

# Install dependencies
RUN apk update && apk upgrade && \
    apk add wget && \
    apk add --no-cache git

# Set working directory
WORKDIR /home/node/app

# Copy configuration file
COPY ./public/config.js /home/node/app/public/

# Clear Yarn cache
RUN yarn cache clean

# Install dependencies
COPY package.json yarn.lock ./
RUN npm install --legacy-peer-deps

# Stage 2: Final image
FROM node:14.17-alpine3.13

# Set environment variable to skip Chromium download
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Set working directory
WORKDIR /home/node/app

# Install Chromium
RUN apk add chromium

# Copy files from the builder stage
COPY --from=builder /home/node/app/ .

# Expose port
EXPOSE 3002

# Run the application
CMD ["yarn", "start"]
