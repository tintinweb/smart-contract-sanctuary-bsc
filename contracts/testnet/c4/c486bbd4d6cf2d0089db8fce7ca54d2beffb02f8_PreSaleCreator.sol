/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
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
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/PreSale.sol

//SPDX-License-Identifier: Unlicensed
//Author: Jose Amorim

pragma solidity 0.8.9;



contract PreSale is Ownable {

	IERC20 public buyToken = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd); //endereço da token utilizada para comprar
	//possível incluir no constructor para mais flexibilidade
	IERC20 public sellToken; //endereço da token que será vendida
	IERC20 public taxToken = IERC20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd); //endereço da token para cobrar a taxa
	//da plataforma de lançamento

	bool public presale; //se a venda esta ativa ou não
	bool public depositMade; //se o deposito das tokens ja foi feito pelo dono do projeto
	bool public isWhitelist; //se tem whitelist na pre venda
	bool public liquidityAdded; //se a liquidez ja foi adicionada
	bool public saleCancel; //se a venda foi cancelada

	mapping(address => uint) public buys; //tokens de compra enviadas por carteira
	mapping(address => uint) public tokensBought; //tokens de venda adquiridas por carteira
	mapping(address => bool) public whitelist; //carteiras autorizadas a comprar (whitelist)

	uint public tax; //valor da taxa da plataforma em wei (10^18)
	uint public totalTokenSales; //Total de tokens para venda
	uint public price; //quantidade de tokens de venda para cada token de compra em wei(10^18)
	uint public minBuy; //valor mínimo em wei (10^18) de compra por wallet em tokens de compra
	uint public maxBuy; //valor máximo em wei (10^18) de compra por wallet em tokens de compra
	uint public softcap; //valor mínimo em tokens de compra total para validar o lançamento
	uint public hardcap; //valor máximo em token de compra total do lançamento
	uint public totalSales; //vendas totais em tokens de compra
	uint public liquidityPercentage; //percentual da venda que vai para a liquidez com 4 digitos
	uint public liquiditySellToken; //tokens de venda reservadas para liquidez
	uint public liquidityBuyToken; //tokens de compra reservadas para liquidez
	uint public projectOwnerToken; //tokens de compra que serão enviadas para o dono do projeto após a venda

	address public projectOwner; //carteira do dono do projeto

	event buyLog(address who, uint amount);

	constructor(address sellToken_, uint totalTokenSales_, uint minBuy_, uint maxBuy_, uint softcap_, uint hardcap_,
		address projectOwner_, address adminWallet, uint liquidityPercentage_, uint tax_, uint price_) {

		/*
		* Função de criação do contrato de lançamento que parametriza as características da venda:
		* selltoken_ -> endereço da token a ser vendida
		* minBuy_ -> valor mínimo em wei (10^18) de compra por wallet em tokens de compra
		* maxBuy_ -> valor máximo em wei (10^18) de compra por wallet em tokens de compra
		* softcap_ -> valor mínimo em tokens de compra total para validar o lançamento
		* hardcap_ -> valor máximo em token de compra total do lançamento
		* projectOwner_ -> carteira do dono do projeto
		* adminWallet -> carteira do admin da plataforma de lançamento
		* liquidityPercentage_ -> percentual da venda que vai para a liquidez com 4 digitos
		* tax_ -> valor da taxa do site em wei a ser cobrada do cliente para o lançamento
		* price_ ->  quantidade de tokens de venda para cada token de compra em wei(10^18)
		*/

		sellToken = IERC20(sellToken_);
		totalTokenSales = totalTokenSales_;
		minBuy = minBuy_;
		maxBuy = maxBuy_;
		softcap = softcap_;
		hardcap = hardcap_;
		projectOwner = projectOwner_;
		tax = tax_;
		price = price_;
		liquidityPercentage = liquidityPercentage_;
		transferOwnership(adminWallet);
	}

	function depositTokens() external{

		/*
		* Função que o dono do projeto utiliza para depositar as tokens a serem vendidas e pagar a taxa de lançamento.
		* Esta função faz quem a executa pagar a quantidade definida no constructor em "tax" (em wei 10^18)
		* na token definida como taxToken.
		* Depois ela cobra a quantidade de tokens a serem vendidas usando a fórmula Hardcap/10^18 * preço
		* e ja separa as tokens de venda que vão para a liquidez conforme definido no constructor para liquidityPercentage
		* Para finalizar ela ativa o "depositMade", que permite que a pré venda seja iniciada pelo administrador
		*/
		taxToken.transferFrom(msg.sender, owner(), tax);
		sellToken.transferFrom(msg.sender, address(this), (totalTokenSales*10**18)/10**18);	
	    liquiditySellToken = hardcap/10**18*price*liquidityPercentage/10**4;
	//	sellToken.transferFrom(msg.sender, address(this), hardcap/10**18*price);
	//	liquiditySellToken = hardcap/10**18*price*liquidityPercentage/10**4;
		depositMade = true;
	}

	function buyTokens(uint amount) external {

		/*
		* Função que o usuário utiliza para participar do lançamento comprando uma determinada quantidade de tokens em wei (10^18)
		*/
        
		require(presale, "SafeHash Presale: No presale right now."); // verifica se o lançamento ja foi autorizado pelo admin
		require(amount >= minBuy, "SafeHash Presale: Amount too low."); // verifica se o valor está acima do mínimo
		buys[msg.sender] += amount; // atualiza o total de compras em tokens de compra da carteira
		tokensBought[msg.sender] += (amount*price)/10**18; // atualiza o total de compras em tokens de venda da carteira
		require(buys[msg.sender] <= maxBuy, "SafeHash Presale: Amount too high."); // verifica se o valor esta abaixo do máximo
		if (isWhitelist){
			// se o modo whitelist estiver ligado, verifica se a carteira esta autorizada
            require(whitelist[msg.sender], "SafeHash Presale: You are not in the whitelist.");
        }
		totalSales += amount; // atualiza o total de vendas em tokens de compra
		liquidityBuyToken += amount * liquidityPercentage / 10**4; // reserva o valor da liquidez em tokens de compra
		projectOwnerToken += amount - liquidityBuyToken; // reserva o valor do dono do projeto
		require(totalSales <= hardcap, "SafeHash Presale: Hardcap reached."); // verifica se não atingiu o hardcap
		buyToken.transferFrom(msg.sender, address(this), amount); // faz o cliente pagar a compra
		emit buyLog(msg.sender, amount); // emite um log que pode ser capturado pelo site para informações
	}

	function setWhitelist(address[] memory who, bool set) external onlyOwner{

		/*
		* Função que recebe uma lista de endereços separada por virgulas e um bool (ligar/desligar) para
		* inclusão (verdadeiro) ou remoção (falso) dos endereços da lista na lista de autorizados a comprar (whitelist)
		*/

        for(uint i=0; i<who.length; i++){
            whitelist[who[i]] = set;
        }
    }

    function tooglePreSale() external onlyOwner{
		//função a ser executada pelo admin da plataforma para iniciar a pré venda ou para encerra-la
        require(depositMade, "SafeHash Presale: Pending Token Deposit."); //Exige que o depósito tenha sido feito
	    presale = !presale;
    }

    function toogleWhitelist() external onlyOwner{
		//somente admin
		//liga/desliga a restrição de endereços que podem comprar
        isWhitelist = !isWhitelist;
    }

	function withdrawToken(uint amount_, address token_) external onlyOwner {
		//somente admin
		//recebe valor em wei e endereço de token
		//saca qualquer token do contrato
		IERC20 _token = IERC20(token_);
		_token.transfer(msg.sender, amount_);
	}

	function withdrawEth(uint amount_) external onlyOwner {
		//somente admin
		//recebe valor em wei
		//saca a moeda da blockchain (ex: BNB) do contrato na quantidade definida
		payable(msg.sender).transfer(amount_);
	}

	function setMin(uint amount) external onlyOwner {
		//somente admin
		//estabelece valor mínimo de compra em wei de tokens de compra
		minBuy = amount;
	}

	function setMax(uint amount) external onlyOwner {
		//somente admin
		//estabelece valor máximo de compra em wei de tokens de compra
		maxBuy = amount;
	}

	function setSoftcap(uint amount) external onlyOwner {
		//somente admin
		//estabelece softcap em wei de tokens de compra
		softcap = amount;
	}

	function setHardcap(uint amount) external onlyOwner {
		//somente admin
		//estabelece hardcap em wei de tokens de compra
		hardcap = amount;
	}

	function setPrice(uint price_) external onlyOwner {
		//somente admin
		//estabelece quantidade de tokens de venda para cada token de compra em wei(10^18)
		price = price_;
	}

	function setLiquidityPercentage(uint liquidityPercentage_) external onlyOwner {
		//somente admin
		//estabelece percentual de liquidez (4 digitos)
		liquidityPercentage = liquidityPercentage_;
	}

	function setBuyToken(address buyToken_) external onlyOwner{
		//somente admin
		//estabelece o endereço da token de compra
		buyToken = IERC20(buyToken_);
	}

	function setTaxToken(address taxToken_) external onlyOwner{
		//somente admin
		//estabelece o endereço da token a ser cobrada a taxa
		taxToken = IERC20(taxToken_);
	}

	function toogleLiquidityHasBeenAdded() external onlyOwner{
		//somente admin
		//desativa a pre venda e indica que a liquidez foi adicionada
		presale = false;
		liquidityAdded = !liquidityAdded;
	}

	function toogleCancelSale() external onlyOwner{
		//somente admin
		//cancela a pre venda
		saleCancel = !saleCancel;
	}

	function withdrawProject() external {
		//somente dono do projeto
		//somente após adicionar liquidez
		//dono do projeto saca as tokens de compra reservadas para ele em projectOwnerToken
		require(msg.sender == projectOwner, "SafeHash Presale: Project owner only.");
		require(liquidityAdded, "SafeHash Presale: Liquidity not added yet.");
		buyToken.transfer(msg.sender, projectOwnerToken);
	}

	function buyerWithdraw() external {
		//somente após adicionar liquidez
		//usuário saca as tokens de venda que adquiriu
		require(liquidityAdded, "SafeHash Presale: Liquidity not added yet.");
		sellToken.transfer(address(this), tokensBought[msg.sender]);
	}

	function cancelWithdraw() external {
		//somente caso a venda tenha sido cancelada
		//usuário saca as tokens de compra que depositou
		require(saleCancel, "SafeHash Presale: Sale not cancelled.");
		buyToken.transferFrom(address(this), msg.sender, buys[msg.sender]);
	}
}

// File: PreSaleCreator.sol

pragma solidity 0.8.9;



contract PreSaleCreator is Ownable{

	event presaleCreated(address presale);

	function createPresale(address sellToken_, uint totalTokenSales_, uint minBuy_, uint maxBuy_, uint softcap_, uint hardcap_,
		address projectOwner_, address adminWallet, uint liquidityPercentage_, uint tax_, uint price_) external onlyOwner {
		PreSale presale = new PreSale(sellToken_, totalTokenSales_, minBuy_, maxBuy_, softcap_, hardcap_, projectOwner_,
		 adminWallet, liquidityPercentage_, tax_, price_);
		emit presaleCreated(address(presale));
	}

}