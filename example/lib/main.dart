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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          brightness: Brightness.light,
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFF50E3C2),
          tertiary: const Color(0xFFF5A623),
        ),
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF50E3C2),
          brightness: Brightness.dark,
          primary: const Color(0xFF50E3C2),
          secondary: const Color(0xFF4A90E2),
          tertiary: const Color(0xFFF8E71C),
        ),
        fontFamily: 'SF Pro Display',
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
  void _onButtonPressed(String buttonName) {
    print('$buttonName pressed');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F23) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildBasicButtonsSection(theme, isDark),
                  const SizedBox(height: 40),
                  _buildAnimationTypesSection(theme, isDark),
                  const SizedBox(height: 40),
                  _buildStyledButtonsSection(theme, isDark),
                  const SizedBox(height: 40),
                  _buildInteractiveSection(theme, isDark),
                  const SizedBox(height: 40),
                  _buildStatesSection(theme, isDark),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF1E1E3F) : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E1E3F), const Color(0xFF2D2D5A)]
                  : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bouncy Button',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Interactive Flutter Buttons',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String description,
    IconData icon,
    List<Widget> children,
    ThemeData theme,
    bool isDark,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.06),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.1),
                      accentColor.withOpacity(0.05)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicButtonsSection(ThemeData theme, bool isDark) {
    return _buildSectionCard(
      'Basic Buttons',
      'Simple and clean button styles',
      Icons.radio_button_checked,
      [
        _buildButtonGrid([
          BouncyButton(
            onPressed: () => _onButtonPressed('Simple Button'),
            style: BouncyButtonStyle(
              backgroundColor: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text(
              'Simple Button',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          BouncyButton.primary(
            onPressed: () => _onButtonPressed('Primary Button'),
            child: const Text('Primary Button'),
            style: BouncyButtonStyle.primary.copyWith(
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ]),
        const SizedBox(height: 16),
        BouncyButton.secondary(
          onPressed: () => _onButtonPressed('Secondary Button'),
          child: const Text('Secondary Button'),
          style: BouncyButtonStyle.secondary.copyWith(
            backgroundColor: theme.colorScheme.secondary,
          ),
        ),
      ],
      theme,
      isDark,
      const Color(0xFF6366F1),
    );
  }

  Widget _buildAnimationTypesSection(ThemeData theme, bool isDark) {
    return _buildSectionCard(
      'Animation Types',
      'Different animation effects for interactions',
      Icons.animation,
      [
        _buildButtonGrid([
          BouncyButton(
            onPressed: () => _onButtonPressed('Scale Animation'),
            animation: const BouncyButtonAnimation(
              type: BouncyButtonAnimationType.scale,
            ),
            style: BouncyButtonStyle(
              backgroundColor: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text(
              'Scale',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          BouncyButton(
            onPressed: () => _onButtonPressed('Bounce Animation'),
            animation: const BouncyButtonAnimation(
              type: BouncyButtonAnimationType.bounce,
              duration: Duration(milliseconds: 200),
            ),
            style: BouncyButtonStyle(
              backgroundColor: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: const Text(
              'Bounce',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        BouncyButton(
          onPressed: () => _onButtonPressed('Rotation Animation'),
          animation: const BouncyButtonAnimation(
            type: BouncyButtonAnimationType.rotation,
          ),
          style: BouncyButtonStyle(
            backgroundColor: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text(
            'Rotation Animation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
      theme,
      isDark,
      const Color(0xFF10B981),
    );
  }

  Widget _buildStyledButtonsSection(ThemeData theme, bool isDark) {
    return _buildSectionCard(
      'Styled Buttons',
      'Beautiful gradients and custom shapes',
      Icons.palette,
      [
        BouncyButton(
          onPressed: () => _onButtonPressed('Gradient Button'),
          style: BouncyButtonStyle(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          ),
          child: const Text(
            'Gradient Button',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
        BouncyButton(
          onPressed: () => _onButtonPressed('Pill Button'),
          style: BouncyButtonStyle.pill.copyWith(
            backgroundColor: const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
          ),
          child: const Text(
            'Pill Shaped Button',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Icon Buttons',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BouncyButton(
              onPressed: () => _onButtonPressed('Heart'),
              style: BouncyButtonStyle.circle.copyWith(
                backgroundColor: const Color(0xFFEF4444),
              ),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child:
                    const Icon(Icons.favorite, color: Colors.white, size: 28),
              ),
            ),
            BouncyButton(
              onPressed: () => _onButtonPressed('Star'),
              style: BouncyButtonStyle.circle.copyWith(
                backgroundColor: const Color(0xFFF59E0B),
              ),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: const Icon(Icons.star, color: Colors.white, size: 28),
              ),
            ),
            BouncyButton(
              onPressed: () => _onButtonPressed('Thumb'),
              style: BouncyButtonStyle.circle.copyWith(
                backgroundColor: const Color(0xFF3B82F6),
              ),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child:
                    const Icon(Icons.thumb_up, color: Colors.white, size: 28),
              ),
            ),
            BouncyButton(
              onPressed: () => _onButtonPressed('Share'),
              style: BouncyButtonStyle.circle.copyWith(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: const Icon(Icons.share, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ],
      theme,
      isDark,
      const Color(0xFF8B5CF6),
    );
  }

  Widget _buildInteractiveSection(ThemeData theme, bool isDark) {
    return _buildSectionCard(
      'Interactive Features',
      'Haptic feedback and advanced interactions',
      Icons.vibration,
      [
        BouncyButton(
          onPressed: () => _onButtonPressed('Haptic Light'),
          onLongPress: () => _onButtonPressed('Long Press'),
          interaction: const BouncyButtonInteraction(
            hapticFeedbackType: HapticFeedbackType.light,
          ),
          style: BouncyButtonStyle(
            backgroundColor: const Color(0xFF06B6D4),
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text(
            'Long Press Me (Light Haptic)',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        BouncyButton(
          onPressed: () => _onButtonPressed('Haptic Heavy'),
          interaction: const BouncyButtonInteraction(
            hapticFeedbackType: HapticFeedbackType.heavy,
            enableSplash: true,
          ),
          style: BouncyButtonStyle(
            backgroundColor: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text(
            'Heavy Haptic + Splash Effect',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
      theme,
      isDark,
      const Color(0xFF06B6D4),
    );
  }

  Widget _buildStatesSection(ThemeData theme, bool isDark) {
    return _buildSectionCard(
      'Button States',
      'Disabled states and elevation effects',
      Icons.layers,
      [
        BouncyButton(
          onPressed: null,
          style: BouncyButtonStyle(
            disabledColor:
                isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Text(
            'Disabled Button',
            style: TextStyle(
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        BouncyButton(
          onPressed: () => _onButtonPressed('High Elevation'),
          style: BouncyButtonStyle(
            elevation: 16,
            backgroundColor: const Color(0xFFF97316),
            shadowDarkness: 0.3,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text(
            'High Elevation Button',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      theme,
      isDark,
      const Color(0xFFF97316),
    );
  }

  Widget _buildButtonGrid(List<Widget> buttons) {
    return Row(
      children: buttons
          .map((button) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: button,
                ),
              ))
          .toList(),
    );
  }
}
