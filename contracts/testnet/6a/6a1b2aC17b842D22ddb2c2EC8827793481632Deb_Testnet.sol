// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IUniswapV2Factory {
   function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
   function factory() external pure returns (address);
   function WETH() external pure returns (address);
   function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
   function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
}

interface IPinkAntiBot {
   function setTokenOwner(address owner) external;
   function onPreTransferCheck(address from, address to, uint256 amount) external;
}

contract Testnet is ERC20, Ownable {
    using SafeMath for uint256;
	
	uint256[] public liquidityFee;
	uint256[] public marketingFee;
	uint256[] public gameDevelopmentFee;
	
	uint256 public gameDevelopmentFeeTotal;
	uint256 public marketingFeeTotal;
	uint256 public liquidityFeeTotal;
	
	uint256 public maxSellPerDay;
	uint256 public maxTokenPerTxn;
	uint256 public swapTokensAtAmount;
	
	IUniswapV2Router public uniswapV2Router;
    address public uniswapV2Pair;
	
	address public marketingWallet;
	address public gameDevelopmentWallet;
	
	IPinkAntiBot public pinkAntiBot;
	
	bool private swapping;
    bool public swapAndLiquifyEnabled;
	bool public antiBotEnabled;

	mapping (address => bool) public isExcludedFromFee;
	mapping (address => bool) public isExcludedFromMaxTokenPerTxn;
	mapping (address => bool) public isExcludedFromDailySaleLimit;
	mapping (address => bool) public isAutomatedMarketMakerPairs;
	mapping (uint256 => mapping(address => uint256)) public dailyTransfers;
	
	event MaxTokenPerWalletUpdated(uint256 amount);
	event SwapTokensAmountUpdated(uint256 amount);
	event MaxTokenPerTxnUpdated(uint256 amount);
    event MaxSellPerDayUpdated(uint256 amount);
	event AutomatedMarketMakerPairUpdated(address pair, bool value);
	event SwapAndLiquifyStatusUpdated(bool status);
	event AntiBotStatusUpdated(bool status);
	event GameDevelopmentWalletUpdated(address newWallet);
    event MarketingWalletUpdated(address newWallet);
	event MarketingFeeUpdated(uint256 buy, uint256 sell, uint256 p2p);
	event LiquidityFee(uint256 buy, uint256 sell, uint256 p2p);
	event GameDevelopmentFeeUpdated(uint256 buy, uint256 sell, uint256 p2p);
	event TransferETH(address recipient, uint256 amount);
    event MigrateTokens(address token, address receiver, uint256 amount);
	
	constructor() ERC20("Testnet", "Testnet") {
	
	   uniswapV2Router = IUniswapV2Router(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);
       uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
	   
	   liquidityFee.push(200);
	   liquidityFee.push(200);
	   liquidityFee.push(200);
	   
	   marketingFee.push(600);
	   marketingFee.push(600);
	   marketingFee.push(600);
	   
	   gameDevelopmentFee.push(600);
	   gameDevelopmentFee.push(600);
	   gameDevelopmentFee.push(600);
	   
	   swapAndLiquifyEnabled = true;
	   antiBotEnabled = true;
	   
	   isExcludedFromFee[owner()] = true;
       isExcludedFromFee[address(this)] = true;
	   
	   isExcludedFromMaxTokenPerTxn[owner()] = true;
	   
	   isExcludedFromDailySaleLimit[address(this)] = true;
       isExcludedFromDailySaleLimit[owner()] = true;  

       isAutomatedMarketMakerPairs[uniswapV2Pair] = true; 	   
	   
	   maxSellPerDay = 1000000000000 * (10 ** 18);
	   maxTokenPerTxn = 1000000000000 * (10 ** 18);
	   swapTokensAtAmount = 100000000 * (10 ** 18);
	   
	   pinkAntiBot = IPinkAntiBot(0xbb06F5C7689eA93d9DeACCf4aF8546C4Fe0Bf1E5);
	   pinkAntiBot.setTokenOwner(msg.sender);
	   
	   _mint(msg.sender, 1000000000000000 * (10 ** 18));
    }
	
	receive() external payable {}
	
	function excludeFromFee(address account, bool status) external onlyOwner {
	   require(isExcludedFromFee[account] != status, "Account is already the value of 'status'");
	   isExcludedFromFee[account] = status;
	}
	
	function excludeFromMaxTokenPerTxn(address account, bool status) public onlyOwner {
		require(isExcludedFromMaxTokenPerTxn[account] != status, "Account is already the value of 'status'");
		isExcludedFromMaxTokenPerTxn[account] = status;
	}
	
	function excludeFromDailySaleLimit(address account, bool status) public onlyOwner {
        require(isExcludedFromDailySaleLimit[account] != status, "Daily sale limit exclusion is already the value of 'status'");
		isExcludedFromDailySaleLimit[account] = status;
    }
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
  	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		
		swapTokensAtAmount = amount;
		emit SwapTokensAmountUpdated(amount);
  	}
	
	function setMaxSellPerDay(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply() && amount >= 1000000 * (10**18), "amount is not correct.");
		
        maxSellPerDay = amount;
		emit MaxSellPerDayUpdated(amount);
    }
	
	function setMaxTokenPerTxn(uint256 amount) external onlyOwner() {
	    require(amount <= totalSupply() && amount >= 1000000 * (10**18), "amount is not correct.");
		
        maxTokenPerTxn = amount;
		emit MaxTokenPerTxnUpdated(amount);
    }
	
	function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(isAutomatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
		
		isAutomatedMarketMakerPairs[address(pair)] = value;
		emit AutomatedMarketMakerPairUpdated(pair, value);
    }
	
	function setSwapAndLiquifyEnabled(bool status) external onlyOwner {
		require(swapAndLiquifyEnabled != status, "`swapAndLiquifyEnabled` is already the value of 'status'");
		
		swapAndLiquifyEnabled = status;
		emit SwapAndLiquifyStatusUpdated(status);
    }
	
	function setAntiBotStatus(bool status) external onlyOwner {
		require(antiBotEnabled != status, "`antiBotEnabled` is already the value of 'status'");
		
		antiBotEnabled = status;
		emit AntiBotStatusUpdated(status);
    }
	
	function setGameDevelopmentWallet(address payable newWallet) external onlyOwner() {
       require(newWallet != address(0), "zero-address not allowed");
	   
	   gameDevelopmentWallet = newWallet;
	   emit GameDevelopmentWalletUpdated(newWallet);
    }
	
	function setMarketingWallet(address payable newWallet) external onlyOwner() {
       require(newWallet != address(0), "zero-address not allowed");
	   
	   marketingWallet = newWallet;
	   emit MarketingWalletUpdated(newWallet);
    }
	
	function setGameDevelopmentFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(marketingFee[0]).add(buy)  <= 10000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(marketingFee[1]).add(sell) <= 10000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(marketingFee[2]).add(p2p)  <= 10000 , "Max fee limit reached for 'P2P'");
		
		gameDevelopmentFee[0] = buy;
		gameDevelopmentFee[1] = sell;
		gameDevelopmentFee[2] = p2p;
		emit GameDevelopmentFeeUpdated(buy, sell, p2p);
	}
	
	function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(gameDevelopmentFee[0]).add(buy)  <= 10000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(gameDevelopmentFee[1]).add(sell) <= 10000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(gameDevelopmentFee[2]).add(p2p)  <= 10000 , "Max fee limit reached for 'P2P'");
		
		marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
		emit MarketingFeeUpdated(buy, sell, p2p);
	}
	
	function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(gameDevelopmentFee[0].add(marketingFee[0]).add(buy)  <= 10000 , "Max fee limit reached for 'BUY'");
		require(gameDevelopmentFee[1].add(marketingFee[1]).add(sell) <= 10000 , "Max fee limit reached for 'SELL'");
		require(gameDevelopmentFee[2].add(marketingFee[2]).add(p2p)  <= 10000 , "Max fee limit reached for 'P2P'");
		
		liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
		emit LiquidityFee(buy, sell, p2p);
	}
	
	function _transfer(address sender, address recipient, uint256 amount) internal override(ERC20){      
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
		
		if(antiBotEnabled) 
		{
           pinkAntiBot.onPreTransferCheck(sender, recipient, amount);
        }
		
		if(!isExcludedFromMaxTokenPerTxn[sender]) 
		{
		    require(amount <= maxTokenPerTxn, "Transfer amount exceeds the `maxTokenPerTxn`");
		}
		
		if (!isExcludedFromDailySaleLimit[sender] && !isAutomatedMarketMakerPairs[sender] && isAutomatedMarketMakerPairs[recipient]) 
		{
		    require(dailyTransfers[getDay()][sender].add(amount) <= maxSellPerDay, "This account has exceeded max daily sell limit");
			dailyTransfers[getDay()][sender] = dailyTransfers[getDay()][sender].add(amount);
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if (!swapping && canSwap && swapAndLiquifyEnabled && isAutomatedMarketMakerPairs[recipient]) {
			swapping = true;
			
			uint256 tokenToDevelopment = gameDevelopmentFeeTotal;
			uint256 tokenToMarketing   = marketingFeeTotal;
			uint256 tokenToLiquidity   = liquidityFeeTotal;
			uint256 liquidityHalf      = tokenToLiquidity.div(2);
			uint256 tokenToSwap = tokenToDevelopment.add(tokenToMarketing).add(liquidityHalf);
			
			if(tokenToSwap >= swapTokensAtAmount) 
			{
			    uint256 initialBalance = address(this).balance;			
				swapTokensForETH(swapTokensAtAmount);
				uint256 newBalance = address(this).balance.sub(initialBalance);
				
				uint256 marketingPart    = newBalance.mul(tokenToMarketing).div(tokenToSwap);
				uint256 liquidityPart    = newBalance.mul(liquidityHalf).div(tokenToSwap);
				uint256 developmentPart  = newBalance.sub(marketingPart).sub(liquidityPart);
				
				if(marketingPart > 0) 
				{
					payable(marketingWallet).transfer(marketingPart);
					marketingFeeTotal = marketingFeeTotal.sub(swapTokensAtAmount.mul(tokenToMarketing).div(tokenToSwap));
				}
				
				if(liquidityPart > 0) 
				{
				    uint256 liqudityToken = swapTokensAtAmount.mul(liquidityHalf).div(tokenToSwap);
				    addLiquidity(liqudityToken, liquidityPart);
					liquidityFeeTotal = liquidityFeeTotal.sub(liqudityToken).sub(liqudityToken);
				}
				
				if(developmentPart > 0) 
				{
					payable(gameDevelopmentWallet).transfer(developmentPart);
					gameDevelopmentFeeTotal = gameDevelopmentFeeTotal.sub(swapTokensAtAmount.mul(tokenToDevelopment).div(tokenToSwap));
				}
			}
			swapping = false;
		}
		
		if(isExcludedFromFee[sender] || isExcludedFromFee[recipient]) 
		{
            super._transfer(sender, recipient, amount);
        }
		else 
		{
		    uint256 allFee = collectFee(amount, isAutomatedMarketMakerPairs[recipient], !isAutomatedMarketMakerPairs[sender] && !isAutomatedMarketMakerPairs[recipient]);
			if(allFee > 0) 
			{
			   super._transfer(sender, address(this), allFee);
			}
			super._transfer(sender, recipient, amount.sub(allFee));
        }
    }
	
	function collectFee(uint256 amount, bool sell, bool p2p) private returns (uint256) {
        uint256 newGameDevelopmentFee = amount.mul(p2p ? gameDevelopmentFee[2] : sell ? gameDevelopmentFee[1] : gameDevelopmentFee[0]).div(10000);
		        gameDevelopmentFeeTotal = gameDevelopmentFeeTotal.add(newGameDevelopmentFee);
		
		uint256 newMarketingFee = amount.mul(p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]).div(10000);
		        marketingFeeTotal = marketingFeeTotal.add(newMarketingFee);
		
		uint256 newLiquidityFee = amount.mul(p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]).div(10000);
		        liquidityFeeTotal = liquidityFeeTotal.add(newLiquidityFee);
				
		uint256 totalFee = newGameDevelopmentFee.add(newMarketingFee).add(newLiquidityFee);
        return totalFee;
    }
	
	function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
		
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
	
	function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(),
            block.timestamp
        );
    }
	
	function migrateTokens(address token, address receiver, uint256 amount) external onlyOwner{
       require(token != address(0), "Zero address");
	   require(receiver != address(0), "Zero address");
	   
	   if(address(token) == address(this))
	   {
	       require(IERC20(address(this)).balanceOf(address(this)).sub(gameDevelopmentFeeTotal).sub(marketingFeeTotal).sub(liquidityFeeTotal) >= amount, "Insufficient balance on contract");
	   }
	   else
	   {
	       require(IERC20(token).balanceOf(address(this)) >= amount, "Insufficient balance on contract");
	   }
	   IERC20(token).transfer(address(receiver), amount);
       emit MigrateTokens(token, receiver, amount);
    }
	
	function migrateETH(address payable recipient) external onlyOwner{
	   require(recipient != address(0), "Zero address");
	   
	   emit TransferETH(recipient, address(this).balance);
       recipient.transfer(address(this).balance);
    }
	
	function getDay() internal view returns(uint256){
        return block.timestamp.div(24 hours);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
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
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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