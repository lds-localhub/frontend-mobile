/// Moradas conhecidas pelo stub do Nominatim (`integration_test/stubs/addresses.json`).
///
/// Os testes usam-nas em vez de escrever moradas à mão, para o backend
/// conseguir sempre convertê-las em coordenadas. Têm de ser iguais às do JSON.
/// Distâncias aproximadas a partir do Porto (carla): gaia 2,9 km,
/// matosinhos 7,5 km, maia 9,6 km, braga 46,6 km, aveiro 56,7 km.
const Map<String, String> testAddresses = {
  'carla': 'Rua das Flores Fictícia, 12, 4050-001 Porto',
  'hugo': 'Avenida da Boavista Fictícia, 900, 4100-001 Porto',
  'gaia': 'Rua do Teste Fictícia, 10, 4400-001 Vila Nova de Gaia',
  'matosinhos': 'Avenida do Mar Fictícia, 20, 4450-001 Matosinhos',
  'maia': 'Rua da Feira Fictícia, 30, 4470-001 Maia',
  'braga': 'Rua do Castelo Fictícia, 40, 4700-001 Braga',
  'aveiro': 'Rua da Ria Fictícia, 50, 3800-001 Aveiro',
};

/// Morada que o stub não conhece: o backend não a converte em coordenadas.
const String unknownAddress = 'Rua Inexistente Fictícia, 1, 0000-000 Nenhures';

/// `detail` do 400 do backend quando não converte a morada em coordenadas.
const String addressNotFound =
    'Não foi possível encontrar esta morada. Confirme-a.';
