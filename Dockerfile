FROM node:latest

RUN apt update -y && apt upgrade -y

WORKDIR /app

RUN git config --global user.email "arnaldovictorm@gmail.com"
RUN git config --global user.name "Arnaldo Victor"

RUN git clone https://github.com/ArnaldoVictor/nova_holanda.git

RUN git init

RUN git remote add origin https://github.com/ArnaldoVictor/nova_holanda.git

RUN git pull origin master

WORKDIR /app/nova_holanda

RUN chmod +x /app/nova_holanda/src/utils/bash/git_push.sh 

RUN npm install

CMD ["npm", "start"]
