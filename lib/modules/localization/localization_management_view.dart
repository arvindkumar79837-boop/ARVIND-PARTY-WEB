import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/web_theme.dart';

class LocalizationManagementView extends StatefulWidget {
  const LocalizationManagementView({super.key});

  @override
  State<LocalizationManagementView> createState() => _LocalizationManagementViewState();
}

class _LocalizationManagementViewState extends State<LocalizationManagementView> {
  final ApiService _apiService = Get.find<ApiService>();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _localizationStrings = [];
  bool _isLoading = false;
  String? _selectedCategory;
  int _currentPage = 1;
  int _totalPages = 1;
  final int _itemsPerPage = 20;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchStrings();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _apiService.get('/localization/categories');
      if (response['success'] == true) {
        setState(() {
          _categories = List<String>.from(response['data']);
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _fetchStrings({bool resetPage = false}) async {
    if (resetPage) {
      setState(() {
        _currentPage = 1;
      });
    }

    setState(() => _isLoading = true);

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': _itemsPerPage.toString(),
      };

      if (_selectedCategory != null) {
        queryParams['category'] = _selectedCategory!;
      }

      if (_searchController.text.isNotEmpty) {
        queryParams['search'] = _searchController.text;
      }

      final response = await _apiService.get('/localization/strings', queryParams: queryParams);

      if (response['success'] == true) {
        final data = response['data'];
        setState(() {
          _localizationStrings = List<dynamic>.from(data['strings']);
          _totalPages = data['pagination']['pages'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching strings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _bulkImportStrings() async {
    try {
      final TextEditingController controller = TextEditingController();
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bulk Import Translations', style: TextStyle(color: WebTheme.textPrimary)),
          content: SizedBox(
            width: 600,
            height: 400,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Enter JSON array of translations:\n[\n  {\n    "key": "welcome_text",\n    "translations": {\n      "en": "Welcome",\n      "hi": "स्वागत हे"\n    },\n    "category": "common"\n  }\n]',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                try {
                  final parsed = jsonDecode(controller.text) as List;
                  Get.back(result: {'strings': parsed});
                } catch (e) {
                  Get.snackbar('Error', 'Invalid JSON format', backgroundColor: Colors.red, colorText: Colors.white);
                }
              },
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final response = await _apiService.post('/localization/strings/bulk-import', result);

        if (response['success'] == true) {
          final data = response['data'];
          Get.snackbar(
            'Import Complete',
            'Success: ${data['success']}, Failed: ${data['failed']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          await _fetchStrings(resetPage: true);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to import: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewString() async {
    try {
      final keyController = TextEditingController();
      final descController = TextEditingController();
      final categoryController = TextEditingController();
      final Map<String, TextEditingController> translationControllers = {};

      for (final lang in ['en', 'hi', 'ar']) {
        translationControllers[lang] = TextEditingController();
      }

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create Translation String', style: TextStyle(color: WebTheme.textPrimary)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: keyController,
                    decoration: const InputDecoration(labelText: 'Key *', hintText: 'e.g., welcome_text', border: OutlineInputBorder()),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'What is this text for?', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g., common, auth, home', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  const Text('Translations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: WebTheme.textPrimary)),
                  const SizedBox(height: 12),
                  ...translationControllers.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: '${entry.key.toUpperCase()} Translation',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.isEmpty || translationControllers['en']!.text.isEmpty) {
                  Get.snackbar('Error', 'Key and English translation are required', backgroundColor: Colors.red, colorText: Colors.white);
                  return;
                }

                final translations = <String, String>{};
                for (final entry in translationControllers.entries) {
                  if (entry.value.text.isNotEmpty) {
                    translations[entry.key] = entry.value.text;
                  }
                }

                Get.back(result: {
                  'key': keyController.text.trim(),
                  'description': descController.text.trim(),
                  'category': categoryController.text.trim().isEmpty ? 'common' : categoryController.text.trim(),
                  'translations': translations,
                });
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final response = await _apiService.post('/localization/strings', result);

        if (response['success'] == true) {
          Get.snackbar('Success', 'Translation string created', backgroundColor: Colors.green, colorText: Colors.white);
          await _fetchStrings(resetPage: true);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editString(dynamic item) async {
    try {
      final descController = TextEditingController(text: item['description'] ?? '');
      final Map<String, TextEditingController> translationControllers = {};

      final translations = item['translations'] as Map<String, dynamic>?;
      for (final lang in ['en', 'hi', 'ar', 'fr', 'es', 'de']) {
        final text = translations != null && translations[lang] != null ? translations[lang]['text'] ?? '' : '';
        translationControllers[lang] = TextEditingController(text: text);
      }

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Edit: ${item['key']}', style: const TextStyle(color: WebTheme.textPrimary)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  const Text('Translations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: WebTheme.textPrimary)),
                  const SizedBox(height: 12),
                  ...translationControllers.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: entry.value,
                          decoration: InputDecoration(
                            labelText: '${entry.key.toUpperCase()} Translation',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updatedTranslations = <String, String>{};
                for (final entry in translationControllers.entries) {
                  if (entry.value.text.isNotEmpty) {
                    updatedTranslations[entry.key] = entry.value.text;
                  }
                }

                Get.back(result: {
                  'description': descController.text.trim(),
                  'translations': updatedTranslations,
                });
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final response = await _apiService.put('/localization/strings/${item['_id']}', result);

        if (response['success'] == true) {
          Get.snackbar('Success', 'Translation updated', backgroundColor: Colors.green, colorText: Colors.white);
          await _fetchStrings();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteString(dynamic item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete', style: TextStyle(color: WebTheme.textPrimary)),
        content: Text('Delete "${item['key']}"? This action cannot be undone.', style: const TextStyle(color: WebTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);
      final response = await _apiService.delete('/localization/strings/${item['_id']}');

      if (response['success'] == true) {
        Get.snackbar('Success', 'Translation deleted', backgroundColor: Colors.green, colorText: Colors.white);
        await _fetchStrings(resetPage: true);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: WebTheme.backgroundLight,
        title: const Text('Localization Management', style: TextStyle(color: WebTheme.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: WebTheme.primaryOrange), onPressed: _createNewString, tooltip: 'Create String'),
          IconButton(icon: const Icon(Icons.upload_file, color: WebTheme.primaryOrange), onPressed: _bulkImportStrings, tooltip: 'Bulk Import'),
          IconButton(icon: const Icon(Icons.refresh, color: WebTheme.primaryOrange), onPressed: () => _fetchStrings(resetPage: true), tooltip: 'Refresh'),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildStringsList()),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: WebTheme.backgroundLight, border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by key...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: WebTheme.backgroundDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: WebTheme.textPrimary),
              onSubmitted: (_) => _fetchStrings(resetPage: true),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String?>(
            value: _selectedCategory,
            hint: const Text('All Categories', style: TextStyle(color: WebTheme.textPrimary)),
            dropdownColor: WebTheme.backgroundLight,
            style: const TextStyle(color: WebTheme.textPrimary),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Categories')),
              ..._categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))),
            ],
            onChanged: (value) {
              setState(() => _selectedCategory = value);
              _fetchStrings(resetPage: true);
            },
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _fetchStrings(resetPage: true),
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Apply'),
            style: ElevatedButton.styleFrom(backgroundColor: WebTheme.primaryOrange, foregroundColor: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildStringsList() {
    if (_isLoading && _localizationStrings.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: WebTheme.primaryOrange));
    }

    if (_localizationStrings.isEmpty) {
      return const Center(child: Text('No translation strings found', style: TextStyle(color: WebTheme.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _localizationStrings.length,
      itemBuilder: (context, index) {
        final item = _localizationStrings[index];
        final translations = item['translations'] as Map<String, dynamic>?;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: WebTheme.backgroundLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: WebTheme.primaryOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.translate, color: WebTheme.primaryOrange),
            ),
            title: Text(item['key'], style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace', color: WebTheme.textPrimary)),
            subtitle: Text('Category: ${item['category']}', style: const TextStyle(color: WebTheme.textSecondary, fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 20), onPressed: () => _editString(item), tooltip: 'Edit'),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteString(item), tooltip: 'Delete'),
              ],
            ),
            children: [
              if (translations != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: translations.entries.map((entry) {
                      final langData = entry.value as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(entry.key.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(langData['text'] ?? '', style: const TextStyle(color: WebTheme.textPrimary))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: WebTheme.backgroundLight, border: Border(top: BorderSide(color: Colors.white10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Page $_currentPage of $_totalPages', style: const TextStyle(color: WebTheme.textSecondary)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 1 ? () => _fetchStrings() : null,
                color: WebTheme.primaryOrange,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages ? () {
                  setState(() => _currentPage++);
                  _fetchStrings();
                } : null,
                color: WebTheme.primaryOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}