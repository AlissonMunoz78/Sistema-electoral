class PoliticalOrganization {
  final String name;
  final String party;
  PoliticalOrganization(this.name, this.party);
}

List<PoliticalOrganization> getOrganizacionesAlcalde() => [
  PoliticalOrganization('María Fernanda Salazar', 'Acción Democrática Nacional (ADN)'),
  PoliticalOrganization('Pabel Muñoz', 'Revolución Ciudadana (RC5)'),
  PoliticalOrganization('Esteban Cárdenas', 'Partido Social Cristiano (PSC)'),
  PoliticalOrganization('Luis Herrera', 'Avanza'),
  PoliticalOrganization('Andrés Quishpe', 'Pachakutik'),
];

List<PoliticalOrganization> getOrganizacionesPrefecto() => [
  PoliticalOrganization('Diego Almeida', 'Acción Democrática Nacional (ADN)'),
  PoliticalOrganization('Paola Pabón', 'Revolución Ciudadana (RC5)'),
  PoliticalOrganization('Roberto Freire', 'Partido Social Cristiano (PSC)'),
  PoliticalOrganization('Cristina Vallejo', 'Avanza'),
  PoliticalOrganization('José Guamán', 'Pachakutik'),
];

Map<String, List<PoliticalOrganization>> getOrganizacionesPorDignidad() => {
  'alcalde': getOrganizacionesAlcalde(),
  'prefecto': getOrganizacionesPrefecto(),
};
