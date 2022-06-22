pragma solidity ^0.8.9;

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

interface IERC20 {
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

contract LockToken is Ownable {
    bool public isOpen = false;
    mapping(address => bool) private _whiteList;
    modifier open(address from, address to) {
        require(isOpen || _whiteList[from] || _whiteList[to], "Not Open");
        _;
    }

    constructor() {
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;
    }

    function openTrade() public onlyOwner {
        isOpen = true;
    }

    function stopTrade() external onlyOwner {
        isOpen = false;
    }

    function includeToWhiteList(address[] memory _users) external onlyOwner {
        for(uint8 i = 0; i < _users.length; i++) {
            _whiteList[_users[i]] = true;
        }
    }
}

interface IPancakeSwapRouter{
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
            address token,
            uint amountTokenDesired,
            uint amountTokenMin,
            uint amountETHMin,
            address to,
            uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeSwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IPancakePair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract Impact is Ownable, LockToken, IERC20 {

    using SafeMath for uint256;

    string private _name = "Impact Finance";
    string private _symbol = "IF";

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => bool) private blacklist;
    mapping(address => uint256) private lastRebased;
    mapping(address => uint256) private sumPrices;
    mapping(address => uint256) private sumAmounts;
    mapping(address => bool) private rebaseExempt;
    mapping(address => bool) private feeExempt;

    uint256[] public price;
    uint256 public constant REBASE_PERIOD = 2;
    uint256 public REBASE_RATE = 342;
    uint8 public constant RATE_DECIMALS = 6;
    uint8 public constant DECIMALS = 5;

    uint24 rebaseCapPerTx = 10000;

    uint256 public supplyCapReachedAt;

    uint256 private constant INITIAL_SUPPLY = 500_000 * 10**DECIMALS;
    uint256 private constant MAX_TO_INITIAL_RATIO = 10 ** 3;
    uint256 public constant MAX_SUPPLY = INITIAL_SUPPLY * MAX_TO_INITIAL_RATIO;

    uint256 private liquidityAddPeriod = 1 hours;

    uint256 maxSwapBackAmount = 500 * 10 ** DECIMALS;
    uint256 minSwapBackAmount = 50 * 10 ** DECIMALS;

    uint256 public liquidityFee = 2;
    uint256 public treasuryFee = 4;
    uint256 public burnFee = 2;

    uint256 public liquidityFeeSell = 4;
    uint256 public treasuryFeeSell = 8;
    uint256 public burnFeeSell = 2;
    
    uint256 devFeeNumerator = 1;
    uint256 devFeeDenominator = 4;
    uint256 public feeDenominator = 100;

    uint256 public initialRebaseTime;
    uint256 public lastGlobalRebaseTime;
    
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public devWallet;

    bool private first;

    IPancakeSwapRouter public router;
    address public pair;

    bool public swapEnabled = true;
    bool private inSwap;
    bool private swapBackEnabled = true;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    bool public _autoRebase;
    bool public _autoAddLiquidity;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;

    constructor() Ownable() {

        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); 
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );
        first = IPancakePair(pair).token0() == address(this) ? true : false;
        autoLiquidityReceiver = 0x5562640B953b6c2f79a655E930aFa68b2a65C627;
        devWallet = 0xD44FbeB26c88F0f18f72664E3c446E0C2836908D;
        treasuryReceiver = msg.sender;

        allowances[address(this)][address(router)] = ~uint(0);
        allowances[treasuryReceiver][address(router)] = ~uint(0);

        _totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        _autoAddLiquidity = true;
        
        feeExempt[treasuryReceiver] = true;
        feeExempt[address(this)] = true;
        feeExempt[msg.sender] = true;

        rebaseExempt[pair] = true;

        emit Transfer(address(0x0), treasuryReceiver, _totalSupply);
    }

    function getETHValue(uint256 tokenAmount) public view returns (uint256 ethValue) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        ethValue = router.getAmountsOut(tokenAmount, path)[1];
    }

    function launch() external onlyOwner {
        openTrade();
        setAutoRebaseStatus(true);
    }

    function getPrice() view internal returns (uint256) {
        (uint256 r0, uint256 r1,) = IPancakePair(pair).getReserves();
        if (r1 == 0 || r0 == 0) return 0;
        uint256 currentReserve = first ? r0 : r1;
        uint256 bnbReserve = first ? r1 : r0;
        return bnbReserve.mul(1e18).div(currentReserve);
    }

    function priceUpdate() public {
        if (!_autoRebase) return;
        
        uint256 deltaTime = block.timestamp - lastGlobalRebaseTime;
        uint256 count = deltaTime.div(REBASE_PERIOD);
        if (count == 0) return;
        
        for (uint24 i = 0; i < count; i++) {
            price.push(getPrice());
        }
        lastGlobalRebaseTime = lastGlobalRebaseTime.add(count.mul(REBASE_PERIOD));
    }

    function balanceOf(address _address) external view override returns (uint256 balance) {
        if (!shouldRebase(_address)){
            return balances[_address];
        }
        balance = getNewBalance(_address, true);
    }

    function rebaseCountSinceStart() external view returns (uint256 count) {
        if (initialRebaseTime == 0) return 0;
        uint256 timestamp = supplyCapReachedAt == 0 ? block.timestamp : supplyCapReachedAt;
        uint256 deltaTime = timestamp - initialRebaseTime;
        count = deltaTime.div(REBASE_PERIOD);
    }

    function rebase(address _address) internal {
        uint256 balanceBefore = balances[_address];
        uint256 newBalance = getNewBalance(_address, false);
        uint256 rebaseAmount = newBalance - balanceBefore;
        balances[_address] += rebaseAmount;
        _totalSupply += rebaseAmount;
        if (_totalSupply >= MAX_SUPPLY && supplyCapReachedAt == 0){
            supplyCapReachedAt = block.timestamp;
        }
        
        lastRebased[_address] = lastGlobalRebaseTime;
        emit Transfer(address(0x0), _address, rebaseAmount);
    }

    function getNewBalance(address _address, bool v) public view returns(uint256 newBalance) {
        
        if (initialRebaseTime == 0) return balances[_address];
        uint256 _lastRebase = lastRebased[_address] == 0 ? initialRebaseTime : lastRebased[_address];
        
        uint256 endTimeStamp = supplyCapReachedAt == 0 ? block.timestamp : supplyCapReachedAt;
        uint256 deltaTime = endTimeStamp - _lastRebase;
        uint24 times = uint24(deltaTime / REBASE_PERIOD);
        uint24 totalTimes = uint24((lastGlobalRebaseTime - initialRebaseTime) / REBASE_PERIOD);
        
        newBalance = balances[_address];
        times = times > rebaseCapPerTx ? rebaseCapPerTx : times;

        if (_address == address(this) || v){
            for (uint24 i = 0; i < times; i++) {
                newBalance = newBalance * (10**RATE_DECIMALS + REBASE_RATE) / 10**RATE_DECIMALS;
            }
        } else {
            uint24 startIndex = totalTimes - times;
            uint256 entry = sumPrices[_address] / sumAmounts[_address];
            uint256 priceAtRebase;
            uint256 rebaseMultiplier;
            for (uint24 i = 0; i < times; i++) {
                priceAtRebase = price[startIndex + i];
                rebaseMultiplier = priceAtRebase < entry ? 10 - priceAtRebase * 10 / entry : 0;
                newBalance = newBalance * (10**RATE_DECIMALS + REBASE_RATE + rebaseMultiplier * 25) / 10 ** RATE_DECIMALS;
            }
        }
    }

    function transfer(address to, uint256 value) external override validRecipient(to) returns (bool) {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override validRecipient(to) returns (bool) {
        if (allowances[from][msg.sender] != ~uint256(0)) {
            allowances[from][msg.sender] = allowances[from][msg.sender].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool) {
        balances[from] = balances[from].sub(amount);
        balances[to] = balances[to].add(amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal open(sender, recipient) returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "blacklisted");

        priceUpdate();

        if (shouldRebase(sender)) rebase(sender);
        if (shouldRebase(recipient)) rebase(recipient);
        
        if (inSwap) return _basicTransfer(sender, recipient, amount);
        if (shouldSwapBack()) swapBack();
        if (shouldAddLiquidity()) addLiquidity();
        
        balances[sender] -= amount;
        uint256 amountReceived = shouldTakeFee(sender, recipient) ? takeFee(sender, recipient, amount) : amount;
        uint256 p = getPrice();
        if (p>0){
            sumPrices[recipient] += p * amountReceived;
            sumAmounts[recipient] += amountReceived;
        }
        
        balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
        return true;
    }

    function takeFee(address sender, address recipient, uint256 amount) internal  returns (uint256) {
        
        uint256 _burnFee = burnFee;
        uint256 _treasuryFee = treasuryFee;
        uint256 _liquidityFee = liquidityFee;
        
        if (recipient == pair) {
            _burnFee = burnFeeSell;
            _treasuryFee = treasuryFeeSell;
            _liquidityFee = liquidityFeeSell;
        }

        uint256 _totalFee = _treasuryFee + _burnFee + _liquidityFee;
        uint256 feeAmount = amount.div(feeDenominator).mul(_totalFee);

        uint256 toBurn = feeAmount.div(_totalFee).mul(_burnFee);
        uint256 toSwapBack = feeAmount.div(_totalFee).mul(_treasuryFee);
        uint256 toLiquidity = feeAmount.sub(toSwapBack).sub(toBurn);

        balances[ZERO] = balances[ZERO].add(toBurn);
        balances[address(this)] = balances[address(this)].add(toSwapBack);
        balances[autoLiquidityReceiver] = balances[autoLiquidityReceiver].add(toLiquidity);
        
        emit Transfer(sender, address(this), toSwapBack.add(toLiquidity));
        emit Transfer(sender, ZERO, toBurn);
        return amount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = balances[autoLiquidityReceiver];
        balances[address(this)] += balances[autoLiquidityReceiver];
        balances[autoLiquidityReceiver] = 0;
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) return;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

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
                autoLiquidityReceiver,
                block.timestamp
            );
        }
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = balances[address(this)];
        amountToSwap = amountToSwap > maxSwapBackAmount ? maxSwapBackAmount : amountToSwap;
        if(amountToSwap == 0 || amountToSwap < minSwapBackAmount) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 toDistribute = address(this).balance - balanceBefore;
        uint256 devPart = toDistribute.mul(devFeeNumerator).div(devFeeDenominator);
        uint256 treasuryPart = toDistribute.sub(devPart);
        payable(treasuryReceiver).transfer(treasuryPart);
        payable(devWallet).transfer(devPart);
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = balances[address(this)];
        require( amountToSwap > 0,"There is no token to withdraw");
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

    function shouldTakeFee(address from, address to) internal view returns (bool){
        return !feeExempt[from] && !feeExempt[to];
    }

    function shouldRebase(address _address) internal view returns (bool) {
        return !rebaseExempt[_address] && initialRebaseTime != 0 && _autoRebase && block.timestamp >= (lastRebased[_address] + REBASE_PERIOD) && (lastRebased[_address] < supplyCapReachedAt || supplyCapReachedAt == 0) && balances[_address] > 0;
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity && 
            !inSwap && 
            msg.sender != pair &&
            block.timestamp >= (_lastAddLiquidityTime + liquidityAddPeriod);
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair && swapBackEnabled; 
    }

    function setAutoRebaseStatus(bool status) public onlyOwner {
        if (status){
            initialRebaseTime = block.timestamp;
            lastGlobalRebaseTime = block.timestamp;
        }
        _autoRebase = status;
    }

    function setSwapBackDetails(uint256 min, uint256 max, bool status) external onlyOwner {
        minSwapBackAmount = min;
        maxSwapBackAmount = max;
        swapBackEnabled = status;
    }

    function setAutoAddLiquidityStatus(bool status) external onlyOwner {
        if(status) {
            _autoAddLiquidity = status;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = status;
        }
    }

    function allowance(address owner_, address spender) external view override returns (uint256) {
        return allowances[owner_][spender];
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 oldValue = allowances[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            allowances[msg.sender][spender] = 0;
        } else {
            allowances[msg.sender][spender] = oldValue.sub(
                subtractedValue
            );
        }
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        allowances[msg.sender][spender] = allowances[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool){
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function isFeeExempt(address _address) external view returns (bool) {
        return feeExempt[_address];
    }

    function isRebaseExempt(address _address) external view returns (bool) {
        return rebaseExempt[_address];
    }

    function setFeeReceivers( address _autoLiquidityReceiver, address _treasuryReceiver, address _devWallet) external onlyOwner {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        devWallet = _devWallet;
    }

    function setFeeExemptStatus(address _address, bool status) external onlyOwner {
        feeExempt[_address] = status;
    }

    function setBlacklistStatus(address _address, bool status) external onlyOwner {
        blacklist[_address] = status;    
    }

    function setRebaseExemptStatus(address _address, bool status) external onlyOwner {
        rebaseExempt[_address] = status;    
    }
    
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function setFees(uint256 newLiquidityFee, uint256 newtreasuryFee, uint256 newburnFee) external onlyOwner {
        liquidityFee = newLiquidityFee;
        treasuryFee = newtreasuryFee;
        burnFee = newburnFee;
    }
    function setSellFees(uint256 newLiquidityFee, uint256 newtreasuryFee, uint256 newburnFee) external onlyOwner {
        liquidityFeeSell = newLiquidityFee;
        treasuryFeeSell = newtreasuryFee;
        burnFeeSell = newburnFee;
    }

    function setDevFees(uint256 num, uint256 den) external onlyOwner {
        devFeeNumerator = num;
        devFeeDenominator = den;
    }

    function setFeeDenominator(uint256 newDenominator) external onlyOwner {
        feeDenominator = newDenominator;
    }

    function manualRebase(address _address) external {
        rebase(_address);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function multiSendTokens(address[] calldata addresses, uint256[] calldata amounts) public onlyOwner{
        require(addresses.length == amounts.length && addresses.length <= 1000, "Error in arguments");
        for(uint256 i=0; i < addresses.length; i++){
            _basicTransfer(msg.sender, addresses[i], amounts[i]);
        }
    }

    function sweepTokens(address token, address recipient) public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(recipient, amount);
    }

    // function APY() external view returns (uint256 apy) {
    //     apy = 10 ** 5;
    //     uint24 power = 12;
    //     uint24 times = 17520;
    //     uint24 timesNew = times / power;
    //     uint24 remainder = times % power;
    //     for (uint24 i = 0; i < timesNew; i++) {
    //         apy = apy
    //             .mul(((10**RATE_DECIMALS).add(REBASE_RATE)) ** power)
    //             .div(10**RATE_DECIMALS ** power);
    //     }
    //     for (uint24 i = 0; i < remainder; i++) {
    //         apy = apy
    //             .mul((10**RATE_DECIMALS).add(REBASE_RATE))
    //             .div(10**RATE_DECIMALS);
    //     }
    //     apy = apy.div(10 ** 3);
    // }

    receive() external payable {}
}