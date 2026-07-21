// ═══════════════════════════════════════════════════════════════════════════
// VIEW: FamiliesView — Admin panel: manage families (list, ban, delete)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import 'family_details_view.dart';

class FamiliesView extends StatefulWidget {
  const FamiliesView({super.key});

  @override
  State<FamiliesView> createState() => _FamiliesViewState();
}

class _FamiliesViewState extends State<FamiliesView> {
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _families = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _statusFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFamilies();
  }

  Future<void> _loadFamilies() async {
    setState(() => _isLoading = true);
    try {
      final params = <String, String>{
        'page': _currentPage.toString(),
        'limit': '20',
      };
      if (_statusFilter != 'all') {
        params['status'] = _statusFilter;
      }
      if (_searchQuery.isNotEmpty) {
        params['search'] = _searchQuery;
      }
      final response = await _apiService.get(
        '/families/admin/all',
        queryParams: params,
      );
      if (response['success'] == true) {
        setState(() {
          _families = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _totalPages = response['totalPages'] ?? 1;
          _currentPage = response['page'] ?? 1;
        });
      }
    } catch (e) {
      debugPrint('Error loading families: $e');
    }
    setState(() => _isLoading = false);
  }



  Future<void> _toggleBanFamily(Map<String, dynamic> family) async {
    final willActivate = !(family['is_active'] ?? false);

    try {
      final response = await _apiService.patch(
        '/families/admin/${family['_id']}/toggle',
      );
      if (response['success'] == true) {
        Get.snackbar('Success', willActivate ? 'Family activated' : 'Family deactivated');
        _loadFamilies();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update status');
      }
    } catch (e) { debugPrint('Error: $e'); Get.snackbar('Error', 'Failed to update family status'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Family Management', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF252542),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFamilies,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : Column(
              children: [
                // Filters
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252542),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildFilterTab('All', 'all'),
                      _buildFilterTab('Active', 'active'),
                      _buildFilterTab('Banned', 'banned'),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: TextEditingController(text: _searchQuery)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: _searchQuery.length),
                      ),
                    onChanged: (val) {
                      _searchQuery = val;
                      _currentPage = 1;
                      _loadFamilies();
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search families...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF252542),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Families List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _families.length,
                    itemBuilder: (context, index) {
                      final family = _families[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xFF252542),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFF8906),
                            child: Text(
                              (family['family_badge'] ?? 'TA').substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            family['family_name'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: ${family['familyId']} | Level: ${family['current_level']} | Members: ${(family['members_list'] ?? []).length}/${family['memberCount']}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              if (family['is_active'] == false)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: const Text(
                                    'INACTIVE',
                                    style: TextStyle(color: Colors.red, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {
                                  Get.to(() => FamilyDetailsView(familyId: family['familyId']));
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  family['is_active'] == true ? Icons.toggle_on : Icons.toggle_off,
                                  color: family['is_active'] == true ? Colors.green : Colors.red,
                                ),
                                onPressed: () => _toggleBanFamily(family),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Pagination
                if (_totalPages > 1)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1 ? () {
                            setState(() => _currentPage--);
                            _loadFamilies();
                          } : null,
                          child: const Text('Previous', style: TextStyle(color: Colors.white)),
                        ),
                        Text('Page $_currentPage of $_totalPages', style: const TextStyle(color: Colors.grey)),
                        TextButton(
                          onPressed: _currentPage < _totalPages ? () {
                            setState(() => _currentPage++);
                            _loadFamilies();
                          } : null,
                          child: const Text('Next', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _statusFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _statusFilter = value;
            _currentPage = 1;
          });
          _loadFamilies();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF8906) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}