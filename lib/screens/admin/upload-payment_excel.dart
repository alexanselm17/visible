import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:visible/common/toast.dart';
import 'package:visible/repository/auth_repository.dart';

class UploadPaymentExcelPage extends StatefulWidget {
  const UploadPaymentExcelPage({super.key});

  @override
  State<UploadPaymentExcelPage> createState() => _UploadPaymentExcelPageState();
}

class _UploadPaymentExcelPageState extends State<UploadPaymentExcelPage>
    with TickerProviderStateMixin {
  String? selectedFilePath;
  String? selectedFileName;
  bool isUploading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Your brand colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color accentOrange = Color(0xFFFF7F00);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF757575);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> uploadExcel(String filePath) async {
    try {
      setState(() => isUploading = true);

      // Add haptic feedback
      HapticFeedback.lightImpact();

      var response =
          await AuthRepository().uploadPaymentExcel(filePath: filePath);
      Logger().i("Upload response: ${response?.data}");

      if (response?.statusCode == 200) {
        // Success feedback
        HapticFeedback.lightImpact();

        CommonUtils.showToast(
            "File uploaded successfully: ${response?.data['message'] ?? 'No message'}");

        Get.snackbar(
          "✅ Success",
          response?.data['message'] ?? "Upload successful",
          backgroundColor: successGreen,
          colorText: pureWhite,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
        );

        setState(() {
          selectedFilePath = null;
          selectedFileName = null;
        });
        _animationController.reset();
      } else {
        // Error feedback
        HapticFeedback.heavyImpact();
        CommonUtils.showErrorToast(response?.statusMessage ?? "Upload failed");
      }

      setState(() => isUploading = false);
    } catch (e) {
      HapticFeedback.vibrate();
      setState(() => isUploading = false);
      CommonUtils.showErrorToast("An error occurred during upload");
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        HapticFeedback.selectionClick();
        setState(() {
          selectedFilePath = result.files.single.path;
          selectedFileName = result.files.single.name;
        });
        _animationController.forward();
      }
    } catch (e) {
      CommonUtils.showErrorToast("Failed to pick file");
    }
  }

  Widget _buildFileSelectionCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isUploading ? null : pickFile,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedFilePath != null
                  ? accentOrange
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  selectedFilePath != null
                      ? Icons.description
                      : Icons.upload_file,
                  size: 48,
                  color: accentOrange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                selectedFilePath != null
                    ? "File Selected"
                    : "Select Excel File",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: selectedFilePath != null ? accentOrange : darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedFilePath != null
                    ? "Tap to change file"
                    : "Tap to browse for .xls or .xlsx files",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileInfo() {
    if (selectedFilePath == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: lightGray,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected File:",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedFileName ?? "Unknown file",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: isUploading
                    ? null
                    : () {
                        setState(() {
                          selectedFilePath = null;
                          selectedFileName = null;
                        });
                        _animationController.reset();
                      },
                icon: Icon(
                  Icons.close,
                  color: Colors.grey.shade600,
                ),
                tooltip: "Remove file",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    final isEnabled = selectedFilePath != null && !isUploading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled ? () => uploadExcel(selectedFilePath!) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? accentOrange : Colors.grey.shade300,
          foregroundColor: pureWhite,
          elevation: isEnabled ? 4 : 0,
          shadowColor: accentOrange.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: isUploading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(pureWhite),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Uploading...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Upload File",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (!isUploading) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(accentOrange),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Please wait while we process your file...",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      appBar: AppBar(
        title: const Text(
          "Upload Payment Excel",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: pureWhite,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Text(
                "Upload Excel File",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select and upload your payment Excel file (.xls or .xlsx format)",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // File selection card
              _buildFileSelectionCard(),
              const SizedBox(height: 16),

              // Selected file info
              _buildSelectedFileInfo(),
              const SizedBox(height: 32),

              // Upload button
              _buildUploadButton(),

              // Progress indicator
              _buildProgressIndicator(),

              // Help text
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "File Requirements:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "• Only .xls and .xlsx files are supported\n• Ensure your file contains valid payment data\n• File size should not exceed 10MB",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
