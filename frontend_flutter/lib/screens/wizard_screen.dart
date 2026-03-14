import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/enums/tier_level.dart';
import 'dashboard_screen.dart';

class WizardScreen extends StatefulWidget {
  final TierLevel tier;
  const WizardScreen({super.key, required this.tier});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  double _stockSlider = 40;
  double _goldSlider = 30;
  double _besSlider = 30;

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardScreen(tier: widget.tier)));
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue), onPressed: _prevPage),
        title: LinearProgressIndicator(
          value: (_currentPage + 1) / 5,
          backgroundColor: AppColors.textSecondaryLight.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _buildQuestionPage('Ülkeniz neresi?', 'Enflasyon ve devlet katkılarını (BES) doğru hesaplamak için gereklidir.', Icons.public, _buildCountrySelector()),
                  _buildQuestionPage('Yaşınız kaç?', 'Tahmini vefat yaşınızı da göz önünde bulundurarak aktüeryal hesaplama yapacağız.', Icons.cake, _buildAgeInputs()),
                  _buildQuestionPage('Finansal Durumunuz', 'Aylık net geliriniz ve gideriniz.', Icons.account_balance, _buildFinancialInputs()),
                  _buildQuestionPage('Portföy Dağılımınız', 'Mevcut varlıklarınızın basit dağılımı.', Icons.pie_chart, _buildPortfolioSliders()),
                  _buildQuestionPage('Gelecek Hedefleri', '70+ yaş bakım evi bütçesi ve miras.', Icons.health_and_safety, _buildGoalInputs()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == 4 ? 'Sonuçları Gör' : 'Devam Et', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(String title, String subtitle, IconData icon, Widget inputSection) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: AppColors.primaryBlue),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), height: 1.4)),
          const SizedBox(height: 32),
          Expanded(child: SingleChildScrollView(child: inputSection)),
        ],
      ),
    );
  }

  Widget _buildCountrySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryBlue)),
      child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🇹🇷 Türkiye (Varsayılan)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), Icon(Icons.check_circle, color: AppColors.primaryBlue)]),
    );
  }

  Widget _buildAgeInputs() {
    return Column(children: [
      TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mevcut Yaşınız (örn. 35)')),
      const SizedBox(height: 16),
      TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tahmini Vefat Yaşınız :(')),
    ]);
  }

  Widget _buildFinancialInputs() {
    return Column(children: [
      TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aylık Net Geliriniz (TL)', prefixIcon: Icon(Icons.trending_up, color: AppColors.successGreen))),
      const SizedBox(height: 16),
      TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aylık Gideriniz (TL)', prefixIcon: Icon(Icons.trending_down, color: AppColors.errorRed))),
    ]);
  }

  Widget _buildPortfolioSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Toplam Birikim (TL)', prefixIcon: Icon(Icons.account_balance_wallet))),
        const SizedBox(height: 32),
        Text('Hisse / Yabancı Fon: %${_stockSlider.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(value: _stockSlider, max: 100, activeColor: AppColors.primaryBlue, onChanged: (val) => setState(() => _stockSlider = val)),
        Text('Altın / Döviz: %${_goldSlider.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(value: _goldSlider, max: 100, activeColor: AppColors.warningOrange, onChanged: (val) => setState(() => _goldSlider = val)),
        Text('BES (Devlet Katkılı): %${_besSlider.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(value: _besSlider, max: 100, activeColor: AppColors.successGreen, onChanged: (val) => setState(() => _besSlider = val)),
      ],
    );
  }

  Widget _buildGoalInputs() {
    return Column(children: [
      TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '70+ Yaş Aylık Bakım Evi (TL)', helperText: 'Varsayılan: 200.000 TL (Günümüz fiyatlarıyla)')),
      const SizedBox(height: 16),
      TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bırakılacak Miras (TL)', helperText: 'Tüm birikiminizi kendi yaşamınızda kullanmak istiyorsanız 0 bırakın.')),
    ]);
  }
}
