import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class NuriPage extends StatelessWidget {
  const NuriPage({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.safeTop = true,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget child;
  final Color backgroundColor;
  final bool safeTop;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: safeTop,
        bottom: bottomNavigationBar == null,
        child: child,
      ),
    );
  }
}

/// Efek tekan ringan dengan haptic opsional dan dukungan reduced-motion.
class NuriImage extends StatelessWidget {
  const NuriImage({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 16,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stack) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceSubtle,
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: AppColors.muted,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class NuriStepHeader extends StatelessWidget {
  const NuriStepHeader({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final int step;
  final int total;
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Langkah $step dari $total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (onClose != null)
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(44),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.line),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 19,
                      color: AppColors.text,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: step / total,
              minHeight: 4,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NuriDisclaimer extends StatelessWidget {
  const NuriDisclaimer({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'NURI adalah alat skrining awal, bukan diagnosis. Konsultasikan hasil dengan bidan atau dokter.',
              style: TextStyle(
                fontSize: compact ? 11 : 11.5,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NuriInfoRow extends StatelessWidget {
  const NuriInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color = AppColors.primary,
    this.background = AppColors.surfaceSubtle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
