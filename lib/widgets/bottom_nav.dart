import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

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
    double height = 60;

    return Container(
      width: size.width,
      height: height,
      color: BrandColors.latteFoam,
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
          FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
            backgroundColor: BrandColors.caramel,
            elevation: 0,
            onPressed: onChatbotTap ?? () {},
            child: const Icon(
              CupertinoIcons.chat_bubble_2_fill,
              color: Colors.white,
            ),
          ),
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
