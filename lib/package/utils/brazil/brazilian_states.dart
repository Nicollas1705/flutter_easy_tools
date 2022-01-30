import 'package:flutter_easy_tools/flutter_package.dart';

abstract class Brazil {
  static const List<_BrazilianStateUf> _states = [
    _BrazilianStateUf("Acre", "AC"),
    _BrazilianStateUf("Alagoas", "AL"),
    _BrazilianStateUf("Amapá", "AP"),
    _BrazilianStateUf("Amazonas", "AM"),
    _BrazilianStateUf("Bahia", "BA"),
    _BrazilianStateUf("Ceará", "CE"),
    _BrazilianStateUf("Espírito Santo", "ES"),
    _BrazilianStateUf("Goiás", "GO"),
    _BrazilianStateUf("Maranhão", "MA"),
    _BrazilianStateUf("Mato Grosso", "MT"),
    _BrazilianStateUf("Mato Grosso do Sul", "MS"),
    _BrazilianStateUf("Minas Gerais", "MG"),
    _BrazilianStateUf("Pará", "PA"),
    _BrazilianStateUf("Paraíba", "PB"),
    _BrazilianStateUf("Paraná", "PR"),
    _BrazilianStateUf("Pernambuco", "PE"),
    _BrazilianStateUf("Piauí", "PI"),
    _BrazilianStateUf("Rio de Janeiro", "RJ"),
    _BrazilianStateUf("Rio Grande do Norte", "RN"),
    _BrazilianStateUf("Rio Grande do Sul", "RS"),
    _BrazilianStateUf("Rondônia", "RO"),
    _BrazilianStateUf("Roraima", "RR"),
    _BrazilianStateUf("Santa Catarina", "SC"),
    _BrazilianStateUf("São Paulo", "SP"),
    _BrazilianStateUf("Sergipe", "SE"),
    _BrazilianStateUf("Tocantins", "TO"),
    _BrazilianStateUf("Distrito Federal", "DF"),
  ];

  /// [stateOrUf] as state name to get the uf or uf to get the state name
  ///
  /// Returns null if [stateOrUf] is null or not found
  static String? changeStateUf(String stateOrUf) {
    stateOrUf = Format.removeAccentAndPonctuation(stateOrUf);
    for (var state in _states) {
      if (stateOrUf.length == 2) {
        if (state.uf == stateOrUf) return state.name;
      } else {
        final name = Format.removeAccentAndPonctuation(state.name);
        if (name == stateOrUf) return state.uf;
      }
    }
    return null;
  }

  static List<String> getAllUfs() {
    List<String> result = [];
    for (var state in _states) {
      result.add(state.uf);
    }
    return result;
  }

  static List<String> getAllStateNames() {
    List<String> result = [];
    for (var state in _states) {
      result.add(state.name);
    }
    return result;
  }
}

class _BrazilianStateUf {
  final String name;
  final String uf;
  const _BrazilianStateUf(this.name, this.uf);
}
