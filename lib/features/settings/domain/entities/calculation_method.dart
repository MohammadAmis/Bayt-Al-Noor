import 'package:adhan/adhan.dart' as adhan;

/// ✅ Prayer calculation methods with user-friendly metadata
enum CalculationMethodOption {
  muslimWorldLeague,   // MWL - Most common globally
  egyptian,            // Egypt, parts of Africa
  karachi,             // Pakistan, India, Bangladesh
  ummAlQura,           // Saudi Arabia (Makkah)
  dubai,               // UAE, Oman
  qatar,               // Qatar
  kuwait,              // Kuwait
  tehran,              // Iran
  northAmerica,        // ISNA - North America
  kuwaitCivil,         // Kuwait Civil
  singapore,           // Singapore
  turkey,              // Turkey
  other;               // Custom parameters

  /// Display name for UI
  String get displayName {
    switch (this) {
      case muslimWorldLeague: return 'Muslim World League';
      case egyptian: return 'Egyptian General Authority';
      case karachi: return 'University of Islamic Sciences, Karachi';
      case ummAlQura: return 'Umm Al-Qura University, Makkah';
      case dubai: return 'Dubai';
      case qatar: return 'Qatar';
      case kuwait: return 'Kuwait';
      case tehran: return 'Institute of Geophysics, Tehran';
      case northAmerica: return 'Islamic Society of North America (ISNA)';
      case kuwaitCivil: return 'Kuwait (Civil)';
      case singapore: return 'Majlis Ugama Islam, Singapore';
      case turkey: return 'Diyanet İşleri Başkanlığı, Turkey';
      case other: return 'Custom Method';
    }
  }

  /// Short code for storage/API
  String get code {
    switch (this) {
      case muslimWorldLeague: return 'MWL';
      case egyptian: return 'EGYPT';
      case karachi: return 'KARACHI';
      case ummAlQura: return 'UMMALQURA';
      case dubai: return 'DUBAI';
      case qatar: return 'QATAR';
      case kuwait: return 'KUWAIT';
      case tehran: return 'TEHRAN';
      case northAmerica: return 'NORTH_AMERICA';
      case kuwaitCivil: return 'KUWAIT_CIVIL';
      case singapore: return 'SINGAPORE';
      case turkey: return 'TURKEY';
      case other: return 'OTHER';
    }
  }

  /// Convert from adhan.CalculationMethod
  static CalculationMethodOption fromAdhan(adhan.CalculationMethod method) {
    switch (method) {
      case adhan.CalculationMethod.muslim_world_league:
        return muslimWorldLeague;
      case adhan.CalculationMethod.egyptian:
        return egyptian;
      case adhan.CalculationMethod.karachi:
        return karachi;
      case adhan.CalculationMethod.umm_al_qura:
        return ummAlQura;
      case adhan.CalculationMethod.dubai:
        return dubai;
      case adhan.CalculationMethod.qatar:
        return qatar;
      case adhan.CalculationMethod.kuwait:
        return kuwait;
      case adhan.CalculationMethod.tehran:
        return tehran;
      case adhan.CalculationMethod.north_america:
        return northAmerica;
      default:
        return other;
    }
  }

  /// Convert to adhan.CalculationMethod
  adhan.CalculationMethod toAdhan() {
    switch (this) {
      case muslimWorldLeague: return adhan.CalculationMethod.muslim_world_league;
      case egyptian: return adhan.CalculationMethod.egyptian;
      case karachi: return adhan.CalculationMethod.karachi;
      case ummAlQura: return adhan.CalculationMethod.umm_al_qura;
      case dubai: return adhan.CalculationMethod.dubai;
      case qatar: return adhan.CalculationMethod.qatar;
      case kuwait: return adhan.CalculationMethod.kuwait;
      case tehran: return adhan.CalculationMethod.tehran;
      case northAmerica: return adhan.CalculationMethod.north_america;
      default: return adhan.CalculationMethod.muslim_world_league; // Fallback
    }
  }

  /// Recommended regions for this method
  String get recommendedRegions {
    switch (this) {
      case muslimWorldLeague: return 'Europe, Africa, Americas, parts of Asia';
      case egyptian: return 'Egypt, Sudan, parts of Africa';
      case karachi: return 'Pakistan, India, Bangladesh';
      case ummAlQura: return 'Saudi Arabia';
      case dubai: return 'UAE, Oman';
      case qatar: return 'Qatar';
      case kuwait: return 'Kuwait';
      case tehran: return 'Iran';
      case northAmerica: return 'United States, Canada';
      case kuwaitCivil: return 'Kuwait (civil calculations)';
      case singapore: return 'Singapore, Malaysia';
      case turkey: return 'Turkey';
      default: return 'Custom configuration';
    }
  }
}