FROM node:18-alpine AS build

WORKDIR /app

COPY . .

RUN npm install

FROM node:18-alpine

WORKDIR /app

COPY --from=build /app /app

EXPOSE 3000
CMD ["npm", "run", "dev"]
