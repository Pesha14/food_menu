import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';
import '../../theme/app_tokens.dart';
import '../../transactions/models/payment_method.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/screens/receipt_screen.dart';
import '../models/menu_models.dart';
import '../providers/menu_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) {
    // Step 6: clear JWT, staff info, and the selected menu, then return
    // to the login screen.
    ref.read(selectedMenuItemProvider.notifier).state = null;
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final menusAsync = ref.watch(availableMenusProvider);
    final staffName = session?.staff.fullName ?? '';

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            backgroundColor: AppTokens.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTokens.surface, AppTokens.bg],
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTokens.gold,
                  child: Text(
                    staffName.isNotEmpty ? staffName[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      color: AppTokens.bg,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Welcome, $staffName',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      color: AppTokens.ivory,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppTokens.mutedText,
                ),
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _CompanyCard(companyName: session?.staff.company.name ?? ''),
            ),
          ),
          menusAsync.when(
            data: (menus) {
              if (menus.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No menus available right now.',
                      style: TextStyle(color: AppTokens.mutedText),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = menus[index];
                    final showHeader = index == 0 ||
                        item.category.id != menus[index - 1].category.id;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              item.category.name.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTokens.gold,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ],
                        _MenuItemCard(
                          item: item,
                          onOrder: () => _confirmAndBuy(context, ref, item),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }, childCount: menus.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTokens.gold),
              ),
            ),
            error: (err, __) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load menus: $err',
                    style: const TextStyle(color: AppTokens.mutedText),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Steps 3 & 4 -- staff taps a meal, confirms, and the transaction is
  /// created immediately. One meal per transaction; the backend computes
  /// discount and amount payable.
  Future<void> _confirmAndBuy(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
  ) async {
    HapticFeedback.lightImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTokens.surface,
        title: Text('Confirm Purchase', style: GoogleFonts.playfairDisplay(color: AppTokens.ivory)),
        content: Text(
          'Buy "${item.menuName}" for KSH ${item.pricing.price}?',
          style: GoogleFonts.inter(color: AppTokens.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppTokens.mutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    ref.read(selectedMenuItemProvider.notifier).state = item;
    final session = ref.read(authProvider);
    if (session == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTokens.gold),
      ),
    );

    try {
      final transactionService = ref.read(transactionServiceProvider);
      final transaction = await transactionService.createTransaction(
        token: session.token,
        menuId: item.menuId,
        paymentMethod: PaymentMethod.cash,
      );

      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(transaction: transaction),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction failed: $e'),
          backgroundColor: AppTokens.danger,
        ),
      );
    }
  }
}

class _CompanyCard extends StatelessWidget {
  final String companyName;

  const _CompanyCard({required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTokens.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Company',
            style: GoogleFonts.inter(fontSize: 13, color: AppTokens.mutedText),
          ),
          Text(
            companyName,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTokens.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onOrder;

  const _MenuItemCard({required this.item, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTokens.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.ivory,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'KSH ${item.pricing.price}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTokens.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.pricing.discountable ? 'Discount Available' : 'No Discount',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.pricing.discountable
                        ? AppTokens.success
                        : AppTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onOrder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Order'),
          ),
        ],
      ),
    );
  }
}
