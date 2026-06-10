import 'package:customer_mobile_app/imports_bindings.dart';

class CustomTextField extends StatefulWidget {
  final void Function()? onTap;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final String? hintText;
  final bool isPasswordType;
  final int? maxLength;
  final int? maxLine;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextStyle? hintStyle;
  final bool readonly;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final bool filled;
  final Color? fillColor;
  final Widget? prefixIcon;
  final TextAlign textAlign;

  const CustomTextField({
    super.key,
    this.controller,
    this.onSaved,
    this.onTap,
    this.onChanged,
    this.hintText,
    this.keyboardType,
    this.hintStyle,
    this.maxLine,
    this.validator,
    this.suffixIcon,
    this.focusNode,
    this.prefixIcon,
    this.isPasswordType = false,
    this.readonly = false,
    this.maxLength,
    this.fillColor = const Color(0xFFF5F5F5),
    this.textAlign = TextAlign.start,
    this.filled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: AppColors.primary,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onSaved: widget.onSaved,
      readOnly: widget.readonly,
      focusNode: widget.focusNode,
      style: TextStyle(
        fontFamily: "poppins",
        color: const Color(0xFF1E1E1E),
        fontWeight: FontWeight.w300,
        fontSize: 16.sp,
      ),
      maxLength: widget.maxLength,
      maxLines: widget.maxLine ?? 1,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      obscureText: widget.isPasswordType ? _obscureText : false,
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        isDense: true, // ✅ makes it compact
        counter: const SizedBox.shrink(),
        fillColor: widget.fillColor,
        filled: widget.filled,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 9, // ✅ reduced vertical padding
          horizontal: 10,
        ),
        constraints: const BoxConstraints(
          minHeight: 34, // ✅ smaller height
        ),
        hintText: widget.hintText,
        hintStyle:
            widget.hintStyle ??
            TextStyle(
              fontFamily: "poppins",
              color: const Color(0xFF1E1E1E),
              fontWeight: FontWeight.w300,
              fontSize: 16.sp,
            ),
        suffixIconConstraints: const BoxConstraints(maxHeight: 40),
        prefixIcon: widget.prefixIcon,
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:
              widget.suffixIcon ??
              (widget.isPasswordType
                  ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFFB5B5B5),
                      size: 18, // ✅ smaller icon
                    ),
                  )
                  : null),
        ),
        errorStyle: const TextStyle(
          fontSize: 0.01, // ✅ prevents height jump on error
          height: 0.01,
        ),
        errorMaxLines: 1,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF9F9F9F),
            width: 0.8, // ✅ thinner line
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF9F9F9F), width: 0.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 0.8, // ✅ keep border width consistent
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.disabledButton,
            width: 0.8,
          ),
        ),
      ),
    );
  }
}
