import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../data/kyc_document_models.dart';
import 'settings_controller.dart';

class KycDocumentsScreen extends ConsumerStatefulWidget {
  const KycDocumentsScreen({super.key});

  @override
  ConsumerState<KycDocumentsScreen> createState() => _KycDocumentsScreenState();
}

class _KycDocumentsScreenState extends ConsumerState<KycDocumentsScreen> {
  String? _uploadingType;

  Future<void> _upload(String documentType) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2000,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() => _uploadingType = documentType);
    try {
      await ref
          .read(kycDocumentRepositoryProvider)
          .upload(documentType: documentType, file: File(picked.path));
      ref.invalidate(kycDocumentListProvider);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(kycDocumentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('KYC documents')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(kycDocumentListProvider),
        child: documentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text(
                  'Could not load documents.\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          data: (documents) {
            final byType = {for (final doc in documents) doc.documentType: doc};
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final entry in KycDocument.types.entries)
                  _DocumentTile(
                    label: entry.value,
                    document: byType[entry.key],
                    uploading: _uploadingType == entry.key,
                    onTap: () => _upload(entry.key),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.label,
    required this.document,
    required this.uploading,
    required this.onTap,
  });

  final String label;
  final KycDocument? document;
  final bool uploading;
  final VoidCallback onTap;

  Color _statusColor(String status) => switch (status) {
    'approved' => Colors.green,
    'rejected' => Colors.redAccent,
    _ => Colors.blueGrey,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        document != null ? Icons.description : Icons.upload_file_outlined,
      ),
      title: Text(label),
      subtitle: document != null
          ? Text(
              document!.statusLabel,
              style: TextStyle(color: _statusColor(document!.status)),
            )
          : const Text('Not uploaded'),
      trailing: uploading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(document != null ? Icons.refresh : Icons.camera_alt_outlined),
      onTap: uploading ? null : onTap,
    );
  }
}
