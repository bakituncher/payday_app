import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:payday/core/services/ad_service.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';

class PaydayBannerAd extends ConsumerStatefulWidget {
  const PaydayBannerAd({super.key});

  @override
  ConsumerState<PaydayBannerAd> createState() => _PaydayBannerAdState();
}

class _PaydayBannerAdState extends ConsumerState<PaydayBannerAd> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Eğer reklam zaten yüklendiyse veya yükleniyorsa tekrar yükleme
    if (_isAdLoaded || _bannerAd != null) return;

    // Premium kontrolü: Widget build edildikten sonra provider'a erişelim
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium) return;

    final adUnitId = AdService().bannerAdUnitId;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    await _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Anlık Premium durumu dinleniyor
    final isPremium = ref.watch(isPremiumProvider);

    // Eğer kullanıcı Premium ise veya reklam yüklenmediyse boş döndür
    if (isPremium || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}