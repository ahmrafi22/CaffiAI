import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'cart_icon_button.dart';
import '../theme/brand_colors.dart';

class BrandLogoTitle extends StatelessWidget {
  const BrandLogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'images/cafe_logo.svg',
              width: 34,
              height: 34,
              colorFilter: ColorFilter.mode(cs.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              'CaffiAI',
              style: TextStyle(
                fontFamily: 'MochiyPopPOne',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: cs.primary,
              ),
            ),
          ],
        ),
        CartIconButton(
          iconColor: BrandColors.espressoBrown,
          badgeColor: BrandColors.warmRed,
        ),
      ],
    );
  }
}
