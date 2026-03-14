import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/feature_home/domain/PasswordEntity.dart';
import '../../features/feature_home/domain/SiteCategory.dart';
import '../../features/feature_home/presentation/bloc/home_bloc.dart';
import '../../features/feature_home/presentation/bloc/home_event.dart';
import 'PasswordDetailsSheet.dart';

class PasswordCard extends StatefulWidget {
  final PasswordEntity item;

  const PasswordCard({super.key, required this.item});

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite(BuildContext context) {
    _controller.forward().then((_) {
      _controller.reverse();
    });

    context.read<PasswordBloc>().add(
          ToggleFavoritePassword(widget.item),
        );
  }

  @override
  Widget build(BuildContext context) {
    final color = SiteCategoryUI.color(widget.item.category);
    final icon = SiteCategoryUI.icon(widget.item.category);

    return GestureDetector(
      onTap: () => _showPasswordDetails(context),
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.015],
            colors: [
              color.withOpacity(0.9),
              Colors.white,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 12, 0),
          child: Row(
            children: [
              // Category Icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 25),
              ),

              const SizedBox(width: 16),
              /// Site & Username
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.site,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite Heart
              ScaleTransition(
                scale: _scale,
                child: IconButton(
                  icon: Icon(
                    widget.item.isfav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: widget.item.isfav ? Colors.redAccent : Colors.grey,
                    size: 25,
                  ),
                  onPressed: () => _toggleFavorite(context),
                  splashRadius: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasswordDetailsSheet(item: widget.item),
    );
  }
}

class SiteCategoryUI {
  static Color color(SiteCategory category) {
    switch (category) {
      case SiteCategory.email:
        return Colors.redAccent;
      case SiteCategory.chat:
        return Colors.green;
      case SiteCategory.social:
        return Colors.blue;
      case SiteCategory.banking:
        return Colors.purple;
      case SiteCategory.dating:
        return Colors.pink;
      case SiteCategory.shopping:
        return Colors.orange;
      case SiteCategory.entertainment:
        return Colors.deepPurple;
      case SiteCategory.app:
        return Colors.teal;
      case SiteCategory.website:
        return Colors.indigo;
      case SiteCategory.other:
        return Colors.grey.shade300;
      default:
        return Colors.grey;
    }
  }

  static IconData icon(SiteCategory category) {
    switch (category) {
      case SiteCategory.email:
        return Icons.email_rounded;
      case SiteCategory.chat:
        return Icons.chat_bubble_rounded;
      case SiteCategory.social:
        return Icons.people_alt_rounded;
      case SiteCategory.banking:
        return Icons.account_balance_rounded;
      case SiteCategory.dating:
        return Icons.favorite_rounded;
      case SiteCategory.shopping:
        return Icons.shopping_bag_rounded;
      case SiteCategory.entertainment:
        return Icons.movie_rounded;
      case SiteCategory.app:
        return Icons.apps_rounded;
      case SiteCategory.website:
        return Icons.language_rounded;
      case SiteCategory.other:
        return Icons.vpn_key_rounded;
      default:
        return Icons.vpn_key_rounded;
    }
  }
}