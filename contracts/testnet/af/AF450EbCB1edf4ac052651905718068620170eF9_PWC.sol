// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
/**
 * SAFEMATH LIBRARY
 */
library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

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

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract BEP20Detailed is IBEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
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

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);
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

interface IDividendDistributor {
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function claimDividend(address rewardAddress) external payable;
}

contract DividendDistributor is IDividendDistributor, Auth {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IBEP20 BASE; 
    address WETH;
    IDEXRouter router;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => bool) public availableRewards;
    mapping (address => uint256) public totalRewardsDistributed;
    mapping (address => address) public pathRewards;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed; // to be shown in UI
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router, address _owner, address weth_) Auth(_owner) {
        router = _router != address(0)
        ? IDEXRouter(_router)
        : IDEXRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); //0x10ED43C718714eb63d5aA57B78B54704E256024E
        _token = msg.sender;
        WETH = weth_;
        BASE = IBEP20(weth_);
        BASE.approve(_router, 2**256 - 1);

    }

    function setReward(address _reward, bool status) public onlyOwner {

        availableRewards[_reward] = status;

    }

    function setPathReward(address _reward, address _path) public onlyOwner {

        pathRewards[_reward] = _path;

    }

    function changeRouterVersion(address _router)
        external
        onlyOwner
    {
        IDEXRouter _uniswapV2Router = IDEXRouter(_router);

        router = _uniswapV2Router;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder, address(BASE));
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 amount = msg.value;
        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function distributeDividend(address shareholder, address rewardAddress) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);

        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);

            //
            if(rewardAddress == _token){
                IBEP20(_token).transferFrom(address(this), msg.sender, amount);
            }
            if(rewardAddress == address(BASE)) {
                payable(shareholder).transfer(amount);
            } else {

                IBEP20 rewardToken = IBEP20(rewardAddress);

                uint256 beforeBalance = rewardToken.balanceOf(shareholder);

                if(pathRewards[rewardAddress] == address(0)) {
                    address[] memory path = new address[](2);
                    path[0] = address(BASE);
                    path[1] = rewardAddress;

                    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
                        0,
                        path,
                        shareholder,
                        block.timestamp
                    );                 
                } else {
                    address[] memory path = new address[](3);
                    path[0] = address(BASE);
                    path[1] = pathRewards[rewardAddress];
                    path[2] = rewardAddress;

                    router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
                        0,
                        path,
                        shareholder,
                        block.timestamp
                    );             
  
                }

                uint256 afterBalance = rewardToken.balanceOf(shareholder);
    
                totalRewardsDistributed[rewardAddress] = totalRewardsDistributed[rewardAddress].add(afterBalance.sub(beforeBalance));  

            }

            //

            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function makeApprove(address token, address spender) public onlyOwner {

        IBEP20(token).approve(spender, 2**256 - 1);

    }

    function claimDividend(address rewardAddress) external payable override {

        require(availableRewards[rewardAddress], "This reward is not available");

        distributeDividend(msg.sender, rewardAddress);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract PWC is IBEP20, BEP20Detailed, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;
    address public WETH;
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "Prime whiterock company";
    string constant _symbol = "PWC";
    uint8 constant _decimals = 9;

    uint256 _totalSupply = 10000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.div(50); // 2%
    uint256 public _maxWallet = _totalSupply.div(50); // 2%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public _isFree;

    uint256 liquidityFee = 50;
    uint256 burnFee = 25;
    uint256 rewardFee = 25;
    uint256 totalFee = 100;

    uint256 liquidityFeeForSell = 50;
    uint256 burnFeeForSell = 25;
    uint256 rewardFeeForSell = 25;
    uint256 totalFeeForSell = 100;

    uint256 liquidityFeeForBuy = 0;
    uint256 burnFeeForBuy = 25;
    uint256 rewardFeeForBuy = 25;
    uint256 totalFeeForBuy = 50;
    
    uint256 feeDenominator = 1000;

    address public autoLiquidityFeeReceiver;
    address public rewardFeeReceiver;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    uint256 buybackMultiplierNumerator = 200;
    uint256 buybackMultiplierDenominator = 100;
    uint256 buybackMultiplierTriggeredAt;
    uint256 buybackMultiplierLength = 30 minutes;

    bool public autoBuybackEnabled = false;
    mapping (address => bool) buyBacker;
    uint256 autoBuybackCap;
    uint256 autoBuybackAccumulator;
    uint256 autoBuybackAmount;
    uint256 autoBuybackBlockPeriod;
    uint256 autoBuybackBlockLast;

    DividendDistributor distributor;
    address public distributorAddress;

    bool public _autoAddLiquidity;
    uint256 public _lastAddLiquidityTime;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor() BEP20Detailed("Prime whiterock company", "PWC", uint8(_decimals)) Auth(msg.sender) {
        address _router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3; //0x10ED43C718714eb63d5aA57B78B54704E256024E
        router = IDEXRouter(_router);
        WETH = router.WETH();
        pair = IDEXFactory(router.factory()).createPair(WETH, address(this));
        _allowances[address(this)][_router] = _totalSupply;
        distributor = new DividendDistributor(_router, msg.sender, WETH);
        distributorAddress = address(distributor);

        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[_router] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
        buyBacker[msg.sender] = true;
        _autoAddLiquidity = true;
        _isFree[msg.sender] = true;


        autoLiquidityFeeReceiver = 0x5562640B953b6c2f79a655E930aFa68b2a65C627;
        rewardFeeReceiver = msg.sender; 

        approve(_router, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    modifier onlyBuybacker() { require(buyBacker[msg.sender] == true, ""); _; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] != _totalSupply){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        // Max  tx check
        address routerAddress = address(router);
        bool isBuy=sender== pair|| sender == routerAddress;
        bool isSell=recipient== pair|| recipient == routerAddress;

        bool isBurn = recipient==address(0)||recipient==DEAD;
        if(isBurn){
            if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]-amount) {} catch {} }
            return _burn(sender, amount);
        }
        
        // Max wallet check excluding pair and router
        if (!isSell){
            if(!_isFree[recipient])
            require((_balances[recipient] + amount) < _maxWallet, "Max wallet has been triggered");
            if(!isBuy){
                if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]-amount) {} catch {} }
                if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]+amount) {} catch {} }
                return _basicTransfer(sender, recipient, amount);
            }
        }
        
        // No swapping on buy and tx
        if (isSell) {
            setAsSellFee();
            if(shouldAddLiquidity()){ 
                addLiquidity(); 
                }
            if(shouldAutoBuyback()){
                 triggerAutoBuyback(); 
                 }
        }

        if (isBuy) {
            setAsBuyFee();
            if(shouldAddLiquidity()){ addLiquidity(); }
            if(shouldAutoBuyback()){ triggerAutoBuyback(); }
        }

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = takeFee(sender, amount);

        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function claimReward(address rewardAddress) external payable{
        distributor.claimDividend(rewardAddress);
    }

    function setAsSellFee() internal {
        liquidityFee = liquidityFeeForSell;
        burnFee = burnFeeForSell;
        rewardFee = rewardFeeForSell;
        totalFee = totalFeeForSell;  
    }

    function setAsBuyFee() internal {
        liquidityFee = liquidityFeeForBuy;
        burnFee = burnFeeForBuy;
        rewardFee = rewardFeeForBuy;
        totalFee = totalFeeForBuy;    
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function getMultipliedFee() public view returns (uint256) {
        return totalFee;
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {

        uint256 feeAmount = amount.mul(totalFee).div(feeDenominator);

        _balances[rewardFeeReceiver] = _balances[rewardFeeReceiver].add(
            amount.mul(rewardFee).div(feeDenominator)
        );
        _balances[ZERO] = _balances[ZERO].add(
            amount.mul(burnFee).div(feeDenominator)
        );
        _balances[autoLiquidityFeeReceiver] = _balances[autoLiquidityFeeReceiver].add(
            amount.mul(liquidityFee).div(feeDenominator)
        );
        
        uint256 amountETHReflection = _balances[rewardFeeReceiver];
        distributor.deposit{value: amountETHReflection}();

        emit Transfer(sender, address(this), feeAmount);
        return amount.sub(feeAmount);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return 
        _autoAddLiquidity
        && msg.sender != pair
        && !inSwap
        && block.timestamp >= (_lastAddLiquidityTime + 2 days);

    }

    function addLiquidity() public swapping {
        uint256 autoLiquidityAmount = _balances[autoLiquidityFeeReceiver];
        _balances[address(this)] = _balances[address(this)].add(autoLiquidityAmount);
        _balances[autoLiquidityFeeReceiver] = 0;

        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;
        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);
            
        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityFeeReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function shouldAutoBuyback() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && autoBuybackEnabled
        && autoBuybackBlockLast + autoBuybackBlockPeriod <= block.number // After N blocks from last buyback
        && address(this).balance >= autoBuybackAmount;
    }

    function triggerZeusBuyback(uint256 amount, bool triggerBuybackMultiplier) external authorized {
        buyTokens(amount, DEAD);
        if(triggerBuybackMultiplier){
            buybackMultiplierTriggeredAt = block.timestamp;
            emit BuybackMultiplierActive(buybackMultiplierLength);
        }
    }

    function clearBuybackMultiplier() external authorized {
        buybackMultiplierTriggeredAt = 0;
    }

    function triggerAutoBuyback() internal {
        buyTokens(autoBuybackAmount, DEAD);
        autoBuybackBlockLast = block.number;
        autoBuybackAccumulator = autoBuybackAccumulator.add(autoBuybackAmount);
        if(autoBuybackAccumulator > autoBuybackCap){ autoBuybackEnabled = false; }
    }

    function buyTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(this);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
    }
    
    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if(_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function setAutoBuybackSettings(bool _enabled, uint256 _cap, uint256 _amount, uint256 _period) external authorized {
        autoBuybackEnabled = _enabled;
        autoBuybackCap = _cap;
        autoBuybackAccumulator = 0;
        autoBuybackAmount = _amount;
        autoBuybackBlockPeriod = _period;
        autoBuybackBlockLast = block.number;
    }

    function setBuybackMultiplierSettings(uint256 numerator, uint256 denominator, uint256 length) external authorized {
        require(numerator / denominator <= 2 && numerator > denominator);
        buybackMultiplierNumerator = numerator;
        buybackMultiplierDenominator = denominator;
        buybackMultiplierLength = length;
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public authorized {
        require(launchedAt == 0, "Already launched boi");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }
    
    function setMaxWallet(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxWallet = amount;
    }

    function setTxLimit(uint256 amount) external authorized {
        _maxTxAmount = amount;
    }

    function setIsDividendExempt(address holder, bool exempt) external authorized {
        require(holder != address(this) && holder != pair);
        isDividendExempt[holder] = exempt;
        if(exempt){
            distributor.setShare(holder, 0);
        }else{
            distributor.setShare(holder, _balances[holder]);
        }
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setFree(address holder) public onlyOwner {
        _isFree[holder] = true;
    }
    
    function unSetFree(address holder) public onlyOwner {
        _isFree[holder] = false;
    }
    
    function checkFree(address holder) public view onlyOwner returns(bool){
        return _isFree[holder];
    }

    function updateBuyfees(uint256 _liquidityFee, uint256 _burnFee, uint256 _rewardFee, uint256 _feeDenominator) external authorized {
        liquidityFeeForBuy = _liquidityFee;
        burnFeeForBuy = _burnFee;
        rewardFeeForBuy = _rewardFee;
        totalFeeForBuy = _liquidityFee.add(_burnFee).add(_rewardFee);
        feeDenominator = _feeDenominator;
    }

    function updateSellFees(uint256 _liquidityFee, uint256 _burnFee, uint256 _rewardFee, uint256 _feeDenominator) external authorized {
        liquidityFeeForSell = _liquidityFee;
        burnFeeForSell = _burnFee;
        rewardFeeForSell = _rewardFee;
        totalFeeForSell = _liquidityFee.add(_burnFee).add(_rewardFee);
        feeDenominator = _feeDenominator;
    }

    function setFeeReceivers(address _autoLiquidityFeeReceiver) external authorized {
        autoLiquidityFeeReceiver = _autoLiquidityFeeReceiver;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    
    function changeRouterVersion(address _router)
        external
        onlyOwner
        returns (address _pair)
    {
        IDEXRouter _uniswapV2Router = IDEXRouter(_router);

        _pair = IDEXFactory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        if (_pair == address(0)) {
            // Pair doesn't exist
            _pair = IDEXFactory(_uniswapV2Router.factory()).createPair(
                address(this),
                _uniswapV2Router.WETH()
            );
        }
        pair = _pair;

        // Set the router of the contract variables
        router = _uniswapV2Router;
        _allowances[address(this)][address(router)] = _totalSupply;
    }


    function _burn(address account, uint256 amount) internal returns(bool) {
        require(account != address(0),"account is zero address");
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        return true;
    }


    event AutoLiquify(uint256 amountETH, uint256 amountBOG);
    event BuybackMultiplierActive(uint256 duration);
}