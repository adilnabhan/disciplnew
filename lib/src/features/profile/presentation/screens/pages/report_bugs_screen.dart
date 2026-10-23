import 'dart:math' as math;
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/domain/repositories/bug_report_repository.dart';

class ReportBugsScreen extends StatefulWidget {
  const ReportBugsScreen({super.key});

  @override
  State<ReportBugsScreen> createState() => _ReportBugsScreenState();
}

class _ReportBugsScreenState extends State<ReportBugsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();
  final BugReportRepository _repository = BugReportRepository();

  int _currentTab = 0;
  static const int _maxImages = 5;
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  bool _isLoadingReports = false;
  String? _reportsError;
  List<BugReportItem> _reports = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _currentTab) {
        setState(() {
          _currentTab = _tabController.index;
        });
      }
      if (!_tabController.indexIsChanging && _tabController.index == 1) {
        _fetchReports();
      }
    });
    _fetchReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _titleFocusNode.dispose();
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    if (!mounted) return;
    setState(() {
      _isLoadingReports = true;
      _reportsError = null;
    });

    final result = await _repository.getBugReports();
    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoadingReports = false;
          _reportsError =
              error.msg.isNotEmpty ? error.msg : 'Failed to load bug reports';
        });
      },
      (list) {
        setState(() {
          _isLoadingReports = false;
          _reports = list;
          _reportsError = null;
        });
      },
    );
  }

  Future<void> _submitBugReport() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a bug title or subject.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _titleFocusNode.requestFocus();
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the bug before submitting.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _descriptionFocusNode.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    final result = await _repository.submitBugReport(
      text: title,
      title: title,
      description: description,
      images: _selectedImages,
      image: _selectedImages.isNotEmpty ? _selectedImages.first : null,
    );

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppErrorHandler.formatUserFriendlyMessage(error.msg, fallback: 'Failed to submit bug report. Please try again.'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (newReport) {
        setState(() {
          _isSubmitting = false;
          _titleController.clear();
          _descriptionController.clear();
          _selectedImages.clear();
          _reports.insert(0, newReport);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bug report submitted! Thank you for your feedback.'),
            backgroundColor: Color(0xFF047857),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Switch to history tab
        _tabController.animateTo(1);
        _fetchReports();
      },
    );
  }

  Future<void> _deleteReport(BugReportItem report) async {
    if (report.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Report',
          style: AppStyles.text16Px.poppins.w600,
        ),
        content: Text(
          'Are you sure you want to delete report #${report.id}?',
          style: AppStyles.text14Px.poppins.w400.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _repository.deleteBugReport(report.id!);
    if (!mounted) return;

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppErrorHandler.formatUserFriendlyMessage(error.msg, fallback: 'Failed to delete bug report. Please try again.'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (_) {
        setState(() {
          _reports.removeWhere((item) => item.id == report.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bug report deleted successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _showAttachmentPickerModal() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum $_maxImages screenshots allowed.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final picker = ImagePicker();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Attach Screenshots',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_selectedImages.length}/$_maxImages added',
                        style: AppStyles.text11Px.poppins.w600.copyWith(
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload photos to help us reproduce and fix the bug faster.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),

                // Choose Multiple from Gallery
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: const Color(0xFFF8FAFC),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Select one or multiple screenshots',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final picked = await picker.pickMultiImage();
                      if (picked.isNotEmpty) {
                        _addMultipleImages(picked);
                      }
                    } catch (e) {
                      debugPrint('Error picking images: $e');
                    }
                  },
                ),
                const SizedBox(height: 10),

                // Take Photo
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: const Color(0xFFF8FAFC),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF047857).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Color(0xFF047857),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Capture directly with your camera',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final photo = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (photo != null) {
                        _addMultipleImages([photo]);
                      }
                    } catch (e) {
                      debugPrint('Error capturing photo: $e');
                    }
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addMultipleImages(List<XFile> newFiles) {
    if (newFiles.isEmpty) return;
    final availableSlots = _maxImages - _selectedImages.length;
    if (availableSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum $_maxImages screenshots allowed.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final toAdd = newFiles.take(availableSlots).toList();
    setState(() {
      _selectedImages.addAll(toAdd);
    });

    if (newFiles.length > availableSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $availableSlots screenshot(s). Maximum is $_maxImages.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeImageAt(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  void _openGalleryViewer({
    List<File>? localFiles,
    List<String>? networkUrls,
    int initialIndex = 0,
    bool allowDelete = false,
  }) {
    final total = localFiles?.length ?? networkUrls?.length ?? 0;
    if (total == 0) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (ctx) {
        var currentIndex = initialIndex.clamp(0, total - 1);
        final pageController = PageController(initialPage: currentIndex);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog.fullscreen(
              backgroundColor: Colors.transparent,
              child: SafeArea(
                child: Stack(
                  children: [
                    // Swipeable PageView with InteractiveViewer
                    PageView.builder(
                      controller: pageController,
                      itemCount: total,
                      onPageChanged: (idx) {
                        setDialogState(() {
                          currentIndex = idx;
                        });
                      },
                      itemBuilder: (context, idx) {
                        return Center(
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4.0,
                            child: localFiles != null
                                ? Image.file(
                                    localFiles[idx],
                                    fit: BoxFit.contain,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: networkUrls![idx],
                                    fit: BoxFit.contain,
                                    placeholder: (c, u) => const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (c, u, e) => const Center(
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        color: Colors.white54,
                                        size: 64,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    // Top Bar (Index badge, close button, delete button)
                    Positioned(
                      top: 10,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${currentIndex + 1} / $total',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),

                          if (allowDelete && localFiles != null) ...[
                            GestureDetector(
                              onTap: () {
                                final toRemoveIndex = currentIndex;
                                Navigator.pop(ctx);
                                _removeImageAt(toRemoveIndex);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0x99DC2626),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom dots indicator (if total > 1)
                    if (total > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(total, (i) {
                            final isActive = i == currentIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern slate background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: const PopButton().center,
        title: Text(
          'Report Bugs',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildModernSegmentedBar(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmitTab(),
          _buildHistoryTab(),
        ],
      ),
      bottomNavigationBar: _currentTab == 0 ? _buildSubmitButton() : null,
    );
  }

  // ==========================================
  // MODERN SEGMENTED BAR (SLATE / FLOATING PILL)
  // ==========================================
  Widget _buildModernSegmentedBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentItem(
              title: 'Submit Report',
              icon: Icons.edit_note_rounded,
              index: 0,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSegmentItem(
              title: 'My Reports',
              icon: Icons.history_rounded,
              badgeCount: _reports.isNotEmpty ? _reports.length : null,
              index: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({
    required String title,
    required IconData icon,
    required int index,
    int? badgeCount,
  }) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () {
        if (_currentTab != index) {
          setState(() {
            _currentTab = index;
          });
          _tabController.animateTo(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppStyles.text14Px.poppins.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppStyles.text11Px.poppins.w600.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: SUBMIT REPORT
  // ==========================================
  Widget _buildSubmitTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Subject / Issue Name
          _buildFieldHeader('Subject / Issue Name', isRequired: true),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey, width: 1.1),
            ),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              maxLength: 150,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _descriptionFocusNode.requestFocus(),
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                prefixIcon: const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                hintText: 'Briefly describe the issue',
                hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                counterText: '',
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 2. Description
          _buildFieldHeader('Description', isRequired: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey, width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, right: 10),
                      child: Icon(
                        Icons.insert_drive_file_outlined,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        maxLines: 5,
                        minLines: 4,
                        maxLength: 500,
                        style: AppStyles.text14Px.poppins.w400.copyWith(
                          color: AppColors.textDark,
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          fillColor: Colors.transparent,
                          hintText:
                              'Please provide more details about the issue, what happened, and any steps to reproduce it...',
                          hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                            color: const Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _descriptionController,
                    builder: (context, value, _) {
                      return Text(
                        '${value.text.length}/500',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Upload Images Section
          _buildScreenshotSection(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFieldHeader(String label, {required bool isRequired}) {
    return Row(
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScreenshotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              'Upload Images',
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(Optional)',
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Add screenshots or photos to help us understand the issue better.',
          style: AppStyles.text13Px.poppins.w400.copyWith(
            color: AppColors.textGrey,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),

        // Dashed Dropzone Card
        GestureDetector(
          onTap: _showAttachmentPickerModal,
          child: CustomPaint(
            painter: _DashedRectPainter(
              color: AppColors.borderGrey,
              strokeWidth: 1.3,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.image_rounded,
                    color: AppColors.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to upload images',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG, JPEG (Max 5 images, 5MB each)',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Selected Thumbnails + Add More Tile below
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length +
                  (_selectedImages.length < _maxImages ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index < _selectedImages.length) {
                  final xFile = _selectedImages[index];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _openGalleryViewer(
                            localFiles: _selectedImages
                                .map((f) => File(f.path))
                                .toList(),
                            initialIndex: index,
                            allowDelete: true,
                          );
                        },
                        child: Container(
                          width: 92,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borderGrey,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.file(
                              File(xFile.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => _removeImageAt(index),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xCC000000),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return GestureDetector(
                  onTap: _showAttachmentPickerModal,
                  child: Container(
                    width: 92,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.borderGrey,
                        width: 1.1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                          size: 30,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add More',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isSubmitting ? null : _submitBugReport,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE50914),
                  Color(0xFFB80005),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCF0B10).withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Submit Bug Report',
                          style: AppStyles.text15Px.poppins.w600.copyWith(
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }


  // ==========================================
  // TAB 2: MY BUG REPORTS (HISTORY)
  // ==========================================
  Widget _buildHistoryTab() {
    if (_isLoadingReports && _reports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_reportsError != null && _reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load reports',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _reportsError!,
                textAlign: TextAlign.center,
                style: AppStyles.text13Px.poppins.w400.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: _fetchReports,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchReports,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bug_report_outlined,
                  color: Color(0xFF94A3B8),
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'No Bug Reports Yet',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                "You haven't submitted any bug reports yet.\nNotice a glitch? Submit a report anytime!",
                textAlign: TextAlign.center,
                style: AppStyles.text13Px.poppins.w400.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentTab = 0;
                  });
                  _tabController.animateTo(0);
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Report a Bug'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchReports,
      color: AppColors.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  (Color, Color, String) _resolveStatusStyle(BugReportItem report) {
    if (report.isResolved) {
      return (
        const Color(0xFF16A34A),
        const Color(0xFFDCFCE7),
        'Resolved',
      );
    }

    if (report.isInReview ||
        (report.statusDisplay != null &&
            report.statusDisplay!.toLowerCase().contains('review'))) {
      return (
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        'In Review',
      );
    }

    return (
      const Color(0xFFDC2626),
      const Color(0xFFFEE2E2),
      (report.statusDisplay != null && report.statusDisplay!.isNotEmpty)
          ? report.statusDisplay!
          : 'Not Resolved',
    );
  }

  Widget _buildReportCard(BugReportItem report) {
    final (statusColor, statusBg, statusLabel) = _resolveStatusStyle(report);
    final isResolved = report.isResolved;

    final dateString = report.createdAt != null
        ? DateFormat('d MMM yyyy, hh:mm a').format(report.createdAt!.toLocal())
        : null;

    final imageUrls = report.allImageUrls;
    final titleText = (report.title != null && report.title!.isNotEmpty)
        ? report.title!
        : (report.text ?? 'Bug Report');

    final descText = (report.description != null &&
            report.description!.isNotEmpty &&
            report.description != report.title)
        ? report.description!
        : (report.text != null && report.text != report.title
            ? report.text!
            : '');

    final hasNote = report.note != null && report.note!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showReportDetailsModal(report),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Left Thumbnail
                    _buildCardThumbnail(report, imageUrls),
                    const SizedBox(width: 12),

                    // 2. Right Content Block
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Title + Status Pill
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  titleText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppStyles.text14Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      statusLabel,
                                      style: AppStyles.text11Px.poppins.w600
                                          .copyWith(
                                        color: statusColor,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Row 2: 2 Lines Description + Chevron >
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  descText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppStyles.text12Px.poppins.w400.copyWith(
                                    color: const Color(0xFF6B7280),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 3: Calendar Date
                          if (dateString != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  dateString,
                                  style:
                                      AppStyles.text11Px.poppins.w400.copyWith(
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Note from API (if present)
                if (hasNote) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isResolved
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isResolved
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isResolved
                              ? Icons.check_circle_rounded
                              : Icons.chat_bubble_outline_rounded,
                          size: 13,
                          color: isResolved
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${isResolved ? "Resolution: " : "Admin Note: "}${report.note!.trim()}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text11Px.poppins.w500.copyWith(
                              color: isResolved
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF1E40AF),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardThumbnail(BugReportItem report, List<String> imageUrls) {
    const double thumbSize = 88;

    if (imageUrls.isEmpty) {
      return Container(
        width: thumbSize,
        height: thumbSize,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Icon(
            Icons.bug_report_outlined,
            color: Color(0xFF94A3B8),
            size: 32,
          ),
        ),
      );
    }

    return SizedBox(
      width: thumbSize,
      height: thumbSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (c, u) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (c, u, e) => Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF94A3B8),
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 11,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
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

  void _showReportDetailsModal(BugReportItem report) {
    final (statusColor, statusBg, statusLabel) = _resolveStatusStyle(report);
    final isResolved = report.isResolved;

    final dateString = report.createdAt != null
        ? DateFormat('d MMM yyyy, hh:mm a').format(report.createdAt!.toLocal())
        : null;

    final imageUrls = report.allImageUrls;
    final titleText = (report.title != null && report.title!.isNotEmpty)
        ? report.title!
        : (report.text ?? 'Bug Report');

    final descText = (report.description != null &&
            report.description!.isNotEmpty &&
            report.description != report.title)
        ? report.description!
        : (report.text != null && report.text != report.title
            ? report.text!
            : '');

    final hasNote = report.note != null && report.note!.trim().isNotEmpty;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(modalCtx).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Bug Report Details',
                      style: AppStyles.text16Px.poppins.w600.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    if (report.id != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${report.id}',
                          style: AppStyles.text11Px.poppins.w600.copyWith(
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: const Color(0xFF64748B),
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style:
                                      AppStyles.text12Px.poppins.w600.copyWith(
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (dateString != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  dateString,
                                  style:
                                      AppStyles.text12Px.poppins.w400.copyWith(
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Subject',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        titleText,
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: AppColors.textDark,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (descText.isNotEmpty) ...[
                        Text(
                          'Description',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            descText,
                            style: AppStyles.text13Px.poppins.w400.copyWith(
                              color: const Color(0xFF334155),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (hasNote) ...[
                        Text(
                          isResolved ? 'Resolution Note' : 'Admin Note',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isResolved
                                ? const Color(0xFFF0FDF4)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isResolved
                                  ? const Color(0xFFBBF7D0)
                                  : const Color(0xFFBFDBFE),
                              width: 1.1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isResolved
                                    ? Icons.task_alt_rounded
                                    : Icons.mark_chat_read_outlined,
                                size: 18,
                                color: isResolved
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  report.note!.trim(),
                                  style:
                                      AppStyles.text13Px.poppins.w400.copyWith(
                                    color: const Color(0xFF334155),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (imageUrls.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              'Attached Screenshots',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${imageUrls.length}',
                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Tap to preview',
                              style: AppStyles.text11Px.poppins.w400.copyWith(
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (ctx, imgIdx) {
                              return GestureDetector(
                                onTap: () {
                                  _openGalleryViewer(
                                    networkUrls: imageUrls,
                                    initialIndex: imgIdx,
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrls[imgIdx],
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (c, u, e) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (report.id != null) ...[
                        const Divider(color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(modalCtx);
                              _deleteReport(report);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            label: Text(
                              'Delete Bug Report',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFFEE2E2)),
                              backgroundColor: const Color(0xFFFFF5F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.2,
  });

  final Color color;
  final double strokeWidth;
  static const double dash = 6;
  static const double gap = 4;
  static const double radius = 14;


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dash, metric.length - distance);
        dashPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
