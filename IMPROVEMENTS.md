# UpsaMe - Red Académica Universitaria

Una aplicación Flutter moderna para conectar estudiantes universitarios, compartir conocimientos y colaborar académicamente.

## 🎨 Mejoras Realizadas

### ✨ Diseño y UI
- **Tema personalizado** con colores verde UPSA (#1B5E3F, #2D8659)
- **Interfaz moderna** con gradientes, sombras y bordes redondeados
- **Paleta de colores consistente** en toda la aplicación
- **Componentes visuales mejorados** con iconos y espaciado equilibrado

### 🔐 Autenticación
- **Login Screen**: Diseño elegante con gradiente verde, campos de entrada estilizados
  - Toggle de visibilidad de contraseña
  - Validación en cliente
  - Indicador de carga durante el login

- **Register Screen**: Formulario completo y bonito
  - Lista completa de **20 carreras** (Ingeniería Civil, Sistemas, Electrónica, Arquitectura, Derecho, Psicología, etc.)
  - Campos: Nombre, Apellido, Email, Contraseña, Teléfono, Semestre, Carrera
  - Validación de campos requeridos
  - Diseño con tarjeta y botones personalizados

### 📱 Pantalla de Inicio
- Feed de publicaciones con paginación infinita
- Tarjetas de posts estilizadas (PostCard)
- Estado vacío mejorado cuando no hay publicaciones
- Pull-to-refresh para actualizar el feed

### ✍️ Crear Publicación (MEJORADO)
- **Rol Selector**: Botones visuales para elegir entre:
  - 🆘 Necesita ayuda
  - 🤝 Ofrece ayuda
  - 💬 Comentario
- **Selector de Materia**: Dropdown con todas las materias disponibles
- **Fecha/Calendario**: 
  - Integración de DatePicker para seleccionar fechas
  - **Placeholder para Calendly** (implementación futura)
  - Aviso visual sobre la próxima integración
- **Formulario completo**:
  - Título (opcional)
  - Contenido (requerido)
  - Capacidad máxima
  - Diseño con tarjetas y espaciado profesional

### 🔍 Búsqueda y Filtros
- Filtros por facultad, carrera y materia
- Búsqueda de texto en posts
- Interfaz intuitiva para explorar contenido

### 👤 Perfil de Usuario
- Información del usuario
- Historial de publicaciones
- Opciones de configuración

## 📦 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── theme.dart               # Tema global de la aplicación
├── constants/
│   └── careers.dart         # Lista de carreras disponibles
├── models/
│   ├── auth_models.dart     # DTOs de autenticación
│   └── post_models.dart     # Modelos de posts
├── services/
│   ├── api_client.dart      # Cliente HTTP (actualmente sin conexión)
│   ├── auth_service.dart    # Servicio de autenticación (mock)
│   ├── posts_service.dart   # Servicio de posts
│   ├── subjects_service.dart # Servicio de materias
│   └── directory_service.dart # Servicio de directorio
├── screens/
│   ├── login_screen.dart    # Pantalla de login
│   ├── register_screen.dart # Pantalla de registro
│   ├── main_tabs.dart       # Navegación principal
│   ├── home_screen.dart     # Feed de inicio
│   ├── search_screen.dart   # Búsqueda y filtros
│   ├── create_post_screen.dart # Crear publicación
│   ├── post_detail_screen.dart # Detalle de post
│   └── profile_screen.dart  # Perfil de usuario
└── widgets/
    └── post_card.dart       # Componente reutilizable de post
```

## 🚀 Cómo Usar

### Instalación

```bash
# Clonar el repositorio
git clone <repo-url>

# Entrar al directorio
cd upsame_api

# Instalar dependencias
flutter pub get
```

### Ejecutar la App

```bash
# En web (Chrome)
flutter run -d chrome

# En Android
flutter run -d android

# En Windows
flutter run -d windows

# En macOS
flutter run -d macos
```

## 🔌 Integración con Backend

Actualmente, la aplicación está configurada con **autenticación mock** para permitir pruebas sin depender del servidor.

### Para conectar al backend real:

1. Abre `lib/services/api_client.dart`
2. Descomenta la línea:
   ```dart
   String baseUrl = 'http://localhost:5034';
   ```
3. Comenta la línea de baseUrl vacío
4. Actualiza los métodos en `auth_service.dart` para hacer requests HTTP reales

### URLs de Backend
- **API Base**: `http://localhost:5034`
- **Swagger UI**: `http://localhost:5034/swagger/index.html`
- **Endpoints principales**:
  - `POST /auth/login` - Iniciar sesión
  - `POST /auth/register` - Registrarse
  - `GET /posts` - Obtener posts
  - `GET /directory/faculties` - Obtener facultades
  - `GET /directory/careers` - Obtener carreras

## 🎯 Carreras Disponibles

La aplicación incluye 20 carreras UPSA:
- Ingeniería Civil
- Ingeniería Industrial
- Ingeniería en Sistemas
- Ingeniería Electrónica
- Ingeniería Mecánica
- Arquitectura
- Administración de Empresas
- Contabilidad
- Derecho
- Psicología
- Enfermería
- Medicina
- Biotecnología
- Agronomía
- Comunicación Social
- Marketing
- Turismo
- Gastronomía
- Educación
- Lenguas Extranjeras

## 📅 Próximos Pasos

- [ ] Integración de **Calendly** para seleccionar fechas/horarios
- [ ] Subida de imágenes/archivos en posts
- [ ] Notificaciones en tiempo real
- [ ] Sistema de calificación/valoración
- [ ] Chat entre usuarios
- [ ] Mapeo de ubicaciones para reuniones
- [ ] Historial de actividad
- [ ] Estadísticas de usuario

## 🛠️ Tecnologías

- **Flutter**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **HTTP**: Cliente para peticiones HTTP
- **Flutter Secure Storage**: Almacenamiento seguro de tokens

## 📝 Notas

- El email de login/registro actualmente no valida dominio específico
- Los datos se almacenan localmente con persistencia de tokens en almacenamiento seguro
- La interfaz es responsive y adaptable a diferentes tamaños de pantalla

## 👨‍💻 Autor

Desarrollado para UPSA - Universidad Privada de Santa Cruz de la Sierra

---

¡Disfruta compartiendo conocimiento con UpsaMe! 🎓✨
