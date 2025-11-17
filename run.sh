#!/bin/bash
# Script para ejecutar UpsaMe

echo "🚀 Iniciando UpsaMe..."
echo ""

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado"
    echo "Por favor instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Mostrar dispositivos disponibles
echo "📱 Dispositivos disponibles:"
flutter devices
echo ""

# Ir al directorio de la app
cd "$(dirname "$0")" || exit

# Instalar dependencias si es necesario
echo "📦 Verificando dependencias..."
flutter pub get

# Ejecutar la app
echo ""
echo "🎮 Selecciona un dispositivo:"
echo "Opciones:"
echo "  1) Chrome (web)"
echo "  2) Android"
echo "  3) Windows"
echo "  4) Todos los dispositivos disponibles"
echo ""

read -p "Selecciona una opción (1-4): " option

case $option in
    1)
        echo "Ejecutando en Chrome..."
        flutter run -d chrome
        ;;
    2)
        echo "Ejecutando en Android..."
        flutter run -d android
        ;;
    3)
        echo "Ejecutando en Windows..."
        flutter run -d windows
        ;;
    4)
        echo "Mostrando dispositivos disponibles..."
        flutter run
        ;;
    *)
        echo "❌ Opción no válida"
        exit 1
        ;;
esac

echo ""
echo "✅ ¡UpsaMe ejecutándose!"
echo "Presiona 'q' en la terminal para salir"
