/// Lista completa de carreras disponibles en UPSA
const Map<String, String> careersMap = {
  'ing_civil': 'Ingeniería Civil',
  'ing_industrial': 'Ingeniería Industrial',
  'ing_sistemas': 'Ingeniería en Sistemas',
  'ing_electronica': 'Ingeniería Electrónica',
  'ing_mecanica': 'Ingeniería Mecánica',
  'arch': 'Arquitectura',
  'adm': 'Administración de Empresas',
  'contabilidad': 'Contabilidad',
  'derecho': 'Derecho',
  'psicologia': 'Psicología',
  'enfermeria': 'Enfermería',
  'medicina': 'Medicina',
  'biotec': 'Biotecnología',
  'agronomia': 'Agronomía',
  'comunicacion': 'Comunicación Social',
  'marketing': 'Marketing',
  'turismo': 'Turismo',
  'gastronomia': 'Gastronomía',
  'educacion': 'Educación',
  'lenguas': 'Lenguas Extranjeras',
};

List<String> get careersList => careersMap.keys.toList();
List<String> get careerNames => careersMap.values.toList();

class UpsaCareers {
  static const List<String> allCareers = [
    'Ingeniería Civil',
    'Ingeniería Industrial',
    'Ingeniería en Sistemas',
    'Ingeniería Electrónica',
    'Ingeniería Mecánica',
    'Arquitectura',
    'Administración de Empresas',
    'Contabilidad',
    'Derecho',
    'Psicología',
    'Enfermería',
    'Medicina',
    'Biotecnología',
    'Agronomía',
    'Comunicación Social',
    'Marketing',
    'Turismo',
    'Gastronomía',
    'Educación',
    'Lenguas Extranjeras',
  ];
}
