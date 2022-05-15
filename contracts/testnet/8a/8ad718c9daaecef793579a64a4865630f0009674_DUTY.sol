/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
	
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IBEP20 {
   
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BEP20 is Context, IBEP20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
	
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
	
    function _initialSupply(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
	
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
	
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

interface IPancakeSwapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakeSwapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
	function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
	function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
	
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
	
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
	
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
	
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
	
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
	
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
	
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
	
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));
    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    require(!(a == - 2**255 && b == -1) && (b > 0));
    return a / b;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {
    require(a >= 0);
    return uint256(a);
  }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

contract DUTY is BEP20, Ownable {
    using SafeMath for uint256;
	
    IPancakeSwapV2Router02 public pancakeSwapV2Router;
    address public pancakeSwapV2Pair;
	
    uint256[] public bigETHPayDayPotFee;
	uint256[] public marketingFee;
    uint256[] public liquidityFee;
	uint256[] public stakingRewardFee;
	uint256[] public P2ERewardPotFee;
	uint256[] public buyBackBurnFee;
	
	uint256 private bigETHPayDayPotFeeTotal;
	uint256 private marketingFeeTotal;
	uint256 private liquidityFeeTotal;
	uint256 private stakingRewardFeeTotal;
	uint256 private P2ERewardPotFeeTotal;
	uint256 private buyBackBurnFeeTotal;
	
    uint256 public swapTokensAtAmount = 50000000000 * (10**18);
	uint256 public maxTxAmount = 500000000000000 * (10**18);
	
	address payable public bigETHPayDayPotFeeAddress = payable(0xC51a5683D66f4B331272F56e9DcA5Df22EbBa64a);
	address payable public marketingFeeAddress = payable(0x07fbF15579B407F3840b02483E71E3B1e2919Fe7);
	address payable public P2ERewardPotFeeAddress = payable(0x6F6316c2A4828CC4f00D6c0b3aDA1649b486a638);
	address payable public buyBackBurnFeeAddress = payable(0xD1aC9958EB7d6fFe1cca5aEa08A94939A8343a15);
	address payable public stakingRewardFeeAddress = payable(0xCc92365DEa171C0207FA223a2885C8152468e16E);
	
	address public ETH = address(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca);
    address public BUSD = address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);

    uint256 private tokenToBigETHPayDayPot;
    uint256 private tokenToMarketing;
    uint256 private tokenToLiquidity;
    uint256 private tokenToStakingReward;
    uint256 private tokenToP2ERewardPot;
    uint256 private tokenToBuyBackBurn;
    uint256 private liquidityHalf;
    uint256 private tokenToSwap;
    uint256 private newBalance;
	
	bool public swapEnable = true;
	bool public whiteListedOnly = true;
	
	bool inSwapping;
	modifier lockTheSwap {
		 inSwapping = true;
		 _;
		 inSwapping = false;
    }
	
    mapping (address => bool) public isExcludedFromFees;
	mapping (address => bool) public isExcludedFromMaxTxAmount;
    mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => bool) public isBlackListed;
	mapping (address => bool) public isWhitelisted;
	
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event AddedBlackList(address _address);
    event RemovedBlackList(address _address);
	event AddToWhiteList(address _address);
	event RemovedFromWhiteList(address _address);
	
    constructor() BEP20("DOGE DUTY", "DUTY") {
    	IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH());

        pancakeSwapV2Router = _pancakeSwapV2Router;
        pancakeSwapV2Pair   = _pancakeSwapV2Pair;
		
        _setAutomatedMarketMakerPair(_pancakeSwapV2Pair, true);
		
        excludeFromFees(address(this), true);
		excludeFromFees(owner(), true);
		
		isWhitelisted[owner()] = true;
		isWhitelisted[address(this)] = true;
		isWhitelisted[pancakeSwapV2Pair] = true;
		
		isExcludedFromMaxTxAmount[owner()] = true;
		
		bigETHPayDayPotFee.push(300);
		bigETHPayDayPotFee.push(300);
		bigETHPayDayPotFee.push(0);
		
		liquidityFee.push(200);
		liquidityFee.push(200);
		liquidityFee.push(0);
		
		marketingFee.push(300);
		marketingFee.push(300);
		marketingFee.push(0);
		
		stakingRewardFee.push(200);
		stakingRewardFee.push(200);
		stakingRewardFee.push(0);
		
		P2ERewardPotFee.push(200);
		P2ERewardPotFee.push(200);
		P2ERewardPotFee.push(0);
		
		buyBackBurnFee.push(0);
		buyBackBurnFee.push(300);
		buyBackBurnFee.push(0);
		
        _initialSupply(owner(), 500000000000000 * (10**18));
    }
	
    receive() external payable {
  	}
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
  	     require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		 swapTokensAtAmount = amount;
  	}
	
	function setMaxTxAmount(uint256 amount) external onlyOwner() {
	     require(amount <= totalSupply() && amount >= 5000000000 * (10**18), "amount is not correct.");
         maxTxAmount = amount;
    }
	
	function setSwapEnable(bool _enabled) public onlyOwner {
        swapEnable = _enabled;
    }
	
	function setBigETHPayDayPotFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(marketingFee[0]).add(stakingRewardFee[0]).add(P2ERewardPotFee[0]).add(buyBackBurnFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(marketingFee[1]).add(stakingRewardFee[1]).add(P2ERewardPotFee[1]).add(buyBackBurnFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(marketingFee[2]).add(stakingRewardFee[2]).add(P2ERewardPotFee[2]).add(buyBackBurnFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		bigETHPayDayPotFee[0] = buy;
		bigETHPayDayPotFee[1] = sell;
		bigETHPayDayPotFee[2] = p2p;
	}
	
	function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(bigETHPayDayPotFee[0]).add(stakingRewardFee[0]).add(P2ERewardPotFee[0]).add(buyBackBurnFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(bigETHPayDayPotFee[1]).add(stakingRewardFee[1]).add(P2ERewardPotFee[1]).add(buyBackBurnFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(bigETHPayDayPotFee[2]).add(stakingRewardFee[2]).add(P2ERewardPotFee[2]).add(buyBackBurnFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
	}
	
	function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(bigETHPayDayPotFee[0]).add(stakingRewardFee[0]).add(P2ERewardPotFee[0]).add(buyBackBurnFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(bigETHPayDayPotFee[1]).add(stakingRewardFee[1]).add(P2ERewardPotFee[1]).add(buyBackBurnFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(bigETHPayDayPotFee[2]).add(stakingRewardFee[2]).add(P2ERewardPotFee[2]).add(buyBackBurnFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
	}
	
	function setStakingRewardFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(bigETHPayDayPotFee[0]).add(liquidityFee[0]).add(P2ERewardPotFee[0]).add(buyBackBurnFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(bigETHPayDayPotFee[1]).add(liquidityFee[1]).add(P2ERewardPotFee[1]).add(buyBackBurnFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(bigETHPayDayPotFee[2]).add(liquidityFee[2]).add(P2ERewardPotFee[2]).add(buyBackBurnFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		stakingRewardFee[0] = buy;
		stakingRewardFee[1] = sell;
		stakingRewardFee[2] = p2p;
	}
	
	function setP2ERewardPotFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(bigETHPayDayPotFee[0]).add(liquidityFee[0]).add(stakingRewardFee[0]).add(buyBackBurnFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(bigETHPayDayPotFee[1]).add(liquidityFee[1]).add(stakingRewardFee[1]).add(buyBackBurnFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(bigETHPayDayPotFee[2]).add(liquidityFee[2]).add(stakingRewardFee[2]).add(buyBackBurnFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		P2ERewardPotFee[0] = buy;
		P2ERewardPotFee[1] = sell;
		P2ERewardPotFee[2] = p2p;
	}
	
	function setBuyBackBurnFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(bigETHPayDayPotFee[0]).add(liquidityFee[0]).add(stakingRewardFee[0]).add(P2ERewardPotFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(bigETHPayDayPotFee[1]).add(liquidityFee[1]).add(stakingRewardFee[1]).add(P2ERewardPotFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(bigETHPayDayPotFee[2]).add(liquidityFee[2]).add(stakingRewardFee[2]).add(P2ERewardPotFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		buyBackBurnFee[0] = buy;
		buyBackBurnFee[1] = sell;
		buyBackBurnFee[2] = p2p;
	}
	
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
	
	function excludeFromMaxTxAmount(address account, bool excluded) public onlyOwner {
		require(isExcludedFromMaxTxAmount[account] != excluded, "APAY: Account is already the value of 'excluded'");
		isExcludedFromMaxTxAmount[account] = excluded;
	}
	
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != pancakeSwapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
	
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
	
	function setBigETHPayDayPotFeeAddress(address payable newAddress) external onlyOwner() {
       require(newAddress != address(0), "zero-address not allowed");
	   bigETHPayDayPotFeeAddress = newAddress;
    }
	
	function setMarketingFeeAddress(address payable newAddress) external onlyOwner() {
       require(newAddress != address(0), "zero-address not allowed");
	   marketingFeeAddress = newAddress;
    }
	
	function setStakingRewardFeeAddress(address payable newAddress) external onlyOwner() {
       require(newAddress != address(0), "zero-address not allowed");
	   stakingRewardFeeAddress = newAddress;
    }
	
	function setP2ERewardPotFeeAddress(address payable newAddress) external onlyOwner() {
       require(newAddress != address(0), "zero-address not allowed");
	   P2ERewardPotFeeAddress = newAddress;
    }
	
	function setBuyBackBurnFeeAddress(address payable newAddress) external onlyOwner() {
       require(newAddress != address(0), "zero-address not allowed");
	   buyBackBurnFeeAddress = newAddress;
    }
	
	function addToBlackList (address _wallet) external onlyOwner {
        isBlackListed[_wallet] = true;
        emit AddedBlackList(_wallet);
    }
	
    function removeFromBlackList (address _wallet) external onlyOwner {
        isBlackListed[_wallet] = false;
        emit RemovedBlackList(_wallet);
    }
	
	function addToWhiteList (address _wallet) external onlyOwner {
        isWhitelisted[_wallet] = true;
        emit AddToWhiteList(_wallet);
    }
	
	function removeFromWhiteList(address _wallet) external onlyOwner {
        isWhitelisted[_wallet] = false;
        emit RemovedFromWhiteList(_wallet);
    }
	
	function whiteListSwitch(bool true_or_false) external onlyOwner {
	    whiteListedOnly = true_or_false;
	}
	
	function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
		require(!isBlackListed[from], "BEP20: transfer to is blacklisted");
		require(!isBlackListed[to], "BEP20: transfer from is blacklisted");
		
        if(!isExcludedFromMaxTxAmount[from]) 
		{
		    require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
		}
		
		if(whiteListedOnly)
		{
		   require(isWhitelisted[to], "You need to be whitelisted");
		}
		
		uint256 contractTokenBalance = balanceOf(address(this));
		bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if (!inSwapping && canSwap && swapEnable && automatedMarketMakerPairs[to]) 
		{
			 tokenToBigETHPayDayPot = bigETHPayDayPotFeeTotal;
			 tokenToMarketing       = marketingFeeTotal;
			 tokenToLiquidity       = liquidityFeeTotal;
			 tokenToStakingReward   = stakingRewardFeeTotal;
			 tokenToP2ERewardPot    = P2ERewardPotFeeTotal;
			 tokenToBuyBackBurn     = buyBackBurnFeeTotal;
			 liquidityHalf          = tokenToLiquidity.div(2);
			 
			 tokenToSwap            = tokenToBigETHPayDayPot.add(tokenToMarketing).add(liquidityHalf).add(tokenToStakingReward).add(tokenToP2ERewardPot).add(tokenToBuyBackBurn);
			 
			 if(tokenToSwap >= swapTokensAtAmount)
			 {
			    uint256 initialBalance = address(this).balance;			
				        swapTokensForBNB(swapTokensAtAmount);
				        newBalance = address(this).balance.sub(initialBalance);
						
				uint256 bigETHPayDayPotPart  = newBalance.mul(tokenToBigETHPayDayPot).div(tokenToSwap);
				uint256 marketingPart        = newBalance.mul(tokenToMarketing).div(tokenToSwap);
				uint256 liquidityPart        = newBalance.mul(liquidityHalf).div(tokenToSwap);
				uint256 stakingRewardPart    = newBalance.mul(tokenToStakingReward).div(tokenToSwap);
				uint256 P2ERewardPotPart     = newBalance.mul(tokenToP2ERewardPot).div(tokenToSwap);
				uint256 buyBackBurnPart      = newBalance.sub(bigETHPayDayPotPart).sub(marketingPart).sub(liquidityPart).sub(stakingRewardPart).sub(P2ERewardPotPart);
			
				if(buyBackBurnPart > 0) 
				{
					payable(buyBackBurnFeeAddress).transfer(buyBackBurnPart);
					buyBackBurnFeeTotal = buyBackBurnFeeTotal.sub(swapTokensAtAmount.mul(tokenToBuyBackBurn).div(tokenToSwap));
				}
				
				if(marketingPart > 0) 
				{
					swapBNBForBUSD(marketingPart, marketingFeeAddress);
					marketingFeeTotal = marketingFeeTotal.sub(swapTokensAtAmount.mul(tokenToMarketing).div(tokenToSwap));
				}
				
				if(stakingRewardPart > 0) 
				{
					swapBNBForETH(stakingRewardPart, stakingRewardFeeAddress);
					stakingRewardFeeTotal = stakingRewardFeeTotal.sub(swapTokensAtAmount.mul(tokenToStakingReward).div(tokenToSwap));
				}
				
				if(P2ERewardPotPart > 0) 
				{
					swapBNBForETH(P2ERewardPotPart, P2ERewardPotFeeAddress);
					P2ERewardPotFeeTotal = P2ERewardPotFeeTotal.sub(swapTokensAtAmount.mul(tokenToP2ERewardPot).div(tokenToSwap));
				}
				
				if(bigETHPayDayPotPart > 0) 
				{
					swapBNBForETH(bigETHPayDayPotPart, bigETHPayDayPotFeeAddress);
					bigETHPayDayPotFeeTotal = bigETHPayDayPotFeeTotal.sub(swapTokensAtAmount.mul(tokenToBigETHPayDayPot).div(tokenToSwap));
				}
				
				if(liquidityPart > 0) 
				{
					addLiquidity(liquidityHalf, liquidityPart);
					liquidityFeeTotal = liquidityFeeTotal.sub(swapTokensAtAmount.mul(tokenToLiquidity).div(tokenToSwap));
				}
				
			 }
		}
		
        bool takeFee = !inSwapping;
		if(isExcludedFromFees[from] || isExcludedFromFees[to]) 
		{
            takeFee = false;
        }
		
		if(takeFee) 
		{
		    uint256 allfee;
		    allfee = collectFee(amount, automatedMarketMakerPairs[to], !automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]);
			if(allfee > 0)
			{
			   super._transfer(from, address(this), allfee);
			   amount = amount.sub(allfee);
			}
		}
        super._transfer(from, to, amount);
    }
	
	function collectFee(uint256 amount, bool sell, bool p2p) private returns (uint256) {
        uint256 totalFee;
		
        uint256 _bigETHPayDayPotFee = amount.mul(p2p ? bigETHPayDayPotFee[2] : sell ? bigETHPayDayPotFee[1] : bigETHPayDayPotFee[0]).div(10000);
		         bigETHPayDayPotFeeTotal = bigETHPayDayPotFeeTotal.add(_bigETHPayDayPotFee);
				 
		uint256 _marketingFee = amount.mul(p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]).div(10000);
		         marketingFeeTotal = marketingFeeTotal.add(_marketingFee);
		
		uint256 _liquidityFee = amount.mul(p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]).div(10000);
		         liquidityFeeTotal = liquidityFeeTotal.add(_liquidityFee);
		
        uint256 _stakingRewardFee = amount.mul(p2p ? stakingRewardFee[2] : sell ? stakingRewardFee[1] : stakingRewardFee[0]).div(10000);
		         stakingRewardFeeTotal = stakingRewardFeeTotal.add(_stakingRewardFee);	

        uint256 _P2ERewardPotFee = amount.mul(p2p ? P2ERewardPotFee[2] : sell ? P2ERewardPotFee[1] : P2ERewardPotFee[0]).div(10000);
		         P2ERewardPotFeeTotal = P2ERewardPotFeeTotal.add(_P2ERewardPotFee);	
				 
        uint256 _buyBackBurnFee = amount.mul(p2p ? buyBackBurnFee[2] : sell ? buyBackBurnFee[1] : buyBackBurnFee[0]).div(10000);
		         buyBackBurnFeeTotal = buyBackBurnFeeTotal.add(_buyBackBurnFee);					 
				 
		totalFee = _bigETHPayDayPotFee.add(_marketingFee).add(_liquidityFee).add(_stakingRewardFee).add(_P2ERewardPotFee).add(_buyBackBurnFee);
        return totalFee;
    }
	
	function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private lockTheSwap{
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            address(this),
            block.timestamp.add(300)
        );
    }
	
	function swapTokensForBNB(uint256 tokenAmount) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }
	
	function swapBNBForBUSD(uint256 BNBAmount, address payable receiver) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = BUSD;
		
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: BNBAmount}(
            0,
            path,
            receiver,
            block.timestamp.add(300)
        );
    }
	
	function swapBNBForETH(uint256 BNBAmount, address payable receiver) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = ETH;
		
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: BNBAmount}(
            0,
            path,
            receiver,
            block.timestamp.add(300)
        );
    }	
	
	function transferTokens(address tokenAddress, address to, uint256 amount) public onlyOwner {
        IBEP20(tokenAddress).transfer(to, amount);
    }
	
	function migrateBNB(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
    }
}