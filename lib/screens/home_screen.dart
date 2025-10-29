import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sicredo/routes/app_routes.dart'; // Mantenha a importação de rotas

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados de exemplo para o gráfico e a lista
    final Map<String, double> dataMap = {
      "Contas": 30,
      "Lazer": 35,
      "Mercado": 10,
      "Transporte": 25,
    };

    // Cores baseadas na sua imagem de referência (grafico_pizza.webp)
    final List<Color> colorList = [
      const Color(0xff00675b), // Verde escuro
      const Color(0xffc21807), // Vermelho
      const Color(0xff4d4d4d), // Cinza escuro
      const Color(0xff8bc34a), // Verde claro
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Dashboard'),
        backgroundColor: Colors.green, // Combinando com o tema
        actions: [
          // Botão para ir para Configurações, por exemplo
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.slaoq);
            },
          ),

          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.welcome);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARD DE SALDO ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SALDO ATUAL',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'R\$ 2.845,00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- GRÁFICO DE PIZZA ---
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  // Remove os números de porcentagem do gráfico
                  sectionsSpace: 4, // Espaço entre as fatias
                  centerSpaceRadius:
                      60, // Raio do buraco no centro (para virar "donut")
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      // Você pode adicionar interatividade aqui se quiser
                    },
                  ),
                  sections: List.generate(dataMap.length, (index) {
                    final entry = dataMap.entries.elementAt(index);
                    return PieChartSectionData(
                      color: colorList[index],
                      value: entry.value,
                      title: '', // Título vazio para não mostrar texto na fatia
                      radius: 50, // Raio da fatia
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Detalhes das Despesas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // --- LEGENDA / LISTA DE ITENS ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: List.generate(dataMap.length, (index) {
                  final entry = dataMap.entries.elementAt(index);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 10,
                      backgroundColor: colorList[index],
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value.toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
            ),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: List.generate(dataMap.length, (index) {
                  final entry = dataMap.entries.elementAt(index);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 10,
                      backgroundColor: colorList[index],
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value.toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
