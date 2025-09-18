enum QuestionType {
  singleChoice,
  multipleChoice,
  text,
  scale,
}

class AdvancedQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final bool allowOther;
  final int? scaleMin;
  final int? scaleMax;

  AdvancedQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    this.allowOther = false,
    this.scaleMin,
    this.scaleMax,
  });
}

final List<AdvancedQuestion> advancedQuestions = [
  AdvancedQuestion(
    id: 'q01',
    question: 'Dos bancos existentes no mercado, qual é o primeiro que lhe vem à cabeça?',
    type: QuestionType.singleChoice,
    options: [
      'BAI', 'BIC', 'BIR', 'Caixa Geral Angola', 'BCA', 'Banco Comercial do Huambo',
      'BCI (Comércio e Indústria)', 'BCS (Crédito do Sul)', 'BFA', 'BNI', 'BPC (Poupança e Crédito)',
      'Banco Económico', 'Banco Keve', 'Banco Millennium Atlântico', 'Banco Rural de Investimento',
      'Banco Sol', 'Banco Valor', 'Banco VTB África', 'Banco Yetu', 'Access Bank',
      'SBA (Standard Bank Angola)', 'Outro'
    ],
    allowOther: true,
  ),
  AdvancedQuestion(
    id: 'q02',
    question: 'Em que bancos tem conta atualmente?',
    type: QuestionType.multipleChoice,
    options: [
      'BAI', 'BIC', 'BIR', 'Caixa Geral Angola', 'BCA', 'Banco Comercial do Huambo',
      'BCI (Comércio e Indústria)', 'BCS (Crédito do Sul)', 'BFA', 'BNI', 'BPC (Poupança e Crédito)',
      'Banco Económico', 'Banco Keve', 'Banco Millennium Atlântico', 'Banco Rural de Investimento',
      'Banco Sol', 'Banco Valor', 'Banco VTB África', 'Banco Yetu', 'Access Bank',
      'SBA (Standard Bank Angola)', 'Outro'
    ],
    allowOther: true,
  ),
  AdvancedQuestion(
    id: 'q03',
    question: 'Qual é o seu banco principal?',
    type: QuestionType.singleChoice,
    options: [], // Preenchido dinamicamente com os bancos selecionados em q02
  ),
  AdvancedQuestion(
    id: 'q04',
    question: 'Por que escolheu o seu banco principal?',
    type: QuestionType.multipleChoice,
    options: [
      'Reputação/imagem corporativa', 'Proximidade da agência', 'Conselhos de familiares ou amigos',
      'Qualidade do serviço', 'Condições econômicas', 'Experiências anteriores positivas',
      'Já utilizado no ambiente de trabalho/família', 'Competência e cortesia do pessoal',
      'Serviços digitais fáceis de utilizar', 'Utilização para hipoteca',
      'Garantia de moeda estrangeira', 'Relação com gestor de conta', 'Outro'
    ],
    allowOther: true,
  ),
  AdvancedQuestion(
    id: 'q05',
    question: 'Por que escolheu o outro banco?',
    type: QuestionType.multipleChoice,
    options: [
      'Reputação/imagem corporativa', 'Proximidade da agência', 'Conselhos de familiares ou amigos',
      'Qualidade do serviço', 'Condições econômicas', 'Experiências anteriores positivas',
      'Já utilizado no ambiente de trabalho/família', 'Competência e cortesia do pessoal',
      'Serviços digitais fáceis de utilizar', 'Utilização para hipoteca',
      'Garantia de moeda estrangeira', 'Relação com gestor de conta', 'Já não uso o banco', 'Outro'
    ],
    allowOther: true,
  ),
  AdvancedQuestion(
    id: 'q06',
    question: 'Como se relaciona com os bancos?',
    type: QuestionType.singleChoice,
    options: [
      'Maioritariamente presencial', 'Simultaneamente presencial e digital', 'Maioritariamente digital'
    ],
  ),
  AdvancedQuestion(
    id: 'q07',
    question: 'Numa escala de 1 a 10, qual é a sua satisfação com os bancos onde tem conta?',
    type: QuestionType.scale,
    scaleMin: 1,
    scaleMax: 10,
  ),
  AdvancedQuestion(
    id: 'q08',
    question: 'Em que canais costuma obter informações sobre os bancos?',
    type: QuestionType.multipleChoice,
    options: [
      'TV', 'Rádio', 'Redes sociais', 'Amigos ou familiares', 'Agências/Balcões', 'Jornais ou revistas', 'Outro'
    ],
    allowOther: true,
  ),
  AdvancedQuestion(
    id: 'q09',
    question: 'Que serviços utiliza no "Banco X"?',
    type: QuestionType.multipleChoice,
    options: [
      'Levantamento', 'Depósitos', 'Transferências interbancárias', 'Transferências internacionais',
      'Home Banking', 'Aplicativo bancário', 'Pagamentos automáticos', 'Gestão de contas online',
      'Pagamento de contas', 'Pagamento de impostos', 'Seguro de vida', 'Seguro de automóvel',
      'Seguro de habitação', 'Seguro de acidentes pessoais', 'Compra/venda de moeda estrangeira',
      'Domiciliação do salário'
    ],
  ),
  AdvancedQuestion(
    id: 'q10',
    question: 'Que produtos utiliza no "Banco X"?',
    type: QuestionType.multipleChoice,
    options: [
      'Conta corrente', 'Cartão de débito', 'Cartão de crédito', 'Cartão pré-pago',
      'Conta a prazo', 'Crédito pessoal', 'Crédito habitação', 'Crédito automóvel',
      'Fundo de investimento', 'Obrigações'
    ],
  ),
  AdvancedQuestion(
    id: 'q11',
    question: 'O que mais importa (escala 1-5)',
    type: QuestionType.scale,
    scaleMin: 1,
    scaleMax: 5,
  ),
];
