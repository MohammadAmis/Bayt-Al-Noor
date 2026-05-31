
class AppSvgs {
  /// Premium Kufic Style Logo for "Bayt Al-Noor"
  /// Stylized geometric representation of 'بيت النور'
  static const String logo = '''
<svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
  <!-- Outer Frame -->
  <rect x="10" y="10" width="180" height="180" rx="40" stroke="currentColor" stroke-width="2" stroke-dasharray="8 4"/>
  
  <!-- Kufic Calligraphy Path (Simplified Stylized Version) -->
  <!-- This represents a geometric "Bayt Al-Noor" -->
  <path d="M50 150V50H70V130H90V50H110V130H130V50H150V150H50Z" fill="currentColor" fill-opacity="0.9"/>
  <path d="M70 160H130V180H70V160Z" fill="currentColor"/>
  
  <!-- Dot Accents (Noor/Light) -->
  <circle cx="100" cy="30" r="6" fill="currentColor"/>
  <circle cx="130" cy="30" r="4" fill="currentColor" fill-opacity="0.5"/>
  <circle cx="70" cy="30" r="4" fill="currentColor" fill-opacity="0.5"/>
  
  <!-- Spiritual Glow Effect -->
  <defs>
    <radialGradient id="paint0_radial" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="translate(100 100) rotate(90) scale(100)">
      <stop stop-color="currentColor" stop-opacity="0.2"/>
      <stop offset="1" stop-color="currentColor" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <circle cx="100" cy="100" r="100" fill="url(#paint0_radial)"/>
</svg>
''';

  /// A more intricate version if needed
  static const String logoIntricate = '''
<svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M40 160V40H60V140H80V40H100V140H120V40H140V140H160V160H40Z" fill="currentColor"/>
  <rect x="60" y="20" width="10" height="10" fill="currentColor"/>
  <rect x="130" y="20" width="10" height="10" fill="currentColor"/>
</svg>
''';
}
