import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../data/notification_models.dart';
import 'notification_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(notificationsFeedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/notifications/report-damage'),
        icon: const Icon(Icons.report_gmailerrorred_outlined),
        label: const Text('Report damage'),
      ),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Could not load notifications.\n$e',
                textAlign: TextAlign.center)),
        data: (feed) => feed.count == 0 && feed.damagedItems.isEmpty
            ? const Center(
                child: Text('Nothing to see here — all clear.',
                    style: TextStyle(color: DukaColors.muted)))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(notificationsFeedProvider.future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (feed.lowStockItems.isNotEmpty)
                      _Section(
                        title: 'Low stock',
                        icon: Icons.warning_amber_rounded,
                        color: DukaColors.rose,
                        children: [
                          for (final item in feed.lowStockItems)
                            _ProductTile(
                              imageUrl: item.imageUrl,
                              title: item.name,
                              subtitle: item.branch?.name,
                              trailing:
                                  '${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''}',
                              trailingColor: DukaColors.rose,
                              onTap: () =>
                                  context.push('/inventory/${item.id}'),
                            ),
                        ],
                      ),
                    if (feed.expiringSoonItems.isNotEmpty)
                      _Section(
                        title: 'Expiring soon',
                        icon: Icons.event_busy,
                        color: DukaColors.indigo,
                        children: [
                          for (final item in feed.expiringSoonItems)
                            _ProductTile(
                              imageUrl: item.imageUrl,
                              title: item.name,
                              subtitle: item.branch?.name,
                              trailing: item.expiryDate != null
                                  ? DateFormat('dd MMM')
                                      .format(DateTime.parse(item.expiryDate!))
                                  : '',
                              trailingColor: DukaColors.indigo,
                              onTap: () =>
                                  context.push('/inventory/${item.id}'),
                            ),
                        ],
                      ),
                    if (feed.damagedItems.isNotEmpty)
                      _Section(
                        title: 'Damaged / written off',
                        icon: Icons.broken_image_outlined,
                        color: DukaColors.muted,
                        children: [
                          for (final report in feed.damagedItems)
                            _DamageTile(report: report),
                        ],
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(
      {required this.title,
      required this.icon,
      required this.color,
      required this.children});

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 17, color: color),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
              const SizedBox(height: 4),
              ...children,
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.title,
    required this.trailing,
    required this.trailingColor,
    required this.onTap,
    this.imageUrl,
    this.subtitle,
  });

  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String trailing;
  final Color trailingColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const _ImagePlaceholder(),
                    )
                  : const _ImagePlaceholder(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DukaColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 11, color: DukaColors.muted)),
                ],
              ),
            ),
            Text(trailing,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: trailingColor)),
          ],
        ),
      ),
    );
  }
}

class _DamageTile extends StatelessWidget {
  const _DamageTile({required this.report});

  final DamageReport report;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: report.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: report.photoUrl!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.productName ?? 'Unknown product',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DukaColors.ink)),
                if (report.description != null &&
                    report.description!.isNotEmpty)
                  Text(report.description!,
                      style: const TextStyle(
                          fontSize: 11, color: DukaColors.muted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                Text(
                  [
                    if (report.branchName != null) report.branchName!,
                    if (report.reportedBy != null)
                      'by ${report.reportedBy}',
                    if (report.reportedAt != null) report.reportedAt!,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 10.5, color: DukaColors.muted),
                ),
              ],
            ),
          ),
          Text('-${report.quantity.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: DukaColors.rose)),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      color: DukaColors.bg,
      child:
          const Icon(Icons.inventory_2_outlined, size: 16, color: DukaColors.muted),
    );
  }
}
