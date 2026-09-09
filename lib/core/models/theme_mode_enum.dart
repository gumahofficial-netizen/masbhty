enum CounterSkin {
  electronicRing,
  traditionalBeads,
  crystalBeads,
  amberBeads,
  minimalistDigital,
}

extension CounterSkinExtension on CounterSkin {
  String get nameAr {
    switch (this) {
      case CounterSkin.electronicRing:
        return 'الخاتم الإلكتروني';
      case CounterSkin.traditionalBeads:
        return 'المسبحة الخشبية';
      case CounterSkin.crystalBeads:
        return 'المسبحة الكريستالية';
      case CounterSkin.amberBeads:
        return 'المسبحة الكهرمانية';
      case CounterSkin.minimalistDigital:
        return 'العداد الرقمي الحديث';
    }
  }

  String get nameEn {
    switch (this) {
      case CounterSkin.electronicRing:
        return 'Electronic Ring';
      case CounterSkin.traditionalBeads:
        return 'Wooden Beads';
      case CounterSkin.crystalBeads:
        return 'Crystal Beads';
      case CounterSkin.amberBeads:
        return 'Amber Beads';
      case CounterSkin.minimalistDigital:
        return 'Minimalist Digital';
    }
  }
}
