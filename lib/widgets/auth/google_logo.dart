import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _googleSvg,
      width: size,
      height: size,
    );
  }
}

const String _googleSvg = '''
<svg width="18" height="18" viewBox="0 0 18 18" xmlns="http://www.w3.org/2000/svg">
  <path fill="#4285F4" d="M17.64 9.2045c0-.638-.057-1.252-.164-1.838H9v3.48h4.844a4.14 4.14 0 0 1-1.797 2.72v2.26h2.907c1.7-1.566 2.686-3.874 2.686-6.622z"/>
  <path fill="#34A853" d="M9 18c2.43 0 4.467-.806 5.956-2.173l-2.907-2.26c-.806.54-1.84.86-3.049.86-2.344 0-4.328-1.584-5.036-3.71H.956v2.332A8.997 8.997 0 0 0 9 18z"/>
  <path fill="#FBBC05" d="M3.964 10.717a5.399 5.399 0 0 1-.282-1.717c0-.596.103-1.177.282-1.717V4.95H.956A9 9 0 0 0 0 9c0 1.452.348 2.828.956 4.05l3.008-2.333z"/>
  <path fill="#EA4335" d="M9 3.58c1.32 0 2.507.454 3.44 1.346l2.58-2.58C13.463.895 11.426 0 9 0 5.5 0 2.48 1.99.956 4.95l3.008 2.333C4.672 5.157 6.656 3.58 9 3.58z"/>
</svg>
''';

