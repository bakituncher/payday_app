# Para Birimi Yönetimi - Merkezi Sistem

## 📌 Genel Bakış

Para birimi yönetimi artık **tek bir merkezi sistemden** yönetiliyor. Tüm uygulama genelinde tutarlı para birimi gösterimi sağlanıyor.

**🎯 Önemli:** `currency_picker` paketi kullanılarak **doğru semboller** gösteriliyor:
- ✅ TRY → **₺** (TL değil!)
- ✅ USD → **$**
- ✅ EUR → **€**
- ✅ GBP → **£**

## 🏗️ Mimari

### 1. **CurrencyFormatter** (Core Utility)
📁 `lib/core/utils/currency_formatter.dart`

**Görevleri:**
- ✅ Para birimi formatlaması
- ✅ **`currency_picker` paketinden doğru semboller** (₺, €, $ vs.)
- ✅ Cihazın yerel ayarlarından otomatik para birimi seçimi
- ✅ **`currency_picker`'dan ondalık basamak sayısı** (otomatik)

**Önemli Metodlar:**
```dart
// Para birimi formatla
CurrencyFormatter.format(1000.00, 'TRY') → "₺1,000.00"  // ₺ sembolü!
CurrencyFormatter.format(1000.00, 'USD') → "$1,000.00"

// Para birimi sembolü al (currency_picker'dan)
CurrencyFormatter.getSymbol('TRY') → "₺"  // Artık ₺ döndürüyor!
CurrencyFormatter.getSymbol('USD') → "$"
CurrencyFormatter.getSymbol('QAR') → "﷼"  // Katar Riyali

// Cihaz para birimini al
CurrencyFormatter.getLocalCurrencyCode() → "TRY" // Türkiye'de
```

### 2. **currency_picker Paketi**
📦 `currency_picker: ^2.0.21`

**Neden currency_picker?**
- ✅ 150+ dünya para birimiyle önceden yüklenmiş
- ✅ **Doğru Unicode semboller** (₺, €, £, ¥, ₹ vs.)
- ✅ Bayrak emojileri dahil
- ✅ Otomatik ondalık basamak yönetimi
- ✅ Para birimi isimlerini yerelleştirilmiş olarak sağlar

**Intl vs currency_picker:**
| Özellik | Intl | currency_picker |
|---------|------|-----------------|
| TRY Sembolü | ❌ "TL" | ✅ "₺" |
| EUR Sembolü | ✅ "€" | ✅ "€" |
| USD Sembolü | ✅ "$" | ✅ "$" |
| Bayraklar | ❌ Yok | ✅ Var |
| Ondalık Basamak | Manuel | ✅ Otomatik |

### 2. **Currency Providers** (Centralized State)
📁 `lib/core/providers/currency_providers.dart`

**Görevleri:**
- ✅ Kullanıcının seçili para birimini global state olarak yönetme
- ✅ Async ve sync provider'lar
- ✅ Kolay erişim için helper fonksiyonlar

**Provider'lar:**
```dart
// Async providers (Future)
currentCurrencyCodeProvider → FutureProvider<String>
currentCurrencySymbolProvider → FutureProvider<String>

// Sync providers (hemen erişim)
syncCurrencyCodeProvider → Provider<String>
syncCurrencySymbolProvider → Provider<String>

// Helper fonksiyonlar
formatWithUserCurrency(ref, 1000.0) → kullanıcının para birimiyle formatlar
getUserCurrencySymbol(ref) → kullanıcının para birimi sembolü
```

## 🎯 Kullanım Örnekleri

### Settings Ekranında
```dart
final currencySymbol = CurrencyFormatter.getSymbol(_selectedCurrency);
TextField(
  decoration: InputDecoration(
    prefixText: currencySymbol, // ₺, $, €, etc.
  ),
)
```

### Premium Paywall Ekranında
```dart
String _getLocalizedPrice(double usdPrice) {
  final currencyCode = ref.read(syncCurrencyCodeProvider);
  final currencySymbol = ref.read(syncCurrencySymbolProvider);
  
  // Conversion rates
  final rate = conversionRates[currencyCode] ?? 1.0;
  final convertedPrice = usdPrice * rate;
  
  return '$currencySymbol${convertedPrice.toStringAsFixed(2)}';
}
```

### Onboarding Ekranında
```dart
@override
void initState() {
  super.initState();
  // Otomatik para birimi seçimi
  _selectedCurrency = CurrencyFormatter.getLocalCurrencyCode();
}

// Maaş input'unda
Text(
  CurrencyFormatter.getSymbol(_selectedCurrency),
  style: TextStyle(color: AppColors.primaryPink),
)
```

### Transaction Listesinde
```dart
Text(
  CurrencyFormatter.format(transaction.amount, currency),
  style: TextStyle(fontWeight: FontWeight.bold),
)
```

## 🌍 Desteklenen Para Birimleri

### Otomatik Destek (Intl Paketi Sayesinde)
Tüm ISO 4217 para birimleri destekleniyor:

**Popüler Para Birimleri:**
- 🇺🇸 USD - US Dollar ($)
- 🇪🇺 EUR - Euro (€)
- 🇬🇧 GBP - British Pound (£)
- 🇹🇷 TRY - Turkish Lira (TL)
- 🇯🇵 JPY - Japanese Yen (¥)
- 🇮🇳 INR - Indian Rupee (₹)
- 🇨🇦 CAD - Canadian Dollar (CA$)
- 🇦🇺 AUD - Australian Dollar (A$)

**Orta Doğu:**
- 🇶🇦 QAR - Qatari Riyal (QR)
- 🇦🇪 AED - UAE Dirham (د.إ)
- 🇸🇦 SAR - Saudi Riyal (SR)
- 🇸🇾 SYP - Syrian Pound (£S)
- 🇰🇼 KWD - Kuwaiti Dinar (KD)

**Diğer:**
- 🇧🇷 BRL - Brazilian Real (R$)
- 🇳🇬 NGN - Nigerian Naira (₦)
- 🇿🇦 ZAR - South African Rand (R)
- 🇨🇳 CNY - Chinese Yuan (¥)
- 🇰🇷 KRW - Korean Won (₩)
- 🇷🇺 RUB - Russian Ruble (₽)
- 🇲🇽 MXN - Mexican Peso ($)

**Toplam: 150+ Para Birimi**

## 🔄 Migration Süreci

### Eski Sistem → Yeni Sistem

**Önce:**
```dart
// ❌ Her yerde farklı implementasyon
CurrencyUtilityService().findByCode('USD')?.symbol ?? '\$'
'TL' // Hardcoded
'\$9.99' // Hardcoded
```

**Şimdi:**
```dart
// ✅ Tek merkezi sistem
CurrencyFormatter.getSymbol('USD')
CurrencyFormatter.getSymbol(_selectedCurrency)
_getLocalizedPrice(9.99)
```

## 📊 Conversion Rates (Premium Paywall)

Premium ekranında fiyatlar kullanıc��nın para birimine dönüştürülüyor:

```dart
final conversionRates = {
  'USD': 1.0,
  'EUR': 0.92,
  'GBP': 0.79,
  'TRY': 32.50,
  'CAD': 1.36,
  'AUD': 1.53,
  'JPY': 149.0,
  'INR': 83.0,
};
```

**Not:** Gerçek uygulamada bir exchange rate API kullanılmalı.

## 🎨 Özel Ondalık Basamak Sayıları

Bazı para birimleri özel formatlar kullanır:

```dart
// 0 ondalık
JPY, KRW, VND, CLP, ISK
¥1000 (not ¥1000.00)

// 3 ondalık
BHD, IQD, JOD, KWD, OMR, TND
KD 1.000 (not KD 1.00)

// 2 ondalık (varsayılan)
USD, EUR, GBP, TRY, etc.
$1000.00
```

## ✅ Avantajlar

1. ✅ **Tek Kaynak Gerçeği** - Tüm para birimi işlemleri tek yerden
2. ✅ **Tutarlılık** - Uygulama genelinde aynı format
3. ✅ **Kolay Bakım** - Değişiklikler tek yerde yapılıyor
4. ✅ **Global Destek** - 150+ para birimi otomatik destekleniyor
5. ✅ **Otomatik Seçim** - Cihaz ayarlarından otomatik para birimi
6. ✅ **Type Safety** - Riverpod ile güvenli state management
7. ✅ **Performans** - Sync provider'lar ile hızlı erişim

## 🚀 Gelecek İyileştirmeler

- [ ] Gerçek zamanlı döviz kuru API entegrasyonu
- [ ] Para birimi geçmişi (historical rates)
- [ ] Kullanıcı tercihine göre format özelleştirme
- [ ] Kripto para birimleri desteği
- [ ] Offline rate caching

## 📝 Notlar

- Premium fiyatlandırma için gerçek bir ödeme sistemi (RevenueCat, In-App Purchase) entegre edilmeli
- Döviz kurları güncel tutulmalı (günlük API call)
- Currency picker UI'ı düzenli olarak güncellenmeli

---

**Son Güncelleme:** 17 Aralık 2024
**Versiyon:** 2.0.0

