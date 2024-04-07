FROM node:latest

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install --legacy-peer-deps

EXPOSE 3000

COPY . .

CMD ["node","main.js"]
