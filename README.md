# 🔗 Blockchain en la Empresa — Experiencias y Aprendizajes v2.0

Aplicación web desarrollada con **Flutter Web** y **Firebase** para registrar, consultar y analizar experiencias aprendidas en implementaciones de blockchain empresarial.

---

## 📋 Descripción

Sistema centralizado con autenticación, dashboard de métricas, búsqueda con filtros, paginación, exportación a PDF y soporte para modo oscuro. Permite a equipos documentar implementaciones blockchain y compartir conocimiento organizacional.

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────┐
│                    UI LAYER                         │
│  LoginScreen │ RegisterScreen │ HomeScreen          │
│  AddExperienceScreen │ ExperienceDetailScreen       │
│              Widgets reutilizables                  │
└──────────────────────┬──────────────────────────────┘
                       │ context.watch / context.read
┌──────────────────────▼──────────────────────────────┐
│                 PROVIDER LAYER                      │
│   AuthProvider  │  ExperienceProvider │ ThemeProvider│
│   (ChangeNotifier + notifyListeners)                │
└──────────────────────┬──────────────────────────────┘
                       │ método directo
┌──────────────────────▼──────────────────────────────┐
│                 SERVICE LAYER                       │
│   AuthService  │  FirestoreService │ StorageService │
│   (lógica de negocio + manejo de errores)           │
└──────────────────────┬──────────────────────────────┘
                       │ SDK calls
┌──────────────────────▼──────────────────────────────┐
│                  FIREBASE                           │
│   Authentication  │  Firestore  │  Storage          │
└─────────────────────────────────────────────────────┘
```

---

## 🗄️ Modelo de Datos en Firestore

### Colección `users/{uid}`
| Campo       | Tipo      | Descripción                        |
|-------------|-----------|-------------------------------------|
| uid         | string    | ID del usuario (Firebase Auth)      |
| name        | string    | Nombre completo                     |
| company     | string    | Empresa u organización              |
| email       | string    | Correo electrónico                  |
| role        | string    | `admin` o `viewer`                  |
| createdAt   | Timestamp | Fecha de registro                   |

### Colección `experiences/{id}`
| Campo           | Tipo         | Descripción                        |
|-----------------|--------------|-------------------------------------|
| companyName     | string       | Nombre de la empresa                |
| industry        | string       | Sector/Industria                    |
| summary         | string       | Resumen (mín. 50 caracteres)        |
| registrationDate| Timestamp    | Fecha del registro                  |
| createdBy       | string       | UID del autor                       |
| createdByName   | string       | Nombre del autor                    |
| createdByCompany| string       | Empresa del autor                   |
| attachments     | array        | Lista de AttachmentModel            |
| createdAt       | Timestamp    | Timestamp de creación               |

### Storage: `/attachments/{experienceId}/{fileName}`

---

## 👥 Roles de Usuario

| Acción                        | admin | viewer |
|-------------------------------|:-----:|:------:|
| Ver listado de experiencias   |  ✅   |  ✅    |
| Crear experiencias            |  ✅   |  ✅    |
| Adjuntar PDFs                 |  ✅   |  ✅    |
| Exportar reportes PDF         |  ✅   |  ✅    |
| **Eliminar experiencias**     |  ✅   |  ❌    |

> Para asignar rol `admin` a un usuario, modifica manualmente el campo `role` en Firestore Console → colección `users`.

---

## 📋 Requisitos Previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) **≥ 3.0.0** con soporte Web
- [Dart SDK](https://dart.dev/get-dart) **≥ 3.0.0**
- [Node.js](https://nodejs.org/) ≥ 16 (para Firebase CLI)
- [Firebase CLI](https://firebase.google.com/docs/cli): `npm install -g firebase-tools`
- Google Chrome instalado
- Cuenta Google con acceso a [Firebase Console](https://console.firebase.google.com)

---

## 🔥 Configuración de Firebase

### 1. Crear Proyecto
```
1. Ir a https://console.firebase.google.com
2. "Agregar proyecto" → nombre (ej: blockchain-experiences)
3. Habilitar/deshabilitar Google Analytics → Crear
```

### 2. Habilitar Authentication
```
Firebase Console → Authentication → Comenzar
→ Método de inicio de sesión → Correo/Contraseña → Habilitar → Guardar
```

### 3. Habilitar Firestore
```
Firebase Console → Firestore Database → Crear base de datos
→ Modo de producción → Elige región → Listo
```

Pegar en **Reglas de Firestore**:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
    match /experiences/{docId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
      allow delete: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid))
          .data.role == "admin";
    }
  }
}
```

### 4. Habilitar Storage
```
Firebase Console → Storage → Comenzar → Modo de prueba → Crear
```

Pegar en **Reglas de Storage**:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /attachments/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 5. Configurar FlutterFire CLI
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Ejecutar en la raíz del proyecto
flutterfire configure
```
Seleccionar tu proyecto y la plataforma **Web**. Se generará `lib/firebase_options.dart` con tus credenciales.

---

## 🚀 Comandos

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome

# Compilar para producción
flutter build web

# Desplegar en Firebase Hosting
firebase login
firebase init hosting
firebase deploy --only hosting
```

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                         # Punto de entrada + MultiProvider
├── firebase_options.dart             # Credenciales Firebase (flutterfire)
│
├── models/
│   ├── user_model.dart               # Modelo de usuario + roles
│   ├── experience_model.dart         # Modelo de experiencia
│   └── attachment_model.dart         # Modelo de archivo adjunto
│
├── services/
│   ├── auth_service.dart             # Firebase Auth + traducción errores
│   ├── firestore_service.dart        # CRUD + paginación + estadísticas
│   └── storage_service.dart          # Subida PDFs con progreso + validación
│
├── providers/
│   ├── auth_provider.dart            # Estado de auth + datos usuario
│   ├── experience_provider.dart      # Filtros + paginación + CRUD
│   └── theme_provider.dart           # Toggle dark/light mode
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login glassmorphism
│   │   └── register_screen.dart      # Registro con validaciones
│   ├── home_screen.dart              # Dashboard + grid + filtros
│   ├── add_experience_screen.dart    # Formulario + carga archivos
│   └── experience_detail_screen.dart # Vista completa + export PDF
│
├── widgets/
│   ├── auth_wrapper.dart             # StreamBuilder authStateChanges
│   ├── experience_card.dart          # Card con hover + admin delete
│   ├── stats_card.dart               # Métrica del dashboard
│   ├── attachment_item.dart          # Item PDF compact/full
│   ├── gradient_button.dart          # Botón azul→violeta
│   ├── industry_badge.dart           # Pill con gradiente
│   ├── search_filter_bar.dart        # Búsqueda + filtros
│   └── loading_shimmer.dart          # Skeleton idéntico a card
│
├── utils/
│   ├── pdf_generator.dart            # Reporte + detalle PDF
│   └── validators.dart               # Validaciones de formularios
│
└── theme/
    └── app_theme.dart                # Tema claro + oscuro
```

---

## ✨ Características

| Característica | Descripción |
|---|---|
| 🔐 Autenticación | Email/Password con Firebase Auth |
| 👤 Roles | admin (eliminar) / viewer |
| 🌙 Modo Oscuro | Toggle con ThemeProvider |
| ⏱️ Tiempo Real | StreamBuilder sobre Firestore |
| 📄 Export PDF | Reporte de lista + detalle individual |
| 🔍 Búsqueda | Local por empresa + filtro industria + rango fechas |
| 📱 Responsivo | Mobile 1col / Tablet 2col / Desktop 2col |
| ✅ Validaciones | Formularios + archivos (solo PDF, max 10MB) |
| 📊 Dashboard | 4 métricas en tiempo real |
| ♾️ Paginación | .limit(10) + startAfterDocument |
| 🌀 Shimmer | Skeleton loader con forma real |

---

## 🔒 Seguridad en Producción

1. Actualizar reglas Firestore para validar datos en escritura
2. Configurar CORS en Firebase Storage
3. Añadir dominio personalizado en Firebase Hosting
4. Revisar reglas de Storage para restringir por tipo de archivo
5. Monitorear uso con Firebase Performance y Crashlytics

---

## 🤔 Decisiones Técnicas

**¿Por qué Flutter Web?**
- Un solo codebase para Web/iOS/Android
- Rendimiento cercano a nativo con Skia/CanvasKit
- Hot reload para desarrollo ágil
- Ecosistema maduro de paquetes Firebase

**¿Por qué Firebase?**
- Firestore: base de datos NoSQL en tiempo real, perfecta para StreamBuilder
- Authentication: OAuth, email/password, social login sin backend propio
- Storage: CDN global para archivos, URLs de descarga seguras
- Escalabilidad automática, sin servidores que mantener

**¿Por qué Provider?**
- Solución oficial de Google, simple y sin boilerplate
- Perfecto para apps de mediano tamaño
- Integración nativa con Flutter DevTools