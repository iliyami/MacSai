<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Ícone do Mac Sai" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>O limpador, otimizador e scanner de malware de código aberto para Mac.</strong><br>
  Uma alternativa gratuita ao CleanMyMac, notarizada pela Apple e criada com Swift 6 e SwiftUI.<br>
  <sub>Mais de 125.000 downloads. Gratuito para sempre, com zero telemetria.</sub>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <a href="README.de.md">Deutsch</a> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a> | <a href="README.es.md">Español</a> | <a href="README.it.md">Italiano</a> | <strong>Português (Brasil)</strong> | <a href="README.ja.md">日本語</a> | <a href="README.ko.md">한국어</a> | <a href="README.tr.md">Türkçe</a> | <a href="README.fa.md">فارسی</a>
</p>

<p align="center">
  <a href="https://iliyami.github.io/MacSai/pt-br/"><img src="https://img.shields.io/badge/website-iliyami.github.io%2FMacSai-7c5cff?style=flat-square" alt="Website" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/downloads/iliyami/MacSai/total?style=flat-square&label=downloads&color=2ea44f" alt="Total de downloads" /></a>
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="Estrelas no GitHub" /></a>
  <a href="https://formulae.brew.sh/cask/mac-sai"><img src="https://img.shields.io/homebrew/cask/installs/dm/mac-sai?style=flat-square&label=homebrew&color=orange" alt="Instalações via Homebrew" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="Versão mais recente" /></a>
  <a href="https://github.com/iliyami/MacSai/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/iliyami/MacSai?style=flat-square&label=commits" alt="Atividade de commits" /></a>
  <br>
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="Notarizado" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="Sem telemetria" />
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6-orange?style=flat-square" alt="Swift 6" />
  <a href="https://github.com/iliyami/MacSai/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/iliyami/MacSai/ci.yml?branch=main&style=flat-square&label=tests" alt="Testes" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="Licença" /></a>
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Captura de tela do Mac Sai" />
</p>

<p align="center">
  <strong>Instale com um único comando:</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  Ou baixe o <a href="https://github.com/iliyami/MacSai/releases/latest">DMG mais recente</a>. Ele é notarizado pela Apple, então simplesmente abre: sem clique com o botão direito, sem avisos, sem Terminal.
</p>

<p align="center">
  <sub>Nunca haverá anúncios no app. Esta página tem <a href="SPONSORS.md">um único espaço de patrocínio selecionado</a>, e ele está disponível.</sub>
</p>

---

## Por que o Mac Sai?

Um limpador de Mac completo não deveria custar uma assinatura anual nem pedir que você confie em uma caixa-preta com acesso profundo aos seus arquivos. O Mac Sai oferece o kit de ferramentas completo, de forma aberta.

- **Gratuito, para sempre.** Sem assinatura, sem compras dentro do app, sem "upgrade para Pro", sem telas insistentes. Licença BSD-3.
- **Zero telemetria.** Sem análises, sem relatório de falhas, sem rastreadores, sem servidor para onde enviar dados. E você não precisa acreditar só na nossa palavra: [verifique você mesmo](#verifique-você-mesmo-a-ausência-de-telemetria) com dois comandos.
- **Todas as principais ferramentas do CleanMyMac, em um só app.** 22 módulos de limpeza, proteção, desempenho, aplicativos e análise de disco, além de um widget na barra de menus.
- **Seguro por design.** Exclusão que passa primeiro pelo Lixo, uma lista de bloqueio de caminhos protegidos, proteções contra symlinks e TOCTOU, e um `SafetyGuard` que valida cada caminho. Ele foi feito para nunca perder seus dados.
- **Notarizado pela Apple e totalmente de código aberto.** O seu Mac verifica a assinatura a cada abertura, e cada linha do código está aqui para você ler.

---

## Recursos em resumo

<table>
<tr>
<td width="33%" valign="top">

### 🧹 Limpeza
- **Smart Scan** (um clique)
- **System Junk** (16+ categorias)
- **Mail Attachments**
- **Trash Bins**
- **Project Junk** (pastas de build)
- **Disk Hogs** (Docker, simuladores)
- **Clean History** (Restaurar com um clique)

</td>
<td width="33%" valign="top">

### 🛡️ Proteção
- **Malware Removal**
- **Privacy** (navegadores)
- **Browser Extensions**
- **Saved Wi-Fi**
- **Permissions Overview**

</td>
<td width="33%" valign="top">

### ⚡ Desempenho
- **Optimization** (itens de início de sessão)
- **Maintenance** (tarefas do sistema)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 Aplicativos
- **Uninstaller** (+ Redefinir para os padrões)
- **Unused Apps**
- **Extensions** (painéis, plug-ins)
- **Updater**

</td>
<td width="33%" valign="top">

### 🗂️ Arquivos
- **Space Lens** (treemap do disco)
- **Large & Old Files**
- **Duplicates** (+ Consolidar)
- **Shredder**

</td>
<td width="33%" valign="top">

### 📊 Barra de menus
- CPU / memória / disco / bateria em tempo real
- Rede, tempo de atividade, swap
- Recomendações práticas

</td>
</tr>
</table>

---

## Recursos em detalhes

### 🧹 Limpeza
| Módulo | O que faz |
|--------|------------|
| **Smart Scan** | Um clique executa juntos os módulos de limpeza, proteção e desempenho, com progresso em tempo real, e depois mostra exatamente quanto foi liberado em cada módulo |
| **System Junk** | 16+ categorias de verificação: caches do usuário e do sistema, logs, arquivos de idioma, preferências corrompidas, itens de início de sessão quebrados, versões de documentos, backups do iOS, lixo do Xcode, caches de gerenciadores de pacotes / IDEs / ferramentas de IA, restos de usuários excluídos e **redução de Universal Binary** (encontra binários Mach-O "fat" que trazem arm64 e x86_64 juntos e os reescreve para a arquitetura nativa do seu Mac via `lipo`, respeitando o Cancelar) |
| **Mail Attachments** | Encontra anexos em cache do Apple Mail, Outlook e Spark |
| **Trash Bins** | Esvazia o Lixo em todos os locais, incluindo unidades externas |
| **Project Junk** | Encontra pastas de build regeneráveis nos seus projetos: `node_modules`, `.next`, `dist`, `target` do Rust e do Maven, `build` do Gradle, virtualenvs do Python e `Pods` do CocoaPods. Uma pasta só conta quando os arquivos ao lado dela confirmam o tipo de projeto, e `dist` e `Pods` só contam quando o seu `.gitignore` os menciona. Tudo vai para o Lixo |
| **Disk Hogs** | Mostra quanto espaço o Docker e os simuladores do Xcode ocupam. Remove contêineres parados, imagens órfãs e cache de build órfão (cada um com uma confirmação) e exclui simuladores indisponíveis e runtimes de simulador antigos. Volumes do Docker e o runtime mais recente de cada plataforma nunca são tocados |
| **Clean History** | Lista suas limpezas recentes (dos últimos 30 dias, até 20) e restaura uma limpeza inteira a partir do Lixo com um clique. O histórico fica no seu Mac, em `~/Library/Logs/MacClean/clean-history.json`, legível apenas pela sua conta de usuário, e nunca é enviado a lugar nenhum |

### 🛡️ Proteção
| Módulo | O que faz |
|--------|------------|
| **Malware Removal** | Verificação baseada em assinaturas em 3 níveis (Rápido / Equilibrado / Profundo): agentes e daemons de inicialização, pacotes de apps, extensões de navegador e padrões conhecidos de adware/malware. Correspondência exata de hash com as assinaturas do XProtect da Apple que já estão no seu Mac, offline, além de um feed opcional de hashes do MalwareBazaar (abuse.ch). Extensões do Safari que estão na lista de bloqueio da Apple e correspondências do MalwareBazaar são listadas para revisão, nunca pré-selecionadas (não é um antivírus, e o app deixa isso claro) |
| **Privacy** | Limpa histórico, cookies e cache do Safari, Chrome e Firefox, com filtros de período. Os **favoritos do Safari nunca são tocados** |
| **Browser Extensions** | Lista as extensões instaladas no Safari, Chrome, Brave, Edge, Arc e Firefox. As extensões do Chromium e do Firefox que você mesmo instalou podem ir para o Lixo enquanto o navegador estiver fechado; as instaladas por política ou pelo próprio navegador são exibidas, mas ficam intactas. As extensões do Safari levam aos ajustes do Safari |
| **Saved Wi-Fi** | Lista suas redes sem fio preferidas e esquece as que você escolher |
| **Permissions Overview** | Uma visão somente leitura, organizada por app, das permissões de privacidade (TCC) que cada app tem, o ângulo que os Ajustes do Sistema não oferecem. Cada ação abre diretamente o painel certo dos Ajustes do Sistema, que controlam as opções |

### ⚡ Desempenho
| Módulo | O que faz |
|--------|------------|
| **Optimization** | Gerencie itens de início de sessão e agentes de inicialização, ativando ou desativando cada item |
| **Maintenance** | Tarefas do sistema: liberar RAM, executar scripts de manutenção, verificar o disco de inicialização, reconstruir o Launch Services, reindexar o Spotlight, limpar o cache de DNS, reduzir snapshots do Time Machine. As tarefas são marcadas por gravidade, "Executar tarefas seguras" roda em sequência, e a senha de administrador é pedida **uma única vez** |

### 📦 Aplicativos
| Módulo | O que faz |
|--------|------------|
| **Uninstaller** | Um mecanismo de correspondência de padrões que encontra todos os arquivos associados em 17+ subdiretórios da Library (incluindo apps aninhados em subpastas de fornecedores). Remoção completa, **Redefinir para os padrões** (apaga os caches e as preferências de um app, mantendo o app instalado) e detecção de apps sem uso |
| **Unused Apps** | Encontra apps que você não abre há 3, 6 ou 12 meses, usando a data de último uso do Spotlight, ordenados por tamanho. Apps em execução nunca são listados, e quando o Spotlight não tem dados de uso, o app avisa em vez de adivinhar. Um clique envia o app para o Uninstaller |
| **Extensions** | Revise painéis de preferências de terceiros, plug-ins da Internet e extensões do Safari. Painéis e plug-ins instalados pelo usuário podem ir para o Lixo |
| **Updater** | Verifica se há atualizações para os apps instalados pelos próprios feeds appcast do Sparkle (lê apenas informações de versão e não envia nada sobre você) |

### 🗂️ Arquivos
| Módulo | O que faz |
|--------|------------|
| **Space Lens** | Visualização do uso do disco em treemap squarified, com navegação por níveis |
| **Large & Old Files** | Encontra arquivos com mais de 50 MB, ordenados por tamanho e data do último acesso |
| **Duplicates** | Detecção progressiva (agrupamento por tamanho, SHA-256 parcial, hash completo, verificação de inode), além de um modo **Consolidar** que recupera espaço com clones copy-on-write do APFS sem excluir nenhuma cópia |
| **Shredder** | Apagamento seguro de arquivos com os modos padrão, permanente e sobrescrita segura |

### 📊 Widget da barra de menus

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Widget da barra de menus do Mac Sai" />
</p>

Um widget de barra de menus em estilo glassmorphism que deixa os sinais vitais do seu Mac a um clique de distância. Ele é um processo independente que abre no início de sessão e é ativado pela barra lateral do app, então você nunca precisa abrir a janela principal só para dar uma olhada.

- **Anéis de estatísticas em tempo real**: carga da CPU, pressão de memória, uso do disco e bateria em uma grade de anéis 2x2 (`host_processor_info`, `vm_statistics64`, capacidade do APFS, fonte de energia do IOKit), com cores que vão do verde ao âmbar e ao vermelho
- **Leitura configurável**: mostre o espaço livre em disco, o uso da GPU, o uso de memória ou a temperatura da bateria; a escolha é mantida, e sensores indisponíveis mostram `--`
- **Rede, tempo de atividade e swap**: taxa de upload/download em tempo real, tempo de atividade do sistema, uso de swap
- **Recomendações**: dicas práticas e dispensáveis ("Os caches do usuário cresceram para 2,52 GB, execute o System Junk"), um toque para agir, ocultadas por 30 dias depois de dispensadas
- **Status de proteção**: horário da última verificação de malware e número de ameaças, com cores conforme a verificação é recente ou não
- **Dispositivos conectados**: volumes externos (com espaço livre) e monitores em um relance
- **Alertas de saúde**: notificações opcionais e espaçadas quando o espaço em disco fica criticamente baixo ou a pressão de memória continua alta

### ⌨️ Atalhos de teclado

| Atalho | Ação |
|----------|--------|
| **⌘R** | Iniciar uma verificação no módulo atual |
| **⌘K** | Limpar a seleção atual (quando há resultados na tela) |
| **⌘1 a ⌘9** | Ir para os nove primeiros módulos da barra lateral |
| **⌘,** | Abrir Ajustes |

---

## Como o Mac Sai se compara

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Preço** | Gratuito | US$ 39,95/ano | Gratuito | Gratuito | Gratuito | Gratuito (CLI) |
| **Código aberto** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **Telemetria** | ❌ Nenhuma | ⚠️ Sim | ❌ Nenhuma | ❌ Nenhuma | ❌ Nenhuma | ❌ Nenhuma |
| **App nativo com interface gráfica** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (GUI paga à parte) |
| **Smart Scan (um clique)** | ✅ | ✅ | ❌ | ➖ Parcial | ❌ | ➖ CLI interativa |
| **System Junk (16+ categorias)** | ✅ | ✅ | ➖ | ✅ | ➖ Limitado | ✅ |
| **Redução de Universal Binary** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Scanner de malware** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Limpeza de privacidade do navegador** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **Desinstalador com detecção de restos** | ✅ | ✅ | ✅ Foco | ❌ | ❌ | ✅ |
| **Localizador de duplicatas (+ consolidação)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **Visualizador de disco em treemap** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ Analisador |
| **Monitor do sistema na barra de menus** | ✅ | ✅ Menu | ❌ | ❌ | ❌ | ❌ |
| **Scripts de manutenção** | ✅ | ✅ | ❌ | ❌ | ✅ Forte | ➖ |
| **Notarizado pela Apple** | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| **Versão do macOS** | 14+ | 13+ | 13+ | 13+ | varia | varia |

> O CleanMyMac é um ótimo produto, e quem quer uma experiência refinada e com suporte deve pagar por ele com prazer. O Mac Sai é para quem prefere código-fonte transparente e nenhuma assinatura.

---

## Idiomas da interface

Escolha Sistema, English, 简体中文, 繁體中文, Русский, Deutsch, Français, Español, Italiano, Português (Brasil), Türkçe, 日本語, 한국어 ou فارسی em Ajustes → Idioma da interface. Inglês, chinês simplificado e russo cobrem a interface inteira. Os demais idiomas traduzem os textos estáticos da interface; por enquanto, as mensagens interpoladas mantêm o texto e as regras de plural do inglês (o chinês tradicional recorre ao simplificado). A janela principal e o widget da barra de menus compartilham a preferência de idioma. Em persa, a interface é exibida da direita para a esquerda.

## Instalação

### Homebrew (recomendado)

O Mac Sai está no cask oficial do Homebrew, então nenhum tap é necessário:

```bash
brew install --cask mac-sai
```

Ele é notarizado pela Apple, então abre pelo Spotlight ou pela pasta Aplicativos sem avisos e sem etapas extras.

<details>
<summary><strong>Outras formas de instalar</strong> (script de uma linha, DMG, compilar a partir do código-fonte)</summary>

<br>

**Instalador de uma linha**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

Baixa o DMG mais recente e instala o app em `/Applications`.

**Download do DMG**

Baixe o DMG mais recente em [Releases](https://github.com/iliyami/MacSai/releases/latest) e arraste o Mac Sai para a pasta Aplicativos.

**Compilar a partir do código-fonte**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # run the full 1,048-test suite
bash scripts/build-dmg.sh      # build a local DMG (unsigned)
```

Requer a toolchain do Swift 6 (Xcode 16+).

**Instalou pelo tap antigo?**

O Mac Sai agora está no cask oficial, então você pode remover o tap: `brew untap iliyami/macsai` (o app instalado e os próximos `brew upgrade` não são afetados).

</details>

### Concedendo Acesso Total ao Disco

Alguns módulos (Mail Attachments, Privacy, Malware) precisam de Acesso Total ao Disco para verificar áreas protegidas:

1. Abra **Ajustes do Sistema, Privacidade e Segurança, Acesso Total ao Disco**
2. Clique em **+** e adicione o **Mac Sai.app**
3. Reinicie o Mac Sai

### Desinstalação

Instalação via Homebrew:

```bash
brew uninstall --zap --cask mac-sai
```

Instalação por DMG ou manual (também funciona para uma instalação via Homebrew):

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

Os dois métodos removem o Mac Sai e também as preferências, caches, logs e o banco de dados dele em `~/Library`.

---

## Assinado, notarizado e digno da sua confiança

O Mac Sai é assinado com um **Developer ID** da Apple e **notarizado pela Apple**. Isso importa mais para um app de limpeza do que para quase qualquer outra coisa que você instala, porque você está prestes a dar a ele acesso profundo aos seus arquivos e merece saber que o que roda no seu Mac é realmente nosso e não foi adulterado. Tudo isso é garantido pelo seu próprio Mac, e não apenas prometido por nós:

- **A Apple já o analisou.** Cada versão é enviada à Apple e verificada contra malware antes de ser lançada.
- **Ele não pode ser adulterado.** A assinatura é um selo criptográfico sobre cada arquivo; altere um único byte e o macOS se recusa a abri-lo.
- **Ele comprovadamente vem de nós.** A assinatura está vinculada à nossa identidade de desenvolvedor Apple, então ninguém mais consegue distribuir algo que o seu Mac aceite como Mac Sai.
- **Simplesmente funciona.** Sem avisos do Gatekeeper, sem clique com o botão direito para abrir, sem Terminal.

Somado ao código totalmente aberto, isso forma uma cadeia de confiança que você não precisa aceitar por fé: o código é público, nós assinamos cada versão, a Apple a verifica, e o seu Mac confere o selo de novo toda vez que você abre o app.

### Verifique você mesmo a ausência de telemetria

Não acredite apenas na nossa palavra. Tanto o código-fonte quanto o processo em execução podem ser verificados.

**1. Procure APIs de rede no código-fonte**

```bash
rg -n 'URLSession|NSURLConnection|Sparkle|SecTrustEvaluate' Sources --glob '*.swift'
```

Os caminhos de rede opcionais estão descritos abaixo. A limpeza local não envia resultados de verificação nem listas de arquivos:

- `Sources/MacClean/Services/SelfUpdateController.swift`: o Sparkle verifica o feed HTTPS selado dentro do app assinado e baixa notas de versão e arquivos de atualização assinados. As verificações automáticas e o download/instalação automáticos são ajustes separados; a coleta de perfil do sistema e o JavaScript nas notas de versão ficam desativados. Veja a [configuração de atualizações](docs/IN_APP_UPDATES.md). Em instalações diretas configuradas, as verificações automáticas de atualização vêm ativadas por padrão e rodam uma vez por dia; cada solicitação inclui as versões do app e do Sparkle no User-Agent, e as verificações podem ser desativadas em Ajustes.
- `Sources/MacCleanKit/UpdateChecker.swift`: verificações de atualização do Homebrew e a alternativa via página de versões para builds sem um feed assinado configurado
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: a verificação, iniciada por você, dos feeds Sparkle *de outros apps* quando você abre o Updater
- `Sources/MacCleanKit/MalwareBazaarFeed.swift`: o download opcional de hashes do MalwareBazaar. Ele só roda quando você adiciona sua própria Auth-Key do abuse.ch e clica em Atualizar agora em Ajustes > Bancos de dados de malware. Cada solicitação envia apenas a sua Auth-Key e a consulta, nunca hashes nem caminhos de arquivos. Quando um hash baixado corresponde a um arquivo assinado, o macOS pergunta à Apple se o certificado de assinatura foi revogado, a mesma verificação que o Gatekeeper faz; essa solicitação é sobre o certificado, e não sobre os seus arquivos

Não existe nenhum SDK de análise, relatório de falhas ou rastreamento em parte alguma do código.

**2. Observe o processo em execução**

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

Este instantâneo seleciona os PIDs pelos caminhos dos executáveis dentro do pacote do app escolhido, então processos Installer/Updater não relacionados ficam de fora. Auxiliares do Sparkle copiados para outros locais e os serviços de confiança do macOS ficam fora deste instantâneo; use um firewall que identifique processos para observá-los. Execute o comando enquanto verifica ou baixa uma atualização para capturar conexões de curta duração.

Com as verificações/downloads de atualização e a verificação opcional de malware inativos, a limpeza local não abre nenhuma conexão de rede. Inclua os processos filhos do Sparkle ao observar uma atualização; as verificações de certificado da Apple passam pelos serviços de confiança do macOS. O Little Snitch ou o LuLu também podem mostrar essas conexões.

**3. Inspecione o binário que você realmente instalou**

Em uma instalação por DMG ou Homebrew, este loop precisa apenas das ferramentas de linha de comando do macOS, sem checkout do código-fonte e sem Python. Ele lê os sete binários incluídos e lista importações de rede comuns, URLs estáticas e strings de rastreadores para inspeção manual:

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

Essas listagens não são uma auditoria de aprovação/reprovação nem uma prova de que todos os destinos em tempo de execução estão visíveis. Para o inventário completo de componentes, as listas de permissões explícitas e os ajustes de privacidade incluídos, use a verificação automatizada abaixo.

Execute a verificação a partir de um checkout do código-fonte que corresponda à versão instalada. Ela inspeciona o pacote real do app, incluindo o executável principal, o auxiliar de menu, `Sparkle.framework`, `Autoupdate`, `Updater.app`, `Downloader.xpc` e `Installer.xpc`:

```bash
bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"
```

Resultado esperado: sete arquivos Mach-O passam. Binários ausentes ou inesperados, importações de rede ou URLs estáticas não listadas e marcadores de rastreadores reprovam a verificação. Importações de URLSession são permitidas no Mac Sai, no auxiliar de menu, no Sparkle e no Downloader; os outros auxiliares do Sparkle não têm nenhuma importação de rede permitida. Os links de documentação e o namespace XML do Sparkle são identificados explicitamente, e não tratados como endpoints de download.

O script também exibe o `SUFeedURL` incluído e verifica os ajustes de feed assinado, pré-extração e privacidade. Compare os destinos de arquivos/notas de versão desse feed e os feeds de outros apps que você solicitar com as conexões ao vivo acima. Os endpoints alternativos são `api.github.com/repos/iliyami/MacSai/releases/latest` e `formulae.brew.sh/api/cask/mac-sai.json`; o endpoint opcional de malware é `mb-api.abuse.ch/api/v1/`. Links do projeto/suporte e links para os ajustes do navegador só abrem quando solicitados. A mesma verificação do pacote completo roda durante o empacotamento; a CI verifica os dois executáveis compilados e todos os cinco binários fixados do Sparkle. [Implementação da verificação e listas de permissões explícitas](scripts/check-network-surface.py).

---

## Arquitetura

```
Mac Sai
├── MacClean          Main SwiftUI app (22 modules)
├── MacCleanKit       Shared framework (models, constants, protocols)
├── MacCleanHelper    XPC privileged helper (LaunchDaemon for root ops)
└── MacCleanMenu      Menu-bar monitor (independent process)
```

### Stack tecnológica

| Camada | Tecnologia |
|-------|-----------|
| Linguagem | Swift 6 com concorrência estrita |
| Interface | Híbrido de SwiftUI + AppKit |
| Concorrência | Actors, TaskGroup, async/await, `@Sendable` |
| Banco de dados | GRDB.swift (SQLite) com modo WAL |
| Verificação de arquivos | Pré-carregamento de `URLResourceKey` no APFS |
| Atualizações incrementais | FSEvents com reprodução do histórico |
| Operações privilegiadas | SMAppService + NSXPCConnection |
| Estatísticas do sistema | APIs Mach (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### Modelo de segurança

O Mac Sai foi projetado para **nunca causar perda de dados**:

- **Lista de bloqueio de caminhos protegidos**: `/System`, `/usr`, `/bin`, `/sbin` e os apps do sistema da Apple são intocáveis, com os firmlinks do macOS canonicalizados para que a detecção de redirecionamento por symlink não gere falsos positivos em caminhos legítimos do sistema
- **Filtro de limpabilidade antes da verificação**: itens que o processo atual não conseguiria mover para o Lixo (filhos de caches do sistema pertencentes ao root, diretórios `~/Library/Caches/com.apple.*` protegidos pelo data vault) são descartados durante a verificação, para que nunca apareçam como limpáveis
- **Exclusão que passa primeiro pelo Lixo**: toda remoção vai para o Lixo por padrão, e um modo de simulação (dry-run) mostra uma prévia sem tocar em nada
- **Prevenção de TOCTOU**: os symlinks são resolvidos novamente logo antes da exclusão
- **Pastas fora da limpeza**: escolha em Ajustes as pastas que as verificações ignoram por completo, e o `SafetyGuard` também se recusa a excluir qualquer coisa dentro delas
- **Limpeza em blocos e cancelável**: seleções grandes são divididas em blocos de 5 mil itens que respeitam o cancelamento entre um bloco e outro, e as verificações voltam ao estado ocioso em cerca de um segundo quando você clica em Cancelar
- **Registro de atividades no app**: cada erro durante uma limpeza é registrado com o caminho completo, pode ser visto e copiado na tela pós-limpeza e é apagado automaticamente após 30 dias
- **Barreira XPC imposta pelo kernel**: o auxiliar privilegiado usa `NSXPCListener.setCodeSigningRequirement`, para que o próprio kernel rejeite qualquer conexão cuja assinatura de código não corresponda ao identificador e à equipe do app

---

## Testes

```bash
swift test
```

A suíte XCTest tem **1.048 testes** e trata `SafetyGuard` e `CleaningEngine` (os arquivos de vida ou morte) como peças que precisam ser perfeitas: cobertura adversarial de symlinks, travessia de caminhos, bytes NULL, SIP, apps protegidos, limites de quantidade de arquivos, TOCTOU e idempotência, além de cobertura de integração da limpeza em dry-run / Lixo / permanente, da máquina de estados da verificação, de cada categoria do System Junk, da matemática do treemap, do mecanismo de correspondência do desinstalador, da detecção de duplicatas, do parsing de appcasts e de ciclos completos de ponta a ponta, da fixture até a limpeza. As fixtures (`withTempHome`, `withFakeApp`, `withFakePlist`) mantêm todos os testes longe da sua pasta pessoal real.

---

## Como contribuir

Contribuições são muito bem-vindas. Leia as [Diretrizes de Contribuição](CONTRIBUTING.md) e depois:

1. Faça um fork do repositório e crie um branch para o recurso
2. Faça sua alteração (uma alteração focada por PR facilita a revisão)
3. Execute `swift test`
4. Abra um Pull Request

Também há uma [votação de recursos](https://github.com/iliyami/MacSai/issues/55) aberta: dê 👍 nas ferramentas que você quer ver em seguida.

## Licença

BSD 3-Clause. Veja [LICENSE](LICENSE). Você pode usar, modificar e redistribuir o código, desde que mantenha o aviso de direitos autorais e o texto da licença e não use o nome "Mac Sai" nem os nomes dos colaboradores para endossar produtos derivados sem permissão.

## Agradecimentos

Inspirado pela comunidade de utilitários de código aberto para Mac:

- [Pearcleaner](https://github.com/alienator88/Pearcleaner): padrões de desinstalação de apps
- [Mole](https://github.com/tw93/Mole): categorias de limpeza
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner): arquitetura modular
- Algoritmo Squarified Treemap de Bruls, Huizing e van Wijk (2000)

## Apoio e patrocinadores

O Mac Sai é gratuito e vai continuar gratuito: sem plano pago, sem anúncios, sem rastreamento. Se ele livrou você da assinatura de um app de limpeza, você pode [me pagar um café ☕](https://buymeacoffee.com/iliyami) ou [se tornar membro](https://buymeacoffee.com/iliyami/membership). Isso mantém as versões assinadas, notarizadas e saindo.

### Apoiadores

Os membros recebem publicações de bastidores, uma prévia de cada versão, builds beta opcionais e o próprio nome no app. Nada no app fica bloqueado por trás de uma assinatura de membro.

<p align="center">
  <em>Ainda não há membros.</em> <a href="https://buymeacoffee.com/iliyami/membership">Seja o primeiro →</a><br>
  <sub>Os membros Power User e Team recebem agradecimentos aqui. Todos estão listados em <a href="SUPPORTERS.md">SUPPORTERS.md</a>.</sub>
</p>

### Espaço de patrocínio

O Mac Sai tem **um único** espaço de patrocínio, exibido aqui e no topo desta página, em todos os idiomas deste README.

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><h3>125.000+</h3><sub>downloads</sub></td>
    <td align="center" width="25%"><h3>2.000+</h3><sub>estrelas no GitHub</sub></td>
    <td align="center" width="25%"><h3>23.000</h3><sub>visualizações de página por mês</sub></td>
    <td align="center" width="25%"><h3>13</h3><sub>idiomas do README</sub></td>
  </tr>
</table>
</div>

A maioria dos visitantes são desenvolvedores e usuários avançados de Mac, que chegam principalmente pela busca do Google e depois pelo YouTube, GitHub e Reddit.

- **Um patrocinador por vez**, para que o seu nome não se perca em um mural de logotipos.
- **Selecionado.** Ferramentas para desenvolvedores, produtos de privacidade e segurança, e apps para Mac que respeitam seus usuários. Nada de limpadores ou "otimizadores", nada de cripto, nada de VPNs com acordos de afiliados, nada que rastreie pessoas.
- **Nunca dentro do app.** O Mac Sai não tem anúncios nem telemetria, e nenhum patrocinador muda isso.

<p align="center">
  <strong>Este espaço está disponível.</strong> <a href="mailto:macsai.team@gmail.com?subject=Mac%20Sai%20sponsor">Seja o patrocinador →</a><br>
  <sub>Detalhes do público e como se candidatar: <a href="SPONSORS.md">SPONSORS.md</a></sub>
</p>

## Histórico de estrelas

<p align="center">
  <a href="https://www.star-history.com/?repos=iliyami%2FMacSai&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&theme=dark&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <img alt="Gráfico do histórico de estrelas" src="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
    </picture>
  </a>
</p>

<p align="center">
  <strong>O Mac Sai é software livre feito pela comunidade, para a comunidade.</strong><br>
  Se ele livrou você de uma assinatura, uma ⭐ ajuda outras pessoas a encontrá-lo, e um <a href="https://buymeacoffee.com/iliyami">café ☕</a> o mantém vivo.
</p>
