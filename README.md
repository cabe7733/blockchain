# Blockchain en la Empresa — Experiencias y Aprendizajes v2.0

![Flutter](https://img.shields.io/badge/Flutter-≥3.22.0-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-≥3.3.0-0175C2?style=flat-square&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-9.6.0-FFCA28?style=flat-square&logo=firebase)
![MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> **Plataforma web para el registro, consulta y análisis de lecciones aprendidas en implementaciones de tecnología blockchain en empresas de diversos sectores industriales.**

---

## 📋 Tabla de Contenidos

1. [Descripción del Proyecto](#-descripción-del-proyecto)
2. [Características Principales](#-características-principales)
3. [Stack Tecnológico](#-stack-tecnológico)
4. [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
5. [Modelo de Datos](#-modelo-de-datos)
6. [Sistema de Permisos y Roles](#-sistema-de-permisos-y-roles)
7. [Requisitos Previos](#-requisitos-previos)
8. [Configuración de Firebase](#-configuración-de-firebase)
9. [Instalación y Ejecución](#-instalación-y-ejecución)
10. [Integración de IA](#-integración-de-ia)
11. [Sistema de Diseño](#-sistema-de-diseño)
12. [Dashboard y Analíticas](#-dashboard-y-analíticas)
13. [Exportación de Reportes](#-exportación-de-reportes)
14. [Seguridad en Producción](#-seguridad-en-producción)
15. [Solución de Problemas](#-solución-de-problemas)
16. [Decisiones Técnicas](#-decisiones-técnicas)

---

## 📖 Descripción del Proyecto

**Blockchain en la Empresa — Experiencias y Aprendizajes** es una aplicación web desarrollada con Flutter que permite a profesionales y organizaciones registrar, explorar y aprender de las experiencias de implementación de tecnología blockchain en el entorno empresarial.

La plataforma facilita:

- **Registro de experiencias** con información detallada (empresa, industria, resumen, retos, beneficios, archivos adjuntos)
- **Análisis automatizado mediante IA** para extraer etiquetas, retos clave y beneficios de cada experiencia
- **Búsqueda y filtrado** por empresa, industria, rango de fechas, tags y contenido textual
- **Dashboard analítico** con métricas, gráficos de distribución por industria y tendencias temporales
- **Copilot conversacional** potenciado por RAG (Retrieval Augmented Generation) que responde preguntas sobre las experiencias registradas
- **Exportación de reportes** en formato PDF para compartir y archivar

### Diferencias con la versión 1.0

- Integración de **Google Gemini 2.5 Flash** para análisis de contenido y copilot conversacional
- Sistema de **gráficos interactivos** para visualización de datos
- Diseño **responsive mejorado** (hasta 4 columnas en desktop)
- **Shimmer loading** para mejor percepción de rendimiento
- Extracción automática de **insights mediante IA**

---

## ✨ Características Principales

| Característica | Descripción |
|----------------|-------------|
| **Autenticación** | Email/Password con Firebase Auth, incluyendo recuperación de contraseña |
| **Gestión de Experiencias** | CRUD completo con soporte para edición y eliminación por parte del propietario |
| **Tiempo Real** | StreamBuilder sobre Firestore para actualizaciones instantáneas |
| **Búsqueda Local** | Filtrado por empresa, industria, rango de fechas, tags, resumen, retos y beneficios |
| **Dark Mode** | Toggle entre modo claro y oscuro con persistencia en sesión |
| **Responsive Design** | 1 columna (móvil) / 2 columnas (tablet) / **4 columnas** (desktop) |
| **Exportación PDF** | Reporte colectivo (landscape) y detalle individual (portrait) |
| **AI Copilot** | Chat conversacional con contexto RAG sobre todas las experiencias |
| **AI Insights** | Extracción automática de tags, retos y beneficios al registrar |
| **Shimmer Loading** | Skeleton loaders que replican la estructura de las cards reales |
| **Paginación Infinita** | Scroll infinito con `startAfterDocument` y límite de 10 documentos |
| **Sistema de Diseño** | Colores, tipografía, espaciado y componentes consistentes |
| **Validaciones** | Formularios con validación de campos obligatorios y archivos (PDF, 10MB máx.) |
| **Link de Referencia** | Campo opcional para vincular a artículos o recursos externos |

---

## 🛠 Stack Tecnológico

### Framework y Lenguaje

| Tecnología | Versión | Uso |
|-------------|---------|-----|
| Flutter SDK | ≥ 3.22.0 | Framework principal |
| Dart | ≥ 3.3.0 | Lenguaje de programación |

### Firebase Services

| Paquete | Versión | Servicio |
|---------|---------|----------|
| `firebase_core` | ^3.6.0 | Inicialización de Firebase |
| `firebase_auth` | ^5.3.1 | Autenticación de usuarios |
| `cloud_firestore` | ^5.4.4 | Base de datos en tiempo real |
| `firebase_storage` | ^12.3.2 | Almacenamiento de archivos PDF |

### Paquetes de Terceros

| Paquete | Versión | Uso |
|---------|---------|-----|
| `provider` | ^6.1.2 | Gestión de estado |
| `google_generative_ai` | ^0.4.0 | Integración con Gemini 2.5 Flash |
| `fl_chart` | ^0.71.0 | Gráficos interactivos |
| `pdf` | ^3.11.1 | Generación de documentos PDF |
| `printing` | ^5.13.1 | Vista e impresión de PDFs |
| `shimmer` | ^3.0.0 | Efectos de carga |
| `file_picker` | ^8.1.2 | Selección de archivos |
| `intl` | ^0.20.2 | Formateo de fechas |
| `uuid` | ^4.5.1 | Generación de identificadores únicos |
| `url_launcher` | ^6.3.0 | Apertura de enlaces externos |

### Plataformas Soportadas

- ✅ **Web** (primaria)
- Android, iOS, macOS, Windows, Linux (mediante Firebase Web config)

---

## 📁 Arquitectura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada y configuración de Firebase
├── firebase_options.dart             # Opciones de Firebase por plataforma
│
├── models/                            # Modelos de datos
│   ├── user_model.dart               # Usuario
│   ├── experience_model.dart        # Experiencia de blockchain
│   └── attachment_model.dart         # Archivo adjunto PDF
│
├── services/                          # Servicios de negocio
│   ├── auth_service.dart             # Autenticación con Firebase Auth
│   ├── firestore_service.dart        # Operaciones CRUD en Firestore
│   ├── storage_service.dart          # Upload de PDFs a Firebase Storage
│   └── ai_service.dart               # Integración con Google Gemini
│
├── providers/                         # Proveedores de estado (Provider)
│   ├── auth_provider.dart            # Estado de autenticación
│   ├── experience_provider.dart     # Estado de experiencias, filtros, paginación, IA
│   └── theme_provider.dart          # Estado del tema (claro/oscuro)
│
├── screens/                           # Pantallas principales
│   ├── auth/
│   │   ├── login_screen.dart        # Inicio de sesión
│   │   └── register_screen.dart     # Registro de usuarios
│   ├── home_screen.dart             # Dashboard con tabs Experiencias/Estadísticas
│   ├── add_experience_screen.dart   # Crear/Editar experiencias
│   └── experience_detail_screen.dart # Vista detalle de experiencia
│
├── widgets/                           # Componentes reutilizables
│   ├── auth_wrapper.dart            # Wrapper de autenticación con stream
│   ├── experience_card.dart         # Card de experiencia con hover effects
│   ├── stats_card.dart              # Métrica individual del dashboard
│   ├── executive_summary_card.dart  # Resumen ejecutivo con estadísticas
│   ├── industry_bar_chart.dart      # Gráfico de barras por industria
│   ├── experience_line_chart.dart   # Gráfico de tendencia temporal
│   ├── copilot_chat_drawer.dart     # Panel lateral del copilot IA
│   ├── search_filter_bar.dart       # Barra de búsqueda y filtros
│   ├── loading_shimmer.dart         # Skeleton loader
│   ├── attachment_item.dart         # Representación de archivo adjunto
│   ├── industry_badge.dart          # Badge con gradiente por industria
│   ├── gradient_button.dart         # Botón con gradiente
│   ├── app_text_field.dart          # Campo de texto estilizado
│   ├── app_button.dart              # Botón base
│   └── empty_state.dart             # Estado cuando no hay datos
│
├── utils/                             # Utilidades
│   ├── pdf_generator.dart           # Generador de reportes PDF
│   └── validators.dart              # Validadores de formularios
│
└── theme/                             # Sistema de diseño
    ├── app_colors.dart              # Paleta de colores completa
    ├── app_typography.dart          # Estilos de tipografía
    ├── design_system.dart           # Espaciado, radios, sombras
    ├── component_theme.dart         # Temas de componentes Material
    └── app_theme.dart               # Temas claro y oscuro
```

---

## 🗄 Modelo de Datos

### Colección: `users/{uid}`

| Campo | Tipo | Descripción | Obligatorio |
|-------|------|-------------|-------------|
| `uid` | String | ID de Firebase Auth | ✅ |
| `name` | String | Nombre completo del usuario | ✅ |
| `company` | String | Nombre de la empresa | ✅ |
| `email` | String | Correo electrónico | ✅ |
| `createdAt` | Timestamp | Fecha de registro | ✅ |

> **Nota:** El modelo `UserModel` no incluye campo `role`. El sistema de permisos se basa únicamente en la propiedad `createdBy` de las experiencias.

### Colección: `experiences/{id}`

| Campo | Tipo | Descripción | Obligatorio |
|-------|------|-------------|-------------|
| `id` | String | ID del documento (Firestore auto-generado) | ✅ |
| `companyName` | String | Nombre de la empresa | ✅ |
| `industry` | String | Sector industrial | ✅ |
| `summary` | String | Resumen de la experiencia (mín. 50 caracteres) | ✅ |
| `registrationDate` | Timestamp | Fecha de registro de la experiencia | ✅ |
| `createdBy` | String | UID del usuario que creó la experiencia | ✅ |
| `createdByName` | String | Nombre del creador | ✅ |
| `createdByCompany` | String | Empresa del creador | ✅ |
| `tags` | Array\<String\> | Etiquetas (generadas por IA o manuales) | No |
| `keyChallenges` | Array\<String\> | Retos identificados | No |
| `keyBenefits` | Array\<String\> | Beneficios y aprendizajes | No |
| `attachments` | Array | Lista de archivos PDF adjuntos | No |
| `link` | String | URL de referencia externa | No |
| `createdAt` | Timestamp | Timestamp de creación en Firestore | ✅ |

### Modelo: `AttachmentModel`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `fileName` | String | Nombre original del archivo |
| `fileUrl` | String | URL de descarga en Firebase Storage |
| `fileSize` | int | Tamaño en bytes |
| `uploadedAt` | DateTime | Fecha de subida |

### Industrias Disponibles

| Industria | Color del Badge |
|-----------|-----------------|
| Finanzas | Verde (#10B981) |
| Logística | Azul (#3B82F6) |
| Salud | Rojo (#EF4444) |
| Retail | Amarillo (#F59E0B) |
| Manufactura | Violeta (#8B5CF6) |
| Gobierno | Índigo (#6366F1) |
| Educación | Teal (#14B8A6) |
| Otro | Gris (#6B7280) |

### Storage: Firebase Storage

```
/attachments/{experienceId}/{fileName}
```

- Formato permitido: **únicamente PDF**
- Tamaño máximo por archivo: **10 MB**
- Múltiples archivos por experiencia: **soportado**

---

## 🔐 Sistema de Permisos y Roles

> **⚠️ Nota importante:** A diferencia de versiones anteriores, **esta aplicación NO utiliza roles de administrador/viewer**. El único sistema de permisos se basa en la propiedad `createdBy` de cada experiencia.

### Permisos por Experiencia

| Acción | ¿Quién puede realizarla? |
|--------|---------------------------|
| **Leer** | Cualquier usuario autenticado |
| **Crear** | Cualquier usuario autenticado |
| **Editar** | **Solo el propietario** (`createdBy == uid`) |
| **Eliminar** | **Solo el propietario** (`createdBy == uid`) |

### Lógica implementada en `ExperienceCard`

```dart
final isOwner = widget.experience.createdBy == currentUid;
```

- Si `isOwner == true`: Se muestra el botón de eliminar
- La edición se realiza desde `AddExperienceScreen` que recibe `experienceToEdit` opcional
- Solo el owner puede passar el parámetro `experienceToEdit` con valor válido

### Reglas de Firestore recomendadas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Colección users: cada usuario solo puede leer/escribir su propio documento
    match /users/{userId} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
    
    // Colección experiences: permisos basados en createdBy
    match /experiences/{docId} {
      allow read: if request.auth != null;
      
      allow create: if request.auth != null
        && request.resource.data.createdBy == request.auth.uid;
      
      allow update: if request.auth != null
        && resource.data.createdBy == request.auth.uid;
      
      allow delete: if request.auth != null
        && resource.data.createdBy == request.auth.uid;
    }
  }
}
```

---

## ✅ Requisitos Previos

### Software necesario

1. **Flutter SDK** ≥ 3.22.0
   ```bash
   flutter --version
   ```

2. **Dart SDK** ≥ 3.3.0

3. **Node.js** (opcional, para Firebase CLI)
   ```bash
   node --version
   ```

4. **Firebase CLI** (opcional, para despliegue)
   ```bash
   npm install -g firebase-tools
   ```

### Cuenta de Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Habilitar los servicios:
   - **Authentication** → Email/Password
   - **Firestore Database** → Crear en modo Producción o Test
   - **Storage** → Crear bucket
3. Registrar una app Web y obtener la configuración

### Clave de API de Google Gemini (opcional para IA)

1. Obtener API Key en [Google AI Studio](https://aistudio.google.com/apikey)
2. La clave debe tener acceso al modelo `gemini-2.5-flash`

---

## 🔥 Configuración de Firebase

### 1. Configuración del proyecto

```bash
# Instalar FlutterFire CLI (si no está instalado)
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

### 2. Habilitar servicios

#### Authentication

1. Ir a **Authentication** → **Sign-in method**
2. Habilitar **Email/Password**

#### Firestore Database

1. Ir a **Firestore Database** → **Create database**
2. Seleccionar ubicación (ej: us-central)
3. Comenzar en **production** o **test mode**
4. Aplicar las reglas de seguridad documentadas anteriormente

#### Storage

1. Ir a **Storage** → **Get started**
2. Seleccionar ubicación
3. Aplicar reglas para permitir uploads autenticados

### 3. Variables de entorno

Crear archivo `.env` en la raíz del proyecto:

```env
GEMINI_API_KEY=tu_api_key_de_gemini
```

O pasar como argumento al ejecutar:

```bash
flutter run --dart-define=GEMINI_API_KEY=tu_api_key
```

### 4. Configuración de índices compuestos (Firestore)

La aplicación utiliza filtrado en el cliente para evitar errores de índices. Sin embargo, si deseas filtrar en el servidor, crea estos índices en Firestore:

| Colección | Campos |
|-----------|--------|
| experiences | `industry` ASC, `createdAt` DESC |
| experiences | `registrationDate` ASC, `createdAt` DESC |

---

## 📦 Instalación y Ejecución

### 1. Clonar el proyecto

```bash
git clone <repository-url>
cd blockchain_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

El archivo `lib/firebase_options.dart` ya está configurado con el proyecto `blockchain-app-95ee5`. Si usas tu propio proyecto:

1. Ejecutar `flutterfire configure`
2. Reemplazar el contenido de `lib/firebase_options.dart`
3. Actualizar las reglas de Firestore

### 4. Ejecutar la aplicación

```bash
# Modo desarrollo (web)
flutter run -d chrome

# Con API key de Gemini
flutter run -d chrome --dart-define=GEMINI_API_KEY=tu_api_key

# Modo release
flutter run -d chrome --release
```

### 5. Construir para producción

```bash
# Construir bundle web
flutter build web

# El output estará en build/web/
```

---

## 🤖 Integración de IA

La aplicación utiliza **Google Gemini 2.5 Flash** para dos funcionalidades:

### 1. AI Insights (Extracción de Insights)

Cuando el usuario escribe un resumen de al menos 50 caracteres, puede presionar **"Analizar e Instalar Insights con IA"** para extraer:

- **Tags/Etiquetas**: 2-4 etiquetas representativas
- **Retos Clave**: 1-3 retos principales
- **Beneficios/Lecciones**: 1-3 beneficios o aprendizajes

#### Prompt utilizado

```
Analiza la siguiente lección aprendida sobre la implementación 
de Blockchain en una empresa y extrae información clave en formato JSON.

El JSON retornado debe cumplir estrictamente con esta estructura:
{
  "tags": ["Tag1", "Tag2", "Tag3"],
  "challenges": ["Reto1", "Reto2", "Reto3"],
  "benefits": ["Beneficio1", "Beneficio2", "Beneficio3"]
}
```

### 2. AI Copilot (RAG Chatbot)

El copilot conversacional permite hacer preguntas sobre las experiencias registradas usando **Retrieval Augmented Generation (RAG)**.

#### Características

- **Contexto inyectado**: Todas las experiencias se pasan como contexto JSON al system instruction
- **Modelo dedicado**: `gemini-2.5-flash` con `systemInstruction` en el constructor
- **Historial de conversación**: Mantiene contexto en la sesión
- **Preguntas sugeridas**: 4 sugerencias predefinidas para iniciar

#### Flujo de inicialización

```dart
// 1. Obtener experiencias en formato compacto (máx. 100)
final experiences = await firestoreService.getAllExperiencesCompact(limit: 100);

// 2. Crear sesión con system instruction
final chatSession = aiService.startCopilotSession(experiences);

// 3. Enviar mensajes usando sendMessage()
final response = await chatSession.sendMessage(Content.text(message));
```

#### System Instruction

```
Eres el Copilot Experto de Blockchain en la Empresa. Eres un asistente 
virtual diseñado para analizar lecciones aprendidas de implementaciones 
de blockchain empresarial.

Tu conocimiento fundamental para responder se basa ÚNICAMENTE en la 
siguiente base de datos en formato JSON...

Reglas críticas:
1. Si el usuario pregunta sobre algo NO en el JSON, indícalo amablemente
2. Responde con tono formal, profesional y analítico
3. Usa Markdown en tus respuestas
4. Relaciona y contrasta experiencias cuando sea útil
```

### 3. Deshabilitar IA

Si no se proporciona `GEMINI_API_KEY` o está vacía:

- El botón "Analizar con IA" no aparece
- El Copilot muestra estado "Deshabilitado"
- La aplicación funciona normalmente sin funciones de IA

---

## 🎨 Sistema de Diseño

### Paleta de Colores

#### Colores Primarios

| Nombre | Hex | Uso |
|--------|-----|-----|
| primaryBlue | `#2563EB` | Color principal |
| primaryBlueLight | `#3B82F6` | Variante clara |
| primaryBlueDark | `#1D4ED8` | Variante oscura |
| primaryViolet | `#7C3AED` | Acento |
| primaryVioletLight | `#8B5CF6` | Variante clara |

#### Colores Semánticos

| Nombre | Hex | Uso |
|--------|-----|-----|
| success | `#10B981` | Éxito |
| warning | `#F59E0B` | Advertencia |
| error | `#EF4444` | Error |
| info | `#06B6D4` | Información |

#### Neutrales (Modo Claro)

| Nombre | Hex |
|--------|-----|
| background | `#F9FAFB` |
| surface | `#FFFFFF` |
| textPrimary | `#111827` |
| textSecondary | `#6B7280` |
| border | `#E5E7EB` |

#### Neutrales (Modo Oscuro)

| Nombre | Hex |
|--------|-----|
| darkBg | `#0F172A` |
| darkSurface | `#1E293B` |
| darkTextPrimary | `#F9FAFB` |
| darkTextSecondary | `#9CA3AF` |
| darkBorder | `#374151` |

### Tipografía

Sistema basado en **Outfit** (Google Fonts):

| Estilo | Tamaño | Peso | Uso |
|--------|--------|------|-----|
| headlineLarge | 32px | Bold | Títulos principales |
| headlineMedium | 24px | Bold | Subtítulos |
| headlineSmall | 20px | SemiBold | Encabezados |
| titleLarge | 22px | SemiBold | Títulos de sección |
| titleMedium | 16px | Medium | Títulos de cards |
| bodyLarge | 16px | Regular | Cuerpo de texto |
| bodyMedium | 14px | Regular | Texto secundario |
| bodySmall | 12px | Regular | Metadatos |
| captionLarge | 14px | Medium | Labels |

### Espaciado (Sistema de 8px)

| Nombre | Valor |
|--------|-------|
| xs | 4px |
| sm | 8px |
| md | 16px |
| lg | 24px |
| xl | 32px |
| xxl | 48px |
| xxxl | 64px |

### Radios de Borde

| Nombre | Valor |
|--------|-------|
| xs | 4px |
| sm | 8px |
| md | 12px |
| lg | 16px |
| xl | 24px |
| xxl | 32px |

### Sombras

| Nivel | blurRadius | offset |
|-------|------------|--------|
| subtle | 8px | (0, 2) |
| card | 16px | (0, 4) |
| elevated | 24px | (0, 8) |
| floating | 32px | (0, 12) |

### Duraciones de Animación

| Nombre | Duración |
|--------|----------|
| instant | 100ms |
| fast | 200ms |
| normal | 300ms |
| slow | 500ms |
| verySlow | 800ms |

---

## 📊 Dashboard y Analíticas

### Pestaña "Estadísticas"

El dashboard presenta 4 métricas principales y 2 gráficos:

#### Métricas

1. **Total** — Cantidad total de experiencias registradas
2. **Empresas** — Número de empresas únicas
3. **Sector Líder** — Industria con más experiencias
4. **PDFs** — Cantidad total de archivos adjuntos

#### Gráficos

1. **IndustryBarChart** — Distribución de experiencias por industria
   - Gráfico de barras horizontales
   - Colores según la paleta de industrias
   - Ordenado por cantidad descendente

2. **ExperienceLineChart** — Tendencia temporal de registros
   - Gráfico de líneas
   - Eje X: Mes-Año (ej: "2024-03")
   - Eje Y: Cantidad de registros
   - Ordenado cronológicamente

#### Resumen Ejecutivo

Tarjeta que muestra:
- Total de experiencias
- Total de empresas únicas
- Industria más popular
- Empresas que más han registrado
- Promedio de experiencias por empresa

### Pestaña "Experiencias"

- Lista de todas las experiencias filtrables
- Búsqueda por texto en: empresa, industria, tags, resumen, retos, beneficios
- Filtro por industria (dropdown)
- Filtro por rango de fechas (DateRangePicker)
- Botón para limpiar filtros
- Paginación infinita con scroll

---

## 📄 Exportación de Reportes

### PDF de Reporte Coleivo

Genera un documento landscape con tabla de todas las experiencias:

- **Formato**: A4 Landscape
- **Tabla columnas**: Empresa, Industria, Fecha, Registrado por, Resumen (truncado a 120 chars), Adjuntos
- **Paginación**: 15 filas por página
- **Encabezado**: Gradiente azul-violeta con logo y fecha de generación
- **Pie de página**: "Blockchain en la Empresa — Confidencial" + número de página

### PDF de Detalle Individual

Genera un documento portrait con información completa de una experiencia:

- **Formato**: A4 Portrait
- **Margen**: 32px
- **Campos**: Empresa, Industria, Fecha, Registrado por, Link de Referencia (si existe)
- **Resumen**: Texto completo en contenedor con fondo
- **Archivos Adjuntos**: Lista de archivos con viñetas

---

## 🔒 Seguridad en Producción

### Recomendaciones

1. **Configurar reglas de Firestore** según el modelo documentado
2. **Habilitar App Check** para proteger against abuse
3. **Configurar CORS** en Firebase Storage si es necesario
4. **Usar HTTPS** obligatoriamente
5. **No exponer API keys** en código cliente:
   - Usar Firebase Security Rules
   - Considerar Cloud Functions para operaciones sensibles
6. **Validar archivos PDF** en servidor ( Cloud Functions) si es necesario
7. **Limitar tamaño de uploads** a 10MB por archivo

### Límites de la aplicación

- Máximo 10 MB por archivo PDF
- Solo extensión `.pdf` permitida
- Máximo 100 experiencias para contexto RAG del copilot
- Timeout de 60 segundos para llamadas a Gemini

---

## 🔧 Solución de Problemas

### Error: `cloud_firestore/failed-precondition`

**Causa**: Intentar hacer `where()` + `orderBy()` en campos diferentes sin índice compuesto.

**Solución**: La aplicación filtra en el cliente sobre el stream de Firestore. Si deseas filtrar en servidor, crea los índices compuestos necesarios en Firestore Console.

### Error: "AI features will be disabled"

**Causa**: `GEMINI_API_KEY` no está definida o está vacía.

**Solución**: Obtener API key de Google AI Studio y pasar como `--dart-define=GEMINI_API_KEY=tu_key`.

### Error: `INVALID_LOGIN_CREDENTIALS`

**Causa**: Credenciales de Firebase Auth inválidas.

**Solución**: Verificar que el email/password sea correcto y que Email/Password esté habilitado en Firebase Console.

### Error: `permission_denied` en Storage

**Causa**: Reglas de Storage no permiten escritura.

**Solución**: Aplicar las reglas documentadas o permitir autenticados:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /attachments/{experienceId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType == 'application/pdf';
    }
  }
}
```

### Shimmer no coincide con la card real

**Causa**: El skeleton loader intenta replicar la estructura de `ExperienceCard` con sus animaciones.

**Solución**: El shimmer en `LoadingShimmer` incluye los mismos elementos: avatar placeholder, líneas de texto, badge de industria.

### Copilot no responde

**Causa**: La sesión RAG no se inicializó o `isAiEnabled` es `false`.

**Solución**: Verificar que `GEMINI_API_KEY` esté configurada y que `initCopilotSession()` se llamó.

---

## 📐 Decisiones Técnicas

### 1. Filtrado en Cliente vs Servidor

**Decisión**: Aplicar filtros en el cliente (`ExperienceProvider.filteredExperiences()`).

**Razón**: Evita el error `cloud_firestore/failed-precondition` causado por combinaciones de `where()` + `orderBy()` que requieren índices compuestos. La pérdida de rendimiento es aceptable dado el límite de documentos (10 por página).

### 2. Sin Sistema de Roles

**Decisión**: No implementar roles admin/viewer.

**Razón**: Simplifica el modelo de datos. La propiedad `createdBy` es suficiente para determinar permisos de edición/eliminación. Todos los usuarios autenticados pueden leer todas las experiencias.

### 3. Provider para State Management

**Decisión**: Usar Provider en lugar de Riverpod, Bloc o GetX.

**Razón**: Provider es el paquete recomendado por Flutter team para state management, con API simple y suficiente para las necesidades de la app.

### 4. System Instruction en Constructor de GenerativeModel

**Decisión**: Crear un `GenerativeModel` nuevo con `systemInstruction` por cada sesión de chat.

**Razón**: Pasar `systemInstruction` dentro de `startChat(history:)` causaba `AssertionError` en `_aggregate`. La solución es instanciar el modelo con el system instruction y usar `startChat(history: [])`.

### 5. Shimmer con Estructura Idéntica

**Decisión**: Implementar `LoadingShimmer` que replica exactamente la estructura de `ExperienceCard`.

**Razón**: Evita el "layout shift" cuando las cards reales cargan. El skeleton incluye avatar, gradiente decorativo, líneas de texto, badge de industria y botón.

### 6. Responsive: 4 Columnas en Desktop

**Decisión**: Grid de 4 columnas en desktop (≥1100px).

**Razón**: El espacio horizontal disponible en desktop permite mostrar más contenido sin hacinamiento. El `childAspectRatio: 0.75` mantiene tarjetas de altura consistente.

### 7. Paginación con Scroll Infinito

**Decisión**: Usar `ScrollController` con侦听 y `startAfterDocument`.

**Razón**: Más natural que botones "Cargar más". El threshold de 300px antes del final anticipa la necesidad de cargar más documentos.

### 8. Link Opcional en Modelo

**Decisión**: Campo `link` de tipo `String?` con validación de URL.

**Razón**: Permite referencing artículos o recursos externos relevantes sin obligatoriedad. Validado con regex que acepta http/https.

---

## 📄 Licencia

MIT License — Ver archivo `LICENSE` para más detalles.


**Versión:** 2.0.0+1  
**Última actualización:** Mayo 2026