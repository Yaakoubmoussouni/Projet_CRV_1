# Use a Node.js base image
FROM node:18


# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./



# Copy the rest of the application
COPY . .

# Build the React app
RUN npm run build

# Expose port 80 to the outside world
EXPOSE 80

# Command to run the application
CMD ["npm", "start"]
