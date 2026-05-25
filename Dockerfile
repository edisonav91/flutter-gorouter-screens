FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml ./
COPY analysis_options.yaml ./

RUN flutter pub get

COPY . .

# Generate the missing platform scaffold inside the image only.
RUN flutter create --platforms=web .
RUN flutter build web --release

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
