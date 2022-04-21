/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


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

 interface IPancakeSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapRouter{
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
    function removeLiquidityETHSupportingFeeOnTransferTokens(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
      address token,
      uint liquidity,
      uint amountTokenMin,
      uint amountETHMin,
      address to,
      uint deadline,
      bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
  
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

interface IPancakeSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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


 

contract WhiteTiggerFinance is IBEP20, Auth , ReentrancyGuard{

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    string constant _name = "White Tigger Finance";
    string constant _symbol = "WTF";
    uint8 constant _decimals = 18;

    // TOTAL_GONS balances
    mapping (address => uint256) _rBalance;
    mapping (address => mapping (address => uint256)) _allowances;


    // controls on transactions to prevent pumping and dumping and sniping
    mapping (address => bool) public isFeeExempt;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isTimelockExempt;

    bool public blacklistMode = true;
    mapping (address => bool) public isBlacklisted;
    mapping(address => uint256) public lastBuyBlock;
    
    uint256 public deadBlocks = 10;
    uint256 public launchedAt = 0;
    uint256 public launchedAtTime = 0;
    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 15;
    mapping (address => uint) public cooldownTimer;



    // fee structure 
    uint256 public liquidityFee    = 5; 
    uint256 public treasuryFee    = 8;
    uint256 public totalFee        = treasuryFee +  liquidityFee;
    uint256 public feeDenominator  = 100;
    uint256 public salesFee = 7;
    uint256 public initialsurcharge = 9;
    uint256 public surchargeextra = 2;

    address public liquidityReceiver;
    address public treasuryReceiver;
    address public teamWallet;

  
  

    // exchange settings 
    IPancakeSwapPair public pairContract;
   
    IPancakeSwapRouter public router;
    address public pair;

  
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
   

    // supply settings 
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =  10**5 * 10**_decimals;
    
    uint256 public rebase_count = 0;
    uint256 public rate;
    uint256 public _totalSupply;
    uint256 private constant MAX_UINT256 = type(uint256).max;  
    uint256 private constant MAX_SUPPLY = type(uint128).max;  
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // Max wallet & Transaction
    uint256 public _maxTxAmount =  TOTAL_GONS /   uint256(2000) ;
    uint256 public _maxWalletToken = TOTAL_GONS / uint256(50);

    // rebase settings 
    uint256 public lastRebaseTime;
    int256 public lastRebaseDelta;
    uint256 public rebaseRate = 7349188;
    uint256 public rebaseFrequency = 1800; 
    bool public autoRebase;
 
   
    constructor () Auth(msg.sender) ReentrancyGuard() {
 
       
      router =  IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
       
          
        pair = IPancakeSwapFactory(router.factory()).createPair( router.WETH(), address(this) );
            
        _allowances[address(this)][address(router)] = type(uint256).max;  
        _allowances[address(this)][pair] = type(uint256).max;  


        pairContract = IPancakeSwapPair(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

        rate = TOTAL_GONS / (_totalSupply);

        isFeeExempt[treasuryReceiver] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[msg.sender] = true;
        isFeeExempt[DEAD] = true;
        isFeeExempt[liquidityReceiver] = true;
        isFeeExempt[teamWallet] = true;
        
        isTxLimitExempt[msg.sender] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[treasuryReceiver] = true;
        isTxLimitExempt[liquidityReceiver] = true;
        isTxLimitExempt[DEAD] = true;
        isTxLimitExempt[teamWallet] = true;

        isTimelockExempt[msg.sender] = true;
        isTimelockExempt[DEAD] = true;
        isTimelockExempt[address(this)] = true;
        isTimelockExempt[treasuryReceiver] = true;
        isTimelockExempt[liquidityReceiver] = true;
        isTimelockExempt[teamWallet] = true;

        lastRebaseTime = block.timestamp;
        lastRebaseDelta = 0;
        autoRebase = false;

  

       liquidityReceiver =  0x1ade19d48B65336a050651E31337493af5523024;
       treasuryReceiver = 0x43844DFd0f4aA469253381C2eaA4Ae62D914B79e;
       teamWallet = 0x60EF3cB827189EF2a66651f635271F6750d21174;

        _rBalance[msg.sender] = TOTAL_GONS;
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
    function transfer(address recipient, uint256 amount) external nonReentrant() override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external nonReentrant() override returns (bool) {
        if(_allowances[sender][msg.sender] !=  type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - (amount);  //need to check if sufficient
        }

        return _transferFrom(sender, recipient, amount);
    }

    // main transfer function 
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        
        //check if trading is open
        if(!authorizations[sender] && !authorizations[recipient]){
            require(tradingOpen,"Trading not open yet");
        }

      //anti sniping control - prevent repeat buy/sell in same block
      if(blacklistMode){
          if (sender != pair && block.number == lastBuyBlock[sender]) { revert(); }
          if (sender == pair) { lastBuyBlock[recipient] = block.number; }
        }


        uint256 rAmount = amount * (rate);

        
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
        checkTxLimit(sender, rAmount, (recipient == pair));

        

        //reduce sender balance by rAmount
        require(_rBalance[sender] >= (rAmount) , 'Insufficient balance');
        _rBalance[sender] = _rBalance[sender] - (rAmount);  


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
    
    
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 rAmount = amount * (rate);
        _rBalance[sender] = _rBalance[sender] - (rAmount);  //need to check if sufficient
        _rBalance[recipient] = _rBalance[recipient] + (rAmount);
        emit Transfer(sender, recipient, rAmount / (rate));
        return true;
    }

    //check if max transfer limit is exceeded
    function checkTxLimit(address sender, uint256 rAmount,  bool isSell) internal view {
        require(rAmount <= _maxTxAmount || isTxLimitExempt[sender] || !isSell, "TX Limit Exceeded");
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
            uint256 _salesFee = salesFee; 
            if (block.timestamp <  ( launchedAtTime + 240 minutes)) {
              _salesFee = initialsurcharge + (5 * surchargeextra);
            } else if (block.timestamp <  ( launchedAtTime + 480 minutes)) {
                _salesFee = initialsurcharge + (4 * surchargeextra);
            } else if (block.timestamp <  ( launchedAtTime + 720 minutes)) {
                _salesFee = initialsurcharge + (3 * surchargeextra);
            } else if (block.timestamp <  ( launchedAtTime + 960 minutes)) {
                _salesFee = initialsurcharge + (2 * surchargeextra); 
            } else if (block.timestamp <  ( launchedAtTime + 1200 minutes)) {
                _salesFee = initialsurcharge + (1 * surchargeextra); 
            } else if (block.timestamp <  ( launchedAtTime + 30 days)) {
                _salesFee = initialsurcharge;  
            } 
 
            feeRate += _salesFee ;
        } 

        uint256 feeAmount = ( rAmount /  feeDenominator ) * (feeRate);

        if( (launchedAt + deadBlocks) > block.number){
            feeAmount = rAmount / (100) * (99);
        }

        _rBalance[treasuryReceiver] = _rBalance[treasuryReceiver] + (feeAmount);

        emit Transfer(sender, address(this), feeAmount / (rate));

        return rAmount - (feeAmount);
    }

     


   
    // check if automatic rebase should be called 
    function shouldRebase() internal view returns (bool) {
      return  autoRebase &&  (_totalSupply < MAX_SUPPLY) && msg.sender != pair   
        &&    block.timestamp >= (lastRebaseTime + rebaseFrequency );
    }

    //adjust total supply according to delta parameter
    function rebase(uint256 epoch, int256 supplyDelta) internal returns (uint256) {
        rebase_count++;
        if(epoch == 0){
            epoch = rebase_count;
        }


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

        rate = TOTAL_GONS / _totalSupply;
        
        //sync up exchange with adjusted supply 
       
        pairContract.sync();

        lastRebaseTime = epoch;
        lastRebaseDelta = supplyDelta;

        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }
 

    
   
    function manualSync() nonReentrant() external onlyOwner{
        IPancakeSwapPair(pair).sync();
    }
    
    
    // enable / disable trading and set dead blocks 
    function tradingStatus(bool _status, uint256 _deadBlocks) nonReentrant() external onlyOwner {
        tradingOpen = _status;
        if(tradingOpen && launchedAt == 0){
            launchedAt = block.number;
            launchedAtTime = block.timestamp;
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
    function setFees(uint256 _liquidityFee,   uint256 _treasuryFee,   uint256 _salesFee) nonReentrant() external authorized {
        liquidityFee = _liquidityFee;       
        treasuryFee = _treasuryFee;
        totalFee = _liquidityFee +  _treasuryFee  ;
        salesFee = _salesFee;
       
        require((totalFee + _salesFee) <= 49, "Fees cannot be more than 49%");
    }


 function setSurcharge(uint256 _initialsurcharge,   uint256 _surchargeextra) nonReentrant() external authorized {
      initialsurcharge = _initialsurcharge;       
      surchargeextra = _surchargeextra;
  }
 
   
    
    // assign main accounts with new addresses
    function setFeeReceivers(address _liquidityReceiver, address _treasuryReceiver ,   address _teamWallet ) nonReentrant() external authorized {
        liquidityReceiver = _liquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
         teamWallet = _teamWallet;
    }

  
   

    
   // change pair address
    function setPair(address _pair) nonReentrant() external onlyOwner {
        pair = _pair;
    }


    // change liquidity provider
    function setLP(address _address) nonReentrant() external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
        isFeeExempt[_address];
    }

    // change master address
    function setMaster(address _master) nonReentrant() external onlyOwner {
        master = _master;
    }

    // set max wallet balance as percentage of supply
    function setMaxWalletPercent_base1000(uint256 maxWallPercent_base1000) nonReentrant() external onlyOwner() {
        _maxWalletToken = TOTAL_GONS / (1000) * (maxWallPercent_base1000);
    }

    // set max transaction size as percentage of supply
    function setMaxTxPercent_base1000(uint256 maxTXPercentage_base1000) nonReentrant() external onlyOwner() {
        _maxTxAmount = TOTAL_GONS / (1000) * (maxTXPercentage_base1000);
    }

    
   
   
    
    // get circulating supply - excludes dead and zero balance
    function getCirculatingSupply()   public view returns (uint256) {
        return (TOTAL_GONS - (_rBalance[DEAD]) - (_rBalance[ZERO])) / (rate);
    }

    
      
    function withdrawAllToTreasury() external   nonReentrant()  onlyOwner {

        uint256 amountToSwap = _rBalance[address(this)] / (rate);
        require( amountToSwap > 0,"There are no tokens deposited in token contract");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

  function withdrawAllToTreasuryAmount(uint256 _amount) external   nonReentrant()  onlyOwner {

        uint256 amountToSwap = _rBalance[address(this)] / (rate);
         require( amountToSwap > 0,"There are no tokens deposited in token contract");
         if (amountToSwap > _amount * 10 ** 18 ) {
            amountToSwap = _amount * 10 ** 18;
         } 
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    


    // query on limit set on wallet size
    function checkMaxWalletToken() external view returns (uint256) {
        return _maxWalletToken / (rate);
    }

    // query on limit set on transaction amount
    function checkMaxTxAmount() external view returns (uint256) {
        return _maxTxAmount / (rate);
    }

   function rescueToken(uint256 tokens) nonReentrant() external onlyOwner returns (bool success){
        return _transferFrom(address(this), msg.sender, tokens * 10 ** 18);
   }

  // clear out balance in contract 
   function clearStuckBalance_sender(uint256 amountPercentage) nonReentrant() external onlyOwner {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer(amountBNB * amountPercentage / 100);
    }


    // call rebase externally with nominal value
    function manualRebase(uint256 epoch, int256 supplyDelta) external onlyOwner {    
          if  ((_totalSupply < MAX_SUPPLY)   ) {
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

    require(addresses.length < 501,"GAS Error: max airdrop limit is 500 addresses"); // to prevent overflow
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