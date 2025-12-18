import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class BottomNavCurvePainter extends CustomPainter {
  Color backgroundColor;
  double insetRadius;

  BottomNavCurvePainter({
    this.backgroundColor = BrandColors.latteFoam,
    this.insetRadius = 38,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 12);

    double insetCurveBeginnningX = size.width / 2 - insetRadius;
    double insetCurveEndX = size.width / 2 + insetRadius;
    double transitionToInsetCurveWidth = size.width * .05;

    path.quadraticBezierTo(
      size.width * 0.20,
      0,
      insetCurveBeginnningX - transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(
      insetCurveBeginnningX,
      0,
      insetCurveBeginnningX,
      insetRadius / 2,
    );

    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );

    path.quadraticBezierTo(
      insetCurveEndX,
      0,
      insetCurveEndX + transitionToInsetCurveWidth,
      0,
    );
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onChatbotTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onChatbotTap,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = 56;

    return SizedBox(
      width: size.width,
      height: height + 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(size.width, height + 7),
              painter: BottomNavCurvePainter(
                backgroundColor: BrandColors.latteFoam,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                backgroundColor: BrandColors.caramel,
                elevation: 0.1,
                onPressed: onChatbotTap ?? () {},
                child: const Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavBarIcon(
                    text: "Home",
                    icon: CupertinoIcons.home,
                    selected: currentIndex == 0,
                    onPressed: () => onTap(0),
                    defaultColor: BrandColors.mocha,
                    selectedColor: BrandColors.caramel,
                  ),
                  NavBarIcon(
                    text: "Map",
                    icon: CupertinoIcons.map,
                    selected: currentIndex == 1,
                    onPressed: () => onTap(1),
                    defaultColor: BrandColors.mocha,
                    selectedColor: BrandColors.caramel,
                  ),
                  const SizedBox(width: 56),
                  NavBarIcon(
                    text: "Community",
                    icon: CupertinoIcons.person_3,
                    selected: currentIndex == 2,
                    onPressed: () => onTap(2),
                    defaultColor: BrandColors.mocha,
                    selectedColor: BrandColors.caramel,
                  ),
                  NavBarIcon(
                    text: "Profile",
                    icon: CupertinoIcons.person,
                    selected: currentIndex == 3,
                    onPressed: () => onTap(3),
                    defaultColor: BrandColors.mocha,
                    selectedColor: BrandColors.caramel,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  final Color defaultColor;
  final Color selectedColor;

  const NavBarIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.selected,
    required this.onPressed,
    this.selectedColor = BrandColors.caramel,
    this.defaultColor = BrandColors.mocha,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: CircleAvatar(
        backgroundColor: selected ? BrandColors.cream : Colors.transparent,
        child: Icon(
          icon,
          size: 25,
          color: selected ? BrandColors.espressoBrown : defaultColor,
        ),
      ),
    );
  }
}
