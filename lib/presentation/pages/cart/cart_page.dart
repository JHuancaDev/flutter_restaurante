import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/cart_item.dart';
import 'package:flutter_restaurante/data/models/order.dart';
import 'package:flutter_restaurante/data/services/cart_service.dart';
import 'package:flutter_restaurante/presentation/pages/payment/payment_method_dialog.dart';
import 'package:flutter_restaurante/presentation/pages/cart/orders_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  List<CartItem> _items = [];
  double _total = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final cartResponse = await _cartService.getCart();
      setState(() {
        _items = cartResponse.items;
        _total = cartResponse.totalAmount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar carrito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateQuantity(int itemId, int newQuantity) async {
    try {
      if (newQuantity == 0) {
        await _removeItem(itemId);
        return;
      }

      final cartResponse = await _cartService.updateQuantity(
        itemId,
        newQuantity,
      );
      setState(() {
        _items = cartResponse.items;
        _total = cartResponse.totalAmount;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar cantidad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Recargar carrito para sincronizar
      await _loadCart();
    }
  }

  Future<void> _removeItem(int itemId) async {
    try {
      final cartResponse = await _cartService.removeFromCart(itemId);
      setState(() {
        _items = cartResponse.items;
        _total = cartResponse.totalAmount;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto eliminado del carrito"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      await _loadCart();
    }
  }

  Future<void> _checkout() async {
    try {
      // Primero obtener mesas disponibles si es dine_in
      List<dynamic> availableTables = [];
      bool isDineIn = await _showOrderTypeDialog();

      if (isDineIn) {
        availableTables = await _getAvailableTables();

        if (availableTables.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No hay mesas disponibles en este momento'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => PaymentMethodDialog(
          totalAmount: _total,
          isDineIn: isDineIn,
          availableTables: availableTables,
        ),
      );

      if (result == null) {
        return;
      }

      final paymentMethod = result['paymentMethod'] as String;
      final notes = result['notes'] as String;
      final tableId = result['tableId'];
      final deliveryAddress = result['deliveryAddress'] as String?;

      final Map<String, dynamic> orderData = {
        'order_type': isDineIn ? 'dine_in' : 'delivery',
        'payment_method': paymentMethod,
        'notes': notes,
      };

      if (isDineIn && tableId != null) {
        orderData['table_id'] = tableId is String
            ? int.tryParse(tableId)
            : tableId;
      } else if (!isDineIn && deliveryAddress != null) {
        orderData['delivery_address'] = deliveryAddress;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Procesando pedido...'),
            ],
          ),
        ),
      );

      final order = await _cartService.checkoutWithTable(orderData);

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
      }

      if (context.mounted) {
        _showOrderConfirmation(order, isDineIn);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al realizar pedido: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<bool> _showOrderTypeDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Tipo de Pedido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.restaurant),
                  title: Text('Comer en el local'),
                  subtitle: Text('Selecciona una mesa disponible'),
                  onTap: () => Navigator.of(context).pop(true),
                ),
                ListTile(
                  leading: Icon(Icons.delivery_dining),
                  title: Text('Delivery'),
                  subtitle: Text('Envío a domicilio'),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  Future<List<dynamic>> _getAvailableTables() async {
    try {
      final tables = await _cartService.getAvailableTables();

      // Filtrar solo las mesas disponibles
      final availableTables = tables.where((table) {
        final isAvailable = table['is_available'] == true;
        final isActive = table['is_active'] != false; // Por si acaso
        return isAvailable && isActive;
      }).toList();

      return availableTables;
    } catch (e) {
      try {
        final allTables = await _cartService.getAllAvailableTables();

        return allTables;
      } catch (e2) {
        return [];
      }
    }
  }

  void _showOrderConfirmation(Order order, bool isDineIn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pedido Confirmado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('N° de Pedido: #${order.id}'),
            Text('Total: S/. ${order.totalAmount.toStringAsFixed(2)}'),
            Text(
              'Método: ${_getPaymentMethodText(order.orderType == 'dine_in' ? 'cash' : 'cash')}',
            ),
            if (isDineIn && order.tableNumber != null)
              Text('Mesa: ${order.tableNumber}'),
            Text('Estado: ${_getStatusText(order.status)}'),
            SizedBox(height: 8),
            Text(
              isDineIn
                  ? 'Tu pedido ha sido registrado. Te avisaremos cuando esté listo.'
                  : 'Tu pedido está en camino. Llegará en aproximadamente 30-45 minutos.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersPage()),
              );
            },
            child: Text('Ver Mis Pedidos'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bottonPrimary,
              foregroundColor: AppColors.blanco,
            ),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'recibido':
        return 'Recibido';
      case 'en_preparacion':
        return 'En preparación';
      case 'listo':
        return 'Listo';
      case 'entregado':
        return 'Entregado';
      case 'completado':
        return 'Completado';
      default:
        return status;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Efectivo';
      case 'card':
        return 'Tarjeta';
      case 'transfer':
        return 'Transferencia';
      case 'digital':
        return 'Pago Digital';
      default:
        return method;
    }
  }

  Future<void> _clearCart() async {
    try {
      await _cartService.clearCart();
      await _loadCart();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Carrito vaciado")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al vaciar carrito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Carrito"),
        backgroundColor: AppColors.fondoPrimary,
        foregroundColor: AppColors.blanco,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearCart,
              tooltip: "Vaciar carrito",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "El carrito está vacío",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.productImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.fondoSecondary,
                                  child: const Icon(
                                    Icons.fastfood,
                                    color: AppColors.bottonPrimary,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "S/. ${item.productPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Subtotal: S/. ${item.subtotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 155,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    _updateQuantity(item.id, item.quantity - 1);
                                  },
                                ),
                                Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    _updateQuantity(item.id, item.quantity + 1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.bottonSecundary,
                                  ),
                                  onPressed: () => _removeItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.blanco,
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
                          Text(
                            "Total:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            "S/. ${_total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bottonSecundary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bottonPrimary,
                            foregroundColor: AppColors.blanco,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Realizar Pedido",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
