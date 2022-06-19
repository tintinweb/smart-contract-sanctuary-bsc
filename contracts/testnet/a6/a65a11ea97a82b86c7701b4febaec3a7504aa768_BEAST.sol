/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

pragma solidity ^0.8.10;

// SPDX-License-Identifier: Unlicensed

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
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
}

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

contract BEAST is Context, IBEP20, Ownable{
    using SafeMath for uint256;
	
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
	
    mapping (address => mapping (address => uint256)) private _allowances;
	
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
	mapping (address => bool) public automatedMarketMakerPairs;
	mapping (address => user) public tradeData;
	mapping (address => uint256) public referralCode;
	mapping (uint256 => address) public codeAddress;
	mapping (address => address) public sponsor;
	
    address[] private _excluded;
	address[] public markerPairs;
	
	struct user {
       uint256 firstBuy;
       uint256 lastTradeTime;
       uint256 tradeAmount;
    }
	
    uint constant private PERCENTS_DIVIDER = 10000;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 666666666666666 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "BEAST";
    string private _symbol = "BEAST";
    uint8 private _decimals = 18;
    
	uint256 public reflectionFee = 400;
    uint256 public marketingFee = 500;
    uint256 public liquidityFee = 300;
	uint256 public rewardBonus = 1000;
	
	uint256 public TwentyFourhours = 86400;
	
	uint256 private _liquidityFee = liquidityFee.add(marketingFee);
    uint256 private _previousLiquidityFee = _liquidityFee;
	uint256 private _previousReflectionFee = reflectionFee;
	
	address payable public marketingWallet = payable(0x9bFfE9a604fBa9d7018C5E00120C9eacC9743bFF);
	address payable public rewardWallet = payable(0x009022b6eD4a176d0c3dC904ce466606681aB295);
	address payable public referralRewardWallet = payable(0x009022b6eD4a176d0c3dC904ce466606681aB295);
	
	address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
	address BUSD = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7;
	
    IPancakeSwapV2Router02 public immutable pancakeSwapV2Router;
    address public pancakeSwapV2Pair;
    
    bool inSwapAndLiquify;
    bool private swapping;
	
	bool public swapAndLiquifyEnabled = true;
	bool public initialDistributionFinished = false;
    bool public launchMode = true;
    bool public liquifyAll = false;
    bool public feesOnNormalTransfers = false;
	bool public P2PEnabled = false;
	
    uint256 public swapTokensAtAmount = 66666666 * 10**18;
	uint256 public maxSellTransactionAmount = 6666666666666 * 10 ** 18;
	uint256 public dailySellLimit = 100;
	uint256 public randNonce = 0;
	
	uint256 targetLiquidity = 50;
    uint256 targetLiquidityDenominator = 100;
	
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify( uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
	event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
	event ExcludeMaxWalletToken(address indexed account, bool isExcluded);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
	
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IPancakeSwapV2Router02 _pancakeSwapV2Router = IPancakeSwapV2Router02( 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pancakeSwapV2Pair = IPancakeSwapV2Factory(_pancakeSwapV2Router.factory()).createPair(address(this), _pancakeSwapV2Router.WETH());
		
        pancakeSwapV2Router = _pancakeSwapV2Router;
		
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
		_isExcludedFromFee[marketingWallet] = true;
		_isExcludedFromFee[referralRewardWallet] = true;
		
		_approve(address(referralRewardWallet), address(this), _tTotal);
		
		_setAutomatedMarketMakerPair(pancakeSwapV2Pair, true);
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }
	
    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }
	
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
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
        require(_isExcluded[account], "Account is already included");
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
    
    function setReflectionFeePercent(uint256 _reflectionFee) external onlyOwner() {
        reflectionFee = _reflectionFee;
    }

    function setMarketingFeePercent(uint256 _marketingFee) external onlyOwner() {
        marketingFee = _marketingFee;
    }
	
    function setLiquidityFeePercent(uint256 LiquidityFee) external onlyOwner() {
         liquidityFee = LiquidityFee;
    }
	
	function setRewardBonusPercent(uint256 RewardBonus) external onlyOwner() {
         rewardBonus = RewardBonus;
    }
	
	function setMarketingWallet(address payable _marketingWallet) external onlyOwner() {
        marketingWallet = _marketingWallet;
    }
	
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
	
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }
	
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
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
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
	
    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(reflectionFee).div(PERCENTS_DIVIDER);
    }
	
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(PERCENTS_DIVIDER);
    }
    
    function removeAllFee() private {
        if(reflectionFee == 0 && _liquidityFee == 0) return;
        
        _previousReflectionFee = reflectionFee;
        _previousLiquidityFee = _liquidityFee;
		
        reflectionFee = 0;
        _liquidityFee = 0;
    }
	
    function restoreAllFee() private {
        reflectionFee = _previousReflectionFee;
        _liquidityFee = _previousLiquidityFee;
    }
	
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private 
	{
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
		
		bool excludedAccount = _isExcludedFromFee[from] || _isExcludedFromFee[to];
		require(initialDistributionFinished || excludedAccount, "Trading not started");
		
		if(!automatedMarketMakerPairs[to] && !automatedMarketMakerPairs[from] && from != rewardWallet && from != owner() && from != referralRewardWallet)
		{
		    require(P2PEnabled, "Wallet to wallet transfer disabled");
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
            else if( (blkTime < tradeData[from].lastTradeTime + TwentyFourhours) && (( blkTime > tradeData[from].lastTradeTime)) )
			{
                require(tradeData[from].tradeAmount + amount <= dailyLimit, "ERR: Can't sell more than daily limit");
                tradeData[from].tradeAmount = tradeData[from].tradeAmount + amount;
            }
		}
		
		if(automatedMarketMakerPairs[to]) 
		{
            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= swapTokensAtAmount;
            if (!swapping && canSwap && swapAndLiquifyEnabled) {
                swapping = true;
				if(!liquifyAll)
				{
				    swapAndLiquify(contractTokenBalance);
				}
				else
				{
				    swapAndLiquify(balanceOf(address(this)));
				}
                swapping = false;
            }
        }
		
        bool takeFee = true;
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
		    _basicTokenTransfer(address(referralRewardWallet), address(to), rewardAmount, false);
			_basicTokenTransfer(address(referralRewardWallet), sponsor[to], rewardAmount, false);
		}
		
        _tokenTransfer(from,to,amount,takeFee);
    }
    
	function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap 
	{
	    uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
		
		uint256 fromLiquidityFee = contractTokenBalance.div(_liquidityFee).mul(dynamicLiquidityFee);
		uint256 OtherTokens = contractTokenBalance.sub(fromLiquidityFee);
		
		uint256 half = fromLiquidityFee.div(2);
		uint256 otherHalf = fromLiquidityFee.sub(half);
		
		uint256 initialBalance = address(this).balance;
		swapTokensForBNB(half.add(OtherTokens));
		uint256 newBalance = address(this).balance.sub(initialBalance);
		
		uint256 liquidityPart = newBalance.div(_liquidityFee).mul(dynamicLiquidityFee);
		        liquidityPart = liquidityPart.div(2);
		uint256 marketingPart = newBalance.sub(liquidityPart);
		
		if(marketingPart > 0)
		{
		   swapBNBForBUSD(marketingPart, marketingWallet);
		}
		
		if(liquidityPart > 0)
		{
		    addLiquidity(otherHalf, liquidityPart);
			emit SwapAndLiquify(half.add(OtherTokens), liquidityPart, otherHalf);
		}
    }
	
	function swapBNBForBUSD(uint256 amount, address receiver) private {
        address[] memory path = new address[](2);
        path[0] = pancakeSwapV2Router.WETH();
        path[1] = address(BUSD);
        pancakeSwapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(receiver),
            block.timestamp
        );
    }
	
    function swapTokensForBNB(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeSwapV2Router.WETH();

        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
		
        pancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(pancakeSwapV2Router), tokenAmount);
        pancakeSwapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(),
            block.timestamp
        );
    }
	
    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();
			
        if (_isExcluded[sender] && !_isExcluded[recipient]) 
		{
            _transferFromExcluded(sender, recipient, amount);
        } 
		else if (!_isExcluded[sender] && _isExcluded[recipient]) 
		{
            _transferToExcluded(sender, recipient, amount);
        } 
		else if (!_isExcluded[sender] && !_isExcluded[recipient]) 
		{
            _transferStandard(sender, recipient, amount);
        } 
		else if (_isExcluded[sender] && _isExcluded[recipient]) 
		{
            _transferBothExcluded(sender, recipient, amount);
        } 
		else 
		{
            _transferStandard(sender, recipient, amount);
        }
        if(!takeFee)
            restoreAllFee();
    }
	
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
	
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
	
	function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
	
	function getCirculatingSupply() public view returns (uint256) {
        return totalSupply().sub(balanceOf(address(DEAD))).sub(balanceOf(address(ZERO)));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256){
        uint256 liquidityBalance = 0;
        for(uint i = 0; i < markerPairs.length; i++)
		{
            liquidityBalance.add(balanceOf(markerPairs[i]).div(10 ** 18));
        }
        return accuracy.mul(liquidityBalance.mul(2)).div(getCirculatingSupply().div(10 ** 18));
    }
	
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool){
        return getLiquidityBacking(accuracy) > target;
    }
	
	function _basicTokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();
			
        _transferStandard(sender, recipient, amount);
		
        if(!takeFee)
            restoreAllFee();
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
            _basicTokenTransfer(from, addresses[i], tokens[i], false);
        }
    }
	
	function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
	    require(amount <= totalSupply(), "Amount cannot be over the total supply.");
  	    swapTokensAtAmount = amount;
  	}
	
	function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
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

	function setInitialDistributionFinished(bool value) external onlyOwner {
        require(initialDistributionFinished != value, "Not changed");
        initialDistributionFinished = value;
    }
	
	function setLaunchModeFinished() external onlyOwner {
        launchMode = false;
    }
	
	function setTargetLiquidity(uint256 target, uint256 accuracy) external onlyOwner {
        targetLiquidity = target;
        targetLiquidityDenominator = accuracy;
    }
	
	function setFeesOnNormalTransfers(bool enabled) external onlyOwner {
        require(feesOnNormalTransfers != enabled, "Not changed");
        feesOnNormalTransfers = enabled;
    }
	
	function setMaxSellTransaction(uint256 maxTxn) external onlyOwner {
	    require(maxTxn >= 6666666666666 * 10 ** 18 && maxTxn <= 33333333333330 * 10 ** 18, "Sell per transection between 1% to 5%");
        maxSellTransactionAmount = maxTxn;
    }
	
	function setMaxSellPerDay(uint256 sellLimit) external onlyOwner {
	    require(sellLimit >= 100 && sellLimit <= 500, "Daily sell limit between 1% to 5%");
        dailySellLimit = sellLimit;
    }
	
	function setLiquifyAll(bool enabled) external onlyOwner {
	    require(liquifyAll != enabled, "Not changed");
        liquifyAll = enabled;
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
	   
	   uint256 code = random(); 
	   referralCode[msg.sender] = code;
	   codeAddress[code] = msg.sender;
    }
	
	function addSponsor(uint256 sponsorCode) external {
	   require(sponsor[msg.sender] == address(0), "Sponsor already added");
       require(codeAddress[sponsorCode] != address(0), "Incorrect Code");
	   
	   address sponsorAddress = codeAddress[sponsorCode];
	   sponsor[msg.sender] = sponsorAddress; 
    }
	
	function random() internal returns(uint256){
	   randNonce++;
       return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, randNonce)));
    }
}