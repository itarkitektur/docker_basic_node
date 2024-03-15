FROM node:16.13.1

WORKDIR /usr/src/app

# Copy package.json and package-lock.json and install dependencies
COPY package*.json ./
RUN npm install

# Install nodemon globally
RUN npm install -g nodemon

# Copy the rest of your application's code
COPY . .

CMD npm config set cache-min 9999999 && npm run dev

