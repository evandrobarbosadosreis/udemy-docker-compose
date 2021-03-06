# Utilizando como base a imagem base do .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src

# Copia os arquivos .csproj para suas respectivas pastas e restaura os pacotes 
COPY Mensagens.Dominio/*.csproj Mensagens.Dominio/ 
COPY Mensagens.Infra/*.csproj Mensagens.Infra/
COPY Mensagens.Webapi/*.csproj Mensagens.Webapi/
RUN dotnet restore Mensagens.Webapi/Mensagens.Webapi.csproj

# Copia todo o conteúdo das pastas e realiza o build do projeto
COPY Mensagens.Dominio/ Mensagens.Dominio/
COPY Mensagens.Infra/ Mensagens.Infra/
COPY Mensagens.Webapi/ Mensagens.Webapi/
WORKDIR Mensagens.Webapi/
RUN dotnet build -c release --no-restore

# Após realizar o build, publish da solução no diretório app
FROM build AS publish
RUN dotnet publish -c release --no-build -o /app

# Agora utilizando a imagem do .NET Runtime, copia os assemblies 
# gerados na publicação e executa a nossa aplicação 
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "Mensagens.Webapi.dll"]