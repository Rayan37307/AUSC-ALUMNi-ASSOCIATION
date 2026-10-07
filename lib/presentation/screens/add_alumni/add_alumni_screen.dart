import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/year_selector.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_list_provider.dart';
import '../../providers/auth_provider.dart';

class AddAlumniScreen extends StatefulWidget {
  const AddAlumniScreen({super.key});

  @override
  State<AddAlumniScreen> createState() => _AddAlumniScreenState();
}

class _AddAlumniScreenState extends State<AddAlumniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  String _name = '';
  String _phone = '';
  String _currentAddress = '';
  String _permanentAddress = '';
  String _position = '';
  String _currentlyDoing = '';
  String _batchYear = DateTime.now().year.toString();
  String? _bloodGroup;
  bool _bloodGroupConsent = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start from the signed-in account's details.
    final auth = context.read<AuthProvider>();
    _name = auth.displayName;
    if (auth.phone.isNotEmpty) _phone = Phone.toLocal(auth.phone);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkBackground, AppColors.darkSurface]
                  : [
                      AppColors.primaryStart.withValues(alpha: 0.1),
                      AppColors.lightBackground,
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 24),
                  _buildBatchYearSelector(),
                  const SizedBox(height: 24),
                  _buildBloodGroupField(),
                  const SizedBox(height: 12),
                  _buildBloodGroupConsent(),
                  const SizedBox(height: 24),
                  _buildLocationFields(),
                  const SizedBox(height: 24),
                  _buildProfessionalFields(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      title: const Text('Add Alumni'),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _ModernTextField(
        label: 'Full Name',
        hint: 'Enter full name',
        icon: Icons.person_rounded,
        value: _name,
        onChanged: (value) => setState(() => _name = value),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Name is required';
          }
          return null;
        },
        onSaved: (value) => _name = value!.trim(),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _ModernTextField(
        label: 'Phone Number',
        hint: 'Enter phone number',
        icon: Icons.phone_rounded,
        value: _phone,
        onChanged: (value) => setState(() => _phone = value),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Phone number is required';
          }
          return null;
        },
        onSaved: (value) => _phone = value!.trim(),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget _buildBatchYearSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Select Batch Year',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          YearSelector(
            selectedYear: int.parse(_batchYear),
            onYearSelected: (year) {
              HapticFeedback.selectionClick();
              setState(() {
                _batchYear = year.toString();
              });
            },
            minYear: AppConstants.minBatchYear,
            maxYear: DateTime.now().year + 5,
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _ModernTextField(
        label: 'Blood Group (optional)',
        hint: 'e.g., A+, B-, AB+, O-',
        icon: Icons.bloodtype_rounded,
        value: _bloodGroup ?? '',
        // Only keep a value the member has explicitly agreed to share.
        onChanged: (value) => setState(
          () => _bloodGroup = _bloodGroupConsent && value.trim().isNotEmpty
              ? value.trim()
              : null,
        ),
        validator: (_) => null,
        onSaved: (value) => _bloodGroup = _bloodGroupConsent && value != null && value.trim().isNotEmpty
            ? value.trim()
            : null,
        textCapitalization: TextCapitalization.none,
      ),
    );
  }

  /// Blood type is health-adjacent personal data, so sharing it has to be an
  /// active choice rather than a default. Withdrawing the consent hides it from
  /// the directory again on the next save.
  Widget _buildBloodGroupConsent() {
    return InkWell(
      onTap: () => setState(() => _bloodGroupConsent = !_bloodGroupConsent),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _bloodGroupConsent,
                onChanged: (value) {
                  setState(() {
                    _bloodGroupConsent = value ?? false;
                    if (!_bloodGroupConsent) _bloodGroup = null;
                  });
                },
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Share my blood group so other members can contact me if I donate.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Current Address',
          hint: 'Where you live now',
          icon: Icons.location_on_rounded,
          value: _currentAddress,
          onChanged: (value) => setState(() => _currentAddress = value),
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Permanent Address',
          hint: 'Your home address',
          icon: Icons.home_rounded,
          value: _permanentAddress,
          onChanged: (value) => setState(() => _permanentAddress = value),
          textCapitalization: TextCapitalization.words,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildProfessionalFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Current Position',
          hint: 'e.g., Software Engineer, Student',
          icon: Icons.work_rounded,
          value: _position,
          onChanged: (value) => setState(() => _position = value),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          label: 'Currently Doing',
          hint: 'Describe what you are currently doing',
          icon: Icons.description_rounded,
          value: _currentlyDoing,
          onChanged: (value) => setState(() => _currentlyDoing = value),
          textCapitalization: TextCapitalization.sentences,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return _ModernTextField(
      label: label,
      hint: hint,
      icon: icon,
      value: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
    );
  }

  Widget _buildSubmitButton() {
    return GradientButton(
      text: 'Add Alumni',
      icon: Icons.add_rounded,
      isLoading: _isLoading,
      onPressed: _submitForm,
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final alumni = Alumni(
        id: '',
        name: _name,
        phone: _phone,
        currentAddress: _currentAddress,
        permanentAddress: _permanentAddress,
        position: _position,
        currentlyDoing: _currentlyDoing,
        batchYear: _batchYear,
        bloodGroup: _bloodGroup,
        createdAt: now,
        updatedAt: now,
      );

      await context.read<AlumniListProvider>().addAlumni(alumni);

      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alumni added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _ModernTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String value;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;

  const _ModernTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
  });

  @override
  State<_ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<_ModernTextField> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_ModernTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      onFocusChange: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: _isFocused
              ? LinearGradient(
                  colors: [
                    AppColors.primaryStart.withValues(alpha: 0.1),
                    AppColors.primaryEnd.withValues(alpha: 0.1),
                  ],
                )
              : null,
          border: Border.all(
            color: _isFocused
                ? AppColors.primary
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: _isFocused ? 2 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: TextFormField(
          controller: _controller,
          onChanged: widget.onChanged,
          validator: widget.validator,
          onSaved: widget.onSaved,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          maxLines: widget.maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isFocused
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: _isFocused
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                size: 20,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}