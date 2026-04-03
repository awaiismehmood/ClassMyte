import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classmyte/features/sms/providers/sms_providers.dart';
import 'package:classmyte/core/providers/device_provider.dart' as dev;
import 'package:classmyte/core/widgets/custom_dialog.dart';

class RemoteProcessLockCard extends ConsumerWidget {
  const RemoteProcessLockCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(smsProgressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceFuture = ref.watch(dev.deviceInfoProvider.future);

    return FutureBuilder<dev.DeviceInfo>(
      future: deviceFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final localId = snapshot.data!.id;

        // If something is sending but it's NOT this device
        if (progress.status == 'sending' && progress.deviceId != localId && progress.deviceId.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                  ? [Colors.orange.withOpacity(0.2), Colors.red.withOpacity(0.1)]
                  : [Colors.orange.shade50, Colors.red.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phonelink_lock, color: Colors.orange, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Process Detected',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                            ),
                          ),
                          Text(
                            'Sending from: ${progress.deviceName}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark ? Colors.orange.shade100.withOpacity(0.7) : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: progress.total > 0 ? progress.currentIndex / progress.total : 0,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${progress.currentIndex}/${progress.total}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        CustomDialog.show(
                          context: context,
                          title: 'Force Unlock?',
                          subtitle: 'Only do this if the other device is offline or crashed. This will allow this phone to send messages, but may cause duplicate SMS if the other device is still active.',
                          confirmText: 'Unlock Account',
                          confirmColor: Colors.red,
                          onConfirm: () {
                            ref.read(smsProgressProvider.notifier).reset();
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      child: Text(
                        'Force Reset',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
