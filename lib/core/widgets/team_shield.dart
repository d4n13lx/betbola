import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

/// Escudo do time (SVG).
///
/// Estratégia:
/// 1. Baixa o SVG via `http.get` (segue redirects automaticamente)
/// 2. Renderiza com [SvgPicture.memory]
/// 3. Se falhar (404, rede, SVG inválido), mostra fallback com iniciais
class TeamShield extends StatefulWidget {
  final String escudo;
  final String name;
  final double size;

  const TeamShield({
    super.key,
    required this.escudo,
    required this.name,
    this.size = 70,
  });

  @override
  State<TeamShield> createState() => _TeamShieldState();
}

class _TeamShieldState extends State<TeamShield> {
  Uint8List? _svgBytes;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _carregarSvg();
  }

  @override
  void didUpdateWidget(covariant TeamShield oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.escudo != widget.escudo) {
      _svgBytes = null;
      _failed = false;
      _carregarSvg();
    }
  }

  Future<void> _carregarSvg() async {
    if (widget.escudo.isEmpty) {
      setState(() => _failed = true);
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http
          .get(Uri.parse(widget.escudo))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        if (mounted) {
          setState(() {
            _svgBytes = response.bodyBytes;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _failed = true;
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _placeholder(loading: true);
    }

    if (_failed || _svgBytes == null) {
      return _initials();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(
        child: SvgPicture.memory(
          _svgBytes!,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => _placeholder(loading: true),
        ),
      ),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: Color(0xFF292F2B),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFB9FF3D),
                ),
              )
            : Icon(Icons.shield,
                color: Colors.white54, size: widget.size * 0.5),
      ),
    );
  }

  Widget _initials() {
    final parts =
        widget.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    String initials;
    if (parts.isEmpty) {
      initials = '?';
    } else if (parts.length == 1) {
      initials =
          parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    } else {
      initials = (parts[0][0] + parts[1][0]).toUpperCase();
    }

    const colors = [
      Color(0xFFD32F2F),
      Color(0xFF1976D2),
      Color(0xFF388E3C),
      Color(0xFF7B1FA2),
      Color(0xFFF57C00),
      Color(0xFF00796B),
    ];
    int hash = 0;
    for (final c in widget.name.codeUnits) {
      hash = (hash * 31 + c) & 0x7FFFFFFF;
    }
    final color = colors[hash % colors.length];

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: widget.size * 0.35,
          ),
        ),
      ),
    );
  }
}
