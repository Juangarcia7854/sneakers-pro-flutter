# 👟 Sneakers Pro 
Aplicación e-commerce premium para la venta de zapatillas deportivas, desarrollada con Flutter y respaldada por una arquitectura serverless utilizando flujos de automatización en n8n y Google Sheets como base de datos.

## 🚀 Características Principales
* **Catálogo Dinámico:** Consumo de inventario en tiempo real vía Webhook.
* **Autenticación con OTP:** Registro de usuarios con verificación SMS de 6 dígitos.
* **Persistencia de Sesión:** Login seguro que mantiene la sesión activa en el dispositivo.
* **Carrito y Pedidos:** Gestión de carrito de compras y actualización de stock en Google Sheets.
* **Historial de Compras:** Rastreo de pedidos anteriores directamente desde el perfil.

## 🏗️ Arquitectura
* **Frontend:** Flutter (Dart) con gestión de estado a través de `Provider`.
* **Backend:** Automatización de Webhooks mediante `n8n`.
* **Base de Datos:** Google Sheets.
* **Servicios Externos:** Twilio (para envío de SMS OTP).

## ⚙️ Cómo ejecutar el proyecto
1. Clonar este repositorio.
2. Ejecutar `flutter pub get` para instalar dependencias (`provider`, `http`, `shared_preferences`, `intl`, `cached_network_image`).
3. Ejecutar `flutter run` en un emulador o dispositivo físico.
4. *Nota:* Los flujos del backend se encuentran exportados en la carpeta `/n8n_workflows` para su importación en cualquier instancia de n8n.
