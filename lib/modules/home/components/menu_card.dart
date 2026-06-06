import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final Color cardColor;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.cardColor,
    required this.iconColor,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double alturaDisponivel = constraints.maxHeight;
          
          final bool telaMuitoPequena = alturaDisponivel < 100;

          return Container(
            padding: EdgeInsets.all(telaMuitoPequena ? 8 : 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bloco do Ícone
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2A3D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon, 
                    color: iconColor, 
                    size: telaMuitoPequena ? 20 : 26,
                  ),
                ),
                
                // Bloco de Textos autoajustável
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: telaMuitoPequena ? 11 : 13, // Fonte menor para cartões pequenos
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1, // Reduzido para 1 linha para garantir estabilidade visual no mobile
                        overflow: TextOverflow.fade,
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: telaMuitoPequena ? 9 : 10,
                          height: 1.1,
                        ),
                        maxLines: telaMuitoPequena ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
