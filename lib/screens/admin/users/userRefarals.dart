import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/controller/authentication_controller.dart';
import 'package:visible/model/users/user_model.dart';
import 'package:visible/screens/reports/customer_report.dart';

class UserReferrals extends StatefulWidget {
  final String? userId;
  final String userName;

  const UserReferrals({super.key, this.userId, required this.userName});

  @override
  State<UserReferrals> createState() => _UserReferralsState();
}

class _UserReferralsState extends State<UserReferrals> {
  static const Color accentOrange = Color(0xFFFF7F00);

  final AuthenticationController controller =
      Get.put(AuthenticationController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool isSelectionMode = false;
  Set<String> selectedUsers = <String>{};
  Timer? _paginationTimer;

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
    _paginationTimer?.cancel();
    super.dispose();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          controller.hasMoreData.value &&
          !controller.isFetchingMore.value) {
        // Debounce pagination calls
        _paginationTimer?.cancel();
        _paginationTimer = Timer(const Duration(milliseconds: 200), () {
          controller.getUserReferrals(
            userId: widget.userId!,
            isRefresh: false,
          );
        });
      }
    });
  }

  Future<void> init() async {
    if (widget.userId != null) {
      await controller.getUserReferrals(
          userId: widget.userId!, isRefresh: true);
    }
  }

  Future<void> _refreshUsers() async {
    if (widget.userId != null) {
      await controller.getUserReferrals(
          userId: widget.userId!, isRefresh: true);
      _exitSelectionMode();
    }
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

    final query = _searchQuery.toLowerCase();
    return controller.users
        .where((user) {
          final name = user.fullname?.toLowerCase() ?? '';
          final email = user.email?.toLowerCase() ?? '';
          final phone = user.phone?.toLowerCase() ?? '';
          return name.contains(query) ||
              email.contains(query) ||
              phone.contains(query);
        })
        .toList()
        .cast<Datum>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${widget.userName} Referrals',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          _buildSearchOrSelectionBar(),
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

  Widget _buildSearchOrSelectionBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isSelectionMode) ...[
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredUsers.length} users found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (_searchQuery.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    child: const Text('Clear search',
                        style: TextStyle(color: accentOrange)),
                  ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Text(
                  '${selectedUsers.length} selected',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                    onPressed: _exitSelectionMode, child: const Text('Cancel')),
              ],
            ),
          ],
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
              valueColor: AlwaysStoppedAnimation<Color>(accentOrange)),
          SizedBox(height: 16),
          Text('Loading users...',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                  color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Users will appear here when they register',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(height: 8),
                    Text('Loading more users...',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            );
          }
          if (!controller.hasMoreData.value && filteredUsers.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No more users',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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
          if (isSelectionMode) _toggleUserSelection(user.id!);
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
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    radius: 20,
                    child: Text(
                      (user.fullname ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                          color: Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullname ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(user.email ?? 'No email',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              if (user.phone != null) ...[
                Text('Phone: ${user.phone}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 12),
              ],
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
                              borderRadius: BorderRadius.circular(6)),
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
