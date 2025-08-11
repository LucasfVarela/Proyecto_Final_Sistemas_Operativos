
#!/bin/bash

DOWNLOAD_DIR="$HOME/Descargas"
TEXTFILE=""
Email_Destino=""
Email_Asunto=""
Email_Mensaje=""

mostrar_menu() {
    echo "Selecciona una opción:"
    echo "1. Generar back up"
    echo "2. Actualizar driver de placa de video"
    echo "3. Analizar la carpeta de descargas"
    echo "4. Salir"
}

# Función para generar backup
Generar_back_up() {
    TEXTFILE="GenerarBK_Log.txt"
    
    read -p "Ingrese la dirección de correo electrónico que desea notificar: " Email_Destino
    if [[ ! "$Email_Destino" =~ ^.+@.+$ ]]; then
        echo "Dirección de correo inválida."
        return 1
    fi
    
    Email_Asunto="Se realizó la operación de backup"
    Email_Mensaje="Este es el log de la operación de backup realizada el día $(date '+%Y-%m-%d %H:%M:%S'), nombre del archivo $TEXTFILE"
    
    echo "Selecciona la carpeta para realizar el backup:"
    select carpeta in "$Documentos"/*; do
        if [ -n "$carpeta" ] && [ -d "$carpeta" ]; then
            echo "Seleccionaste la carpeta: $carpeta"
            log_message "Se realizó el backup de la siguiente carpeta: $carpeta"
            echo "Subiendo la copia de seguridad a Google Drive..."
            
            
            gdrive upload --parent "18N7YpYhzJSkBu2ZmALhuo1yXEyP2KBCn" "$carpeta"
            log_message "Copia de seguridad subida a Google Drive."
            
            echo "Proceso completado. El log ha sido enviado a $Email_Destino."
            log_message "Proceso de backup finalizado."
            envio_correo
            break
        else
            echo "Opción no válida, intenta de nuevo."
            log_message "No se ha completado la operación"
        fi
    done
}

# Función para actualizar driver NVIDIA
Actualizar_Driver() {
    current_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
    url="https://www.nvidia.com/Download/index.aspx"
    latest_version=$(curl -s "$url" | grep -oP 'Version \d+\.\d+\.\d+\.\d+' | head -n 1 | awk '{print $2}')

    TEXTFILE="Actualizar_Driver_Log.txt"
    
    read -p "Ingrese la dirección de correo electrónico que desea notificar: " Email_Destino
    if [[ ! "$Email_Destino" =~ ^.+@.+$ ]]; then
        echo "Dirección de correo inválida."
        return 1
    fi
    
    Email_Asunto="Se realizó la operación de actualización de drivers"
    Email_Mensaje="Este es el log de la operación de actualización de drivers realizada el día $(date '+%Y-%m-%d %H:%M:%S'), nombre del archivo $TEXTFILE"

    echo "A continuación se hará la actualización del driver de la placa de video"
    if [[ "$current_version" == "$latest_version" ]]; then
        log_message "La versión del controlador NVIDIA está actualizada: $current_version."
    else
        log_message "Nueva versión disponible: $latest_version. Tu versión actual es: $current_version."
        
        download_url=$(curl -s "$url" | grep -oP 'https://\S+driver_download\S+' | head -n 1)
    
        if [[ -z "$download_url" ]]; then
            log_message "No se pudo obtener la URL de descarga para la nueva versión."
            return 1
        fi
        
        log_message "Descargando el controlador desde: $download_url"
        
        wget -O nvidia_driver.run "$download_url"
        
        if [[ $? -eq 0 ]]; then
            log_message "Descarga completada. Iniciando la instalación del nuevo controlador..."
            
            chmod +x nvidia_driver.run
            
            sudo ./nvidia_driver.run --silent
            
            if [[ $? -eq 0 ]]; then
                log_message "Instalación completada exitosamente. Reiniciando el servicio del controlador..."
                
                sudo systemctl restart nvidia-persistenced
    
                log_message "Instalación y reinicio del servicio completados. El controlador está actualizado."
            else
                log_message "Hubo un error durante la instalación del controlador."
            fi
        else
            log_message "Hubo un problema durante la descarga del controlador."
        fi
    fi
    envio_correo
}


# Función para monitorear carpeta de descargas
scan_file_Action() {
    TEXTFILE="Analizar_Carpeta_Log.txt"
    
    read -p "Ingrese la dirección de correo electrónico que desea notificar: " Email_Destino
    if [[ ! "$Email_Destino" =~ ^.+@.+$ ]]; then
        echo "Dirección de correo inválida."
        return 1
    fi
    
    Email_Asunto="Se analizó el archivo descargado"
    Email_Mensaje="Este es el log de la operación de análisis de la carpeta de descarga el día $(date '+%Y-%m-%d %H:%M:%S'), nombre del archivo $TEXTFILE"
    
    echo "Monitoreando la carpeta $DOWNLOAD_DIR para nuevos archivos..."
    inotifywait -m -r -e close_write --format "%w%f" "$DOWNLOAD_DIR" | while read NEW_FILE; do
        # Llamar a la función para escanear el archivo recién descargado
        scan_file "$NEW_FILE"
    done
}

# Función para escanear un archivo
scan_file() {
    local file="$1"            
    if [[ -f "$file" ]]; then
        log_message "Escaneando $file..."
        clamscan --infected --remove --quiet "$file"
        
        if [[ $? -eq 1 ]]; then
            log_message "¡Alerta! Se detectó un virus en $file y ha sido eliminado."
        elif [[ $? -eq 0 ]]; then
            log_message "No se detectaron virus en $file."
        else
            log_message "Error al escanear $file."
        fi
        envio_correo
    fi
}


# Función para escribir mensajes en el log
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$1"
    echo "$timestamp - $message" >> "$TEXTFILE"
}

# Función para enviar correo
envio_correo() {
    local destino="$Email_Destino"
    local asunto="$Email_Asunto"
    local mensaje="$Email_Mensaje"
    echo -e "$mensaje" | msmtp --subject="$asunto" "$destino"
}

# Bucle principal del menú
while true; do
    mostrar_menu
    read -p "Ingresa tu opción: " opcion

    case $opcion in
        1) Generar_back_up ;;
        2) Actualizar_Driver ;;
        3) scan_file_Action ;;
        4) 
            echo "Saliendo..."
            break
            ;;
        *)
            echo "Opción no válida. Intenta de nuevo."
            ;;    
    esac
done