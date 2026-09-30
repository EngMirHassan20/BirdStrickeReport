import 'dart:math';
import 'package:flutter/material.dart';
import 'package:birdhitting_app/pages/info_card_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  bool changeButton = false;
  bool _obscurePassword = true;

  late AnimationController _bgController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _fade = CurvedAnimation(parent: _formController, curve: Curves.easeIn);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buttonScale = Tween<double>(begin: 1, end: 0.85).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> moveToHome(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => changeButton = true);

      await _buttonController.forward();

      await Future.delayed(const Duration(milliseconds: 600));

      //  MOVE TO INFO CARD PAGE
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InfoCardPage()),
      );

      await _buttonController.reverse();
      setState(() => changeButton = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Scaffold(
            body: Stack(
              children: [
                // ================= BACKGROUND IMAGE =================
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/aeroplane.png",
                    fit: BoxFit.cover,
                  ),
                ),

                // ================= DARK OVERLAY =================
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.35)),
                ),

                // ================= OPTIONAL FLYING BIRDS =================
                ...List.generate(12, (i) => _bird(i)),

                // ================= LOGIN FORM =================
                Center(
                  child: SingleChildScrollView(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Container(
                              padding: const EdgeInsets.all(25),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ================= LOGO =================
                                  Container(
                                    height: 110,
                                    width: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          "../android/assets/paalogo.png",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  const Text(
                                    "Bird Strike Report",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // ======== USERNAME ========
                                  TextFormField(
                                    style: const TextStyle(color: Colors.white),
                                    validator: (v) =>
                                        v!.isEmpty ? "Enter username" : null,
                                    decoration: InputDecoration(
                                      hintText: "Username",
                                      hintStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      filled: true,
                                      fillColor: Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ).withOpacity(0.12),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            233,
                                            232,
                                            232,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            233,
                                            232,
                                            232,
                                          ),
                                          width: 2,
                                        ),
                                      ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            233,
                                            232,
                                            232,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // ======== PASSWORD ========
                                  TextFormField(
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    validator: (v) => v!.length < 6
                                        ? "Min 6 characters"
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: "Password",
                                      hintStyle: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                        color: Colors.white,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.12),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            233,
                                            232,
                                            232,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            233,
                                            232,
                                            232,
                                          ),
                                          width: 2,
                                        ),
                                      ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            233,
                                            232,
                                            232,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 25),

                                  // ======== LOGIN BUTTON ========
                                  ScaleTransition(
                                    scale: _buttonScale,
                                    child: GestureDetector(
                                      onTap: changeButton
                                          ? null
                                          : () => moveToHome(context),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        height: 50,
                                        width: changeButton ? 50 : 150,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.pinkAccent,
                                              Colors.deepPurple,
                                              Colors.blueAccent,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: changeButton
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                "LOGIN",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bird(int index) {
    final random = Random(index);

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top:
              (random.nextDouble() * MediaQuery.of(context).size.height +
                  (_bgController.value * 250)) %
              MediaQuery.of(context).size.height,
          child: Transform.rotate(
            angle: -0.3,
            child: FaIcon(
              FontAwesomeIcons.dove,
              size: random.nextDouble() * 20 + 25,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        );
      },
    );
  }
}
