import 'package:flutter/material.dart';
import 'package:flutter_caller/models/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/controllers/client_controller.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  const AddClientScreen({super.key});

  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Controller-ele pentru input-uri
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _extraController = TextEditingController();

  @override
  void dispose() {
    // Întotdeauna curățăm controller-ele
    _nameController.dispose();
    _phoneController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validăm formularul înainte de trimitere
    if (!_formKey.currentState!.validate()) return;

    // Creăm obiectul client (asigură-te că constructorul corespunde modelului tău)
    final newClient = Client(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      extra: _extraController.text.trim(),
    );

    // Apelăm controller-ul
    await ref.read(clientControllerProvider.notifier).createClient(newClient);

    // 2. Verificăm dacă a reușit (dacă nu avem eroare în state)
    if (!ref.read(clientControllerProvider).hasError) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Ascultăm starea pentru a vedea dacă se încarcă
    final clientState = ref.watch(clientControllerProvider);
    final isLoading = clientState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Client"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _extraController,
                decoration: const InputDecoration(
                  labelText: "Extra Info (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !isLoading,
              ),
              const SizedBox(height: 32),

              // 4. Buton care își schimbă starea
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save Client"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
