/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

//Liquidity will be locked 
//Social and telegram will be available ,temporary social: https://t.me/BurnBSC
//First everBurn Fork in BSC on steroid

// SPDX-License-Identifier: MIT

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
        uint amountBNBMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountBNB, uint liquidity);

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
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;// excluded dividend
        uint256 totalRealised;
    }

    IBEP20 Token1 = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD token
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IDEXRouter router;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //PanCake Router

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;// to be shown in UI
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;
    uint256 public Token1Decimals = 6;
    uint256 public minPeriod = 30 minutes;
    uint256 public minDistribution = 1 / 100000 * (10 ** 18);

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

    constructor (address _router) {
        router = _router != address(0) ? IDEXRouter(_router) : IDEXRouter(routerAddress);
        _token = msg.sender;
    }

    function getMinPeriod() external view  returns (uint256) {
        return minPeriod ;
    }


    function GetDistribution() external view  returns (uint256) {
        return minDistribution ;
    }
    
     
    function setPrintToken(address _printToken, uint256 _printTokenDecimals)
        external
        onlyToken
    {
        Token1 = IBEP20( _printToken);
        Token1Decimals = _printTokenDecimals;
        minDistribution = 10 * (10 ** Token1Decimals);
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
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
        uint256 balanceBefore =Token1.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(Token1);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = Token1.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
        && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            Token1.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function claimDividend() external {
        distributeDividend(msg.sender);
    }
/*
returns the  unpaid earnings
*/
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

contract BSCBURN is IBEP20, Auth {
    using SafeMath for uint256;

    uint256 public constant MASK = type(uint128).max;

    address public Token1 = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD token
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //WBNB
    
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;
    address DEAD_NON_CHECKSUM = 0x000000000000000000000000000000000000dEaD;

    address DexPoolAddress1 = 0x0000000000000000000000000000000000000000;
    address DexPoolAddress2 = 0x0000000000000000000000000000000000000000;

    address public DexPair = 0x0000000000000000000000000000000000000000;
    
    address ROUTERADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //pancake router

    string constant _name = "BSCBURN";
    string constant _symbol = "bBURN";
    uint8 constant _decimals = 8;

    uint256 public _totalSupply = 1_000_000_000_000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply.div(1000); // 1% 
    uint256 public _maxWallet = _totalSupply.div(500); // 2%

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) isFeeExempt;
    mapping (address => bool) isTxLimitExempt;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public _isFree;
  
    bool public TransferEnabled = true;
 
    //Sell taxes
    uint256  public burnFee = 200;
    uint256  public SellReflectionFee = 500;
    uint256  public marketingFee = 400; // Marketing 2% + treasury 1% goes to same wallet for now. As project grows we will setup a multisig treasury wallet.
    uint256  public liquidityFee = 500;
    uint256  public totalFee = 1400; // Burn not included

    //BUY Taxes
    uint256  public burnFeeBuy = 200;
    uint256  public BuyReflectionFee = 0;
    uint256  public BuyMarketingFee = 300; // Marketing 2% + treasury 1% goes to same wallet for now. As project grows we will setup a multisig treasury wallet.
    uint256  public BuyliquidityFee = 500;
    uint256  public totalBuyFee = 800; // Burn not included
   
   //Transfer Taxes
    uint256  public TransferReflectionFee = 0;
    uint256  public TransferBurnFee = 0;
    uint256  public TransferMarketingFee = 0;
    uint256  public TransferLiquidityFee = 0;
    uint256  public totalTransferFee = 0; // Burn not included

    uint256  feeDenominator = 10000;

    address public autoLiquidityReceiver=0xDEAD1116e2679Ce4d5EcC218abA77d167D2b8794;
    address public marketingFeeReceiver=0xDEAD1116e2679Ce4d5EcC218abA77d167D2b8794; // Marketing 2% + treasury 1% goes to same wallet for now. As project grows we will setup a multisig treasury wallet.


    uint256 targetLiquidity = 10;
    uint256 targetLiquidityDenominator = 100;

    IDEXRouter public router;
    address public pair;

    uint256 public launchedAt;
    uint256 public launchedAtTimestamp;

    DividendDistributor distributor;
    address public distributorAddress;

    uint256 distributorGas = 600000;

    bool public swapEnabled = true;

    uint256 public swapPercentMax = 100; // % of amount swap
    uint256 public swapThresholdMax = _totalSupply / 50; // 2%

  
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }

    constructor () Auth(msg.sender) {
        
        router = IDEXRouter(ROUTERADDR);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = _totalSupply;
        distributor = new DividendDistributor(address(router));
        distributorAddress = address(distributor);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;
        isDividendExempt[pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[DEAD] = true;
      

        autoLiquidityReceiver = msg.sender;

        approve(ROUTERADDR, _totalSupply);
        approve(address(pair), _totalSupply);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        
       require( TransferEnabled || isAuthorized(msg.sender) || isAuthorized(sender),"Transfers are Disabled");
        
        uint256 currentFeeAmount = 0;
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }
         
        // Max  tx check
        address routerAddress = ROUTERADDR;
        //bool isBuy=sender== pair|| sender == routerAddress;
        bool isSell=recipient== pair|| recipient == routerAddress ||  recipient == DexPoolAddress1 ||  recipient == DexPoolAddress2;
        
        checkTxLimit(sender, amount);
        
        // Max wallet check excluding pair and router
        if (!isSell && !_isFree[recipient]){
            require((_balances[recipient] + amount) < _maxWallet, "Max wallet has been triggered");
        }
                
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

        uint256 amountReceived = shouldTakeFee(sender) ? takeFee(sender, recipient, amount) : amount;
        currentFeeAmount = amount - amountReceived;
        // No swapping on buy and tx
        if (isSell) {
            if(currentFeeAmount > 0){ if(shouldSwapBack(currentFeeAmount)){ swapBack(currentFeeAmount); }}
        }
      
        _balances[recipient] = _balances[recipient].add(amountReceived);

        if(!isDividendExempt[sender]){ try distributor.setShare(sender, _balances[sender]) {} catch {} }
        if(!isDividendExempt[recipient]){ try distributor.setShare(recipient, _balances[recipient]) {} catch {} }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
//        emit Transfer(sender, recipient, amount);
        return true;
    }

    function checkTxLimit(address sender, uint256 amount) internal view {
        require(amount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }

    function shouldTakeFee(address sender) internal view returns (bool) {
        return !isFeeExempt[sender];
    }

    function getTotalFee(bool selling) public view returns (uint256) {
        if(launchedAt + 1 >= block.number){ return totalFee; }
        if(selling){ return totalFee; }
        return totalFee;
    }



    function takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount;
        
        uint256 burnAmountSell = amount.mul(burnFee).div(feeDenominator);
        uint256 burnAmountBuy = amount.mul(burnFeeBuy).div(feeDenominator);
        uint256 burnAmountTrans = amount.mul(TransferBurnFee).div(feeDenominator);
    
        bool isSell = receiver == DexPoolAddress1 || receiver == DexPoolAddress2 || receiver == pair || receiver == ROUTERADDR ;
        bool isBuy = sender == DexPoolAddress1 || sender == DexPoolAddress2 || sender == pair || sender == ROUTERADDR ; 

        setFindDexPair(sender);  //debug

        if (isBuy){  //BUY TAX

            feeAmount = amount.mul(totalBuyFee).div(feeDenominator);
                
            _balances[DEAD] = _balances[DEAD].add(burnAmountBuy);
            emit Transfer(sender, DEAD, burnAmountBuy);

            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);


            return amount.sub(feeAmount).sub(burnAmountBuy);
        
        } 
        else if (isSell){  //SELL TAX
            feeAmount = amount.mul(totalFee).div(feeDenominator);
            
            _balances[DEAD] = _balances[DEAD].add(burnAmountSell);
            emit Transfer(sender, DEAD, burnAmountSell);

            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
            
            
            return amount.sub(feeAmount).sub(burnAmountSell); 
        
        }
        else {  //Transfer TAX - 
            feeAmount = amount.mul(totalTransferFee).div(feeDenominator);

            _balances[DEAD] = _balances[DEAD].add(burnAmountTrans);
            emit Transfer(sender, DEAD, burnAmountTrans);


            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);

                   
            return amount.sub(feeAmount).sub(burnAmountTrans);
        }
    

    }

    function shouldSwapBack(uint256 _amount) internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _balances[address(this)] >= _amount;
    }

    function swapBack(uint256 _amount) internal swapping {
        uint256 swapAmount = getSwapAmount(_amount);

        uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityFee;
        uint256 amountToLiquify = swapAmount.mul(dynamicLiquidityFee).div(totalFee).div(2);
        uint256 amountToSwap = swapAmount.sub(amountToLiquify);

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

        uint256 totalBNBFee = totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB.mul(dynamicLiquidityFee).div(totalBNBFee).div(2);
        uint256 amountBNBReflection = amountBNB.mul(SellReflectionFee).div(totalBNBFee);
        uint256 amountBNBMarketing = amountBNB.mul(marketingFee).div(totalBNBFee);

        try distributor.deposit{value: amountBNBReflection}() {} catch {}
        payable(marketingFeeReceiver).transfer(amountBNBMarketing);
   
        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
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
    
    function Sweep() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function launched() internal view returns (bool) {
        return launchedAt != 0;
    }

    function launch() public authorized {
        require(launchedAt == 0, "Already launched Ser");
        launchedAt = block.number;
        launchedAtTimestamp = block.timestamp;
    }
    
    function setMaxWallet(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
        _maxWallet = amount;
    }

    function setTxLimit(uint256 amount) external authorized {
        require(amount >= _totalSupply / 1000);
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

    function setIsFeeExempt(address holder, bool exempt) external authorized {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt) external authorized {
        isTxLimitExempt[holder] = exempt;
    }
    
    function setFree(address holder) public onlyOwner {
        _isFree[holder] = true;
    }

    

    function setTransferEnabled(bool _enabled) public onlyOwner {
        TransferEnabled = _enabled;
    }
    
    function unSetFree(address holder) public onlyOwner {
        _isFree[holder] = false;
    }
    
    function checkFree(address holder) public view onlyOwner returns(bool){
        return _isFree[holder];
    }

    function setSellFees(
      
        uint256 _burnFee,
        uint256 _SellReflectionFee,
        uint256 _marketingFee,
        uint256 _liquidityFee

    ) external authorized {
        burnFee = _burnFee;
        SellReflectionFee = _SellReflectionFee;
        marketingFee = _marketingFee;
        liquidityFee = _liquidityFee;
        totalFee = _liquidityFee.add(_SellReflectionFee).add(_marketingFee);
        require(totalFee < feeDenominator / 3);

    }


    function setBuyFees(
        
        uint256 _burnFeeBuy,
        uint256 _BuyReflectionFee,
        uint256 _BuyMarketingFee,
        uint256 _BuyliquidityFee

    ) external authorized {
        burnFeeBuy = _burnFeeBuy;
        BuyReflectionFee = _BuyReflectionFee;
        BuyMarketingFee = _BuyMarketingFee;
        BuyliquidityFee =_BuyliquidityFee;
        totalBuyFee = _BuyliquidityFee.add(_BuyReflectionFee).add(_BuyMarketingFee);
        require(totalBuyFee < feeDenominator / 3);
        
    }
    function setTransFees(
      
        uint256 _TransferReflectionFee,
        uint256 _TransferBurnFee,
        uint256 _TransferMarketingFee,
        uint256 _TransferLiquidityFee

    ) external authorized {

        TransferReflectionFee = _TransferReflectionFee;
        TransferBurnFee = _TransferBurnFee;
        TransferMarketingFee = _TransferMarketingFee;
        TransferLiquidityFee = _TransferLiquidityFee;
        totalTransferFee = _TransferLiquidityFee.add(_TransferReflectionFee).add(_TransferMarketingFee);
        require(totalTransferFee < feeDenominator / 3);
  }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingFeeReceiver = _marketingFeeReceiver;
    }

    function setSwapBackSettings(
        bool _enabled,
        uint256 _maxPercTransfer,
        uint256 _max
    ) external authorized {
        swapEnabled = _enabled;
        swapPercentMax = _maxPercTransfer;
        swapThresholdMax = _max;
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external authorized {
        distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }

    function setDistributorSettings(uint256 gas) external authorized {
        require(gas < 850000);
        distributorGas = gas;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(pair).mul(2)).div(getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function setPrintTokens(address _PrintToken1, uint256 _PrintTokenDecimals) external authorized {
        Token1 = address(_PrintToken1);
        distributor.setPrintToken(Token1, _PrintTokenDecimals);
        
    }

    function setDexPoolAddress1(address _DexPoolAddress) external authorized {
        DexPoolAddress1 = address(_DexPoolAddress);
    }

    function setDexPoolAddress2(address _DexPoolAddress) external authorized {
        DexPoolAddress2 = address(_DexPoolAddress);
    }

    function setFindDexPair(address _PairPoolAddress) internal {
        DexPair  = _PairPoolAddress;
    } 
    
    function setdistributorAddress(address _distributorAddress) external authorized{
        distributorAddress  = address(_distributorAddress);
    } 

    function createNewDistributor() external authorized{
        distributor = new DividendDistributor(ROUTERADDR);
        distributorAddress = address(distributor);
    } 

  
    function getDexPoolAddress1() external view returns (address) {
        return DexPoolAddress1 ;
    }

    function getDexPoolAddress2() external view returns (address) {
        return DexPoolAddress2 ;
    }

    function getPrintToken() external view returns (address) {
        return Token1 ;
    }

    function getFindDexPair() external view returns (address) {
        return DexPair ;
    } 
    function getMinPeriod() external view  returns (uint256) {
        return distributor.getMinPeriod() ;
    }
    function getSwapAmount(uint256 _transferAmount)
        public
        view
        returns (uint256)
    {
        uint256 amountFromTxnPercMax = _transferAmount.mul(swapPercentMax).div(100);
        return
        amountFromTxnPercMax > swapThresholdMax
            ? swapThresholdMax
            : amountFromTxnPercMax;
    }

    function GetDistribution() external view  returns (uint256) {
        return distributor.GetDistribution() ;
    }

    function SwapBackManual(uint256 _amount)  external authorized{
        if (_balances[address(this)] >= _amount){
        
            uint256 swapAmount = _amount;  

            uint256 balanceBefore = address(this).balance;

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = WBNB;
                
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
            );

            uint256 amountBNB = address(this).balance.sub(balanceBefore);

            try distributor.deposit{value: amountBNB}() {} catch {}
        }
    }
       



    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    
}