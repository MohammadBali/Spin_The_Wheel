// sliced_circle.dart
// at C:\Users\mhdba\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_fortune_wheel-1.3.2\lib\src\wheel

// part of 'wheel.dart';
//
// class _TransformedCircleSlice extends StatelessWidget {
//   final TransformedFortuneItem item;
//   final StyleStrategy styleStrategy;
//   final _WheelData wheelData;
//   final int index;
//
//   const _TransformedCircleSlice({
//     Key? key,
//     required this.item,
//     required this.styleStrategy,
//     required this.index,
//     required this.wheelData,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final style = item.style ??
//         styleStrategy.getItemStyle(theme, index, wheelData.itemCount);
//
//     return Stack(
//       alignment: Alignment.topRight,
//
//       children: [
//         _CircleSliceLayout(
//           handler: item,
//           child: DefaultTextStyle(
//             textAlign: style.textAlign,
//             style: style.textStyle,
//             child: item.child,
//           ),
//           slice: _CircleSlice(
//             radius: wheelData.radius,
//             angle: wheelData.itemAngle,
//             fillColor: style.color,
//             strokeColor: style.borderColor,
//             strokeWidth: style.borderWidth,
//           ),
//         ),
//
//
//         Positioned(
//             right: 0,
//             top: 0,
//             // bottom: 0,
//             child: Transform.translate(
//               offset: Offset(15, -15),
//               child: Image.asset(
//                 'assets/images/others/nut.png',
//                 color: Colors.white,
//                 filterQuality: FilterQuality.high,
//                 height: 30,
//                 width: 30,
//               ),
//             )
//         ),
//
//         // Positioned(
//         //   right: 0,
//         //   child: Transform.rotate(
//         //     angle: _math.pi,
//         //     child: Image.asset(
//         //       'assets/images/others/nut-bolt.png',
//         //       color: Colors.white,
//         //       filterQuality: FilterQuality.high,
//         //       height: 30,
//         //       width: 30,
//         //     ),
//         //
//         //   //   CustomPaint(
//         //   //       painter: TriangleIndicatorPainter(
//         //   //         color: Colors.green, // Customize indicator color
//         //   //         size: 20, // Customize indicator size
//         //   //       ),
//         //   // )
//         //   ),
//         // ),
//       ],
//     );
//   }
// }
//
// class _CircleSlices extends StatelessWidget {
//   final List<TransformedFortuneItem> items;
//   final StyleStrategy styleStrategy;
//   final _WheelData wheelData;
//
//   const _CircleSlices({
//     Key? key,
//     required this.items,
//     required this.styleStrategy,
//     required this.wheelData,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final slices = [
//       for (var i = 0; i < items.length; i++)
//         Transform.translate(
//           offset: items[i].offset,
//           child: Transform.rotate(
//             alignment: Alignment.topLeft,
//             angle: items[i].angle,
//             child: _TransformedCircleSlice(
//               item: items[i],
//               styleStrategy: styleStrategy,
//               index: i,
//               wheelData: wheelData,
//             ),
//           ),
//         ),
//     ];
//
//     return Stack(
//       children: slices,
//     );
//   }
// }
//
//
// class TriangleIndicatorPainter extends CustomPainter {
//   final Color color;
//   final double size;
//
//   TriangleIndicatorPainter({required this.color, required this.size});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;
//
//     final path = Path();
//     path.moveTo(0, -this.size); // Top point
//     path.lineTo(-this.size / 2, 0); // Bottom left
//     path.lineTo(this.size / 2, 0); // Bottom right
//     path.close();
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
//
