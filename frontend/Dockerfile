# Use the official Node.js image.
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your application's code
COPY . .

# Expose the port the development server runs on
EXPOSE 5173

# TODO NOTE: the dev script must give vite the --host flag to expose the port outside of the container
# Command to run the development server
CMD ["npm", "run", "dev"]
