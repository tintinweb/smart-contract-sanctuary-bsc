/**
 *Submitted for verification at BscScan.com on 2022-06-27
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: Unlicensed

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
	
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
	
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0));
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
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IPancakeSwapV2Router02 is IPancakeSwapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable;
}

contract BEAST is BEP20, Ownable{
    using SafeMath for uint256;
	
    mapping (address => bool) public isExcludedFromFee;
	mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => user) public tradeData;
	mapping (address => uint256) public referralCode;
	mapping (uint256 => address) public codeAddress;
	mapping (address => address) public sponsor;
	mapping (address => bool) public isExcludedFromP2PDisable;
	mapping (address => bool) public isWhiteListForReward;
	mapping (address => bool) public isFirstBuy;
	mapping (address => bool) public isWhiteListed;
	mapping (address => bool) public isExcludedFromMaxTokenPerWallet;
	
	address[] public markerPairs;
	
	struct user {
       uint256 firstBuy;
       uint256 lastTradeTime;
       uint256 tradeAmount;
    }
	
	uint256 public shillToEarnFee = 400;
    uint256 public marketingFee = 500;
    uint256 public liquidityFee = 300;
	uint256 totalFee = shillToEarnFee.add(marketingFee).add(liquidityFee);
	
	uint256 public rewardBonus = 1000;
	uint256 public rewardBonusForWhiteList = 1500;
	uint256 public TwentyFourhours = 86400;
	
	address payable public marketingWallet = payable(0x9bFfE9a604fBa9d7018C5E00120C9eacC9743bFF);
	address payable public shillToEarnWallet = payable(0xC907F3c8b39dbCFC539C08FBD18C54A55e2EB0A5);
	address payable public rewardWallet = payable(0x009022b6eD4a176d0c3dC904ce466606681aB295);
	address payable public referralRewardWallet = payable(0xD3B109BD9ca2591C3801D251Bd6c7C0BCE485061);
	
	address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
	address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
	
    IPancakeSwapV2Router02 public immutable pancakeSwapV2Router;
    address public pancakeSwapV2Pair;

	bool public swapAndLiquifyEnabled = true;
	bool public initialDistributionFinished = false;
    bool public launchMode = true;
    bool public liquifyAll = false;
    bool public feesOnNormalTransfers = false;
	bool public P2PEnabled = false;
	
    uint256 public swapTokensAtAmount = 66666666666 * (10**18);
	uint256 public maxSellTransactionAmount = 6666666666666 * (10**18);
	uint256 public maxTokenPerWallet = 6666666666666 * (10**18);
	uint256 public dailySellLimit = 100;
	
	uint256 constant private MAX_NUMBER = 99999999999999;
	uint[MAX_NUMBER] private indices;
    uint nonce;
	
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event SetMarketingWallet(address wallet);
	event SetShillToEarnWallet(address wallet);
	event SetRewardBonusPercent(uint256 rewardbonus, uint256 rewardbonusforwhiteList);
	event SetFeePercent(uint256 shillToEarnFee, uint256 marketingFee, uint256 liquidityFee);
	event ExcludeFromMaxTokenPerWallet(address wallet);
	event IncludeInMaxTokenPerWallet(address wallet);
	event ExcludeFromP2PDisable(address wallet);
	event IncludeInP2PDisable(address wallet);
	event ExcludeFromFee(address wallet);
	event IncludeInFee(address wallet);
	event ExcludeFromReward(address wallet);
	event IncludeInReward(address wallet);
	event SetSwapTokensAtAmount(uint256 amount);
	event SetLiquifyAll(bool enabled);
	event SetmaxTokenPerWallet(uint256 amount);
	event SetMaxSellPerDay(uint256 amount);
	event SetMaxSellTransaction(uint256 amount);
	event SetFeesOnNormalTransfers(bool enabled);
	event SetTargetLiquidity(uint256 target, uint256 accuracy);
	event GenerateReferralCode(address wallet, uint256 code);
	event AddSponsor(address wallet, address sponsor);
    
	bool inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
	
   constructor() BEP20("BEAST", "BEAST", 18) {
        
        IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pancakeSwapV2Pair = IPancakeSwapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH());
		
        pancakeSwapV2Router = _pancakeSwapV2Router;
		
        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
		isExcludedFromFee[marketingWallet] = true;
		isExcludedFromFee[referralRewardWallet] = true;
		isExcludedFromFee[shillToEarnWallet] = true;
		
		isExcludedFromP2PDisable[referralRewardWallet] = true;
		isExcludedFromP2PDisable[rewardWallet] = true;
		isExcludedFromP2PDisable[owner()] = true;
		
		isExcludedFromMaxTokenPerWallet[pancakeSwapV2Pair] = true;
		isExcludedFromMaxTokenPerWallet[address(this)] = true;
		isExcludedFromMaxTokenPerWallet[owner()] = true;
		isExcludedFromMaxTokenPerWallet[rewardWallet] = true;
		isExcludedFromMaxTokenPerWallet[referralRewardWallet] = true;
		
		_approve(address(referralRewardWallet), address(this), 666666666666666 * (10**18));
		
		_setAutomatedMarketMakerPair(pancakeSwapV2Pair, true);
		
        _initialSupply(owner(), 666666666666666 * (10**18));
    }
	
    function excludeFromFee(address account) public onlyOwner {
	   require(isExcludedFromFee[account] != true, "Account is already exclude");
       isExcludedFromFee[account] = true;
	   emit ExcludeFromFee(account);
    }
    
    function includeInFee(address account) public onlyOwner {
	     require(isExcludedFromFee[account] != false, "Account is already include");
        isExcludedFromFee[account] = false;
		emit IncludeInFee(account);
    }
	
	function excludeFromP2PDisable(address account) public onlyOwner {
	    require(isExcludedFromP2PDisable[account] != true, "Account is already exclude");
        isExcludedFromP2PDisable[account] = true;
		emit ExcludeFromP2PDisable(account);
    }
    
    function includeInP2PDisable(address account) public onlyOwner {
	    require(isExcludedFromP2PDisable[account] != false, "Account is already include");
        isExcludedFromP2PDisable[account] = false;
		emit IncludeInP2PDisable(account);
    }
	
	function excludeFromMaxTokenPerWallet(address account) public onlyOwner {
		require(isExcludedFromMaxTokenPerWallet[account] != true, "Account is already exclude");
		isExcludedFromMaxTokenPerWallet[account] = true;
		emit ExcludeFromMaxTokenPerWallet(account);
	}
	
	function includeInMaxTokenPerWallet(address account) public onlyOwner {
		require(isExcludedFromMaxTokenPerWallet[account] != false, "Account is already include");
		isExcludedFromMaxTokenPerWallet[account] = false;
		emit IncludeInMaxTokenPerWallet(account);
	}
	
    function setFeePercent(uint256 _shillToEarnFee, uint256 _marketingFee, uint256 _liquidityFee) external onlyOwner() {
        require(_shillToEarnFee.add(_marketingFee).add(_liquidityFee) <= 2000 , "Max fee limit reached for fee");
		
	    shillToEarnFee = _shillToEarnFee;
		marketingFee  = _marketingFee;
		liquidityFee  = _liquidityFee;
		
		totalFee = _shillToEarnFee.add(_marketingFee).add(_liquidityFee);
		emit SetFeePercent(_shillToEarnFee, _marketingFee, _liquidityFee);
    }
	
	function setRewardBonusPercent(uint256 RewardBonus, uint256 RewardBonusForWhiteList) external onlyOwner() {
	     require(RewardBonus <= 2000 , "Max fee limit reached for rewardBonus");
		 require(RewardBonusForWhiteList <= 2000 , "Max fee limit reached for rewardBonus");
		 
         rewardBonus = RewardBonus;
		 rewardBonusForWhiteList = RewardBonusForWhiteList;
		 emit SetRewardBonusPercent(RewardBonus, RewardBonusForWhiteList);
    }
	
	function setMarketingWallet(address payable _marketingWallet) external onlyOwner() {
	    require(_marketingWallet != address(0), "zero-address not allowed");
		
        marketingWallet = _marketingWallet;
		emit SetMarketingWallet(_marketingWallet);
    }
	
	function setShillToEarnWallet(address payable _shillToEarnWallet) external onlyOwner() {
	    require(_shillToEarnWallet != address(0), "zero-address not allowed");
		
        shillToEarnWallet = _shillToEarnWallet;
		emit SetShillToEarnWallet(_shillToEarnWallet);
    }
	
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
	
    function _transfer(address from, address to, uint256 amount) internal override 
	{
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
		
		bool excludedAccount = isExcludedFromFee[from] || isExcludedFromFee[to];
		require(initialDistributionFinished || excludedAccount || isWhiteListed[to], "Trading not started");
		
		if(!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && !isExcludedFromP2PDisable[from])
		{
		    require(P2PEnabled, "Wallet to wallet transfer disabled");
		}
		
		if(!isExcludedFromMaxTokenPerWallet[to] && !automatedMarketMakerPairs[to])
		{
            uint256 balanceRecepient = balanceOf(to);
            require(balanceRecepient + amount <= maxTokenPerWallet, "Exceeds maximum token per wallet limit");
        }
		
		if(automatedMarketMakerPairs[to] && !excludedAccount)
		{
		    require(amount <= maxSellTransactionAmount, "Error amount");
			
			uint blkTime = block.timestamp;
            uint256 dailyLimit = balanceOf(from).mul(dailySellLimit).div(10000);
            require(amount <= dailyLimit, "ERR: Can't sell more than daily limit");
			
            if(blkTime > tradeData[from].lastTradeTime + TwentyFourhours) 
			{
                tradeData[from].lastTradeTime = blkTime;
                tradeData[from].tradeAmount = amount;
            }
            else
			{
                require(tradeData[from].tradeAmount + amount <= dailyLimit, "ERR: Can't sell more than daily limit");
				tradeData[from].tradeAmount = tradeData[from].tradeAmount + amount;
            }
		}
		
		if(automatedMarketMakerPairs[to]) 
		{
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= swapTokensAtAmount;
            if (!inSwapAndLiquify && canSwap && swapAndLiquifyEnabled) {
				if(!liquifyAll)
				{
					uint256 fromLiquidityFee = swapTokensAtAmount.div(totalFee).mul(liquidityFee);
					uint256 OtherTokens = swapTokensAtAmount.sub(fromLiquidityFee);
					
					uint256 half = fromLiquidityFee.div(2);
					uint256 otherHalf = fromLiquidityFee.sub(half);
					
					uint256 initialBalance = address(this).balance;
					swapTokensForBNB(half.add(OtherTokens));
					uint256 newBalance = address(this).balance.sub(initialBalance);
					
					uint256 liquidityPart   = newBalance.div(totalFee).mul(liquidityFee);
							liquidityPart   = liquidityPart.div(2);
					uint256 marketingPart   = newBalance.div(totalFee).mul(marketingFee);
					uint256 shillToEarnPart = newBalance.sub(liquidityPart).sub(marketingPart);
					
					if(marketingPart > 0)
					{
					    payable(marketingWallet).transfer(marketingPart);
						// swapBNBForBUSD(marketingPart, marketingWallet);
					}
					
					if(shillToEarnPart > 0)
					{
					    payable(shillToEarnWallet).transfer(shillToEarnPart);
						// swapBNBForBUSD(shillToEarnPart, shillToEarnWallet);
					}
					
					if(liquidityPart > 0)
					{
						addLiquidity(otherHalf, liquidityPart);
						emit SwapAndLiquify(half.add(OtherTokens), liquidityPart, otherHalf);
					}
				}
				else
				{
				
					uint256 fromLiquidityFee = contractTokenBalance.div(totalFee).mul(liquidityFee);
					uint256 OtherTokens = contractTokenBalance.sub(fromLiquidityFee);
					
					uint256 half = fromLiquidityFee.div(2);
					uint256 otherHalf = fromLiquidityFee.sub(half);
					
					uint256 initialBalance = address(this).balance;
					swapTokensForBNB(half.add(OtherTokens));
					uint256 newBalance = address(this).balance.sub(initialBalance);
					
					uint256 liquidityPart   = newBalance.div(totalFee).mul(liquidityFee);
							liquidityPart   = liquidityPart.div(2);
					uint256 marketingPart   = newBalance.div(totalFee).mul(marketingFee);
					uint256 shillToEarnPart = newBalance.sub(liquidityPart).sub(marketingPart);
					
					if(marketingPart > 0)
					{
					    payable(marketingWallet).transfer(marketingPart);
						// swapBNBForBUSD(marketingPart, marketingWallet);
					}
					
					if(shillToEarnPart > 0)
					{
					    payable(shillToEarnWallet).transfer(shillToEarnPart);
						// swapBNBForBUSD(shillToEarnPart, shillToEarnWallet);
					}
					
					if(liquidityPart > 0)
					{
						addLiquidity(otherHalf, liquidityPart);
						emit SwapAndLiquify(half.add(OtherTokens), liquidityPart, otherHalf);
					}
				}
            }
        }
		
        bool takeFee = !inSwapAndLiquify;
        if(excludedAccount)
		{
            takeFee = false;
        }
		else if(!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && !feesOnNormalTransfers)
		{
		    takeFee = false;
		}
		
		if(automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to] && sponsor[to] != address(0))
		{
		    uint256 rewardAmount = (amount * rewardBonus) / 10000;
			uint256 rewardAmountSponsor = isWhiteListForReward[sponsor[to]] ? (amount * rewardBonusForWhiteList) / 10000 : (amount * rewardBonus) / 10000;
			
			if(balanceOf(address(referralRewardWallet)) >= rewardAmount && !isFirstBuy[to]) 
			{
			    super._transfer(address(referralRewardWallet), address(to), rewardAmount);
				isFirstBuy[to] = true;
			}
			
			if(balanceOf(address(referralRewardWallet)) >= rewardAmountSponsor) 
			{
			    super._transfer(address(referralRewardWallet), sponsor[to], rewardAmountSponsor);
			}
		}
        if(takeFee) 
		{
		    uint256 allfee = amount.mul(shillToEarnFee.add(marketingFee).add(liquidityFee)).div(10000);
			if(allfee > 0)
			{
			   super._transfer(from, address(this), allfee);
			   amount = amount.sub(allfee);
			}
		}
        super._transfer(from, to, amount);
    }
	
	function swapBNBForBUSD(uint256 amount, address receiver) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = address(BUSD);
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(receiver),
            block.timestamp.add(300)
        );
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();

        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);

        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp.add(300)
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private lockTheSwap{
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(),
            block.timestamp.add(300)
        );
    }
	
	function getCirculatingSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(address(DEAD))).sub(balanceOf(address(ZERO)));
    }
	
	function multiTransfer(address from, address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        require(launchMode, "Cannot execute this after launch is done");

        require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses");
        require(addresses.length == tokens.length,"Mismatch between Address and token count");
		
        uint256 SCCC = 0;
        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }
		
        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");
        for(uint i=0; i < addresses.length; i++){
            super._transfer(from, addresses[i], tokens[i]);
        }
    }
	
	function whiteListForExtraReward(address[] calldata addresses, bool _type) external onlyOwner {
	    require(addresses.length < 501,"GAS Error: max whitelist limit is 500 addresses");
		for(uint i=0; i < addresses.length; i++){
            isWhiteListForReward[addresses[i]] = _type;
        }
	}
	
	function whiteListForSale(address[] calldata addresses, bool _type) external onlyOwner {
	    require(addresses.length < 501,"GAS Error: max whitelist limit is 500 addresses");
		for(uint i=0; i < addresses.length; i++){
            isWhiteListed[addresses[i]] = _type;
        }
	}
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
  	    swapTokensAtAmount = amount;
		emit SetSwapTokensAtAmount(amount);
  	}
	
	function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != pancakeSwapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
	
	function _setAutomatedMarketMakerPair(address pair, bool value) private {
		require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
		automatedMarketMakerPairs[pair] = value;
        
		if(value) {
            markerPairs.push(pair);
        } else {
            require(markerPairs.length > 1, "Required 1 pair");
            for (uint256 i = 0; i < markerPairs.length; i++) {
                if (markerPairs[i] == pair) {
                    markerPairs[i] = markerPairs[markerPairs.length - 1];
                    markerPairs.pop();
                    break;
                }
            }
        }
		
		emit SetAutomatedMarketMakerPair(pair, value);
	}

	function setInitialDistributionFinished() external onlyOwner {
        initialDistributionFinished = true;
    }
	
	function setLaunchModeFinished() external onlyOwner {
        launchMode = false;
    }
	
	function setFeesOnNormalTransfers(bool enabled) external onlyOwner {
        require(feesOnNormalTransfers != enabled, "Not changed");
        feesOnNormalTransfers = enabled;
		emit SetFeesOnNormalTransfers(enabled);
    }
	
	function setMaxSellTransaction(uint256 maxTxn) external onlyOwner {
	    require(maxTxn >= 6666666666666 * 10 ** 18 && maxTxn <= 33333333333330 * 10 ** 18, "Sell per transection between 1% to 5%");
        maxSellTransactionAmount = maxTxn;
		emit SetMaxSellTransaction(maxTxn);
    }
	
	function setMaxSellPerDay(uint256 sellLimit) external onlyOwner {
	    require(sellLimit >= 100 && sellLimit <= 500, "Daily sell limit between 1% to 5%");
        dailySellLimit = sellLimit;
		emit SetMaxSellPerDay(sellLimit);
    }
	
	function setmaxTokenPerWallet(uint256 amount) external onlyOwner {
		require(amount <= totalSupply(), "Amount cannot be over the total supply.");
		require(amount >= 6666666666666 * (10**18), "Amount can be over the 1%.");
		maxTokenPerWallet = amount;
		emit SetmaxTokenPerWallet(amount);
	}
	
	function setLiquifyAll(bool enabled) external onlyOwner {
	    require(liquifyAll != enabled, "Not changed");
        liquifyAll = enabled;
		emit SetLiquifyAll(enabled);
    }
	
	function clearStuckBalance(address _receiver) external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_receiver).transfer(balance);
    }

    function rescueToken(address tokenAddress, uint256 tokens) external onlyOwner returns (bool success){
        return IBEP20(tokenAddress).transfer(msg.sender, tokens);
    }
	
	function generateReferralCode() external {
	   require(referralCode[msg.sender] == 0, "Code already generated");
	   
	   uint256 code = _randMod(); 
	   referralCode[msg.sender] = code;
	   codeAddress[code] = msg.sender;
	   emit GenerateReferralCode(msg.sender, code);
    }
	
	function addSponsor(uint256 _referralCode) external {
	   require(sponsor[msg.sender] == address(0), "Sponsor already added");
       require(codeAddress[_referralCode] != address(0) && codeAddress[_referralCode] != msg.sender, "Incorrect Code");
	   
	   address sponsorAddress = codeAddress[_referralCode];
	   sponsor[msg.sender] = sponsorAddress; 
	   emit AddSponsor(msg.sender, sponsorAddress);
    }
	
    function _randMod() private returns (uint) {
        uint totalSize = MAX_NUMBER - nonce;
        uint index = uint(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint value = 0;
        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }
 
        if (indices[totalSize - 1] == 0) {
            indices[index] = totalSize - 1;
        } else {
            indices[index] = indices[totalSize - 1];
        }
        nonce++;
        return value+1;
    }
}