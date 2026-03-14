import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/enums/tier_level.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                  size: 80,
                  color: AppColors.primaryBlue
                ),
                const SizedBox(height: 32),
                const Text(
                  'SananeLazım',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ne zaman emekli olabileceğinizi ve finansal özgürlüğünüze nasıl ulaşacağınızı 5 soruda keşfedin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5
                  ),
                ),
                const SizedBox(height: 48),
                _buildTierCard(
                  context: context,
                  tier: TierLevel.basic,
                  icon: Icons.flash_on_rounded,
                  isPrimary: true,
                ),
                const SizedBox(height: 16),
                _buildTierCard(
                  context: context,
                  tier: TierLevel.pro,
                  icon: Icons.analytics_rounded,
                  isPrimary: false,
                ),
                const SizedBox(height: 16),
                _buildTierCard(
                  context: context,
                  tier: TierLevel.advisor,
                  icon: Icons.auto_awesome_rounded,
                  isPrimary: false,
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard({
    required BuildContext context,
    required TierLevel tier,
    required IconData icon,
    bool isPrimary = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isPrimary
        ? AppColors.primaryBlue
        : (isDark ? AppColors.surfaceDark : Colors.white);
    final textColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white : Colors.black);
    final borderColor = isPrimary
        ? Colors.transparent
        : (isDark ? Colors.white24 : Colors.black12);

    return InkWell(
      onTap: () {
        // TODO: Navigate to Input Wizard
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tier.title} seçildi. Sihirbaz ekranı hazırlanıyor...')),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tier.title,
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tier.description,
                    style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13)
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textColor.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
