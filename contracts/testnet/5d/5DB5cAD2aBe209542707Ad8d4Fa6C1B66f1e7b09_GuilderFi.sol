// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// Libraries
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Interfaces
import "./interfaces/IDexPair.sol";
import "./interfaces/IDexRouter.sol";
import "./interfaces/IDexFactory.sol";
import "./interfaces/IGuilderFi.sol";
import "./interfaces/ISwapEngine.sol";
import "./interfaces/ILiquidityReliefFund.sol";
import "./interfaces/IAutoLiquidityEngine.sol";
import "./interfaces/ISafeExitFund.sol";
import "./interfaces/IPreSale.sol";

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
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 1 * 10**6 * 10**DECIMALS; // 1 million
    uint256 private constant MAX_SUPPLY = 82 * 10**21 * 10**DECIMALS;
    uint256 private constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // REBASE CONSTANTS
    uint256 private constant YEAR1_REBASE_RATE = 160309122470000; // 0.0160309122470000 %
    uint256 private constant YEAR2_REBASE_RATE = 144501813571063; // 0.0144501813571063 %
    uint256 private constant YEAR3_REBASE_RATE = 128715080592867; // 0.0128715080592867 %
    uint256 private constant YEAR4_REBASE_RATE = 112969085762193; // 0.0112969085762193 %
    uint256 private constant YEAR5_REBASE_RATE = 97303671485527;    // 0.0097303671485527 %
    uint256 private constant YEAR6_REBASE_RATE = 34322491203609;    // 0.0034322491203609 %
    uint8   private constant REBASE_RATE_DECIMALS = 18;
    uint256 private constant REBASE_FREQUENCY = 12 minutes;
    
    // REBASE VARIABLES
    uint256 public override maxRebaseBatchSize = 40; // 8 hours
    
    // ADDRESSES
    address internal _treasuryAddress;
    address internal _burnAddress = DEAD;

    // OTHER CONTRACTS
    ISwapEngine private swapEngine;
    ILiquidityReliefFund private lrf;
    IAutoLiquidityEngine private autoLiquidityEngine;
    ISafeExitFund private safeExitFund;
    IPreSale private preSale;

    address private _swapEngineAddress;
    address private _lrfAddress;
    address private _autoLiquidityEngineAddress;
    address private _safeExitFundAddress;
    address private _preSaleAddress;
    
    // FEES
    uint256 private constant MAX_BUY_FEES = 200; // 20%
    uint256 private constant MAX_SELL_FEES = 250; // 25%
    uint256 private constant FEE_DENOMINATOR = 1000;
    
    // BUY FEES | Treasury = 3% | LRF = 5% | Auto-Liquidity = 5% | SafeExit = 0 | Burn = 0
    Fee private _buyFees = Fee(30, 50, 50, 0, 0, 130);
    
    // SELL FEES | Treasury = 4% | LRF = 7% | Auto-Liquidity = 6% | SafeExit = 1% | Burn = 0
    Fee private _sellFees = Fee(40, 70, 60, 10, 0, 180);

    // SETTING FLAGS
    bool public override isAutoRebaseEnabled = true;
    bool public override isAutoSwapEnabled = false;
    bool public override isAutoLiquidityEnabled = false;
    bool public override isAutoLrfEnabled = false;
    bool public override isAutoSafeExitEnabled = true;

    // FREQUENCIES
    uint256 public override autoSwapFrequency = 0;    
    uint256 public override autoLiquidityFrequency = 0;
    uint256 public override autoLrfFrequency = 0;

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
    mapping(address => bool) private _isContract;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;

    // TOKEN LAUNCHED FLAG
    bool public override hasLaunched = false;

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
        // init treasury address
        _treasuryAddress = msg.sender;

        // initialise total supply
        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        
        // exempt fees from contract + treasury
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[_treasuryAddress] = true;

        // assign total supply to treasury
        _gonBalances[_treasuryAddress] = TOTAL_GONS;
        emit Transfer(address(0x0), _treasuryAddress, _totalSupply);
    }

    function setSwapEngine(address _address) external override onlyOwner {
        _swapEngineAddress = _address;
        swapEngine = ISwapEngine(_address);
        initSubContract(_address);
    }

    function setLrf(address _address) external override onlyOwner {
        _lrfAddress = _address;
        lrf = ILiquidityReliefFund(_address);
        initSubContract(_address);
    }

    function setLiquidityEngine(address _address) external override onlyOwner {
        _autoLiquidityEngineAddress = _address;
        autoLiquidityEngine = IAutoLiquidityEngine(_address);
        initSubContract(_address);
    }        

    function setSafeExitFund(address _address) external override onlyOwner {
        _safeExitFundAddress = _address;
        safeExitFund = ISafeExitFund(_address);
        initSubContract(_address);
    }
    
    function setPreSaleEngine(address _address) external override onlyOwner {
        _preSaleAddress = _address;
        preSale = IPreSale(_address);
        initSubContract(_address);
    }

    function initSubContract(address _address) internal {
        if (address(_router) != address(0)) {
            _allowedFragments[_address][address(_router)] = type(uint256).max;
        }

        _isContract[_address] = true;
        _isFeeExempt[_address] = true;
    }

    function setTreasury(address _address) external override onlyOwner {
        require(_treasuryAddress != _address, "Address already in use");
        
        _gonBalances[_address] = _gonBalances[_treasuryAddress];
        _gonBalances[_treasuryAddress] = 0;
        emit Transfer(_treasuryAddress, _address, _gonBalances[_address].div(_gonsPerFragment));
        
        _treasuryAddress = _address;

        // exempt fees
        _isFeeExempt[_treasuryAddress] = true;

        // transfer ownership
        _transferOwnership(_treasuryAddress);
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

    function pendingRebases() internal view returns (uint256) {
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

    function shouldDoBasicTransfer(address sender, address recipient) internal view returns (bool) {
        if (_inSwap) return true;
        if (_isContract[sender]) return true;
        if (_isContract[recipient]) return true;
        if (sender == address(_router) || recipient == address(_router)) return true;
        if (swapEngine.inSwap() || autoLiquidityEngine.inSwap()) return true;
        
        /*
        if (sender == address(_pair)) {
            return _isContract[recipient];
        }
        
        if (recipient == address(_pair)) {
            return _isContract[sender];
        }
        */

        return false;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
    
        require(!blacklist[sender] && !blacklist[recipient], "Address blacklisted");

        if (shouldDoBasicTransfer(sender, recipient)) {
            return _basicTransfer(sender, recipient, amount);
        }
        else {
            preTransactionActions(sender, recipient, amount);
        }
        
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
            safeExitFund.execute(sender, recipient, amount);
        }

        if (shouldSwap()) {
            swapEngine.execute();
            lastSwapTime = block.timestamp;
        }

        if (shouldAddLiquidity()) {
            autoLiquidityEngine.execute();
            lastAddLiquidityTime = block.timestamp;
        }
   
        if (shouldExecuteLrf()) {
            lrf.execute();
            lastLrfExecutionTime = block.timestamp;
        }

        if (shouldRebase()) {
            rebase();
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
        _gonBalances[_autoLiquidityEngineAddress] = _gonBalances[_autoLiquidityEngineAddress].add(liquidityAmount);
        emit Transfer(sender, _autoLiquidityEngineAddress, liquidityAmount.div(_gonsPerFragment));
        
        // move the rest to swap engine
        _gonBalances[_swapEngineAddress] = _gonBalances[_swapEngineAddress].add(totalToSwap);
        emit Transfer(sender, _swapEngineAddress, totalToSwap.div(_gonsPerFragment));
        
        // record fees in swap engine
        if (address(swapEngine) != address(0)) {
            swapEngine.recordFees(
                lrfAmount.div(_gonsPerFragment),
                safeExitAmount.div(_gonsPerFragment),
                treasuryAmount.div(_gonsPerFragment)
            );
        }

        return gonAmount.sub(total);
    }
    
    /*
     * INTERNAL CHECKER FUNCTIONS
     */ 
    function shouldTakeFee(address from, address to) internal view returns (bool) {
        if (_isFeeExempt[from]) return false;
        if (address(_pair) == from || address(_pair) == to) return true;

        return false;
    }

    function shouldRebase() internal view returns (bool) {
        return
            isAutoRebaseEnabled &&
            hasLaunched &&
            (_totalSupply < MAX_SUPPLY) &&
            block.timestamp >= (lastRebaseTime + REBASE_FREQUENCY);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            isAutoLiquidityEnabled && 
            _autoLiquidityEngineAddress != address(0) &&
            (autoLiquidityFrequency == 0 || (block.timestamp >= (lastAddLiquidityTime + autoLiquidityFrequency))); 
    }

    function shouldSwap() internal view returns (bool) {
        return 
            isAutoSwapEnabled &&
            _swapEngineAddress != address(0) &&
            (autoSwapFrequency == 0 || (block.timestamp >= (lastSwapTime + autoSwapFrequency)));
    }

    function shouldExecuteLrf() internal view returns (bool) {
        return
            isAutoLrfEnabled &&
            _lrfAddress != address(0) &&            
            (autoLrfFrequency == 0 || (block.timestamp >= (lastLrfExecutionTime + autoLrfFrequency))); 
    }

    function shouldExecuteSafeExit() internal view returns (bool) {
        return
            isAutoSafeExitEnabled &&
            _safeExitFundAddress != address(0);
            // safeExitFund.balanceOf(msg.sender) > 0;
    }

    /*
     * TOKEN ALLOWANCE/APPROVALS
     */ 
    function allowance(address owner_, address spender) public view override(IGuilderFi, IERC20) returns (uint256) {
        return _allowedFragments[owner_][spender];
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
        isAutoSwapEnabled = _flag;
    }

    function setAutoLrf(bool _flag) external override onlyOwner {
        isAutoLrfEnabled = _flag;
    }

    function setAutoLiquidity(bool _flag) external override onlyOwner {
        isAutoLiquidityEnabled = _flag;
        if(_flag) {
            lastAddLiquidityTime = block.timestamp;
        }
    }

    function setAutoRebase(bool _flag) override external onlyOwner {
        isAutoRebaseEnabled = _flag;
        if (_flag) {
            lastRebaseTime = block.timestamp;
        }
    }

    function setAutoSafeExit(bool _flag) external override onlyOwner {
        isAutoSafeExitEnabled = _flag;
    }

    function setFeeExempt(address _address, bool _flag) external override onlyOwner {
        _isFeeExempt[_address] = _flag;
    }

    function setBlacklist(address _address, bool _flag) external override onlyOwner {
        blacklist[_address] = _flag;    
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

        // exempt fees
        _isFeeExempt[_routerAddress] = true;
        
        // update allowances
        _allowedFragments[address(this)][_routerAddress] = type(uint256).max;
        _allowedFragments[address(swapEngine)][_routerAddress] = type(uint256).max;
        _allowedFragments[address(lrf)][_routerAddress] = type(uint256).max;
        _allowedFragments[address(autoLiquidityEngine)][_routerAddress] = type(uint256).max;
        _allowedFragments[address(safeExitFund)][_routerAddress] = type(uint256).max;
        _allowedFragments[address(preSale)][_routerAddress] = type(uint256).max;                          
    }

    function setAutoLiquidityFrequency(uint256 _frequency) external override onlyOwner {
        autoLiquidityFrequency = _frequency;
    }
    
    function setLrfFrequency(uint256 _frequency) external override onlyOwner {
        autoLrfFrequency = _frequency;
    }
    
    function setSwapFrequency(uint256 _frequency) external override onlyOwner {
        autoSwapFrequency = _frequency;
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

    function launchToken() external override onlyOwner {
        require(!hasLaunched, "Token has already launched");

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
    function getOwner() public view override returns (address) {
        return owner();
    }
    function getTreasuryAddress() public view override returns (address) {
        return _treasuryAddress;
    }
    function getSwapEngineAddress() public view override returns (address) {
        return address(swapEngine);
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
     
    function balanceOf(address who) public view override(IGuilderFi, IERC20) returns (uint256) {
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

pragma solidity 0.8.9;

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
    function maxRebaseBatchSize() external view returns (uint256);
    
    // Transfer
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    // Allowance
    function allowance(address owner_, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);

    // Launch token
    function launchToken() external;
    
    // Set on/off flags
    function setAutoSwap(bool _flag) external;
    function setAutoLiquidity(bool _flag) external;
    function setAutoLrf(bool _flag) external;
    function setAutoSafeExit(bool _flag) external;
    function setAutoRebase(bool _flag) external;

    // Set frequencies
    function setAutoLiquidityFrequency(uint256 _frequency) external;
    function setLrfFrequency(uint256 _frequency) external;
    function setSwapFrequency(uint256 _frequency) external;
    
    // Other settings
    function setMaxRebaseBatchSize(uint256 _maxRebaseBatchSize) external;

    // Address settings
    function setFeeExempt(address _address, bool _flag) external;
    function setBlacklist(address _address, bool _flag) external;

    // Read only functions
    // function isPreSale() external view returns (bool);
    function hasLaunched() external view returns (bool);

    // Addresses
    function getOwner() external view returns (address);
    function getTreasuryAddress() external view returns (address);
    function getSwapEngineAddress() external view returns (address);
    function getLrfAddress() external view returns (address);
    function getAutoLiquidityAddress() external view returns (address);
    function getSafeExitFundAddress() external view returns (address);
    function getPreSaleAddress() external view returns (address);

    // Setup functions
    function setSwapEngine(address _address) external;
    function setLrf(address _address) external;
    function setLiquidityEngine(address _address) external;
    function setSafeExitFund(address _address) external;
    function setPreSaleEngine(address _address) external;
    function setTreasury(address _address) external;
    function setDex(address routerAddress) external;

    // Setup fees
    function setFees(
        bool _isSellFee,
        uint256 _treasuryFee,
        uint256 _lrfFee,
        uint256 _liquidityFee,
        uint256 _safeExitFee,
        uint256 _burnFee
    ) external;

    // Getters - setting flags
    function isAutoSwapEnabled() external view returns (bool);
    function isAutoRebaseEnabled() external view returns (bool);
    function isAutoLiquidityEnabled() external view returns (bool);
    function isAutoLrfEnabled() external view returns (bool);
    function isAutoSafeExitEnabled() external view returns (bool);

    // Getters - frequencies
    function autoSwapFrequency() external view returns (uint256);
    function autoLiquidityFrequency() external view returns (uint256);
    function autoLrfFrequency() external view returns (uint256);

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

pragma solidity 0.8.9;

interface ISwapEngine {

    function execute() external;
    function recordFees(uint256 lrfAmount, uint256 safeExitAmount, uint256 treasuryAmount) external;
    function isEnabled() external view returns (bool);
    function inSwap() external view returns (bool);
    function setEnabled(bool _enable) external;
    function withdraw(uint256 amount) external;
    function withdrawTokens(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface ILiquidityReliefFund {

    function execute() external;
    function forceExecute() external;
    function inSwap() external view returns (bool);    
    function withdraw(uint256 amount) external;
    function withdrawTokens(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IAutoLiquidityEngine {

    function execute() external;
    function inSwap() external view returns (bool);    
    function withdraw(uint256 amount) external;
    function withdrawTokens(address token, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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
    string memory metadataUriLive,
    string memory metadataUriReady,
    string memory metadataUriDead
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
  function setMetadataUri(uint256 _packageId, string memory _uriLive, string memory _uriReady) external;
  function setUnrevealedMetadataUri(string memory _uri) external;
  function setUsedMetadataUri(string memory _uri) external;
  function setActivationDate(uint256 _date) external;
  function setMaxSupply(uint256 newMaxSupply) external;
  
  function withdraw(uint256 amount) external;
  function withdrawTokens(address _tokenAddress, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

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