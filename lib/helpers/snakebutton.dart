// import 'package:flutter/material.dart';
//
//
// class SnakeBorderButton extends StatefulWidget {
//   final VoidCallback onPressed;
//   final Widget child;
//
//   SnakeBorderButton({required this.onPressed, required this.child});
//
//   @override
//   _SnakeBorderButtonState createState() => _SnakeBorderButtonState();
// }
//
// class _SnakeBorderButtonState extends State<SnakeBorderButton> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return CustomPaint(
//           painter: SnakePainter(_controller.value),
//           child: ElevatedButton(
//             onPressed: widget.onPressed,
//             child: widget.child,
//             style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// class SnakePainter extends CustomPainter {
//   final double position;
//
//   SnakePainter(this.position);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue[900]!
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;
//
//     final path = Path();
//     path.moveTo(size.width * position, 0);
//     path.lineTo(size.width * position + size.width * 0.1, 0);
//     path.lineTo(size.width, size.height * position);
//     path.lineTo(0, size.height * position + size.height * 0.1);
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
