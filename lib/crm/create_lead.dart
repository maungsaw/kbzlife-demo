import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/app_segmented_tabs.dart';
import '../widgets/app_text_field.dart';
import '../eapp/pickers.dart';
import 'create_model.dart';

class CreateLeadScreen extends ConsumerStatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  ConsumerState<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends ConsumerState<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  LeadType _leadType = LeadType.individual;

  // Personal Information
  final _nameController = TextEditingController();
  final _nrcController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String? _maritalStatus;
  final _jobTitleController = TextEditingController();

  // Address Information
  final _roomController = TextEditingController();
  final _buildingController = TextEditingController();
  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _wardController = TextEditingController();
  final _townController = TextEditingController();
  final _townshipController = TextEditingController();
  String? _stateRegion;

  // Company Information
  final _companyController = TextEditingController();
  final _headcountController = TextEditingController();
  final _industryController = TextEditingController();

  // Policy Details
  PolicyType? _policyType;
  final _premiumAmountController = TextEditingController();
  LeadStatus? _leadStatus;
  LeadPriority? _priority;
  final _affordabilityController = TextEditingController();

  // Products
  List<ProductModel> _selectedProducts = [];

  // Additional
  final _remarkController = TextEditingController();
  final _tagsController = TextEditingController();

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

  bool get _isIndividual => _leadType == LeadType.individual;

  String? get _addressSummary {
    final parts = [
      if (_roomController.text.isNotEmpty) 'Room ${_roomController.text}',
      if (_buildingController.text.isNotEmpty) 'Bldg ${_buildingController.text}',
      if (_houseController.text.isNotEmpty) 'No.${_houseController.text}',
      if (_streetController.text.isNotEmpty) '${_streetController.text} St',
      if (_wardController.text.isNotEmpty) 'Ward ${_wardController.text}',
      if (_townController.text.isNotEmpty) _townController.text,
      if (_townshipController.text.isNotEmpty) _townshipController.text,
      if (_stateRegion != null) _stateRegion!,
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nrcController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _jobTitleController.dispose();
    _roomController.dispose();
    _buildingController.dispose();
    _houseController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _townController.dispose();
    _townshipController.dispose();
    _companyController.dispose();
    _headcountController.dispose();
    _industryController.dispose();
    _premiumAmountController.dispose();
    _affordabilityController.dispose();
    _remarkController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _showProductBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductMultiSelectBottomSheet(
          availableProducts: _availableProducts,
          initiallySelected: List.from(_selectedProducts),
          onConfirm: (selected) => setState(() => _selectedProducts = selected),
        );
      },
    );
  }

  void _showAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Address',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.deep,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _roomController,
                      label: 'Room No',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      controller: _buildingController,
                      label: 'Building No',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _houseController,
                      label: 'House No *',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      controller: _streetController,
                      label: 'Street *',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _wardController,
                      label: 'Ward *',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppTextField(
                      controller: _townController,
                      label: 'Town',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppTextField(
                controller: _townshipController,
                label: 'Township *',
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'State/Region *',
                'Select',
                ['Yangon', 'Mandalay', 'Naypyidaw'],
                (val) => setState(() => _stateRegion = val),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        automaticallyImplyActions: true,
        backgroundColor: Colors.white,
        title: const Text(
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
                  // Offline Banner
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

                  // Lead Type Segmented Tabs
                  AppSegmentedTabs<LeadType>(
                    label: 'Lead Type *',
                    value: _leadType,
                    options: [
                      (LeadType.individual, 'Individual', Icons.person_outline),
                      (
                        LeadType.corporate,
                        'Corporate',
                        Icons.business_outlined,
                      ),
                    ],
                    onChanged: (val) => setState(() => _leadType = val),
                  ),
                  const SizedBox(height: 20),

                  // Personal Information
                  _buildSectionHeader('PERSONAL INFORMATION'),
                  _buildCard([
                    _buildTextField(
                      'LEAD PERSON NAME *',
                      'Enter full name',
                      _nameController,
                    ),
                    const SizedBox(height: 14),
                    if (_isIndividual) ...[
                      AppTextField(
                        controller: _nrcController,
                        label: 'Identification *',
                        hint: '12/KaMaNa(N)127487',
                        readOnly: true,
                        suffixIcon: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final result = await showIdentificationPickerSheet(
                            context,
                            initial: _nrcController.text,
                          );
                          if (result != null) {
                            setState(() => _nrcController.text = result);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _phoneController,
                            label: 'Mobile Phone No *',
                            hint: '',
                            keyboardType: TextInputType.phone,
                            showFlag: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            'EMAIL',
                            'email@example.com',
                            _emailController,
                          ),
                        ),
                      ],
                    ),
                    if (_isIndividual) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              'MARITAL STATUS',
                              'Select',
                              ['Single', 'Married', 'Divorced'],
                              (val) => setState(() => _maritalStatus = val),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'JOB TITLE',
                              'Job title',
                              _jobTitleController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // Address Information
                  _buildSectionHeader('ADDRESS INFORMATION'),
                  _buildCard([
                    AppTextField(
                      label: 'Address',
                      hint: 'Tap to enter address',
                      readOnly: true,
                      controller: TextEditingController(text: _addressSummary ?? ''),
                      suffixIcon: const Icon(Icons.chevron_right),
                      onTap: () => _showAddressSheet(),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Company & Job
                  _buildSectionHeader('COMPANY & JOB'),
                  _buildCard([
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
                        if (!_isIndividual) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              'INDUSTRY *',
                              'Industry type',
                              _industryController,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Policy Details
                  _buildSectionHeader('POLICY DETAILS'),
                  _buildCard([
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'POLICY TYPE *',
                            'Select',
                            ['New', 'Renewal'],
                            (val) => setState(
                              () => _policyType = val == 'New'
                                  ? PolicyType.newPolicy
                                  : PolicyType.renewal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            'PREMIUM AMOUNT',
                            'Estimated',
                            _premiumAmountController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'STATUS *',
                            'Select',
                            [
                              'New Lead',
                              'Contacted',
                              'Qualified',
                              'Negotiation',
                              'Won',
                              'Lost',
                            ],
                            (val) {
                              final statusMap = {
                                'New Lead': LeadStatus.newLead,
                                'Contacted': LeadStatus.contacted,
                                'Qualified': LeadStatus.qualified,
                                'Negotiation': LeadStatus.negotiation,
                                'Won': LeadStatus.won,
                                'Lost': LeadStatus.lost,
                              };
                              setState(() => _leadStatus = statusMap[val]);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            'PRIORITY *',
                            'Select',
                            ['Low', 'Medium', 'High'],
                            (val) {
                              final priorityMap = {
                                'Low': LeadPriority.low,
                                'Medium': LeadPriority.medium,
                                'High': LeadPriority.high,
                              };
                              setState(() => _priority = priorityMap[val]);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      'AFFORDABILITY',
                      'Free text',
                      _affordabilityController,
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Products
                  _buildProductsSection(),
                  const SizedBox(height: 20),

                  // Additional
                  _buildSectionHeader('ADDITIONAL INFO'),
                  _buildCard([
                    _buildTextField('REMARK', 'Add remark', _remarkController),
                    const SizedBox(height: 14),
                    _buildTextField('TAGS', 'Field and Value', _tagsController),
                  ]),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
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

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                _selectedProducts.isEmpty ? '+ Add Products' : 'Edit Products',
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap to select products',
                          style: TextStyle(
                            color: Colors.grey.shade400,
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
                      backgroundColor: AppColors.primaryColor.withValues(
                        alpha: 0.08,
                      ),
                      side: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(
                        () => _selectedProducts.removeWhere(
                          (p) => p.id == prod.id,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
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
                'Cancel',
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
    );
  }
}

// ==========================================
// PRODUCT MULTI-SELECT BOTTOM SHEET
// ==========================================
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
  final _searchController = TextEditingController();
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
// CRM CONTACTS LIST VIEW SCREEN
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
        title: const Text(
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
            if (result == true) _fetchContacts();
          },
        ),
      ),
    );
  }
}
