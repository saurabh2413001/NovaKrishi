import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../services/localization.dart';

/// Keeps content readable on tablets while allowing full-width phone layouts.
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const ResponsiveBody({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 680), child: Padding(padding: padding, child: child)));
}

/// Small rounded logo mark used in every app bar: a leaf glyph on a soft
/// mint tile, next to the AppStrings.t("NovaKrishi", "NovaKrishi") wordmark.
class BrandMark extends StatelessWidget {
  final double size;
  BrandMark({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.18),
        child: Image.asset(
          'assets/images/novakrishi_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.eco, color: Colors.white, size: size * 0.58),
        ),
      ),
    );
  }
}

class BrandWordmark extends StatelessWidget {
  final String subtitle;
  final VoidCallback? onTap;
  BrandWordmark({
    super.key,
    this.subtitle = 'FARM TO MARKET DIRECT',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keep the wordmark bounded because it is commonly placed inside an
    // Expanded slot next to action icons on narrow phones.
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BrandMark(size: 30),
        SizedBox(width: 6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.t('NovaKrishi', 'NovaKrishi'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return onTap == null
        ? content
        : Semantics(
            button: true,
            label: AppStrings.t('NovaKrishi home', 'NovaKrishi होम'),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: content,
              ),
            ),
          );
  }
}

/// The green pill banner at the very top of most screens, e.g.
/// AppStrings.t("Direct Trade • 100% Escrow Protected • Zero Middlemen", "सीधा व्यापार • 100% एस्क्रो सुरक्षा • कोई बिचौलिया नहीं").
class TopStrip extends StatelessWidget {
  final String text;
  TopStrip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A soft rounded pill, e.g. "+4.2%", AppStrings.t("Verified", "सत्यापित"), AppStrings.t("Zero Commission", "शून्य कमीशन").
class Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final double fontSize;

  Pill({
    super.key,
    required this.text,
    this.background = AppColors.mintTint,
    this.foreground = AppColors.primary,
    this.icon,
    this.fontSize = 11,
  });

  factory Pill.change(double percent, {double fontSize = 11}) {
    final up = percent >= 0;
    return Pill(
      text: '${up ? '+' : ''}${percent.toStringAsFixed(1)}%',
      background: up ? Color(0xFFE7F8ED) : Color(0xFFFCEAEA),
      foreground: up ? AppColors.success : AppColors.danger,
      icon: up ? Icons.arrow_upward : Icons.arrow_downward,
      fontSize: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: foreground),
            SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header row: leading icon-in-pill + eyebrow label, used above the
/// AppStrings.t("Core Platform Benefits", "मुख्य प्लेटफ़ॉर्म लाभ") / AppStrings.t("Live Mandi Benchmarks", "लाइव मंडी भाव") style sections.
class EyebrowLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  EyebrowLabel({
    super.key,
    required this.text,
    this.icon = Icons.circle,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 8, color: color),
        SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// A single benefit row under AppStrings.t("Core Platform Benefits", "मुख्य प्लेटफ़ॉर्म लाभ"), e.g.
/// AppStrings.t("Direct From Farmers — Zero APMC broker commissions & markups", "सीधे किसानों से — शून्य APMC ब्रोकर कमीशन और अतिरिक्त शुल्क").
class BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  BenefitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: appCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder "photo" tile used instead of a real network/asset image.
/// TODO IMAGES API: replace this widget with Image.network / cached_network_image
/// using URLs returned by your image/CDN service (see lib/services/api_service.dart).
class ProduceThumb extends StatelessWidget {
  final IconData icon;
  final double size;
  final BorderRadiusGeometry radius;
  final String? imageUrl;

  ProduceThumb({
    super.key,
    this.icon = Icons.eco,
    this.size = 64,
    this.radius = const BorderRadius.all(Radius.circular(12)),
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: [Color(0xFFDDF0DF), Color(0xFFB9E3C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(icon, color: AppColors.primaryDark.withOpacity(0.65), size: size * 0.42)
          : ClipRRect(
              borderRadius: radius,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.primaryDark.withOpacity(0.65), size: size * 0.42),
              ),
            ),
    );
  }
}

/// A card in the AppStrings.t("Fresh From the Farm", "खेत से सीधे ताज़ा") marketplace grid / list.
class ProduceCard extends StatelessWidget {
  final Produce produce;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const ProduceCard({
    super.key,
    required this.produce,
    this.onAddToCart,
    this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 360;
    final thumbSize = compact ? 68.0 : 84.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: appCardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ProduceThumb(
                icon: Icons.eco,
                size: thumbSize,
                imageUrl: produce.imageUrl,
              ),
              if (produce.verified)
                Positioned(
                  left: 4,
                  top: 4,
                  child: Pill(
                    text: AppStrings.t('Verified', 'सत्यापित'),
                    fontSize: 9,
                    background: Colors.white,
                    foreground: AppColors.primary,
                    icon: Icons.verified,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produce.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${produce.farmName} • ${produce.distanceKm.toStringAsFixed(1)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.t(
                    'Available: ${produce.availableQty} ${produce.availableUnit}',
                    'उपलब्ध: ${produce.availableQty} ${produce.availableUnit}',
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '₹${produce.price.toStringAsFixed(0)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        produce.unit,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onAddToCart,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          AppStrings.t(
                            'Add to Cart',
                            'कार्ट में जोड़ें',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onBuyNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          AppStrings.t(
                            'Buy Now',
                            'अभी खरीदें',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A benchmark price card used on the Prices tab, e.g. AppStrings.t("Wheat ₹2,450/Quintal", "गेहूँ ₹2,450/क्विंटल").
class MandiPriceCard extends StatelessWidget {
  final MandiPrice price;

  const MandiPriceCard({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: appCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop + change indicator
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  price.cropName,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 72),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Pill.change(price.changePercent),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // Price + unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                flex: 3,
                child: Text(
                  '₹${price.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                flex: 2,
                child: Text(
                  '/ ${price.unit}',
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Mandi name
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  price.mandiName,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Last updated / benchmark
          Text(
            'Benchmark: ${price.updatedAt}',
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// The bottom AppStrings.t("Farmer / Consumer / Bulk Buyer / Cold-Chain", "किसान / उपभोक्ता / थोक खरीदार / कोल्ड-चेन") role option card
/// used in the role-selection onboarding step.
class RoleOptionCard extends StatelessWidget {
  final IconData icon;
  final KrishiRole role;
  final bool selected;
  final VoidCallback onTap;

  RoleOptionCard({
    super.key,
    required this.icon,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(14),
        decoration: appCardDecoration(
          color: selected ? AppColors.mintTint : AppColors.surface,
          borderColor: selected ? AppColors.primary : AppColors.border,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryDark : AppColors.chipUnselected,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(icon, color: selected ? Colors.white : AppColors.textSecondary, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 220;

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Pill(text: role.badge, fontSize: 9.5),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Flexible(
                            child: Text(
                              role.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Pill(text: role.badge, fontSize: 9.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 3),
                  Text(role.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            SizedBox(width: 6),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.success : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable AppStrings.t("Track this progress", "इस प्रगति को ट्रैक करें") style stepper header, e.g.
/// AppStrings.t("FARMER & FPO ONBOARDING — STEP 2 OF 2", "किसान और FPO पंजीकरण — चरण 2 / 2").
class ProgressHeader extends StatelessWidget {
  final String eyebrow;
  final String step;
  final double progress; // 0..1

  ProgressHeader({
    super.key,
    required this.eyebrow,
    required this.step,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: appCardDecoration(color: AppColors.mintTint, borderColor: AppColors.mintTintStrong),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 300;

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        eyebrow.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        step,
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Numbered section label used inside forms, e.g. "1. Personal Information".
class FormSectionLabel extends StatelessWidget {
  final int number;
  final String title;

  const FormSectionLabel({
    super.key,
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.primaryDark,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }
}
