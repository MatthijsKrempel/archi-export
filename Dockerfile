FROM debian:latest AS architool-export
COPY ./model ./model
RUN apt update && \
    apt install -y xvfb libswt-gtk-4-jni git unzip curl vim jq dbus-x11 && \
    mkdir ./dist && \
    curl -o ./dist/Archi-Linux64-5.6.0.tgz https://www.archimatetool.com/downloads/archi/5.6.0/Archi-Linux64-5.6.0.tgz && \
    curl -o ./dist/coArchi_0.9.4.archiplugin https://www.archimatetool.com/downloads/coarchi/coArchi_0.9.4.archiplugin && \
    tar -xf ./dist/Archi-Linux64-5.6.0.tgz -C / && \
    mkdir ~/.archi && mkdir ~/.archi/dropins && \
    unzip ./dist/coArchi_0.9.4.archiplugin -d ~/.archi/dropins/ && \
    xvfb-run /Archi/Archi.sh -application com.archimatetool.commandline.app -consoleLog -nosplash --modelrepository.loadModel . --html.createReport export

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
COPY --from=architool-export /export /src/Krempel.Archi-Export.WebServer/wwwroot
COPY ./src ./src
WORKDIR /src/Krempel.Archi-Export.WebServer
RUN dotnet publish -maxcpucount:5 -c Release -o /app/publish --runtime linux-x64 "./Krempel.Archi-Export.WebServer.csproj"

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS krempel-architecturedocs-web
WORKDIR /app
	
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Krempel.Archi-Export.WebServer.dll"]