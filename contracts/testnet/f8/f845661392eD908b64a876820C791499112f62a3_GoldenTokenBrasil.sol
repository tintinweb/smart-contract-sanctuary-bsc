// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GoldenTokenBrasil is ERC20, Ownable {
    string public goldenTokenGoogleDrive =
        "https://drive.google.com/drive/folders/1js1Pd-TsOUtn-7LACD8eVj1y6MZs0XAF";

    string public confirmacaoOnlineDoRegistroEmCartorio =
        "https://horus.funarpen.com.br/Consulta/Selo/0183774CVAA0000001030421Y%7C1358%7C113500e2bc04381fbca40de94ddd7ad3";

    constructor() ERC20("Golden Token Brasil", "GTB") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setGoldenTokenGoogleDrive(string memory v) public onlyOwner() {
        goldenTokenGoogleDrive = v;
    }

    function setConfirmacaoOnlineDoRegistroEmCartorio(string memory v)
        public
        onlyOwner()
    {
        confirmacaoOnlineDoRegistroEmCartorio = v;
    }
}

/**
 * CONTRATO DE COMPRA E VENDA DE CRIPTOATIVOS COM CLÁUSULA DE RECOMPRA E OUTRAS AVENÇAS
 */

// Pelo presente instrumento particular, as PARTES:
// I. GOLDEN MINERAÇÃO LTDA, sociedade constituída sob as leis da República Federativa do Brasil, registada sob o número 39.773.416/0001-88, com sede em Curitiba no Paraná, nesse ato representada pelo seu representante legal, doravante denominada “GOLDEN TOKEN BRASIL” ou “VENDEDORA”, e de outro lado;
// II. O ADQUIRENTE, pessoa física ou jurídica, capaz, interessada em firmar o presente CONTRATO, a qual preencheu devidamente o cadastro na plataforma da GOLDEN TOKEN BRASIL e encaminhou os seus respectivos documentos, doravante denominado simplesmente “USUÁRIO”;
// sendo ambas as partes designadas, em conjunto, como “PARTES”, e isoladamente como “PARTE”,

/**
 * CONSIDERAÇÕES PRELIMINARES:
 */

// Considerando que a GOLDEN TOKEN, nos termos da legislação em vigor, dispõe de uma plataforma especializada na compra e venda de ativos digitais;
// Considerando que a GOLDEN TOKEN é pessoa jurídica que se dedica à mineração e comércios de minérios e pedras preciosas e semipreciosas;
// Considerando que a GOLDEN TOKEN possui interesse em TOKENIZAR parte de seus ativos relacionadas às suas atividades de mineração com o objetivo de negociá-los no mercado descentralizado de criptoativos;
// Considerando que o USUÁRIO se declara conhecedor do mercado de criptoativos;
// Considerando que o USUÁRIO declara possuir ciência que ativos digitais apresentam alta volatilidade e são considerados ativos de alto risco, podendo gerar prejuízos financeiros decorrentes de sua desvalorização;
// Considerando que o USUÁRIO declara possuir plena capacidade civil, dispondo de todas as faculdades necessárias para firmar este CONTRATO e assumir as obrigações aqui previstas;
// As PARTES celebram o presente “Contrato de Compra e Venda de Criptoativos com Cláusula de Recompra” (“CONTRATO”), que se regerá pelas seguintes cláusulas e condições:

/**
 * 1. OBJETO DO CONTRATO E CARACTERÍSTICAS DOS SERVIÇOS
 */

// 1.1 O presente CONTRATO tem por objeto a compra e venda de lote de TOKENS, disponibilizados pela GOLDEN TOKEN BRASIL, na plataforma digital encontrada no endereço eletrônico oficial da empresa.
// 1.2 A aquisição dos TOKENS pelo USUÁRIO se dará de acordo com as condições de preço e quantidade as regras e condições espelhadas na proposta de contratação, firmada no momento da aquisição.
// 1.3 Os TOKENS oferecidos pela GOLDEN TOKEN BRASIL poderão, conforme o caso, referirem-se à fração ideal de determinado ativo real, e, portanto, sua negociação, representará a cessão da titularidade da fração ideal do referido ativo real. Tais informações deverão constar da proposta de contratação (“ANEXO I”).
// 1.4 A GOLDEN TOKEN BRASIL poderá aceitar como forma de pagamento, a seu exclusivo critério, a permuta por outras criptomoedas, as quais, se aceitas, estarão informadas em seu portal oficial.
// 1.5 Formalizada a aquisição dos TOKENS, de acordo com as condições estabelecidas na proposta de contratação, realizada a abertura de uma carteira digital “wallet” ou indicação de wallet já existente, confirmada a assinatura digital deste contrato e confirmado o pagamento, o USUÁRIO receberá um e-mail informando a transferência dos TOKENS para sua carteira “wallet”.
// 1.6 A GOLDEN TOKEN BRASIL oferece ao USUÁRIO a possibilidade de lhes recomprar a totalidade dos TOKENS adquiridos, de acordo com as regras e condições estabelecidas na proposta de contratação escolhida pelo USUÁRIO no momento da aquisição dos TOKENS (“ANEXO I”), cabendo ao USUÁRIO, caso queira, optar pelo direito de revenda dos TOKENS à GOLDEN TOKEN BRASIL.
// 1.7 Caso o USUÁRIO não deseje optar pela revenda de seus TOKENS à GOLDEN TOKEN BRASIL, poderá solicitar que a GOLDEN MINERAÇÃO envie ao USUÁRIO as frações dos ativos reais adquiridos e que lastreiam os referidos TOKENS, sendo de responsabilidade do USUÁRIO os custos relativos a este envio (transporte, embalagem, etc).
// 1.8 A GOLDEN TOKEN BRASIL disponibilizará produtos e serviços em sua plataforma para que, querendo, o USUÁRIO possa adquiri-los com seus TOKENS.
// 1.9 O USUÁRIO poderá ainda utilizar a plataforma da GOLDEN TOKEN BRASIL para emitir ordens para compra ou venda dos TOKENS adquiridos ou de outros criptoativos diversos, sendo que tais transações serão efetuadas entre os próprios usuários da plataforma, ou diretamente com a GOLDEN TOKEN BRASIL.
// 1.10 Se realizadas operações entre os usuários, a GOLDEN TOKEN BRASIL atuará apenas como intermediária, permitindo que os usuários negociem entre si diretamente, sem que a GOLDEN TOKEN BRASIL participe das transações, cobrando apenas eventuais taxas de intermediação.
// 1.11 Como condição para a utilização da plataforma, o USUÁRIO se compromete a não utilizar a plataforma da GOLDEN TOKEN BRASIL para fins diretos ou indiretos de (i) infringir qualquer lei, regulamento ou contrato, nem praticar atos contrários à moral e aos bons costumes; (ii) praticar lavagem de dinheiro; e/ou (iii) financiar atividades e/ou organizações que envolvam terrorismo, crime organizado, tráfico de drogas, pessoas e/ou órgãos humanos.
// 1.12 Para que seja possível emitir uma ordem de venda, o USUÁRIO deverá possuir TOKENS ou outros criptoativos armazenadas em sua Wallet.
// 1.13 A GOLDEN TOKEN BRASIL esclarece que não custodia dinheiro, não faz arbitragem de criptomoedas, não faz trade, mineração ou outras operações de rentabilização de criptomoedas.
// 1.14 A GOLDEN TOKEN BRASIL submeterá as carteiras digitais administradas por revisões e controles bimestrais de Compliance que verificarão os saldos das carteiras, garantindo a real existência dos ativos mostrados a você em nossa plataforma.
// 1.15 O USUÁRIO é responsável, perante a GOLDEN TOKEN BRASIL e perante quaisquer terceiros, inclusive autoridades locais a respeito do conteúdo das informações, a origem e a legitimidade dos ativos negociados na plataforma da GOLDEN TOKEN BRASIL.
// 1.16 As PARTES se obrigam a cumprir fielmente a legislação que trata da prevenção e combate às atividades ligadas à ocultação de bens e lavagem de dinheiro.

/**
 * 2. CADASTRO
 */

// 2.1 Antes de iniciar seu relacionamento com a GOLDEN TOKEN BRASIL, o USUÁRIO deverá fornecer todas as informações cadastrais solicitadas, enviando, inclusive, os documentos comprobatórios (RG, CPF e Comprovante de Residência) solicitados pela GOLDEN TOKEN BRASIL.
// 2.2 O USUÁRIO declara estar ciente e concorda que é de sua exclusiva responsabilidade manter seu cadastro permanentemente atualizado perante a GOLDEN TOKEN BRASIL, podendo a GOLDEN TOKEN BRASIL recusar qualquer ordem do USUÁRIO que não estiver devidamente cadastrado ou que estiver com seu cadastro desatualizado.
// 2.3 O USUÁRIO concorda com o processamento de seus dados pessoais fornecidos no contexto deste CONTRATO para os fins aqui descritos e também concorda, até a revogação a qualquer momento do armazenamento de seus dados além do prazo acima.
// 2.4 Ao adquirir a partir de uma unidade do Token, o USUÁRIO poderá indicar o produto a terceiros e fará jus à remuneração por intermediação, conforme percentuais determinados pela GOLDEN TOKEN BRASIL, indicados em seu site.
// 2.5 O preenchimento do questionário de aptidão é obrigatório para a contratação dos serviços, podendo a GOLDEN TOKEN BRASIL se negar a aceitação do cadastro.

/**
 * 3. REMUNERAÇÃO E TAXAS
 */

// 3.1 Pelos serviços de custódia simples aqui contratados, a GOLDEN TOKEN BRASIL fará jus à remuneração baseada nos ativos negociados em sua plataforma, cujos valores estarão disponíveis no ato da contratação
// 3.2 A GOLDEN TOKEN BRASIL poderá implementar taxas de movimentação requerida pelo cliente ou taxas de saques, as quais ficarão disponíveis em seu portal oficial.
// 3.3 A GOLDEN TOKEN BRASIL realizará a recompra dos Tokens negociados, ao final do contrato de 36 meses, de acordo com os valores indicados no Anexo I deste contrato.
// 3.4 A GOLDEN TOKEN BRASIL poderá realizar o pagamento parcelado e antecipado pelo recompra dos TOKENS, de forma progressiva, ao longo dos 36 (trinta e seis) meses de contrato, de acordo com as solicitações do USUÁRIO e de acordo com os valores constantes do ANEXO I.
// 3.5 O USUÁRIO poderá vender seus Tokens a terceiros a qualquer momento.

/**
 * 4. OBRIGAÇÕES DO USUÁRIO
 */

// 4.1 O USUÁRIO será responsável e encontra-se ciente:
// i) pelos atos que praticar e por suas omissões, bem como pela correição e veracidade dos documentos e informações apresentados, respondendo por todos os danos e prejuízos, diretos ou indiretos, eventualmente causados à GOLDEN TOKEN BRASIL ou a terceiros, em especial com relação a quaisquer vícios relativos às informações e aos documentos necessários à prestação dos serviços ora contratados;
// ii) por cumprir a legislação, as regras e os procedimentos operacionais aplicáveis à realização de operações;
// iii) por assumir responsabilidade civil e criminal por todas e quaisquer informações prestadas à GOLDEN TOKEN BRASIL;
// iv) que quaisquer prejuízos sofridos em decorrência de suas decisões de comprar, vender ou manter criptomoedas são de sua inteira responsabilidade, eximindo a GOLDEN TOKEN BRASIL de quaisquer responsabilidades por eventuais perdas;

/**
 * 5. DA RESPONSABILIDADE DA GOLDEN TOKEN BRASIL
 */

// 5.1 A responsabilidade da GOLDEN TOKEN não abrange danos especiais, danos de terceiros ou lucro cessante, sendo que qualquer responsabilidade estará limitada às condições da transação constante da proposta de contratação.
// 5.2 A GOLDEN TOKEN BRASIL não poderá ser responsabilizada por caso fortuito ou força maior, tais como, mas não se limitando a determinação de governos locais que impeçam a atividade da GOLDEN TOKEN BRASIL, extinção do mercado de tokens, pandemias ou qualquer outro acontecimento de força maior.

/**
 * 6. DO PRAZO E RESCISÃO
 */

// 6.1 O presente CONTRATO e os serviços a ele relacionados entram em vigor na data de confirmação do cadastro e desde que este instrumento tenha sido aceito eletronicamente, permanecendo em vigência por prazo indeterminado.
// 6.2 Este contrato pode ser rescindido a pedido de qualquer das partes, mediante solicitação da plataforma.
// 6.3 A mera rescisão do CONTRATO não impõe à GOLDEN TOKEN BRASIL o dever de devolver os valores que lhe forma pagos pelo USUÁRIO, ou o dever de recomprar os TOKENS adquiridos pelo USUÁRIO.

/**
 * 7. DISPOSIÇÕES GERAIS
 */

// 7.1 Cada uma das pessoas que aceita o presente CONTRATO declara e garante que possui capacidade civil para fazê-lo ou para agir em nome da PARTE para a qual está assinando, vinculando essa PARTE e todos os que venham a apresentar reivindicações em nome dessa PARTE nos termos do presente instrumento.
// 7.2 Os direitos e obrigações decorrentes deste CONTRATO não poderão ser cedidos a terceiros por qualquer das PARTES, sem o prévio e expresso consentimento da outra PARTE.
// 7.3 Este CONTRATO é gravado com as cláusulas de irrevogabilidade e irretratabilidade, expressando, segundo seus termos e condições, a mais ampla vontade das PARTES.
// 7.4 A nulidade de quaisquer das disposições ou cláusulas contidas neste CONTRATO não prejudicará as demais disposições nele contidas, as quais permanecerão válidas e produzirão seus regulares efeitos jurídicos, obrigando as PARTES.
// 7.5 Fica pactuado como garantia deste, frações de minérios da GOLDEN TOKEN BRASIL (Cobre, Mármore, Granito, Ouro, Areia e Diamantes, sendo sempre elencado o tipo e quantidade pela GOLDEN MINERAÇÃO, em caso de adversidades poderá ser acionado as garantias como forma de pagamento.
// 7.6 Eventual tolerância de uma das PARTES com relação a qualquer infração ao presente CONTRATO cometida pela outra PARTE, não constituirá novação e nem renúncia aos direitos ou faculdades, tampouco alteração tácita deste CONTRATO, devendo ser considerada como mera liberalidade das PARTES.
// 7.7 Todos os avisos, comunicações ou notificações a serem efetuados no âmbito deste CONTRATO, terão de ser apresentados formalmente, sendo que o USUÁRIO está ciente e concorda que a comunicação da GOLDEN TOKEN BRASIL será exclusivamente por e-mail, através do endereço indicado pelo USUÁRIO no momento de contratação dos serviços ou outro indicado posteriormente, sendo considerando-se válidas todas as comunicações enviadas em tal correio eletrônico.

// Curitiba, 05 de abril de 2021.

/**
 * PROPOSTA COMERCIAL – ANEXO I
 */

/**
 * Exemplo 01 Token de USD 50
 */

// Ano: 1º ano
// Valor a ser pago se o USUÁRIO optar por 1 Recompra Anual: 25
// Valor a ser pago se o USUÁRIO optar por 2 Recompras Anuais: 20
// Valor a ser pago se o USUÁRIO optar por 3 Recompras Anuais: 15

// Ano: 2º ano
// Valor a ser pago se o USUÁRIO optar por 1 Recompra Anual: 25
// Valor a ser pago se o USUÁRIO optar por 2 Recompras Anuais: 20
// Valor a ser pago se o USUÁRIO optar por 3 Recompras Anuais: 15

// Ano: 3º ano
// Valor a ser pago se o USUÁRIO optar por 1 Recompra Anual: 25
// Valor a ser pago se o USUÁRIO optar por 2 Recompras Anuais: 20
// Valor a ser pago se o USUÁRIO optar por 3 Recompras Anuais: 15

// Ano: Total Final a ser pago pela Golden Token Brasil
// Valor a ser pago se o USUÁRIO optar por 1 Recompra Anual: 125
// Valor a ser pago se o USUÁRIO optar por 2 Recompras Anuais: 110
// Valor a ser pago se o USUÁRIO optar por 3 Recompras Anuais: 95

/**
 * Cada unidade de GOLDEN TOKEN BRASIL corresponde, alternativamente, a seguinte fração de minérios:
 */

// 01 Golden Token Brasil equivale = 10kg Cobre Brutos; ou
// 01 Golden Token equivale = 5 a 10 pontos de Diamante Brutos; ou
// 01 Golden Token Brasil equivale = 2 metros de Granito Branco Bruto, ou
// Outros conforme disponibilidade da extração ou estoque.

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}