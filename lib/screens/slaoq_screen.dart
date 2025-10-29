import 'package:flutter/material.dart';

class SlaoqScreen extends StatelessWidget {
  const SlaoqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo cores para fácil reutilização
    const Color primaryTextColor = Color(0xFF1A1A1A);
    const Color secondaryTextColor = Color(0xFF8A8A8A);
    const Color cardBackgroundColor = Color(0xFFFFFFFF);
    const Color inviteCardColor = Color(0xFF2A9D8F); // Um verde azulado

    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F8,
      ), // Um cinza bem claro para o fundo
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryTextColor, // Cor dos ícones e texto de volta
        title: const Text(
          'Minha Conta',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- CABEÇALHO DO PERFIL ---
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                'assets/images/profile_image.jpg', // Imagem de placeholder
              ), // Imagem de placeholder
            ),
            const SizedBox(height: 12),
            const Text(
              'Jarvis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 24),

            // --- CARD DE RESUMO DE GASTOS ---
            _buildSpendingCard(
              primaryTextColor,
              secondaryTextColor,
              cardBackgroundColor,
            ),

            const SizedBox(height: 20),

            // --- CARD DE CONVITE ---
            _buildInviteCard(inviteCardColor),

            const SizedBox(height: 20),

            // --- LISTA DE OPÇÕES ---
            _buildOptionsList(primaryTextColor),
          ],
        ),
      ),
    );
  }

  // Widget para o Card de Resumo de Gastos
  Widget _buildSpendingCard(
    Color primaryTextColor,
    Color secondaryTextColor,
    Color cardBackgroundColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo de Gastos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'R\$12,521.10',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'de R\$20,000.00',
                  style: TextStyle(fontSize: 14, color: secondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              value: 12521.10 / 20000.00,
              backgroundColor: Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
              minHeight: 8,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            const SizedBox(height: 16),
            _buildLegendRow(
              const Color(0xFF1E293B),
              'Assinaturas',
              'R\$8,221.00',
            ),
            const SizedBox(height: 8),
            _buildLegendRow(
              const Color(0xFF26A69A),
              'Amigos & Família',
              'R\$4,300.10',
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para as linhas da legenda
  Widget _buildLegendRow(Color color, String title, String amount) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Widget para o Card de Convite
  Widget _buildInviteCard(Color inviteCardColor) {
    return Card(
      color: inviteCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Convide Amigos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Convide para gerenciar as finanças e ganhe R\$100.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group_add, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para a lista de opções de menu
  Widget _buildOptionsList(Color primaryTextColor) {
    return Column(
      children: [
        _buildMenuOption(Icons.person_outline, 'Minha Conta', () {}),
        const Divider(),
        _buildMenuOption(Icons.history, 'Histórico de Transações', () {}),
        const Divider(),
        _buildMenuOption(
          Icons.security_outlined,
          'Configurações de Segurança',
          () {},
        ),
      ],
    );
  }

  // Widget auxiliar para cada item do menu
  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2A9D8F)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
