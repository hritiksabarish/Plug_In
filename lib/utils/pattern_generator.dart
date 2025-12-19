
import 'dart:math';

class PatternGenerator {
  static String generateRandomSvgPattern(String seedKey) {
    final random = Random(seedKey.hashCode);
    
    // Expanded Vibrant Palettes
    final palettes = [
      ['#FF6B6B', '#4ECDC4', '#556270', '#C44D58', '#FF9F1C'], // Sunset
      ['#A8E6CF', '#DCEDC1', '#FFD3B6', '#FFAAA5', '#FF8B94'], // Pastel
      ['#2C3E50', '#E74C3C', '#ECF0F1', '#3498DB', '#2980B9'], // Professional
      ['#8E44AD', '#3498DB', '#2ECC71', '#F1C40F', '#E67E22'], // Vivid
      ['#1A1A1D', '#4E4E50', '#6F2232', '#950740', '#C3073F'], // Dark Red
      ['#FE4A49', '#2AB7CA', '#FED766', '#E6E6EA', '#F4F4F8'], // Pop
    ];

    final palette = palettes[random.nextInt(palettes.length)];
    final bgColor = palette[0];
    
    // Base SVG
    String svgContent = '''
<svg width="100%" height="100%" viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="blurMe">
      <feGaussianBlur in="SourceGraphic" stdDeviation="2" />
    </filter>
  </defs>
  <rect width="400" height="200" fill="$bgColor" />
''';

    // Velocity & Chaos: Generate 20-30 shapes
    final shapeCount = random.nextInt(15) + 20;

    for (int i = 0; i < shapeCount; i++) {
        final shapeType = random.nextInt(5); // 0-4
        final color = palette[random.nextInt(palette.length)];
        final opacity = (random.nextDouble() * 0.4 + 0.1).toStringAsFixed(2); // Lower opacity for layering
        
        // Random Transform
        final x = random.nextInt(450) - 25;
        final y = random.nextInt(250) - 25;
        final scale = (random.nextDouble() * 1.5 + 0.5);
        final rotation = random.nextInt(360);
        
        if (shapeType == 0) {
            // Circle bubbles
            final r = random.nextInt(60) + 10;
            svgContent += '<circle cx="$x" cy="$y" r="${r * scale}" fill="$color" fill-opacity="$opacity" />';
        } else if (shapeType == 1) {
             // Dynamic Lines (Simulating velocity)
             final x2 = x + (random.nextInt(200) - 100);
             final y2 = y + (random.nextInt(100) - 50);
             final strokeWidth = random.nextInt(5) + 1;
             svgContent += '<line x1="$x" y1="$y" x2="$x2" y2="$y2" stroke="$color" stroke-width="$strokeWidth" stroke-opacity="$opacity" stroke-linecap="round" />';
        } else if (shapeType == 2) {
            // Rectangles (Rotated)
            final w = random.nextInt(120) + 20;
            final h = random.nextInt(120) + 20;
            svgContent += '<rect x="$x" y="$y" width="$w" height="$h" fill="$color" fill-opacity="$opacity" transform="rotate($rotation ${x + w/2} ${y + h/2})" rx="10" />';
        } else if (shapeType == 3) {
             // Triangles / Polygons
             final p1 = '$x,$y';
             final p2 = '${x + random.nextInt(80) - 40},${y + random.nextInt(80) + 20}';
             final p3 = '${x - random.nextInt(80) + 40},${y + random.nextInt(80) + 20}';
             svgContent += '<polygon points="$p1 $p2 $p3" fill="$color" fill-opacity="$opacity" transform="rotate($rotation $x $y)" />';
        } else {
            // "Velocity Swish" (Bezier Curve)
             final c1x = x + 50;
             final c1y = y - 50;
             final c2x = x + 100;
             final c2y = y + 50;
             final ex = x + 150;
             final ey = y;
             svgContent += '<path d="M$x $y C$c1x $c1y, $c2x $c2y, $ex $ey" stroke="$color" stroke-width="4" fill="none" stroke-opacity="$opacity" />';
        }
        svgContent += '\n';
    }
    
    svgContent += '</svg>';
    return svgContent;
  }
}
