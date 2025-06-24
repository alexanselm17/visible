import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/constants/colors.dart';

import 'package:visible/controller/user_controller.dart';
import 'package:visible/model/users/user_model.dart';
import 'package:visible/screens/reports/customer_report.dart';

class UserSearchDelegate extends SearchDelegate<String?> {
  final UsersController controller = Get.find();

  UserSearchDelegate()
      : super(
          searchFieldLabel: 'Search users...',
          searchFieldStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, size: 22),
          onPressed: () {
            query = '';
            controller.searchUser.clear();
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 24),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState('Search for users', Icons.search);
    }

    controller.searchUsers(query: query);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.searchUser.isEmpty) {
        return _buildEmptyState('No users found', Icons.person_off_outlined);
      }

      return ListView.builder(
        itemCount: controller.searchUser.length,
        itemBuilder: (context, index) {
          final user = controller.searchUser[index];
          return _buildUserCard(user);
        },
      );
    });
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState('Search for users', Icons.search);
    }

    controller.searchUsers(query: query);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.searchUser.isEmpty) {
        return _buildEmptyState('No users found', Icons.person_off_outlined);
      }

      return ListView.builder(
        itemCount: controller.searchUser.length,
        itemBuilder: (context, index) {
          final user = controller.searchUser[index];
          return _buildUserCard(user);
        },
      );
    });
  }

  Widget _buildUserCard(Datum user) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    child: Text(
                      (user.fullname ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.isActive == 1
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
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
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.phone!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => Get.to(CustomerReport(
                      customerId: user.id!,
                      customerName: user.username!,
                    )),
                    icon: const Icon(Icons.assessment_outlined, size: 16),
                    label: const Text('Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      side: const BorderSide(color: AppColors.darkBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.isLoading.value) return;
                      controller.accountActivation(user.id!);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          user.isActive == 1 ? Colors.red : AppColors.darkBlue,
                      foregroundColor: AppColors.pureWhite,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      user.isActive == 1 ? "Deactivate" : "Activate",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
