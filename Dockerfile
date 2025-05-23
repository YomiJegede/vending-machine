# official Node.js LTS image
FROM node:18-alpine

# Install curl
RUN apk add --no-cache curl

# Create app directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
COPY tsconfig.json ./
RUN npm install

# Bundle app source
COPY src ./src

# Build
RUN npm run build

# Set environment variables
ENV NODE_ENV=dev
ENV PORT=3000

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["node", "dist/app.js"]