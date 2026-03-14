import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/enums/tier_level.dart';

class DashboardScreen extends StatelessWidget {
  final TierLevel tier;
  const DashboardScreen({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Simülasyon Sonucu', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMainResultCard(context),
              const SizedBox(height: 24),
              const Text('Ne Yapmalıyım?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(height: 16),
              _buildActionableInsights(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainResultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF004499)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text('Finansal Özgürlük Yaşınız', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('54', style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold, height: 1.0)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
            child: const Text('%95 Başarı Olasılığı (Monte Carlo)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableInsights(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _buildInsightRow(Icons.savings_rounded, AppColors.successGreen, 'Tasarruf Oranı', 'Aylık gelirinizin %26\'sını yatırıma yönlendirin.', isDark),
        const SizedBox(height: 12),
        _buildInsightRow(Icons.shield_rounded, AppColors.warningOrange, 'Rejim Koruması', 'Yüksek enflasyon riskine karşı Altın oranını %28\'de tutun.', isDark),
        const SizedBox(height: 12),
        _buildInsightRow(Icons.elderly_rounded, AppColors.primaryBlue, 'Bakım Evi Hedefi', '70 yaş sonrası 200.000 TL reel harcama güvenle karşılanıyor.', isDark),
      ],
    );
  }

  Widget _buildInsightRow(IconData icon, Color iconColor, String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
