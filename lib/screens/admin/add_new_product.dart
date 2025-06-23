import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/product_controller.dart';
import 'package:visible/model/campaign/campaign_product.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum MediaType { image, video }

class AdminProductEditPage extends StatefulWidget {
  final Datum? product;
  final String campaignId;

  const AdminProductEditPage(
      {super.key, required this.campaignId, this.product});

  @override
  State<AdminProductEditPage> createState() => _AdminProductEditPageState();
}

class _AdminProductEditPageState extends State<AdminProductEditPage> {
  final ImagePicker _picker = ImagePicker();

  // Media files
  File? _selectedImageFile;
  File? _selectedVideoFile;
  File? _videoThumbnailFile;
  String? _existingImageUrl;
  String? _existingVideoUrl;
  bool _mediaChanged = false;
  MediaType _selectedMediaType = MediaType.image;

  // Video player
  VideoPlayerController? _videoController;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get isEditing => widget.product != null;
  ProductController productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();

    // if (isEditing) {
    //   _nameController.text = widget.product!.name ?? '';
    //   _descriptionController.text = widget.product!.description ?? '';

    //   if (widget.product!.imageUrl != null) {
    //     _existingImageUrl = widget.product!.imageUrl;
    //     _selectedMediaType = MediaType.image;
    //   }
    //   if (widget.product!.videoUrl != null) {
    //     _existingVideoUrl = widget.product!.videoUrl;
    //     _selectedMediaType = MediaType.video;
    //   }
    // }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(MediaType mediaType) async {
    try {
      if (mediaType == MediaType.image) {
        final result = await showDialog<ImageSource>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Image'),
              content: const Text('Choose image source:'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.gallery),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_library, size: 20),
                      SizedBox(width: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.camera),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, size: 20),
                      SizedBox(width: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
              ],
            );
          },
        );

        if (result != null) {
          final XFile? image = await _picker.pickImage(
            source: result,
            imageQuality: 80,
          );
          if (image != null) {
            setState(() {
              _selectedImageFile = File(image.path);
              _selectedVideoFile = null;
              _videoThumbnailFile = null;
              _selectedMediaType = MediaType.image;
              _mediaChanged = true;
            });
            _videoController?.dispose();
            _videoController = null;
          }
        }
      } else {
        final result = await showDialog<ImageSource>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Select Video'),
              content: const Text('Choose video source:'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.gallery),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.video_library, size: 20),
                      SizedBox(width: 8),
                      Text('Gallery'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(ImageSource.camera),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam, size: 20),
                      SizedBox(width: 8),
                      Text('Camera'),
                    ],
                  ),
                ),
              ],
            );
          },
        );

        if (result != null) {
          final XFile? video = await _picker.pickVideo(
            source: result,
            maxDuration: const Duration(minutes: 5),
          );
          if (video != null) {
            setState(() {
              _selectedVideoFile = File(video.path);
              _selectedImageFile = null;
              _selectedMediaType = MediaType.video;
              _mediaChanged = true;
            });

            // Initialize video controller
            _videoController?.dispose();
            _videoController = VideoPlayerController.file(_selectedVideoFile!)
              ..initialize().then((_) {
                setState(() {});
              });

            // Show dialog for thumbnail options
            _showThumbnailOptionsDialog();
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick ${mediaType == MediaType.image ? 'image' : 'video'}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showThumbnailOptionsDialog() async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Wait for video to initialize

    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Video Thumbnail Required'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A thumbnail image is required for your video.'),
              SizedBox(height: 12),
              Text('Choose how you want to add the thumbnail:'),
              SizedBox(height: 8),
              Text('• Upload an existing image from your device'),
              Text('• Take a new photo with your camera'),
              Text('• Add it later (you can add it anytime)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('later'),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('upload'),
              child: const Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop('camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Take Photo'),
            ),
          ],
        );
      },
    );

    if (result == 'upload' || result == 'camera') {
      await _uploadVideoThumbnail(result == 'camera');
    }
  }

  Future<void> _uploadVideoThumbnail([bool useCamera = false]) async {
    try {
      final XFile? thumbnail = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );

      if (thumbnail != null) {
        setState(() {
          _videoThumbnailFile = File(thumbnail.path);
        });

        Get.snackbar(
          'Success',
          'Video thumbnail added successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload thumbnail: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showThumbnailUploadOptions() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Video Thumbnail'),
          content: const Text('Choose how to add the video thumbnail:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('gallery'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, size: 20),
                  SizedBox(width: 8),
                  Text('Upload from Gallery'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('camera'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 20),
                  SizedBox(width: 8),
                  Text('Take Photo'),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await _uploadVideoThumbnail(result == 'camera');
    }
  }

  Widget _buildMediaTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMediaType = MediaType.image;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedMediaType == MediaType.image
                      ? AppColors.accentOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      color: _selectedMediaType == MediaType.image
                          ? Colors.white
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Image',
                      style: TextStyle(
                        color: _selectedMediaType == MediaType.image
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
                  _selectedMediaType = MediaType.video;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedMediaType == MediaType.video
                      ? AppColors.accentOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      color: _selectedMediaType == MediaType.video
                          ? Colors.white
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Video',
                      style: TextStyle(
                        color: _selectedMediaType == MediaType.video
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
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (_selectedMediaType == MediaType.image) {
      return _buildImagePreview();
    } else {
      return _buildVideoPreview();
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    } else if (isEditing &&
        _existingImageUrl != null &&
        _selectedMediaType == MediaType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: _existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else {
      return _buildDefaultPlaceholder(
          Icons.add_photo_alternate, 'Tap to select image');
    }
  }

  Widget _buildVideoPreview() {
    if (_selectedVideoFile != null && _videoController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentOrange),
                    ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_videoController!.value.isPlaying) {
                        _videoController!.pause();
                      } else {
                        _videoController!.play();
                      }
                    });
                  },
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (isEditing &&
        _existingVideoUrl != null &&
        _selectedMediaType == MediaType.video) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 60, color: Colors.grey),
                SizedBox(height: 8),
                Text('Existing Video', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    } else {
      return _buildDefaultPlaceholder(Icons.videocam, 'Tap to select video');
    }
  }

  Widget _buildDefaultPlaceholder(IconData icon, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 60, color: Colors.grey),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildVideoThumbnailSection() {
    if (_selectedMediaType != MediaType.video || _selectedVideoFile == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Video Thumbnail',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Required',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload an image that will be shown as a preview for your video',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _showThumbnailUploadOptions,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _videoThumbnailFile == null
                    ? Colors.red.withOpacity(0.5)
                    : Colors.grey,
                width: _videoThumbnailFile == null ? 2 : 1,
              ),
            ),
            child: _videoThumbnailFile != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _videoThumbnailFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 8,
                        left: 8,
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_outline,
                                color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Video Thumbnail',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: _videoThumbnailFile == null
                            ? Colors.red.withOpacity(0.7)
                            : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload thumbnail image',
                        style: TextStyle(
                          color: _videoThumbnailFile == null
                              ? Colors.red.withOpacity(0.7)
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Required for video preview',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (_videoThumbnailFile == null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showThumbnailUploadOptions,
              icon: const Icon(Icons.upload, size: 18),
              label: const Text('Upload Thumbnail Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentOrange,
                side: const BorderSide(color: AppColors.accentOrange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleSubmit() async {
    if (_nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a product name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!isEditing) {
      if (_selectedMediaType == MediaType.image && _selectedImageFile == null) {
        Get.snackbar(
          'Error',
          'Please select a product image',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (_selectedMediaType == MediaType.video) {
        if (_selectedVideoFile == null) {
          Get.snackbar(
            'Error',
            'Please select a product video',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (_videoThumbnailFile == null) {
          Get.snackbar(
            'Error',
            'Please upload a thumbnail image for your video',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
    }

    if (isEditing) {
    } else {
      if (_selectedMediaType == MediaType.image) {
        await productController.uploadProductAdvert(
          campaignId: widget.campaignId,
          imageFile: _selectedImageFile!,
          name: _nameController.text,
          description: _descriptionController.text,
        );
      } else {
        await productController.uploadVideoProductAdvert(
          campaignId: widget.campaignId,
          videoFile: _selectedVideoFile!,
          imageFile: _videoThumbnailFile!,
          name: _nameController.text,
          description: _descriptionController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
            fontFamily: 'Leotaro',
            color: AppColors.primaryBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlack),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Type Selector
            const Text(
              'Media Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 10),
            _buildMediaTypeSelector(),
            const SizedBox(height: 20),

            // Media Preview
            Text(
              _selectedMediaType == MediaType.image
                  ? 'Product Image'
                  : 'Product Video',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _pickMedia(_selectedMediaType),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: _buildMediaPreview(),
              ),
            ),

            // Video Thumbnail Section
            _buildVideoThumbnailSection(),

            const SizedBox(height: 24),

            // Product Details Form
            const Text(
              'Product Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            const SizedBox(height: 10),

            // Product Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                hintText: 'Enter product name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Description
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter product description...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            Obx(
              () => productController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accentOrange))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Product' : 'Create Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
