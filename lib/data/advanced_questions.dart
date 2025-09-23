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
  // 1
  AdvancedQuestion(
    id: 'q01',
    question: 'Dos bancos existentes no mercado, qual é o primeiro banco que lhe vem à cabeça?',
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
  // 2
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
  // 3
  AdvancedQuestion(
    id: 'q03',
    question: 'Dos bancos onde tem conta, qual é o seu banco principal? (Aquele com o qual mais se relaciona)',
    type: QuestionType.singleChoice,
    options: [], // Preenchido dinamicamente com os bancos selecionados em q02
    allowOther: true,
  ),
  // 4
  AdvancedQuestion(
    id: 'q04',
    question: 'Por que escolheu o seu banco principal?',
    type: QuestionType.multipleChoice,
    options: [
      'Reputação/imagem corporativa', 'Proximidade da sucursal', 'Conselhos de familiares ou amigos',
      'Qualidade do serviço', 'Condições económicas (impostos, custos)', 'Experiências anteriores positivas',
      'Já utilizado em ambiente de trabalho/família', 'Competência e cortesia do pessoal',
      'Serviços digitais fáceis de utilizar', 'Utilização do banco para a hipoteca',
      'Garantia de ter moeda estrangeira todos os meses', 'Relação criada com o gestor de conta', 'Outro'
    ],
    allowOther: true,
  ),
  // 5
  AdvancedQuestion(
    id: 'q05',
    question: 'Por que escolheu o outro banco?',
    type: QuestionType.multipleChoice,
    options: [
      'Reputação/imagem corporativa', 'Proximidade da sucursal', 'Conselhos de familiares ou amigos',
      'Qualidade do serviço', 'Condições económicas (impostos, custos)', 'Experiências anteriores positivas',
      'Já utilizado em ambiente de trabalho/família', 'Competência e cortesia do pessoal',
      'Serviços digitais fáceis de utilizar', 'Utilização do banco para a hipoteca',
      'Garantia de ter moeda estrangeira todos os meses', 'Relação criada com o gestor de conta', 'Já não uso o banco', 'Outro'
    ],
    allowOther: true,
  ),
  // 6
  AdvancedQuestion(
    id: 'q06',
    question: 'De um modo geral, como se relaciona com os bancos?',
    type: QuestionType.singleChoice,
    options: [
      'Maioritariamente de forma presencial, nas agências ou balcões',
      'Simultaneamente de forma presencial e digital',
      'Maioritariamente de forma digital (sem necessidade de deslocação às agências ou balcões)'
    ],
  ),
  // 7
  AdvancedQuestion(
    id: 'q07',
    question: 'Considerando uma escala de 1 a 10, em que 1 significa totalmente insatisfeito e 10 totalmente satisfeito, qual a sua satisfação com os bancos onde tem conta?',
    type: QuestionType.scale,
    scaleMin: 1,
    scaleMax: 10,
  ),
  // 8
  AdvancedQuestion(
    id: 'q08',
    question: 'No geral, em que canais costuma obter informações sobre os bancos?',
    type: QuestionType.multipleChoice,
    options: [
      'TV', 'Rádio', 'Redes sociais (Facebook, Instagram, Linkedin)', 'Amigos ou familiares', 'Agências/Balcões', 'Jornais ou revistas', 'Outro'
    ],
    allowOther: true,
  ),
  // 9
  AdvancedQuestion(
    id: 'q09',
    question: 'Que serviços utiliza em "Banco X"?',
    type: QuestionType.multipleChoice,
    options: [
      'Levantamento (retirada de dinheiro)', 'Depósitos', 'Transferências interbancárias', 'Transferências internacionais',
      'Home Banking', 'Aplicativo bancário', 'Pagamentos automáticos', 'Gestão de contas online',
      'Pagamento de contas (água, eletricidade, telefone, gás...)', 'Pagamento de impostos', 'Seguro de vida', 'Seguro de automóvel',
      'Seguro de habitação', 'Seguro de acidentes pessoais', 'Compra/venda de moeda estrangeira', 'Domiciliação do ordenado'
    ],
  ),
  // 10
  AdvancedQuestion(
    id: 'q10',
    question: 'Que produtos utiliza em "Banco X"?',
    type: QuestionType.multipleChoice,
    options: [
      'Conta corrente', 'Cartão de débito', 'Cartão de crédito', 'Cartão pré-pago',
      'Conta a prazo / débito a prazo', 'Crédito pessoal', 'Crédito habitação', 'Crédito automóvel',
      'Fundo de investimento', 'Obrigações'
    ],
  ),
  // 11
  AdvancedQuestion(
    id: 'q11',
    question: 'O que mais importa para você ao escolher um banco? (escala 1-5)',
    type: QuestionType.scale,
    scaleMin: 1,
    scaleMax: 5,
  ),
  // 12
  AdvancedQuestion(
    id: 'q12',
    question: 'Análise de sentimento positivo ou negativo? Por quê?',
    type: QuestionType.text,
  ),
  // 13
  AdvancedQuestion(
    id: 'q13',
    question: 'Em uma escala de 0 a 10, qual é a probabilidade de recomendar o "Banco X" a um amigo ou colega?',
    type: QuestionType.scale,
    scaleMin: 0,
    scaleMax: 10,
  ),
  // 14
  AdvancedQuestion(
    id: 'q14',
    question: 'Qual a principal razão desta recomendação?',
    type: QuestionType.text,
  ),
  // 15
  AdvancedQuestion(
    id: 'q15',
    question: 'Género',
    type: QuestionType.singleChoice,
    options: ['Masculino', 'Feminino'],
  ),
  // 16
  AdvancedQuestion(
    id: 'q16',
    question: 'Faixa etária',
    type: QuestionType.singleChoice,
    options: [
      '18 aos 25 anos', '26 aos 35 anos', '36 aos 45 anos', '46 aos 55 anos', 'Mais de 56 anos'
    ],
  ),
  // 17
  AdvancedQuestion(
    id: 'q17',
    question: 'Profissão',
    type: QuestionType.text,
  ),
  // 18
  AdvancedQuestion(
    id: 'q18',
    question: 'Escolaridade',
    type: QuestionType.text,
  ),
  // 19
  AdvancedQuestion(
    id: 'q19',
    question: 'Rendimento médio mensal',
    type: QuestionType.singleChoice,
    options: [
      'Inferior a 250.000,00 AKZ', '250.000,00 -- 500.000,00 AKZ', '500.000,00 -- 1.000.000,00 AKZ',
      '1.000.000,00 -- 2.500.000,00 AKZ', '2.500.000,00 -- 5.000.000,00 AKZ', 'Superior a 5.000.000,00 AKZ'
    ],
  ),
];
