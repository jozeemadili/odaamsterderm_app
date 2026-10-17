import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../auth/data/auth_models.dart';
import 'settings_controller.dart';

class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Staff accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<DukaUser>('/settings/staff/new');
          if (created != null) ref.invalidate(staffListProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(staffListProvider),
        child: staffAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            final message = e is ApiException && e.statusCode == 403
                ? 'Only the business owner can manage staff accounts.'
                : 'Could not load staff.\n$e';
            return ListView(
              children: [
                const SizedBox(height: 80),
                Center(child: Text(message, textAlign: TextAlign.center)),
              ],
            );
          },
          data: (staff) {
            if (staff.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(
                      child: Text('No staff added yet. Tap + to invite one.')),
                ],
              );
            }
            return ListView.separated(
              itemCount: staff.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = staff[index];
                return ListTile(
                  leading: const CircleIcon(),
                  title: Text(user.name),
                  subtitle: Text([
                    user.email,
                    if (user.phone != null) user.phone!
                  ].join(' · ')),
                  trailing:
                      Chip(label: Text(user.roleLabel ?? user.role ?? '—')),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(child: Icon(Icons.person_outline));
  }
}
