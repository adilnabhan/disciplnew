import 'package:customer_mobile_app/imports_bindings.dart';

class Question extends StatelessWidget {
  final String heading;
  final Widget answer;

  Question.text({
    super.key,
    String? hintText,
    int? maxLine,
    int? maxLength,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    // fillColor? fillColor,
    bool readonly = false,
    void Function(String)? onChanged,
    void Function(String?)? onSaved,
    TextEditingController? controller,
    String? Function(String?)? validator,
    required this.heading,
    TextStyle? hintStyle,
  }) : answer = CustomTextField(
         onSaved: onSaved,
         controller: controller,
         onChanged: onChanged,
         hintText: hintText,
         maxLength: maxLength,
         maxLine: maxLine ?? 1,
         validator: validator,
         keyboardType: keyboardType,
         focusNode: focusNode,
         readonly: readonly,
         hintStyle: hintStyle,
       );

  Question.dropDown({
    super.key,
    required this.heading,
    Color? fillColor,
    BuildContext? context,
    String? value,
    String? hint,
    double? width,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    // dynamic items,
    List<DropdownMenuItem<String>>? items,
  }) : answer = SizedBox(
         width: width ?? 200,
         child: DropdownButtonFormField(
           isExpanded: true,
           autovalidateMode: AutovalidateMode.onUserInteraction,
           validator: validator,
           style: TextStyle(
             fontFamily: "poppins",
             color: const Color(0xFF1E1E1E),
             fontWeight: FontWeight.w300,
             fontSize: 16.sp,
           ),
           dropdownColor: Colors.white,
           decoration: InputDecoration(
             isDense: true, // ✅ make the field compact
             counter: const SizedBox.shrink(),
             fillColor: fillColor ?? const Color(0xFFF5F5F5),
             filled: true,
             contentPadding: const EdgeInsets.symmetric(
               horizontal: 10, // ✅ smaller padding
               vertical: 8,
             ),
             constraints: const BoxConstraints(
               minHeight: 34, // ✅ smaller dropdown height
             ),
             suffixIconConstraints: const BoxConstraints(maxHeight: 40),
             errorStyle: const TextStyle(
               fontSize: 0.01, // ✅ prevent height jump when error appears
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
               borderSide: const BorderSide(
                 color: Color(0xFF9F9F9F),
                 width: 0.8,
               ),
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
           hint: Text(
             hint ?? "",
             style: TextStyle(
               fontFamily: "poppins",
               color: const Color(0xFF1E1E1E),
               fontWeight: FontWeight.w300,
               fontSize: 16.sp,
             ),
           ),
           value: value,
           icon: Icon(
             Icons.arrow_drop_down_sharp,
             size: 18.sp, // ✅ smaller icon
             color: AppColors.primary,
           ),
           items: items,
           onChanged: onChanged,
         ),
       );

  Question.radioBtn({
    super.key,
    required this.heading,
    Color? activeColor,
    FontWeight? font,
    required List<Map<String, dynamic>> value,
    required var groupValue,
    required void Function(dynamic)? onChanged,
  }) : answer = ListView.separated(
         shrinkWrap: true,
         padding: EdgeInsets.zero,
         physics: const NeverScrollableScrollPhysics(),
         scrollDirection: Axis.vertical,
         itemCount: value.length,
         separatorBuilder: (context, index) => SizedBox(height: 8.h),
         itemBuilder: (context, index) {
           final item = value[index];
           final key = item['value'];
           final label = item['label'];

           return Row(
             children: [
               Radio(
                 activeColor: activeColor ?? AppColors.primary,
                 value: key,
                 groupValue: groupValue,
                 onChanged: onChanged,
                 visualDensity: const VisualDensity(horizontal: -4),
               ),
               Expanded(
                 child: Text(
                   label.toString(),
                   style: TextStyle(
                     fontFamily: "poppins",
                     color: const Color(0xFF1E1E1E),
                     fontWeight: font ?? FontWeight.w300,
                     fontSize: 16.sp,
                   ),
                 ),
               ),
             ],
           );
         },
       );

  Question.checkBox({
    super.key,
    required this.heading,
    Color? activeColor,
    FontWeight? font,
    required List<Map<String, dynamic>> value,
    required List<String> selectedValues,
    required void Function(List<String>) onChanged,
  }) : answer = ListView.separated(
         shrinkWrap: true,
         padding: EdgeInsets.zero,
         physics: const NeverScrollableScrollPhysics(),
         scrollDirection: Axis.vertical,
         itemCount: value.length,
         separatorBuilder: (context, index) => SizedBox(height: 8.h),
         itemBuilder: (context, index) {
           final item = value[index];
           final key = item['value'];
           final label = item['label'];
           final isChecked = selectedValues.contains(key);

           return Row(
             children: [
               Checkbox(
                 activeColor: activeColor ?? AppColors.primary,
                 value: isChecked,
                 onChanged: (bool? val) {
                   if (val == true) {
                     selectedValues.add(key.toString());
                   } else {
                     selectedValues.remove(key.toString());
                   }
                   onChanged(List<String>.from(selectedValues));
                 },
                 visualDensity: const VisualDensity(horizontal: -4),
               ),
               Expanded(
                 child: Text(
                   label.toString(),
                   style: TextStyle(
                     fontFamily: "poppins",
                     color: const Color(0xFF1E1E1E),
                     fontWeight: font ?? FontWeight.w300,
                     fontSize: 16.sp,
                   ),
                 ),
               ),
             ],
           );
         },
       );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (heading != '')
          Text(
            heading,
            style: TextStyle(
              fontFamily: 'poppins',
              color: AppColors.dark,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: 5.h),
        // kSpacer,
        answer,
      ],
    );
  }

  Question.date({
    super.key,
    void Function()? onTap,
    bool readonly = true,
    TextEditingController? controller,
    String? Function(String?)? validator,
    BuildContext? context,
    required this.heading,
    TextStyle? hintStyle,
  }) : answer = CustomTextField(
         controller: controller,
         validator: validator,
         readonly: readonly,
         hintStyle: hintStyle,
         suffixIcon: InkWell(
           onTap: onTap,
           child: const Icon(
             Icons.calendar_month_sharp,
             color: AppColors.primary,
           ),
         ),
       );
}

// List<String> abc = ['a', 'b', 'c'];
// String? selectDrop;
//
// Question.dropDown(
// heading: 'Name of Applicant',
// context: context,
// items: abc.map((items) {
// return DropdownMenuItem(
// value: items.toString(),
// child: Text(
// items,
// style: CustomFontStyle().common(
// fontSize: 16.sp,
// fontWeight: FontWeight.w300,
// color: Colors.black,
// ),
// ),
// );
// }).toList(),
// onChanged: (String? item) {
// setState(() {
// selectDrop = item;
// });
// },
// )
