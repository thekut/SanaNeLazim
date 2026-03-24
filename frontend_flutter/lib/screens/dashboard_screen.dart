import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/app_colors.dart';
import '../core/enums/tier_level.dart';
import '../providers/user_data_provider.dart';

class DashboardScreen extends StatefulWidget {
  final TierLevel tier;
  final http.Client? httpClient;

  const DashboardScreen({super.key, required this.tier, this.httpClient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<Map<String, dynamic>>? _calculationFuture;

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz Python Backend'ine veri gönder!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userData = Provider.of<UserDataProvider>(context, listen: false);
      setState(() {
        _calculationFuture = _fetchCalculationFromBackend(userData);
      });
    });
  }

  Future<Map<String, dynamic>> _fetchCalculationFromBackend(UserDataProvider data) async {
    final url = Uri.parse('http://127.0.0.1:8000/calculate'); // Python Motorumuzun Adresi
    
    final requestBody = {
      "currentAge": data.currentAge,
      "deathAge": data.deathAge,
      "monthlyIncome": data.monthlyIncome,
      "monthlyExpense": data.monthlyExpense,
      "totalSavings": data.totalSavings,
      "stockRatio": data.stockRatio,
      "goldRatio": data.goldRatio,
      "besRatio": data.besRatio,
      "careHomeBudget": data.careHomeBudget,
      "legacyTarget": data.legacyTarget,
    };

    final headers = {"Content-Type": "application/json"};
    final body = json.encode(requestBody);

    final response = widget.httpClient != null
        ? await widget.httpClient!.post(url, headers: headers, body: body)
        : await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Backend bağlantı hatası: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue), onPressed: () => Navigator.pop(context)),
        title: const Text('Simülasyon Sonucu', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _calculationFuture == null 
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>>(
              future: _calculationFuture,
              builder: (context, snapshot) {
                // Yüklenirken (Python hesaplarken)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                        SizedBox(height: 16),
                        Text('Python Motoru Hesaplarken Lütfen Bekleyin...', style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  );
                } 
                // Hata olursa
                else if (snapshot.hasError) {
                  return Center(child: Text('Sunucu Kapalı veya Hata: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                } 
                // Python'dan cevap gelirse!
                else if (snapshot.hasData) {
                  final result = snapshot.data!;
                  final freedomAge = result['freedomAge'] as int;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMainResultCard(freedomAge),
                        const SizedBox(height: 24),
                        const Text('Ne Yapmalıyım?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                        const SizedBox(height: 16),
                        _buildActionableInsights(context, userData, result),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
          ),
      ),
    );
  }

  Widget _buildMainResultCard(int age) {
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
          Text(age >= 99 ? 'Çok Zor' : '$age', style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold, height: 1.0)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(30)),
            child: Text(widget.tier == TierLevel.basic ? 'Python API Bağlantısı' : 'Backend Motoru Hesapladı', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableInsights(BuildContext context, UserDataProvider data, Map<String, dynamic> result) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double savingRate = data.monthlyIncome > 0 ? ((data.monthlyIncome - data.monthlyExpense) / data.monthlyIncome) * 100 : 0;
    final target = result['targetNestEgg'] as double;
    
    return Column(
      children: [
        _buildInsightRow(Icons.savings_rounded, AppColors.successGreen, 'Tasarruf Oranı', 'Aylık gelirinizin %${savingRate.toStringAsFixed(0)}\'sini yatırıyorsunuz.', isDark),
        const SizedBox(height: 12),
        _buildInsightRow(Icons.flag_rounded, AppColors.warningOrange, 'Hedef Büyüklük', 'Ulaşmanız gereken toplam portföy: ${target.toInt()} TL.', isDark),
        const SizedBox(height: 12),
        _buildInsightRow(Icons.api_rounded, AppColors.primaryBlue, 'Python AI Bağlantısı', 'Bu veriler lokalde değil, backend sunucusunda işlendi.', isDark),
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
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
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