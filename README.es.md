<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Icono de Mac Sai" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>El limpiador, optimizador y escáner de malware de código abierto para Mac.</strong><br>
  Una alternativa gratuita a CleanMyMac, notarizada por Apple y creada con Swift 6 y SwiftUI.<br>
  <sub>Más de 125.000 descargas. Gratis para siempre y sin telemetría.</sub>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <a href="README.de.md">Deutsch</a> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a> | <strong>Español</strong> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (Brasil)</a> | <a href="README.ja.md">日本語</a> | <a href="README.ko.md">한국어</a> | <a href="README.tr.md">Türkçe</a>
</p>

<p align="center">
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/downloads/iliyami/MacSai/total?style=flat-square&label=downloads&color=2ea44f" alt="Descargas totales" /></a>
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="Estrellas en GitHub" /></a>
  <a href="https://formulae.brew.sh/cask/mac-sai"><img src="https://img.shields.io/homebrew/cask/installs/dm/mac-sai?style=flat-square&label=homebrew&color=orange" alt="Instalaciones con Homebrew" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="Última versión" /></a>
  <a href="https://github.com/iliyami/MacSai/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/iliyami/MacSai?style=flat-square&label=commits" alt="Actividad de commits" /></a>
  <br>
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="Notarizada" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="Sin telemetría" />
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6-orange?style=flat-square" alt="Swift 6" />
  <a href="https://github.com/iliyami/MacSai/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/iliyami/MacSai/ci.yml?branch=main&style=flat-square&label=tests" alt="Pruebas" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="Licencia" /></a>
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Captura de pantalla de Mac Sai" />
</p>

<p align="center">
  <strong>Instálala con un solo comando:</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  O descarga el <a href="https://github.com/iliyami/MacSai/releases/latest">DMG más reciente</a>. Está notarizado por Apple, así que se abre sin más: sin clic derecho, sin advertencias y sin Terminal.
</p>

<p align="center">
  <sub>Nunca habrá anuncios en la app. Esta página tiene <a href="SPONSORS.md">un único espacio de patrocinio verificado</a>, y está disponible.</sub>
</p>

---

## ¿Por qué Mac Sai?

Un limpiador completo para Mac no debería costar una suscripción anual ni pedirte que confíes en una caja negra con acceso profundo a tus archivos. Mac Sai te ofrece todas las herramientas, a la vista de todos.

- **Gratis, para siempre.** Sin suscripción, sin compras dentro de la app, sin "pásate a Pro" y sin pantallas insistentes. Con licencia BSD-3.
- **Cero telemetría.** Sin analíticas, sin informes de fallos, sin rastreadores y sin ningún servidor al que enviar datos. Y no tienes que creernos sin más: [verifícalo tú mismo](#verifica-tú-mismo-que-no-hay-telemetría) con dos comandos.
- **Todas las herramientas principales de CleanMyMac, en una sola app.** 22 módulos de limpieza, protección, rendimiento, aplicaciones y análisis del disco, además de un widget en la barra de menús.
- **Segura por diseño.** Todo se envía primero a la Papelera, hay una lista de rutas protegidas, protecciones contra enlaces simbólicos y TOCTOU, y un `SafetyGuard` que valida cada ruta. Está diseñada para no perder nunca tus datos.
- **Notarizada por Apple y totalmente de código abierto.** Tu Mac verifica la firma en cada inicio, y cada línea de código está aquí para que la leas.

---

## Funciones de un vistazo

<table>
<tr>
<td width="33%" valign="top">

### 🧹 Limpieza
- **Smart Scan** (un clic)
- **System Junk** (más de 16 categorías)
- **Mail Attachments**
- **Trash Bins**
- **Project Junk** (carpetas de compilación)
- **Disk Hogs** (Docker, simuladores)
- **Clean History** (restauración con un clic)

</td>
<td width="33%" valign="top">

### 🛡️ Protección
- **Malware Removal**
- **Privacy** (navegadores)
- **Browser Extensions**
- **Saved Wi-Fi**
- **Permissions Overview**

</td>
<td width="33%" valign="top">

### ⚡ Rendimiento
- **Optimization** (ítems de inicio)
- **Maintenance** (tareas del sistema)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 Aplicaciones
- **Uninstaller** (+ restablecer valores predeterminados)
- **Unused Apps**
- **Extensions** (paneles, plug-ins)
- **Updater**

</td>
<td width="33%" valign="top">

### 🗂️ Archivos
- **Space Lens** (mapa del disco)
- **Large & Old Files**
- **Duplicates** (+ consolidación)
- **Shredder**

</td>
<td width="33%" valign="top">

### 📊 Barra de menús
- CPU / memoria / disco / batería en tiempo real
- Red, tiempo de actividad, swap
- Recomendaciones útiles

</td>
</tr>
</table>

---

## Funciones en detalle

### 🧹 Limpieza
| Módulo | Qué hace |
|--------|------------|
| **Smart Scan** | Con un clic ejecuta a la vez los módulos de limpieza, protección y rendimiento con el progreso en tiempo real, y luego muestra exactamente cuánto liberó cada módulo |
| **System Junk** | Más de 16 categorías de análisis: cachés del usuario y del sistema, registros, archivos de idioma, preferencias dañadas, ítems de inicio dañados, versiones de documentos, copias de seguridad de iOS, restos de Xcode, cachés de gestores de paquetes / IDE / herramientas de IA, restos de usuarios eliminados y **reducción de binarios universales** (encuentra binarios Mach-O "fat" que incluyen arm64 y x86_64 y los reescribe para tu arquitectura nativa con `lipo`, respetando Cancelar) |
| **Mail Attachments** | Encuentra los archivos adjuntos en caché de Apple Mail, Outlook y Spark |
| **Trash Bins** | Vacía la Papelera en todas las ubicaciones, incluidos los discos externos |
| **Project Junk** | Encuentra carpetas de compilación regenerables en tus proyectos: `node_modules`, `.next`, `dist`, `target` de Rust y Maven, `build` de Gradle, entornos virtuales de Python y `Pods` de CocoaPods. Una carpeta solo cuenta si los archivos que la acompañan confirman el tipo de proyecto, y `dist` y `Pods` solo si tu `.gitignore` los menciona. Todo va a la Papelera |
| **Disk Hogs** | Muestra cuánto espacio ocupan Docker y los simuladores de Xcode. Elimina contenedores detenidos, imágenes huérfanas y la caché de compilación huérfana (cada acción con su confirmación), y borra los simuladores no disponibles y los runtimes de simulador antiguos. Los volúmenes de Docker y el runtime más reciente de cada plataforma nunca se tocan |
| **Clean History** | Muestra tus limpiezas recientes (los últimos 30 días, hasta 20) y recupera una limpieza completa de la Papelera con un clic. El historial se queda en tu Mac, en `~/Library/Logs/MacClean/clean-history.json`, solo lo puede leer tu cuenta de usuario y nunca se envía a ninguna parte |

### 🛡️ Protección
| Módulo | Qué hace |
|--------|------------|
| **Malware Removal** | Análisis basado en firmas con 3 niveles de profundidad (Rápido / Equilibrado / Profundo): agentes y daemons de arranque, paquetes de apps, extensiones de navegador y patrones conocidos de adware/malware. Comparación exacta de hashes con las firmas de XProtect de Apple que ya están en tu Mac, sin conexión, además de un feed opcional de hashes de MalwareBazaar (abuse.ch). Las extensiones de Safari de la lista de bloqueo de Apple y las coincidencias de MalwareBazaar se muestran para que las revises, nunca vienen preseleccionadas (no es un antivirus, y lo dice claramente) |
| **Privacy** | Limpia el historial, las cookies y la caché de Safari, Chrome y Firefox, con filtros por fecha. Los **marcadores de Safari nunca se tocan** |
| **Browser Extensions** | Muestra las extensiones instaladas en Safari, Chrome, Brave, Edge, Arc y Firefox. Las extensiones de Chromium y Firefox que instalaste tú pueden ir a la Papelera mientras ese navegador está cerrado; las instaladas por una política o por el propio navegador se muestran, pero no se tocan. Las extensiones de Safari enlazan a los ajustes de Safari |
| **Saved Wi-Fi** | Muestra tus redes inalámbricas preferidas y olvida las que elijas |
| **Permissions Overview** | Una vista de solo lectura, organizada por app, de los permisos de privacidad (TCC) que tiene cada app, el enfoque que Ajustes del Sistema no te ofrece. Cada acción abre directamente Ajustes del Sistema, que es donde están los interruptores |

### ⚡ Rendimiento
| Módulo | Qué hace |
|--------|------------|
| **Optimization** | Gestiona los ítems de inicio y los agentes de arranque, activándolos o desactivándolos uno a uno |
| **Maintenance** | Tareas del sistema: liberar RAM, ejecutar scripts de mantenimiento, verificar el disco de arranque, reconstruir Launch Services, reindexar Spotlight, vaciar la caché DNS y reducir las instantáneas de Time Machine. Las tareas están etiquetadas por nivel de riesgo, "Ejecutar tareas seguras" las ejecuta una tras otra y la contraseña de administrador se pide **una sola vez** |

### 📦 Aplicaciones
| Módulo | Qué hace |
|--------|------------|
| **Uninstaller** | Un motor de coincidencia de patrones que encuentra todos los archivos asociados en más de 17 subdirectorios de Library (incluidas las apps anidadas en subcarpetas del fabricante). Eliminación completa, **restablecer valores predeterminados** (borra las cachés y preferencias de una app sin eliminar la app) y detección de apps sin usar |
| **Unused Apps** | Encuentra las apps que no has abierto en 3, 6 o 12 meses, según la fecha de último uso de Spotlight, ordenadas por tamaño. Las apps abiertas nunca aparecen y, cuando Spotlight no tiene datos de uso, lo indica en lugar de adivinar. Con un clic, envía una app al Uninstaller |
| **Extensions** | Revisa paneles de preferencias, Internet Plug-Ins y extensiones de Safari de terceros. Los paneles y plug-ins instalados por el usuario pueden ir a la Papelera |
| **Updater** | Busca actualizaciones de las apps instaladas mediante sus propios feeds appcast de Sparkle (solo lee la información de versión y no envía nada sobre ti) |

### 🗂️ Archivos
| Módulo | Qué hace |
|--------|------------|
| **Space Lens** | Visualización del uso del disco en un mapa de árbol (squarified treemap) con navegación por niveles |
| **Large & Old Files** | Encuentra archivos de más de 50 MB, ordenados por tamaño y fecha del último acceso |
| **Duplicates** | Detección progresiva (agrupación por tamaño, SHA-256 parcial, hash completo, verificación de inodos), además de un modo **Consolidar** que recupera espacio con clones de copia en escritura (copy-on-write) de APFS sin eliminar ninguna copia |
| **Shredder** | Borrado seguro de archivos con modos estándar, permanente y de sobrescritura segura |

### 📊 Widget de la barra de menús

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Widget de Mac Sai en la barra de menús" />
</p>

Un widget de estilo glassmorphism en la barra de menús que pone los signos vitales de tu Mac a un clic. Es un proceso independiente que se abre al iniciar sesión y se activa o desactiva desde la barra lateral de la app, así que nunca tienes que abrir la ventana principal solo para echar un vistazo.

- **Anillos de estadísticas en tiempo real**: carga de CPU, presión de memoria, uso del disco y batería en una cuadrícula de anillos de 2x2 (`host_processor_info`, `vm_statistics64`, capacidad de APFS, fuente de alimentación de IOKit), con colores que van del verde al ámbar y al rojo
- **Lectura configurable**: muestra el espacio libre en disco, el uso de GPU, el uso de memoria o la temperatura de la batería; la elección se guarda, y los sensores no disponibles muestran `--`
- **Red, tiempo de actividad y swap**: velocidad de subida/bajada en tiempo real, tiempo de actividad del sistema y uso de swap
- **Recomendaciones**: consejos útiles que puedes descartar ("Las cachés de usuario crecieron hasta 2,52 GB, ejecuta System Junk"), se actúa con un toque y, una vez descartados, se ocultan durante 30 días
- **Estado de protección**: hora del último análisis de malware y número de amenazas, con colores según su antigüedad
- **Dispositivos conectados**: volúmenes externos (con su espacio libre) y pantallas de un vistazo
- **Alertas de estado**: notificaciones opcionales y espaciadas cuando el disco se queda con muy poco espacio o la presión de memoria sigue alta

### ⌨️ Atajos de teclado

| Atajo | Acción |
|----------|--------|
| **⌘R** | Inicia un análisis en el módulo actual |
| **⌘K** | Limpia la selección actual (cuando se muestran resultados) |
| **⌘1 a ⌘9** | Salta a los nueve primeros módulos de la barra lateral |
| **⌘,** | Abre Ajustes |

---

## Cómo se compara Mac Sai

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Precio** | Gratis | $39.95/año | Gratis | Gratis | Gratis | Gratis (CLI) |
| **Código abierto** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **Telemetría** | ❌ Ninguna | ⚠️ Sí | ❌ Ninguna | ❌ Ninguna | ❌ Ninguna | ❌ Ninguna |
| **App nativa con interfaz gráfica** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (GUI de pago aparte) |
| **Smart Scan (un clic)** | ✅ | ✅ | ❌ | ➖ Parcial | ❌ | ➖ CLI interactiva |
| **System Junk (más de 16 categorías)** | ✅ | ✅ | ➖ | ✅ | ➖ Limitado | ✅ |
| **Reducción de binarios universales** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Escáner de malware** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Limpieza de privacidad del navegador** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **Desinstalador con detección de restos** | ✅ | ✅ | ✅ Especialidad | ❌ | ❌ | ✅ |
| **Buscador de duplicados (+ consolidación)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **Mapa visual del disco** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ Analizador |
| **Monitor del sistema en la barra de menús** | ✅ | ✅ Menú | ❌ | ❌ | ❌ | ❌ |
| **Scripts de mantenimiento** | ✅ | ✅ | ❌ | ❌ | ✅ Muy completo | ➖ |
| **Notarizada por Apple** | ✅ | ✅ | ✅ | ✅ | ✅ | N/D |
| **Versión de macOS** | 14+ | 13+ | 13+ | 13+ | variable | variable |

> CleanMyMac es un gran producto, y quien quiera una experiencia pulida y con soporte debería pagarlo con gusto. Mac Sai es para todos los que prefieren código fuente transparente y cero suscripciones.

---

## Idiomas de la interfaz

Elige Sistema, English, 简体中文, 繁體中文, Русский, Deutsch, Français, Español, Italiano, Português (Brasil), Türkçe, 日本語 o 한국어 en Ajustes → Idioma de la interfaz. El inglés, el chino simplificado y el ruso cubren toda la interfaz. Los demás idiomas traducen los textos estáticos de la interfaz; por ahora, los mensajes con valores interpolados mantienen el texto en inglés y sus reglas de plural (el chino tradicional recurre al simplificado). La ventana principal y el widget de la barra de menús comparten la preferencia de idioma.

## Instalación

### Homebrew (recomendado)

Mac Sai está en el cask oficial de Homebrew, así que no necesitas ningún tap:

```bash
brew install --cask mac-sai
```

Está notarizada por Apple, así que se abre desde Spotlight o Aplicaciones sin advertencias ni pasos adicionales.

<details>
<summary><strong>Otras formas de instalarla</strong> (script de una línea, DMG, compilar desde el código fuente)</summary>

<br>

**Instalador de una línea**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

Descarga el DMG más reciente e instala la app en `/Applications`.

**Descarga del DMG**

Descarga el DMG más reciente desde [Releases](https://github.com/iliyami/MacSai/releases/latest) y arrastra Mac Sai a tu carpeta Aplicaciones.

**Compilar desde el código fuente**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # run the full 1,048-test suite
bash scripts/build-dmg.sh      # build a local DMG (unsigned)
```

Requiere la cadena de herramientas de Swift 6 (Xcode 16+).

**¿La instalaste con el tap antiguo?**

Mac Sai ya está en el cask oficial, así que puedes quitar el tap: `brew untap iliyami/macsai` (no afecta a la app instalada ni a los futuros `brew upgrade`).

</details>

### Conceder acceso total al disco

Algunos módulos (Mail Attachments, Privacy, Malware) necesitan acceso total al disco para analizar las áreas protegidas:

1. Abre **Ajustes del Sistema, Privacidad y seguridad, Acceso total al disco**
2. Haz clic en **+** y añade **Mac Sai.app**
3. Reinicia Mac Sai

### Desinstalar

Instalación con Homebrew:

```bash
brew uninstall --zap --cask mac-sai
```

Instalación con DMG o manual (también sirve para una instalación con Homebrew):

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

Ambos métodos eliminan Mac Sai junto con sus preferencias, cachés, registros y base de datos dentro de `~/Library`.

---

## Firmada, notarizada y digna de tu confianza

Mac Sai está firmada con un **Developer ID** de Apple y **notarizada por Apple**. Esto importa más en una app de limpieza que en casi cualquier otra cosa que instales, porque vas a darle acceso profundo a tus archivos, y mereces saber que lo que se ejecuta en tu Mac es realmente nuestro y no ha sido manipulado. Todo esto lo comprueba tu propio Mac, no es solo una promesa nuestra:

- **Apple la ha analizado.** Cada versión se envía a Apple y se revisa en busca de malware antes de publicarse.
- **No se puede manipular.** La firma es un sello criptográfico sobre cada archivo; si cambia un solo byte, macOS se niega a abrirla.
- **Se puede demostrar que es nuestra.** La firma está vinculada a nuestra identidad de Apple Developer, así que nadie más puede distribuir algo que tu Mac acepte como Mac Sai.
- **Simplemente funciona.** Sin advertencias de Gatekeeper, sin clic derecho para abrir y sin Terminal.

Junto con un código totalmente abierto, esto forma una cadena de confianza que no depende de la fe: el código es público, firmamos cada versión, Apple la verifica y tu Mac vuelve a comprobar el sello cada vez que abres la app.

### Verifica tú mismo que no hay telemetría

No te fíes solo de nuestra palabra. Puedes comprobar tanto el código fuente como el proceso en ejecución.

**1. Busca APIs de red en el código fuente**

```bash
rg -n 'URLSession|NSURLConnection|Sparkle|SecTrustEvaluate' Sources --glob '*.swift'
```

Las rutas de red opcionales se detallan a continuación. La limpieza local no sube resultados de análisis ni listas de archivos:

- `Sources/MacClean/Services/SelfUpdateController.swift`: Sparkle consulta el feed HTTPS sellado dentro de la app firmada y descarga notas de la versión y archivos de actualización firmados. Las comprobaciones automáticas y la descarga/instalación automática son ajustes independientes; el perfilado del sistema y el JavaScript en las notas de la versión están desactivados. Consulta la [configuración de actualizaciones](docs/IN_APP_UPDATES.md). En las instalaciones directas configuradas, las comprobaciones automáticas de actualizaciones están activadas de forma predeterminada y se ejecutan una vez al día; cada solicitud incluye las versiones de la app y de Sparkle en el User-Agent, y las comprobaciones se pueden desactivar en Ajustes.
- `Sources/MacCleanKit/UpdateChecker.swift`: comprobaciones de actualizaciones de Homebrew y la alternativa de la página de versiones para compilaciones sin un feed firmado configurado
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: la comprobación, iniciada por ti, de los feeds de Sparkle *de otras apps* cuando abres el Updater
- `Sources/MacCleanKit/MalwareBazaarFeed.swift`: la descarga opcional de hashes de MalwareBazaar. Solo se ejecuta cuando añades tu propia Auth-Key de abuse.ch y pulsas Actualizar ahora en Ajustes > Base de datos de malware. Cada solicitud envía solo tu Auth-Key y la consulta, nunca hashes ni rutas de archivos. Cuando un hash descargado coincide con un archivo firmado, macOS le pregunta a Apple si su certificado de firma fue revocado, la misma comprobación que hace Gatekeeper; esa solicitud trata sobre el certificado, no sobre tus archivos

No hay ningún SDK de analíticas, informes de fallos ni rastreo en todo el código.

**2. Observa el proceso en ejecución**

```bash
(
MACSAI_APP=$(cd "/Applications/Mac Sai.app" && pwd -P) || exit 1
MACSAI_PIDS=$(ps -ww -axo pid=,comm= | awk -v bundle="$MACSAI_APP/" '
  { pid=$1; sub(/^[[:space:]]*[0-9]+[[:space:]]+/, "")
    if (index($0, bundle) == 1) print pid }' | paste -sd, -)
if [ -n "$MACSAI_PIDS" ]; then
  ps -p "$MACSAI_PIDS" -o pid=,comm=
  lsof -nP -a -p "$MACSAI_PIDS" -i
else
  echo "No running executables from this Mac Sai bundle"
fi
)
```

Esta captura selecciona los PID según las rutas de los ejecutables dentro del paquete de la app elegido, así que se excluyen los procesos Installer/Updater que no tienen relación. Los helpers de Sparkle copiados en otras ubicaciones y los servicios de confianza de macOS quedan fuera de esta captura; usa un firewall que identifique procesos para observarlos. Ejecútalo mientras compruebas o descargas una actualización para detectar conexiones de corta duración.

Con las comprobaciones/descargas de actualizaciones y la verificación opcional de malware inactivas, la limpieza local no abre ninguna conexión de red. Incluye los procesos hijos de Sparkle cuando observes una actualización; las comprobaciones de certificados de Apple se hacen a través de los servicios de confianza de macOS. Little Snitch o LuLu también pueden mostrar estas conexiones.

**3. Inspecciona el binario que realmente instalaste**

En una instalación con DMG o Homebrew, este bucle solo necesita las herramientas de línea de comandos de macOS, sin copia del código fuente ni Python. Lee los siete binarios incluidos y muestra las importaciones de red habituales, las URL estáticas y las cadenas de rastreadores para que las inspecciones manualmente:

```bash
(
MACSAI_APP="/Applications/Mac Sai.app"
MACSAI_SPARKLE="$MACSAI_APP/Contents/Frameworks/Sparkle.framework/Versions/B"
for MACSAI_BINARY in \
  "$MACSAI_APP/Contents/MacOS/MacClean" \
  "$MACSAI_APP/Contents/Library/LoginItems/MacCleanMenu.app/Contents/MacOS/MacCleanMenu" \
  "$MACSAI_SPARKLE/Sparkle" "$MACSAI_SPARKLE/Autoupdate" \
  "$MACSAI_SPARKLE/Updater.app/Contents/MacOS/Updater" \
  "$MACSAI_SPARKLE/XPCServices/Downloader.xpc/Contents/MacOS/Downloader" \
  "$MACSAI_SPARKLE/XPCServices/Installer.xpc/Contents/MacOS/Installer"
do
  printf '\n%s\n' "$MACSAI_BINARY"
  MACSAI_IMPORTS=$(nm -uj "$MACSAI_BINARY") || exit 1
  printf '%s\n' "$MACSAI_IMPORTS" | grep -Ei \
    'URLSession|URLConnection|CFNetwork|Network|nw_|DNSService|NetService|curl_|^_(socket|connect|connectx|send|recv)([$]|$)' || true
  MACSAI_STRINGS=$(strings -a "$MACSAI_BINARY") || exit 1
  printf '%s\n' "$MACSAI_STRINGS" | grep -Ei \
    '://|sentry|firebase|mixpanel|amplitude|bugsnag|crashlytics|posthog|appsflyer' || true
done
)
```

Estos listados no son una auditoría de aprobado/suspenso ni prueban que todos los destinos en tiempo de ejecución sean visibles. Para el inventario completo de componentes, las listas de permitidos explícitas y los ajustes de privacidad incluidos, usa la comprobación automática que aparece a continuación.

Ejecuta la comprobación desde una copia del código fuente que coincida con la versión instalada. Inspecciona el paquete real de la app, incluidos el ejecutable principal, el helper del menú, `Sparkle.framework`, `Autoupdate`, `Updater.app`, `Downloader.xpc` y `Installer.xpc`:

```bash
bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"
```

Resultado esperado: los siete archivos Mach-O pasan la comprobación. Los binarios ausentes o inesperados, las importaciones de red o URL estáticas no incluidas en la lista y los indicadores de rastreadores hacen que falle. Las importaciones de URLSession están permitidas en Mac Sai, su helper del menú, Sparkle y Downloader; los demás helpers de Sparkle no tienen importaciones de red permitidas. Los enlaces a la documentación de Sparkle y su espacio de nombres XML se identifican explícitamente y no se tratan como destinos de descarga.

El script también muestra el `SUFeedURL` incluido y verifica los ajustes del feed firmado, de la verificación previa a la extracción y de privacidad. Contrasta los destinos de archivos y notas de la versión de ese feed, y los feeds de otras apps que consultes, con las conexiones en tiempo real de arriba. Los endpoints alternativos son `api.github.com/repos/iliyami/MacSai/releases/latest` y `formulae.brew.sh/api/cask/mac-sai.json`; el endpoint opcional de malware es `mb-api.abuse.ch/api/v1/`. Los enlaces del proyecto y de soporte, y los enlaces a los ajustes del navegador, solo se abren cuando lo pides. La misma comprobación del paquete completo se ejecuta durante el empaquetado; la CI comprueba los dos ejecutables compilados y los cinco binarios de Sparkle con versión fijada. [Implementación de la comprobación y listas de permitidos explícitas](scripts/check-network-surface.py).

---

## Arquitectura

```
Mac Sai
├── MacClean          Main SwiftUI app (22 modules)
├── MacCleanKit       Shared framework (models, constants, protocols)
├── MacCleanHelper    XPC privileged helper (LaunchDaemon for root ops)
└── MacCleanMenu      Menu-bar monitor (independent process)
```

### Tecnologías

| Capa | Tecnología |
|-------|-----------|
| Lenguaje | Swift 6 con concurrencia estricta |
| Interfaz | Híbrido de SwiftUI + AppKit |
| Concurrencia | Actors, TaskGroup, async/await, `@Sendable` |
| Base de datos | GRDB.swift (SQLite) en modo WAL |
| Análisis de archivos | Precarga de `URLResourceKey` en APFS |
| Actualizaciones incrementales | FSEvents con reproducción del historial |
| Operaciones con privilegios | SMAppService + NSXPCConnection |
| Estadísticas del sistema | APIs de Mach (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### Modelo de seguridad

Mac Sai está diseñada para **no causar nunca pérdida de datos**:

- **Lista de rutas protegidas**: `/System`, `/usr`, `/bin`, `/sbin` y las apps del sistema de Apple son intocables, y los firmlinks de macOS se canonicalizan para que la detección de redirecciones mediante enlaces simbólicos no dé falsos positivos en rutas legítimas del sistema
- **Filtro previo de elementos limpiables**: los elementos que el proceso actual no podría enviar a la Papelera (hijos propiedad de root dentro de cachés del sistema, directorios `~/Library/Caches/com.apple.*` protegidos por data vault) se descartan durante el análisis, así que nunca aparecen como limpiables
- **Primero a la Papelera**: de forma predeterminada, todo lo que se elimina va a la Papelera, y un modo de simulación (dry-run) muestra una vista previa sin tocar nada
- **Prevención de TOCTOU**: los enlaces simbólicos se vuelven a resolver justo antes de eliminar
- **Carpetas excluidas**: elige en Ajustes carpetas que los análisis omiten por completo, y además `SafetyGuard` se niega a eliminar cualquier cosa dentro de ellas
- **Limpieza por bloques y cancelable**: las selecciones grandes se dividen en bloques de 5.000 elementos, se respeta la cancelación entre bloques y los análisis vuelven a reposo en aproximadamente un segundo cuando pulsas Cancelar
- **Registro de actividad en la app**: cada error durante una limpieza se registra con su ruta completa, se puede ver y copiar desde la pantalla posterior a la limpieza y se elimina automáticamente a los 30 días
- **Control de XPC aplicado por el kernel**: el helper con privilegios usa `NSXPCListener.setCodeSigningRequirement`, de modo que el propio kernel rechaza cualquier conexión cuya firma de código no coincida con el identificador y el equipo de la app

---

## Pruebas

```bash
swift test
```

La suite de XCTest tiene **1.048 pruebas** y trata `SafetyGuard` y `CleaningEngine` (los archivos de vida o muerte) como piezas que deben ser perfectas: cobertura adversarial de enlaces simbólicos, path traversal, bytes NULL, SIP, apps protegidas, límites de número de archivos, TOCTOU e idempotencia, además de cobertura de integración de la limpieza en simulación / a la Papelera / permanente, la máquina de estados del análisis, cada categoría de System Junk, las matemáticas del mapa de árbol, el motor de coincidencias del desinstalador, la detección de duplicados, el análisis de appcasts y ciclos completos de extremo a extremo, desde los datos de prueba hasta la limpieza. Los fixtures (`withTempHome`, `withFakeApp`, `withFakePlist`) mantienen todas las pruebas lejos de tu carpeta de inicio real.

---

## Contribuir

Las contribuciones son muy bienvenidas. Lee las [Pautas de contribución](CONTRIBUTING.md) y luego:

1. Haz un fork del repositorio y crea una rama para tu cambio
2. Haz tu cambio (un cambio concreto por PR facilita la revisión)
3. Ejecuta `swift test`
4. Abre un Pull Request

También hay una [votación de funciones](https://github.com/iliyami/MacSai/issues/55) abierta: 👍 a las herramientas que quieres que se creen a continuación.

## Licencia

BSD 3-Clause. Consulta [LICENSE](LICENSE). Puedes usar, modificar y redistribuir el código, siempre que conserves el aviso de copyright y el texto de la licencia, y no uses el nombre "Mac Sai" ni los nombres de los colaboradores para promocionar productos derivados sin permiso.

## Agradecimientos

Inspirada por la comunidad de utilidades de código abierto para Mac:

- [Pearcleaner](https://github.com/alienator88/Pearcleaner): patrones de desinstalación de apps
- [Mole](https://github.com/tw93/Mole): categorías de limpieza
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner): arquitectura modular
- Algoritmo Squarified Treemap de Bruls, Huizing y van Wijk (2000)

## Apoyo y patrocinadores

Mac Sai es gratuita y lo seguirá siendo: sin plan de pago, sin anuncios y sin rastreo. Si te ahorró la suscripción a un limpiador, puedes [invitarme a un café ☕](https://buymeacoffee.com/iliyami) o [hacerte miembro](https://buymeacoffee.com/iliyami/membership). Así las versiones siguen llegando, firmadas y notarizadas.

### Colaboradores

Los miembros reciben publicaciones sobre el desarrollo, un adelanto de cada versión, versiones beta opcionales y su nombre en la app. Nada de la app se bloquea nunca tras una membresía.

<p align="center">
  <em>Todavía no hay miembros.</em> <a href="https://buymeacoffee.com/iliyami/membership">Sé el primero →</a><br>
  <sub>Aquí agradecemos a los miembros Power User y Team. Todos aparecen en <a href="SUPPORTERS.md">SUPPORTERS.md</a>.</sub>
</p>

### Espacio de patrocinio

Mac Sai tiene **un único** espacio de patrocinio, que se muestra aquí y al principio de esta página, en todos los idiomas de este README.

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><h3>125.000+</h3><sub>descargas</sub></td>
    <td align="center" width="25%"><h3>2.000+</h3><sub>estrellas en GitHub</sub></td>
    <td align="center" width="25%"><h3>23.000</h3><sub>visitas a la página al mes</sub></td>
    <td align="center" width="25%"><h3>12</h3><sub>idiomas del README</sub></td>
  </tr>
</table>
</div>

La mayoría de los visitantes son desarrolladores y usuarios avanzados de Mac, que llegan sobre todo desde la búsqueda de Google y, después, desde YouTube, GitHub y Reddit.

- **Un solo patrocinador a la vez**, para que tu nombre no se pierda en un muro de logotipos.
- **Verificado.** Herramientas para desarrolladores, productos de privacidad y seguridad, y apps para Mac que respetan a sus usuarios. Nada de limpiadores ni "optimizadores", nada de criptomonedas, nada de VPN con enlaces de afiliado, nada que rastree a las personas.
- **Nunca dentro de la app.** Mac Sai no tiene anuncios ni telemetría, y ningún patrocinador cambia eso.

<p align="center">
  <strong>Este espacio está disponible.</strong> <a href="mailto:macsai.team@gmail.com?subject=Mac%20Sai%20sponsor">Conviértete en el patrocinador →</a><br>
  <sub>Detalles de la audiencia y cómo solicitarlo: <a href="SPONSORS.md">SPONSORS.md</a></sub>
</p>

## Historial de estrellas

<p align="center">
  <a href="https://www.star-history.com/?repos=iliyami%2FMacSai&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&theme=dark&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <img alt="Gráfico del historial de estrellas" src="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
    </picture>
  </a>
</p>

<p align="center">
  <strong>Mac Sai es software libre creado por la comunidad, para la comunidad.</strong><br>
  Si te ahorró una suscripción, una ⭐ ayuda a que otros la encuentren, y un <a href="https://buymeacoffee.com/iliyami">café ☕</a> la mantiene en marcha.
</p>
