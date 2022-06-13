// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.5;

import "./IERC20.sol";
import "./IPancakeRouterV2.sol";
import "./Ownable.sol";

 contract StarGateToken is Context, IERC20Metadata, Ownable {

	string private constant NAME = "STARGATE";
	string private constant SYMBOL = "STAR";
	uint8 private constant DECIMALS = 18;

	uint256 public _celestialLpFee; //% of each transaction that will be added as liquidity
	uint256 public _stargateFee; //% of each transaction that will be used for BNB reward pool
	uint256 public _bigBangFee; //% of each transaction that will be used for _bigBangFee
	uint256 public _blackHoleFee; //% of each transaction that will be burned to the blackhole
	uint256 public _additionalSellFee; //Additional % fee to apply on sell transactions.
	uint256 public _totalFee; //The total fee to be taken

	uint256 private constant _totalTokens = 100000 * 10**DECIMALS;
	mapping (address => mapping (address => uint256)) private _allowances;
	mapping (address => uint256) private _balances; 
	mapping (address => bool) private _addressesExcludedFromFees; 
	mapping (address => bool) private _blacklistedAddresses; 
	mapping (address => uint256) private _sellsAllowance; //consecutive sells are not allowed within a 1min window

	bool private _isFeeEnabled; // True if fees should be applied on transactions, false otherwise

	uint256 private _tokenSwapThreshold = 250 * 10**DECIMALS; //There should be at least of the total supply in the contract before triggering a swap
	uint256 private _tokenSwapThresholdAmount = _totalTokens; //max token Amount that gets swapped 
	uint256 private _transactionLimit = _totalTokens; // The amount of tokens that can be sold at once

	// UNISWAP INTERFACES (For swaps)
	IPancakeRouter02 internal _pancakeswapV2Router;
	address private _pancakeswapV2Pair;
	address public _celestialLiquidityWallet; 
	address public _bigBangWallet;
	address public _StarGateReserve;
	address public _blackHole; 

	// EVENTS
	event Swapped(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity, uint256 bnbIntoLiquidity, bool successSentMarketing);

    //Router MAINNET: 0x10ED43C718714eb63d5aA57B78B54704E256024E TESTNET ROPSTEN: 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
	constructor () {
		_balances[_msgSender()] = totalSupply();
		
		// Exclude contract from fees
		_addressesExcludedFromFees[address(this)] = true;

		_bigBangWallet = msg.sender;
		_StarGateReserve = msg.sender;
		_blackHole = msg.sender;

		// Initialize Pancakeswap V2 router and STAR <-> BNB pair.
		setPancakeswapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
		setFees(1, 2, 1, 1, 8);

		emit Transfer(address(0), _msgSender(), totalSupply());
		setAutoLiquidityWallet(owner());

		presale();
	}

	function presale() public onlyOwner {
		setExcludedFromFees(owner(),true);
		setTransactionLimit(_totalTokens); 
	}

	function activate() public onlyOwner {
		setTransactionLimit(_totalTokens / 100 * 1); 
		setFeeEnabled(true);
	}

	function setMarketingWallet(address marketingWallet) public onlyOwner() {
        _bigBangWallet = marketingWallet;
    }
  
	function balanceOf(address account) public view override returns (uint256) {
		return _balances[account];
	}
	
	function transfer(address recipient, uint256 amount) public override returns (bool) {
		doTransfer(_msgSender(), recipient, amount);
		return true;
	}
	
	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
		doTransfer(sender, recipient, amount);
		doApprove(sender, _msgSender(), _allowances[sender][_msgSender()] - amount); // Will fail when there is not enough allowance
		return true;
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		doApprove(_msgSender(), spender, amount);
		return true;
	}
	
	function doTransfer(address sender, address recipient, uint256 amount) internal virtual {
		require(sender != address(0), "Transfer from the zero address is not allowed");
		require(recipient != address(0), "Transfer to the zero address is not allowed");
		require(amount > 0, "Transfer amount must be greater than zero");
		
		if(!isExcludedFromFees(sender)){
			if (isTransferLimited(sender, recipient)) {
				require(amount <= _transactionLimit, "Transfer amount exceeds the maximum allowed");
			}

			// Perform a swap if needed.  A swap in the context of this contract is the process of swapping the contract's token balance with BNBs in order to provide liquidity and increase the reward pool
			executeSwapIfNeeded(sender, recipient);
		}

		onBeforeTransfer(sender, recipient, amount);

		// Calculate fee rate
		uint256 feeRate = calculateFeeRate(sender, recipient);
		
		uint256 feeAmount = amount * feeRate / 100;
		uint256 transferAmount = amount - feeAmount;

		uint256 burnFee = 0;
		if(feeAmount > 0){
			burnFee = amount * _blackHoleFee / 100;
		}
		// Update balances
		updateBalances(sender, recipient, amount, feeAmount,burnFee);

		emit Transfer(sender, recipient, transferAmount); 
		onTransfer(sender, recipient, amount);

	}
	
	function executeSwapIfNeeded(address sender, address recipient) private {
		if (!isMarketTransfer(sender, recipient)) {
			return;
		}

		uint256 tokensAvailableForSwap = balanceOf(address(this));
		if (tokensAvailableForSwap >= _tokenSwapThreshold) {
			tokensAvailableForSwap = _tokenSwapThresholdAmount;
			// Swap on sells and enable a 30 seconds cooldown
			bool isSelling = isPancakeswapPair(recipient);
			if (isSelling) {
				executeSwap(tokensAvailableForSwap);
			    if (sender != address(this)) {
    				require((block.timestamp >= (_sellsAllowance[sender] + 60)), "Sell was less than 1 minute ago, wait a bit.");
    				_sellsAllowance[sender] = block.timestamp;
			    }
			}
		}
	}
	
	function executeSwap(uint256 amount) private {
		// Allow pancakeswap to spend the tokens of the address
		doApprove(address(this), address(_pancakeswapV2Router), amount);

		uint256 poolFee = _totalFee + _additionalSellFee;

		uint256 tokensReservedForLiquidity = amount * _celestialLpFee / poolFee;
		uint256 tokensReservedForReward = amount * _stargateFee / poolFee;
		uint256 tokensReservedForMarketing = amount - tokensReservedForLiquidity - tokensReservedForReward;

		uint256 tokensToSwapForLiquidity = tokensReservedForLiquidity / 2;
		uint256 tokensToAddAsLiquidity = tokensToSwapForLiquidity;

		uint256 tokensToSwap = tokensReservedForReward + tokensToSwapForLiquidity + tokensReservedForMarketing;
		uint256 bnbSwapped = swapTokensForBNB(tokensToSwap);
		
		uint256 bnbToBeAddedToLiquidity = bnbSwapped * tokensToSwapForLiquidity / tokensToSwap;
		uint256 bnbToBeSentToMarketing = bnbSwapped * tokensReservedForMarketing / tokensToSwap;
		uint256 bnbToBeSentToStargate = bnbSwapped -bnbToBeAddedToLiquidity - bnbToBeSentToMarketing;

		(bool successSentMarketing,) = _bigBangWallet.call{value:bnbToBeSentToMarketing}("");
		_StarGateReserve.call{value:bnbToBeSentToStargate};
		(,uint bnbAddedToLiquidity,) = _pancakeswapV2Router.addLiquidityETH{value: bnbToBeAddedToLiquidity}(address(this), tokensToAddAsLiquidity, 0, 0, _celestialLiquidityWallet, block.timestamp + 360);
		
		emit Swapped(tokensToSwap, bnbSwapped, tokensToAddAsLiquidity, bnbToBeAddedToLiquidity, successSentMarketing);
	}

	function onBeforeTransfer(address sender, address recipient, uint256 amount) internal virtual { }
	function onTransfer(address sender, address recipient, uint256 amount) internal virtual { }

	function updateBalances(address sender, address recipient, uint256 sentAmount, uint256 feeAmount, uint256 burnAmount) private {
		// Calculate amount to be received by recipient
		uint256 receivedAmount = sentAmount - feeAmount;

		// Update balances
		_balances[sender] -= sentAmount;
		_balances[recipient] += receivedAmount;
		
		// Add fees to contract
		_balances[address(this)] += feeAmount;

		// burn blackhole portion from contract
		_balances[address(this)] -= burnAmount;
		_balances[_blackHole] += burnAmount;
		emit Transfer(address(this), _blackHole, burnAmount); 
	}

	function doApprove(address owner, address spender, uint256 amount) private {
		require(owner != address(0), "Cannot approve from the zero address");
		require(spender != address(0), "Cannot approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function calculateFeeRate(address sender, address recipient) private view returns(uint256) {
		bool applyFees = _isFeeEnabled && !_addressesExcludedFromFees[sender] && !_addressesExcludedFromFees[recipient];
		if (applyFees) {
			if (isPancakeswapPair(recipient)) {
				if (_blacklistedAddresses[sender]) {
				    return _totalFee + 36;
				} else {
				    return _totalFee + _additionalSellFee;
				}
			}
			return _totalFee;
		}
		return 0;
	}


	// This function swaps a {tokenAmount} of STAR tokens for BNB and returns the total amount of BNB received
	function swapTokensForBNB(uint256 tokenAmount) internal returns(uint256) {
		uint256 initialBalance = address(this).balance;
		
		// Generate pair for STAR -> WBNB
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = _pancakeswapV2Router.WETH();

		// Swap
		_pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp + 360);
		
		// Return the amount received
		return address(this).balance - initialBalance;
	}

	// Returns true if the transfer between the two given addresses should be limited by the transaction limit and false otherwise
	function isTransferLimited(address sender, address recipient) private view returns(bool) {
		bool isSelling = isPancakeswapPair(recipient);
		return isSelling && isMarketTransfer(sender, recipient);
	}

	function isSwapTransfer(address sender, address recipient) private view returns(bool) {
		bool isContractSelling = sender == address(this) && isPancakeswapPair(recipient);
		return isContractSelling;
	}

	// Function that is used to determine whether a transfer occurred due to a user buying/selling/transfering and not due to the contract swapping tokens
	function isMarketTransfer(address sender, address recipient) internal virtual view returns(bool) {
		return !isSwapTransfer(sender, recipient);
	}

	// Returns how many more $STAR tokens are needed in the contract before triggering a swap
	function amountUntilSwap() public view returns (uint256) {
		uint256 balance = balanceOf(address(this));
		if (balance > _tokenSwapThreshold) {
			// Swap on next relevant transaction
			return 0;
		}

		return _tokenSwapThreshold - balance;
	}

	function setPancakeswapRouter(address routerAddress) public onlyOwner {
		require(routerAddress != address(0), "Cannot use the zero address as router address");
		
		_pancakeswapV2Router = IPancakeRouter02(routerAddress);
		_pancakeswapV2Pair = IPancakeFactory(_pancakeswapV2Router.factory()).createPair(address(this), _pancakeswapV2Router.WETH());
     
	}

	function isPancakeswapPair(address addr) internal view returns(bool) {
		return _pancakeswapV2Pair == addr;
	}

    // update fee manually
	function setFees(uint256 liquidityFee, uint256 rewardFee, uint256 marketingFee, uint256 burnFee ,uint256 additionalSellFee) public onlyOwner {
		
		_celestialLpFee = liquidityFee;
		_stargateFee = rewardFee;
		_bigBangFee = marketingFee;
		_blackHoleFee = burnFee;

		// Enforce invariant
		uint256 newFee = _stargateFee + _bigBangFee + _celestialLpFee + _blackHoleFee;

		require(newFee <= 10, "fee to high");
		require(additionalSellFee <= 10, "fee to high");

		_totalFee = newFee;
		_additionalSellFee = additionalSellFee;
	}

	function updateSwapAmount(uint256 _amount) public onlyOwner{
		_tokenSwapThresholdAmount = _amount;
	}
	
	// This function will be used to reduce the limit later on, according to the price of the token
	function setTransactionLimit(uint256 limit) public onlyOwner {
		require(limit > 100 * 10**DECIMALS);
		_transactionLimit = limit;
	}

	function transactionLimit() public view returns (uint256) {
		return _transactionLimit;
	}

	function setTokenSwapThreshold(uint256 threshold) public onlyOwner {
		require(threshold > 0, "Threshold must be greater than 0");
		_tokenSwapThreshold = threshold;
	}

	function tokenSwapThreshold() public view returns (uint256) {
		return _tokenSwapThreshold;
	}


	function name() public override pure returns (string memory) {
		return NAME;
	}


	function symbol() public override pure returns (string memory) {
		return SYMBOL;
	}


	function totalSupply() public override pure returns (uint256) {
		return _totalTokens;
	}
	

	function decimals() public override pure returns (uint8) {
		return DECIMALS;
	}
	

	function allowance(address user, address spender) public view override returns (uint256) {
		return _allowances[user][spender];
	}

	function pancakeswapPairAddress() public view returns (address) {
		return _pancakeswapV2Pair;
	}

	function setAutoLiquidityWallet(address liquidityWallet) public onlyOwner {
		_celestialLiquidityWallet = liquidityWallet;
	}

	function setStarGateReserve(address _stargate) public onlyOwner {
		_StarGateReserve = _stargate;
	}

	function isFeeEnabled() public view returns (bool) {
		return _isFeeEnabled;
	}

	function setFeeEnabled(bool isEnabled) public onlyOwner {
		_isFeeEnabled = isEnabled;
	}

	function isExcludedFromFees(address addr) public view returns(bool) {
		return _addressesExcludedFromFees[addr];
	}

	function setExcludedFromFees(address addr, bool value) public onlyOwner {
		_addressesExcludedFromFees[addr] = value;
	}
		
	function setBlacklistedWallet(address wallet) public onlyOwner {
	    _blacklistedAddresses[wallet] = true;
	}
	
	function removeBlacklistedWallet(address wallet) public onlyOwner {
	    _blacklistedAddresses[wallet] = false;
	}
	
	function isBlacklistedWallet(address wallet) public view onlyOwner returns(bool)  {
	    return _blacklistedAddresses[wallet];
	}

	// sends stuck tokens
    function sendToBigBang() public payable onlyOwner {
        (bool os, ) = payable(_bigBangWallet).call{value: address(this).balance }("");
        require(os);
    }

	// Ensures that the contract is able to receive BNB
	receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;

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

pragma solidity 0.8.5;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.0;

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