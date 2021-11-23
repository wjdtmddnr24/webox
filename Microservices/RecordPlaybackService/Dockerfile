FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./

RUN yarn

RUN apt update && apt install -y ffmpeg

COPY . .

RUN yarn build

EXPOSE 3000

CMD ["yarn", "start:prod"]