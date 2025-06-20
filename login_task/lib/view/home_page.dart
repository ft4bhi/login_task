import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as ch;
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' as dc;
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

class HomePage extends StatefulWidget {
  final String accessToken;
  final String opponentUsername;

  const HomePage({
    required this.accessToken,
    required this.opponentUsername,
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ch.Chess _chess;
  late dc.Position _position;

  @override
  void initState() {
    super.initState();
    _chess = ch.Chess();
    // Create initial position using Setup.parseFen with standard starting position
    final setup = dc.Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
    _position = dc.Chess.fromSetup(setup);
  }

  ValidMoves getValidMoves() {
    // Get legal moves from dartchess position - this returns IMap<Square, SquareSet>
    final legalMoves = _position.legalMoves;

    // Convert SquareSet to ISet<Square> for each entry
    final Map<dc.Square, ISet<dc.Square>> validMovesMap = {};
    for (final entry in legalMoves.entries) {
      validMovesMap[entry.key] = entry.value.squares.toISet();
    }

    return validMovesMap.toIMap();
  }

  Pieces getCurrentPieces() {
    final Map<dc.Square, dc.Piece> pieces = {};

    // Get pieces from current position
    for (final square in dc.Square.values) {
      final piece = _position.board.pieceAt(square);
      if (piece != null) {
        pieces[square] = piece;
      }
    }

    return pieces;
  }

  void _makeMove(dc.Move move) {
    // Handle different move types from dartchess
    String? promotionPiece;
    if (move is dc.NormalMove && move.promotion != null) {
      promotionPiece = move.promotion!.name;
    }

    // Convert dartchess move to chess.dart format
    final chessMove = _chess.move({
      'from': move.to.name,
      'to': move.to.name,
      if (promotionPiece != null) 'promotion': promotionPiece,
    });

    if (chessMove != null) {
      // Update dartchess position for display
      final newPos = _position.playUnchecked(move);
      setState(() {
        _position = newPos;
      });
    }
  }

  dc.Move? _createMoveFromSquares(dc.Square from, dc.Square to, {dc.Role? promotion}) {
    // Create a normal move
    return dc.NormalMove(from: from, to: to, promotion: promotion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Play with ${widget.opponentUsername}')),
      body: Center(
        child: Chessboard(
          size: 360,
          orientation: dc.Side.white,
          fen: _position.fen,
          game: GameData(
            playerSide: PlayerSide.white,
            isCheck: _position.isCheck,
            sideToMove: _position.turn,
            validMoves: getValidMoves(),
            promotionMove: dc.NormalMove(
                from: dc.Square.a1,
                to: dc.Square.a1,
                promotion: dc.Role.queen
            ),
            onMove: (move, {isDrop}) {
              _makeMove(move);
            },
            onPromotionSelection: (role) {
              // Handle promotion piece selection
              // This will be called when user selects a promotion piece
            },
          ),
        ),
      ),
    );
  }
}