FROM node:16

WORKDIR /usr/src/app

COPY package*.json ./

RUN yarn

RUN apt update

RUN apt install ffmpeg -y

COPY . .

RUN yarn build

EXPOSE 3000

CMD ["yarn", "start:prod"]