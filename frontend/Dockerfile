FROM node:24-slim

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 5173

CMD ["npm", "run", "dev"]
