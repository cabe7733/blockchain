import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Barra de búsqueda y filtros: texto, industria y rango de fechas.
class SearchFilterBar extends StatelessWidget {
  final String searchValue;
  final String industryValue;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onIndustryChanged;
  final VoidCallback onDateRangePick;
  final VoidCallback onClearFilters;

  static const List<String> industries = [
    '',
    'Finanzas',
    'Logística',
    'Salud',
    'Retail',
    'Manufactura',
    'Gobierno',
    'Educación',
    'Otro',
  ];

  const SearchFilterBar({
    super.key,
    required this.searchValue,
    required this.industryValue,
    required this.startDate,
    required this.endDate,
    required this.onSearchChanged,
    required this.onIndustryChanged,
    required this.onDateRangePick,
    required this.onClearFilters,
  });

  bool get hasActiveFilters =>
      searchValue.isNotEmpty ||
      industryValue.isNotEmpty ||
      startDate != null ||
      endDate != null;

  String get dateRangeLabel {
    final fmt = DateFormat('dd/MM/yy');
    if (startDate != null && endDate != null) {
      return '${fmt.format(startDate!)} — ${fmt.format(endDate!)}';
    }
    if (startDate != null) return 'Desde ${fmt.format(startDate!)}';
    if (endDate != null) return 'Hasta ${fmt.format(endDate!)}';
    return 'Rango de fechas';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Column(
        children: [
          _buildSearchField(context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildIndustryDropdown(context)),
              const SizedBox(width: 10),
              Expanded(child: _buildDateButton(context)),
            ],
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 8),
            _buildClearButton(context),
          ],
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: _buildSearchField(context)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildIndustryDropdown(context)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildDateButton(context)),
        if (hasActiveFilters) ...[
          const SizedBox(width: 8),
          _buildClearButton(context),
        ],
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: searchValue,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por empresa, tags...',
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
      ),
    );
  }

  Widget _buildIndustryDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: industryValue.isEmpty ? '' : industryValue,
      isDense: true,
      isExpanded: true, // 👈 MUY IMPORTANTE
      decoration: InputDecoration(
        hintText: 'Industria',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      items: industries.map((ind) {
        final text = ind.isEmpty ? 'Todas las industrias' : ind;

        return DropdownMenuItem(
          value: ind,
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis, // 👈 evita overflow
          ),
        );
      }).toList(),
      onChanged: (v) => onIndustryChanged(v ?? ''),
    );
  }

  Widget _buildDateButton(BuildContext context) {
    final theme = Theme.of(context);
    final active = startDate != null || endDate != null;
    return OutlinedButton.icon(
      onPressed: onDateRangePick,
      icon: Icon(
        Icons.date_range,
        size: 16,
        color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      label: Text(
        dateRangeLabel,
        style: TextStyle(
          fontSize: 12,
          color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        side: BorderSide(
          color: active ? theme.colorScheme.primary : Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onClearFilters,
      icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      tooltip: 'Limpiar filtros',
    );
  }
}
