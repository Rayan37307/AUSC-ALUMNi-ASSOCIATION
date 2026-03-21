import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/themed_text.dart';
import '../../../core/widgets/year_selector.dart';
import '../../../data/models/alumni.dart';
import '../../providers/alumni_list_provider.dart';

/// Add Alumni Screen - Form to add a new alumni
class AddAlumniScreen extends StatefulWidget {
  const AddAlumniScreen({super.key});

  @override
  State<AddAlumniScreen> createState() => _AddAlumniScreenState();
}

class _AddAlumniScreenState extends State<AddAlumniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form fields
  String _name = '';
  String _phone = '';
  String _village = '';
  String _postOffice = '';
  String _upazila = '';
  String _district = '';
  String _position = '';
  String _currentlyDoing = '';
  String _achievements = '';
  String _batchYear = DateTime.now().year.toString();

  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ThemedText('Add Alumni'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter full name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              onSaved: (value) => _name = value!.trim(),
            ),

            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
              onSaved: (value) => _phone = value!.trim(),
            ),

            const SizedBox(height: 16),

            // Batch Year Selector
            const ThemedText(
              'Batch Year *',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            const SizedBox(height: 8),
            YearSelector(
              selectedYear: int.parse(_batchYear),
              onYearSelected: (year) {
                setState(() {
                  _batchYear = year.toString();
                });
              },
              minYear: AppConstants.minBatchYear,
              maxYear: DateTime.now().year + 5,
            ),

            const SizedBox(height: 24),

            // Location Section
            const ThemedText(
              'Location Information',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Village',
                hintText: 'Enter village name',
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.words,
              onSaved: (value) => _village = value?.trim() ?? '',
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Post Office',
                hintText: 'Enter post office',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
              onSaved: (value) => _postOffice = value?.trim() ?? '',
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Upazila',
                hintText: 'Enter upazila',
                prefixIcon: Icon(Icons.map),
              ),
              textCapitalization: TextCapitalization.words,
              onSaved: (value) => _upazila = value?.trim() ?? '',
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'District',
                hintText: 'Enter district',
                prefixIcon: Icon(Icons.location_city),
              ),
              textCapitalization: TextCapitalization.words,
              onSaved: (value) => _district = value?.trim() ?? '',
            ),

            const SizedBox(height: 24),

            // Professional Section
            const ThemedText(
              'Professional Information',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Current Position',
                hintText: 'e.g., Software Engineer, Student',
                prefixIcon: Icon(Icons.work),
              ),
              textCapitalization: TextCapitalization.words,
              onSaved: (value) => _position = value?.trim() ?? '',
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Currently Doing',
                hintText: 'Describe what you are currently doing',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onSaved: (value) => _currentlyDoing = value?.trim() ?? '',
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Achievements',
                hintText: 'List your achievements',
                prefixIcon: Icon(Icons.emoji_events),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              onSaved: (value) => _achievements = value?.trim() ?? '',
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: ThemedText(
                          'Add Alumni',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
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
        village: _village,
        postOffice: _postOffice,
        upazila: _upazila,
        district: _district,
        position: _position,
        currentlyDoing: _currentlyDoing,
        achievements: _achievements,
        batchYear: _batchYear,
        createdAt: now,
        updatedAt: now,
      );

      await context.read<AlumniListProvider>().addAlumni(alumni);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alumni added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
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
