import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CertificateViewerScreen extends StatefulWidget {
  const CertificateViewerScreen({
    required this.fileUrl,
    required this.certificateName,
    super.key,
  });

  final String fileUrl;
  final String certificateName;

  @override
  State<CertificateViewerScreen> createState() => _CertificateViewerScreenState();
}

class _CertificateViewerScreenState extends State<CertificateViewerScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
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
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.certificateName,
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_errorMessage == null)
            SfPdfViewer.network(
              widget.fileUrl,
              onDocumentLoaded: (details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              onDocumentLoadFailed: (details) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = details.description;
                  });
                }
              },
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load certificate',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Button.filled(
                      title: 'Try Again',
                      ontap: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                      },
                      buttonColor: AppColors.primary,
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: Colors.white,
                      ),
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
