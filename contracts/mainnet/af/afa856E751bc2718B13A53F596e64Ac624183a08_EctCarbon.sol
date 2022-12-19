// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Ownable.sol";

contract EctCarbon is ERC20, Ownable {

    address public admin;

    constructor() ERC20('ECT CARBON', 'ECTC') {
        _mint(msg.sender, 500000 * 10 ** 6);
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
 * ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACA0 EXPORTACAO E COMERCIO LTDA 
 */
//Cadastro Nacional de Pessoa Juridica N° 38.075.070/0001-81 
/* 
 * CONTRATO DE COMPRA E VENDA DE CRIPTO ATIVOS COM CLÁUSULA DE VANTAGENS E OUTRAS AVENÇAS 
 */
//Pelo presente instrumento particular, as PARTES: 
//ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXxPORTACAO E COMERCIO LIDA, sociedade 
//constituida sob as leis da República Federativa do Brasil, registada sob o número CNPJ: 38.07507/00001-8 1.sendo 
//representante oficial do conglomerado de empresas que formou EcOTELHASOLAR ENERGIA FOTovoLTAICA 
//IMPORTACAO EXPORTACAO E COMERCIO LTDA, neste ato representada pelo seu representante legal, doravante 
//denominada "ECOTELHASOLAR ENERGIA FOTOvOLTAICA IMPORTACAo EXPORTACAO E COMERCIO LTDA" 
//ou "VENDEDORA", e de outro lado; 
//
//O ADQUIRENTE, pessoa fisica ou juridica, capaz, interessada em firmar o presente CONTRATO, a qual preencheu 
//devidamente o cadastro na plataforma da BCOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO 
//EXPORTACAO E COMERCIO LTDA e encaminhou os seus respectivos documentos, doravante denominado simplesmente 
//"USUARIO"; sendo ambas as partes designadas, em conjunto, como "PARTES", e isoladamente como "PARTE". 
/* 
 * CONSIDERAÇÕES PRELIMINARES: 
 */
//Considerando que a EcOTELHASOLAR ENERGIA FOTOvOLTAICA IMPORTACAO EXPORTACAO E COMERCIO 
//LTDA, nos termos da legislação em vigor, dispõe de uma plataforma especializada na compra e venda de ativos digitais, 
//
//Considerando que a ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIo 
//LTDA possui interesse em TOKENIZAR parte de seus ativos relacionadas às suas atividades e expertises de negociação com 
//o objetivo de negociá-los no mercado descentralizado de cripto ativos; 
//
//Considerando que o USUÁRIO se declara conhecedor do mercado de cripto ativos; 
//
//Considerando que o USUARIO declara possuir ciência que ativos digitais apresentam alta volatilidade e são considerados 
//ativos de alto risco, podendo gerar prejuizos financeiros decorrentes de sua desvalorização 
//
//Considerando que o USU declara possuir plena capacidade civil, dispondo de todas as faculdades necessárias para 
//fimar este cONTRATO e assumir as obrigações aqui previstas; 
//As PARTES celebram o presente "Contrato de Compra e Venda de Criptoativos com Cláusula de Prioridade" 
//cONTRATO"), que se regerá pelas seguintes cláusulas e condições: 
/*
 * 1.OBJETO DO CONTRATO E CARACTERÍSTICAS DOS SERVIÇOS 
 */
//O presente CONTRATO tem por objeto a compra e venda de lote de TOKENS, disponibilizados pela EcOTELHASOLAR 
//ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LIDA, na plataforma digital encontrada no 
//endereço eletrônico oficial da empresa. A aquisição dos TOKENS pelo USUÁRIO se dará de acordo com as condiçöes de 
//preço e quantidade das regras e condições espelhadas na proposta de contratação, firmada no momento da aquisição. Os 
//TOKENSoferecidos pela ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E 
//COMERCIO LTDA poderão, conforme o caso, referirem-se à fração ideal de determinado ativo real, e, portanto, sua 
//negociação. represcntara a cessão da titularidade da fração ideal do rcferido ativo rcal. Tais informações deverão constar da 
//proposta de contratação ("NA PLATAFORMA OFICIAL. DA ECOTEILIHASOLAR ENERGIA FOTovoLTAICA 
//IMPORTACAO EXPORTACAO E COMERCIO LTDA"). A ECOTELHASOLAR ENERGIA FOTOVOLTAICA 
//IMPORTACAO EXPORTACAO E COMERCIO LTDA poderá accitar como forma de pagamento, a seu exclusivo critério, a 
//permuta por outras criptomocdas, as quais, se accitas, estarão informadas em seu portal oficial. Formalizada a aquisigão dos 
//TOKENS. de acordo com as condiçõcs estabeleridas na proposta de contratação, realizada a abertura de uma carteira digital 
//"wallet" ou indicação de wallet já existente, confirmada a assinatura digital deste contrato e confirmado o pagamento, o 
//UsUÁRIO TEecberá um e-mail informando a transferéncia dos TOKENS para sua carteira "wallet". A ECOTELHASOLAR 
//ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E cOMERCIO LTDA oferece ao USUARIO a 
//possibilidade de acordo com as regras e condiçõcs cstabelecidas na proposta de contratação escolhida pelo USUARIO no 
//momento da aquisição dos TOKENS, cabendo ao USU caso queira, optar pelo direito de revenda dos TOKENS. A 
//ECOTELHASOLAR ENERGIA FOTOVoLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA não 
//disponibilizará, diretamente. produtos e serviços em tecnologia de operações de "TRADDING" em sua plataforma para que, 
//querendo. o USUÁRIO possa adquiri-los com seus TOKENS, sob orma de um clube de vantagens ou assemelhados. O 
//UsUÁRIO poderá ainda utilizar a plataforma da ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO 
//EXPORTACAO E COMERCIO LIDA para emitir ordens para compra ou venda dos TOKENS adquiridos ou de outros 
//cripto ativas diversos, sendo que tais transações serão efetuadas entre os próprios usuários da plataforma, ou diretamente 
//com a ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA. Se 
//realizadas operações entre os usuários, a ECOTELHASOLAR ENERGIA FOTOvOLTAICA IMPORTACAO 
//LTDA atuará apenas como intermediária, permitindo que os usuários negociem entre si EXPORTACAO E COMERCIO 
//diretamente, sem que a ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E 
//cOMERCIo LTDA participe das transações, cobrando apenas eventuais taxas de intermediação. Como condição para a 
//utilização da plataforma, o USUÁRIO se compromete a não utilizar a plataforma da ECoTELHASOLAR ENERGIA 
//FOTOVOLIAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA para fins diretos ou indiretos de ) infringir 
//qualquer lei. regulamento ou contrato, nem praticar atos contrários à moral e aos bons costumes; (i) praticar lavagem de 
//dinheiro: e/ou (ii) financiar atividades e/ou organizações que envolvam terrorismo, crime organizado, tráfico de drogas, 
//pessoas elou órgãos humanos. Para que seja possível emitir uma ordem de venda, o USUÁRIO deverá possuir TOKENS ou 
//outros cripto ativos armazenados em sua WALLET. A ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO 
//EXPORTACAO E COMERCIO LTDA esclarece que pode custodiar dinheiro, fazer arbitragem de criptomoedas, não fazer 
//trade, mineração ou outras operações de rentabilização de criptomoedas. O USUARIO é responsável, perante a 
//ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA e perante 
//quaisquer terceiros, inclusive autoridades locais a respeito do comteúdo das informações, a origem e a legitimidade dos ativos 
//negociados na plataforma da ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E 
//cOMERCIO LTDA. As PARTES se obrigam a cumpir ficimente a legislação que trata da prevenção e combate às 
//atividades ligadas à ocultação de bens e lavagem de dinheiro. 
/* 
 * 2. CADASTRO 
 */
//2.1 Antes de iniciar seu relacionamento com a ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO 
//EXPORTACAO E COMERcIo LTDA, o USUÁRIO deverá fornecer todas as informações cadastrais solicitadas, enviando, 
//inclusive, os documenios comprobatórios (RG, CPF e Comprovante de Residéncia) solicitados pela ECOTELHASOLAR 
//ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA. 
//
//2.2 USUÁRIO declara estar ciente e concorda que é de sua exclusiva responsabilidade manter seu cadastro 
//permanentemente atualizado perante a ECOTELHASOLAR ENERGIA FOTOVvoLTAICA IMPORTACAO EXPORTACAO 
//E COMERCIo LTDA, podendo a ECOTELHASOLAR ENERGIA FOTOVvoLTAICA IMPORTACAO EXPORTACAO E 
//cOMERCIO LTDA recusar qualquer ordem do USUÁRIO que não estiver devidamente cadastrado ou que estiver com seu 
//cadastro desatualizado. 
//
//2.3 0 USUARIO concorda com o procssamcnto de seus dados pessoais fomecidos no contexto deste CONTRATO para os 
//fins aqui descritos e também concorda, até a revogação a qualquer momento do armazenamento de seus dados além do prazo 
//acima. 
//
//2.4 Ao adquirir a partir de uma unidade do Token, o USUÁRIO poderá indicar o produto a terceiros e poderá fazer jus à 
//bonificação por intermediação, conforne pereentuais determinados pela ECOTELHASOLAR ENERGIA FOTOVOLTAICA 
//IMPORTACAO EXPORTACAO E COMERCIO LTDA, indicados em seu site. 
//
//2.5 0 preenchimento do questionário de aptidãoé obrigatório para a contratação dos serviços, podendo a 
//ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LIDA se negar a 
//aceitar o cadastro. 
/* 
 * 3.REMUNERAÇÃO E TAXAS 
 */
//3.1 Pelos serviços de custódia simples aqui contratados, a ECOTELHASOLAR ENERGIA FOTOVOLTAICA 
//IMPORTACAO EXPORTACAO E COMERCIO LTDA naão fará remuneração direta pré ou pós fixada dos ativos 
//negociados em sua plataforma. 
//
//3.2 ECOTELHASOLAR ENERGIA FOTovoLTAICA IMPORTACAO EXPORTACA0 E COMERCIo LTDA poderá 
//implementar taxas de movimentação requeridas pelo cliente ou taxas de saques, as quais ficarão disponíveis em seu portal 
//oficial. 
//
//3.3 OUSU poderá vender seus Tokens a terceiros a qualquer momento. 
/* 
 * 4.0BRIGAçÕES DO USUÁRIO 
 */
//o USUARIO será responsável e encontra-se ciente: pelos atos que praticar e por suas omissões, bem como pela correção e 
//veracidade dos documentos e informações apresentados, respondendo por todos os danos e prejuízos, diretos ou indiretos 
//eventualmente causados à ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E 
//COMERCIO LIDA ou a terceiros, em especial com relação a quaisquer vicios relativos às informações e aos documentos 
//necessårios à prestação dos serviços ora contratados; por cumprir a legislação, as regras e os procedimentos operacionais 
//aplicáveis à realização de operações,; por assumir responsabilidade civil e criminal por todas e quaisquer informações 
//prestadas à ECOTELHASOLAR ENERGIA FOTOvOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA; 
//que quaisquer prejuizos sofridos em decorrência de suas decisões de comprar, vender ou manter criptomoedas são de sua 
//inteira responsabilidade, eximindo a ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E 
//COMERCIO LTDA de quaisquer responsabilidades por eventuais perdas 
/* 
 * 5. DA RESPONSABILIDADE DA ECOTELHASOLAR ENERGIA FOTovoLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA 
 */
//5.1 A responsabilidade da ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO ExPORTACAO E 
//COMERCIO LTDA não abrange danos especiais, danos de terceiros ou lucro cessante, sendo que qualquer responsabilidade 
//estará limitada às condições da transação constante da proposta de contratação. 
//
//5.2 A ECOTELHASOLAR ENERGIA FOTOvoLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA não 
//poderá ser responsabilizada por caso fortuito ou força maior, tais como, mas não se limitando a determinação de govemos 
//locais que impeçam a atividade da ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E 
//COMERCIO LTDA, extinção do mercado de tokens ou cripto ativos, pandemias ou qualquer outro acontecimento de força 
//maior. 
/* 
 * 6. DO PRAZO E RESCISÃO 
 */
//6.1 O presente CONTRATO c os serviços a cle relacionados entram cm vigor na data de confimação do cadastro e desde 
//que este instrumento tenha sido accito cletronicamente, permanccendo em vigência por prazo constante da proposta de 
//contrataçãão. 
//
//6.2 Este contrato pode ser rescindido a pedido de qualquer das partes, mediante solicitação interna a plataforma. 
//
//6.3 A mera rescisão do CONTRATO não impöe à ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO 
//EXPORTACAO E COMERCIO LTDA o dever de devolver os valores que Ihe foram pagos pelo USUÁRIO, Ou o dever de 
//recomprar os TOKENS adquiridos pclo USUARI0. 
/* 
 * 7. DISPOSIçÖES GERAIS 
 */
//7.1 Cada um dos USUÁRIOS que accitarem o presente CONTRATO, declara e garante que possui capacidade civil para 
//fazê-lo ou para agir em nome da PARTE para a qual está assinando, vinculando essa PARTE e todos os que venham a 
//apresentar reivindicações em nome dessa PARTE nos termos do presente instrumento. 
//
//7.2 Os direitos e obrigações decorrentes deste CONTRATO não poderão ser cedidos a terceiros por qualquer das PARTES, 
//sem o prévio e expresso consentimento da outra PARTE. 
//
//7.3 Este CONTRATO é gravado com as cláusulas de irevogabilidade e iretratabilidade, expressando, segundo seus termos 
//e condições, a mais ampla vontade das PARTES. 
//
//7.4 A nulidade de quaisquer das disposições ou cláusulas contidas neste CONTRATO não prejudicará as demais disposições 
//nele contidas, as quais permaneceräo válidas e produzirão seus regulares efeitos jurídicos, obrigando as PARTES. 
//
//7.5. Eventual tolerância de uma das PARTES com relação a qualquer infração ao presente CONTRATO cometida pela outra 
//PARTE, não constituirá novaçãoe nem renúncia aos direitos ou faculdades, tampouco alteração tácita deste CONTRATO, 
//devendo ser considerada como mera liberalidade das PARTES. 
//
//7.6 Todos os avisos, comunicações ou notificações a serem efetuados no ambito deste CONTRATO, terão de ser 
//apresentados formalmente, sendo que o USUARIO está ciente e concorda que a comunicação da ECOTELHASOLAR 
//ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA será exclusivamente por e-mail, 
//através do endereço indicado pelo USUARIO no momento de contratação dos serviços ou outro indicado posteriornmente, 
//sendo considerando-se válidas todas as comunicações enviadas em tal correio eletrônico. Cada unidade de TOKEN pode 
//corresponder, mas não obrigatoriamente, e alternativamente, ao seguinte: 
//Acesso a beneficios, clube de vantagens, bônus ou descontos, sempre referenciados e atualizados na plataforma oficial da 
//ECOTELHASOLAR ENERGIA FoTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA. 
/* 
 * ECOTELHASOLAR ENERGIA FOTOVOLTAICA IMPORTACAO EXPORTACAO E COMERCIO LTDA 
 *
 * CNPJ: 38.075.070/0001-81 
 *
 * BRASIL
 */