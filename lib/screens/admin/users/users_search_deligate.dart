import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:visible/controller/user_controller.dart';
import 'package:visible/model/users/user_model.dart';

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
          return _buildUserTile(user);
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
          return _buildUserTile(user);
        },
      );
    });
  }

  Widget _buildUserTile(Datum user) {
    return GestureDetector(
      // onTap: () =>
      //     Get.to(() => UserDetailedScreen(user: _convertDatumToData(user))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Text(
              (user.fullname ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          title: Text(
            user.fullname ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Text(
            user.email ?? 'No email',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          trailing: IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.blue),
              onPressed: () {}),
        ),
      ),
    );
  }
}
