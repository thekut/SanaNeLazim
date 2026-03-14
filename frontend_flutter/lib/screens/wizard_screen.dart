import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/enums/tier_level.dart';

class WizardScreen extends StatefulWidget {
  final TierLevel tier;
  const WizardScreen({super.key, required this.tier});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analiz ediliyor... (Dashboard\'a geçilecek)')));
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
                physics: const NeverScrollableScrollPhysics(), // Prevent manual swipe
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _buildQuestionPage('Ülkeniz neresi?', 'Enflasyon ve devlet katkılarını (BES) doğru hesaplamak için gereklidir.', Icons.public, _buildCountrySelector()),
                  _buildQuestionPage('Yaşınız kaç?', 'Tahmini vefat yaşınızı da göz önünde bulundurarak aktüeryal hesaplama yapacağız.', Icons.cake, _buildAgeInputs()),
                  _buildQuestionPage('Finansal Durumunuz', 'Aylık net geliriniz ve gideriniz (Kira dahil/hariç).', Icons.account_balance, _buildFinancialInputs()),
                  _buildQuestionPage('Portföy Dağılımınız', 'Mevcut varlıklarınızın basit dağılımı (Nasdaq, Altın, TL, BES).', Icons.pie_chart, _buildPortfolioSliders()),
                  _buildQuestionPage('Gelecek Hedefleri', '70+ yaş bakım evi bütçesi ve bırakmak istediğiniz miras hedefi.', Icons.health_and_safety, _buildGoalInputs()),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('🇹🇷 Türkiye (Varsayılan)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Icon(Icons.check_circle, color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildAgeInputs() {
    return Column(
      children: [
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mevcut Yaşınız (örn. 35)')),
        const SizedBox(height: 16),
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tahmini Vefat Yaşı (örn. 90)')),
      ],
    );
  }

  Widget _buildFinancialInputs() {
    return Column(
      children: [
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aylık Net Geliriniz (TL)', prefixIcon: Icon(Icons.attach_money))),
        const SizedBox(height: 16),
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aylık Gideriniz (TL)', prefixIcon: Icon(Icons.money_off))),
      ],
    );
  }

  Widget _buildPortfolioSliders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Toplam Birikim: 0 TL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const Text('Hisse / Yabancı Fon (Nasdaq vb.)'),
        Slider(value: 40, max: 100, activeColor: AppColors.primaryBlue, onChanged: (val) {}),
        const Text('Altın / Döviz'),
        Slider(value: 30, max: 100, activeColor: AppColors.warningOrange, onChanged: (val) {}),
        const Text('BES (Devlet Katkılı)'),
        Slider(value: 30, max: 100, activeColor: AppColors.successGreen, onChanged: (val) {}),
      ],
    );
  }

  Widget _buildGoalInputs() {
    return Column(
      children: [
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '70+ Yaş Aylık Bakım Evi Bütçesi (Reel TL)', helperText: 'Varsayılan: 200.000 TL')),
        const SizedBox(height: 16),
        TextFormField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bırakılacak Miras (TL)', helperText: 'No-bequest agresif harcama için 0 bırakın.')),
      ],
    );
  }
}
