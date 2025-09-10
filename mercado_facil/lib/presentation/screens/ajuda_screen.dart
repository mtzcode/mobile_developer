import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AjudaScreen extends StatelessWidget {
  const AjudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda e Suporte'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_center, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Perguntas Frequentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    'Como fazer um pedido?',
                    'Navegue pelos produtos, adicione ao carrinho e finalize o pedido na tela de confirmação.',
                  ),
                  _buildFAQItem(
                    'Como acompanhar meu pedido?',
                    'Acesse "Meus Pedidos" no menu lateral para ver o status de todos os seus pedidos.',
                  ),
                  _buildFAQItem(
                    'Posso cancelar um pedido?',
                    'Sim, você pode cancelar pedidos que ainda não foram processados na tela de detalhes do pedido.',
                  ),
                  _buildFAQItem(
                    'Como alterar meus dados?',
                    'Acesse "Meus Dados" no menu lateral para editar suas informações pessoais.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_support, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Entre em Contato',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: const Text('suporte@mercadofacil.com'),
                    onTap: () => _launchEmail(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Telefone'),
                    subtitle: const Text('(11) 9999-9999'),
                    onTap: () => _launchPhone(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text('WhatsApp'),
                    subtitle: const Text('(11) 9999-9999'),
                    onTap: () => _launchWhatsApp(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Horário de Atendimento',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Segunda a Sexta: 8h às 18h'),
                  const Text('Sábado: 8h às 14h'),
                  const Text('Domingo: Fechado'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer),
        ),
      ],
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'suporte@mercadofacil.com',
      query: 'subject=Suporte Mercado Fácil',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+5511999999999');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/5511999999999');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }
}