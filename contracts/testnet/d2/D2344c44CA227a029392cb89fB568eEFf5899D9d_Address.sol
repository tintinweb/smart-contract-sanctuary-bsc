/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-08
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: Unlicensed

interface IERC20 {

    function totalSupply() external view returns (uint256);

 /**
     * @dev Retorna a quantidade de tokens de propriedade de `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
 * @dev Move tokens `amount` da conta do chamador para `recipient`.
     *
     * Retorna um valor booleano indicando se a operação foi bem-sucedida.
     *
     * Emite um evento {Transfer}.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Retorna o número restante de tokens que o `spender` será
     * permitido gastar em nome do `proprietário` por meio de {transferFrom}. Isso é
     * zero por padrão.
     *
     * Este valor muda quando {approve} ou {transferFrom} são chamados.
     */
    function allowance(address owner, address spender) external view returns (uint256);
/**
     * @dev Define `amount` como a permissão de `spender` sobre os tokens do chamador.
     *
     * Retorna um valor booleano indicando se a operação foi bem-sucedida.
     *
     * IMPORTANTE: Cuidado que alterar uma provisão com este método traz o risco
     * que alguém pode usar tanto o subsídio antigo quanto o novo por infelizes
     * ordenação de transações. Uma possível solução para mitigar essa corrida
     * condição é primeiro reduzir o subsídio do gastador para 0 e definir o
     * valor desejado depois:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emite um evento {Approval}.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Move tokens `amount` de `sender` para `recipient` usando o
     * mecanismo de subsídio. `amount` é então deduzido do valor do chamador
     * abono.
     *
     * Retorna um valor booleano indicando se a operação foi bem-sucedida.
     *
     * Emite um evento {Transfer}.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitido quando tokens `value` são movidos de uma conta (`from`) para
     * outroer (`to`).
     *
  * Observe que `value` pode ser zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitido quando a permissão de um `gastador` para um `proprietário` é definida por
     * uma chamada para {approve}. `value` é o novo subsídio.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @dev Wrappers sobre as operações aritméticas do Solidity com estouro adicional
 * Verificações.
 *
 * Operações aritméticas no Solidity quebram no estouro. Isso pode resultar facilmente
 * em bugs, porque os programadores geralmente assumem que um estouro gera um
 * erro, que é o comportamento padrão em linguagens de programação de alto nível.
 * `SafeMath` restaura essa intuição revertendo a transação quando um
 * operação transborda.
 *
 * Usar esta biblioteca em vez das operações desmarcadas elimina todo um
 * classe de bugs, por isso é recomendável usá-lo sempre.
 */
 
library SafeMath {
    /**
     * @dev Retorna a adição de dois inteiros sem sinal, revertendo em
     * transbordar.
     *
     * Contraparte ao operador `+` do Solidity.
     *
     * Requisitos:
     *
     * - Adição não pode transbordar.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Retorna a subtração de dois inteiros sem sinal, revertendo em
     * estouro (quando o resultado é negativo).
     *
     * Contraparte ao operador `-` do Solidity.
     *
     * Requisitos:
     *
     * - A subtração não pode transbordar.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

   /**
     * @dev Retorna a subtração de dois inteiros sem sinal, revertendo com mensagem personalizada ativada
     * estouro (quando o resultado é negativo).
     *
     * Contraparte ao operador `-` do Solidity.
     *
     * Requisitos:
     *
     * - A subtração não pode transbordar.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Retorna a multiplicação de dois inteiros sem sinal, revertendo em
     * transbordar.
     *
     * Contraparte ao operador `*` do Solidity.
     *
     * Requisitos:
     *
     * - A multiplicação não pode transbordar.
     */
     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Otimização de gás: isso é mais barato do que exigir que 'a' não seja zero, mas o
        // o benefício é perdido se 'b' também for testado.
        // Veja: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Retorna a divisão inteira de dois inteiros sem sinal. Reverte em
     * divisão por zero. O resultado é arredondado para zero.
     *
     * Contraparte ao operador `/` do Solidity. Nota: esta função usa um
     * opcode `revert` (que deixa o gás restante intocado) enquanto Solidity
     * usa um opcode inválido para reverter (consumindo todo o gás restante).
     *
     * Requisitos:
     *
     * - O divisor não pode ser zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Retorna a divisão inteira de dois inteiros sem sinal. Reverte com mensagem personalizada ativada
     * divisão por zero. O resultado é arredondado para zero.
     *
     * Contraparte ao operador `/` do Solidity. Nota: esta função usa um
     * opcode `revert` (que deixa o gás restante intocado) enquanto Solidity
     * usa um opcode inválido para reverter (consumindo todo o gás restante).
     *
     * Requisitos:
     *
     * - O divisor não pode ser zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
       // assert(a == b * c + a % b); // Não há nenhum caso em que isso não seja válido

        return c;
    }

    /**
     * @dev Retorna o resto da divisão de dois inteiros sem sinal. (módulo inteiro sem sinal),
     * Reverte ao dividir por zero.
     *
     * Contraparte ao operador `%` do Solidity. Esta função usa um `revert`
     * opcode (que deixa o gás restante intocado) enquanto Solidity usa um
     * opcode inválido para reverter (consumindo todo o gás restante).
     *
     * Requisitos:
     *
     * - O divisor não pode ser zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

  /**
     * @dev Retorna o resto da divisão de dois inteiros sem sinal. (módulo inteiro sem sinal),
     * Reverte com mensagem personalizada ao dividir por zero.
     *
     * Contraparte ao operador `%` do Solidity. Esta função usa um `revert`
     * opcode (que deixa o gás restante intocado) enquanto Solidity usa um
     * opcode inválido para reverter (consumindo todo o gás restante).
     *
     * Requisitos:
     *
     * - O divisor não pode ser zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silencia o aviso de mutabilidade do estado sem gerar bytecode - veja https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Coleção de funções relacionadas ao tipo de endereço
 */
library Address {
    /**
     * @dev Retorna verdadeiro se `conta` for um contrato.
     *
     * [IMPORTANTE]
     * ====
     * Não é seguro assumir que um endereço para o qual esta função retorna
     * false é uma conta de propriedade externa (EOA) e não um contrato.
     *
     * Entre outros, `isContract` retornará false para os seguintes
     * tipos de endereços:
     *
     * - uma conta de propriedade externa
     * - um contrato em construção
     * - um endereço onde um contrato será criado
     * - um endereço onde um contrato viveu, mas foi destruído
     * ====
     */
    function isContract(address account) internal view returns (bool) {
      // De acordo com EIP-1052, 0x0 é o valor retornado para contas ainda não criadas
        // e 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 é retornado
        // para contas sem código, ou seja, `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Substituição para `transfer` do Solidity: envia `amount` wei para
     * `destinatário`, encaminhando todo gás disponível e revertendo em caso de erros.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] aumenta o custo do gás
     * de certos opcodes, possivelmente fazendo com que os contratos ultrapassem o limite de 2300 gás
     * imposto por `transferência`, tornando-os incapazes de receber fundos via
     * `transferência`. {sendValue} remove essa limitação.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Saiba mais].
     *
     * IMPORTANTE: como o controle é transferido para o `destinatário`, os cuidados devem ser
     * tomadas para não criar vulnerabilidades de reentrada. Considere usar
     * {ReentrancyGuard} ou o
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

       // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Executa uma chamada de função Solidity usando uma `call` de baixo nível. UMA
     * plain`call` é um substituto inseguro para uma chamada de função: use isto
     * função em vez disso.
     *
     * Se `target` for revertido com um motivo de reversão, ele será borbulhado por isso
     * função (como chamadas regulares de função Solidity).
     *
     * Retorna os dados brutos retornados. Para converter para o valor de retorno esperado,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requisitos:
     *
     * - `target` deve ser um contrato.
     * - chamar `target` com `data` não deve ser revertido.
     *
     * _Disponível desde a v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

   /**
     * @dev Igual a {xref-Address-functionCall-address-bytes-}[`functionCall`], mas com
     * `errorMessage` como motivo de reversão de fallback quando `target` é revertido.
     *
     * _Disponível desde a v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Igual a {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * mas também transferindo `value` wei para `target`.
     *
     * Requisitos:
     *
     * - o contrato chamador deve ter um saldo ETH de pelo menos `value`.
     * - a função Solidity chamada deve ser `payable`.
     *
     * _Disponível desde a v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

  /**
     * @dev Igual a {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], mas
     * com `errorMessage` como motivo de reversão de fallback quando `target` é revertido.
     *
     * _Disponível desde a v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Procure por motivo de reversão e borbulhe se estiver presente
            if (returndata.length > 0) {
                // A maneira mais fácil de borbulhar o motivo da reversão é usar a memória via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Módulo de contrato que fornece um mecanismo básico de controle de acesso, onde
 * existe uma conta (um proprietário) que pode ter acesso exclusivo a
 * funções específicas.
 *
 * Por padrão, a conta do proprietário será aquela que implanta o contrato. Esse
 * pode ser alterado posteriormente com {transferOwnership}.
 *
 * Este módulo é usado por herança. Ele disponibilizará o modificador
 * `onlyOwner`, que pode ser aplicado às suas funções para restringir seu uso a
 * o dono.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 /**
     * @dev Inicializa o contrato definindo o implantador como o proprietário inicial.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
/**
     * @dev Retorna o endereço do proprietário atual.
     */
    function owner() public view returns (address) {
        return _owner;
    }

/**
     * @dev Lança se chamado por qualquer conta que não seja o proprietário.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   /**
     * @dev Deixa o contrato sem dono. Não será possível ligar
     * `onlyOwner` funciona mais. Só pode ser chamado pelo proprietário atual.
     *
     * NOTA: A renúncia à propriedade deixará o contrato sem proprietário,
     * removendo assim qualquer funcionalidade que esteja disponível apenas para o proprietário.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

   /**
     * @dev Transfere a propriedade do contrato para uma nova conta (`newOwner`).
     * Só pode ser chamado pelo proprietário atual.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Bloqueia o contrato para o proprietário pelo período de tempo fornecido
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
  //Desbloqueia o contrato para o proprietário quando _lockTime é excedido
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract DogeDash is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    mapping (address => uint256) private lastTimeBuy;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tRewardTotal;

    string private _name = "DogeDash";
    string private _symbol = "DogeDash";
    uint8 private _decimals = 18;
    
    uint256 public _distributionFee = 3;
    uint256 private _previousDistributionFee = _distributionFee;
    
    uint256 public _burnFee = 3;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _marketingFee = 3;
    uint256 private _previousMarketingFee = _marketingFee;

    address public burnWallet = 0x000000000000000000000000000000000000dEaD;
    address public marketingWallet;

    constructor () public {

        //exclui o proprietário e este contrato da taxa
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        marketingWallet = _msgSender();

        excludeFromReward(burnWallet);

        _rOwned[_msgSender()] = _rTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function totalRewards() public view returns (uint256) {
        return _tRewardTotal;
    }

    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setDistributionFeePercent(uint256 distributionFee) external onlyOwner() {
        _distributionFee = distributionFee;
    }
    
    function setBurnFeePercent(uint256 burnFee) external onlyOwner() {
        _burnFee = burnFee;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {
        _marketingFee = marketingFee;
    }

    function updateMarketingWallet(address account) public onlyOwner {
        marketingWallet = account;
    }

    //para receber ETH do uniswapV2Router ao trocar
    receive() external payable {}

    function _distributionToAllHolder(uint256 rDistribution, uint256 tDistribution) private {
        _rTotal = _rTotal.sub(rDistribution);
        _tRewardTotal = _tRewardTotal.add(tDistribution);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tDistribution, uint256 tMarketingAndBurn) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rDistribution) = _getRValues(tAmount, tDistribution, tMarketingAndBurn, _getRate());
        return (rAmount, rTransferAmount, rDistribution, tTransferAmount, tDistribution, tMarketingAndBurn);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tDistribution = calculateDistributionFee(tAmount);
        uint256 tMarketingAndBurn = calculateBurnAndMarketingFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tDistribution).sub(tMarketingAndBurn);
        return (tTransferAmount, tDistribution, tMarketingAndBurn);
    }

    function _getRValues(uint256 tAmount, uint256 tDistribution, uint256 tMarketingAndBurn, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rDistribution = tDistribution.mul(currentRate);
        uint256 rMarketingAndBurn = tMarketingAndBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rDistribution).sub(rMarketingAndBurn);
        return (rAmount, rTransferAmount, rDistribution);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    
    function _takeMarketingAndBurnToken(uint256 tMarketingAndBurn, address sender) private {
        if(_marketingFee + _burnFee > 0){
            uint256 tMarketing = tMarketingAndBurn.mul(_marketingFee).div(_marketingFee + _burnFee);
            uint256 tBurn = tMarketingAndBurn.sub(tMarketing);

            uint256 currentRate =  _getRate();

            uint256 rBurn = tBurn.mul(currentRate);
            _rOwned[burnWallet] = _rOwned[burnWallet].add(rBurn);
            if(_isExcluded[burnWallet])
                _tOwned[burnWallet] = _tOwned[burnWallet].add(tBurn);
            emit Transfer(sender, burnWallet, tBurn);

            uint256 rMarketing = tMarketing.mul(currentRate);
            _rOwned[marketingWallet] = _rOwned[marketingWallet].add(rMarketing);
            if(_isExcluded[marketingWallet])
                _tOwned[marketingWallet] = _tOwned[marketingWallet].add(tMarketing);
            emit Transfer(sender, marketingWallet, tMarketing);
        }
    }
    
    function calculateDistributionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_distributionFee).div(
            10**2
        );
    }

    function calculateBurnAndMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee + _marketingFee).div(
            10**2
        );
    }
    
    function removeAllFee() private {
        if(_distributionFee == 0 && _burnFee == 0 && _marketingFee == 0) return;
        
        _previousDistributionFee = _distributionFee;
        _previousBurnFee = _burnFee;
        _previousMarketingFee = _marketingFee;
        
        _distributionFee = 0;
        _burnFee = 0;
        _marketingFee = 0;
    }
    
    function restoreAllFee() private {
        _distributionFee = _previousDistributionFee;
        _burnFee = _previousBurnFee;
        _marketingFee = _previousMarketingFee;
    }


    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

      //indica se a taxa deve ser deduzida da transferência
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
       //transferir valor, será cobrado imposto, queimado, taxa de liquidez
        _tokenTransfer(from,to,amount,takeFee);
    }

    //este método é responsável por tirar todas as taxas, se takeFee for true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rDistribution, uint256 tTransferAmount, uint256 tDistribution, uint256 tMarketingAndBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeMarketingAndBurnToken(tMarketingAndBurn, sender);
        _distributionToAllHolder(rDistribution, tDistribution);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rDistribution, uint256 tTransferAmount, uint256 tDistribution, uint256 tMarketingAndBurn) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeMarketingAndBurnToken(tMarketingAndBurn, sender);
        _distributionToAllHolder(rDistribution, tDistribution);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rDistribution, uint256 tTransferAmount, uint256 tDistribution, uint256 tMarketingAndBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeMarketingAndBurnToken(tMarketingAndBurn, sender);
        _distributionToAllHolder(rDistribution, tDistribution);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rDistribution, uint256 tTransferAmount, uint256 tDistribution, uint256 tMarketingAndBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeMarketingAndBurnToken(tMarketingAndBurn, sender);
        _distributionToAllHolder(rDistribution, tDistribution);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}