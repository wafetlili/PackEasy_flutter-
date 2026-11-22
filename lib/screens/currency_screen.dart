// ============================================================
// currency_screen.dart
// Convertisseur de devises : API REST (package http),
// FutureBuilder pour le chargement et ListView.builder pour la liste.
// ============================================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../utils/l10n_ext.dart';
import '../utils/ui.dart';
import '../widgets/glass_card.dart';
import '../widgets/state_views.dart';
import '../widgets/travel_background.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  // Devises proposées
  static const _currencies = ['EUR', 'USD', 'GBP', 'TND', 'MAD', 'DZD', 'EGP', 'SAR', 'AED', 'TRY', 'JPY', 'CAD'];

  final _api = ApiService();
  final _amountController = TextEditingController(text: '100');
  final _formKey = GlobalKey<FormState>();

  String _base = 'EUR';
  double _amount = 100;
  late Future<ExchangeRates> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchRates(_base);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Recharge les taux (changement de devise ou bouton "Réessayer")
  void _reload() {
    setState(() => _future = _api.fetchRates(_base));
  }

  // Met à jour le montant saisi (si le champ est valide)
  void _onAmountChanged(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value != null && value > 0) setState(() => _amount = value);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final number = NumberFormat('#,##0.00', lang);

    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l.currencyConverter),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Formulaire : montant + devise de départ
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: l.amount,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: _onAmountChanged,
                              validator: (v) {
                                final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                                if (n == null) return l.errorNumber;
                                if (n <= 0) return l.errorPositive;
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _base,
                              decoration: InputDecoration(
                                labelText: l.baseCurrency,
                                border: const OutlineInputBorder(),
                              ),
                              items: _currencies
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                _base = value;
                                _reload();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Résultat de l'API : chargement / erreur / liste
                Expanded(
                  child: FutureBuilder<ExchangeRates>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return LoadingView(message: l.loading);
                      }
                      if (snapshot.hasError) {
                        return ErrorView(message: l.ratesError, onRetry: _reload);
                      }

                      final data = snapshot.data!;
                      // On ne garde que les devises proposées (sauf la devise de départ)
                      final codes = _currencies.where((c) => c != data.base && data.rates.containsKey(c)).toList();

                      if (codes.isEmpty) {
                        return EmptyView(icon: Icons.currency_exchange, title: l.ratesError);
                      }

                      return Column(
                        children: [
                          Text(l.lastUpdate(formatDate(context, data.updatedAt))),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: codes.length,
                              itemBuilder: (context, i) {
                                final code = codes[i];
                                final converted = _amount * data.rates[code]!;
                                return GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(child: Text(code.substring(0, 1))),
                                    title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('1 ${data.base} = ${data.rates[code]!.toStringAsFixed(4)} $code'),
                                    trailing: Text(number.format(converted),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
