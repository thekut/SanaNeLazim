enum TierLevel {
  basic,
  pro,
  advisor,
}

extension TierLevelExtension on TierLevel {
  String get title {
    switch (this) {
      case TierLevel.basic:
        return 'SananeLazım Basic';
      case TierLevel.pro:
        return 'SananeLazım Pro';
      case TierLevel.advisor:
        return 'SananeLazım Danışman';
    }
  }

  String get description {
    switch (this) {
      case TierLevel.basic:
        return '5 soruda hızlı finansal özgürlük tahmini.';
      case TierLevel.pro:
        return 'Detaylı analiz, 10.000 Monte Carlo simülasyonu ve Markov rejimleri.';
      case TierLevel.advisor:
        return 'Yapay zeka ile limitsiz senaryo ve kişisel finansal planlama.';
    }
  }

  int get questionCount {
    switch (this) {
      case TierLevel.basic:
        return 5;
      case TierLevel.pro:
        return 15;
      case TierLevel.advisor:
        return 0;
    }
  }
}
