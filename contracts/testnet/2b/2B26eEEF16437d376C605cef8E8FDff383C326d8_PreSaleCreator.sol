/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

//SPDX-License-Identifier: Unlicensed
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


//Author: Jose Amorim

pragma solidity 0.8.9;



contract PreSale is Ownable {

	IERC20 public buyToken = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); //@dev BUSD for testing change to USDT
	IERC20 public sellToken;
	IERC20 public taxToken = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); //@dev BUSD for testing change to USDT

	bool public presale;
	bool public depositMade;
	bool public isWhitelist;
	bool public liquidityAdded;
	bool public saleCancel;

	mapping(address => uint) public buys;
	mapping(address => uint) public tokensBought;
	mapping(address => bool) public whitelist;

	uint public tax;
	uint public price; //@dev sellTokens per buyToken
	uint public minBuy;
	uint public maxBuy;
	uint public softcap;
	uint public hardcap;
	uint public totalSales;
	uint public liquidityPercentage; //@dev 4 digits
	uint public liquiditySellToken;
	uint public liquidityBuyToken;
	uint public projectOwnerToken;

	address public projectOwner;

	event buyLog(address who, uint amount);

	constructor(address sellToken_, uint minBuy_, uint maxBuy_, uint softcap_, uint hardcap_,
		address projectOwner_, address adminWallet, uint liquidityPercentage_, uint tax_, uint price_) {
		sellToken = IERC20(sellToken_);
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
		taxToken.transferFrom(msg.sender, owner(), tax);
		sellToken.transferFrom(msg.sender, address(this), hardcap*price);
		liquiditySellToken = hardcap*price*liquidityPercentage/10**4;
		depositMade = true;
	}

	function buyTokens(uint amount) external {
		require(presale, "SafeHash Presale: No presale right now.");
		require(amount >= minBuy, "SafeHash Presale: Amount too low.");
		buys[msg.sender] += amount;
		tokensBought[msg.sender] += amount*price;
		require(buys[msg.sender] <= maxBuy, "SafeHash Presale: Amount too high.");
		if (isWhitelist){
            require(whitelist[msg.sender], "SafeHash Presale: You are not in the whitelist.");
        }
		totalSales += amount;
		liquidityBuyToken += amount * liquidityPercentage / 10**4;
		projectOwnerToken += amount - liquidityBuyToken;
		require(totalSales <= hardcap, "SafeHash Presale: Hardcap reached.");
		buyToken.transferFrom(msg.sender, address(this), amount);
		emit buyLog(msg.sender, amount);
	}

	function setWhitelist(address[] memory who, bool set) external onlyOwner{
        for(uint i=0; i<who.length; i++){
            whitelist[who[i]] = set;
        }
    }

    function tooglePreSale() external onlyOwner{
        require(depositMade, "SafeHash Presale: Pending Token Deposit.");
	    presale = !presale;
    }

    function toogleWhitelist() external onlyOwner{
        isWhitelist = !isWhitelist;
    }

	function withdrawToken(uint amount_, address token_) external onlyOwner {
		IERC20 _token = IERC20(token_);
		_token.transfer(msg.sender, amount_);
	}

	function withdrawEth(uint amount_) external onlyOwner {
		payable(msg.sender).transfer(amount_);
	}

	function setMin(uint amount) external onlyOwner {
		minBuy = amount;
	}

	function setMax(uint amount) external onlyOwner {
		maxBuy = amount;
	}

	function setSoftcap(uint amount) external onlyOwner {
		softcap = amount;
	}

	function setHardcap(uint amount) external onlyOwner {
		hardcap = amount;
	}

	function setPrice(uint price_) external onlyOwner {
		price = price_;
	}

	function setLiquidityPercentage(uint liquidityPercentage_) external onlyOwner {
		liquidityPercentage = liquidityPercentage_;
	}

	function setBuyToken(address buyToken_) external onlyOwner{
		buyToken = IERC20(buyToken_);
	}

	function setTaxToken(address taxToken_) external onlyOwner{
		taxToken = IERC20(taxToken_);
	}

	function toogleLiquidityHasBeenAdded() external onlyOwner{
		presale = false;
		liquidityAdded = !liquidityAdded;
	}

	function toogleCancelSale() external onlyOwner{
		saleCancel = !saleCancel;
	}

	function withdrawProject() external {
		require(msg.sender == projectOwner, "SafeHash Presale: Project owner only.");
		require(liquidityAdded, "SafeHash Presale: Liquidity not added yet.");
		buyToken.transferFrom(address(this), msg.sender, projectOwnerToken);
	}

	function buyerWithdraw() external {
		require(liquidityAdded, "SafeHash Presale: Liquidity not added yet.");
		sellToken.transferFrom(address(this), msg.sender, tokensBought[msg.sender]);
	}

	function cancelWithdraw() external {
		require(saleCancel, "SafeHash Presale: Sale not cancelled.");
		buyToken.transferFrom(address(this), msg.sender, buys[msg.sender]);
	}
}
// File: PreSaleCreator.sol

//Author: Jose Amorim
pragma solidity 0.8.9;



contract PreSaleCreator is Ownable{

	event presaleCreated(address presale);

	function createPresale(address sellToken_, uint minBuy_, uint maxBuy_, uint softcap_, uint hardcap_,
		address projectOwner_, address adminWallet, uint liquidityPercentage_, uint tax_, uint price_) external onlyOwner {
		PreSale presale = new PreSale(sellToken_, minBuy_, maxBuy_, softcap_, hardcap_, projectOwner_,
		 adminWallet, liquidityPercentage_, tax_, price_);
		emit presaleCreated(address(presale));
	}

}