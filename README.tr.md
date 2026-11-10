<p align="center">
  <img src="assets/app_icon.png" width="150" alt="Mac Sai Simgesi" />
</p>

<h1 align="center">Mac Sai</h1>

<p align="center">
  <strong>Açık kaynaklı Mac temizleyici, optimize edici ve kötü amaçlı yazılım tarayıcısı.</strong><br>
  CleanMyMac'e ücretsiz ve Apple tarafından noter onaylı bir alternatif; Swift 6 ve SwiftUI ile geliştirildi.<br>
  <sub>125.000+ kez indirildi. Sonsuza dek ücretsiz, sıfır telemetri.</sub>
</p>

<p align="center">
  <a href="README.md">English</a> | <a href="README.zh-CN.md">简体中文</a> | <a href="README.zh-Hant.md">繁體中文</a> | <a href="README.de.md">Deutsch</a> | <a href="README.fr.md">Français</a> | <a href="README.ru.md">Русский</a> | <a href="README.es.md">Español</a> | <a href="README.it.md">Italiano</a> | <a href="README.pt-BR.md">Português (Brasil)</a> | <a href="README.ja.md">日本語</a> | <a href="README.ko.md">한국어</a> | <strong>Türkçe</strong> | <a href="README.fa.md">فارسی</a>
</p>

<p align="center">
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/downloads/iliyami/MacSai/total?style=flat-square&label=downloads&color=2ea44f" alt="Total downloads" /></a>
  <a href="https://github.com/iliyami/MacSai/stargazers"><img src="https://img.shields.io/github/stars/iliyami/MacSai?style=flat-square&color=gold" alt="GitHub stars" /></a>
  <a href="https://formulae.brew.sh/cask/mac-sai"><img src="https://img.shields.io/homebrew/cask/installs/dm/mac-sai?style=flat-square&label=homebrew&color=orange" alt="Homebrew installs" /></a>
  <a href="https://github.com/iliyami/MacSai/releases/latest"><img src="https://img.shields.io/github/v/release/iliyami/MacSai?style=flat-square&color=blue" alt="Latest release" /></a>
  <a href="https://github.com/iliyami/MacSai/graphs/commit-activity"><img src="https://img.shields.io/github/commit-activity/m/iliyami/MacSai?style=flat-square&label=commits" alt="Commit activity" /></a>
  <br>
  <img src="https://img.shields.io/badge/Apple-notarized-black?style=flat-square&logo=apple" alt="Notarized" />
  <img src="https://img.shields.io/badge/telemetry-none-brightgreen?style=flat-square" alt="No telemetry" />
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6-orange?style=flat-square" alt="Swift 6" />
  <a href="https://github.com/iliyami/MacSai/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/iliyami/MacSai/ci.yml?branch=main&style=flat-square&label=tests" alt="Tests" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-BSD--3--Clause-green?style=flat-square" alt="License" /></a>
</p>

<p align="center">
  <img src="assets/demo.png" width="720" alt="Mac Sai Ekran Görüntüsü" />
</p>

<p align="center">
  <strong>Tek komutla kurun:</strong>
</p>

```bash
brew install --cask mac-sai
```

<p align="center">
  Ya da <a href="https://github.com/iliyami/MacSai/releases/latest">en son DMG</a> dosyasını indirin. Apple tarafından noter onaylı olduğu için doğrudan açılır: sağ tık yok, uyarı yok, Terminal yok.
</p>

<p align="center">
  <sub>Uygulamada asla reklam yok. Bu sayfada <a href="SPONSORS.md">özenle seçilen tek bir sponsor alanı</a> var ve şu an boş.</sub>
</p>

---

## Neden Mac Sai?

Tam donanımlı bir Mac temizleyicisi yıllık abonelik gerektirmemeli ya da dosyalarınıza derin erişimi olan bir kara kutuya güvenmenizi istememeli. Mac Sai size tüm araç setini açık bir şekilde sunar.

- **Sonsuza dek ücretsiz.** Abonelik yok, uygulama içi satın alma yok, "Pro'ya yükselt" yok, rahatsız edici uyarı ekranları yok. BSD-3 lisanslı.
- **Sıfır telemetri.** Analitik yok, çökme raporlayıcı yok, izleyici yok, veri gönderilen bir sunucu yok. Üstelik sözümüze güvenmek zorunda değilsiniz: iki komutla [kendiniz doğrulayın](#telemetri-olmadığını-kendiniz-doğrulayın).
- **CleanMyMac'in tüm önemli araçları tek uygulamada.** Temizlik, koruma, performans, uygulamalar ve disk analizi alanlarında 22 modül, artı bir menü çubuğu widget'ı.
- **Tasarımı gereği güvenli.** Önce Çöp Sepeti'ne taşıyan silme, korumalı yollar için engel listesi, sembolik bağlantı ve TOCTOU korumaları ve her yolu doğrulayan bir `SafetyGuard`. Verilerinizi asla kaybetmeyecek şekilde tasarlandı.
- **Apple tarafından noter onaylı ve tamamen açık kaynak.** Mac'iniz her açılışta imzayı doğrular ve kodun her satırı burada okunabilir.

---

## Özelliklere genel bakış

<table>
<tr>
<td width="33%" valign="top">

### 🧹 Temizlik
- **Akıllı Tarama** (tek tıkla)
- **Gereksiz Sistem Dosyaları** (16+ kategori)
- **Mail Ekleri**
- **Çöp Sepetleri**
- **Gereksiz Proje Dosyaları** (derleme klasörleri)
- **Geliştirici Depolaması** (Docker, simülatörler)
- **Temizleme Geçmişi** (tek tıkla geri yükleme)

</td>
<td width="33%" valign="top">

### 🛡️ Koruma
- **Tehdit Temizleme**
- **Gizlilik** (tarayıcılar)
- **Tarayıcı Uzantıları**
- **Kayıtlı Wi-Fi**
- **İzinler**

</td>
<td width="33%" valign="top">

### ⚡ Performans
- **Optimizasyon** (giriş öğeleri)
- **Bakım** (sistem görevleri)

</td>
</tr>
<tr>
<td width="33%" valign="top">

### 📦 Uygulamalar
- **Kaldırıcı** (+ Varsayılanlara Sıfırla)
- **Kullanılmayan Uygulamalar**
- **Uzantılar** (paneller, eklentiler)
- **Güncelleyici**

</td>
<td width="33%" valign="top">

### 🗂️ Dosyalar
- **Disk Haritası** (disk ağaç haritası)
- **Büyük ve Eski Dosyalar**
- **Yinelenen Dosyalar** (+ Birleştir)
- **Dosya Öğütücü**

</td>
<td width="33%" valign="top">

### 📊 Menü Çubuğu
- Canlı CPU / bellek / disk / pil
- Ağ, çalışma süresi, takas alanı
- Uygulanabilir öneriler

</td>
</tr>
</table>

---

## Ayrıntılı özellikler

### 🧹 Temizlik
| Modül | Ne yapar |
|--------|------------|
| **Akıllı Tarama** | Tek tıkla temizlik, koruma ve performans modüllerini canlı ilerleme göstergesiyle birlikte çalıştırır, ardından her modülün tam olarak ne kadar yer açtığını gösterir |
| **Gereksiz Sistem Dosyaları** | 16+ tarama kategorisi: kullanıcı ve sistem önbellekleri, günlükler, dil dosyaları, bozuk tercihler, bozuk giriş öğeleri, belge sürümleri, iOS yedekleri, Xcode artıkları, paket yöneticisi / IDE / yapay zekâ aracı önbellekleri, silinmiş kullanıcılardan kalanlar ve **Universal Binary inceltme** (hem arm64 hem x86_64 içeren şişkin Mach-O ikili dosyalarını bulur ve `lipo` ile Mac'inizin yerel mimarisine göre yeniden yazar, İptal komutuna uyar) |
| **Mail Ekleri** | Apple Mail, Outlook ve Spark'ın önbelleğe aldığı ekleri bulur |
| **Çöp Sepetleri** | Harici sürücüler dahil her konumdaki Çöp Sepeti'ni boşaltır |
| **Gereksiz Proje Dosyaları** | Projelerinizdeki yeniden oluşturulabilir derleme klasörlerini bulur: `node_modules`, `.next`, `dist`, Rust ve Maven `target`, Gradle `build`, Python sanal ortamları (virtualenv) ve CocoaPods `Pods`. Bir klasör yalnızca yanındaki dosyalar proje türünü doğruladığında sayılır; `dist` ve `Pods` ise yalnızca `.gitignore` dosyanızda adları geçiyorsa. Her şey Çöp Sepeti'ne gider |
| **Geliştirici Depolaması** | Docker ve Xcode simülatörlerinin ne kadar yer kapladığını gösterir. Durdurulmuş kapsayıcıları, sahipsiz (dangling) imajları ve sahipsiz derleme önbelleğini temizler (her biri ayrı onay ister), kullanılamayan simülatörleri ve eski simülatör çalışma ortamlarını siler. Docker birimlerine (volume) ve her platformun en yeni çalışma ortamına asla dokunulmaz |
| **Temizleme Geçmişi** | Son temizlemelerinizi listeler (son 30 gün, en fazla 20) ve bir temizlemenin tamamını tek tıkla Çöp Sepeti'nden geri yükler. Geçmiş, Mac'inizde `~/Library/Logs/MacClean/clean-history.json` dosyasında kalır, yalnızca kullanıcı hesabınız tarafından okunabilir ve hiçbir yere gönderilmez |

### 🛡️ Koruma
| Modül | Ne yapar |
|--------|------------|
| **Tehdit Temizleme** | 3 derinlikte imza tabanlı tarama (Hızlı / Dengeli / Derin): başlatma aracıları ve arka plan hizmetleri (launch agents, daemons), uygulama paketleri, tarayıcı uzantıları ve bilinen reklam yazılımı/kötü amaçlı yazılım kalıpları. Mac'inizde zaten bulunan Apple XProtect imzalarıyla çevrimdışı, birebir karma (hash) eşleştirmesi, artı isteğe bağlı bir MalwareBazaar (abuse.ch) karma beslemesi. Apple'ın engel listesindeki Safari uzantıları ve MalwareBazaar eşleşmeleri inceleme için listelenir, asla önceden seçilmez (bir antivirüs değildir ve bunu açıkça söyler) |
| **Gizlilik** | Safari, Chrome ve Firefox geçmişini, çerezlerini ve önbelleğini zaman filtreleriyle temizler. Safari **yer işaretlerine asla dokunulmaz** |
| **Tarayıcı Uzantıları** | Safari, Chrome, Brave, Edge, Arc ve Firefox'ta yüklü uzantıları listeler. Kendi yüklediğiniz Chromium ve Firefox uzantıları, ilgili tarayıcı kapalıyken Çöp Sepeti'ne taşınabilir; bir ilke (policy) ile ya da tarayıcının kendisi tarafından yüklenenler gösterilir ama onlara dokunulmaz. Safari uzantıları Safari'nin ayarlarına yönlendirir |
| **Kayıtlı Wi-Fi** | Tercih ettiğiniz kablosuz ağları listeler ve seçtiklerinizi unutur |
| **İzinler** | Her uygulamanın hangi gizlilik (TCC) izinlerine sahip olduğunu uygulama bazında gösteren salt okunur bir görünüm; Sistem Ayarları'nın size sunmadığı bir bakış açısı. Her işlem, anahtarların asıl yönetildiği Sistem Ayarları'ndaki ilgili bölüme doğrudan bağlantı verir |

### ⚡ Performans
| Modül | Ne yapar |
|--------|------------|
| **Optimizasyon** | Giriş öğelerini ve başlatma aracılarını öğe bazında etkinleştirip devre dışı bırakarak yönetin |
| **Bakım** | Sistem görevleri: RAM'i boşaltma, bakım betiklerini çalıştırma, başlangıç diskini doğrulama, Launch Services'i yeniden oluşturma, Spotlight'ı yeniden dizinleme, DNS önbelleğini temizleme, Time Machine anlık görüntülerini azaltma. Görevler önem derecesine göre etiketlenir, "Güvenli görevleri çalıştır" görevleri sırayla çalıştırır ve yönetici parolası **yalnızca bir kez** sorulur |

### 📦 Uygulamalar
| Modül | Ne yapar |
|--------|------------|
| **Kaldırıcı** | 17+ Library alt dizininde (satıcı alt klasörlerine yerleştirilmiş uygulamalar dahil) ilişkili her dosyayı bulan bir kalıp eşleştirme motoru. Eksiksiz kaldırma, **Varsayılanlara Sıfırla** (uygulamayı tutarken önbelleklerini ve tercihlerini siler) ve kullanılmayan uygulama tespiti |
| **Kullanılmayan Uygulamalar** | Spotlight'ın son kullanım tarihine dayanarak 3, 6 veya 12 aydır açmadığınız uygulamaları bulur ve boyuta göre sıralar. Çalışan uygulamalar asla listelenmez; Spotlight'ta kullanım verisi yoksa tahmin yürütmek yerine bunu açıkça söyler. Tek tıkla bir uygulamayı Kaldırıcı'ya aktarır |
| **Uzantılar** | Üçüncü taraf tercih panellerini, İnternet Eklentilerini (Internet Plug-Ins) ve Safari uzantılarını gözden geçirin. Kullanıcının yüklediği paneller ve eklentiler Çöp Sepeti'ne taşınabilir |
| **Güncelleyici** | Yüklü uygulamaların güncellemelerini kendi Sparkle appcast beslemeleri üzerinden denetler (yalnızca sürüm bilgisini okur, sizinle ilgili hiçbir şey göndermez) |

### 🗂️ Dosyalar
| Modül | Ne yapar |
|--------|------------|
| **Disk Haritası** | Disk kullanımını, ayrıntıya inerek gezinebileceğiniz kareleştirilmiş ağaç haritası (squarified treemap) olarak görselleştirir |
| **Büyük ve Eski Dosyalar** | 50 MB'tan büyük dosyaları bulur, boyuta ve son erişim tarihine göre sıralar |
| **Yinelenen Dosyalar** | Aşamalı tespit (boyuta göre gruplama, kısmi SHA-256, tam karma, inode doğrulaması), ayrıca tek bir kopyayı bile silmeden APFS copy-on-write klonlarıyla yer kazandıran bir **Birleştir** modu |
| **Dosya Öğütücü** | Standart, kalıcı ve güvenli üzerine yazma modlarıyla güvenli dosya silme |

### 📊 Menü Çubuğu Widget'ı

<p align="center">
  <img src="assets/menu_bar.png" width="300" alt="Mac Sai menü çubuğu widget'ı" />
</p>

Mac'inizin hayati değerlerini bir tık uzağınıza getiren, buzlu cam (glassmorphism) görünümlü bir menü çubuğu widget'ı. Girişte başlayan bağımsız bir süreçtir ve uygulamanın kenar çubuğundan açılıp kapatılır; böylece yalnızca bir göz atmak için ana pencereyi açmanız gerekmez.

- **Canlı istatistik halkaları**: CPU yükü, bellek baskısı, disk kullanımı ve pil, 2x2 halka ızgarasında (`host_processor_info`, `vm_statistics64`, APFS kapasitesi, IOKit güç kaynağı), yeşilden kehribar rengine ve kırmızıya kademeli renklendirmeyle
- **Yapılandırılabilir gösterge**: boş disk alanını, GPU kullanımını, bellek kullanımını veya pil sıcaklığını gösterin; seçim kalıcıdır ve kullanılamayan sensörler `--` gösterir
- **Ağ, çalışma süresi ve takas alanı**: gerçek zamanlı yükleme/indirme hızı, sistem çalışma süresi, takas alanı kullanımı
- **Öneriler**: uygulanabilir, kapatılabilir ipuçları ("Kullanıcı önbellekleri 2,52 GB'a ulaştı, Gereksiz Sistem Dosyaları'nı çalıştırın"), tek dokunuşla işlem; kapatıldıktan sonra 30 gün boyunca gösterilmez
- **Koruma durumu**: son kötü amaçlı yazılım taramasının zamanı ve tehdit sayısı, ne kadar güncel olduğuna göre renk kodlu
- **Bağlı aygıtlar**: harici birimler (boş alanlarıyla) ve ekranlar bir bakışta
- **Sağlık uyarıları**: disk kritik derecede dolduğunda veya bellek baskısı yüksek kaldığında, sıklığı sınırlandırılmış ve isteğe bağlı bildirimler

### ⌨️ Klavye kısayolları

| Kısayol | İşlem |
|----------|--------|
| **⌘R** | Geçerli modülde tarama başlatır |
| **⌘K** | Geçerli seçimi temizler (sonuçlar görüntülenirken) |
| **⌘1 ile ⌘9 arası** | Kenar çubuğundaki ilk dokuz modüle atlar |
| **⌘,** | Ayarlar'ı açar |

---

## Mac Sai ve alternatifleri

|  | Mac Sai | CleanMyMac | Pearcleaner | PureMac | OnyX | Mole |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **Fiyat** | Ücretsiz | $39.95/yıl | Ücretsiz | Ücretsiz | Ücretsiz | Ücretsiz (CLI) |
| **Açık kaynak** | ✅ BSD-3 | ❌ | ✅ Fair-code | ✅ MIT | ❌ | ✅ MIT |
| **Telemetri** | ❌ Yok | ⚠️ Var | ❌ Yok | ❌ Yok | ❌ Yok | ❌ Yok |
| **Yerel GUI uygulaması** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ CLI (ücretli GUI ayrı) |
| **Akıllı Tarama (tek tık)** | ✅ | ✅ | ❌ | ➖ Kısmi | ❌ | ➖ Etkileşimli CLI |
| **Gereksiz Sistem Dosyaları (16+ kategori)** | ✅ | ✅ | ➖ | ✅ | ➖ Sınırlı | ✅ |
| **Universal Binary inceltme** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Kötü amaçlı yazılım tarayıcısı** | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Tarayıcı gizlilik temizleyicisi** | ✅ | ✅ | ❌ | ❌ | ➖ | ❌ |
| **Artık dosya tespitli kaldırıcı** | ✅ | ✅ | ✅ Ana odak | ❌ | ❌ | ✅ |
| **Yinelenen dosya bulucu (+ birleştirme)** | ✅ | ➖ | ❌ | ❌ | ❌ | ❌ |
| **Disk ağaç haritası görselleştirici** | ✅ | ❌ | ❌ | ❌ | ❌ | ➖ Analiz aracı |
| **Menü çubuğu sistem izleyicisi** | ✅ | ✅ Menü | ❌ | ❌ | ❌ | ❌ |
| **Bakım betikleri** | ✅ | ✅ | ❌ | ❌ | ✅ Güçlü | ➖ |
| **Apple tarafından noter onaylı** | ✅ | ✅ | ✅ | ✅ | ✅ | Geçerli değil |
| **macOS sürümü** | 14+ | 13+ | 13+ | 13+ | değişir | değişir |

> CleanMyMac harika bir ürün; özenle cilalanmış, destekli bir deneyim isteyenler bunun için gönül rahatlığıyla ödeme yapmalı. Mac Sai ise şeffaf kaynak kodu ve sıfır aboneliği tercih eden herkes için.

---

## Arayüz dilleri

Ayarlar → Arayüz Dili bölümünden Sistem, English, 简体中文, 繁體中文, Русский, Deutsch, Français, Español, Italiano, Português (Brasil), Türkçe, 日本語, 한국어 veya فارسی seçeneğini belirleyin. İngilizce, Basitleştirilmiş Çince ve Rusça arayüzün tamamını kapsar. Diğer diller statik arayüz metinlerini çevirir; değişken değer içeren mesajlar şimdilik İngilizce ifadeleri ve İngilizce çoğul kurallarını korur (Geleneksel Çince, eksik yerlerde Basitleştirilmiş Çinceye geri döner). Ana pencere ve menü çubuğu widget'ı aynı dil tercihini paylaşır. Farsçada arayüz sağdan sola gösterilir.

## Kurulum

### Homebrew (önerilen)

Mac Sai resmi Homebrew cask deposunda yer alır, bu yüzden tap eklemeniz gerekmez:

```bash
brew install --cask mac-sai
```

Apple tarafından noter onaylı olduğu için Spotlight'tan veya Uygulamalar klasöründen uyarısız ve ek adım gerektirmeden açılır.

<details>
<summary><strong>Diğer kurulum yöntemleri</strong> (tek satırlık betik, DMG, kaynaktan derleme)</summary>

<br>

**Tek satırlık yükleyici**

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/install.sh | bash
```

En son DMG'yi indirir ve uygulamayı `/Applications` klasörüne yükler.

**DMG indirme**

En son DMG'yi [Sürümler](https://github.com/iliyami/MacSai/releases/latest) sayfasından indirin ve Mac Sai'yi Uygulamalar klasörünüze sürükleyin.

**Kaynaktan derleme**

```bash
git clone https://github.com/iliyami/MacSai.git
cd MacSai
swift build
swift test                     # run the full 1,048-test suite
bash scripts/build-dmg.sh      # build a local DMG (unsigned)
```

Swift 6 araç zinciri (Xcode 16+) gerekir.

**Eski tap ile mi yüklediniz?**

Mac Sai artık resmi cask'ta yer aldığı için tap'i kaldırabilirsiniz: `brew untap iliyami/macsai` (yüklü uygulamanız ve gelecekteki `brew upgrade` işlemleri bundan etkilenmez).

</details>

### Tam Disk Erişimi verme

Birkaç modül (Mail Ekleri, Gizlilik, Tehdit Temizleme) korumalı alanları taramak için Tam Disk Erişimi'ne ihtiyaç duyar:

1. **Sistem Ayarları, Gizlilik ve Güvenlik, Tam Disk Erişimi** bölümünü açın
2. **+** düğmesine tıklayın ve **Mac Sai.app** uygulamasını ekleyin
3. Mac Sai'yi yeniden başlatın

### Kaldırma

Homebrew ile kurulum:

```bash
brew uninstall --zap --cask mac-sai
```

DMG veya elle kurulum (Homebrew kurulumunu da kapsar):

```bash
curl -fsSL https://raw.githubusercontent.com/iliyami/MacSai/main/scripts/uninstall.sh | bash
```

Her ikisi de Mac Sai'yi ve `~/Library` altındaki tercihlerini, önbelleklerini, günlüklerini ve veritabanını kaldırır.

---

## İmzalı, noter onaylı ve güvenebileceğiniz bir uygulama

Mac Sai, Apple **Developer ID** ile kod imzalıdır ve **Apple tarafından noter onaylıdır**. Bu, bir temizleme uygulaması için yüklediğiniz neredeyse her şeyden daha önemlidir, çünkü ona dosyalarınıza derin erişim vermek üzeresiniz ve Mac'inizde çalışanın gerçekten bize ait olduğunu ve kurcalanmadığını bilmeyi hak ediyorsunuz. Bunların hepsini yalnızca biz vaat etmiyoruz, Mac'inizin kendisi uyguluyor:

- **Apple tarafından taranmıştır.** Her sürüm yayımlanmadan önce Apple'a gönderilir ve kötü amaçlı yazılıma karşı denetlenir.
- **Kurcalanamaz.** İmza, her dosyanın üzerinde kriptografik bir mühürdür; tek bir baytı değiştirirseniz macOS uygulamayı açmayı reddeder.
- **Bizden geldiği kanıtlanabilir.** İmza, Apple Developer kimliğimize bağlıdır; bu yüzden başka hiç kimse Mac'inizin Mac Sai olarak kabul edeceği bir şey yayımlayamaz.
- **Sorunsuz çalışır.** Gatekeeper uyarısı yok, sağ tıklayıp açma yok, Terminal yok.

Tamamen açık kaynak olmasıyla birleştiğinde bu, körü körüne inanmanızı gerektirmeyen bir güven zinciridir: kod herkese açıktır, her sürümü biz imzalarız, Apple doğrular ve Mac'iniz uygulamayı her açtığınızda mührü yeniden denetler.

### Telemetri olmadığını kendiniz doğrulayın

Sözümüze güvenmeyin. Hem kaynak kod hem de çalışan süreç denetlenebilir.

**1. Kaynak kodda ağ API'lerini arayın**

```bash
rg -n 'URLSession|NSURLConnection|Sparkle|SecTrustEvaluate' Sources --glob '*.swift'
```

İsteğe bağlı ağ yolları aşağıda açıklanmıştır. Yerel temizlik, tarama sonuçlarını veya dosya listelerini hiçbir yere yüklemez:

- `Sources/MacClean/Services/SelfUpdateController.swift`: Sparkle, imzalı uygulamaya mühürlenmiş HTTPS beslemesini denetler ve imzalı sürüm notlarını ve güncelleme arşivlerini indirir. Otomatik denetim ile otomatik indirme/yükleme ayrı ayarlardır; sistem profili gönderimi ve sürüm notlarındaki JavaScript devre dışıdır. Bkz. [güncelleme kurulumu](docs/IN_APP_UPDATES.md). Yapılandırılmış doğrudan kurulumlarda otomatik güncelleme denetimleri varsayılan olarak açıktır ve günde bir kez çalışır; her istek User-Agent içinde uygulama ve Sparkle sürümlerini içerir ve denetimler Ayarlar'dan kapatılabilir.
- `Sources/MacCleanKit/UpdateChecker.swift`: Homebrew güncelleme denetimleri ve yapılandırılmış imzalı beslemesi olmayan derlemeler için sürüm sayfası yedeği
- `Sources/MacClean/Modules/Updater/UpdaterModule.swift`: Güncelleyici'yi açtığınızda *diğer uygulamaların* Sparkle beslemelerinin sizin başlattığınız denetimi
- `Sources/MacCleanKit/MalwareBazaarFeed.swift`: isteğe bağlı MalwareBazaar karma indirmesi. Yalnızca kendi abuse.ch Auth-Key'inizi ekleyip Ayarlar > Kötü Amaçlı Yazılım Veri Tabanları bölümünde Şimdi Güncelle'ye bastığınızda çalışır. Her istek yalnızca Auth-Key'inizi ve sorguyu gönderir, asla dosya karmalarını veya yollarını göndermez. İndirilen bir karma imzalı bir dosyayla eşleştiğinde macOS, Gatekeeper'ın yaptığı denetimin aynısıyla, dosyanın imzalama sertifikasının iptal edilip edilmediğini Apple'a sorar; bu istek dosyalarınızla değil, sertifikayla ilgilidir

Kod tabanının hiçbir yerinde analitik, çökme raporlayıcı veya izleyici SDK'sı yoktur.

**2. Çalışan süreci izleyin**

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

Bu anlık görüntü, PID'leri seçilen uygulama paketinin içindeki yürütülebilir dosya yollarına göre seçer; böylece ilgisiz Installer/Updater süreçleri dışarıda kalır. Başka bir yere kopyalanmış Sparkle yardımcıları ve macOS güven hizmetleri bu anlık görüntünün kapsamı dışındadır; bunları gözlemlemek için süreçleri ayırt edebilen bir güvenlik duvarı kullanın. Kısa ömürlü bağlantıları yakalamak için komutu bir güncellemeyi denetlerken veya indirirken çalıştırın.

Güncelleme denetimleri/indirmeleri ve isteğe bağlı kötü amaçlı yazılım doğrulaması etkin değilken yerel temizlik hiçbir ağ bağlantısı açmaz. Bir güncellemeyi gözlemlerken Sparkle'ın alt süreçlerini de dahil edin; Apple sertifika denetimleri macOS güven hizmetleri üzerinden çalışır. Little Snitch veya LuLu da bu bağlantıları gösterebilir.

**3. Gerçekten yüklediğiniz ikili dosyayı inceleyin**

DMG veya Homebrew kurulumu için bu döngü yalnızca macOS komut satırı araçlarına ihtiyaç duyar; kaynak kod kopyası veya Python gerekmez. Paketteki yedi ikili dosyanın tümünü okur ve elle incelemeniz için yaygın ağ içe aktarımlarını (import), statik URL'leri ve izleyici dizelerini listeler:

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

Bu listeler bir geçti/kaldı denetimi ya da çalışma zamanındaki her hedefin görünür olduğunun kanıtı değildir. Eksiksiz bileşen envanteri, açık izin listeleri ve paketlenmiş gizlilik ayarları için aşağıdaki otomatik denetimi kullanın.

Denetimi, yüklü sürümle eşleşen bir kaynak kod kopyasından çalıştırın. Ana yürütülebilir dosya, menü yardımcısı, `Sparkle.framework`, `Autoupdate`, `Updater.app`, `Downloader.xpc` ve `Installer.xpc` dahil olmak üzere gerçek uygulama paketini inceler:

```bash
bash scripts/check-network-surface.sh "/Applications/Mac Sai.app"
```

Beklenen sonuç: yedi Mach-O dosyası denetimden geçer. Eksik veya beklenmeyen ikili dosyalar, listelenmemiş ağ içe aktarımları veya statik URL'ler ve izleyici işaretleri denetimin başarısız olmasına yol açar. URLSession içe aktarımlarına Mac Sai'de, menü yardımcısında, Sparkle'da ve Downloader'da izin verilir; diğer Sparkle yardımcılarının izin verilen hiçbir ağ içe aktarımı yoktur. Sparkle'ın belge bağlantıları ve XML ad alanı açıkça tanımlanır, indirme uç noktası olarak değerlendirilmez.

Betik ayrıca paketlenmiş `SUFeedURL` değerini yazdırır ve imzalı besleme, ayıklama öncesi doğrulama (pre-extraction) ve gizlilik ayarlarını denetler. Bu beslemenin arşiv/sürüm notu hedeflerini ve talep ettiğiniz diğer uygulama beslemelerini yukarıdaki canlı bağlantılarla karşılaştırın. Yedek uç noktalar `api.github.com/repos/iliyami/MacSai/releases/latest` ve `formulae.brew.sh/api/cask/mac-sai.json`; isteğe bağlı kötü amaçlı yazılım uç noktası ise `mb-api.abuse.ch/api/v1/`. Proje/destek bağlantıları ve tarayıcı ayarları bağlantıları yalnızca istendiğinde açılır. Aynı eksiksiz paket denetimi paketleme sırasında da çalışır; CI hem derlenen iki yürütülebilir dosyayı hem de sabitlenmiş beş Sparkle ikili dosyasının tümünü denetler. [Denetim uygulaması ve açık izin listeleri](scripts/check-network-surface.py).

---

## Mimari

```
Mac Sai
├── MacClean          Main SwiftUI app (22 modules)
├── MacCleanKit       Shared framework (models, constants, protocols)
├── MacCleanHelper    XPC privileged helper (LaunchDaemon for root ops)
└── MacCleanMenu      Menu-bar monitor (independent process)
```

### Teknoloji yığını

| Katman | Teknoloji |
|-------|-----------|
| Dil | Katı eşzamanlılık (strict concurrency) ile Swift 6 |
| Arayüz | SwiftUI + AppKit karma yapı |
| Eşzamanlılık | Actors, TaskGroup, async/await, `@Sendable` |
| Veritabanı | WAL modunda GRDB.swift (SQLite) |
| Dosya tarama | APFS üzerinde `URLResourceKey` ön getirme |
| Artımlı güncellemeler | Geçmiş olayları yeniden oynatan FSEvents |
| Ayrıcalıklı işlemler | SMAppService + NSXPCConnection |
| Sistem istatistikleri | Mach API'leri (`host_processor_info`, `vm_statistics64`, `proc_pidinfo`) |

### Güvenlik modeli

Mac Sai **asla veri kaybına yol açmayacak** şekilde tasarlanmıştır:

- **Korumalı yollar engel listesi**: `/System`, `/usr`, `/bin`, `/sbin` ve Apple sistem uygulamalarına dokunulamaz; macOS firmlink'leri standart biçime getirilir, böylece sembolik bağlantı yönlendirme tespiti meşru sistem yollarında yanlış alarm vermez
- **Tarama öncesi temizlenebilirlik filtresi**: geçerli sürecin Çöp Sepeti'ne taşıyamayacağı öğeler (sistem önbelleklerinin root'a ait alt öğeleri, veri kasasıyla korunan `~/Library/Caches/com.apple.*` dizinleri) tarama sırasında elenir, böylece asla temizlenebilir olarak görünmez
- **Önce Çöp Sepeti'ne silme**: her kaldırma işlemi varsayılan olarak Çöp Sepeti'ne gider ve deneme (dry-run) modu hiçbir şeye dokunmadan önizleme sunar
- **TOCTOU önleme**: sembolik bağlantılar silme işleminden hemen önce yeniden çözümlenir
- **Hariç Tutulan Klasörler**: Ayarlar'da taramaların tamamen atlayacağı klasörleri seçin; `SafetyGuard` ayrıca bunların altındaki hiçbir şeyi silmeyi reddeder
- **Parçalı, iptal edilebilir temizlik**: büyük seçimler, parçalar arasında iptali dikkate alan 5 bin öğelik parçalara bölünür ve İptal'e bastığınızda taramalar yaklaşık bir saniye içinde boşta durumuna döner
- **Uygulama içi etkinlik günlüğü**: temizlik sırasında oluşan her hata tam yoluyla günlüğe kaydedilir, temizlik sonrası ekranda görüntülenip kopyalanabilir ve 30 gün sonra otomatik olarak silinir
- **Çekirdek tarafından uygulanan XPC kapısı**: ayrıcalıklı yardımcı `NSXPCListener.setCodeSigningRequirement` kullanır; böylece kod imzası uygulamanın tanımlayıcısı ve ekibiyle eşleşmeyen her bağlantıyı doğrudan çekirdeğin kendisi reddeder

---

## Testler

```bash
swift test
```

XCTest paketi **1.048 test** içerir ve `SafetyGuard` ile `CleaningEngine` dosyalarını (ölüm kalım meselesi olan dosyalar) kusursuz olması gereken parçalar olarak ele alır: sembolik bağlantılar, yol geçişi (path traversal), NULL baytlar, SIP, korumalı uygulamalar, dosya sayısı sınırları, TOCTOU ve idempotentlik için saldırgan senaryolarla kapsam; ayrıca deneme / Çöp Sepeti / kalıcı temizlik, tarama durum makinesi, her Gereksiz Sistem Dosyaları kategorisi, ağaç haritası hesaplamaları, kaldırıcı eşleştirme motoru, yinelenen dosya tespiti, appcast ayrıştırma ve fikstürden temizliğe uçtan uca tam döngüler için entegrasyon kapsamı. Fikstürler (`withTempHome`, `withFakeApp`, `withFakePlist`) her testi gerçek ana dizininizden uzak tutar.

---

## Katkıda bulunma

Katkılarınızı memnuniyetle karşılıyoruz. Önce [Katkı Yönergeleri](CONTRIBUTING.md) belgesini okuyun, ardından:

1. Depoyu fork'layın ve bir özellik dalı oluşturun
2. Değişikliğinizi yapın (PR başına tek bir odaklı değişiklik incelemeyi kolaylaştırır)
3. `swift test` komutunu çalıştırın
4. Bir Pull Request açın

Ayrıca açık bir [özellik oylaması](https://github.com/iliyami/MacSai/issues/55) var: sırada geliştirilmesini istediğiniz araçlara 👍 verin.

## Lisans

BSD 3-Clause. Bkz. [LICENSE](LICENSE). Kodu kullanabilir, değiştirebilir ve yeniden dağıtabilirsiniz; yeter ki telif hakkı ve lisans metnini koruyun ve "Mac Sai" adını ya da katkıda bulunanların adlarını izin almadan türetilmiş ürünleri desteklemek için kullanmayın.

## Teşekkürler

Açık kaynaklı Mac yardımcı araçları topluluğundan ilham alınmıştır:

- [Pearcleaner](https://github.com/alienator88/Pearcleaner): uygulama kaldırıcı kalıpları
- [Mole](https://github.com/tw93/Mole): temizlik kategorileri
- [Tencent Lemon Cleaner](https://github.com/Tencent/lemon-cleaner): modüler mimari
- Bruls, Huizing ve van Wijk'in Squarified Treemap algoritması (2000)

## Destek ve sponsorlar

Mac Sai ücretsizdir ve ücretsiz kalacak: ücretli sürüm yok, reklam yok, izleme yok. Sizi bir temizleyici aboneliğinden kurtardıysa [bana bir kahve ısmarlayabilir ☕](https://buymeacoffee.com/iliyami) ya da [üye olabilirsiniz](https://buymeacoffee.com/iliyami/membership). Bu destek, sürümlerin imzalı, noter onaylı ve düzenli olarak gelmeye devam etmesini sağlar.

### Destekçiler

Üyeler perde arkası paylaşımlarını, her sürüme erken bakışı ve isteğe bağlı beta derlemelerini alır, adları da uygulamada yer alır. Uygulamadaki hiçbir özellik asla üyeliğe bağlı olarak kilitlenmez.

<p align="center">
  <em>Henüz üye yok.</em> <a href="https://buymeacoffee.com/iliyami/membership">İlk siz olun →</a><br>
  <sub>Power User ve Team üyelerine burada teşekkür edilir. Herkes <a href="SUPPORTERS.md">SUPPORTERS.md</a> dosyasında listelenir.</sub>
</p>

### Sponsor alanı

Mac Sai'nin **tek bir** sponsor alanı var; bu alan burada ve sayfanın en üstünde, bu README'nin her dilinde gösterilir.

<div align="center">
<table>
  <tr>
    <td align="center" width="25%"><h3>125.000+</h3><sub>indirme</sub></td>
    <td align="center" width="25%"><h3>2.000+</h3><sub>GitHub yıldızı</sub></td>
    <td align="center" width="25%"><h3>23.000</h3><sub>aylık sayfa görüntüleme</sub></td>
    <td align="center" width="25%"><h3>13</h3><sub>README dili</sub></td>
  </tr>
</table>
</div>

Ziyaretçilerin çoğu geliştiriciler ve ileri düzey Mac kullanıcılarıdır; çoğunlukla Google aramasından, ardından YouTube, GitHub ve Reddit'ten gelirler.

- **Aynı anda tek sponsor**, böylece adınız bir logo yığınının içinde kaybolmaz.
- **Özenle seçilir.** Geliştirici araçları, gizlilik ve güvenlik ürünleri ve kullanıcılarına saygı duyan Mac uygulamaları. Temizleyiciler veya "optimize ediciler" yok, kripto yok, ortaklık (affiliate) VPN anlaşmaları yok, insanları izleyen hiçbir şey yok.
- **Asla uygulamanın içinde değil.** Mac Sai'de reklam ve telemetri yoktur ve hiçbir sponsor bunu değiştirmez.

<p align="center">
  <strong>Bu alan boş.</strong> <a href="mailto:macsai.team@gmail.com?subject=Mac%20Sai%20sponsor">Sponsor olun →</a><br>
  <sub>Kitle ayrıntıları ve başvuru: <a href="SPONSORS.md">SPONSORS.md</a></sub>
</p>

## Yıldız Geçmişi

<p align="center">
  <a href="https://www.star-history.com/?repos=iliyami%2FMacSai&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&theme=dark&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
      <img alt="Yıldız Geçmişi Grafiği" src="https://api.star-history.com/chart?repos=iliyami/MacSai&type=date&legend=top-left&sealed_token=U-awhgge-qJwqcwRMpeYAooRYIriMPXuNrQErHZuAQsbmKYoo3D7oum-5zvqFjZlP77FXRFg56nh-1Ie9oWSBAPeS7-NUe70kSI-3XJ_Ce97vHA0OQcqEKhE0STA4FhfJ-bkteG7lb2xAVJWcLPtIJalJjJuhE2nrgA4rrcQbs6cJPk2-sbuJw76SARx" />
    </picture>
  </a>
</p>

<p align="center">
  <strong>Mac Sai, topluluk tarafından topluluk için geliştirilmiş özgür bir yazılımdır.</strong><br>
  Sizi bir abonelikten kurtardıysa, bir ⭐ başkalarının onu bulmasına yardımcı olur, bir <a href="https://buymeacoffee.com/iliyami">kahve ☕</a> ise projenin sürmesini sağlar.
</p>
