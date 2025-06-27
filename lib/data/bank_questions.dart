class BankQuestion {
  final String question;
  final List<String> options;

  BankQuestion({required this.question, required this.options});
}

final List<BankQuestion> bankQuestions = [
  BankQuestion(
    question: '¿Cuál es la función principal de un banco comercial?',
    options: [
      'Otorgar préstamos',
      'Emitir billetes',
      'Recaudar impuestos',
      'Regular la inflación',
    ],
  ),
  BankQuestion(
    question: '¿Qué es una cuenta de ahorros?',
    options: [
      'Una cuenta para guardar dinero y ganar intereses',
      'Una cuenta para pagar servicios',
      'Una cuenta para invertir en bolsa',
    ],
  ),
  BankQuestion(
    question: '¿Qué documento es necesario para abrir una cuenta bancaria?',
    options: [
      'Documento de identidad',
      'Licencia de conducir',
      'Pasaporte',
      'Recibo de luz',
    ],
  ),
  BankQuestion(
    question: '¿Qué es un cajero automático (ATM)?',
    options: [
      'Un dispositivo para retirar y depositar dinero',
      'Un empleado del banco',
      'Un tipo de préstamo',
    ],
  ),
  BankQuestion(
    question: '¿Qué significa la sigla “PIN” en el contexto bancario?',
    options: [
      'Personal Identification Number',
      'Pago Instantáneo Nacional',
      'Plan de Inversión Neta',
    ],
  ),
  BankQuestion(
    question: '¿Cuál de los siguientes productos bancarios genera intereses?',
    options: [
      'Cuenta de ahorros',
      'Cuenta corriente',
      'Tarjeta de débito',
      'Préstamo personal',
    ],
  ),
  BankQuestion(
    question: '¿Qué es una transferencia bancaria?',
    options: [
      'Enviar dinero de una cuenta a otra',
      'Pedir un préstamo',
      'Abrir una nueva cuenta',
    ],
  ),
  BankQuestion(
    question: '¿Qué es un crédito hipotecario?',
    options: [
      'Un préstamo para comprar una vivienda',
      'Un seguro de vida',
      'Un tipo de tarjeta de crédito',
    ],
  ),
  BankQuestion(
    question: '¿Cuál es la función de la banca móvil?',
    options: [
      'Permitir operaciones bancarias desde el celular',
      'Emitir cheques',
      'Ofrecer préstamos personales',
    ],
  ),
  BankQuestion(
    question: '¿Qué es un estado de cuenta?',
    options: [
      'Un resumen de movimientos y saldo de una cuenta',
      'Un tipo de tarjeta',
      'Un préstamo a corto plazo',
    ],
  ),
];