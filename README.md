# Study Sprint

Study Sprint es una aplicacion hecha en Flutter para organizar tareas de estudio. Permite registrar actividades, marcarlas como completadas y ver un resumen del progreso general.

## Que hace la aplicacion

- Agrega tareas de estudio con titulo, materia, duracion, prioridad y fecha limite.
- Muestra una lista de tareas registradas.
- Permite marcar tareas como completadas.
- Filtra tareas por todas, pendientes o completadas.
- Muestra un resumen con total de tareas, tiempo planeado y porcentaje de avance.

## Tecnicas usadas en Flutter

En este proyecto se trabajaron varios temas vistos en clase:

- `StatefulWidget` y `setState`
- widgets reutilizables
- `NavigationBar`
- formularios con validacion
- `SnackBar`
- `showDatePicker`
- `AnimatedSwitcher`
- `LayoutBuilder`

## Estructura basica

```text
lib/
  main.dart
test/
  widget_test.dart
README.md
VIDEO_GUIA.md
```

## Como ejecutar el proyecto

1. Clona el repositorio:

```bash
git clone <URL_DEL_REPOSITORIO>
cd study_sprint
```

2. Instala las dependencias:

```bash
flutter pub get
```

3. Ejecuta la aplicacion:

```bash
flutter run
```

## Prueba basica

Para ejecutar la prueba incluida:

```bash
flutter test
```

## Comentarios en el codigo

El archivo `lib/main.dart` tiene comentarios explicativos sobre la estructura de la app, el manejo del estado, el formulario y la organizacion de la interfaz.

## Video explicativo

El archivo `VIDEO_GUIA.md` sirve como apoyo para grabar el video de la entrega y explicar el proyecto.
