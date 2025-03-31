import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinDialog extends StatefulWidget {
  const PinDialog({super.key});

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final _pinController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ingrese PIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: _isObscured,
            decoration: InputDecoration(
              hintText: 'PIN de 4 dígitos',
              counterText: '',
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'PIN por defecto: 1234',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final pin = _pinController.text;
            if (pin.length == 4) {
              Navigator.pop(context, pin);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El PIN debe tener 4 dígitos'),
                ),
              );
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}