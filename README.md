# Sistema de Mantenimiento Automatizado

Un script de Bash para automatizar tareas de mantenimiento del sistema, incluyendo backups, actualizaciones de drivers y análisis de seguridad de archivos descargados.

## 🚀 Características

- **Generación de Backups**: Copia de seguridad automática de carpetas con subida a Google Drive
- **Actualización de Drivers NVIDIA**: Verificación y actualización automática de drivers de tarjeta gráfica
- **Análisis de Descargas**: Monitoreo en tiempo real de la carpeta de descargas con escaneo antivirus
- **Notificaciones por Email**: Envío automático de logs por correo electrónico
- **Interfaz de Menú**: Sistema de menú interactivo para fácil navegación

## 📋 Requisitos Previos

Antes de ejecutar el script, asegúrate de tener instaladas las siguientes dependencias:

### Herramientas Requeridas
```bash
# Para backups en Google Drive
sudo apt install gdrive

# Para análisis de virus
sudo apt install clamav clamav-daemon

# Para monitoreo de archivos
sudo apt install inotify-tools

# Para envío de emails
sudo apt install msmtp
```

### Drivers NVIDIA
- Sistema con tarjeta gráfica NVIDIA
- Drivers NVIDIA previamente instalados
- Acceso a internet para descargar actualizaciones

## ⚙️ Configuración Inicial

### 1. Configurar Google Drive
```bash
# Configurar gdrive (primera vez)
gdrive about
```

### 2. Configurar ClamAV
```bash
# Actualizar base de datos de virus
sudo freshclam

# Iniciar el servicio
sudo systemctl start clamav-daemon
sudo systemctl enable clamav-daemon
```

### 3. Configurar msmtp
Crear archivo de configuración en `~/.msmtprc`:
```
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account gmail
host smtp.gmail.com
port 587
from email@gmail.com
auth on
user email@gmail.com
password tu_contraseña_de_aplicacion
```

## 🚀 Uso

### Ejecutar el Script
```bash
# Dar permisos de ejecución
chmod +x script.sh

# Ejecutar
./script.sh
```

### Opciones del Menú

#### 1. Generar Backup
- Selecciona una carpeta de la carpeta Documentos
- Sube la copia de seguridad a Google Drive
- Envía notificación por email con el log

#### 2. Actualizar Driver de Placa de Video
- Verifica la versión actual del driver NVIDIA
- Compara con la última versión disponible
- Descarga e instala automáticamente si hay actualizaciones
- Reinicia los servicios necesarios

#### 3. Analizar Carpeta de Descargas
- Monitorea en tiempo real la carpeta `~/Descargas`
- Escanea automáticamente cada archivo descargado
- Elimina archivos infectados
- Envía notificaciones por email de cada análisis

## 📁 Estructura de Archivos

```
proyecto/
├── Proyecto_Final_Sistemas_Operativos.bat                 # Script principal
├── README.md                 # Este archivo
├── GenerarBK_Log.txt         # Log de operaciones de backup
├── Actualizar_Driver_Log.txt # Log de actualizaciones de driver
└── Analizar_Carpeta_Log.txt  # Log de análisis de archivos
```

## 📝 Logs Generados

Cada operación genera un archivo de log con timestamp:
- `GenerarBK_Log.txt`: Registro de operaciones de backup
- `Actualizar_Driver_Log.txt`: Registro de actualizaciones de drivers
- `Analizar_Carpeta_Log.txt`: Registro de análisis de archivos

Formato de log:
```
YYYY-MM-DD HH:MM:SS - Mensaje de la operación
```

## ⚠️ Consideraciones de Seguridad

- El script requiere permisos sudo para la instalación de drivers
- Las contraseñas de email deben ser contraseñas de aplicación, no la contraseña principal
- Los logs pueden contener información sensible del sistema
- Se recomienda revisar los permisos de archivos regularmente

## 🔧 Personalización

### Cambiar Carpeta de Descargas
Modifica la variable `DOWNLOAD_DIR` en la línea 3:
```bash
DOWNLOAD_DIR="/ruta/a/tu/carpeta"
```

### Cambiar ID de Carpeta Google Drive
Modifica el ID en la función `Generar_back_up()`:
```bash
gdrive upload --parent "TU_ID_DE_CARPETA" "$carpeta"
```

## 🐛 Resolución de Problemas

### Error: "Dirección de correo inválida"
- Verifica que el formato del email sea correcto
- Asegúrate de incluir el símbolo @ y un dominio válido

### Error en descarga de drivers NVIDIA
- Verifica tu conexión a internet
- Comprueba que tengas permisos sudo
- Asegúrate de que el sistema sea compatible con drivers NVIDIA

### ClamAV no encuentra virus
- Actualiza la base de datos: `sudo freshclam`
- Verifica que el servicio esté ejecutándose: `sudo systemctl status clamav-daemon`

## 📄 Licencia

Este proyecto es parte de un trabajo académico. Libre uso para propósitos educativos.

## ✨ Autores
  Tobio Gabriel
  Piccotto Valentino
  Varela Lucas
Proyecto Final - Sistema de Mantenimiento Automatizado

