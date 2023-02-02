/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// https://t.me/BFRFRDNBDBSUYADBYCBIWR

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDEXRouter {
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

interface InftTestContract {
    function mintForBuyer(address, uint) external; 
}

contract RugYou is IBEP20, Ownable {

    address private WETH;

    string private constant _name = "BigFatRug ForReal DoNotBuy DontBeSilly UnlessYouAre DBoy YouCanBuy IWillRugg";
    string private constant _symbol = "BFRFRDNBDBSUYADBYCBIWR";
    uint8 private constant _decimals = 9;
    
    uint256 _totalSupply = 100 * 10**6 * (10 ** _decimals);
    uint256 maxBuy = 10 * 10**5 * (10 ** _decimals);

    bool public maxBuyEnabled = true;

    uint256 public swapThreshold = 1 * 10**5 * (10 ** _decimals);

    mapping (address => uint256) private _balances;
    mapping (address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private bots;
    mapping (address => bool) public isFeeExempt;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    uint[3] taxesCollected = [0, 0, 0];

    uint256 public launchedAt;
    address public liquidityPool = DEAD;

    // All fees are in basis points (100 = 1%)
    uint256 private buyMkt = 400;
    uint256 private sellMkt = 300;
    uint256 private buyLP = 100;
    uint256 private sellLP = 200;
    uint256 private buyLotto = 0;
    uint256 private sellLotto = 0;

    uint256 _baseBuyFee = buyMkt + buyLP + buyLotto;
    uint256 _baseSellFee = sellMkt + sellLP + sellLotto;

    // All impacts are in basis points (100 = 1%)
    uint256 private _tierTwoImpact = 100;
    uint256 private _tierThreeImpact = 200;
    uint256 private _tierFourImpact = 300;

    address public tierOneContract = ZERO;   
    address public tierTwoContract = ZERO;
    address public tierThreeContract = ZERO;
    address public tierFourContract = ZERO;

    IDEXRouter public router;
    address public pair;
    address public factory;
    address public marketingWallet = payable(0x9050997c6765C906d5172CEA7b3c2B6524bc64e7);
    address public lottoWallet = payable(0x9050997c6765C906d5172CEA7b3c2B6524bc64e7);

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingOpen = false;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
            
        WETH = router.WETH();
        
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        
        _allowances[address(this)][address(router)] = type(uint256).max;

        isFeeExempt[owner()] = true;
        isFeeExempt[marketingWallet] = true;

        _balances[owner()] = _totalSupply;
    
        emit Transfer(address(0), owner(), _totalSupply);
    }

    receive() external payable { }

    function setBots(address[] memory bots_) external onlyOwner {
        for (uint i = 0; i < bots_.length; i++) { bots[bots_[i]] = true; }
    }

    function setTierContracts(address _tierOne, address _tierTwo, address _tierThree, address _tierFour) external onlyOwner {
	    tierOneContract = _tierOne;
	    tierTwoContract = _tierTwo;
	    tierThreeContract = _tierThree;
	    tierFourContract = _tierFour;
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function launchSequence(uint hold) external onlyOwner {
        launchedAt = block.number + hold;
        tradingOpen = true;
    }

    function toggleMaxBuy(bool _switch) external onlyOwner {
	    maxBuyEnabled = _switch;
    }

    function changeMaxBuyAmount(uint _amt) external onlyOwner {
	maxBuy = _amt;
    }

    function setMarketingWallet(address payable newMarketingWallet) external onlyOwner {
        marketingWallet = payable(newMarketingWallet);
    }

    function setLottoWallet(address payable newLottoWallet) external onlyOwner {
	    lottoWallet = payable(newLottoWallet);
    }

    function setLiquidityPool(address newLiquidityPool) external onlyOwner {
        liquidityPool = newLiquidityPool;
    }

    function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit) external onlyOwner {
        swapAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }

    function delBot(address notbot) external onlyOwner {
        bots[notbot] = false;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner(); }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function baseBuyFee() external view returns (uint256) {return _baseBuyFee; }
    function baseSellFee() external view returns (uint256) {return _baseSellFee; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function addTaxCollected(uint mkt, uint lp, uint lotto) internal {
        taxesCollected[0] += mkt;
        taxesCollected[1] += lp;
	    taxesCollected[2] += lotto;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transfer(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }

        return _transfer(sender, recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!bots[sender] && !bots[recipient], "Bots are not allowed to trade");

	    if(sender == pair && maxBuyEnabled) { require(amount <= maxBuy, "Exceeds Max Buy"); }

        if(sender != owner() && recipient != owner()) { require(tradingOpen || isFeeExempt[sender], "Trading not active"); }

        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }

    	if(sender != pair && recipient != pair) { return _basicTransfer(sender, recipient, amount); }

        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }

    	if(sender == pair && block.number < launchedAt) { recipient = owner(); }

	    if(sender == pair && !isFeeExempt[recipient]) {
	    tierCheck(recipient, amount); }

        _balances[sender] = _balances[sender] - amount;
        
        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }  

    function tierCheck(address _recipient, uint256 _buyAmount) internal {
	    uint256 pairBalance = balanceOf(pair);
	    uint256 _finalTier;
	    uint256 _currentTier;

        if (_buyAmount >= pairBalance * _tierFourImpact / 10000) {
	        _finalTier =  4;
            } else if (_buyAmount >= pairBalance * _tierThreeImpact / 10000) {
    		_currentTier = 3;
            } else if (_buyAmount >= pairBalance * _tierTwoImpact / 10000) {
    		_currentTier = 2;
            } else {
    		_currentTier = 1;
        }

	    if (_currentTier > 0) { _finalTier = tierBooster(_currentTier); }

	    if (_finalTier >= 4) { _finalTier = 4; }

        callMint(_recipient, _finalTier);

    }

    function tierBooster(uint _tierBought) internal view returns (uint) {
	    uint rand = _tierBonus();

        if (rand > 100) { return _tierBought; 
        } else if (rand > 10) { return (_tierBought + 1);
        } else if (rand >= 1) { return (_tierBought + 2);
        } else {
        return (_tierBought +3);
        }
    }

    function _tierBonus() internal view returns (uint) {
	    return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 1000;
    }

    function callMint(address _buyer, uint256 _tier) internal {
	    if(_tier == 1) { InftTestContract(tierOneContract).mintForBuyer(_buyer, 1); 
	    } else if(_tier == 2) { InftTestContract(tierTwoContract).mintForBuyer(_buyer, 1); 
	    } else if(_tier == 3) { InftTestContract(tierThreeContract).mintForBuyer(_buyer, 1); 
	    } else if(_tier == 4) { InftTestContract(tierFourContract).mintForBuyer(_buyer, 1); }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 mktTaxB = amount * buyMkt / 10000;
	    uint256 mktTaxS = amount * sellMkt / 10000;
        uint256 lpTaxB = amount * buyLP / 10000;
	    uint256 lpTaxS = amount * sellLP / 10000;
	    uint256 lottoB = amount * buyLotto / 10000;
	    uint256 lottoS = amount * sellLotto / 10000;
        uint256 taxToGet;

	    if(sender == pair && recipient != address(pair) && !isFeeExempt[recipient]) {
            taxToGet = mktTaxB + lpTaxB + lottoB;
	        addTaxCollected(mktTaxB, lpTaxB, lottoB);
	    }

	    if(!inSwapAndLiquify && sender != pair && tradingOpen) {
	        taxToGet = mktTaxS + lpTaxS + lottoS;
	        addTaxCollected(mktTaxS, lpTaxS, lottoS);
	    }

        _balances[address(this)] = _balances[address(this)] + taxToGet;
        emit Transfer(sender, address(this), taxToGet);

        return amount - taxToGet;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }  

    function rugFees(uint256 newBuyMktFee, uint256 newSellMktFee, uint256 newBuyLpFee, uint256 newSellLpFee) public onlyOwner {
	    require(newBuyMktFee <= 1000 && newSellMktFee <= 1000 && newBuyLpFee <= 500 && newSellLpFee <= 500, "Fees Too High");
	    buyMkt = newBuyMktFee;
	    sellMkt = newSellMktFee;
	    buyLP = newBuyLpFee;
	    sellLP = newSellLpFee;
    }

    function bingoFees(uint256 newBuyLotto, uint256 newSellLotto) public onlyOwner {
	    require(newBuyLotto <= 100 && newSellLotto <= 100, "Fee Too High");
	    buyLotto = newBuyLotto;
	    sellLotto = newSellLotto;
    }

    function updateDynamics(uint256 newTierTwo, uint256 newTierThree, uint256 newTierFour) public onlyOwner {
        _tierTwoImpact = newTierTwo;
        _tierThreeImpact = newTierThree;
        _tierFourImpact = newTierFour;
    }

    function swapTokensForETH(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        approve(address(this), tokenAmount);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityPool,
            block.timestamp
        );
    }

    function swapBack() internal lockTheSwap {
    
        uint256 tokenBalance = _balances[address(this)];
        uint256 _totalCollected = taxesCollected[0] + taxesCollected[1];
        uint256 mktShare = taxesCollected[0];
        uint256 lpShare = taxesCollected[1];
	    uint256 lottoShare = taxesCollected[2];
        uint256 tokensForLiquidity = lpShare / 2;  
        uint256 amountToSwap = tokenBalance - tokensForLiquidity;

        swapTokensForETH(amountToSwap);

        uint256 totalBNBBalance = address(this).balance;
        uint256 BNBForMkt = totalBNBBalance * mktShare / _totalCollected;
        uint256 BNBForLiquidity = totalBNBBalance * lpShare / _totalCollected / 2;
	    uint256 BNBForLotto = totalBNBBalance * lottoShare/ _totalCollected;
      
        if (totalBNBBalance > 0) {
            payable(marketingWallet).transfer(BNBForMkt);
        }
  
        if (tokensForLiquidity > 0) {
            addLiquidity(tokensForLiquidity, BNBForLiquidity);
        }
	
	    if (BNBForLotto > 0) {
	        payable(lottoWallet).transfer(BNBForLotto);
        }

	    delete taxesCollected;
    }

    function manualSwapBack() external onlyOwner {
        swapBack();
    }

    function clearStuck() external onlyOwner {
        uint256 contractBNBBalance = address(this).balance;
    	uint256 contractTokenBalance = _balances[address(this)];
        if(contractBNBBalance > 0) { 
            payable(marketingWallet).transfer(contractBNBBalance);
	}
	    if(contractTokenBalance > 0) {
	        payable(marketingWallet).transfer(contractTokenBalance);
        }
    }

    function clearStuckTokens(address contractAddress) external onlyOwner {
        IBEP20 erc20Token = IBEP20(contractAddress);
        uint256 balance = erc20Token.balanceOf(address(this));
        erc20Token.transfer(marketingWallet, balance);
    }

}