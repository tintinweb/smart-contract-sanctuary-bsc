/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/*
use anti dumpday e.g. launch, airdrop presale
anti dumpday : selltax = buy tax * 1.7
anti dumpday + 1 : selltax = buy tax * 1.6
anti dumpday + 2 to 8  : selltax = buy tax * 1.5
anti dumpday + 9 to 22  : selltax = buy tax * 1.4
anti dumpday + 23 to 50  : selltax = buy tax * 1.3
anti dumpday + 51   : selltax = buy tax * 1.2

wallet size max = 0.01 of total supply
sell size max = 0.02 of total supply

burnrate?

recommended initial liquidity 50 BNB per 1 Trillion 

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
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

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

interface InterfaceLP {
    function sync() external;
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
 
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


 

contract Tortoise is IBEP20, Auth , ReentrancyGuard{

    //mainnet
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    //testnet
    //address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
   
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "TORTOISE";
    string constant _symbol = "TORTOISE";
    uint8 constant _decimals = 18;

    // rsupply balances
    mapping (address => uint256) _rBalance;
    mapping (address => mapping (address => uint256)) _allowances;


    // controls on transactions to prevent pumping and dumping and sniping
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;

    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;
    mapping(address => uint256) public lastBuyBlock;
    mapping (address => uint256) public _buyBlock; 
    uint256 public deadBlocks = 10;
    uint256 public launchedAt = 0;
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 15;
    mapping (address => uint) public cooldownTimer;



    // fee structure 
    uint256 public liquidityFee    = 5; 
    uint256 public treasuryFee    = 3;
    uint256 public triggerFee      = 5;
    uint256 public totalFee        = treasuryFee +  liquidityFee + triggerFee;
    uint256 public feeDenominator  = 100;
     uint256 public sellFee = 12;

    address public autoLiquidityReceiver;
    address public treasuryFeeReceiver;
    address public triggerFeeReceiver;


    //liquidity settings
    uint256 targetLiquidity = 50;
    uint256 targetLiquidityDenominator = 100;
    bool public swapEnabled = true;
    bool inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
  

    // exchange settings 
    IDEXRouter public router;
    address public pair;
    InterfaceLP public pairContract; 

    
    // on set up complete,  enable trading -  
    bool public tradingOpen = false;
    bool public feesOnNormalTransfers = false;

    // restrict certain external calls to master of contract
    address public master;
    modifier onlyMaster() {
        require(msg.sender == master || isOwner(msg.sender));
        _;
    }

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event AutoLiquify(uint256 amountBNB, uint256 amountTokens);

    // supply settings 
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 8 * 10**6 * 10**_decimals;
    uint256 public swapThreshold = rSupply / uint256(1000);
    uint256 public rebase_count = 0;
    uint256 public rate;
    uint256 public _totalSupply;
    uint256 private constant MAX_UINT256 = type(uint256).max;  
    uint256 private constant MAX_SUPPLY = type(uint128).max;  
    uint256 private constant rSupply = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // Max wallet & Transaction
    uint256 public _maxTxAmount =  rSupply /   uint256(100) ;
    uint256 public _maxWalletToken = rSupply / uint256(50);

    // rebase settings 
    uint256 public lastRebaseTime;
    int256 public lastRebaseDelta;
    uint256 public rebaseRate = 7349188;
    uint256 public rebaseFrequency = 1800; 
    bool public autoRebase;

   
    constructor () Auth(msg.sender) ReentrancyGuard() {

         //mainnet
         // router =  IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
       
        //testnet
         router =  IDEXRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
       
         pair = IDEXFactory(router.factory()).createPair(WBNB, address(this));        
        _allowances[address(this)][address(router)] = type(uint256).max; //uint256(-1);

        pairContract = InterfaceLP(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        rate = rSupply / (_totalSupply);

        isFeeExempt[msg.sender] = true;
        isTxLimitExempt[msg.sender] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;

        lastRebaseTime = block.timestamp;
        lastRebaseDelta = 0;
        autoRebase = false;

        // autoLiquidityReceiver = msg.sender;
        // treasuryFeeReceiver = 0xF697b0E56A29FF679a9f7A28BCD942476702ffbA;
        // triggerFeeReceiver = 0x67aEc5c39b0b04B338d4Ee188dd236766D419725;

        autoLiquidityReceiver = msg.sender;
        treasuryFeeReceiver = 0xF697b0E56A29FF679a9f7A28BCD942476702ffbA;
        triggerFeeReceiver = 0x67aEc5c39b0b04B338d4Ee188dd236766D419725;


        //  autoLiquidityReceiver = msg.sender;
        // treasuryFeeReceiver = 0x80c18A35A1e449AA1c898cc889217cC1C1Ba8C8E;
        // triggerFeeReceiver = 0x8e870b86395b146516aBDC2844Aa7DAa1A8ff303;

         

        _rBalance[msg.sender] = rSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);

    }

    // manage mistaken direct transfers to contract 
    fallback() external payable {}
    receive() external payable { }

    
    // BEP 20 calls
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }

    function balanceOf(address account) public view override returns (uint256) {
        return _rBalance[account] / (rate);
    }
    
    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    
    function approveMax(address spender)  external returns (bool) {
        return approve(spender,  type(uint256).max);
    }

    //transfer calls - transfer/transfFrom - both call _transferFrom 
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if(_allowances[sender][msg.sender] !=  type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - (amount);  //need to check if sufficient
        }

        return _transferFrom(sender, recipient, amount);
    }

    // main transfer function 
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        //if swapping just do basic transfer and exit
        if(inSwap){ return _basicTransfer(sender, recipient, amount); }

        //check if trading is open
        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

      //anti sniping control - prevent repeat buy/sell in same block
      if(blacklistMode){
          require(_buyBlock[sender] != block.number, "Bad bot!");
 
          _buyBlock[recipient] = block.number;
          //anti bot 
          if (sender != pair && block.number == lastBuyBlock[sender]) { revert(); }
          if (sender == pair) { lastBuyBlock[recipient] = block.number; }
        }


        uint256 rAmount = amount * (rate);

        // prevent individual wallet balance exceeding limit
        if (!authorizations[sender] && recipient != address(this)  && recipient != address(DEAD) && recipient != pair && recipient != treasuryFeeReceiver && recipient != triggerFeeReceiver  && recipient != autoLiquidityReceiver){
            uint256 heldTokens = balanceOf(recipient);
            require((heldTokens + rAmount) <= _maxWalletToken,"Total Holding is currently limited, you can not buy that much.");}
        
        //if cooldown enabled, prevent repeat purchases from same wallet
        if (sender == pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"buy Cooldown exists");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }

        // block blacklisted addresses
        if(blacklistMode){
            require(!isBlacklisted[sender] && !isBlacklisted[recipient],"Blacklisted");    
        }

        // prevent transaction size exceeding limit
        checkTxLimit(sender, rAmount);

        // check if need to do swap back of liquidity and if so call swap back
        if(shouldSwapBack()){ swapBack(); }

        //reduce sender balance by rAmount
        _rBalance[sender] = _rBalance[sender] - (rAmount);  //need to check if sufficient


        //check if transaction incurs fee - if so, calculate fee and increase receiver balance by nett after fee
        uint256 amountReceived = (!shouldTakeFee(sender, recipient)) ? rAmount : takeFee(sender, rAmount,(recipient == pair));
     
        _rBalance[recipient] = _rBalance[recipient] + (amountReceived);

         
        emit Transfer(sender, recipient, amountReceived / (rate));

        //if autorebase is on and time to rebase call rebase
        if (shouldRebase()) {
           rebase(block.timestamp, int256(_totalSupply * (rebaseRate) / (10 ** 10))); 
        }

        return true;
    }
    
    // if swapping this call is made to transaction no fee transaction
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 rAmount = amount * (rate);
        _rBalance[sender] = _rBalance[sender] - (rAmount);  //need to check if sufficient
        _rBalance[recipient] = _rBalance[recipient] + (rAmount);
        emit Transfer(sender, recipient, rAmount / (rate));
        return true;
    }

    //check if max transfer limit is exceeded
    function checkTxLimit(address sender, uint256 rAmount) internal view {
        require(rAmount <= _maxTxAmount || isTxLimitExempt[sender], "TX Limit Exceeded");
    }


    // check if transfer incurs fee
    function shouldTakeFee(address from, address to) internal view returns (bool) {
      if(isFeeExempt[from] || isFeeExempt[to]){
            return false;
      }else if (feesOnNormalTransfers){
          return true;
      }else{
          return ( pair == from || pair == to);
      }

    }

    //calculate fee and credit contract balance with fee amount, return nett amount
    function takeFee(address sender, uint256 rAmount, bool isSell) internal returns (uint256) {
        
        uint256 feeRate = totalFee;
        if(isSell){
            feeRate += sellFee;
        } 

        uint256 feeAmount = ( rAmount /  feeDenominator ) * (feeRate);

        if(!isSell && (launchedAt + deadBlocks) > block.number){
            feeAmount = rAmount / (100) * (99);
        }

        _rBalance[address(this)] = _rBalance[address(this)] + (feeAmount);
        emit Transfer(sender, address(this), feeAmount / (rate));

        return rAmount - (feeAmount);
    }

    //check if contract balance has reached swapthreshold 
    function shouldSwapBack() internal view returns (bool) {
        return msg.sender != pair
        && !inSwap
        && swapEnabled
        && _rBalance[address(this)] >= swapThreshold;
    }


   
    // check if automatic rebase should be called 
    function shouldRebase() internal view returns (bool) {
      return  autoRebase &&  (_totalSupply < MAX_SUPPLY) && msg.sender != pair  
        &&  !inSwap &&  block.timestamp >= (lastRebaseTime + rebaseFrequency );
    }

    //adjust total supply according to delta parameter
    function rebase(uint256 epoch, int256 supplyDelta) internal returns (uint256) {
        rebase_count++;
        if(epoch == 0){
            epoch = rebase_count;
        }

        require(!inSwap, "Try again");

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            lastRebaseTime = epoch;
            lastRebaseDelta = supplyDelta;
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply - (uint256(-supplyDelta));
        } else {
            _totalSupply = _totalSupply + (uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        rate = rSupply / _totalSupply;
        
        //sync up exchange with adjusted supply 
        //pdh
       // pairContract.sync();

        lastRebaseTime = epoch;
        lastRebaseDelta = supplyDelta;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }

   
    // replenish liquidity from treasury funds
    function swapBack() internal swapping {
         
      uint256 tokensToSell = swapThreshold / (rate);

       uint256 dynamicLiquidityFee = isOverLiquified(
            targetLiquidity,
            targetLiquidityDenominator
        )
            ? 0
            : liquidityFee;

        uint256 amountToLiquify = tokensToSell / (totalFee) * (dynamicLiquidityFee) / (2);
        uint256 amountToSwap = tokensToSell - (amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] =  WBNB;

        uint256 balanceBefore = address(this).balance;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountBNB = address(this).balance - (balanceBefore);

        uint256 totalBNBFee = totalFee - (dynamicLiquidityFee / (2));
        
        uint256 amountBNBLiquidity = amountBNB * (dynamicLiquidityFee) / (totalBNBFee) / (2);
        uint256 amountBNBTreasury = amountBNB * (treasuryFee) / (totalBNBFee);
        uint256 amountBNBTrigger = amountBNB * (triggerFee) / (totalBNBFee);

        (bool tmpSuccess,) = payable(treasuryFeeReceiver).call{value: amountBNBTreasury, gas: 30000}("");
        (tmpSuccess,) = payable(triggerFeeReceiver).call{value: amountBNBTrigger, gas: 30000}("");
        
        // only to supress warning msg
        tmpSuccess = false;

        if(amountToLiquify > 0){
            router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify / (rate));
        }
    }

    

    // external call to resync exchange with current supply
    function manualSync() nonReentrant() external onlyOwner {
        InterfaceLP(pair).sync();
    }
    
    
    // enable / disable trading and set dead blocks 
    function tradingStatus(bool _status, uint256 _deadBlocks) nonReentrant() external onlyOwner {
        tradingOpen = _status;
        if(tradingOpen && launchedAt == 0){
            launchedAt = block.number;
            deadBlocks = _deadBlocks;
        }
    }

    function setFeesOnNormalTransfers(bool _enabled) external onlyOwner {
        require(feesOnNormalTransfers != _enabled, "Not changed");
        feesOnNormalTransfers = _enabled;
    }

    // reset launch block
    function launchStatus(uint256 _launchblock) nonReentrant() external onlyOwner {
        launchedAt = _launchblock;
    }

    
    // set blacklist mode
    function enable_blacklist(bool _status) nonReentrant() external onlyOwner {
        blacklistMode = _status;
    }

    function setBotBlacklist(address _botAddress, bool _flag) external onlyOwner {
        require(isContract(_botAddress), "only contract address, not allowed externally owned account");
        isBlacklisted[_botAddress] = _flag;    
    }

    // add / remove addresses to blacklist
    function manage_blacklist(address[] calldata addresses, bool status) nonReentrant() external onlyOwner {
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
    }

    // set cooldown flag
    function cooldownEnabled(bool _status, uint8 _interval) nonReentrant() external onlyOwner {
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    // add or remove address to fee exempt
    function setIsFeeExempt(address holder, bool exempt) nonReentrant() external authorized {
        isFeeExempt[holder] = exempt;
    }
    
    // assign tax limit exemption status to address
    function setIsTxLimitExempt(address holder, bool exempt) nonReentrant() external authorized {
        isTxLimitExempt[holder] = exempt;
    }

    // assign address with timelock status 
    function setIsTimelockExempt(address holder, bool exempt) nonReentrant() external authorized {
        isTimelockExempt[holder] = exempt;
    }

    
    function setCooldownTimer(address holder) nonReentrant() external authorized {
        cooldownTimer[holder] = block.timestamp + cooldownTimerInterval;
    }

    


    // set buy fees, including total fee and limit to 25%
    function setFees(uint256 _liquidityFee,   uint256 _treasuryFee, uint256 _triggerFee, uint256 _sellFee, uint256 _feeDenominator) nonReentrant() external authorized {
        liquidityFee = _liquidityFee;       
        treasuryFee = _treasuryFee;
        triggerFee = _triggerFee;
        totalFee = _liquidityFee +  _treasuryFee   +  _triggerFee ;
        sellFee = _sellFee;
        feeDenominator = _feeDenominator;
        require((totalFee + sellFee) <= feeDenominator/4, "Fees cannot be more than 25%");
    }

   
    
    // assign main accounts with new addresses
    function setFeeReceivers(address _autoLiquidityReceiver, address _treasuryFeeReceiver, address _triggerFeeReceiver ) nonReentrant() external authorized {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryFeeReceiver = _treasuryFeeReceiver;
        triggerFeeReceiver = _triggerFeeReceiver;
    }


    // enable / disable swap back settings and set threshold to a percentage
    function setSwapBackSettings(bool _enabled,  uint256 _num,  uint256 _denom) nonReentrant() external authorized {
        swapEnabled = _enabled;
        swapThreshold = rSupply / (_denom) * (_num);
    }

    // set target liquidity
    function setTargetLiquidity(uint256 _target, uint256 _denominator) nonReentrant() external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

    
    // change liquidity provider
    function setLP(address _address) nonReentrant() external onlyOwner {
        pairContract = InterfaceLP(_address);
        isFeeExempt[_address];
    }

    // change master address
    function setMaster(address _master) nonReentrant() external onlyOwner {
        master = _master;
    }

    // set max wallet balance as percentage of supply
    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) nonReentrant() external onlyOwner() {
        _maxWalletToken = rSupply / (1000) * (maxWallPercent_base1000);
    }

    // set max transaction size as percentage of supply
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) nonReentrant() external onlyOwner() {
        _maxTxAmount = rSupply / (1000) * (maxTXPercentage_base1000);
    }

    
    // check if swapping
    function isNotInSwap()  external view returns (bool) {
        return !inSwap;
    }

    
    // check swap threshold
    function checkSwapThreshold()   external view returns (uint256) {
        return swapThreshold / (rate);
    }

    
    // get circulating supply - excludes dead and zero balance
    function getCirculatingSupply()   public view returns (uint256) {
        return (rSupply - (_rBalance[DEAD]) - (_rBalance[ZERO])) / (rate);
    }

   
    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy * (balanceOf(pair) * (2)) / (getCirculatingSupply());
    }

    // check if liquidity pair has too high level of backing
    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    // query on limit set on wallet size
    function checkMaxWalletToken() external view returns (uint256) {
        return _maxWalletToken / (rate);
    }

    // quiery on limit set on transaction amount
    function checkMaxTxAmount() external view returns (uint256) {
        return _maxTxAmount / (rate);
    }


  // clear out balance in contract 
   function clearStuckBalance_sender(uint256 amountPercentage) nonReentrant() external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }


    // call rebase externally with nominal value
    function manualRebase(uint256 epoch, int256 supplyDelta) external onlyOwner {    
          if  ((_totalSupply < MAX_SUPPLY)  &&  !inSwap ) {
           rebase(epoch, supplyDelta * 10 ** 18);
         }    
    }

  
    // call rebase externally with percentage value total supply
     function rebase_percentage(uint256 _percentage_base1000, bool reduce) nonReentrant() external onlyMaster returns (uint256 newSupply){

        if(reduce){
            newSupply = rebase(0,int(_totalSupply / (1000000000) * (_percentage_base1000)) * (-1));
        } else{
            newSupply = rebase(0,int(_totalSupply / (1000000000) * (_percentage_base1000)));
        }
        
    }

    // enable auto rebase
    function setAutoRebase(bool _flag) nonReentrant() external onlyOwner {
        if (_flag) {
            autoRebase = _flag;
            lastRebaseTime = block.timestamp;
        } else {
            autoRebase = _flag;
        }
    }

    // change rebase rate - factor of 10**10
   function setRebaseRate( uint256 _rebaseRate ) nonReentrant() external onlyOwner {
        rebaseRate = _rebaseRate;
    }

    // change rebase frequency - seconds between automatic calls
    function setRebaseFrequency(uint256 _rebaseFrequency) nonReentrant() external onlyOwner {
      rebaseFrequency = _rebaseFrequency;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }


    // airdrop individual specific number of tokens to batch of addresses 
  function multiTransfer(address[] calldata addresses, uint256[] calldata tokens) nonReentrant() external onlyOwner {

    require(addresses.length < 801,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
    require(addresses.length == tokens.length,"Mismatch between Address and token count");

    uint256 airdropcount = 0;

    for(uint i=0; i < addresses.length; i++){
        airdropcount = airdropcount + tokens[i];
    }

    require(balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(msg.sender,addresses[i],tokens[i]);
    }
   
  }

  // airdrop fixed amount to batch of addresses 
  function multiTransfer_fixed(address[] calldata addresses, uint256 tokens) nonReentrant() external onlyOwner {

    require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

    uint256 airdropcount = tokens * addresses.length;

    require(balanceOf(msg.sender) >= airdropcount, "Not enough tokens in wallet");

    for(uint i=0; i < addresses.length; i++){
        _basicTransfer(msg.sender,addresses[i],tokens);
    }
}



}