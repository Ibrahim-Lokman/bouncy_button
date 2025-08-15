import 'package:flutter/material.dart';
import 'package:bouncy_button/bouncy_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bouncy Button Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BouncyButtonDemo(),
    );
  }
}

class BouncyButtonDemo extends StatefulWidget {
  const BouncyButtonDemo({Key? key}) : super(key: key);

  @override
  State<BouncyButtonDemo> createState() => _BouncyButtonDemoState();
}

class _BouncyButtonDemoState extends State<BouncyButtonDemo> {
  String _lastPressed = 'None';

  void _onButtonPressed(String buttonName) {
    setState(() {
      _lastPressed = buttonName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$buttonName pressed!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bouncy Button Demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Last Pressed Button:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastPressed,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSection(
                'Basic Buttons',
                [
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Simple Button'),
                    child: const Text('Simple Button'),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton.primary(
                    onPressed: () => _onButtonPressed('Primary Button'),
                    child: const Text('Primary Button'),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton.secondary(
                    onPressed: () => _onButtonPressed('Secondary Button'),
                    child: const Text('Secondary Button'),
                  ),
                ],
              ),
              _buildSection(
                'Animation Types',
                [
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Scale Animation'),
                    animation: const BouncyButtonAnimation(
                      type: BouncyButtonAnimationType.scale,
                    ),
                    child: const Text('Scale Animation'),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Bounce Animation'),
                    animation: const BouncyButtonAnimation(
                      type: BouncyButtonAnimationType.bounce,
                      duration: Duration(milliseconds: 200),
                    ),
                    child: const Text('Bounce Animation'),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Rotation Animation'),
                    animation: const BouncyButtonAnimation(
                      type: BouncyButtonAnimationType.rotation,
                    ),
                    child: const Text('Rotation Animation'),
                  ),
                ],
              ),
              _buildSection(
                'Styled Buttons',
                [
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Gradient Button'),
                    style: BouncyButtonStyle(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Text(
                      'Gradient Button',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Pill Button'),
                    style: BouncyButtonStyle.pill.copyWith(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Pill Shaped',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BouncyButton(
                        onPressed: () => _onButtonPressed('Heart'),
                        style: BouncyButtonStyle.circle.copyWith(
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(Icons.favorite, color: Colors.white),
                      ),
                      BouncyButton(
                        onPressed: () => _onButtonPressed('Star'),
                        style: BouncyButtonStyle.circle.copyWith(
                          backgroundColor: Colors.amber,
                        ),
                        child: const Icon(Icons.star, color: Colors.white),
                      ),
                      BouncyButton(
                        onPressed: () => _onButtonPressed('Thumb'),
                        style: BouncyButtonStyle.circle.copyWith(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Icon(Icons.thumb_up, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              _buildSection(
                'Interactive Features',
                [
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Haptic Light'),
                    onLongPress: () => _onButtonPressed('Long Press'),
                    interaction: const BouncyButtonInteraction(
                      hapticFeedbackType: HapticFeedbackType.light,
                    ),
                    child: const Text('Long Press Me (Light Haptic)'),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton(
                    onPressed: () => _onButtonPressed('Haptic Heavy'),
                    interaction: const BouncyButtonInteraction(
                      hapticFeedbackType: HapticFeedbackType.heavy,
                      enableSplash: true,
                    ),
                    style: const BouncyButtonStyle(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text(
                      'Heavy Haptic + Splash',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              _buildSection(
                'States',
                [
                  BouncyButton(
                    onPressed: null,
                    style: const BouncyButtonStyle(
                      disabledColor: Colors.grey,
                    ),
                    child: const Text('Disabled Button'),
                  ),
                  const SizedBox(height: 16),
                  BouncyButton(
                    onPressed: () => _onButtonPressed('High Elevation'),
                    style: const BouncyButtonStyle(
                      elevation: 16,
                      backgroundColor: Colors.orange,
                      shadowDarkness: 0.5,
                    ),
                    child: const Text(
                      'High Elevation',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 32),
      ],
    );
  }
}
