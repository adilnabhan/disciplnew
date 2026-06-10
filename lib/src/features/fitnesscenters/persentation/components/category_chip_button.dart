import 'package:customer_mobile_app/imports_bindings.dart';

class CategoryChipButton extends StatelessWidget {
  const CategoryChipButton({required this.onTap, required this.isSelected, required this.text, super.key});

  final bool isSelected;
  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99999),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(25) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary.withAlpha(25) : const Color(0xFFEEEEEE), width: 1.5),
        ),
        child: Text(text, style: AppStyles.text16Px.poppins.copyWith(color: isSelected ? AppColors.primary : AppColors.textGrey, fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400)),
      ),
    );
  }
}
