# TODO

Checklist del proyecto **Great Alarm**.

## Features

- [x] Pantalla fija en horizontal.
- [x] Panel izquierdo (2/3) con listado de alarmas.
- [x] Cada alarma muestra hora, días/fecha y cuenta atrás «sonará en …».
- [x] Barra regresiva que se acorta hasta 0 (ventana de una semana).
- [x] Botón flotante (+) para añadir alarmas.
- [x] Alarmas de un solo uso y de repetición semanal.
- [x] Activar/desactivar y borrar alarmas.
- [x] Programación real en Android (AlarmManager) que suena con la app cerrada.
- [x] Persistencia de las alarmas entre reinicios.
- [x] Panel derecho (1/3) con mapamundi gris/azul oscuro y sombra negra día/noche.
- [x] Relojes GMT y local con segundos bajo el mapa.
- [x] README divulgativo sin menciones al stack.

## Fix

- [ ] Comprobar el sonido de la alarma en un dispositivo físico (pendiente de programar una alarma a pocos segundos).
- [ ] Revisar el comportamiento de la barra en alarmas de un solo uso ya vencidas.
- [ ] Verificar el terminador solar en un dispositivo real durante los equinoccios (|declinación| < 0.5°).

## Tareas finalizadas

- [x] README inicial y corrección del boceto para que horas, relojes y barras sean coherentes.
- [x] `git init` del repositorio.
- [x] Creación del proyecto Flutter con identificador `eu.elarreglador.great_alarm`.
- [x] Reutilización del cálculo del terminador solar de `80-Dias-La-Herencia-de-Phoebe`.
- [x] Asset vectorial de tierra firme (Natural Earth 110m) para el mapa sin red.
- [x] Configuración Android: permisos, desugaring, receptores y sonido de alarma.
- [x] Tests unitarios de `AlarmCalculator` y del terminador solar, y test de widget.
- [x] `flutter analyze` sin incidencias, `flutter test` en verde.
- [x] APK debug y release compilados correctamente.
- [x] Corregida la proporción del mapa en pantallas altas (mundo 2:1 centrado).
- [x] Eliminadas las diagonales desde las esquinas al sur de América: el anillo de la Antártida ahora se desbobina en el antimeridiano y se recorta al lienzo.
- [x] El anillo polar se cierra por el borde del polo (no con una cuerda), evitando el corte en dos partes del mapa.
- [x] Sombra nocturna semitransparente para que se adivinen los continentes debajo.
- [x] Recorte sur de la proyección (unos km al sur de Tierra del Fuego): se oculta la Antártida y desaparece la costura del antimeridiano.
- [x] Resguardo a la derecha del reloj local para que no lo tape el botón (+).
- [x] `AGENTS.md` documenta cómo lanzar la app por USB y los problemas de MIUI.
