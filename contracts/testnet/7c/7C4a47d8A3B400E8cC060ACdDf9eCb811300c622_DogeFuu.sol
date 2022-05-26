pragma solidity ^0.7.4;

import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IPancakeSwapPair.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapFactory.sol";
import "./MGMController.sol";

contract DogeFuu is ERC20Detailed, Ownable, MGMController {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "DogeFuu";
    string public _symbol = "DOGEFUU";
    uint8 public _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) public _operators;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    modifier onlyOperator() {
        require(_operators[msg.sender], "Forbidden");
        _;
    }

    uint256 public constant DECIMALS = 5;
    uint256 public constant MAX_UINT256 = ~uint256(0);
    uint8 public constant RATE_DECIMALS = 7;

    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        200 * 10**3 * 10**DECIMALS;

    uint256 public limitSellRate = 1;
    uint256 public limitSellRateDiscount = 2;
    uint256 public secondLimitSell = 120;
    uint256 minTaxFreeExemp = 100;

    struct Trader {
        uint256 lastTradeTime;
        uint256 amount;
        uint256 totalBuy;
        uint256 totalSell;
    }
    mapping(address => Trader) public tradeHistory;
    mapping(address => uint256) public boughtAmount;

    //Buy fee
    uint256 public treasuryFeeB = 20;
    uint256 public insuranceFundFeeB = 20;
    uint256 public firePitFeeB = 10;
    uint256 public totalFeeB =
        treasuryFeeB.add(insuranceFundFeeB).add(firePitFeeB);

    //Sell fee
    uint256 public treasuryFeeS = 40;
    uint256 public insuranceFundFeeS = 40;
    uint256 public firePitFeeS = 20;
    uint256 public totalFeeS =
        treasuryFeeS.add(insuranceFundFeeS).add(firePitFeeS);
    uint256 public feeDenominator = 1000;

    //Transfer
    bool public transferFeeEnable = false;
    bool public tradingEnabled = true;

    //Rate fee
    uint256 public totalFeeBnb =
        treasuryFeeB.add(treasuryFeeS).add(insuranceFundFeeB).add(
            insuranceFundFeeS
        );
    uint256 public treasuryFeeRate =
        (treasuryFeeB.add(treasuryFeeS)).div(totalFeeBnb);
    uint256 public insuranceFundFeeRate =
        (insuranceFundFeeB.add(insuranceFundFeeS)).div(totalFeeBnb);

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public treasuryReceiver;
    address public insuranceFundReceiver;
    address public firePit;
    IPancakeSwapRouter public router;
    address public pair;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private constant TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    uint256 private constant MAX_SUPPLY = 1600000000 * 10**DECIMALS;

    bool public _autoRebase;
    uint256 public _initRebaseStartTime;
    uint256 public _lastRebasedTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;

    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;

    constructor()
        ERC20Detailed("DogeFuu", "DOGEFUU", uint8(DECIMALS))
        Ownable()
    {
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        setMgmPair(pair);
        treasuryReceiver = 0xB9DffCE05FD93f82981242Ab8c2949D5230f4d1F;
        insuranceFundReceiver = 0xA24E8a58df3011f522EbCaDA803a690a7920ED6e;
        firePit = 0xE6F1F6638EBaC6c9c0c681FA3B7D48DC3d723c69;

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        pairContract = IPancakeSwapPair(pair);

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _initRebaseStartTime = block.timestamp;
        _lastRebasedTime = block.timestamp;
        _autoRebase = false;

        _isFeeExempt[insuranceFundReceiver] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[address(this)] = true;

        _operators[msg.sender] = true;

        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function forceRebase() external onlyOperator {
        if (shouldRebase()) {
            rebase();
        }
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _initRebaseStartTime;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(20 minutes);
        uint256 epoch = times.mul(20);

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 3078;
        } else if (deltaTimeFromInit >= (7 * 365 days)) {
            rebaseRate = 13;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
            rebaseRate = 24;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 146;
        }

        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(20 minutes));

        pairContract.sync();

        emit LogRebase(epoch, _totalSupply);
    }

    function transfer(address to, uint256 value)
        external
        override
        validRecipient(to)
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != uint256(-1)) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        boughtAmount[to] = boughtAmount[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        // if (sender == pair || recipient == pair) {
        //     require(tradingEnabled == true, "Trading not open yet");
        // }

        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        if (inSwap || excludedAccount) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (recipient == pair) {
            uint256 blkTime = block.timestamp;
            uint256 txLimitRate = mgmTree[msg.sender] == address(0)
                ? limitSellRate
                : limitSellRateDiscount;
            uint256 limitAmount = balanceOf(sender).mul(txLimitRate).div(100);
            require(
                amount <= limitAmount,
                "ERR: Can't sell more than limit rate"
            );

            if (
                blkTime > tradeHistory[sender].lastTradeTime + secondLimitSell
            ) {
                tradeHistory[sender].lastTradeTime = blkTime;
                tradeHistory[sender].amount = amount;
            } else if (
                (blkTime <
                    tradeHistory[sender].lastTradeTime + secondLimitSell) &&
                ((blkTime > tradeHistory[sender].lastTradeTime))
            ) {
                require(
                    tradeHistory[sender].amount + amount <= limitAmount,
                    "ERR: Can't sell more than limit rate in One day"
                );
                tradeHistory[sender].amount =
                    tradeHistory[sender].amount +
                    amount;
            }
        }

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = gonAmount;
        uint256 mgmFee = 0;
        if (shouldTakeFee(sender, recipient)) {
            (gonAmountReceived, mgmFee) = takeFee(
                sender,
                recipient,
                gonAmount,
                amount
            );
        }
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        if (mgmFee > 0) {
            swapMgm(
                recipient == pair ? sender : recipient,
                mgmFee,
                recipient != pair
            );
        }

        if (recipient != pair) {
            boughtAmount[recipient] = boughtAmount[recipient].add(
                gonAmountReceived.div(_gonsPerFragment)
            );
        }

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount,
        uint256 amount
    ) internal returns (uint256, uint256) {
        uint256 _totalFee;
        uint256 _firePitFee;
        uint256 _treasuryFee;
        uint256 _insuranceFundFee;
        uint256 _mgmFee;
        uint256 taxedGons = gonAmount;

        if (recipient == pair) {
            //Sell
            _totalFee = totalFeeS;
            _firePitFee = firePitFeeS;
            _treasuryFee = treasuryFeeS;
            _insuranceFundFee = insuranceFundFeeS;
            _mgmFee = mgmFeeS;

            uint256 _boughtAmount = boughtAmount[msg.sender];
            if (_boughtAmount <= minTaxFreeExemp) {
                uint256 mgmAmount = gonAmount.div(feeDenominator).mul(_mgmFee);
                _gonBalances[address(this)] = _gonBalances[address(this)].add(
                    mgmAmount
                );

                emit Transfer(
                    sender,
                    address(this),
                    mgmAmount.div(_gonsPerFragment)
                );
                return (gonAmount.sub(mgmAmount), mgmAmount);
            }

            uint256 taxedAmount = amount > _boughtAmount
                ? _boughtAmount
                : amount;
            boughtAmount[msg.sender] = _boughtAmount.sub(taxedAmount);
            taxedGons = taxedAmount.mul(_gonsPerFragment);
        } else {
            //Buy or transfer
            _totalFee = totalFeeB;
            _firePitFee = firePitFeeB;
            _treasuryFee = treasuryFeeB;
            _insuranceFundFee = insuranceFundFeeB;
            _mgmFee = mgmFeeB;
        }

        uint256 feeAmount = taxedGons.div(feeDenominator).mul(_totalFee);
        uint256 mgmAmount = gonAmount.div(feeDenominator).mul(_mgmFee);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            taxedGons.div(feeDenominator).mul(_firePitFee)
        );
        _gonBalances[address(this)] = _gonBalances[address(this)]
            .add(taxedGons.div(feeDenominator).mul(_totalFee.sub(_firePitFee)))
            .add(mgmAmount);

        emit Transfer(
            sender,
            address(this),
            (feeAmount.add(mgmAmount)).div(_gonsPerFragment)
        );
        return (gonAmount.sub(feeAmount).sub(mgmAmount), mgmAmount);
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        if (amountToSwap == 0) {
            return;
        }

        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountEthPayout = address(this).balance.sub(balanceBefore);

        (bool success, ) = payable(treasuryReceiver).call{
            value: amountEthPayout.mul(totalFeeBnb).div(treasuryFeeRate),
            gas: 30000
        }("");
        (success, ) = payable(insuranceFundReceiver).call{
            value: amountEthPayout.mul(totalFeeBnb).div(insuranceFundFeeRate),
            gas: 30000
        }("");
    }

    function swapMgm(
        address child,
        uint256 amount,
        bool isBuy
    ) internal swapping {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 amountEthPayout = address(this).balance.sub(balanceBefore);
        addMgmAmount(child, amountEthPayout, isBuy);
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        require(
            amountToSwap > 0,
            "There is no SELO token deposited in token contract"
        );
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

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        if (_isFeeExempt[from]) {
            return false;
        }
        if (transferFeeEnable) {
            return true;
        }
        return pair == from || pair == to;
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 20 minutes);
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function allowance(address owner_, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = _allowedFragments[msg.sender][
            spender
        ].add(addedValue);
        emit Approval(
            msg.sender,
            spender,
            _allowedFragments[msg.sender][spender]
        );
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function checkFeeExempt(address _addr) external view returns (bool) {
        return _isFeeExempt[_addr];
    }

    function getCirculatingSupply() public view returns (uint256) {
        return
            (TOTAL_GONS.sub(_gonBalances[DEAD]).sub(_gonBalances[ZERO])).div(
                _gonsPerFragment
            );
    }

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function manualSync() external {
        IPancakeSwapPair(pair).sync();
    }

    function setFeeReceivers(
        address _treasuryReceiver,
        address _insuranceFundReceiver,
        address _firePit
    ) external onlyOwner {
        treasuryReceiver = _treasuryReceiver;
        insuranceFundReceiver = _insuranceFundReceiver;
        firePit = _firePit;
    }

    function setWhitelist(address[] calldata _addrs, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = flag;
        }
    }

    function setPairAddress(address _pair) public onlyOwner {
        pair = _pair;
        setMgmPair(pair);
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function setLimitSaleRate(uint256 _limitSellRate) external onlyOwner {
        limitSellRate = _limitSellRate;
    }

    function setLimitSaleRateDiscount(uint256 _limitSellRateDiscount)
        external
        onlyOwner
    {
        limitSellRateDiscount = _limitSellRateDiscount;
    }

    function setSecondLimitSell(uint256 _secondLimitSell) external onlyOwner {
        secondLimitSell = _secondLimitSell;
    }

    function setEnableTransferFee(bool enable) external onlyOwner {
        transferFeeEnable = enable;
    }

    function setTradingEnabled(bool enable) external onlyOwner {
        tradingEnabled = enable;
    }

    function getDecimal() external view override returns (uint256) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    function taxFreeAmount(address addr) external view returns (uint256) {
        if (!(boughtAmount[addr] >= _gonBalances[addr].div(_gonsPerFragment))) {
            return
                (_gonBalances[addr].div(_gonsPerFragment)).sub(
                    boughtAmount[addr]
                );
        }
        return 0;
    }

    function setOperator(address operatorAddress, bool value)
        external
        onlyOwner
    {
        require(
            operatorAddress != address(0),
            "operatorAddress is zero address"
        );
        _operators[operatorAddress] = value;
        emit OperatorSetted(operatorAddress, value);
    }

    event OperatorSetted(address operatorAddress, bool value);
}

pragma solidity ^0.7.4;

import "./IERC20.sol";

abstract contract ERC20Detailed is IERC20 {
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

pragma solidity ^0.7.4;

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.7.4;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

pragma solidity ^0.7.4;

interface IPancakeSwapPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

pragma solidity ^0.7.4;

interface IPancakeSwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

pragma solidity ^0.7.4;

interface IPancakeSwapFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

pragma solidity ^0.7.4;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapPair.sol";
import "./Ownable.sol";

contract MGMController is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    //MGM
    uint256 public mgmFeeB = 50;
    uint256[] public mgmFeeBDetail = [50, 0];
    uint256 public mgmFeeS = 150;
    uint256[] public mgmFeeSDetail = [100, 50];
    uint256 public minHoldBnb = 0.03 * 10**18;
    uint256 private feeDenominator = 1000;

    struct Profile {
        uint256 amount;
        uint256 totalRealised;
    }

    mapping(address => address) mgmTree;
    mapping(address => Profile) profiles;
    address _pair;

    function addParent(address _parent) external {
        require(_parent != address(0), "Zero address");
        require(_parent != msg.sender, "Add yourself");
        require(mgmTree[msg.sender] == address(0), "Already add");
        require(!isContract(_parent), "Invalid address");

        address parentF = _parent;
        for (uint32 i = 1; i <= 3; i++) {
            parentF = mgmTree[parentF];
            require(
                parentF == address(0) || parentF != msg.sender,
                "Invalid tree"
            );
        }
        mgmTree[msg.sender] = _parent;
        emit AddMgm(msg.sender, _parent);
    }

    function addMgmAmount(
        address from,
        uint256 amount,
        bool isBuy
    ) internal {
        address f1 = mgmTree[from];
        address f0 = mgmTree[f1];

        if (f1 != address(0)) {
            uint256 f1Amount = amount.mul(
                (isBuy ? mgmFeeBDetail[0] : mgmFeeSDetail[0]).div(
                    feeDenominator
                )
            );
            profiles[f1].amount = profiles[f1].amount.add(f1Amount);
            emit AddMgmAmount(from, f1, 1, f1Amount);
        }

        if (f0 != address(0)) {
            uint256 f0Amount = amount.mul(
                (isBuy ? mgmFeeBDetail[1] : mgmFeeSDetail[1]).div(
                    feeDenominator
                )
            );
            profiles[f0].amount = profiles[f0].amount.add(f0Amount);
            emit AddMgmAmount(from, f0, 2, f0Amount);
        }
    }

    function claim() external {
        require(isValidBalance(msg.sender), "Not hold enough token");

        uint256 claimAmount = profiles[msg.sender].amount;
        require(claimAmount > 0, "Not enough balance to claim");
        profiles[msg.sender].amount = 0;
        profiles[msg.sender].totalRealised += claimAmount;

        (bool success, ) = payable(msg.sender).call{
            value: claimAmount,
            gas: 30000
        }("");
        require(success, "Failure");
    }

    function isValidBalance(address addr) public returns (bool) {
        IERC20 token = IERC20(address(this));
        uint256 decimal = token.getDecimal();
        uint256 balance = token.balanceOf(addr);

        IPancakeSwapPair pair = IPancakeSwapPair(_pair);
        (uint256 _reserve0, uint256 _reserve1, ) = pair.getReserves();
        uint256 priceInBnb = pair.token0() == address(this)
            ? _reserve1.div(_reserve0.mul(10**(18 - decimal)))
            : _reserve0.div(_reserve1.mul(10**(18 - decimal)));

        return
            priceInBnb.mul(balance.div(10**decimal)).mul(10**18) >= minHoldBnb;
    }

    function setMgmPair(address pair) internal {
        _pair = pair;
    }

    function setMinHoldBnb(uint256 amount) external onlyOwner {
        minHoldBnb = amount;
    }

    function setMgmFeeB(uint256 _mgmFeeB, uint256[] calldata _mgmFeeBDetail)
        external
        onlyOwner
    {
        mgmFeeB = _mgmFeeB;
        mgmFeeBDetail[0] = _mgmFeeBDetail[0];
        mgmFeeBDetail[1] = _mgmFeeBDetail[1];
    }

    function setMgmFeeS(uint256 _mgmFeeS, uint256[] calldata _mgmFeeSDetail)
        external
        onlyOwner
    {
        mgmFeeS = _mgmFeeS;
        mgmFeeSDetail[0] = _mgmFeeSDetail[0];
        mgmFeeSDetail[1] = _mgmFeeSDetail[1];
    }

    function mgmProfile(address addr) external view returns (uint256, uint256) {
        return (profiles[addr].amount, profiles[addr].totalRealised);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    event AddMgm(address child, address parent);
    event AddMgmAmount(address from, address to, uint32 level, uint256 amount);
}

pragma solidity ^0.7.4;

interface IERC20 {
    function getDecimal() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}