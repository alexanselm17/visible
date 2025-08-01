import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/controller/product_controller.dart';
import '../../../model/campaign/campaign_product.dart' as campaign_product;
import 'package:visible/model/auth/location_search.dart';

class AdminAddProductPage extends StatefulWidget {
  final String campaignId;
  final campaign_product.Datum? product;

  const AdminAddProductPage({
    super.key,
    required this.campaignId,
    this.product,
  });

  @override
  _AdminAddProductPageState createState() => _AdminAddProductPageState();
}

class _AdminAddProductPageState extends State<AdminAddProductPage> {
  static const Color accentOrange = Color(0xFFFF7F00);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController capitalInvestedController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController rewardController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController validUntilController = TextEditingController();
  final TextEditingController badgeController = TextEditingController();
  final TextEditingController validUntilDateController =
      TextEditingController();
  final TextEditingController validUntilTimeController =
      TextEditingController();
  final TextEditingController countySearchController = TextEditingController();

  final AuthenticationController authenticationController =
      Get.find<AuthenticationController>();
  final ProductController productController = Get.put(ProductController());

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<String> badges = [];
  File? selectedImage;
  File? selectedVideo;
  File? videoThumbnail;
  String selectedMediaType = "image";
  String? selectedGender;
  String? selectedCountyId;
  String? selectedCountyName;
  List<Datum> _counties = [];
  List<Datum> _filteredCounties = [];
  bool _showCountyDropdown = false;
  bool _isLoadingCounties = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Preload values if editing
    if (widget.product != null) {
      final p = widget.product!;
      categoryController.text = p.category ?? '';
      nameController.text = p.name ?? '';
      capitalInvestedController.text = p.capitalInvested?.toString() ?? '';
      descriptionController.text = p.description ?? '';
      rewardController.text = p.reward?.toString() ?? '';
      capacityController.text = p.capacity?.toString() ?? '';
      validUntilController.text = p.validUntil?.toString() ?? '';
      badges = p.badge ?? [];
      selectedGender =
          p.targetAudience != null ? p.targetAudience!.gender! : '';
      selectedCountyId =
          p.targetAudience != null ? p.targetAudience!.countyId : '';
      selectedMediaType = p.videoUrl == null ? 'image' : 'video';
    }
  }

  @override
  void dispose() {
    categoryController.dispose();
    nameController.dispose();
    capitalInvestedController.dispose();
    descriptionController.dispose();
    rewardController.dispose();
    capacityController.dispose();
    validUntilController.dispose();
    badgeController.dispose();
    validUntilDateController.dispose();
    validUntilTimeController.dispose();
    countySearchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool isThumbnail = false}) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isThumbnail) {
          videoThumbnail = File(pickedFile.path);
        } else {
          selectedImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedVideo = File(pickedFile.path);
      });
    }
  }

  void _addBadge() {
    if (badgeController.text.isNotEmpty) {
      setState(() {
        badges.add(badgeController.text);
        badgeController.clear();
      });
    }
  }

  void _removeBadge(int index) {
    setState(() {
      badges.removeAt(index);
    });
  }

  Future<void> _searchCounties(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoadingCounties = true;
    });
    try {
      final locationData =
          await authenticationController.getUserLocation(search: query);
      if (locationData != null) {
        setState(() {
          _counties = locationData;
          _filteredCounties = locationData;
          _showCountyDropdown = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching locations: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingCounties = false;
      });
    }
  }

  void _calculateCapacity() {
    final double? capital = double.tryParse(capitalInvestedController.text);
    final double? reward = double.tryParse(rewardController.text);

    if (capital != null && reward != null) {
      if (reward != 0) {
        final newCapacity = capital / reward;
        capacityController.text = newCapacity.toStringAsFixed(2);
      } else {
        capacityController.text = '0'; // Handle division by zero
      }
    } else {
      // Clear capacity if inputs are incomplete or invalid
      capacityController.clear();
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedMediaType == "video" && videoThumbnail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thumbnail image required for video")),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Combine date & time before sending
        String validUntilCombined = '';
        if (selectedDate != null && selectedTime != null) {
          final dt = DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime!.hour,
            selectedTime!.minute,
          );
          validUntilCombined = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
        } else if (widget.product != null &&
            widget.product!.validUntil != null) {
          // If editing and no new date/time selected, use existing validUntil
          validUntilCombined = DateFormat('yyyy-MM-dd HH:mm:ss')
              .format(widget.product!.validUntil!);
        }

        if (widget.product == null) {
          // CREATE
          await productController.uploadProductAdvert(
            imageFile: selectedMediaType == "image" ? selectedImage : null,
            videoFile: selectedMediaType == "video" ? selectedVideo : null,
            thumbnailFile: selectedMediaType == "video" ? videoThumbnail : null,
            campaignId: widget.campaignId,
            name: nameController.text,
            description: descriptionController.text,
            badge: badges,
            category: categoryController.text,
            reward: rewardController.text,
            capacity: (double.tryParse(capacityController.text)?.round() ?? 0)
                .toString(),
            validUntil: validUntilCombined,
            capitalInvested: capitalInvestedController.text,
            gender: selectedGender ?? '',
            countyId: selectedCountyId ?? '',
          );
        } else {
          await productController.updateProductAdvert(
            productId: widget.product!.id!,
            imageFile: selectedMediaType == "image" ? selectedImage : null,
            videoFile: selectedMediaType == "video" ? selectedVideo : null,
            thumbnailFile: selectedMediaType == "video" ? videoThumbnail : null,
            campaignId: widget.campaignId,
            name: nameController.text,
            description: descriptionController.text,
            badge: badges,
            category: categoryController.text,
            reward: rewardController.text,
            capacity: capacityController.text,
            validUntil: validUntilCombined, // Use the combined date/time
            capitalInvested: capitalInvestedController.text,
            gender: selectedGender ?? '',
            countyId: selectedCountyId ?? '',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Product created successfully!'
                : 'Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _buildSection(
              title: 'Basic Information',
              children: [
                _buildTextField(
                  controller: nameController,
                  label: 'Product Name',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: categoryController,
                  label: 'Category',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Category is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionController,
                  label: 'Description',
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Description is required' : null,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Pricing
            _buildSection(
              title: 'Pricing',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: capitalInvestedController,
                        label: 'Capital Invested',
                        keyboardType: TextInputType.number,
                        onChanged: (_) =>
                            _calculateCapacity(), // Calls new method
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: rewardController,
                        label: 'Reward',
                        keyboardType: TextInputType.number,
                        onChanged: (_) =>
                            _calculateCapacity(), // Calls new method
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: capacityController,
                        label: 'Capacity',
                        keyboardType: TextInputType.number,
                        // No onChanged here, as it's the calculated field
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 24),

            // Media
            _buildSection(
              title: 'Media',
              children: [
                _buildMediaSelector(),
                const SizedBox(height: 16),
                if (selectedMediaType == "image") _buildImageSection(),
                if (selectedMediaType == "video") _buildVideoSection(),
              ],
            ),

            const SizedBox(height: 24),

            // Badges
            _buildSection(
              title: 'Badges',
              children: [
                _buildBadgesSection(),
              ],
            ),

            const SizedBox(height: 24),

            // Validity
            _buildSection(
              title: 'Validity Period',
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDateField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTimeField()),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Target Audience
            _buildSection(
              title: 'Target Audience',
              children: [
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildCountySelector(),
              ],
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.product == null
                            ? 'Create Product'
                            : 'Update Product',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged, // Added onChanged parameter
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged, // Pass the onChanged callback to TextFormField
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentOrange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildMediaSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedMediaType = "image";
                selectedVideo = null;
                videoThumbnail = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedMediaType == "image"
                    ? accentOrange
                    : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                border: Border.all(
                  color: selectedMediaType == "image"
                      ? accentOrange
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    color: selectedMediaType == "image"
                        ? Colors.white
                        : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Image',
                    style: TextStyle(
                      color: selectedMediaType == "image"
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedMediaType = "video";
                selectedImage = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedMediaType == "video"
                    ? accentOrange
                    : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: selectedMediaType == "video"
                      ? accentOrange
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    color: selectedMediaType == "video"
                        ? Colors.white
                        : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Video',
                    style: TextStyle(
                      color: selectedMediaType == "video"
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedImage != null || widget.product?.imageUrl != null)
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: selectedImage != null
                  ? Image.file(selectedImage!, fit: BoxFit.cover)
                  : Image.network(widget.product!.imageUrl!, fit: BoxFit.cover),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(),
            icon: const Icon(Icons.add_photo_alternate, size: 20),
            label: Text(
                selectedImage != null || widget.product?.imageUrl != null
                    ? 'Change Image'
                    : 'Select Image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentOrange,
              side: const BorderSide(color: accentOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Selection
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(
                Icons.videocam,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                selectedVideo != null
                    ? "Video: ${selectedVideo!.path.split('/').last}"
                    : widget.product?.videoUrl != null
                        ? "Video: ${widget.product!.videoUrl!.split('/').last}"
                        : "No video selected",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.video_library, size: 20),
            label: const Text('Select Video'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentOrange,
              side: const BorderSide(color: accentOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Thumbnail Section
        const Text(
          'Thumbnail (Required)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (videoThumbnail != null || widget.product?.imageUrl != null)
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: videoThumbnail != null
                  ? Image.file(videoThumbnail!, fit: BoxFit.cover)
                  : Image.network(widget.product!.imageUrl!, fit: BoxFit.cover),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(isThumbnail: true),
            icon: const Icon(Icons.add_photo_alternate, size: 20),
            label: Text(
                videoThumbnail != null || widget.product?.imageUrl != null
                    ? 'Change Thumbnail'
                    : 'Select Thumbnail'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentOrange,
              side: const BorderSide(color: accentOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badges.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.asMap().entries.map((entry) {
              int index = entry.key;
              String badge = entry.value;
              return Chip(
                label: Text(badge),
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(color: Colors.grey[700]),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeBadge(index),
                deleteIconColor: Colors.grey[600],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: badgeController,
                decoration: InputDecoration(
                  labelText: 'Add Badge',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: accentOrange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                onSubmitted: (_) => _addBadge(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addBadge,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(16),
                elevation: 0,
              ),
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return _buildTextField(
      controller: validUntilDateController,
      label: 'Valid Until Date',
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
            validUntilDateController.text =
                DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildTimeField() {
    return _buildTextField(
      controller: validUntilTimeController,
      label: 'Valid Until Time',
      readOnly: true,
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime;
            validUntilTimeController.text = pickedTime.format(context);
          });
        }
      },
    );
  }

  Widget _buildGenderSelector() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: 'Target Gender',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentOrange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: ["male", "female"].map((g) {
        return DropdownMenuItem(
          value: g,
          child: Text(g.capitalizeFirst!),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          selectedGender = val;
        });
      },
    );
  }

  Widget _buildCountySelector() {
    return Column(
      children: [
        TextField(
          controller: countySearchController,
          decoration: InputDecoration(
            labelText: 'Search County',
            suffixIcon: _isLoadingCounties
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: accentOrange),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          onChanged: _searchCounties,
        ),
        if (_showCountyDropdown) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedCountyId,
            decoration: InputDecoration(
              labelText: 'Select County',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: accentOrange),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            items: _filteredCounties.map((county) {
              return DropdownMenuItem(
                value: county.id,
                child: Text(county.name!),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedCountyId = val;
                selectedCountyName =
                    _filteredCounties.firstWhere((c) => c.id == val).name;
              });
            },
          ),
        ],
      ],
    );
  }
}
