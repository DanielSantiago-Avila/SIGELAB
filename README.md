========================================================================
                 SIGELAB - GUÍA DE INSTALACIÓN Y CONFIGURACIÓN
========================================================================

Este proyecto fue desarrollado en Flutter y está conectado a SQL Server
en AWS RDS. Incluye autenticación con contraseñas cifradas en SHA-256.

------------------------------------------------------------------------
1. REQUISITOS PREVIOS
------------------------------------------------------------------------
Asegúrate de contar con lo siguiente instalado en tu equipo:
- Flutter SDK (versión estable)
- Dart SDK (incluido con Flutter)
- Android Studio o Visual Studio Code (con extensión Flutter/Dart)
- Dispositivo físico con depuración USB habilitada o Emulador Android.

------------------------------------------------------------------------
2. INSTALACIÓN Y BAJADA DE DEPENDENCIAS
------------------------------------------------------------------------
Sigue estos comandos paso a paso desde la consola/terminal:

Paso A: Clonar el repositorio
> git clone https://github.com/DanielSantiago-Avila/SIGELAB.git
> cd SIGELAB

Paso B: Cambiar a la rama de desarrollo (si aplica)
> git checkout gerson

Paso C: Descargar los paquetes y dependencias (OBLIGATORIO)
Ejecuta el siguiente comando para que Flutter descargue todas las
librerías necesarias (crypto, mssql_connection, etc.):
> flutter pub get

------------------------------------------------------------------------
3. ARCHIVO DE CREDENCIALES (BASE DE DATOS)
------------------------------------------------------------------------
Para conectar con la base de datos AWS RDS, verifica que exista
el archivo de configuración:
- Ruta requerida: assets/Conectividad_BD.txt
- Contenido: Cadena cifrada en Base64 con los datos de acceso.

------------------------------------------------------------------------
4. EJECUCIÓN DEL PROYECTO
------------------------------------------------------------------------
Con las dependencias instaladas y el emulador/móvil conectado:
> flutter run

------------------------------------------------------------------------
5. RESOLUCIÓN DE PROBLEMAS HABITUALES
------------------------------------------------------------------------
Si se presentan errores al compilar o no reconoce un paquete recién agregado:
1. Limpiar caché del proyecto:
   > flutter clean
2. Reinstalar dependencias:
   > flutter pub get
3. En VS Code, reinicia el servidor de Dart:
   Presiona Ctrl + Shift + P -> Selecciona "Dart: Restart Analysis Server"
========================================================================