import 'dart:async';

import 'package:flutter/material.dart';

import '../../../shared/date_format.dart';
import '../data/notification_item.dart';
import '../data/notifications_source.dart';

/// Öğrencinin "çözüldü" bildirimleri; başlıkta okunmamış sayısı (USR 03).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    required this.source,
    this.onNotificationTap,
  });

  final NotificationsSource source;

  /// Bildirime dokununca (ör. ilgili bildirimin detayını açmak için).
  final ValueChanged<NotificationItem>? onNotificationTap;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _items = <NotificationItem>[];
  int _unreadCount = 0;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final result = await widget.source.fetchFirstPage();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      switch (result) {
        case NotificationsLoaded(:final items, :final unreadCount):
          _loadFailed = false;
          _unreadCount = unreadCount;
          _items
            ..clear()
            ..addAll(items);
        case NotificationsFailed():
          _loadFailed = true;
      }
    });
  }

  Future<void> _markRead(NotificationItem item) async {
    final marked = await widget.source.markRead(item.id);
    if (!mounted) return;
    if (!marked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İşaretlenemedi, tekrar deneyin')),
      );
      return;
    }
    setState(() {
      _items[_items.indexOf(item)] = item.markedRead();
      _unreadCount--;
    });
  }

  void _retry() {
    setState(() => _isLoading = true);
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Badge(
          isLabelVisible: _unreadCount > 0,
          // Ekran okuyucu yalnızca "1" demesin.
          label: Semantics(
            container: true,
            child: Text(
              '$_unreadCount',
              semanticsLabel: '$_unreadCount okunmamış bildirim',
            ),
          ),
          child: const Text('Bildirimler'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_loadFailed && _items.isEmpty) {
      return Center(
        child: TextButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Tekrar dene'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: _items.isEmpty
            ? const [
                SizedBox(height: 120),
                Center(child: Text('Henüz bildirim yok')),
              ]
            : [for (final item in _items) _buildTile(item)],
      ),
    );
  }

  Widget _buildTile(NotificationItem item) {
    final onTap = widget.onNotificationTap;
    return ListTile(
      onTap: onTap == null ? null : () => onTap(item),
      leading: Icon(
        Icons.check_circle,
        color: item.isRead ? Colors.grey : Colors.green,
        semanticLabel: item.isRead ? 'Okundu' : 'Okunmadı',
      ),
      title: Text(
        item.message,
        style: item.isRead
            ? null
            : const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(formatDate(item.createdAt)),
      trailing: item.isRead
          ? null
          : TextButton(
              onPressed: () => _markRead(item),
              child: const Text('Okundu'),
            ),
    );
  }
}
