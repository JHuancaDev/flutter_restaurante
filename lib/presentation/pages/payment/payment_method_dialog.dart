import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';

class PaymentMethodDialog extends StatefulWidget {
  final double totalAmount;
  final bool isDineIn;
  final List<dynamic> availableTables;

  const PaymentMethodDialog({
    super.key,
    required this.totalAmount,
    required this.isDineIn,
    required this.availableTables,
  });

  @override
  State<PaymentMethodDialog> createState() => _PaymentMethodDialogState();
}

class _PaymentMethodDialogState extends State<PaymentMethodDialog> {
  String _selectedPaymentMethod = 'cash';
  int? _selectedTableId;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'Efectivo', 'icon': Icons.money_off_csred},
    {'value': 'card', 'label': 'Tarjeta', 'icon': Icons.credit_card}, 
    {'value': 'digital', 'label': 'Yape - Plin', 'icon': Icons.phone_android},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isDineIn ? 'Confirmar Pedido en Local' : 'Confirmar Delivery',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total a pagar: S/. ${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.bottonSecundary,
              ),
            ),
            SizedBox(height: 16),

            // Selector de mesa (solo para dine_in)
            if (widget.isDineIn) ...[
              Text(
                'Selecciona una mesa:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (widget.availableTables.isEmpty)
                Text(
                  'No hay mesas disponibles',
                  style: TextStyle(color: Colors.red),
                )
              else
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: _selectedTableId,
                  onChanged: (value) {
                    setState(() {
                      _selectedTableId = value;
                    });
                  },
                  items: widget.availableTables.map<DropdownMenuItem<int>>((
                    table,
                  ) {
                    // Asegurar que el ID sea int
                    final tableId = table['id'] is int
                        ? table['id']
                        : int.tryParse(table['id'].toString());

                    return DropdownMenuItem<int>(
                      value: tableId,
                      child: Text(
                        'Mesa ${table['number']} - Capacidad: ${table['capacity']} personas',
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selecciona una mesa',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor selecciona una mesa';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 16),
            ],

            // Dirección de entrega (solo para delivery)
            if (!widget.isDineIn) ...[
              Text(
                'Dirección de entrega:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Ingresa tu dirección completa',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16),
            ],

            // Método de pago
            Text(
              'Método de pago:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._paymentMethods.map((method) {
              return RadioListTile<String>(
                value: method['value'],
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                title: Row(
                  children: [
                    Icon(method['icon'], size: 20),
                    SizedBox(width: 8),
                    Text(method['label']),
                  ],
                ),
              );
            }),
            SizedBox(height: 16),

            // Notas adicionales
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notas adicionales (opcional)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validaciones
            if (widget.isDineIn && _selectedTableId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor selecciona una mesa')),
              );
              return;
            }

            if (!widget.isDineIn && _addressController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Por favor ingresa la dirección de entrega'),
                ),
              );
              return;
            }

            Navigator.of(context).pop({
              'paymentMethod': _selectedPaymentMethod,
              'notes': _notesController.text,
              'tableId': _selectedTableId,
              'deliveryAddress': _addressController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bottonPrimary,
            foregroundColor: AppColors.blanco,
          ),
          child: Text('Confirmar Pedido'),
        ),
      ],
    );
  }
}
