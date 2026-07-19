import 'package:customer_mobile_app/imports_bindings.dart';

class ImagePickerDialog extends StatefulWidget {
  const ImagePickerDialog({
    super.key,
    this.onPickedImage,
    this.hasImage = false,
  });

  final void Function(XFile? image)? onPickedImage;
  final bool hasImage;

  Future<void> show(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => this,
    );
  }

  @override
  State<ImagePickerDialog> createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  bool _isPicking = false;

  void _handlePick(ImageSource source) {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
    });

    final navigator = Navigator.of(context);
    navigator.pop();

    ImagePicker().pickImage(source: source).then((xFile) {
      widget.onPickedImage?.call(xFile);
    }).catchError((e) {
      debugPrint('Error picking image: $e');
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contents = [
      (
        label: 'Take Photo',
        onTap: () => _handlePick(ImageSource.camera),
      ),
      (
        label: 'Choose from Gallery',
        onTap: () => _handlePick(ImageSource.gallery),
      ),
      if (widget.hasImage)
        (
          label: 'Remove Photo',
          onTap: () {
            widget.onPickedImage?.call(null);
            Navigator.of(context).pop();
          },
        ),
      (
        label: 'Cancel',
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: contents.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              contents[index].onTap();
            },
            child: Text(
              contents[index].label,
              textAlign: TextAlign.center,
              style: AppStyles.text16Px.poppins.w400.dark,
            ).pxy(y: 22),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: AppColors.borderGrey,
            height: 1,
            thickness: 1,
          );
        },
      ),
    );
  }
}
