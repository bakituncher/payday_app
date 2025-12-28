import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:payday/features/premium/providers/premium_providers.dart';

class PaydayBannerAd extends ConsumerStatefulWidget {
  final String adUnitId;
  const PaydayBannerAd({super.key, required this.adUnitId});

  @override
  ConsumerState<PaydayBannerAd> createState() => _PaydayBannerAdState();
}

class _PaydayBannerAdState extends ConsumerState<PaydayBannerAd> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Eğer reklam zaten yüklendiyse veya yükleniyorsa tekrar yükleme
    if (_isAdLoaded || _bannerAd != null) return;

    // Premium kontrolü
    final isPremium = ref.read(isPremiumProvider);
    if (isPremium) return;

    final adUnitId = widget.adUnitId;
    if (adUnitId.isEmpty) return;

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
          _bannerAd = null;
        },
      ),
    );

    await _bannerAd?.load();
  }

  @override
  void didUpdateWidget(covariant PaydayBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isAdLoaded = false;
      _loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

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