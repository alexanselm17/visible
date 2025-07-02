import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/campaign_controller.dart';

class AdminCampaignCreatePage extends StatefulWidget {
  const AdminCampaignCreatePage({super.key});

  static const routeName = '/admin/campaigns/create';

  @override
  State<AdminCampaignCreatePage> createState() =>
      _AdminCampaignCreatePageState();
}

class _AdminCampaignCreatePageState extends State<AdminCampaignCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _validUntilController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final CampaignController campaignController = Get.find<CampaignController>();

  // Auto-calculation variables
  int _calculatedCapacity = 0;
  bool _isAutoCalculationEnabled = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedTime = const TimeOfDay(hour: 23, minute: 59);
    _validUntilController.text =
        DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Add listeners for auto-calculation
    _capitalController.addListener(_calculateCapacity);
    _rewardController.addListener(_calculateCapacity);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timeController.text.isEmpty && _selectedTime != null) {
      _timeController.text = _selectedTime!.format(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capitalController.dispose();
    _rewardController.dispose();
    _capacityController.dispose();
    _validUntilController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // Auto-calculate capacity based on budget and reward
  void _calculateCapacity() {
    if (!_isAutoCalculationEnabled) return;

    final budgetText = _capitalController.text.replaceAll(',', '');
    final rewardText = _rewardController.text;

    if (budgetText.isNotEmpty && rewardText.isNotEmpty) {
      try {
        final budget = int.parse(budgetText);
        final reward = int.parse(rewardText);

        if (reward > 0) {
          final capacity = (budget / reward).floor();
          setState(() {
            _calculatedCapacity = capacity;
            _capacityController.text =
                NumberFormat('#,###', 'en_US').format(capacity);
          });
        }
      } catch (e) {
        // Handle parsing errors silently
      }
    } else {
      setState(() {
        _calculatedCapacity = 0;
        if (_capacityController.text.isNotEmpty) {
          _capacityController.clear();
        }
      });
    }
  }

  // Toggle auto-calculation
  void _toggleAutoCalculation(bool value) {
    setState(() {
      _isAutoCalculationEnabled = value;
      if (value) {
        _calculateCapacity();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _validUntilController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 23, minute: 59),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.primaryBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  String _getCombinedDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      return combinedDateTime.toIso8601String();
    }
    return '';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final combinedDateTime = _getCombinedDateTime();

      try {
        campaignController.createCampaign(
          name: _nameController.text.trim(),
          capitalInvested:
              int.parse(_capitalController.text.replaceAll(',', '')),
          validUntil: combinedDateTime,
          reward: int.parse(_rewardController.text),
          capacity: int.parse(_capacityController.text.replaceAll(',', '')),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
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
        title: const Text(
          'Create Campaign',
          style: TextStyle(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Campaign Information'),
                const SizedBox(height: 4),
                _buildInfoCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Campaign Name',
                        hint: 'e.g. OMO PROMOTION',
                        prefixIcon: Icons.campaign,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter campaign name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _validUntilController,
                            label: 'Valid Until (Date)',
                            hint: 'Select end date',
                            prefixIcon: Icons.calendar_today,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select end date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: _buildTextField(
                            controller: _timeController,
                            label: 'Valid Until (Time)',
                            hint: 'Select end time',
                            prefixIcon: Icons.access_time,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select end time';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.accentOrange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: AppColors.accentOrange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Campaign ends: ${_selectedDate != null && _selectedTime != null ? DateFormat('MMM dd, yyyy \'at\' h:mm a').format(DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute)) : 'Select date and time'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accentOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Budget & Rewards'),
                const SizedBox(height: 4),
                _buildInfoCard(
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _capitalController,
                        label: 'Budget (KSh)',
                        hint: 'e.g. 20,000',
                        prefixIcon: Icons.money,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter budget amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _rewardController,
                        label: 'Reward per Participant (KSh)',
                        hint: 'e.g. 20',
                        prefixIcon: Icons.redeem,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter reward amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Participant Capacity'),
                const SizedBox(height: 4),
                _buildInfoCard(
                  child: Column(
                    children: [
                      // Auto-calculation toggle
                      Row(
                        children: [
                          Switch(
                            value: _isAutoCalculationEnabled,
                            onChanged: _toggleAutoCalculation,
                            activeColor: AppColors.accentOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Auto-calculate from budget',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _capacityController,
                        label: 'Maximum Participants',
                        hint: _isAutoCalculationEnabled
                            ? 'Auto-calculated'
                            : 'e.g. 10,000',
                        prefixIcon: Icons.group,
                        keyboardType: TextInputType.number,
                        inputFormatters: _isAutoCalculationEnabled
                            ? null
                            : [
                                FilteringTextInputFormatter.digitsOnly,
                                _ThousandsSeparatorInputFormatter(),
                              ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter participant capacity';
                          }
                          return null;
                        },
                        readOnly: _isAutoCalculationEnabled,
                      ),
                      const SizedBox(height: 8),
                      // Calculation display
                      if (_isAutoCalculationEnabled && _calculatedCapacity > 0)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calculate,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Calculation: KSh ${_capitalController.text} ÷ KSh ${_rewardController.text} = ${NumberFormat('#,###', 'en_US').format(_calculatedCapacity)} participants',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _isAutoCalculationEnabled
                            ? 'Capacity is automatically calculated based on your budget and reward per participant.'
                            : 'This is the maximum number of participants who can join this campaign.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: campaignController.isLoading.value
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: campaignController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Campaign',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 106),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlack,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon,
            color: readOnly ? Colors.grey[400] : Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: readOnly ? Colors.grey[200]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: readOnly ? Colors.grey[200]! : AppColors.accentOrange),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[50] : null,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _numberFormat = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (newValue.text != oldValue.text &&
        RegExp(r'\d').hasMatch(newValue.text)) {
      final String digitsOnly = newValue.text.replaceAll(',', '');

      if (oldValue.text.length > newValue.text.length &&
          oldValue.text.contains(',') &&
          !newValue.text.contains(',')) {
        return newValue;
      }

      String formatted = _numberFormat.format(int.parse(digitsOnly));

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
