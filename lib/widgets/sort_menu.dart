import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/file_manager_provider.dart';
import '../theme/app_theme.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FileManagerProvider>();

    return PopupMenuButton<SortOption>(
      onSelected: (option) {
        provider.setSortOption(option);
      },
      icon: FaIcon(
        provider.isAscending ? FontAwesomeIcons.arrowUpWideShort : FontAwesomeIcons.arrowDownWideShort,
        color: AppTheme.primaryBlue,
        size: 18,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => [
        _buildPopupItem(
          value: SortOption.name,
          icon: FontAwesomeIcons.font,
          label: 'Sort by Name',
          isSelected: provider.sortOption == SortOption.name,
        ),
        _buildPopupItem(
          value: SortOption.date,
          icon: FontAwesomeIcons.calendarDay,
          label: 'Sort by Date',
          isSelected: provider.sortOption == SortOption.date,
        ),
        _buildPopupItem(
          value: SortOption.size,
          icon: FontAwesomeIcons.database,
          label: 'Sort by Size',
          isSelected: provider.sortOption == SortOption.size,
        ),
      ],
    );
  }

  PopupMenuItem<SortOption> _buildPopupItem({
    required SortOption value,
    required dynamic icon,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<SortOption>(
      value: value,
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 14,
            color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
