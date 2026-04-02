// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rpl1getx/app/modules/auth/controllers/auth_controller.dart';

// class RegisterView extends GetView {
//   RegisterView({super.key});
//   final AuthController c = Get.put(AuthController());

//   final nameC = TextEditingController();
//   final emailC = TextEditingController();
//   final passwordC = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFF74B9FF)],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 40),

//                   // Back Button
//                   Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(
//                             Icons.arrow_back_rounded,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => Get.back(),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   // Logo/Icon
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.person_add_rounded,
//                       size: 60,
//                       color: Colors.white,
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // Title
//                   const Text(
//                     'Create Account',
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   const Text(
//                     'Join us and explore amazing features',
//                     style: TextStyle(fontSize: 16, color: Colors.white70),
//                   ),

//                   const SizedBox(height: 40),

//                   // Form Card
//                   Container(
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(25),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           // Name Field
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF8F9FA),
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: Colors.grey.withOpacity(0.2),
//                               ),
//                             ),
//                             child: TextFormField(
//                               controller: nameC,
//                               decoration: const InputDecoration(
//                                 labelText: 'Full Name',
//                                 prefixIcon: Icon(
//                                   Icons.person_rounded,
//                                   color: Color(0xFF6C5CE7),
//                                 ),
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.all(16),
//                                 labelStyle: TextStyle(color: Colors.grey),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your name';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),

//                           const SizedBox(height: 16),

//                           // Email Field
//                           Container(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF8F9FA),
//                               borderRadius: BorderRadius.circular(15),
//                               border: Border.all(
//                                 color: Colors.grey.withOpacity(0.2),
//                               ),
//                             ),
//                             child: TextFormField(
//                               controller: emailC,
//                               keyboardType: TextInputType.emailAddress,
//                               decoration: const InputDecoration(
//                                 labelText: 'Email Address',
//                                 prefixIcon: Icon(
//                                   Icons.email_rounded,
//                                   color: Color(0xFF6C5CE7),
//                                 ),
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.all(16),
//                                 labelStyle: TextStyle(color: Colors.grey),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter your email';
//                                 }
//                                 if (!GetUtils.isEmail(value)) {
//                                   return 'Please enter a valid email';
//                                 }
//                                 return null;
//                               },
//                             ),
//                           ),

//                           const SizedBox(height: 16),

//                           // Password Field
//                           Obx(
//                             () => Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF8F9FA),
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(
//                                   color: Colors.grey.withOpacity(0.2),
//                                 ),
//                               ),
//                               child: TextFormField(
//                                 controller: passwordC,
//                                 obscureText: c.isPasswordHidden.value,
//                                 decoration: InputDecoration(
//                                   labelText: 'Password',
//                                   prefixIcon: const Icon(
//                                     Icons.lock_rounded,
//                                     color: Color(0xFF6C5CE7),
//                                   ),
//                                   suffixIcon: IconButton(
//                                     icon: Icon(
//                                       c.isPasswordHidden.value
//                                           ? Icons.visibility_rounded
//                                           : Icons.visibility_off_rounded,
//                                       color: Colors.grey,
//                                     ),
//                                     onPressed: c.togglePasswordVisibility,
//                                   ),
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.all(16),
//                                   labelStyle: const TextStyle(
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter your password';
//                                   }
//                                   if (value.length < 6) {
//                                     return 'Password must be at least 6 characters';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 32),

//                           // Register Button
//                           Obx(
//                             () => Container(
//                               width: double.infinity,
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [
//                                     Color(0xFF6C5CE7),
//                                     Color(0xFFA29BFE),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(28),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: const Color(
//                                       0xFF6C5CE7,
//                                     ).withOpacity(0.3),
//                                     blurRadius: 15,
//                                     offset: const Offset(0, 8),
//                                   ),
//                                 ],
//                               ),
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(28),
//                                   onTap: c.isLoading.value
//                                       ? null
//                                       : () {
//                                           if (_formKey.currentState!
//                                               .validate()) {
//                                             c.register(
//                                               nameC.text,
//                                               emailC.text,
//                                               passwordC.text,
//                                             );
//                                           }
//                                         },
//                                   child: Center(
//                                     child: c.isLoading.value
//                                         ? const SizedBox(
//                                             width: 24,
//                                             height: 24,
//                                             child: CircularProgressIndicator(
//                                               valueColor:
//                                                   AlwaysStoppedAnimation<Color>(
//                                                     Colors.white,
//                                                   ),
//                                               strokeWidth: 2,
//                                             ),
//                                           )
//                                         : const Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               Icon(
//                                                 Icons.person_add_rounded,
//                                                 color: Colors.white,
//                                               ),
//                                               SizedBox(width: 12),
//                                               Text(
//                                                 'Create Account',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 24),

//                           // Login Link
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Text(
//                                 'Already have an account? ',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                               TextButton(
//                                 onPressed: () => Get.back(),
//                                 child: const Text(
//                                   'Sign In',
//                                   style: TextStyle(
//                                     color: Color(0xFF6C5CE7),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }