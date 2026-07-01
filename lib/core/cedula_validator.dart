// Validador de cédula ecuatoriana.
//
// Algoritmo oficial (módulo 10) usado por el Registro Civil del Ecuador:
// 1. Los dos primeros dígitos representan el código de provincia (01-24, o 30
//    para extranjeros residentes con cédula ecuatoriana en algunos casos).
// 2. El tercer dígito debe ser menor a 6 para personas naturales.
// 3. Se aplica el algoritmo de Luhn modificado (módulo 10) sobre los primeros
//    9 dígitos, y el resultado debe coincidir con el décimo dígito (verificador).
//
// Referencia pública del algoritmo: documentación técnica del Registro Civil
// y validaciones replicadas en múltiples SDKs de validación ecuatoriana.
class CedulaValidator {
  /// Valida que [cedula] sea una cédula ecuatoriana válida.
  /// Devuelve true si es válida, false en caso contrario.
  static bool isValid(String cedula) {
    final cleaned = cedula.trim();

    // Debe tener exactamente 10 dígitos numéricos.
    if (cleaned.length != 10) return false;
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleaned)) return false;

    final digits = cleaned.split('').map(int.parse).toList();

    // Código de provincia: 01-24 (más 30 para casos especiales registrados).
    final provincia = digits[0] * 10 + digits[1];
    if (provincia < 1 || (provincia > 24 && provincia != 30)) return false;

    // Tercer dígito debe ser menor a 6 para cédulas de personas naturales.
    final tercerDigito = digits[2];
    if (tercerDigito > 6) return false;

    // Algoritmo módulo 10 (Luhn modificado):
    // Posiciones impares (índice 0,2,4,6,8) se multiplican por 2;
    // si el resultado es >= 10, se le resta 9.
    const coeficientes = [2, 1, 2, 1, 2, 1, 2, 1, 2];
    var suma = 0;
    for (var i = 0; i < 9; i++) {
      var valor = digits[i] * coeficientes[i];
      if (valor >= 10) valor -= 9;
      suma += valor;
    }

    final digitoVerificadorEsperado = (10 - (suma % 10)) % 10;
    final digitoVerificadorReal = digits[9];

    return digitoVerificadorEsperado == digitoVerificadorReal;
  }

  /// Devuelve un mensaje de error legible, o null si la cédula es válida.
  /// Útil para mostrar feedback directo en formularios.
  static String? validationMessage(String cedula) {
    final cleaned = cedula.trim();
    if (cleaned.isEmpty) return 'La cédula es obligatoria.';
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'La cédula debe contener solo números.';
    }
    if (cleaned.length != 10) {
      return 'La cédula debe tener exactamente 10 dígitos.';
    }
    if (!isValid(cleaned)) {
      return 'La cédula ingresada no es válida.';
    }
    return null;
  }
}