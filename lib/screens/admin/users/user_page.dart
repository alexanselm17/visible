import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';
import 'package:visible/controller/user_controller.dart';
import 'package:visible/model/users/user_model.dart';
import 'package:visible/screens/admin/users/users_search_deligate.dart';
import 'package:visible/screens/reports/customer_report.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  static const Color accentOrange = Color(0xFFFF7F00);

  final UsersController controller = Get.put(UsersController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool isSelectionMode = false;
  Set<String> selectedUsers = <String>{};

  @override
  void initState() {
    super.initState();
    init();
    _setupScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !controller.isFetchingMore.value &&
          controller.hasMoreData.value) {
        controller.getAllUsers();
      }
    });
  }

  init() async {
    await controller.getAllUsers(isRefresh: true);
  }

  Future<void> _refreshUsers() async {
    await controller.getAllUsers();
    _exitSelectionMode();
  }

  void _enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
      selectedUsers.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedUsers.clear();
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.add(userId);
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Datum> get filteredUsers {
    if (_searchQuery.isEmpty) return controller.users.toList().cast<Datum>();

    return controller.users
        .where((user) {
          final name = user.fullname?.toLowerCase() ?? '';
          final email = user.email?.toLowerCase() ?? '';
          final phone = user.phone?.toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();

          return name.contains(query) ||
              email.contains(query) ||
              phone.contains(query);
        })
        .toList()
        .cast<Datum>();
  }

  Future<void> _bulkActivateUsers() async {
    if (selectedUsers.isEmpty) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Activation'),
        content: Text(
            'Are you sure you want to activate ${selectedUsers.length} selected users?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Activate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (String userId in selectedUsers) {
        await controller.accountActivation(userId);
      }
      _exitSelectionMode();
    }
  }

  Future<void> _bulkDeactivateUsers() async {
    if (selectedUsers.isEmpty) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bulk Deactivation'),
        content: Text(
            'Are you sure you want to deactivate ${selectedUsers.length} selected users?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (String userId in selectedUsers) {
        await controller.accountActivation(userId);
      }
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isSelectionMode ? 'Select Users' : 'Users',
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
        actions: [
          if (!isSelectionMode)
            IconButton(
              onPressed: _enterSelectionMode,
              icon: const Icon(Icons.checklist),
              tooltip: 'Bulk Actions',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and Selection Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!isSelectionMode) ...[
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredUsers.length} users found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          child: const Text(
                            'Clear search',
                            style: TextStyle(color: accentOrange),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  // Selection Mode Bar
                  Row(
                    children: [
                      Text(
                        '${selectedUsers.length} selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _exitSelectionMode,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              selectedUsers.isEmpty ? null : _bulkActivateUsers,
                          icon:
                              const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('Activate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accentOrange,
                            side: const BorderSide(color: accentOrange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: selectedUsers.isEmpty
                              ? null
                              : _bulkDeactivateUsers,
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text('Deactivate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return _buildLoadingState();
              }

              if (controller.users.isEmpty && !controller.isLoading.value) {
                return _buildEmptyState();
              }

              return _buildUsersList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
          ),
          SizedBox(height: 16),
          Text(
            'Loading users...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.person_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No users found' : 'No users yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Users will appear here when they register',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return RefreshIndicator(
      onRefresh: _refreshUsers,
      color: accentOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        controller: _scrollController,
        itemCount: filteredUsers.length + 1,
        itemBuilder: (context, index) {
          if (index < filteredUsers.length) {
            return _buildUserCard(filteredUsers[index]);
          }

          if (controller.isFetchingMore.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading more users...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!controller.hasMoreData.value && filteredUsers.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No more users',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserCard(Datum user) {
    final isSelected = selectedUsers.contains(user.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? accentOrange : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (isSelectionMode) {
            _toggleUserSelection(user.id!);
          }
        },
        onLongPress: () {
          if (!isSelectionMode) {
            _enterSelectionMode();
            _toggleUserSelection(user.id!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  if (isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          _toggleUserSelection(user.id!);
                        },
                        activeColor: accentOrange,
                      ),
                    ),

                  // Avatar
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 20,
                    child: Text(
                      (user.fullname ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullname ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'No email',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.isActive == 1
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.isActive == 1 ? "Active" : "Inactive",
                      style: TextStyle(
                        color: user.isActive == 1
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Phone Number
              if (user.phone != null) ...[
                Text(
                  'Phone: ${user.phone}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Action Buttons
              if (!isSelectionMode)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(() => CustomerReport(
                              customerId: user.id!,
                              customerName: user.username!,
                            )),
                        icon: const Icon(Icons.assessment_outlined, size: 16),
                        label: const Text('Report'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.isLoading.value) return;
                          controller.accountActivation(user.id!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              user.isActive == 1 ? Colors.red : accentOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          user.isActive == 1 ? "Deactivate" : "Activate",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
