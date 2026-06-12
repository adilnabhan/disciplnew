import 'package:customer_mobile_app/imports_bindings.dart';

class PopButton extends StatelessWidget {
  const PopButton({this.onPressed, super.key});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (Navigator.canPop(context) == false) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: Color(0xFF444444),
          size: 24,
        ),
      ),
    );
  }
}
