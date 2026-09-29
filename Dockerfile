FROM debian:latest AS architool-export
COPY ./model ./model
RUN apt update && \
    apt install -y xvfb libswt-gtk-4-jni git unzip curl vim jq dbus-x11 && \
    mkdir ./dist && \
    curl -L -o ./dist/Archi-Linux64.tgz https://github.com/archimatetool/archi.io/releases/download/5.10_0/Archi-Linux64-5.10.0.tgz && \
    curl -L -o ./dist/coArchi.archiplugin https://www.archimatetool.com/downloads/coarchi/coArchi_0.9.7.archiplugin && \
    tar -xf ./dist/Archi-Linux64.tgz -C / && \
    mkdir ~/.archi && mkdir ~/.archi/dropins && \
    unzip ./dist/coArchi.archiplugin -d ~/.archi/dropins/ && \
    xvfb-run /Archi/Archi.sh -application com.archimatetool.commandline.app -consoleLog -nosplash --modelrepository.loadModel . --html.createReport export

FROM mcr.microsoft.com/dotnet/sdk:latest AS build
COPY --from=architool-export /export /src/Krempel.Archi-Export.WebServer/wwwroot
COPY ./src ./src
WORKDIR /src/Krempel.Archi-Export.WebServer
RUN dotnet publish -maxcpucount:5 -c Release -o /app/publish --runtime linux-x64 "./Krempel.Archi-Export.WebServer.csproj"
