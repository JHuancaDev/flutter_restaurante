import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/extra.dart';
import 'package:flutter_restaurante/data/models/order.dart';
import 'package:flutter_restaurante/data/services/extra_service.dart';

class OrderExtrasPage extends StatefulWidget {
  final Order order;
  
  const OrderExtrasPage({super.key, required this.order});

  @override
  State<OrderExtrasPage> createState() => _OrderExtrasPageState();
}

class _OrderExtrasPageState extends State<OrderExtrasPage> {
  final ExtraService _extraService = ExtraService();
  List<Extra> _availableExtras = [];
  final Map<int, int> _selectedExtras = {}; // extraId -> quantity
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadExtras();
    _loadCurrentExtras();
  }

  Future<void> _loadExtras() async {
    try {
      final extras = await _extraService.getExtras();
      setState(() {
        _availableExtras = extras;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _loadCurrentExtras() {
    for (final extra in widget.order.extras) {
      _selectedExtras[extra.extraId] = extra.quantity;
    }
  }

  void _updateQuantity(int extraId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _selectedExtras.remove(extraId);
      } else {
        _selectedExtras[extraId] = quantity;
      }
    });
  }

  Future<void> _saveExtras() async {
    try {
      final extrasToAdd = _selectedExtras.entries
          .map((entry) => {
                'extra_id': entry.key,
                'quantity': entry.value,
              })
          .toList();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Añadiendo extras...'),
            ],
          ),
        ),
      );

      await _extraService.addExtrasToOrder(widget.order.id, extrasToAdd);

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Extras añadidos correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(true); // Regresar con éxito
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildExtraCard(Extra extra) {
    final currentQuantity = _selectedExtras[extra.id] ?? 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagen del extra
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.fondoSecondary,
                    child: extra.imageUrl != null
                        ? Image.network(
                            extra.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                _getExtraIcon(extra.category),
                                color: AppColors.bottonPrimary,
                              );
                            },
                          )
                        : Icon(
                            _getExtraIcon(extra.category),
                            color: AppColors.bottonPrimary,
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Información del extra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        extra.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      
                      if (extra.description != null)
                        Text(
                          extra.description!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          Text(
                            extra.isFree ? 'Gratis' : 'S/. ${extra.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: extra.isFree ? Colors.green : AppColors.bottonPrimary,
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(extra.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getCategoryName(extra.category),
                              style: TextStyle(
                                color: _getCategoryColor(extra.category),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Selector de cantidad
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _updateQuantity(extra.id, currentQuantity - 1),
                        ),
                        
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            currentQuantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _updateQuantity(extra.id, currentQuantity + 1),
                        ),
                      ],
                    ),
                    
                    if (currentQuantity > 0)
                      Text(
                        extra.isFree 
                            ? 'Gratis'
                            : 'S/. ${(extra.price * currentQuantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getExtraIcon(String category) {
    switch (category) {
      case 'bebida':
        return Icons.local_drink;
      case 'condimento':
        return Icons.emoji_food_beverage;
      case 'acompanamiento':
        return Icons.fastfood;
      default:
        return Icons.add_circle;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'bebida':
        return 'Bebida';
      case 'condimento':
        return 'Salsa';
      case 'acompanamiento':
        return 'Acompañamiento';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bebida':
        return Colors.blue;
      case 'condimento':
        return Colors.red;
      case 'acompanamiento':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (final entry in _selectedExtras.entries) {
      final extra = _availableExtras.firstWhere(
        (e) => e.id == entry.key,
        orElse: () => Extra(
          id: 0,
          name: '',
          price: 0,
          category: '',
          isAvailable: true,
          isFree: false,
          stock: 0,
          createdAt: DateTime.now(),
        ),
      );
      if (!extra.isFree) {
        total += extra.price * entry.value;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Extras'),
        backgroundColor: AppColors.fondoPrimary,
        foregroundColor: AppColors.blanco,
        actions: [
          if (_selectedExtras.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveExtras,
              tooltip: 'Guardar extras',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text('Error: $_errorMessage'),
                )
              : Column(
                  children: [
                    // Header informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.fondoSecondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Orden #${widget.order.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Selecciona los extras que deseas añadir a tu pedido:',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    
                    // Lista de extras
                    Expanded(
                      child: ListView.builder(
                        itemCount: _availableExtras.length,
                        itemBuilder: (context, index) {
                          final extra = _availableExtras[index];
                          if (!extra.isAvailable) return const SizedBox();
                          return _buildExtraCard(extra);
                        },
                      ),
                    ),
                    
                    // Resumen y botón
                    if (_selectedExtras.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total extras:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'S/. ${_calculateTotal().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.bottonPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveExtras,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bottonPrimary,
                                  foregroundColor: AppColors.blanco,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text(
                                  'AÑADIR EXTRAS AL PEDIDO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}