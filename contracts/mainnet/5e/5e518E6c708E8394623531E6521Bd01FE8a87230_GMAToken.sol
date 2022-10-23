// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract GMAToken is ERC20, Ownable {

    address public admin;

    constructor() ERC20('GMA Token', 'GMAT') {
        _mint(msg.sender, 32650800 * 10 ** 6);
        admin = msg.sender;
    }

    function mint(address to, uint amount) external {
        require(msg.sender == admin, 'Only admin');
        _mint(to, amount);
    }

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }

}

//Developed by KR Technology - https://krtecnology.website/
/* 
 * CONTRATO DE TRANSAÇÃO DE ATIVOS DIGITAIS
*/
//
//O presente CONTRATO DE TRANSAÇÃO DE ATIVOS DIGITAIS (doravante definidos como “CONTRATO”) é efetivo desde a data do aceite (“Data de Entrada em Vigor”) por e entre:
//
//GMA DIGITAL LTDA e empresas afiliadas, inscrita no CNPJ 28.079.171/0001-77, com sede na Rua LUIZ DE CAMÕES Nº 391, PORTO ALEGRE- RS (neste descrita como “GMA”); e
//
//O USUÁRIO, pessoa física ou jurídica, capaz, interessada em firmar o presente CONTRATO, a qual inscreveu-se na plataforma da GMA DIGITAL LTDA com adesão aos respectivos termos, preenchimento de informações e finalização do cadastro; (neste descrita como “USUÁRIO”); 
//
//Sendo ambas as partes designadas, em conjunto, como “PARTES”, e isoladamente como “PARTE”.
//
//CONSIDERANDO QUE, a GMA opera uma plataforma central de negociação de livros de ordens com limite pré-estabelecido, bem como liquida e processa negociações de diversos Ativos Digitais (“tokens” e “NFTs”) e moedas eletrônicas e/ou digitais (“criptoativos, stablecoins e criptomoedas”)
//
//CONSIDERANDO QUE, GMA e USUÁRIO desejam engajar em uma relação comercial no qual o USUÁRIO utilizará a plataforma para negociações envolvendo ativos digitais.
//
//CONSIDERANDO QUE, ao acessar, baixar, usar ou clicar em “Concordo” para aceitar quaisquer Serviços da GMA (conforme definido abaixo) fornecido pela GMA (conforme definido abaixo), o USUÁRIO reconhece que leu, entendeu e aceitou todos os termos e condições estipulados neste CONTRATO e nos Termos de Uso, bem como nossa Política de Privacidade e demais termos aplicáveis. Além disso, ao usar alguns recursos dos Serviços, poderá estar sujeito a termos e condições adicionais específicos aplicáveis aos mesmos.
//
//CONSIDERANDO QUE, ao se cadastrar na GMA EXCHANGE, uma plataforma digital para negociação de ativos digitais (definida como “Plataforma”), o USUÁRIO está ciente, reconhece, aceita e concorda com as condições deste CONTRATO, e que caso discorde não poderá utilizar os serviços e produtos oferecidos. 
//
//CONSIDERANDO QUE, a GMA é a empresa detentora da GMA EXCHANGE e de outras soluções, pela qual os USUÁRIOs podem acessar e realizar diversas operações e negociações com Ativos Digitais, próprios da GMA ou de terceiros através das plataformas.
//
//CONSIDERANDO QUE, a GMA também tokeniza e comercializa parte de seus ativos relacionadas às suas atividades e oferece a expertises de negociação com o objetivo disponibilizá-los no mercado de Ativos Digitais;
//
//CONSIDERANDO QUE, o USUÁRIO é detentor de conhecimento de riscos e operações do mercado de Ativos Digitais, conforme as Regras de Negociação e Aviso Geral de Riscos.
//
//CONSIDERANDO QUE, o USUÁRIO possui ciência que ativos digitais apresentam alta volatilidade e são considerados ativos de alto risco, podendo gerar prejuízos os quais a GMA não assume responsabilidade ou dever de indemnização. Como acontece com qualquer ativo, o valor dos Ativos Digitais pode subir ou descer e pode haver um risco substancial de USUÁRIO perder dinheiro comprando, vendendo, mantendo ou investindo em Ativos Digitais. Atualmente, os Serviços de Ativos Digitais não são plenamente regulamentados no Brasil. USUÁRIO deve considerar cuidadosamente se negociar ou manter Ativos Digitais é adequado para USUÁRIO à luz de sua condição financeira.
//
//CONSIDERANDO QUE, o USUÁRIO possui plena capacidade civil para celebrar este CONTRATO e assumir as obrigações deste decorrentes;
//
//ACORDAM as partes para com o CONTRATO onde USUÁRIO fica ciente e concorda que ao utilizar a plataforma, aderirá e concordará em se submeter integralmente às condições do mesmo e qualquer de seus aditivos futuros.
//
//Ao se inscrever para usar os serviços da GMA, o USUÁRIO concorda, leu, compreendeu e aceitou todos os termos e condições contidos neste CONTRATO, bem como nossa Política de Privacidade e Política de Cookies, Termos de Uso e outros Termos específicos.
//
//Referimo-nos aos Serviços de Ativos Digitais e Negociação de Ativos Digitais coletivamente como "Serviços GMA", que podem ser acessados através da plataforma operada pela GMA.
/*
 * 1.	OBJETO
*/
//1.1	O OBJETO deste CONTRATO são as transações com Ativos Digitais na plataforma GMA EXCHANGE ou outras conforme disponibilizado pela GMA. A aquisição dos Ativos Digitais pelo USUÁRIO se dará de acordo com as condições de preço e quantidade das regras e condições aceitas no momento da contratação. 
//
//1.2	A GMA disponibilizará produtos e serviços em tecnologia de transações em sua plataforma      . O USUÁRIO poderá ainda utilizar a plataforma da GMA para emitir ordens para compra ou venda dos ATIVOS DIGITAIS próprios ou de terceiros a serem adquiridos ou, sendo que tais transações serão efetuadas entre os próprios USUÁRIOs da plataforma. Se realizadas operações entre os USUÁRIOs, a GMA atuará apenas como intermediária, permitindo que os USUÁRIOs negociem entre si, sem participação ativa da GMA nas transações, cobrando apenas eventuais taxas de intermediação. Como condição para a utilização da plataforma, o USUÁRIO se compromete a não utilizar a plataforma da GMA para fins diretos ou indiretos de:
//i)	Violação de leis ou normas;
///ii)	Engajar com práticas de lavagem de dinheiro; e/ou
//iii)	atividades e/ou organizações que envolvam terrorismo, crime organizado, tráfico de drogas, pessoas e/ou órgãos humanos. 
//
//1.3	 Para que seja possível emitir uma ordem de venda, o USUÁRIO deverá possuir ATIVOS DIGITAIS ou outros criptoativos armazenados em sua wallet. A GMA esclarece que pode custodiar dinheiro e fazer arbitrage de ativos digitais. A GMA submeterá as carteiras digitais administradas à revisões e controles bimestrais de compliance e conciliação financeira que verificarão os saldos das carteiras, garantindo a real existência dos ativos mostrados na plataforma. O USUÁRIO é responsável, perante a GMA e perante quaisquer terceiros, inclusive autoridades locais a respeito do conteúdo das informações, a origem e a legitimidade dos ativos negociados na plataforma. 
//
//1.4	A distribuição de Ativos Digitais não é uma oferta pública de capital próprio ou dívida e, consequentemente, não se enquadra nos títulos ou em qualquer regulação do prospecto.  
/*
 * 2.	CONFIGURAÇÃO DE CONTA E CADASTRO
 */
//2.1	Registro da Conta GMA:
//Para usar os Serviços GMA, o USUÁRIO precisará se registrar fornecendo seus detalhes, incluindo seu nome, endereço de e-mail e uma senha, e aceitando os termos deste CONTRATO.
//
//Ao usar uma Conta GMA, USUÁRIO concorda e declara que usará os Serviços GMA apenas para si mesmo, e não em nome de terceiros, a menos que tenha obtido aprovação prévia da GMA.
//
//Cada cliente pode registrar apenas uma conta GMA. O USUÁRIO é totalmente responsável por todas as atividades que ocorrem em sua conta GMA.
//
//Podemos, a nosso exclusivo critério, recusar a abertura de uma Conta GMA para USUÁRIO, ou suspender ou encerrar quaisquer Contas GMA (incluindo, mas não se limitando a contas duplicadas) ou suspender ou encerrar a negociação de Ativos Digitais em sua conta.
//
//2.2	Acesso de terceiros.
//Se o USUÁRIO conceder permissão expressa a um Terceiro Regulamentado para acessar ou se conectar à(s) sua(s) Conta(s) GMA, seja por meio do produto ou serviço do Terceiro Regulamentado ou pelo Site, o USUÁRIO reconhece que conceder permissão para tomar ações específicas em seu nome, não o isenta de nenhuma de suas responsabilidades sob este CONTRATO. 
//
//O USUÁRIO é totalmente responsável por todos os atos ou omissões de qualquer Terceiro Regulamentado com acesso à(s) sua(s) Conta(s) GMA e ainda, de qualquer ação de tal Terceiro Regulamentado será considerada uma ação autorizada por USUÁRIO. Além disso, USUÁRIO reconhece e concorda que não responsabilizará e indenizará a GMA de qualquer responsabilidade decorrente ou relacionada a qualquer ato ou omissão de qualquer Terceiro Regulamentado com acesso à(s) sua(s) Conta(s) GMA.
//
//2.3	Verificação de Identidade.
//O USUÁRIO concorda em nos fornecer as informações que solicitamos (que podemos solicitar a qualquer momento considerado necessário) para fins de verificação de identidade e detecção de lavagem de dinheiro, financiamento do terrorismo, fraude ou qualquer outro crime financeiro, inclusive conforme estabelecido em Apêndice II (Procedimentos e Limites de Verificação) e nos permite manter um registro de tais informações. 
//
//O USUÁRIO precisará concluir certos procedimentos de verificação antes de ter permissão para começar a usar os Serviços GMA e acessar Serviços específicos, incluindo certas transferências de Wallet e Ativos Digitas, e os limites que se aplicam ao seu uso dos Serviços GMA podem ser alterados como resultado de informações coletadas continuamente.
//
//As informações que solicitamos podem incluir, porém não se limitam à:  informações pessoais, como seu nome, endereço residencial, número de telefone, endereço de e-mail, data de nascimento, número de identificação fiscal, número de identificação do governo, informações sobre sua conta bancária (como o número de nome do banco, tipo de conta, número de roteamento e número da conta) status da rede, tipo de cliente, função do cliente, tipo de cobrança, identificadores de dispositivos móveis (por exemplo, identidade de assinante móvel internacional e identidade de equipamento móvel internacional) e outros detalhes de status do assinante, e qualquer informação que a GMA seja obrigada a coletar de tempos em tempos de acordo com a lei aplicável.
//
//Ao nos fornecer qualquer outra informação que possa ser necessária, o USUÁRIO confirma que as informações são verdadeiras, precisas e completas, e que não reteve nenhuma informação que possa influenciar a avaliação da GMA sobre o USUÁRIO para fins de seu registro para uma Conta ou o fornecimento de Serviços.
//
//O USUÁRIO se compromete a notificar imediatamente por escrito e fornecer à GMA informações sobre quaisquer alterações nas circunstâncias que possam fazer com que tais informações fornecidas se tornem falsas, imprecisas ou incompletas, e também se compromete a fornecer quaisquer outros documentos, registros e informações adicionais que possam ser exigidos pela GMA e/ou legislação aplicável. 
//
//USUÁRIO nos autoriza a fazer consultas, diretamente ou por meio de terceiros, que sejam consideradas necessárias para verificar a identidade do USUÁRIO ou protegê-lo contra fraudes ou outros crimes financeiros, e tomar as medidas de segurança que julgarmos necessárias . Quando realizadas essas consultas, o USUÁRIO reconhece e concorda que suas informações pessoais podem ser divulgadas a agências de referência de crédito e prevenção de fraudes ou crimes financeiros, e que essas agências podem responder às perguntas na íntegra. Esta é apenas uma verificação de identidade e não deve ter nenhum efeito adverso em sua classificação de crédito. 
//
//Além disso, podemos exigir que USUÁRIO espere algum tempo após a conclusão de uma transação antes de permitir que este use outros Serviços GMA e/ou antes de permitir que USUÁRIO se envolva em transações além de certos limites de volume.
/*
 * 3.	TRANSAÇÕES
 */ 
//3.1	Natureza
//A Wallet, não é uma conta de depósito ou investimento, o que significa que o seu crédito não será protegido pelo FGC (Fundo Garantidor de Crédito). O dinheiro eletrônico mantido em uma carteira de dinheiro eletrônico não renderá juros. 
//
//3.2	Revogação. 
//Quando USUÁRIO nos dá instruções para realizar uma Transação de Ativos Digitais , este  não pode retirar seu consentimento para essa Transação, a menos que a Transação não deva ocorrer até uma data futura acordada, por exemplo, se USUÁRIO tiver configurado Transações Futuras. No caso de uma Transação Futura, USUÁRIO pode retirar seu consentimento até o final do dia útil anterior à data em que a Transação Futura deve ocorrer. Para retirar seu consentimento para uma Transação Futura, siga as instruções no Site. 
//
//3.3	Transações Não Autorizadas e Incorretas.
//Quando uma compra de Ativos digitais e/ou resgate for iniciada a partir de sua Wallet usando suas credenciais, presumiremos que USUÁRIO autorizou tal transação, sendo assim, a transação será autorizada, a menos que USUÁRIO nos notifique de outra forma.
//
//Se USUÁRIO acredita que foi realizada uma transação fraudulenta ou se USUÁRIO tem motivos para acreditar que uma transação realizada incorretamente ou não estiver completo (uma “Transação Incorreta”), USUÁRIO deve entrar em contato conosco o mais rápido possível e, em qualquer caso, no prazo máximo de 24 horas após a ocorrência da Transação Não Autorizada ou da Transação Incorreta. Considerando a natureza de uma transação de Ativos Digitais na blockchain, não podemos entretanto garantir que uma medida para reverter ou corrigir poderá ser tomada. 
//
//É importante que USUÁRIO verifique regularmente o saldo da sua Wallet e seu histórico de transações para garantir que quaisquer Transações Não Autorizadas ou Incorretas sejam identificadas e notificadas a nós na primeira oportunidade possível.
//
//3.4	Consentimento. 
//Ao abrir uma Conta, o USUÁRIO fornece seu consentimento explícito para que os serviços sejam prestados. USUÁRIO pode retirar esse consentimento a qualquer momento fechando sua conta junto à GMA.
//
//Este consentimento não se refere ao processamento de informações pessoais de acordo com as leis e regulamentos de proteção de dados. 
//
//Para maiores informações sobre o tratamento de dados pessoais, consulte a Política de Privacidade. 
//
//
//4.	SERVIÇOS DE ATIVOS DIGITAIS
//Em geral, sua Wallet permite que o USUÁRIO envie, solicite, receba e armazene Ativos Digitais de outros USUÁRIOs ou terceiros fora da Plataforma GMA, dando instruções através do Site (cada uma dessas transações é uma "Transação de Moeda Digital").
//
//4.1	Taxas de conversão. 
//Cada compra ou venda de Ativos Digitais está sujeita a uma taxa ("Taxa de Conversão"). A Taxa de Conversão aplicável será exibida para USUÁRIO no Site antes de cada transação e é indicada em cada recibo que emitimos para USUÁRIO. 
//
//As Taxas de Conversão poderão ser alteradas a qualquer momento.
//
//Outras taxas podem ser aplicadas. Uma lista completa das taxas da GMA pode ser encontrada em nossa página de divulgação de preços e taxas.
//
//4.2	Taxas de Câmbio. 
//Cada compra ou venda de Ativos Digitais também está sujeita à Taxa de Câmbio da transação em questão. A "Taxa de Câmbio" significa o preço de um determinado Ativo Digital suportado em moeda fiduciária, conforme cotado no Site. A Taxa de Câmbio é indicada como um "Preço de Compra" ou um "Preço de Venda", que é o preço pelo qual USUÁRIO pode comprar ou vender Ativos digitais, respectivamente.
//
//USUÁRIO reconhece que a Taxa de Câmbio do Preço de Compra pode não ser a mesma que a Taxa de Câmbio do Preço de Venda a qualquer momento, e que podemos adicionar uma margem ou “spread” à Taxa de Câmbio cotada. USUÁRIO concorda em aceitar a Taxa de Câmbio quando autoriza uma transação. 
//
//USUÁRIO pode saber mais sobre as taxas de câmbio na plataforma da GMA. 
//
//4.3	Autorizações; Reversões; Cancelamentos.
//Ao clicar no botão “Comprar” ou “Vender” no Site, USUÁRIO está autorizando a GMA a iniciar a transação no Preço de Compra ou Preço de Venda cotado e concorda com quaisquer Taxas de Conversão e Taxas de Câmbio associadas e quaisquer outras taxas.
//
//4.4	Moedas Digitais Suportadas. 
//Nossos Serviços de Ativos Digitais estão disponíveis apenas em conexão com as moedas digitais que a GMA suporta (“Moedas Digitais Suportadas”), e isso pode ser alterado conforme necessidade da empresa.
//
//Não assumimos nenhuma responsabilidade ou obrigação em relação a qualquer tentativa de usar sua Carteira de Ativos Digitais para moedas digitais que não são suportadas pela GMA.  
//
//4.5	Operação de Protocolos de Ativos digitais. 
//A GMA não possuí nem controla os protocolos de software subjacentes que regem a operação de Ativos digitais suportadas em nossa plataforma. Geralmente, os protocolos subjacentes são de “código aberto” e qualquer pessoa pode usá-los, copiá-los, modificá-los e distribuí-los.
//
//A GMA não assume qualquer responsabilidade pela operação dos protocolos subjacentes e não podemos garantir a funcionalidade ou segurança das operações de rede. USUÁRIO reconhece e aceita o risco de que os protocolos de software subjacentes relacionados a qualquer Ativos Digitais que USUÁRIO armazene em sua Carteira possam ser alterados.
//
//4.6	Fungibilidade de Certas Moedas Digitais. 
//USUÁRIO reconhece e concorda que a GMA pode manter Ativos Digitais em suas Wallet de várias maneiras diferentes, inclusive em vários protocolos de Blockchain, como redes de camada dois, redes alternativas de camada um ou cadeias laterais. 
//
//4.7	Título de Ativos Digitais. 
//Todos os Ativos Digitais mantidas em sua Wallet são ativos mantidos pela GMA para seu benefício em regime de custódia. Entre outras coisas, isso significa:
//(A)	A titularidade dos ativos digitais permanecerá sempre com USUÁRIO e não será transferida para a GMA. Como proprietário de Ativos Digitais, o USUÁRIO arcará com todos os riscos de perda.  A GMA não terá qualquer responsabilidade por flutuações no valor da moeda fiduciária dos Ativos Digitais mantidos em sua Wallet.
//
//4.8	Ativos Digitais Lastreados. 
//A GMA poderá oferecer Ativos Digitais próprios. Estes ativos terão escassez pré-determinada e serão baseados em SKRs emitidas por instituição de renome, cujo lastro são pedras e metais preciosos físicos e existentes. As mesmas poderão ser oferecidas aos USUÁRIOs em quantidade limitada e pré-determinada, com potencial deságio ou não. A GMA não assume responsabilidade pela valorização ou desvalorização dos mesmos no mercado, ante a característica de um livre mercado digital, nem os riscos subjacentes de tal transação. 
/* 
 * 5.	SUSPENSÃO, RESCISÃO E CANCELAMENTO
 */
//5.1	Suspensão, Rescisão e Cancelamento. 
//A GMA poderá: 
//(a) recusar completar ou colocar em espera, bloquear, cancelar ou reverter uma transação que USUÁRIO autorizou (mesmo após os fundos terem sido debitados de sua Conta GMA), 
//(b) suspender, restringir ou encerrar seu acesso a qualquer ou todos os Serviços GMA e/ou 
//(c) desativar ou cancelar a Conta GMA com efeito imediato por motivo justificáveis incluindo, mas não limitado a:
//i.	Por determinação legal, ou a pedido de autoridades judiciais e/ou administrativas;
//ii.	Por violações deste CONTRATO e seus anexos;
//iii.	Em caso de transações suspeitas, fraudulentas ou não autorizadas; 
//iv.	Suspeitas de práticas de lavagem de dinheiro, financiamento do terrorismo, fraude ou qualquer outro crime financeiro;
//v.	Cancelamento ou suspensão de uma transação poderá ocorrer quando o saldo de sua carteira for insuficiente para concluir a referida transação ou quando o meio de pagamento for recusado/inválido. 
//
//5.1.2 Em qualquer caso de suspensão, rescisão ou cancelamento por parte da GMA será informado ao USUÁRIO assim que possível, constando o motivo que levou à determinada ação.  
//
//5.1.3 O USUÁRIO reconhece que nossa decisão de tomar certas ações, incluindo limitar o acesso, suspender ou encerrar sua Conta GMA, pode ser baseada em critérios confidenciais que são essenciais para os propósitos de nossos protocolos de gerenciamento de risco e segurança. 
//
//5.2	Consequências da Rescisão ou Suspensão
//Na rescisão deste CONTRATO por qualquer motivo, a menos que proibido pela legislação aplicável ou por qualquer decisão judicial e/ou administrativa, o USUÁRIO tem permissão para acessar sua Conta GMA:
//
//(A)	por noventa (90) dias para concluir toda e qualquer transação que esteja pendente. 
/* 
 * 6.	RESPONSABILIDADE
 */ 
//6.1	A responsabilidade da GMA 
//não abrange danos especiais, danos de terceiros ou lucro cessante, sendo que qualquer responsabilidade estará limitada às condições da transação constante da proposta de contratação.
//
//6.1.2 A GMA não poderá ser responsabilizada por caso fortuito ou força maior, tais como, mas não se limitando a determinação de governos locais que impeçam a atividade da GMA extinção do mercado ativos digitais, pandemias ou qualquer outro acontecimento de força maior, ou mesmo por defasagens tecnológicas e modificações no ambiente digital que afetem o mercado de Ativos Digitais.
//
//6.1.3 As Partes reconhecem a possibilidade da falha e/ou mau funcionamento da blockchain. Não é possível garantir que o código-fonte da plataforma usada pela Empresa será livre de falhas. Sendo assim, poderão conter certas falhas, erros, defeitos e bugs, que podem afetar algumas funcionalidades para os USUÁRIOs.
//
//6.1.4 As Partes reconhecem que há riscos associados à criptografia, como quebra de código ou avanços técnicos, como o desenvolvimento de computadores quânticos, podem apresentar riscos para todas as criptomoedas. Isso pode resultar no roubo, perda, desaparecimento, destruição ou desvalorização de ativos digitais.
//
//6.1.5 As Partes, concordam e garantem que estão cientes dos potenciais riscos envolvidos usando os serviços, site, produto e outras tecnologias relevantes mencionadas neste instrumento, bem como que pode haver outros riscos envolvidos, que não estão especificados nesse CONTRATO.
//
//6.2	Indenização. 
//O USUÁRIO concorda em indenizar a GMA, suas afiliadas, prestadores de serviços, e cada um de seus respectivos executivos, diretores, agentes, funcionários e representantes, em relação a quaisquer custos (incluindo honorários advocatícios e quaisquer multas, honorários ou penalidades impostas por qualquer autoridade reguladora) que tenham sido razoavelmente incorridos em conexão com quaisquer reclamações, demandas ou danos decorrentes ou relacionados à sua violação e/ou aplicação deste CONTRATO (incluindo, sem limitação, sua violação da “Política de Comportamento” ou “Política sobre Uso Proibido, Negócios Proibidos e Uso Condicional” (conforme estabelecido no Apêndice I) ou a violação de qualquer lei, regra ou regulamento, ou os direitos de terceiros.
//
//6.3	Nenhuma responsabilidade por violação. 
//A GMA não se responsabiliza por qualquer violação do CONTRATO, incluindo atrasos, falha no desempenho ou interrupção do serviço, quando eles surgirem direta ou indiretamente de circunstâncias anormais e imprevisíveis além de seu controle, cujas consequências seriam inevitáveis, apesar de todos os efeitos para o contrário, nem somos responsáveis quando a violação se deve à aplicação de regras legais obrigatórias
/*
 * 7.	PROTEÇÃO DE DADOS
 */
//As partes confirmam dentro do propósito das tratativas, a autorização para uso de suas informações pessoais dentro do necessário sob a égide da Lei Geral de Proteção de Dados- LGPD (Lei nº 13.709/2018) e demais normas aplicáveis, devendo o Tratamento de Dados Pessoais que venha a ser realizado no âmbito deste CONTRATO, destinar-se ao adimplemento e consecução do objeto deste, em estrita observância às legislações aplicáveis.  
//
//7.1	Para efeitos desta cláusula, define-se:
//
//a)	“Leis Aplicáveis” significam todas as leis aplicáveis relacionadas à proteção de Dados Pessoais, incluindo, mas não limitado à Lei Federal nº. 13.709/2018 (Lei Geral de Proteção de Dados Pessoais, neste CONTRATO definida como “LGPD”), decretos, Instruções Normativas, Jurisprudências e outras legislações e normas aplicadas no Brasil, e suas posteriores atualizações;
//b)	“Requisição” significa qualquer requisição, queixa ou outra comunicação oriunda dos titulares dos dados ou terceiros (incluindo requisições para exercer os direitos dos titulares dentro da LGPD), autoridades competentes, ou oriunda de outras autoridades regulatórias ou judiciais relacionada aos Dados Pessoais que são dentro do escopo das Leis de Proteção de Dados, processados pelas Partes;
//c)	“LGPD” refere-se à Lei Federal n. 13.709/2018 e suas alterações posteriores. 
//d)	“Titular dos Dados”, “Dados Pessoais”, “Controladores”, “Operadores”, “Incidentes de Segurança”, “Autoridade Nacional”, “Encarregado”, “Banco de Dados”, “Tratamento”, entre outros, terão o significado que lhes é atribuído no art. 5º e subsequentes, da Lei nº 13.709 de 14 de agosto de 2018, bem como outros termos eventuais descritos terão o mesmo significado definido na LGPD.
//
//7.1.1 Os dados serão coletados com base no legítimo interesse das Partes, bem como para garantir a fiel execução do CONTRATO pelas Partes, cujo quais, fundamentam-se no artigo 7º da LGPD, razão pela qual as finalidades descritas nesta cláusula não são exaustivas.
//
//7.1.2 As Partes informam que todos os dados pessoais solicitados e coletados são estritamente necessários para os fins almejados neste CONTRATO e autorizam o compartilhamento de seus dados, para os fins descritos, com terceiros legalmente legítimos para defender os interesses das Partes.
//
//7.1.3 GMA DIGITAL LTDA compromete-se a tratar os dados pessoais com a devida legalidade, com base no legitimo interesse, nos termos deste CONTRATO e com base nas Leis Aplicáveis, e que eventuais multas e perdas diretas comprovadamente incorridas, por descumprimento das Leis Aplicáveis serão devidas.
//
//7.1.4 As informações pessoais das Partes e de seus sócios bem como outras informações disponibilizadas por razão deste CONTRATO estão sujeitas ao tratamento e processamento de dados conforme lei, incluindo a transferência destas informações e dados para outros territórios, para fins de armazenamento, processamento e utilização, para envio às autoridades competentes caso requisitado, para as finalidades da prestação ou utilização dos serviços e demais previstos na Política de Privacidade, de acordo com a LGPD do Brasil e GDPR da União Europeia, assegurando desde já todos os consentimentos.
//
//7.1.5 As Partes autorizam a coleta de dados pessoais imprescindíveis à execução deste CONTRATO, estando informados quanto ao potencial tratamento de dados nos termos da Lei n° 13.709/2018, e conexas, especificamente quanto a coleta dos seguintes dados:
//
//i)	Dados relacionados à identificação pessoal dos sócios e das partes, a fim de que se garanta a fiel contratação pelos respectivos titulares do CONTRATO;
//ii)	Dados relacionados ao endereço das Partes tendo em vista a necessidade de identificação para fins envio de documentos/notificações e outras garantias necessárias ao fiel cumprimento do CONTRATO; 
//7.1.6 Os dados coletados poderão conforme solicitação legal pertinente, ser compartilhados com autoridade administrativa e/ou judicial no âmbito de suas competências com base no estrito cumprimento do dever legal.
//
//8.	DA PROPRIEDADE INTELECTUAL
//Na medida em que os direitos autorais ou outros direitos de propriedade intelectual existem na plataforma, site ou Token, tais como serviços de software, know-how, análise ou programas, esses direitos autorais e outros direitos intelectuais e industriais são exclusivos da GMA DIGITAL LTDA e/ou de suas afiliadas ou sucessoras. Em nenhuma circunstância serão interpretados como concedidos. As Partes concordam que a Propriedade intelectual da Empresa só pode ser usada conforme previsto nestes termos. Todos os direitos não expressamente concedidos aqui são reservados.
/* 
 * 9.	SEGURANÇA
 */
//9.1	Segurança de senha. 
//Para acessar os Serviços da GMA, será solicitado a criação de uma senha para acesso ao site. USUÁRIO é responsável por manter seguro o dispositivo eletrônico através do qual acessa os Serviços GMA e manter a segurança e o controle adequados de todos e quaisquer detalhes de segurança que USUÁRIO usa para acessar os Serviços GMA. 
//
//Isso inclui tomar todas as medidas razoáveis para evitar a perda, roubo ou uso indevido de tal dispositivo eletrônico e garantir que tal dispositivo eletrônico seja criptografado e protegido por senha.
//
//A GMA não assume nenhuma responsabilidade por qualquer perda que USUÁRIO possa sofrer devido ao comprometimento das credenciais de login da conta devido a nenhuma falha de segurança que não deriva da GMA. 
/* 
 * 10.	DISPOSIÇÕES GERAIS
 */
//10.1	O USUÁRIO deverá cumprir todas as leis, regulamentos, requisitos de licenciamento e direitos de terceiros aplicáveis (incluindo, sem limitação, leis de privacidade de dados e leis de combate à lavagem de dinheiro e ao financiamento do terrorismo) no uso dos Serviços GMA, da Plataforma GMA e do site.
//
//10.2	As cláusulas deste CONTRATO são imbuídas de irrevogabilidade e irretratabilidade, expressando, segundo seus termos e condições, a mais ampla vontade das PARTES.
//
//10.3	Eventual tolerância de uma das PARTES com relação a qualquer infração ao presente CONTRATO cometida pela outra PARTE, não constituirá novação e nem renúncia aos direitos ou faculdades, tampouco alteração tácita deste CONTRATO, devendo ser considerada como mera liberalidade das PARTES.
//
//10.4	Licença Limitada. Concedemos a USUÁRIO uma licença limitada, não exclusiva e intransferível, sujeita aos termos deste CONTRATO, para acessar e utilizar o Site e o conteúdo, materiais e informações relacionados (coletivamente, o "Conteúdo") exclusivamente para fins aprovados como permitido por nós de tempos em tempos. 
//
//10.5	Qualquer outro uso do Site ou Conteúdo é expressamente proibido e todos os outros direitos, títulos e interesses no Site ou Conteúdo são de propriedade exclusiva da GMA e seus licenciadores. USUÁRIO concorda em não copiar, transmitir, distribuir, vender, licenciar, fazer engenharia reversa, modificar, publicar ou participar da transferência ou venda, criar trabalhos derivados ou de qualquer outra forma explorar qualquer Conteúdo, no todo ou em papel.
//
//10.6	Alterações. 
//Iremos notificá-lo de qualquer alteração ao CONTRATO relacionado aos Serviços prestados, por e-mail ou disponibilizando na plataforma. Em tais circunstâncias, será considerado que USUÁRIO aceitou o Aditivo se não nos notificar de outra forma antes da data em que a alteração entrar. Se USUÁRIO não aceitar a alteração, informe-nos e o CONTRATO será rescindido no final do aviso. 
//
//10.7	Privacidade de terceiros. 
//Se USUÁRIO receber informações sobre outro USUÁRIO por meio dos Serviços GMA, deverá manter as informações confidenciais e usá-las apenas em conexão com os Serviços GMA. USUÁRIO não pode divulgar ou distribuir as informações de um USUÁRIO a terceiros ou usar as informações, exceto conforme razoavelmente necessário para realizar uma transação e outras funções razoavelmente incidentais, como suporte, reconciliação e contabilidade, a menos que receba o consentimento expresso do USUÁRIO para fazê-lo. USUÁRIO não pode enviar comunicações não solicitadas a outro USUÁRIO por meio dos Serviços GMA.
//
//10.8	Informações de contato.
//USUÁRIO é responsável por manter seus detalhes de contato (incluindo seu endereço de e-mail e número de telefone) atualizados no perfil da sua conta GMA para receber quaisquer avisos ou alertas que possamos enviar a USUÁRIO (incluindo avisos ou alertas de ou suspeitas de violação de segurança). 
//
//10.9	Impostos. 
//É de sua exclusiva responsabilidade determinar se, e em que medida, quaisquer impostos se aplicam a quaisquer transações que USUÁRIO realizar por meio dos Serviços GMA, e reter, coletar, relatar e remeter o valor correto do imposto às autoridades fiscais apropriadas. Seu histórico de transações está disponível através de sua conta GMA.
//
//10.10	Interpretação. 
//Os títulos das seções deste CONTRATO são apenas para conveniência e não devem reger o significado ou a interpretação de qualquer disposição deste CONTRATO.
//
//10.11	Transferência e Cessão
//Este CONTRATO é pessoal para o USUÁRIO e este não poderá transferir ou ceder seus direitos, licenças, interesses e/ou obrigações a terceiros. A GMA poderá transferir ou ceder nossas licenças de direitos, interesses e/ou nossas obrigações a qualquer momento, inclusive como parte de uma fusão, aquisição ou outra reorganização corporativa envolvendo a GMA e/ou suas afiliadas. Sujeito ao acima exposto, este CONTRATO vinculará e reverterá em benefício das partes, seus sucessores e cessionários permitidos. 
//
//10.12	Invalidez.
//Se qualquer disposição deste CONTRATO for considerada inválida ou inexequível sob qualquer lei aplicável, isso não afetará a validade de qualquer outra disposição. 
//
//10.13	Mudança de Controle.
//No caso de a GMA ser adquirida ou fundida com uma entidade terceirizada, nos reservamos o direito, em qualquer uma dessas circunstâncias, de transferir ou atribuir as informações que coletamos de USUÁRIO e nosso relacionamento com USUÁRIO (incluindo este CONTRATO) como parte de tal fusão, aquisição, venda ou outra mudança de controle.
//
//10.14	Lei Aplicável e Jurisdição.
//O presente CONTRATO deverá ser regido e interpretado de acordo com as leis da República Federativa do Brasil, ficando eleito o foro de Brasília-DF como competente para dirimir quaisquer conflitos e controvérsias oriundos do presente CONTRATO, com renúncia a qualquer outro por mais privilegiado que seja
/*
 * APÊNDICE I
 * USO PROIBIDO, NEGÓCIOS PROIBIDOS E USO CONDICIONAL
 */
//1. USUÁRIO não pode usar sua conta da GMA para se envolver nas categorias de atividade ("Usos Proibidos") listadas. Os tipos específicos de uso listados são representativos, mas não exaustivos. Se USUÁRIO não tiver certeza se o seu uso dos Serviços GMA ou da Plataforma GMA envolve um Uso Proibido ou tiver dúvidas sobre como esses requisitos se aplicam a USUÁRIO, envie uma solicitação de suporte para [inserir link ou email] 
//
//1.1 Ao abrir uma Conta GMA, USUÁRIO declara e garante que não usará sua Conta, quaisquer Serviços GMA e/ou a Plataforma GMA para fazer as seguintes atividades:
//
//a)	 Atividade ilegal: Atividade que violaria ou ajudaria na violação de qualquer lei, estatuto, portaria, regulamento ou programas de sanções que envolvam proventos de qualquer atividade ilícita; publicar, distribuir ou divulgar qualquer material ou informação ilegal.
//b)	Atividade abusiva: Ações que impõem uma carga não razoável ou desproporcionalmente grande em nossa infraestrutura, ou interferem negativamente, interceptam ou expropriam qualquer sistema, dados ou informações; transmitir ou fazer upload de qualquer material para o Site que contenha vírus, cavalos de tróia, worms ou quaisquer outros programas prejudiciais ou deletérios; tentar obter acesso não autorizado ao Site, outras Contas GMA, sistemas de computador ou redes conectadas ao Site, por meio de mineração de senha ou qualquer outro meio; usar informações da Conta GMA de outra parte para acessar ou usar o Site, exceto no caso de negociantes específicos e/ou aplicativos que são especificamente autorizados por um USUÁRIO a acessar a Conta e informações GMA desse USUÁRIO; ou transferir o acesso ou os direitos de sua conta para terceiros, a menos que por força de lei ou com a permissão expressa da GMA.
//c)	Abuso de direito de outros USUÁRIOs: Interferir no acesso ou uso de qualquer outro indivíduo ou entidade de quaisquer Serviços da GMA; difamar, abusar, extorquir, assediar, perseguir, ameaçar ou de outra forma violar ou infringir os direitos legais (como, mas não limitado a, direitos de privacidade, publicidade e propriedade intelectual) de outros; colher ou de outra forma coletar informações do Site sobre outras pessoas, incluindo, sem limitação, endereços de e-mail, sem o devido consentimento.
//d)	Fraude: Atividade que opera para fraudar a GMA, USUÁRIOs da GMA ou qualquer outra pessoa; fornecer qualquer informação falsa, imprecisa ou enganosa à GMA.
//e)	Jogos de azar: Loterias; leilões de taxa de licitação; previsão esportiva ou criação de probabilidades; ligas de esportes de fantasia com prêmios em dinheiro; jogos na Internet; concursos; sorteios; jogos de azar.
//f)	Violação de Propriedade Intelectual: Envolver-se em transações envolvendo itens que infrinjam ou violem qualquer direito autoral, marca registrada, direito de publicidade ou privacidade ou qualquer outro direito de propriedade sob a lei, incluindo, entre outros, vendas, distribuição ou acesso a música falsificada, filmes, software ou outros materiais licenciados sem a devida autorização do detentor dos direitos; uso de propriedade intelectual, nome ou logotipo da GMA, incluindo o uso de marcas comerciais ou de serviço da GMA, sem o consentimento expresso da GMA ou de forma que prejudique a GMA ou a marca GMA; qualquer ação que implique um endosso falso ou afiliação com a GMA.
/*
 * 2. Negócios Proibidos. 
 */
//Além dos Usos Proibidos descritos acima, as seguintes categorias de negócios, práticas comerciais e itens de venda estão impedidos de serem realizados usando os Serviços GMA ou a Plataforma GMA ("Negócios Proibidos"). A maioria das categorias de Negócios Proibidos são impostas pelas regras da rede de cartões ou pelos requisitos de nossos provedores ou processadores bancários. Os tipos específicos de uso listados abaixo são representativos, mas não exaustivos. Se USUÁRIO não tiver certeza se o seu uso dos Serviços GMA ou da Plataforma GMA envolve um Negócio Proibido, ou tiver dúvidas sobre como esses requisitos se aplicam a USUÁRIO, entre em contato conosco em: [inserir link ou email] 
//
//2.1. Ao abrir uma Conta GMA, o USUÁRIO declara e garante que não usará os Serviços ou a Plataforma em conexão com qualquer um dos seguintes negócios, atividades, práticas ou itens:
//
//a)	Serviços de Investimento e Crédito: corretoras de valores mobiliários; serviços de consultoria hipotecária ou redução de dívidas; aconselhamento ou reparação de crédito; oportunidades imobiliárias; esquemas de investimento;
//b)	Serviços Financeiros Restritos: desconto de cheques, fianças; agências de cobrança;
//c)	Violação de Propriedade Intelectual ou Direitos de Propriedade: vendas, distribuição ou acesso a músicas, filmes, softwares ou outros materiais licenciados falsificados sem a devida autorização do detentor dos direitos;
//d)	Mercadorias Falsificadas ou Não Autorizadas: venda ou revenda não autorizada de produtos ou serviços de marca ou designer; venda de bens ou serviços importados ou exportados ilegalmente ou roubados;
//e)	Produtos e Serviços Regulamentados: dispensários de maconha e negócios relacionados; venda de tabaco, cigarros eletrônicos e líquidos eletrônicos; prescrição online ou serviços farmacêuticos; bens ou serviços com restrição de idade; armas e munições; pólvora e outros explosivos; fogos de artifício e produtos relacionados; materiais tóxicos, inflamáveis e radioativos;
//f)	Drogas: venda de entorpecentes, substâncias controladas e qualquer equipamento destinado à fabricação ou uso de drogas, como bongs, vaporizadores e narguilés;
//g)	Pseudo-farmacêuticos: produtos farmacêuticos e outros produtos que fazem alegações de saúde que não foram aprovados ou verificados pelo órgão regulador local e/ou nacional aplicável;
//h)	Substâncias destinadas a imitar drogas ilegais: venda de uma substância legal que produz o mesmo efeito que uma droga ilegal;
//i)	Conteúdo e Serviços Adultos: pornografia e outros materiais obscenos (incluindo literatura, imagens e outras mídias); sites que oferecem quaisquer serviços relacionados a sexo, como prostituição, acompanhantes, pay-per-view, recursos de bate-papo ao vivo para adultos;
//j)	Marketing Multinível: esquemas de pirâmide, marketing de rede e programas de marketing de referência;
//k)	Práticas desleais, predatórias ou enganosas: oportunidades de investimento ou outros serviços que prometem altas recompensas; venda ou revenda de um serviço sem benefício adicional para o comprador; revenda de ofertas governamentais sem autorização ou valor agregado; sites que determinamos, a nosso exclusivo critério, como injustos, enganosos ou predatórios em relação aos consumidores; e
//l)	Negócios de alto risco: qualquer negócio que acreditemos representar risco financeiro elevado, responsabilidade legal ou violar a rede de cartões ou as políticas bancárias.
/*
 * 3. Uso Condicional. 
 */
//O consentimento expresso por escrito e a aprovação da GMA devem ser obtidos antes de usar os Serviços para as categorias de negócios e/ou uso ("Usos Condicionais"). O consentimento pode ser solicitado entrando em contato conosco em: [inserir link ou email] 
//
//A GMA também pode exigir que USUÁRIO concorde com condições adicionais, faça representações e garantias suplementares, conclua procedimentos aprimorados de integração e opere sujeito a restrições se USUÁRIO usar os Serviços da GMA em conexão com qualquer um dos seguintes negócios, atividades ou práticas:
//
//a)	Serviços monetários: transmissores de dinheiro, transmissores de moeda digital; trocas ou revendedores de moeda ou moeda digital; cartões de presente; cartões pré-pagos; venda de moeda do jogo, a menos que o comerciante seja o operador do mundo virtual; atuar como intermediário ou agregador de pagamentos ou revender qualquer um dos Serviços da GMA;
//b)	Caridades: Aceitação de doações para empreendimento sem fins lucrativos;
//c)	Jogos de Habilidade: Jogos que não são definidos como jogos de azar sob este CONTRATO ou por lei, mas que exigem uma taxa de inscrição e concedem um prêmio; e
//d)	Organizações religiosas/espirituais: Operação de uma organização religiosa ou espiritual com fins lucrativos.
/* 
 * APÊNDICE II: PROCEDIMENTOS E LIMITES DE VERIFICAÇÃO
 */
//A GMA usa sistemas e procedimentos de vários níveis para coletar e verificar informações sobre USUÁRIO, a fim de proteger a empresa e a comunidade de USUÁRIOs fraudulentos e manter os registros apropriados dos clientes da GMA. Seu acesso a um ou mais Serviços ou à Plataforma e limites impostos ao seu uso dos Serviços (incluindo, mas não limitado a limites de conversão diários ou semanais, limites de retirada e negociação, limites de compra instantânea, Carteira de Ativo digital, limites de transferência e limites de transações de um método de pagamento vinculado) e quaisquer alterações nesses limites de tempos em tempos, podem ser baseadas nas informações de identificação e/ou prova de identidade que USUÁRIO fornece à GMA.
//
//A GMA pode exigir que USUÁRIO forneça ou verifique informações adicionais, ou aguarde algum tempo após a conclusão de uma transação, antes de permitir que o USUÁRIO use quaisquer Serviços da GMA e/ou antes de permitir que o USUÁRIO se envolva em transações além de certos limites de volume. 
//
//USUÁRIO pode enviar uma solicitação com para solicitar limites maiores. A GMA exigirá que o USUÁRIO se submeta à Due Diligence aprimorada. Taxas e custos adicionais podem ser aplicados, e a GMA não garante que aumentaremos seus limites.
/* 
 * APÊNDICE III: COMUNICAÇÕES
 */ 
//1. Entrega Eletrônica de Comunicações.
//USUÁRIO concorda e consente em receber eletronicamente todas as comunicações, acordos, documentos, avisos e divulgações (coletivamente, "Comunicações") que fornecemos em conexão com sua Conta e seu uso dos Serviços GMA. As comunicações incluem:
//a)	termos de uso e políticas com as quais USUÁRIO concorda (por exemplo, o CONTRATO e a Política de Privacidade), incluindo atualizações desses CONTRATOs ou políticas;
//b)	detalhes da conta, histórico, recibos de transações, confirmações e qualquer outra conta ou informação de transação;
//c)	divulgações ou declarações legais, regulatórias e fiscais que possamos ser obrigados a disponibilizar a USUÁRIO; e
//d)	respostas a reclamações ou consultas de suporte ao cliente arquivadas em conexão com sua conta.
//A menos que especificado de outra forma neste CONTRATO, forneceremos essas Comunicações ao USUÁRIO publicando-as no Site, enviando-as por e-mail para o USUÁRIO no endereço de e-mail principal listado em sua Conta, comunicando-se com o USUÁRIO via chat instantâneo e/ou por meio de outra comunicação eletrônica como mensagem de texto ou notificação por push móvel, e USUÁRIO concorda que tais Comunicações constituirão um aviso suficiente do assunto em questão.
//2. Como retirar seu consentimento. 
//USUÁRIO pode retirar seu consentimento para receber Comunicações eletronicamente entrando em contato conosco em: [inserir link ou email]. Se USUÁRIO não fornecer ou retirar seu consentimento para receber Comunicações das formas especificadas, a GMA se reserva o direito de encerrar imediatamente sua Conta e cobrar taxas adicionais por cópias impressas das Comunicações.
//3. Atualizando suas informações. 
//É de responsabilidade do USUÁRIO fornecer à GMA um endereço de e-mail verdadeiro, preciso e completo e suas informações de contato, e manter essas informações atualizadas. USUÁRIO entende e concorda que se a GMA lhe enviar uma Comunicação eletrônica, mas USUÁRIO não a receber porque seu endereço de e-mail principal fornecido está incorreto, desatualizado, bloqueado pelo seu provedor de serviços ou USUÁRIO não consegue receber Comunicações eletrônicas, será considerado que a GMA forneceu a Comunicação a USUÁRIO. O USUÁRIO pode atualizar suas informações acessando sua conta GMA e visitando as configurações ou entrando em contato com nossa equipe de suporte em: [inserir link]
//
//    Data      |	Versão	 |  Descrição  |	      Autor	            |     Aprovado por  |
// 17/10/2022	|     0.1	 |   Criação   |   Jurídico e Compliance	|    Matheus Puppe  |
//
/* ------------------------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------- */
//
/* 
 * MEMORANDO DE AQUISICAO DE UTILITY TOKEN
 */ 
//A GMA DIGITAL LTDA (“GMA”) oferece ao mercado por meio de uma oferta privada a ser negociada dentro de sua plataforma GMA EXCHANGE, em ambiente fechado, determinados Utility Tokens que são Ativos Digitais próprios. Estes ativos possuem escassez pré-determinada e serão baseados em SKRs emitidas por instituição de renome, cujo lastro são pedras e metais preciosos físicos e existentes. As mesmas são oferecidas aos USUÁRIO em quantidade limitada e pré-determinada. Cada unidade de Utility Token poderá corresponder à seguinte:
//
//1)	Prioridade ou exclusividade na compra de frações de empresas administradas pela GMA  quando disponíveis; ou
//2)	Prioridade ou exclusividade na compra de ações de empresas administradas pela GMA  quando disponíveis; ou
//3)	Prioridade ou exclusividade na compra de cotas de empresas administradas pela GMA  quando disponíveis, ou
//4)	Prioridade ou exclusividade na compra de ações de empresas aceleradas pela GMA  quando disponíveis; ou
//5)	Prioridade ou exclusividade na aquisição de serviços de empresas administradas pela GMA  quando disponíveis; ou
//6)	Prioridade ou exclusividade na aquisição de serviços de empresas aceleradas pela GMA  quando disponíveis; ou
//7)	Prioridade ou exclusividade na aquisição de serviços de empresas parceiras da GMA  quando disponíveis; ou
//8)	Prioridade ou exclusividade na aquisição de tokens de empresas administradas pela GMA  quando disponíveis; ou
//9)	Prioridade ou exclusividade na aquisição de tokens de empresas aceleradas pela GMA  quando disponíveis; ou
//10)	Prioridade ou exclusividade na aquisição de tokens de empresas parceiras da GMA  quando disponíveis; ou
//11)	Possibilidade da colheita de valorização proveniente de tokens de terceiros na plataforma da GMA  quando disponíveis; ou
//12)	Possibilidade da colheita de valorização proveniente de tokens de empresas aceleradas pela GMA  quando disponíveis; ou
//13)	Possibilidade da colheita de valorização proveniente de tokens de empresas parceiras da GMA  quando disponíveis; ou
//14)	Possibilidade de reserva de capital lastreado em SKRs da GMA  quando disponíveis; ou
//15)	Possibilidade da colheita de valorização na compra de tokens pareados as SKRs da GMA  quando disponíveis, com fonte de recursos provenientes das taxas de adesão aos planos de valorização, taxas institucionais de compra de tokens, taxas institucionais de vendas de tokens, taxa de adesão ao uso do ambiente de negociação lastreado, taxas de saques, taxas de adesão na modalidade reserva de capital; ou
//
//A GMA não assume responsabilidade pela valorização ou desvalorização dos mesmos no mercado, ante a característica de um livre mercado digital, nem os riscos subjacentes de tal transação. A oferta dos mesmos não é vinculante e não trata-se de uma oferta pública.