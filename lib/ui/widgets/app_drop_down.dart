import 'package:flutter/material.dart';

class DropdownMenuState {
  final String label;
  final String? value;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? action;

  DropdownMenuState({
    this.value,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.action,
  });
}

class AppDropDown extends StatefulWidget {
  const AppDropDown({
    super.key,
    required this.list,
    this.onSelected,
    this.value,
    this.menuOpener,
    this.menuController,
  });
  final DropdownMenuState? value;
  final List<DropdownMenuState> list;
  final Widget? menuOpener;
  final MenuController? menuController;
  final void Function(String?)? onSelected;

  @override
  State<AppDropDown> createState() => _AppDropDownState();
}

class _AppDropDownState extends State<AppDropDown> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final MenuController menuController =
        widget.menuController ?? MenuController();
    return MenuAnchor(
      style: MenuStyle(
        maximumSize: WidgetStatePropertyAll(Size.fromWidth(300)),
        backgroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surface,
        ),
        shadowColor: WidgetStatePropertyAll(
          Colors.black.withValues(alpha: 0.3),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      alignmentOffset: const Offset(16, 0),
      crossAxisUnconstrained: false,
      controller: menuController,
      menuChildren:
          widget.list
              .map(
                (item) => AppDropdownMenuButton(
                  item: item,
                  showDivider: item != widget.list.last,
                  onSelected: widget.onSelected,
                ),
              )
              .toList(),
      builder: (context, controller, child) {
        return widget.menuOpener ??
            AppDefaultMenuOpener(
              value: widget.value,
              theme: theme,
              menuController: menuController,
            );
      },
    );
  }
}

class AppDefaultMenuOpener extends StatelessWidget {
  const AppDefaultMenuOpener({
    super.key,
    required this.value,
    required this.theme,
    required this.menuController,
  });

  final DropdownMenuState? value;
  final ThemeData theme;
  final MenuController menuController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:
          () =>
              menuController.isOpen
                  ? menuController.close()
                  : menuController.open(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              overflow: TextOverflow.ellipsis,
              value?.label ?? '',
              style: theme.textTheme.titleSmall,
            ),
          ),
          SizedBox(width: 5),
          Icon(
            menuController.isOpen
                ? Icons.keyboard_arrow_up_outlined
                : Icons.keyboard_arrow_down_outlined,
          ),
        ],
      ),
    );
  }
}

class AppDropdownMenuButton extends StatelessWidget {
  const AppDropdownMenuButton({
    super.key,
    required this.showDivider,
    required this.onSelected,
    required this.item,
  });

  final bool showDivider;
  final void Function(String?)? onSelected;
  final DropdownMenuState item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MenuItemButton(
          leadingIcon: item.leadingIcon,
          trailingIcon: item.trailingIcon,
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(250, 40)),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            visualDensity: VisualDensity.compact,
          ),
          onPressed:
              item.action ??
              () {
                if (onSelected != null) onSelected!(item.value);
              },
          child: Text(maxLines: 2, overflow: TextOverflow.ellipsis, item.label),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

class TitledDropdown extends StatelessWidget {
  const TitledDropdown({
    super.key,
    required this.theme,
    required this.title,
    required this.list,
    required this.onSelected,
    required this.value,
  });

  final ThemeData theme;
  final String title;
  final DropdownMenuState value;
  final List<DropdownMenuState> list;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title, style: theme.textTheme.titleMedium)),
          AppDropDown(value: value, list: list, onSelected: onSelected),
        ],
      ),
    );
  }
}
