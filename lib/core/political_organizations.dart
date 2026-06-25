class PoliticalOrganization {
  final String name;
  final String party;
  PoliticalOrganization(this.name, this.party);
}

List<PoliticalOrganization> getOrganizacionesAlcalde() => [
  PoliticalOrganization('Pabel Muñoz', 'Movimiento Pueblo Igual'),
  PoliticalOrganization('Jorge Yunda', 'Avanza'),
  PoliticalOrganization('John Reimberg', 'ADN'),
  PoliticalOrganization('Marlene Cevallos', 'Movimiento Social'),
  PoliticalOrganization('Mario Jaramillo', 'Partido Liberal'),
];

List<PoliticalOrganization> getOrganizacionesPrefecto() => [
  PoliticalOrganization('Rosa Cárdenas', 'Movimiento Pueblo Igual'),
  PoliticalOrganization('Luis Torres', 'Avanza'),
  PoliticalOrganization('Ana Belén', 'ADN'),
  PoliticalOrganization('Fernando Vega', 'Movimiento Social'),
  PoliticalOrganization('Carlos Rivas', 'Partido Liberal'),
];

Map<String, List<PoliticalOrganization>> getOrganizacionesPorDignidad() => {
  'alcalde': getOrganizacionesAlcalde(),
  'prefecto': getOrganizacionesPrefecto(),
};
