import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/auth_screen.dart';
import '../../theme/app_tokens.dart';
import '../models/menu_models.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import 'cart_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).clear();
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
    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.watch(cartProvider);
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = menus[index];
                    final showHeader = index == 0 ||
                        item.category.id != menus[index - 1].category.id;
                    final cartIndex =
                        cart.indexWhere((c) => c.item.menuId == item.menuId);
                    final qtyInCart =
                        cartIndex >= 0 ? cart[cartIndex].quantity : 0;
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
                          qtyInCart: qtyInCart,
                          onAdd: () {
                            HapticFeedback.lightImpact();
                            cartNotifier.addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.menuName} added'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
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
      bottomNavigationBar: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: AppTokens.surface,
                border: Border(
                  top: BorderSide(color: AppTokens.cardBorder, width: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cart Subtotal',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTokens.mutedText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KSH ${cartNotifier.subtotal.toStringAsFixed(2)}',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTokens.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        ),
                        icon: const Icon(Icons.shopping_cart_rounded),
                        label: Text('View Cart (${cart.length})'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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
  final int qtyInCart;
  final VoidCallback onAdd;

  const _MenuItemCard({
    required this.item,
    required this.qtyInCart,
    required this.onAdd,
  });

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
          if (qtyInCart > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTokens.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'x$qtyInCart',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppTokens.gold,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
