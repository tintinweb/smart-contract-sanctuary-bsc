/**
 *Submitted for verification at BscScan.com on 2022-06-17
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

    constructor (string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
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

contract CBOX is BEP20, Ownable {
    using SafeMath for uint256;
	
    IPancakeSwapV2Router02 public pancakeSwapV2Router;
    address public pancakeSwapV2Pair;
	
    uint256[] public rewardsFee;
	uint256[] public marketingFee;
    uint256[] public liquidityFee;
	uint256[] public developmentFee;
	uint256[] public poolShare;
	uint256[] public cryptoBoxPrice = [50000000000000000, 100000000000000000, 200000000000000000];
	
	uint256 private rewardsFeeTotal;
	uint256 private marketingFeeTotal;
	uint256 private liquidityFeeTotal;
	uint256 private developmentFeeTotal;
	
    uint256 public swapTokensAtAmount = 10000 * (10**9);
	uint256 public maxTxAmount = 10000000 * (10**9);
	uint256 public maxTokenPerWallet = 10000000 * (10**9);
    
	address[] rewardToken = [
		address(this),
		address(this),
		address(this),
		address(this),
		address(this),
		address(0xDAcbdeCc2992a63390d108e8507B98c7E2B5584a), // SHIBA
		address(0x8a9424745056Eb399FD19a0EC26A14316684e274), // DOGE
		address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684), // LTC
		address(0x8BaBbB98678facC7342735486C851ABD7A0d17Ca), // ETH
		address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7)  // BTC
	];
	
	uint256[3][] public box1;
	uint256[3][] public box2;
	uint256[3][] public box3;
	
	address payable public marketingFeeAddress = payable(0x2c242A27517b0557A3606385d561eFDf9Bcfb814);
	address payable public developmentFeeAddress = payable(0xc7731666b8F373c39357e53577E72f92521CA078);
	address private DEAD = address(0x000000000000000000000000000000000000dEaD);
	
    uint256 private tokenToMarketing;
    uint256 private tokenToLiquidity;
    uint256 private tokenToDevelopment;
    uint256 private tokenToRewards;
    uint256 private liquidityHalf;
    uint256 private tokenToSwap;
    uint256 private newBalance;
	
	bool public swapEnable = true;
	
	bool inSwapping;
	modifier lockTheSwap {
		 inSwapping = true;
		 _;
		 inSwapping = false;
    }
	
    mapping (address => bool) public isExcludedFromFees;
	mapping (address => bool) public isExcludedFromMaxTokenPerTx;
    mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => bool) public isBlackListed;
	mapping (address => bool) public isExcludedFromMaxTokenPerWallet;
	
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event AddedBlackList(address _address);
    event RemovedBlackList(address _address);
	event Reward(address rewardAddress, uint256 multiplier);
	
	constructor() BEP20("CBOX", "CBOX", 9) {
		
    	IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        address _pancakeSwapV2Pair = IPancakeSwapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH());

        pancakeSwapV2Router = _pancakeSwapV2Router;
        pancakeSwapV2Pair   = _pancakeSwapV2Pair;
		
        _setAutomatedMarketMakerPair(_pancakeSwapV2Pair, true);
		
        excludeFromFees(address(this), true);
		excludeFromFees(owner(), true);
		excludeFromFees(DEAD, true);
		
		isExcludedFromMaxTokenPerWallet[pancakeSwapV2Pair] = true;
		isExcludedFromMaxTokenPerWallet[address(this)] = true;
		isExcludedFromMaxTokenPerWallet[owner()] = true;
		
		isExcludedFromMaxTokenPerTx[owner()] = true;
		isExcludedFromMaxTokenPerTx[address(this)] = true;
		
		rewardsFee.push(200);
		rewardsFee.push(200);
		rewardsFee.push(0);
		
		marketingFee.push(150);
		marketingFee.push(200);
		marketingFee.push(0);
		
		developmentFee.push(50);
		developmentFee.push(100);
		developmentFee.push(0);
		
		liquidityFee.push(200);
		liquidityFee.push(200);
		liquidityFee.push(0);
		
		poolShare.push(9000);
		poolShare.push(400);
		poolShare.push(400);
		poolShare.push(200);
		
		box1.push([1, 3000, 30]);
		box1.push([3001, 6000, 50]);
		box1.push([6001, 7000, 80]);
		box1.push([7001, 8500, 100]);
		box1.push([8501, 9000, 150]);
		box1.push([9001, 9850, 300]);
		box1.push([9851, 9900, 500]);
		box1.push([9901, 9970, 1000]);
		box1.push([9971, 9985, 2000]);
		box1.push([9986, 9995, 3000]);
		box1.push([9996, 9999, 5000]);
		box1.push([10000, 10000, 10000]);
		
		box2.push([1, 3000, 30]);
		box2.push([3001, 6000, 50]);
		box2.push([6001, 7000, 80]);
		box2.push([7001, 8500, 100]);
		box2.push([8501, 9000, 150]);
		box2.push([9001, 9850, 300]);
		box2.push([9851, 9900, 500]);
		box2.push([9901, 9970, 1000]);
		box2.push([9971, 9985, 2000]);
		box2.push([9986, 9995, 3000]);
		box2.push([9996, 9999, 5000]);
		box2.push([10000, 10000, 20000]);
		
		box3.push([1, 3000, 30]);
		box3.push([3001, 6000, 50]);
		box3.push([6001, 7000, 80]);
		box3.push([7001, 8500, 100]);
		box3.push([8501, 9000, 150]);
		box3.push([9001, 9850, 300]);
		box3.push([9851, 9900, 500]);
		box3.push([9901, 9970, 1000]);
		box3.push([9971, 9985, 2000]);
		box3.push([9986, 9995, 3000]);
		box3.push([9996, 9999, 5000]);
		box3.push([10000, 10000, 40000]);
		
        _initialSupply(owner(), 1000000000 * (10**9));
    }
	
    receive() external payable {}
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
  	     require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		 swapTokensAtAmount = amount;
  	}
	
	function setMaxTxAmount(uint256 amount) external onlyOwner() {
	     require(amount <= totalSupply(), "amount is not correct.");
         maxTxAmount = amount;
    }
	
	function setmaxTokenPerWallet(uint256 amount) public onlyOwner {
		require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		maxTokenPerWallet = amount;
	}
	
	function setSwapEnable(bool _enabled) public onlyOwner {
        swapEnable = _enabled;
    }
	
	function setMarketingFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(liquidityFee[0].add(developmentFee[0]).add(rewardsFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(liquidityFee[1].add(developmentFee[1]).add(rewardsFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(liquidityFee[2].add(developmentFee[2]).add(rewardsFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		marketingFee[0] = buy;
		marketingFee[1] = sell;
		marketingFee[2] = p2p;
	}
	
	function setLiquidityFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(developmentFee[0]).add(rewardsFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(developmentFee[1]).add(rewardsFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(developmentFee[2]).add(rewardsFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		liquidityFee[0] = buy;
		liquidityFee[1] = sell;
		liquidityFee[2] = p2p;
	}
	
	function setDevelopmentFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(liquidityFee[0]).add(rewardsFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(liquidityFee[1]).add(rewardsFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(liquidityFee[2]).add(rewardsFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		developmentFee[0] = buy;
		developmentFee[1] = sell;
		developmentFee[2] = p2p;
	}
	
	function setRewardsFee(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {
	    require(marketingFee[0].add(liquidityFee[0]).add(developmentFee[0]).add(buy)  <= 3000 , "Max fee limit reached for 'BUY'");
		require(marketingFee[1].add(liquidityFee[1]).add(developmentFee[1]).add(sell) <= 3000 , "Max fee limit reached for 'SELL'");
		require(marketingFee[2].add(liquidityFee[2]).add(developmentFee[2]).add(p2p)  <= 3000 , "Max fee limit reached for 'P2P'");
		
		rewardsFee[0] = buy;
		rewardsFee[1] = sell;
		rewardsFee[2] = p2p;
	}
	
	function setPoolShare(uint256 reward, uint256 marketing, uint256 development, uint256 burn) public onlyOwner {
	    require(reward.add(marketing).add(development).add(burn) == 10000 , "Share limit must be '100%'");
		
		poolShare[0] = reward;
		poolShare[1] = marketing;
		poolShare[2] = development;
		poolShare[3] = burn;
	}
	
	function setCryptoBoxPrice(uint256 box1Price, uint256 box2Price, uint256 box3Price) external onlyOwner {
	    require(box1Price > 0 && box2Price > 0 && box3Price > 0, "Incorrect value");
		
		cryptoBoxPrice[0] = box1Price;
		cryptoBoxPrice[1] = box2Price;
		cryptoBoxPrice[2] = box3Price;
	}
	
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "Account is already the value of 'excluded'");
        isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
	
	function excludeFromMaxTxAmount(address account, bool excluded) public onlyOwner {
		require(isExcludedFromMaxTokenPerTx[account] != excluded, "APAY: Account is already the value of 'excluded'");
		isExcludedFromMaxTokenPerTx[account] = excluded;
	}
	
	function excludeFromMaxTokenPerWallet(address account, bool excluded) public onlyOwner {
		require(isExcludedFromMaxTokenPerWallet[account] != excluded, "Account is already the value of 'excluded'");
		isExcludedFromMaxTokenPerWallet[account] = excluded;
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
	
	function setMarketingFeeAddress(address payable newAddress) external onlyOwner() {
        require(newAddress != address(0), "zero-address not allowed");
	    marketingFeeAddress = newAddress;
    }
	
	function setDevelopmentFeeAddress(address payable newAddress) external onlyOwner() {
        require(newAddress != address(0), "zero-address not allowed");
	    developmentFeeAddress = newAddress;
    }
	
	function addToBlackList (address _wallet) external onlyOwner {
        isBlackListed[_wallet] = true;
        emit AddedBlackList(_wallet);
    }
	
    function removeFromBlackList (address _wallet) external onlyOwner {
        isBlackListed[_wallet] = false;
        emit RemovedBlackList(_wallet);
    }
	
	function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
		require(!isBlackListed[from], "BEP20: transfer to is blacklisted");
		require(!isBlackListed[to], "BEP20: transfer from is blacklisted");
		
        if(!isExcludedFromMaxTokenPerTx[from]) 
		{
		    require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
		}
		
		if(!isExcludedFromMaxTokenPerWallet[to] && !automatedMarketMakerPairs[to]){
            uint256 balanceRecepient = balanceOf(to);
            require(balanceRecepient + amount <= maxTokenPerWallet, "Exceeds maximum token per wallet limit");
        }
		
		uint256 contractTokenBalance = balanceOf(address(this));
		bool canSwap = contractTokenBalance >= swapTokensAtAmount;
		
		if (!inSwapping && canSwap && swapEnable && automatedMarketMakerPairs[to]) 
		{
			 tokenToMarketing     = marketingFeeTotal;
			 tokenToLiquidity     = liquidityFeeTotal;
			 tokenToDevelopment   = developmentFeeTotal;
			 liquidityHalf        = tokenToLiquidity.div(2);
			 tokenToSwap          = tokenToMarketing.add(liquidityHalf).add(tokenToDevelopment);
			 
			 if(tokenToSwap >= swapTokensAtAmount)
			 {
			    uint256 initialBalance = address(this).balance;			
				swapTokensForBNB(swapTokensAtAmount);
				newBalance = address(this).balance.sub(initialBalance);
				
				uint256 marketingPart     = newBalance.mul(tokenToMarketing).div(tokenToSwap);
				uint256 liquidityPart     = newBalance.mul(liquidityHalf).div(tokenToSwap);
				uint256 developmentPart   = newBalance.sub(marketingPart).sub(liquidityPart);
				
				if(marketingPart > 0)
				{
					payable(marketingFeeAddress).transfer(marketingPart);
					marketingFeeTotal = marketingFeeTotal.sub(swapTokensAtAmount.mul(tokenToMarketing).div(tokenToSwap));
				}
				
				if(developmentPart > 0) 
				{
					payable(developmentFeeAddress).transfer(developmentPart);
					developmentFeeTotal = developmentFeeTotal.sub(swapTokensAtAmount.mul(tokenToDevelopment).div(tokenToSwap));
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
		
		uint256 _marketingFee = amount.mul(p2p ? marketingFee[2] : sell ? marketingFee[1] : marketingFee[0]).div(10000);
		         marketingFeeTotal = marketingFeeTotal.add(_marketingFee);
		
		uint256 _liquidityFee = amount.mul(p2p ? liquidityFee[2] : sell ? liquidityFee[1] : liquidityFee[0]).div(10000);
		         liquidityFeeTotal = liquidityFeeTotal.add(_liquidityFee);
		
        uint256 _developmentFee = amount.mul(p2p ? developmentFee[2] : sell ? developmentFee[1] : developmentFee[0]).div(10000);
		         developmentFeeTotal = developmentFeeTotal.add(_developmentFee);	

        uint256  _rewardsFee = amount.mul(p2p ? rewardsFee[2] : sell ? rewardsFee[1] : rewardsFee[0]).div(10000);
		         rewardsFeeTotal = rewardsFeeTotal.add(_rewardsFee);	
				 
		totalFee = _marketingFee.add(_liquidityFee).add(_developmentFee).add(_rewardsFee);
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
	
	function swapTokensTokenForToken(uint256 tokenAmount, address token, address receiver) private lockTheSwap{
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();
		path[2] = address(token);
		
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(receiver), block.timestamp);
    }
	
	function transferTokens(address tokenAddress, address to, uint256 amount) public onlyOwner {
       IBEP20(tokenAddress).transfer(to, amount);
    }
	
	function migrateBNB(address payable recipient) public onlyOwner {
       recipient.transfer(address(this).balance);
    }
	
	function resetFeeTotal() public onlyOwner {
	   marketingFeeTotal = 0;
	   liquidityFeeTotal = 0;
	   developmentFeeTotal = 0;
    }
	
	function getQuotes(uint256 boxID) public view returns (uint256){
	   require(cryptoBoxPrice.length > boxID, "BEP20: transfer from the zero address");
	   
	   uint256 amountIn = cryptoBoxPrice[boxID]; 
	   
	   address[] memory path = new address[](2);
       path[0] = pancakeSwapV2Router.WETH();
	   path[1] = address(this);
	   
	   uint256[] memory tokenRequired = pancakeSwapV2Router.getAmountsOut(amountIn, path);
	   return tokenRequired[1];
    }
	
    function buyBox(uint256 boxID, uint256 tokens) public{
	    require(cryptoBoxPrice.length > boxID, "BEP20: transfer from the zero address");
		
	    uint256 tokenRequired = getQuotes(boxID);
		require(tokens >= tokenRequired, "BEP20: token amount is less than required amount");
		require(balanceOf(msg.sender) >= tokens, "BEP20: sufficient balance not found on address");
		
		uint256 _rewardsFee = tokens.mul(poolShare[0]).div(10000);
		         rewardsFeeTotal = rewardsFeeTotal.add(_rewardsFee);	
				 
		uint256 _marketingFee = tokens.mul(poolShare[1]).div(10000);
		         marketingFeeTotal = marketingFeeTotal.add(_marketingFee);

        uint256 _developmentFee = tokens.mul(poolShare[2]).div(10000);
		         developmentFeeTotal = developmentFeeTotal.add(_developmentFee);
				 
        uint256 _burnFee = tokens.mul(poolShare[3]).div(10000);
		
		_transfer(msg.sender, address(this), tokens-_burnFee);
		_transfer(msg.sender, DEAD, _burnFee);
		
		uint256 rewardTokenID = (random(11)) - 1;
		uint256 rewardMultiplier = random(10001);
		
        if(boxID==0)
	    {
			for(uint256 i = 0; i < box1.length; i++) {
			
			    uint256 min  = box1[i][0];
			    uint256 max  = box1[i][1];
			    uint256 mult = box1[i][2];
			    if(rewardMultiplier >= min && max >= rewardMultiplier)
			    {
			        address rewardTokenAddress = rewardToken[rewardTokenID];
					uint256 amountIn = cryptoBoxPrice[boxID]; 
					uint256 amountMP = (amountIn * mult).div(100);
					
					address[] memory path = new address[](2);
				    path[0] = pancakeSwapV2Router.WETH();
				    path[1] = address(this);
					
					uint256[] memory tokensRequired = pancakeSwapV2Router.getAmountsOut(amountMP, path);
	                uint256 tokenToSend = tokensRequired[1];
					if(rewardTokenAddress == address(this))
					{
					    tokenToSend = rewardsFeeTotal >= tokenToSend ? tokenToSend : rewardsFeeTotal; 
						uint256 userBalance = balanceOf(msg.sender);
                        if(userBalance.add(tokenToSend) > maxTokenPerWallet)
						{
						    rewardTokenAddress = rewardToken[9];
						    swapTokensTokenForToken(tokenToSend, rewardTokenAddress, msg.sender);
						    rewardsFeeTotal = rewardsFeeTotal.sub(tokenToSend);
						}						
						else
						{
						    _transfer(address(this), msg.sender, tokenToSend);
						}
					}
					else
					{
					    tokenToSend = rewardsFeeTotal >= tokenToSend ? tokenToSend : rewardsFeeTotal;  
					    swapTokensTokenForToken(tokenToSend, rewardTokenAddress, msg.sender);
						rewardsFeeTotal = rewardsFeeTotal.sub(tokenToSend);
					}
					emit Reward(rewardTokenAddress, mult);
					break;
			    }
			}
	    }
        else if(boxID==1)
	    {
		    for(uint256 i = 0; i < box2.length; i++) {
			    uint256 min  = box2[i][0];
			    uint256 max  = box2[i][1];
			    uint256 mult = box2[i][2];
			    if(rewardMultiplier >= min && max >= rewardMultiplier)
			    {
			        address rewardTokenAddress = rewardToken[rewardTokenID];
					uint256 amountIn = cryptoBoxPrice[boxID]; 
					uint256 amountMP = (amountIn * mult).div(100);
					
					address[] memory path = new address[](2);
				    path[0] = pancakeSwapV2Router.WETH();
				    path[1] = address(this);
					
					uint256[] memory tokensRequired = pancakeSwapV2Router.getAmountsOut(amountMP, path);
	                uint256 tokenToSend = tokensRequired[1];
					if(rewardTokenAddress == address(this))
					{
					    tokenToSend = rewardsFeeTotal >= tokenToSend ? tokenToSend : rewardsFeeTotal; 
						uint256 userBalance = balanceOf(msg.sender);
                        if(userBalance.add(tokenToSend) > maxTokenPerWallet)
						{
						    rewardTokenAddress = rewardToken[9];
						    swapTokensTokenForToken(tokenToSend, rewardTokenAddress, msg.sender);
						    rewardsFeeTotal = rewardsFeeTotal.sub(tokenToSend);
						}						
						else
						{
						    _transfer(address(this), msg.sender, tokenToSend);
						}
					}
					else
					{
					    tokenToSend = rewardsFeeTotal >= tokenToSend ? tokenToSend : rewardsFeeTotal;  
					    swapTokensTokenForToken(tokenToSend, rewardTokenAddress, msg.sender);
						rewardsFeeTotal = rewardsFeeTotal.sub(tokenToSend);
					}
					emit Reward(rewardTokenAddress, mult);
					break;
			    }
			}
	    }
        else
	    {
           	for(uint256 i = 0; i < box3.length; i++) {
			
			    uint256 min  = box3[i][0];
			    uint256 max  = box3[i][1];
			    uint256 mult = box3[i][2];
			    if(rewardMultiplier >= min && max >= rewardMultiplier)
			    {
			        address rewardTokenAddress = rewardToken[rewardTokenID];
					uint256 amountIn = cryptoBoxPrice[boxID]; 
					uint256 amountMP = (amountIn * mult).div(100);
					
					address[] memory path = new address[](2);
				    path[0] = pancakeSwapV2Router.WETH();
				    path[1] = address(this);
					
					uint256[] memory tokensRequired = pancakeSwapV2Router.getAmountsOut(amountMP, path);
	                uint256 tokenToSend = tokensRequired[1];
					if(rewardTokenAddress == address(this))
					{
					    tokenToSend = rewardsFeeTotal >= tokenToSend ? tokenToSend : rewardsFeeTotal; 
						uint256 userBalance = balanceOf(msg.sender);
                        if(userBalance.add(tokenToSend) > maxTokenPerWallet)
						{
						    rewardTokenAddress = rewardToken[9];
						    swapTokensTokenForToken(tokenToSend, rewardTokenAddress, msg.sender);
						    rewardsFeeTotal = rewardsFeeTotal.sub(tokenToSend);
						}						
						else
						{
						    _transfer(address(this), msg.sender, tokenToSend);
						}
					}
					else
					{
					    tokenToSend = rewardsFeeTotal >= tokenToSend ? tokenToSend : rewardsFeeTotal;  
					    swapTokensTokenForToken(tokenToSend, rewardTokenAddress, msg.sender);
						rewardsFeeTotal = rewardsFeeTotal.sub(tokenToSend);
					}
					emit Reward(rewardTokenAddress, mult);
					break;
			    }
			}	
	    }	   
    }
    
	function random(uint256 number) public view returns(uint256){
       return uint256(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender))) % number;
    }
}