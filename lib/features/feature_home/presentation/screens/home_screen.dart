import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routes/appRoutes.dart';
import '../../../../core/widgits/AnimatedFab.dart';
import '../../../../core/widgits/DeleteDialog.dart';
import '../../../../core/widgits/EditPasswordDialog.dart';
import '../../../../core/widgits/EmptyVaultView.dart';
import '../../../../core/widgits/PasswordCard.dart';
import '../../../../core/widgits/PasswordFilter.dart';
import '../../../feature_privacyscreen/presentation/privacy_screen.dart';
import '../../domain/FilterPasswords.dart';
import '../../domain/PasswordEntity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {

  late final ScrollController _controller;
  late final ValueNotifier<bool> _showSearch;

  bool _locked = false;
  bool _showPrivacy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = ScrollController();
    _showSearch = ValueNotifier(false);

    _controller.addListener(_onScroll);
    // _enableSecure();
  }
  //
  // Future<void> _enableSecure() async {
  //   await FlutterWindowManager.addFlags(
  //     FlutterWindowManager.FLAG_SECURE,
  //   );
  // }
  //
  // Future<void> _disableSecure() async {
  //   await FlutterWindowManager.clearFlags(
  //     FlutterWindowManager.FLAG_SECURE,
  //   );
  // }

  void _onScroll() {
    final direction = _controller.position.userScrollDirection;

    if (_controller.offset <= 0 &&
        direction == ScrollDirection.forward &&
        !_locked) {
      _locked = true;
      _showSearch.value = true;
    }

    if (direction == ScrollDirection.reverse && _showSearch.value) {
      _showSearch.value = false;
      _locked = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _showSearch.dispose();
    // _disableSecure();
    super.dispose();
  }

  /// 🔐 App lifecycle (privacy screen)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      setState(() => _showPrivacy = true);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _showPrivacy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PasswordBloc>();

    if (bloc.state is PasswordInitial) {
      bloc.add(LoadPasswords());
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade100,
          floatingActionButton:
          AnimatedFab(bloc: context.read<PasswordBloc>()),
          body: CustomScrollView(
            controller: _controller,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _appBar(context),
              _animatedSearch(),
              _passwordList(),
            ],
          ),
        ),

        if (_showPrivacy) const PrivacyScreen(),
      ],
    );
  }

  Widget _appBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Secure Vault',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: Image.asset('assets/images/filter.png', height: 22),
          onPressed: () async {
            final bloc = context.read<PasswordBloc>();

            final selected = bloc.isFavoritesOnly
                ? PasswordFilter.favorites
                : PasswordFilter.all;

            await showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) {
                return PasswordFilterDialog(
                  selected: selected,
                  onSelected: (filter) {
                    bloc.add(
                      FilterPasswords(
                        filter == PasswordFilter.favorites,
                      ),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.settings);
          },
        ),
      ],
    );
  }

  Widget _animatedSearch() {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder<bool>(
        valueListenable: _showSearch,
        builder: (_, visible, __) {
          return AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: visible
                ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                height: 42,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by site name',
                    prefixIcon:
                    const Icon(Icons.search, size: 20),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (query) {
                    context
                        .read<PasswordBloc>()
                        .add(SearchPasswords(query));
                  },
                ),
              ),
            )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _passwordList() {
    return BlocBuilder<PasswordBloc, PasswordState>(
      builder: (context, state) {
        if (state is PasswordLoading || state is PasswordInitial) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is PasswordEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyVaultView(isFiltered: state.isFiltered),
          );
        }

        if (state is PasswordLoaded) {
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            sliver: SliverList.separated(
              itemCount: state.passwords.length,
              separatorBuilder: (_, _) =>
              const SizedBox(height: 2),
              itemBuilder: (context, index) {
                final item = state.passwords[index];

                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.horizontal,
                  background: _editBackground(),
                  secondaryBackground: _deleteBackground(),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await _confirmDelete(context);
                    } else {
                      _openEditDialog(context, item);
                      return false;
                    }
                  },
                  onDismissed: (_) {
                    context
                        .read<PasswordBloc>()
                        .add(DeletePassword(item.id!));
                  },
                  child: PasswordCard(item: item),
                );
              },
            ),
          );
        }

        return const SliverToBoxAdapter();
      },
    );
  }

  Widget _deleteBackground() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.red.shade600,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.delete, color: Colors.white),
        SizedBox(width: 8),
        Text(
          'Delete',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _editBackground() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.blue.shade600,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Edit',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 8),
        Icon(Icons.edit, color: Colors.white),
      ],
    ),
  );

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteDialog(),
    ) ??
        false;
  }

  void _openEditDialog(BuildContext context, PasswordEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PasswordBloc>(),
        child: EditPasswordDialog(item: item),
      ),
    );
  }
}

