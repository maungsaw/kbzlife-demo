// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/app_text_field.dart';
import 'create_model.dart';

class CreateLeadScreen extends ConsumerStatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  ConsumerState<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends ConsumerState<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nrcController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _townshipController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _headcountController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();

  String? _maritalStatus;
  String? _stateRegion;
  String? _industry;
  String? _leadType;

  // Selected products state
  List<ProductModel> _selectedProducts = [];

  // Available products master list
  // KBZ Life Insurance products master list
  final List<ProductModel> _availableProducts = [
    ProductModel(id: 'P01', name: 'Short Term Endowment', category: 'Savings'),
    ProductModel(id: 'P02', name: 'Universal Life', category: 'Savings'),
    ProductModel(id: 'P03', name: 'Education Life', category: 'Savings'),
    ProductModel(id: 'P04', name: 'Personal Accident', category: 'Protections'),
    ProductModel(id: 'P05', name: 'Critical Illness', category: 'Protections'),
    ProductModel(id: 'P06', name: 'Health', category: 'Medical Care'),
    ProductModel(id: 'P07', name: 'Group Life', category: 'Group Insurance'),
    ProductModel(id: 'P08', name: 'Credit Life', category: 'Protections'),
  ];

  void _showProductBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductMultiSelectBottomSheet(
          availableProducts: _availableProducts,
          initiallySelected: List.from(_selectedProducts),
          onConfirm: (selected) {
            setState(() {
              _selectedProducts = selected;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        automaticallyImplyActions: true,
        backgroundColor: Colors.white,
        title: Text(
          'New Lead',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFEEBA)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 16,
                          color: Color(0xFF856404),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Offline Mode • Will auto-sync when online',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PERSONAL INFORMATION',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          'LEAD PERSON NAME *',
                          'Enter full name',
                          _nameController,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'NRC',
                                '12/ABC(N)123456',
                                _nrcController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                'PHONE NO *',
                                '09xxxxxxxxx',
                                _phoneController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          'EMAIL',
                          'email@example.com',
                          _emailController,
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField('MARITAL STATUS', 'Select status', [
                          'Single',
                          'Married',
                          'Divorced',
                        ], (val) => setState(() => _maritalStatus = val)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ADDRESS INFORMATION',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'ROOM NO',
                                'Room',
                                _roomController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                'BUILDING NO',
                                'Building',
                                _buildingController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'HOUSE NO',
                                'House',
                                _houseController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                'STREET NO',
                                'Street',
                                _streetController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'WARD NO',
                                'Ward',
                                _wardController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                'TOWNSHIP *',
                                'Township',
                                _townshipController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField(
                          'STATE/REGION *',
                          'Select state/region',
                          ['Yangon', 'Mandalay', 'Naypyidaw'],
                          (val) => setState(() => _stateRegion = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'COMPANY & JOB',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          'COMPANY NAME *',
                          'Company name',
                          _companyController,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'HEAD COUNTS *',
                                'e.g. 50',
                                _headcountController,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                'JOB TITLE *',
                                'Job title',
                                _jobTitleController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Products Interest Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'INTERESTED PRODUCTS',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showProductBottomSheet,
                        child: Text(
                          _selectedProducts.isEmpty
                              ? '+ Add Products'
                              : 'Edit Products',
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _selectedProducts.isEmpty
                        ? InkWell(
                            onTap: _showProductBottomSheet,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 18,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Tap to select products',
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedProducts.map((prod) {
                              return Chip(
                                label: Text(
                                  prod.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: AppColors.primaryColor
                                    .withValues(alpha: 0.08),
                                side: BorderSide(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 14),
                                onDeleted: () {
                                  setState(() {
                                    _selectedProducts.removeWhere(
                                      (p) => p.id == prod.id,
                                    );
                                  });
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Save Draft',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty &&
                          _phoneController.text.isNotEmpty) {
                        if (context.mounted) context.pop(true);
                      }
                    },
                    child: const Text(
                      'Create Lead',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return AppTextField(controller: controller, label: label, hint: hint);
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.accentNavy,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
            filled: true,
            fillColor: AppColors.surfaceBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Multi-Select Bottom Sheet Widget
class _ProductMultiSelectBottomSheet extends StatefulWidget {
  final List<ProductModel> availableProducts;
  final List<ProductModel> initiallySelected;
  final ValueChanged<List<ProductModel>> onConfirm;

  const _ProductMultiSelectBottomSheet({
    required this.availableProducts,
    required this.initiallySelected,
    required this.onConfirm,
  });

  @override
  State<_ProductMultiSelectBottomSheet> createState() =>
      _ProductMultiSelectBottomSheetState();
}

class _ProductMultiSelectBottomSheetState
    extends State<_ProductMultiSelectBottomSheet> {
  late List<ProductModel> _tempSelected;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initiallySelected);
  }

  List<ProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.availableProducts;
    return widget.availableProducts
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentNavy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.muted),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.muted,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = _filteredProducts[index];
                    final isSelected = _tempSelected.any(
                      (p) => p.id == item.id,
                    );

                    return CheckboxListTile(
                      activeColor: AppColors.primaryColor,
                      value: isSelected,
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: item.category != null
                          ? Text(
                              item.category!,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _tempSelected.add(item);
                          } else {
                            _tempSelected.removeWhere((p) => p.id == item.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      widget.onConfirm(_tempSelected);
                      context.pop();
                    },
                    child: Text(
                      'Done (${_tempSelected.length} Selected)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ==========================================
// 4. CRM CONTACTS LIST VIEW SCREEN
// ==========================================
class CRMContactsScreen extends ConsumerStatefulWidget {
  const CRMContactsScreen({super.key});

  @override
  ConsumerState<CRMContactsScreen> createState() => _CRMContactsScreenState();
}

class _CRMContactsScreenState extends ConsumerState<CRMContactsScreen> {
  final CRMRepository _repository = CRMRepository();
  List<CRMContactModel> _contacts = [];
  bool _isLoading = true;
  final String _searchQuery = '';
  ContactType _selectedTab = ContactType.lead;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final data = await _repository.fetchContacts();
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  List<CRMContactModel> get _filteredContacts {
    return _contacts.where((c) {
      final matchesType = c.type == _selectedTab;
      final matchesSearch =
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery) ||
          c.id.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final leadsCount = _contacts
        .where((c) => c.type == ContactType.lead)
        .length;
    final clientsCount = _contacts
        .where((c) => c.type == ContactType.client)
        .length;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text(
          'New Lead',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Toggle Tabs
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == ContactType.lead
                              ? AppColors.primaryColor
                              : Colors.white,
                        ),
                        onPressed: () =>
                            setState(() => _selectedTab = ContactType.lead),
                        child: Text(
                          'Leads ($leadsCount)',
                          style: TextStyle(
                            color: _selectedTab == ContactType.lead
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == ContactType.client
                              ? AppColors.primaryColor
                              : Colors.white,
                        ),
                        onPressed: () =>
                            setState(() => _selectedTab = ContactType.client),
                        child: Text(
                          'Clients ($clientsCount)',
                          style: TextStyle(
                            color: _selectedTab == ContactType.client
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._filteredContacts.map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      child: ListTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.phone),
                        trailing: Text(contact.id),
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Tooltip(
        message: 'Create Lead',
        child: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.add_rounded, color: Colors.white),
          onPressed: () async {
            final result = await context.push<bool>(RoutePaths.crmCreateLead);
            if (result == true) {
              _fetchContacts();
            }
          },
        ),
      ),
    );
  }
}
