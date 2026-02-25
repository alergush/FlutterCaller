import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/mock/client_controller.dart';
import 'package:flutter_caller/providers/client_search_provider.dart';

class SearchClientField extends ConsumerStatefulWidget {
  const SearchClientField({super.key});

  @override
  ConsumerState<SearchClientField> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends ConsumerState<SearchClientField> {
  final _textController = TextEditingController();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final isNotEmpty = _textController.text.trim().isNotEmpty;

    ref.read(clientSearchProvider.notifier).set(_textController.text.trim());

    if (isNotEmpty != _isVisible) {
      setState(() {
        _isVisible = isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChange);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientsListStateAsync = ref.watch(clientsStreamProvider);

    final isDisabled =
        clientsListStateAsync.isLoading || clientsListStateAsync.hasError;

    return TextField(
      enabled: !isDisabled,
      controller: _textController,
      decoration: InputDecoration(
        hintText: "Enter client name or phone...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _isVisible
            ? IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _textController.clear();
                },
                icon: const Icon(Icons.highlight_off_rounded),
              )
            : null,
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
