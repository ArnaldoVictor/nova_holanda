FROM node:latest

RUN apt update -y && apt upgrade -y

WORKDIR /app

RUN git config --global user.email "arnaldovictorm@gmail.com"
RUN git config --global user.name "Arnaldo Victor"

RUN git clone https://github.com/ArnaldoVictor/nova_holanda.git

WORKDIR /app/nova_holanda

RUN npm install

CMD ["npm", "start"]
