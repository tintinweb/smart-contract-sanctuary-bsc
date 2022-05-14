/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

/*
    MilkFarm Token - BSC BNB Token
    Developed by Kraitor Team <TG: kraitordev>
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

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
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IMilk {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function ContributeToTVL() external payable;
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

contract MilkFarmToken is IBEP20, Auth {
    using SafeMath for uint256;

    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address DEAD = 0x0000000000000000000000000000000000000000;
    address router_address = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    string constant _name = "MilkFarm Token";
    string constant _symbol = "MILKT";
    uint8 constant _decimals = 18;
    uint256 constant __totalSupply = 1000000000; 

    uint256 _totalSupply = __totalSupply * (10 ** _decimals);
    uint256 public _maxTxAmount = (_totalSupply * 5) / 100;
    uint256 public _maxWalletSize = (_totalSupply * 5) / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;

    mapping (address => bool) blacklisted_address;

    uint256 liquidityFee = 0;
    uint256 buybackFee = 0;
    uint256 marketingFee = 4;
    uint256 tvlFee = 4;
    uint256 totalFee = liquidityFee + buybackFee + marketingFee + tvlFee;
    uint256 feeDenominator = 100;

    uint8 _gasPriceMax = 100;
    uint256 _gasLimitMax = 100000000;

    address private marketingFeeReceiver = 0x83243E27B0177D03280bD7454fA672D4AEf43E06;
    address private buybackFeeReceiver = 0x83243E27B0177D03280bD7454fA672D4AEf43E06;
    address private buyTLVReceiver = 0x83243E27B0177D03280bD7454fA672D4AEf43E06;

    IDEXRouter public router;
    IMilk public milkCA;
    address public pair;

    uint256 public startBlock;
    bool public tradeOpened;

    bool public swapEnabled = true;
    uint256 public swapThreshold = _totalSupply / 1000 * 1; // 0.1%
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        router = IDEXRouter(router_address);
        milkCA = IMilk(buyTLVReceiver);
        pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;

        address _owner = owner;
        isFeeExempt[_owner] = true;
        isTxLimitExempt[_owner] = true;
        isFeeExempt[address(this)] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[pair] = true;
        authorize(router_address);

        _balances[_owner] = _totalSupply;
        emit Transfer(address(0), _owner, _totalSupply);
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        require(checkIfOpened() || isAuthorized(msg.sender), 'Trade still not opened');
        if(!checkIfOpened()){ return _basicTransfer(sender, recipient, amount); }

        require(isBlacklisted(sender) == false, 'Blacklisted');
        require(checkGasSettings() || isAuthorized(msg.sender), 'reverted because antibot');
        checkTxLimit(sender, amount);
        checkWalletLimit(recipient, amount);
        
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        if(shouldSwapBack()){ swapBack(); }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, amount) : amount;
        _balances[recipient] = _balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        if (sender != pair && sender != DEAD) {
            require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
        }
    }

    function checkWalletLimit(address recipient, uint256 amount) internal view {
        if (recipient != pair && recipient != DEAD) {
            require(isTxLimitExempt[recipient] || _balances[recipient] + amount <= _maxWalletSize, "Transfer amount exceeds the bag size.");
        }
    }

    function setGasAntibot(uint8 gasPriceMax, uint256 gasLimitMax) external authorized {
        require(gasPriceMax >= 7 && gasLimitMax >= 750000, 'invalid gas antibot settings');
        _gasPriceMax = gasPriceMax;
        _gasLimitMax = gasLimitMax;
    }

    function checkGasSettings() internal view returns (bool) {
        return tx.gasprice <= SafeMath.mul(_gasPriceMax, 1000000000) && gasleft() <= _gasLimitMax;
    }
    
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= swapThreshold;
    }

    function swapBack() internal swapping {

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 amountToLiquify = contractTokenBalance.mul(liquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = contractTokenBalance.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance.sub(balanceBefore);
        uint256 totalBNBFee = totalFee.sub(liquidityFee.div(2));
        uint256 amountBNBLiquidity = amountBNB.mul(liquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBbuyback = amountBNB.mul(buybackFee).div(totalBNBFee).div(2);
        uint256 amountBNBtlv = amountBNB.mul(tvlFee).div(totalBNBFee).div(2);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee).div(2);

        if(amountBNBMarketing > 0){
            (bool MarketingSuccess, /* bytes memory data */) = payable(marketingFeeReceiver).call{value: amountBNBMarketing, gas: 30000}("");
            require(MarketingSuccess, "receiver rejected BNB transfer");
        }

        if(amountBNBbuyback > 0){
            (bool BuyBackSuccess, /* bytes memory data */) = payable(buybackFeeReceiver).call{value: amountBNBbuyback, gas: 30000}("");
            require(BuyBackSuccess, "receiver rejected BNB transfer");
        }

        if(amountBNBtlv > 0){
            milkCA.ContributeToTVL{value: amountBNBtlv, gas: 30000}();
        }

        if(amountToLiquify > 0){
            addLiquidity(amountToLiquify, amountBNBLiquidity);
        }
    }

    function addLiquidity(uint256 amountToLiquify, uint256 BNBAmount) private {
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: BNBAmount}(
                address(this),
                amountToLiquify,
                0,
                0,
                marketingFeeReceiver,
                block.timestamp
            );
            emit AutoLiquify(BNBAmount, amountToLiquify);
        }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }

    function openTrade(uint256 deadblocks) external authorized {
        tradeOpened = true;
        startBlock = block.number + deadblocks;
        unauthorize(router_address);
        unauthorize(pair);
    }

    function closeTrade() external authorized {
        tradeOpened = false;
    }

    function checkIfOpened() internal view returns (bool) {
        return tradeOpened && block.number >= startBlock;
    }

    function blacklist_address(address adr, bool addRemove) external authorized { blacklisted_address[adr] = addRemove; }

    function isBlacklisted(address adr) public view returns (bool) { return blacklisted_address[adr]; }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxTxAmount = amount;
    }

    function setTxLimitPc(uint256 amount_pc) external authorized {
        uint256 amount_set = amount_pc.mul(_totalSupply).div(100);
        require(amount_set >= _totalSupply / 1000);
        _maxTxAmount = amount_set;
    }

    function setMaxWallet(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000 );
        _maxWalletSize = amount;
    }  

    function setMaxWalletPc(uint256 amount_pc) external authorized {
        uint256 amount_set = amount_pc.mul(_totalSupply).div(100);
        require(amount_set >= _totalSupply / 1000);
        _maxWalletSize = amount_set;
    }  

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _marketingFee, uint256 _tlvFee, uint256 _feeDenominator) external authorized {
        liquidityFee = _liquidityFee;
        buybackFee = _buybackFee;
        marketingFee = _marketingFee;
        tvlFee = _tlvFee;
        totalFee = _liquidityFee.add(_buybackFee).add(_marketingFee).add(tvlFee);
        feeDenominator = _feeDenominator;
    }

    function setFeeReceiver(address _marketingFeeReceiver, address _buybackFeeReceiver, address _tlvFeeReceiver) external authorized {
        marketingFeeReceiver = _marketingFeeReceiver;
        buybackFeeReceiver = _buybackFeeReceiver;
        buyTLVReceiver = _tlvFeeReceiver;
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external authorized {
        swapEnabled = _enabled;
        swapThreshold = _amount;
    }

    function manualSend() external authorized {
        uint256 contractETHBalance = address(this).balance;
        payable(marketingFeeReceiver).transfer(contractETHBalance);
    }

    function transferForeignToken(address _token) public authorized {
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IBEP20(_token).balanceOf(address(this));
        payable(marketingFeeReceiver).transfer(_contractBalance);
    }
        
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD));
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
}