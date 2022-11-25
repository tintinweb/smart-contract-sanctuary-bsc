/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/**
*/

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

abstract contract Auth {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not Owner"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

contract VagJuice is IBEP20, Auth {

    address private WETH;

    string private constant _name = "VagJuice";
    string private constant _symbol = "MOIST";
    uint8 private constant _decimals = 3;
    
    uint256 _totalSupply = 100000 * (10 ** _decimals);
    uint256 maxTx = 1000 * (10 ** _decimals);
    uint256 maxWallet = 2000 * (10 ** _decimals);

    uint256 public swapThreshold = 100 * (10 ** _decimals);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private cooldown;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    mapping (address => bool) private bots;
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isWltExempt;

    uint256 public launchedAt;
    address private liquidityPool = DEAD;

    uint256 public buyFee = 5;
    uint256 public sellFee = 5;

    uint256 public toLP = 10;
    uint256 public toMarketing = 40;

    bool public tripwire = true;

    IDEXRouter public router;
    address public pair;
    address public factory;
    address public marketingWlt = payable(0x6b34B08694F80c2556B311b4082AB26051E4C610);

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingOpen = false;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (address _owner) Auth(_owner) {
        router = IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
            
        WETH = router.WETH();
        
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        
        _allowances[address(this)][address(router)] = type(uint256).max;
        
        isFeeExempt[_owner] = true;
        isFeeExempt[marketingWlt] = true;          

        isTxLimitExempt[_owner] = true;
        isTxLimitExempt[pair] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[ZERO] = true;
        isTxLimitExempt[marketingWlt] = true;   

    	isWltExempt[_owner] = true;
    	isWltExempt[DEAD] = true;
    	isWltExempt[ZERO] = true;
    	isWltExempt[marketingWlt] = true;

        _balances[_owner] = _totalSupply;
    
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function setBots(address[] memory bots_) external onlyOwner {
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }

    function changeIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }
    
    function changeIsWltExempt(address holder, bool exempt) external onlyOwner {
        isWltExempt[holder] = exempt;
    }

    function changeIsTxLimitExempt(address holder, bool exempt) external onlyOwner {      
        isTxLimitExempt[holder] = exempt;
    }

    function launchAlpha() external onlyOwner {
    	require(tripwire);
    	tradingOpen = true;
    }

    function launchBeta() external onlyOwner {
    	require(tripwire);
    	tradingOpen = false;
    	tripwire = false;
    }

    function launchOmega() external onlyOwner {
	require(tripwire == false);
        launchedAt = block.number;
        tradingOpen = true;
    }

    function changeTotalFees(uint256 newBuyFee, uint256 newSellFee) external onlyOwner {
        require(buyFee <= 10);
        require(sellFee <= 10);

        buyFee = newBuyFee;
        sellFee = newSellFee;
    } 
    
    function changeFeeAllocation(uint256 newLpFee, uint256 newMarketingFee) external onlyOwner {
        toLP = newLpFee;
        toMarketing = newMarketingFee;
    }

    function changeTxLimit(uint256 newLimit) external onlyOwner {
	require(newLimit >= 100 * _decimals);
        maxTx = newLimit;
    }

    function changeWalletLimit(uint256 newLimit) external onlyOwner {
	require(newLimit >= 1000 * _decimals);
        maxWallet  = newLimit;
    }

    function changeMarketingWlt(address payable newMarketingWlt) external onlyOwner {
        marketingWlt = payable(newMarketingWlt);
    }

    function setLP(address newLP) external onlyOwner {
        liquidityPool = newLP;
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
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }
    function maxTransaction() external view returns (uint256) {return maxTx; }
    function maxWalletAmt() external view returns (uint256) {return maxWallet; }


    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
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
        if (sender != owner && recipient != owner) require(tradingOpen, "Trading not active");
        require(!bots[sender] && !bots[recipient], "Nope");

        if(inSwapAndLiquify){ return _basicTransfer(sender, recipient, amount); }

        require(amount <= maxTx || isTxLimitExempt[sender], "Exceeds Tx Limit");

        if(!isTxLimitExempt[recipient])
        {
            require(_balances[recipient] + amount <= maxWallet || isWltExempt[sender], "Exceeds Max Wallet");
        }

        if(msg.sender != pair && !inSwapAndLiquify && swapAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapBack(); }

        _balances[sender] = _balances[sender] - amount;
        
        uint256 finalAmount = !isFeeExempt[sender] && !isFeeExempt[recipient] ? takeFee(sender, recipient, amount) : amount;
        _balances[recipient] = _balances[recipient] + finalAmount;

        emit Transfer(sender, recipient, finalAmount);
        return true;
    }    

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }  
    
    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint256 feeApplicable = pair == recipient ? sellFee : buyFee;
        uint256 feeAmount = amount * feeApplicable / 100;

        _balances[address(this)] = _balances[address(this)] + feeAmount;
        emit Transfer(sender, address(this), feeAmount);

        return amount - feeAmount;
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
        uint256 tokensForLP = tokenBalance * toLP / 50 / 2;     
        uint256 amountToSwap = tokenBalance - tokensForLP;

        swapTokensForETH(amountToSwap);

        uint256 totalBNBBalance = address(this).balance;
        uint256 BNBForMarketing = totalBNBBalance * toMarketing / 50;
        uint256 BNBForLiquidity = totalBNBBalance * toLP / 50 / 2;
      
        if (totalBNBBalance > 0){
            payable(marketingWlt).transfer(BNBForMarketing);
        }
        
        if (tokensForLP > 0){
            addLiquidity(tokensForLP, BNBForLiquidity);
        }
    }

    function manualSwapBack() external onlyOwner {
        swapBack();
    }

    function clearStuckBNB() external onlyOwner {
        uint256 contractBNBBalance = address(this).balance;
        if(contractBNBBalance > 0){          
            payable(marketingWlt).transfer(contractBNBBalance);
        }
    }
}