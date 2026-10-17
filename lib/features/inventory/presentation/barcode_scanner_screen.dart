import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/api/api_exception.dart';
import 'inventory_controller.dart';

/// Point the camera at a barcode. In the default (inventory) mode, a match
/// navigates straight to that product and no match offers "add new
/// product" pre-filled with the code. In [forCart] mode (POS), a match is
/// popped back to the caller to add to the cart instead, and no match just
/// reports an inline error — creating a product mid-sale is out of scope.
/// In [returnCode] mode, no lookup happens at all — the raw scanned code is
/// popped straight back to the caller, for filling in a form field (the
/// backend's uniqueness check catches an accidental duplicate on submit).
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen(
      {super.key, this.forCart = false, this.returnCode = false});

  final bool forCart;
  final bool returnCode;

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  bool _handling = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _handling = true;
      _error = null;
    });
    await _controller.stop();

    if (widget.returnCode) {
      if (mounted) context.pop(code);
      return;
    }

    try {
      final item =
          await ref.read(inventoryRepositoryProvider).lookupBarcode(code);

      if (!mounted) return;

      if (item != null) {
        if (widget.forCart) {
          context.pop(item);
        } else {
          context.pushReplacement('/inventory/${item.id}');
        }
      } else if (widget.forCart) {
        setState(() {
          _error = 'No product found for barcode $code.';
          _handling = false;
        });
        await _controller.start();
      } else {
        context.pushReplacement('/inventory/new', extra: {'barcode': code});
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _handling = false;
      });
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_handling)
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          if (_error != null)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Material(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
