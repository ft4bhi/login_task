// import 'package:flutter/material.dart';
// import 'package:chessground/chessground.dart';
// import 'package:dartchess/dartchess.dart' as dc;
//
// class ChessBoard extends StatelessWidget {
//   final double size;
//   final dc.Side orientation;
//   final String fen;
//   final GameData game;
//
//   const ChessBoard({
//     required this.size,
//     required this.orientation,
//     required this.fen,
//     required this.game,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Chessground(
//         size: BoardSize.square(size),
//         orientation: orientation == dc.Side.white
//             ? BoardOrientation.white
//             : BoardOrientation.black,
//         fen: fen,
//         interactableSide: game.playerSide == PlayerSide.white
//             ? InteractableSide.white
//             : InteractableSide.black,
//         onMove: (from, to, {promotion}) {
//           final move = dc.Move.fromUci('${from.name}${to.name}${promotion?.name ?? ''}');
//           game.onMove(move!);
//         },
//       ),
//     );
//   }
// }