# 🔗 Blockchain en la Empresa — Experiencias y Aprendizajes v2.0

Aplicación web desarrollada con **Flutter Web** y **Firebase** para registrar, consultar y analizar experiencias aprendidas en implementaciones de blockchain empresarial.

---

## 📋 Descripción

Sistema centralizado con autenticación, dashboard de métricas y gráficos, búsqueda con filtros, paginación, exportación a PDF, **asistente AI Copilot con RAG**, extracción inteligente de insights mediante **Gemini API**, modo oscuro y un sistema de diseño propio. Permite a equipos documentar implementaciones blockchain y compartir conocimiento organizacional.

---

## ✨ Características

| Característica | Descripción |
|---|---|
| 🔐 Autenticación | Email/Password con Firebase Auth + recuperación de contraseña |
| 👤 Roles | admin (eliminar) / viewer |
| 🌙 Modo Oscuro | Toggle con ThemeProvider |
| ⏱️ Tiempo Real | StreamBuilder sobre Firestore |
| 📄 Export PDF | Reporte de lista + detalle individual |
| 🔍 Búsqueda | Local por empresa + filtro industria + rango fechas + tags |
| 📱 Responsivo | Mobile 1col / Tablet 2col / Desktop 2col |
| ✅ Validaciones | Formularios + archivos (solo PDF, max 10MB) |
| 📊 Dashboard | 4 métricas + gráfico de industrias + tendencia mensual + resumen ejecutivo |
| ♾️ Paginación | .limit(10) + startAfterDocument |
| 🌀 Shimmer | Skeleton loader con forma real |
| 🤖 AI Copilot | Chat contextual con RAG sobre todas las experiencias (Gemini 2.5 Flash) |
| 🏷️ AI Insights | Extracción automática de tags, retos y beneficios al crear experiencias |
| 🎨 Design System | Sistema de diseño propio con colores, tipografía, componentes y espaciado |

---

## 🖥 Stack Tecnológico

| Tecnología | Versión |
|---|---|
| Flutter Web | ≥ 3.22.0 (SDK ≥ 3.3.0) |
| Dart | ≥ 3.3.0 |
| Firebase Auth | ^5.3.1 |
| Firestore | ^5.4.4 |
| Firebase Storage | ^12.3.2 |
| Provider | ^6.1.2 (state management) |
| google_generative_ai | ^0.4.0 (Gemini API) |
| fl_chart | ^0.71.0 (gráficos dashboard) |
| shimmer | ^3.0.0 (skeleton loading) |
| file_picker | ^8.1.2 (carga de PDFs) |
| pdf | ^3.11.1 (generación de reportes) |
| printing | ^5.13.1 (impresión de reportes) |
| intl | ^0.20.2 (formateo de fechas) |
| url_launcher | ^6.3.0 (apertura de enlaces) |
| uuid | ^4.5.1 (generación de IDs) |
| flutter_localizations | i18n (ES/EN) |

---

## 📂 Arquitectura

```
lib/
├── main.dart                         # Punto de entrada + MultiProvider
├── firebase_options.dart             # Credenciales Firebase (flutterfire)
│
├── models/
│   ├── user_model.dart               # Modelo de usuario + roles
│   ├── experience_model.dart         # Modelo de experiencia (tags, challenges, benefits)
│   └── attachment_model.dart         # Modelo de archivo adjunto
│
├── services/
│   ├── auth_service.dart             # Firebase Auth + traducción errores
│   ├── firestore_service.dart        # CRUD + paginación + estadísticas
│   ├── storage_service.dart          # Subida PDFs con progreso + validación
│   └── ai_service.dart               # Gemini API: extracción JSON + Copilot RAG
│
├── providers/
│   ├── auth_provider.dart            # Estado de auth + datos usuario
│   ├── experience_provider.dart      # Filtros + paginación + CRUD + IA
│   └── theme_provider.dart           # Toggle dark/light mode
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # Login glassmorphism
│   │   └── register_screen.dart      # Registro con validaciones
│   ├── home_screen.dart              # Dashboard + TabBar (Experiencias + Estadísticas)
│   ├── add_experience_screen.dart    # Formulario + IA Insights + carga archivos
│   └── experience_detail_screen.dart # Vista completa + export PDF
│
├── widgets/
│   ├── auth_wrapper.dart             # StreamBuilder authStateChanges
│   ├── experience_card.dart          # Card con hover + admin delete
│   ├── stats_card.dart               # Métrica del dashboard
│   ├── executive_summary_card.dart   # Resumen ejecutivo del dashboard
│   ├── industry_bar_chart.dart       # Gráfico de barras por industria
│   ├── experience_line_chart.dart    # Gráfico de línea de tendencia mensual
│   ├── copilot_chat_drawer.dart      # Chat drawer con AI Copilot (RAG)
│   ├── attachment_item.dart          # Item PDF compact/full
│   ├── gradient_button.dart          # Botón azul→violeta
│   ├── industry_badge.dart           # Pill con gradiente
│   ├── search_filter_bar.dart        # Búsqueda + filtros
│   ├── loading_shimmer.dart          # Skeleton idéntico a card
│   ├── app_text_field.dart           # TextField del Design System
│   ├── app_button.dart               # Botón del Design System
│   └── empty_state.dart              # Estado vacío del Design System
│
├── utils/
│   ├── pdf_generator.dart            # Reporte + detalle PDF
│   └── validators.dart               # Validaciones de formularios
│
└── theme/
    ├── app_theme.dart                # Tema claro + oscuro + primaryDark
    ├── design_system.dart            # Spacing, Radius, Shadows
    ├── app_colors.dart               # Paleta extendida (AppColors)
    ├── app_typography.dart           # Escala tipográfica (AppTypography)
    └── component_theme.dart          # Themes de componentes reutilizables
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
| Campo             | Tipo         | Descripción                        |
|-------------------|--------------|-------------------------------------|
| companyName       | string       | Nombre de la empresa                |
| industry          | string       | Sector/Industria                    |
| summary           | string       | Resumen (mín. 50 caracteres)        |
| registrationDate  | Timestamp    | Fecha del registro                  |
| createdBy         | string       | UID del autor                       |
| createdByName     | string       | Nombre del autor                    |
| createdByCompany  | string       | Empresa del autor                   |
| tags              | array        | Etiquetas (extraídas por IA o manuales) |
| keyChallenges     | array        | Retos clave identificados           |
| keyBenefits       | array        | Beneficios o aprendizajes clave     |
| attachments       | array        | Lista de AttachmentModel            |
| createdAt         | Timestamp    | Timestamp de creación               |

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

- [Flutter SDK](https://flutter.dev/docs/get-started/install) **≥ 3.22.0** con soporte Web
- [Dart SDK](https://dart.dev/get-dart) **≥ 3.3.0**
- [Node.js](https://nodejs.org/) ≥ 16 (para Firebase CLI)
- [Firebase CLI](https://firebase.google.com/docs/cli): `npm install -g firebase-tools`
- Google Chrome instalado
- Cuenta Google con acceso a [Firebase Console](https://console.firebase.google.com)
- Clave de API de [Google AI Studio](https://aistudio.google.com/apikey) (para funciones IA)

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

## 🚀 Instalación y Ejecución

```bash
# 1. Clonar el repositorio
git clone <repo-url>
cd blockchain_app

# 2. Instalar dependencias
flutter pub get

# 3. Configurar API key de Gemini (el código usa --dart-define)
#    Ejecutar con la clave como dart-define:
flutter run -d chrome --dart-define=GEMINI_API_KEY=tu_clave_aqui
#    Para build de producción:
flutter build web --dart-define=GEMINI_API_KEY=tu_clave_aqui

# 4. Ejecutar en Chrome
flutter run -d chrome

# 5. Compilar para producción
flutter build web

# 6. Desplegar en Firebase Hosting
firebase login
firebase init hosting
firebase deploy --only hosting
```

---

## 🤖 Integración de IA

### AIService (`lib/services/ai_service.dart`)

Servicio unificado que usa **Google Gemini 2.5 Flash** con dos modos de operación:

1. **Extractor de Insights (JSON)** — analiza el resumen de una experiencia y devuelve tags, retos y beneficios en formato JSON estructurado. Se usa en el formulario de creación (`AddExperienceScreen`) para autocompletar estos campos.

2. **Copilot Conversacional (RAG)** — al abrir el chat, se cargan todas las experiencias desde Firestore, se serializan a JSON y se inyectan como contexto en el `systemInstruction` del modelo. El asistente responde preguntas del usuario basándose exclusivamente en esos datos, sin inventar información.

### CopilotChatDrawer (`lib/widgets/copilot_chat_drawer.dart`)

Drawer lateral accesible desde el FAB del dashboard. Ofrece:
- Sugerencias de preguntas predefinidas
- Historial de mensajes con burbujas de usuario y copilot
- Indicador de "pensando" mientras la IA responde
- Status con indicador verde/rojo de conectividad
- Scroll automático al último mensaje

### AI Insights en formulario

Al escribir un resumen y presionar "Analizar e Instalar Insights con IA", el sistema envía el texto a Gemini y rellena automáticamente los campos de tags, retos y beneficios del formulario.

---

## 🎨 Sistema de Diseño

### DesignSystem (`lib/theme/design_system.dart`)
Constantes centralizadas de espaciado, bordes redondeados y sombras:
- **Spacing**: 4, 8, 12, 16, 20, 24, 32, 48, 64
- **Radius**: xs (4), sm (8), md (12), lg (16), xl (24), pill (999)
- **Shadows**: sm, md, lg con variantes dark/light

### AppColors (`lib/theme/app_colors.dart`)
Paleta cromática extendida con:
- surfaceDark, surfaceContainerDark, cardDark
- primaryContainer, secondaryContainer
- successGreen, warningAmber, errorRed, infoBlue
- Gradientes predefinidos: primaryGradient, chartGradient, etc.

### AppTypography (`lib/theme/app_typography.dart`)
Escala tipográfica con estilos predefinidos:
- displayLarge, displayMedium, headlineLarge/Medium/Small
- titleLarge/Medium/Small, bodyLarge/Medium/Small
- labelLarge/Medium/Small

### ComponentTheme (`lib/theme/component_theme.dart`)
Temas reutilizables para componentes del ecosistema:
- AppTextFieldTheme, AppButtonTheme, AppCardTheme, AppChipTheme
- InputDecoration, ElevatedButton, OutlinedButton, Card, Chip

### Widgets del Design System
- `app_text_field.dart` — campos de texto con estilo unificado
- `app_button.dart` — botones primarios, secundarios y outlined
- `empty_state.dart` — estado vacío con icono y mensaje

---

## 📊 Dashboard y Analytics

El dashboard (`HomeScreen`) se organiza en dos tabs:

### "Experiencias"
- Grid responsivo de tarjetas con datos de cada experiencia
- Barra de búsqueda con filtros por industria y rango de fechas
- Filtro por tags
- FABs para agregar experiencia y abrir el Copilot IA

### "Estadísticas"
- **StatsCard** — 4 métricas (total experiencias, industrias, empresas, adjuntos)
- **ExecutiveSummaryCard** — resumen ejecutivo con totales, top industria y rango de fechas
- **IndustryBarChart** — gráfico de barras con distribución por industria
- **ExperienceLineChart** — gráfico de línea con tendencia mensual de registros
- Selector de rango de fechas para filtrar estadísticas

---

## 🔒 Seguridad en Producción

1. Actualizar reglas Firestore para validar datos en escritura
2. Configurar CORS en Firebase Storage
3. Añadir dominio personalizado en Firebase Hosting
4. Revisar reglas de Storage para restringir por tipo de archivo
5. Monitorear uso con Firebase Performance y Crashlytics
6. No exponer la API key de Gemini en el frontend (usar Cloud Function como proxy)

---

## ❓ Solución de Problemas

### La IA no responde / "API key not set"
```
Asegúrate de ejecutar con --dart-define:
flutter run -d chrome --dart-define=GEMINI_API_KEY=tu_clave
```
Si usas `flutter build web`, incluye el mismo flag en el build.

### Error `cloud_firestore/failed-precondition`
Ocurre cuando se usan filtros combinados (industria + fecha) sin índices compuestos. La app aplica filtros del lado del cliente, pero si agregas consultas nuevas, crea los índices desde el enlace de error en la consola de Firebase.

### Error de CORS en Storage
Si los PDFs no se cargan, configura CORS en Firebase Storage:
```bash
gsutil cors set cors.json gs://tu-bucket.appspot.com
```

### Error `setState() called during build`
Es un warning controlado por `AuthProvider._safeNotify()`. No afecta la funcionalidad.

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

**¿Por qué Gemini para IA?**
- Modelo gratuito con cuota generosa (Gemini 2.5 Flash)
- Soporte nativo para JSON structured output
- API sencilla con el paquete `google_generative_ai`
- Sin necesidad de servidor propio para el RAG conversacional
