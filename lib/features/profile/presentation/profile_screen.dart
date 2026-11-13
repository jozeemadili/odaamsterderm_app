import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/locale_controller.dart';
import '../../../app/theme.dart';
import '../../../app/theme_mode_controller.dart';
import '../../../core/api/api_exception.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../market/presentation/location_sheet.dart';
import '../../market/presentation/market_controller.dart';
import '../data/profile_repository.dart';

final _versionProvider = FutureProvider.autoDispose(
  (ref) async => (await PackageInfo.fromPlatform()).version,
);

/// The signed-in person's profile: photo, details, password, light/dark,
/// language, location and log out. Customers see it as their Account tab;
/// seller staff open it from More.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  void _saved(DukaUser user, String message) {
    ref.read(authControllerProvider.notifier).updateUser(user);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _failed(Object e) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$e')));

  Future<void> _changePhoto(DukaUser user) async {
    final l10n = context.l10n;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.profileTakePhoto),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileChoosePhoto),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (user.avatarUrl != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: DukaColors.rose),
                title: Text(
                  l10n.profileRemovePhoto,
                  style: const TextStyle(color: DukaColors.rose),
                ),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    try {
      if (choice == 'remove') {
        setState(() => _uploading = true);
        _saved(await _repo.removeAvatar(), l10n.profilePhotoUpdated);
        return;
      }
      final photo = await ImagePicker().pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (photo == null || !mounted) return;
      setState(() => _uploading = true);
      _saved(await _repo.uploadAvatar(photo), l10n.profilePhotoUpdated);
    } catch (e) {
      if (mounted) _failed(e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _editField({
    required String title,
    required String field,
    required String? initial,
    TextInputType keyboard = TextInputType.text,
    String? hint,
    required String? Function(String) validate,
  }) async {
    final l10n = context.l10n;
    final user = await showModalBottomSheet<DukaUser>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditSheet(
        title: title,
        initial: initial ?? '',
        keyboard: keyboard,
        hint: hint,
        validate: validate,
        save: (value) => _repo.update(
          name: field == 'name' ? value : null,
          phone: field == 'phone' ? value : null,
          email: field == 'email' ? value : null,
        ),
        field: field,
      ),
    );
    if (user != null && mounted) _saved(user, l10n.profileSaved);
  }

  Future<void> _changePassword(DukaUser user) async {
    final l10n = context.l10n;
    final updated = await showModalBottomSheet<DukaUser>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PasswordSheet(
        needsCurrent: user.hasPassword,
        save: (current, password, confirmation) => _repo.changePassword(
          current: current,
          password: password,
          confirmation: confirmation,
        ),
      ),
    );
    if (updated != null && mounted) {
      _saved(updated, l10n.profilePasswordChanged);
    }
  }

  Future<void> _logout() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profileLogout),
        content: Text(l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.profileCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: DukaColors.rose),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.profileLogout),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    if (user == null) return const Scaffold();

    final mode = ref.watch(themeModeProvider);
    final locale =
        ref.watch(localeControllerProvider)?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final location = ref.watch(marketLocationProvider);
    final version = ref.watch(_versionProvider).valueOrNull;

    return Scaffold(
      backgroundColor: DukaColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              user: user,
              uploading: _uploading,
              canPop: context.canPop(),
              roleLabel: user.isCustomer
                  ? l10n.profileCustomer
                  : (user.roleLabel ?? ''),
              onPhoto: () => _changePhoto(user),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.list(
              children: [
                _Section(
                  title: l10n.profileSectionAccount,
                  children: [
                    _Tile(
                      icon: Icons.person_outline,
                      tint: DukaColors.maroonTint,
                      color: DukaColors.indigo,
                      title: l10n.profileName,
                      value: user.name,
                      onTap: () => _editField(
                        title: l10n.profileName,
                        field: 'name',
                        initial: user.name,
                        validate: (v) =>
                            v.trim().isEmpty ? l10n.profileRequired : null,
                      ),
                    ),
                    _Tile(
                      icon: Icons.phone_outlined,
                      tint: DukaColors.leafTint,
                      color: DukaColors.leafDeep,
                      title: l10n.profilePhone,
                      value: user.phone ?? l10n.profileNotSet,
                      onTap: () => _editField(
                        title: l10n.profilePhone,
                        field: 'phone',
                        initial: user.phone,
                        keyboard: TextInputType.phone,
                        hint: l10n.profilePhoneHint,
                        validate: (v) =>
                            RegExp(r'^\+?[0-9 ]{7,20}$').hasMatch(v.trim())
                            ? null
                            : l10n.profileInvalidPhone,
                      ),
                    ),
                    _Tile(
                      icon: Icons.mail_outline,
                      tint: DukaColors.maroonTint,
                      color: DukaColors.indigo,
                      title: l10n.profileEmail,
                      value: user.email,
                      onTap: () => _editField(
                        title: l10n.profileEmail,
                        field: 'email',
                        initial: user.email,
                        keyboard: TextInputType.emailAddress,
                        validate: (v) =>
                            RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(v.trim())
                            ? null
                            : l10n.profileInvalidEmail,
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: l10n.profileSectionSecurity,
                  children: [
                    _Tile(
                      icon: Icons.lock_outline,
                      tint: DukaColors.leafTint,
                      color: DukaColors.leafDeep,
                      title: user.hasPassword
                          ? l10n.profileChangePassword
                          : l10n.profileSetPassword,
                      value: user.hasPassword
                          ? '••••••••'
                          : l10n.profileSetPasswordHint,
                      onTap: () => _changePassword(user),
                    ),
                  ],
                ),
                _Section(
                  title: l10n.profileSectionPreferences,
                  children: [
                    _ChoiceTile(
                      icon: Icons.dark_mode_outlined,
                      title: l10n.profileAppearance,
                      segments: [
                        (ThemeMode.system, l10n.profileThemeSystem),
                        (ThemeMode.light, l10n.profileThemeLight),
                        (ThemeMode.dark, l10n.profileThemeDark),
                      ],
                      selected: mode,
                      onSelected: (m) =>
                          ref.read(themeModeProvider.notifier).setMode(m),
                    ),
                    _ChoiceTile(
                      icon: Icons.translate,
                      title: l10n.profileLanguage,
                      segments: const [('en', 'English'), ('sw', 'Kiswahili')],
                      selected: locale,
                      onSelected: (code) => ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(Locale(code)),
                    ),
                    _Tile(
                      icon: Icons.location_on_outlined,
                      tint: DukaColors.maroonTint,
                      color: DukaColors.indigo,
                      title: l10n.profileLocation,
                      value: location == null
                          ? l10n.marketSetLocation
                          : (location.label ?? l10n.marketMyLocation),
                      onTap: () => showMarketLocationSheet(context),
                    ),
                  ],
                ),
                if (user.isCustomer)
                  _Section(
                    title: l10n.profileSectionShopping,
                    children: [
                      _Tile(
                        icon: Icons.receipt_long_outlined,
                        tint: DukaColors.leafTint,
                        color: DukaColors.leafDeep,
                        title: l10n.accountOrders,
                        value: l10n.ordersTitle,
                        onTap: () => context.push('/my-orders'),
                      ),
                      _Tile(
                        icon: Icons.shopping_cart_outlined,
                        tint: DukaColors.maroonTint,
                        color: DukaColors.indigo,
                        title: l10n.navCart,
                        onTap: () => context.push('/cart'),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DukaColors.rose,
                    side: BorderSide(
                      color: DukaColors.rose.withValues(alpha: .4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.profileLogout),
                ),
                if (version != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Amsterdam Digital · ${l10n.profileVersion(version)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: DukaColors.muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Maroon band with the photo, name, email and role.
class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.uploading,
    required this.canPop,
    required this.roleLabel,
    required this.onPhoto,
  });

  final DukaUser user;
  final bool uploading;
  final bool canPop;
  final String roleLabel;
  final VoidCallback onPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DukaColors.maroon, DukaColors.brandDark],
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
            child: Column(
              children: [
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      if (canPop)
                        IconButton(
                          color: Colors.white,
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                        )
                      else
                        const SizedBox(width: 12),
                      Text(
                        l10n.profileTitle,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: uploading ? null : onPhoto,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [DukaColors.leaf, Colors.white],
                          ),
                        ),
                        child: ClipOval(
                          child: Container(
                            color: const Color(0xFFF6E4E6),
                            child: uploading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : user.avatarUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: user.avatarUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Text(
                                      initials,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: DukaColors.maroon,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: 2,
                        child: Tooltip(
                          message: l10n.profileEditPhoto,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: DukaColors.leaf,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DukaColors.brandDark,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo_camera,
                              size: 16,
                              color: Color(0xFF1B2A0A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 13,
                  ),
                ),
                if (roleLabel.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DukaColors.leaf.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: DukaColors.leaf.withValues(alpha: .5),
                      ),
                    ),
                    child: Text(
                      roleLabel,
                      style: const TextStyle(
                        color: Color(0xFFC9E89E),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A titled, rounded group of rows.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
                color: DukaColors.muted,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: DukaColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DukaColors.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: 62),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.tint,
    required this.color,
  });

  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, size: 19, color: color),
  );
}

/// A row: tinted icon, label, current value, chevron.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.tint,
    required this.color,
    required this.title,
    this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color color;
  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            _IconBadge(icon: icon, tint: tint, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: DukaColors.ink,
                    ),
                  ),
                  if (value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        value!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: DukaColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: DukaColors.muted),
          ],
        ),
      ),
    );
  }
}

/// A row with a segmented choice underneath (appearance, language).
class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.segments,
    required this.selected,
    required this.onSelected,
  });

  final IconData icon;
  final String title;
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: icon,
                tint: DukaColors.leafTint,
                color: DukaColors.leafDeep,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: DukaColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: DukaColors.soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                for (final (value, label) in segments)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSelected(value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: value == selected
                              ? DukaColors.card
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: value == selected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: value == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: value == selected
                                ? DukaColors.indigo
                                : DukaColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet editing one profile field, showing server errors inline.
class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.title,
    required this.initial,
    required this.keyboard,
    required this.validate,
    required this.save,
    required this.field,
    this.hint,
  });

  final String title;
  final String initial;
  final TextInputType keyboard;
  final String? hint;
  final String field;
  final String? Function(String) validate;
  final Future<DukaUser> Function(String) save;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final _controller = TextEditingController(text: widget.initial);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    final error = widget.validate(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = await widget.save(value);
      if (mounted) Navigator.pop(context, user);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.fieldError(widget.field) ?? e.message);
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: widget.keyboard,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: _error,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.profileSave),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to change (or, for Google accounts, set) the password.
class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet({required this.needsCurrent, required this.save});

  final bool needsCurrent;
  final Future<DukaUser> Function(String?, String, String) save;

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _errors = <String, String?>{};
  bool _saving = false;
  bool _show = false;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    setState(() {
      _errors
        ..clear()
        ..addAll({
          if (widget.needsCurrent && _current.text.isEmpty)
            'current_password': l10n.profileRequired,
          if (_password.text.length < 8)
            'password': l10n.profilePasswordTooShort,
          if (_confirm.text != _password.text)
            'password_confirmation': l10n.profilePasswordMismatch,
        });
    });
    if (_errors.isNotEmpty) return;

    setState(() => _saving = true);
    try {
      final user = await widget.save(
        widget.needsCurrent ? _current.text : null,
        _password.text,
        _confirm.text,
      );
      if (mounted) Navigator.pop(context, user);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errors['current_password'] = e.fieldError('current_password');
          _errors['password'] = e.fieldError('password') ?? e.message;
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String key, String label, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      obscureText: !_show,
      autofillHints: [
        key == 'current_password'
            ? AutofillHints.password
            : AutofillHints.newPassword,
      ],
      decoration: InputDecoration(
        labelText: label,
        errorText: _errors[key],
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: key == 'password'
            ? IconButton(
                onPressed: () => setState(() => _show = !_show),
                icon: Icon(
                  _show
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : null,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.needsCurrent
                  ? l10n.profileChangePassword
                  : l10n.profileSetPassword,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (!widget.needsCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.profileSetPasswordHint,
                  style: TextStyle(color: DukaColors.muted, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            if (widget.needsCurrent)
              _field('current_password', l10n.profileCurrentPassword, _current),
            _field('password', l10n.profileNewPassword, _password),
            _field(
              'password_confirmation',
              l10n.profileConfirmPassword,
              _confirm,
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.profileSave),
            ),
          ],
        ),
      ),
    );
  }
}
