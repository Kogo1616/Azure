# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Test/Test/Test.csproj Test/Test/
RUN dotnet restore Test/Test/Test.csproj

COPY Test/Test/ Test/Test/
RUN dotnet publish Test/Test/Test.csproj -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

# The app listens on 8080 (the default HTTP port in .NET 8+ images)
ENV ASPNETCORE_HTTP_PORTS=8080
# Trust X-Forwarded-Proto/For from the hosting proxy so the app (and Swagger)
# sees the public https URL instead of the internal http one
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true
EXPOSE 8080

COPY --from=build /app/publish ./
ENTRYPOINT ["dotnet", "Test.dll"]
