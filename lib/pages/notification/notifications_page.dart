import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  final Function(String) onDeleteNotification;

  const NotificationsPage({
    Key? key,
    required this.notifications,
    required this.onDeleteNotification,
  }) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<Map<String, dynamic>>.from(widget.notifications);
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'].toString() == id);
    });
    widget.onDeleteNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 153, 0),
        title: const Text("الإشعارات"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _notifications),
        ),
        elevation: 2,
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "لا توجد إشعارات حالياً",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                final isUnread = n['is_read'] == false;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: isUnread
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 153, 0),
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      title: Text(
                        n['title'] ?? "بدون عنوان",
                        style: TextStyle(
                          fontWeight: isUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        n['body'] ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: const Color.fromARGB(255, 255, 153, 0),
                        ),
                        onPressed: () =>
                            _deleteNotification(n['id'].toString()),
                      ),
                      onTap: () {
                        // ممكن تضيف هنا فتح تفاصيل الإشعار إذا تحب
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
