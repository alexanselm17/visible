import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visible/controller/user_controller.dart';
import 'package:visible/screens/user/notification/notification_page.dart';

Widget buildNotificationIconAlt() {
  final UsersController controller = Get.find<UsersController>();

  return GestureDetector(
    onTap: () => Get.to(const NotificationPage()),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.notifications_outlined,
            color: Colors.black87,
            size: 20,
          ),
          // Alternative badge style with dot for single notification
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: controller.unreadCount.value == 1 ? 8 : null,
                  height: controller.unreadCount.value == 1 ? 8 : 18,
                  constraints: controller.unreadCount.value == 1
                      ? null
                      : const BoxConstraints(minWidth: 18),
                  padding: controller.unreadCount.value == 1
                      ? null
                      : const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(
                        controller.unreadCount.value == 1 ? 4 : 9),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: controller.unreadCount.value == 1
                      ? null
                      : Center(
                          child: Text(
                            controller.unreadCount.value > 99
                                ? '99+'
                                : controller.unreadCount.value.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    ),
  );
}
