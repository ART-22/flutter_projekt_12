
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'services/api_service.dart';

void main() {
  runApp(const Lab12App());
}

class Lab12App extends StatelessWidget {
  const Lab12App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Практична робота 12',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Головний екран з трьома вкладками
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Практична робота №12'),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Sign up'),
              Tab(text: 'Reset'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AuthForm(action: AuthAction.login),
            AuthForm(action: AuthAction.signup),
            AuthForm(action: AuthAction.reset),
          ],
        ),
      ),
    );
  }
}

// Види форм
enum AuthAction {
  login,
  signup,
  reset,
}

// Спільний віджет для трьох форм
class AuthForm extends StatefulWidget {
  final AuthAction action;

  const AuthForm({
    super.key,
    required this.action,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

  // Заголовок залежно від обраної вкладки
  String get _title {
    switch (widget.action) {
      case AuthAction.login:
        return 'Авторизація';
      case AuthAction.signup:
        return 'Реєстрація';
      case AuthAction.reset:
        return 'Відновлення пароля';
    }
  }

  String get _description {
    switch (widget.action) {
      case AuthAction.login:
        return 'Введіть email та пароль для входу';
      case AuthAction.signup:
        return 'Заповніть дані для реєстрації';
      case AuthAction.reset:
        return 'Введіть email для відновлення пароля';
    }
  }

  String get _buttonText {
    switch (widget.action) {
      case AuthAction.login:
        return 'Login';
      case AuthAction.signup:
        return 'Sign up';
      case AuthAction.reset:
        return 'Reset Password';
    }
  }

  String get _endpoint {
    switch (widget.action) {
      case AuthAction.login:
        return '/login';
      case AuthAction.signup:
        return '/signup';
      case AuthAction.reset:
        return '/reset';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Валідація email
  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Введіть електронну пошту';
    }

    final emailPattern =
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'Введіть правильний email';
    }

    return null;
  }

  // Валідація пароля
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль';
    }

    if (value.length < 6) {
      return 'Пароль повинен мати хоча б 6 символів';
    }

    return null;
  }

  // Повідомлення користувачу
  void _showMessage(String message, bool isError) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? Colors.red.shade700 : Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // Надсилання HTTP POST-запиту
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      switch (widget.action) {
        case AuthAction.login:
          await _api.login(
            email: email,
            password: password,
          );
          break;

        case AuthAction.signup:
          await _api.signup(
            name: _nameController.text.trim(),
            email: email,
            password: password,
          );
          break;

        case AuthAction.reset:
          await _api.resetPassword(
            email: email,
          );
          break;
      }

      if (!mounted) return;

      _showMessage(
        'Запит POST $_endpoint надіслано! '
            'Перевірте RequestCatcher.',
        false,
      );
    } on DioException catch (error) {
      if (!mounted) return;

      String message = 'Помилка надсилання запиту';

      if (error.response != null) {
        message =
        'Помилка HTTP: ${error.response!.statusCode}';
      } else {
        message =
        'Немає з\'єднання із сервером. '
            'Перевірте інтернет і адресу.';
      }

      _showMessage(message, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Невідома помилка: $error',
        true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          child: Card(
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Colors.indigo,
                    ),

                    const SizedBox(height: 18),

                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Поле імені лише для реєстрації
                    if (widget.action == AuthAction.signup) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        textCapitalization:
                        TextCapitalization.words,
                        validator: (value) {
                          if (value == null ||
                              value.trim().length < 2) {
                            return 'Введіть ім\'я';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email для всіх трьох форм
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'test@example.com',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // Пароль для входу та реєстрації
                    if (widget.action != AuthAction.reset) ...[
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Повторення пароля при реєстрації
                    if (widget.action == AuthAction.signup) ...[
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon:
                          Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Повторіть пароль';
                          }

                          if (value !=
                              _passwordController.text) {
                            return 'Паролі не збігаються';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 8),

                    // Кнопка надсилання запиту
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed:
                        _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          _buttonText,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'HTTP POST $_endpoint',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Flutter + Dio + RequestCatcher',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
