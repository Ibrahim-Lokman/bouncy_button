import 'package:bouncy_button/bouncy_button.dart';
import 'package:flutter/material.dart';

import '../data/fixtures.dart';
import '../data/mock_backend.dart';
import '../data/models.dart';
import '../state/demo_scope.dart';

/// Thrown when Pay is pressed with an incomplete form. The button shakes,
/// and the form shows what is missing.
class _FormIncomplete implements Exception {
  const _FormIncomplete();
}

/// A mock checkout that shows async buttons handling success, failure, and
/// retries, while never charging twice.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _card = TextEditingController();
  final _promo = TextEditingController();

  final Map<String, int> _quantities = {'headphones': 1, 'mug': 2};
  int _discountPercent = 0;
  String _delivery = 'standard';

  static const int _expressCents = 999;
  String? _promoError;
  String? _orderId;
  String? _payError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _card.dispose();
    _promo.dispose();
    super.dispose();
  }

  Product _product(String id) =>
      mockProducts.firstWhere((product) => product.id == id);

  int get _subtotal => _quantities.entries.fold(
        0,
        (sum, entry) => sum + _product(entry.key).priceCents * entry.value,
      );

  int get _discount => _subtotal * _discountPercent ~/ 100;

  int get _deliveryCents => _delivery == 'express' ? _expressCents : 0;

  int get _total => _subtotal - _discount + _deliveryCents;

  void _changeQuantity(String id, int delta) {
    setState(() {
      _quantities[id] = (_quantities[id]! + delta).clamp(1, 9);
    });
  }

  Future<void> _applyPromo() async {
    final scope = DemoScope.read(context);
    setState(() => _promoError = null);
    final percent = await scope.backend.applyPromo(_promo.text);
    if (!mounted) {
      return;
    }
    setState(() => _discountPercent = percent);
    scope.log.add('Promo applied: $percent% off');
  }

  void _promoFailed(Object error, StackTrace stackTrace) {
    final message =
        error is MockApiException ? error.message : 'Something went wrong.';
    setState(() => _promoError = message);
    DemoScope.read(context).log.add('Promo failed: $message');
  }

  Future<void> _pay() async {
    setState(() => _payError = null);
    if (!_formKey.currentState!.validate()) {
      throw const _FormIncomplete();
    }
    final scope = DemoScope.read(context);
    final orderId = await scope.backend.placeOrder(
      totalCents: _total,
      cardNumber: _card.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _orderId = orderId);
    scope.log.add('Order $orderId placed for ${formatPrice(_total)}');
  }

  void _payFailed(Object error, StackTrace stackTrace) {
    final log = DemoScope.read(context).log;
    if (error is _FormIncomplete) {
      log.add('Pay blocked: form incomplete');
      return;
    }
    final message =
        error is MockApiException ? error.message : 'Something went wrong.';
    log.add('Payment failed: $message');
    // Shown under the button rather than in a snack bar, which would cover it.
    setState(() => _payError = message);
  }

  void _newOrder() {
    _formKey.currentState!.reset();
    for (final controller in [_name, _email, _card, _promo]) {
      controller.clear();
    }
    setState(() {
      _orderId = null;
      _discountPercent = 0;
      _delivery = 'standard';
      _promoError = null;
      _payError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final backend = DemoScope.of(context).backend;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your cart', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final id in _quantities.keys) _cartLine(id),
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promo,
                      decoration: InputDecoration(
                        labelText: 'Promo code',
                        helperText: 'Try ${MockBackend.promoCode}',
                        errorText: _promoError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BouncyButton.secondary(
                    onPressedAsync: _applyPromo,
                    onError: _promoFailed,
                    child: const Text('Apply'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Delivery', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              BouncyButtonGroup<String>(
                segments: const [
                  BouncyButtonSegment(
                    value: 'standard',
                    icon: Icon(Icons.local_shipping_outlined),
                    label: Text('Standard'),
                  ),
                  BouncyButtonSegment(
                    value: 'express',
                    icon: Icon(Icons.bolt),
                    label: Text('Express'),
                  ),
                ],
                selected: {_delivery},
                onSelectionChanged: (selection) =>
                    setState(() => _delivery = selection.first),
              ),
              const SizedBox(height: 16),
              _totalLine('Subtotal', _subtotal),
              if (_discount > 0) _totalLine('Discount', -_discount),
              if (_deliveryCents > 0)
                _totalLine('Express delivery', _deliveryCents),
              _totalLine('Total', _total, bold: true),
              const Divider(height: 32),
              Text('Payment', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name on card'),
                textInputAction: TextInputAction.next,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Enter the name on the card'
                    : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) => (value ?? '').contains('@')
                    ? null
                    : 'Enter an email address',
              ),
              TextFormField(
                controller: _card,
                decoration: const InputDecoration(
                  labelText: 'Card number',
                  helperText: 'Any 16 digits. 4000 0000 0000 0002 is '
                      'always declined.',
                  helperMaxLines: 2,
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value ?? '').replaceAll(' ', '').length == 16
                        ? null
                        : 'Enter a 16 digit card number',
              ),
              const SizedBox(height: 24),
              BouncyButton.primary(
                onPressedAsync: _pay,
                onError: _payFailed,
                style: BouncyButtonStyle.primary.copyWith(
                  width: double.infinity,
                ),
                child: Text('Pay ${formatPrice(_total)}'),
              ),
              // Under the button, where the person who pressed it is looking.
              if (_orderId != null)
                Card(
                  margin: const EdgeInsets.only(top: 12),
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order $_orderId placed',
                            style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        BouncyButton.tertiary(
                          onPressed: _newOrder,
                          child: const Text('Start a new order'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_payError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _payError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Mock card charged ${backend.charges} '
                '${backend.charges == 1 ? 'time' : 'times'}',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartLine(String id) {
    final product = _product(id);
    final quantity = _quantities[id]!;
    // Controls sit under the name, so large text has the full width.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${product.name}, ${formatPrice(product.priceCents)} each'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove,
                label: 'Remove one ${product.name}',
                onTap: quantity > 1 ? () => _changeQuantity(id, -1) : null,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 32),
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  semanticsLabel: '${product.name} quantity $quantity',
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                label: 'Add one ${product.name}',
                onTap: quantity < 9 ? () => _changeQuantity(id, 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalLine(String label, int cents, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    final amount = cents < 0 ? '-${formatPrice(-cents)}' : formatPrice(cents);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: style)),
          // Right-aligned, and wraps rather than overflowing at large sizes.
          Expanded(
            flex: 2,
            child: Text(amount, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return BouncyPressable(
      onTap: onTap,
      scaleFactor: 0.8,
      semanticLabel: label,
      focusColor: color,
      focusBorderRadius: const BorderRadius.all(Radius.circular(24)),
      child: SizedBox.square(
        dimension: 48,
        child: Icon(icon,
            color: onTap == null ? Theme.of(context).disabledColor : color),
      ),
    );
  }
}
