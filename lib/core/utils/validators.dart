class Validators {
  Validators._();

  static bool validarCedula(String cedula) {
    final value = cedula.trim();
    if (value.length != 10) return false;
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return false;
    if (RegExp(r'^(\d)\1{9}$').hasMatch(value)) return false;

    final provincia = int.parse(value.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    final tercerDigito = int.parse(value.substring(2, 3));
    if (tercerDigito > 5) return false;

    final digits = value.split('').map(int.parse).toList();
    int suma = 0;
    for (int i = 0; i < 9; i++) {
      int val = digits[i];
      if (i.isEven) {
        val *= 2;
        if (val > 9) val -= 9;
      }
      suma += val;
    }

    final digitoVerificador = (10 - (suma % 10)) % 10;
    return digitoVerificador == digits[9];
  }

  static bool validarEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);

  static String? cedulaValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa la cédula';
    final cedula = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(cedula)) {
      return 'La cédula solo debe contener números';
    }
    if (cedula.length != 10) return 'La cédula debe tener 10 dígitos';
    if (!validarCedula(cedula)) return 'Cédula inválida';
    return null;
  }

  static String? requerido(String? value, {String campo = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? soloLetras(String? value, {String campo = 'Este campo'}) {
    final requeridoError = requerido(value, campo: campo);
    if (requeridoError != null) return requeridoError;
    final text = value!.trim();
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'-]+$").hasMatch(text)) {
      return '$campo solo debe contener letras';
    }
    return null;
  }

  static String? enteroPositivo(String? value, {String campo = 'Valor'}) {
    if (value == null || value.isEmpty) return '$campo es obligatorio';
    final n = int.tryParse(value);
    if (n == null) return '$campo debe ser un número entero';
    if (n < 0) return '$campo no puede ser negativo';
    return null;
  }

  static String? telefono(String? value, {String campo = 'Teléfono'}) {
    final requeridoError = requerido(value, campo: campo);
    if (requeridoError != null) return requeridoError;
    final text = value!.trim();
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return '$campo solo debe contener números';
    }
    if (text.length < 7 || text.length > 10) {
      return '$campo debe tener entre 7 y 10 dígitos';
    }
    return null;
  }
}
