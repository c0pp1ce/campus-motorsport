import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/provider/category_filter_provider.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Provides category filters.
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    Key? key,
    required this.filterProvider,
    this.hint,
  }) : super(key: key);

  final CategoryFilterProvider filterProvider;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Kategorien Filter',
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.start,
        ),
        _buildFilterChips(context),
        const Divider(
          thickness: 1.2,
          indent: SizeConfig.basePadding,
          endIndent: SizeConfig.basePadding,
          height: SizeConfig.basePadding * 2,
        ),
        _buildInfo(
          context,
          hint ?? 'Filter die Komponenten basierend auf ihrer Kategorie.',
          LineIcons.filter,
        ),
        const Divider(
          thickness: 1.2,
          indent: SizeConfig.basePadding,
          endIndent: SizeConfig.basePadding,
          height: SizeConfig.basePadding * 2,
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ComponentCategory.values.map((category) {
        final bool selected =
            filterProvider.allowedCategories.contains(category);
        return FilterChip(
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          label: Text(
            category.name,
            style: getChipTextStyle(selected, context),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          elevation: SizeConfig.baseBackgroundElevation,
          selected: selected,
          onSelected: (select) {
            if (select) {
              filterProvider.allowCategory(category);
            } else {
              filterProvider.hideCategory(category);
            }
          },
        );
      }).toList(),
    );
  }

  TextStyle? getChipTextStyle(bool selected, BuildContext context) {
    return Theme.of(context).textTheme.bodyText2?.copyWith(
          color: selected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontSize: 12,
        );
  }

  Widget _buildInfo(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(icon),
        SizedBox(
          width: SizeConfig.safeBlockHorizontal * 65,
          child: Text(
            text,
          ),
        ),
      ],
    );
  }
}
