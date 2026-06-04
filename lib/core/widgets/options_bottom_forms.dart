import 'package:flutter/material.dart';

class OptionsBottomForms extends StatelessWidget {
  final VoidCallback? onCalculate;
  final VoidCallback? onClear;
  final VoidCallback? onShare;

  const OptionsBottomForms({
    super.key,
    this.onCalculate,
    this.onClear,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    const darkButtonColor = Color(0xFF1A222D); 

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onCalculate,
            icon: const Icon(Icons.calculate_outlined, color: Colors.white),
            label: const Text('Calcular'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E94F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),

        Row(
          spacing: 12, // Espaçamento horizontal entre os dois botões
          children: [
            // Botão Limpar
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
                label: const Text('Limpar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            
            // Botão Compartilhar
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined, color: Colors.white70),
                label: const Text('Compartilhar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkButtonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
