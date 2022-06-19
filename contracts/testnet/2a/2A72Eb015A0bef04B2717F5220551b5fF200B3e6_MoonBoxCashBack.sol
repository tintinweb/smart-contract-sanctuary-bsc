// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapPair.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapFactory.sol";
import "./IMoonBoxAffiliate.sol";
import "hardhat/console.sol";

contract MoonBoxTest is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "MoonBox";
    string public _symbol = "MoonBox";
    uint8 public _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) _isWhiteList;
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

    uint256 public limitSellRate = 100;
    uint256 public limitSellRateBonus = 100;
    uint256 public limitSellRateReduce = 100;
    uint256 public limitSellRateBonusPr = 100;
    uint256 public secondLimitSell = 420;
    uint256 public maxSellTransactionAmount = 2500000 * 10**DECIMALS;

    struct Trader {
        uint256 lastTradeTime;
        uint256 amount;
        uint256 limitAmount;
        uint256 totalBuy;
        uint256 totalSell;
    }

    struct Pr {
        bool enable;
        uint256 amount;
    }

    mapping(address => Trader) public tradeHistory;
    mapping(address => uint256) public boughtAmount;
    mapping(address => Pr) public prs;

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
    bool public transferEnabled = true;

    //Rate fee
    uint256 public treasuryFeeRate = 500;
    uint256 public insuranceFundFeeRate = 500;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public treasuryReceiver;
    address public insuranceFundReceiver;
    address public firePit;
    IPancakeSwapRouter public router;
    IMoonBoxAffiliate affiliate;
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

    constructor(address mgmAddr)
        ERC20Detailed("MoonBox", "MoonBox", uint8(DECIMALS))
        Ownable()
    {
        require(mgmAddr != address(0), "Zero address");
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

        treasuryReceiver = 0xB9DffCE05FD93f82981242Ab8c2949D5230f4d1F;
        insuranceFundReceiver = 0xA24E8a58df3011f522EbCaDA803a690a7920ED6e;
        firePit = 0xE6F1F6638EBaC6c9c0c681FA3B7D48DC3d723c69;

        affiliate = IMoonBoxAffiliate(mgmAddr);

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);
        _allowedFragments[address(this)][address(this)] = uint256(-1);
        _allowedFragments[mgmAddr][address(router)] = uint256(-1);
        _allowedFragments[mgmAddr][pair] = uint256(-1);
        _allowedFragments[mgmAddr][mgmAddr] = uint256(-1);
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
        _isFeeExempt[address(router)] = true;
        _isFeeExempt[mgmAddr] = true;

        _isWhiteList[msg.sender] = true;

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
        console.log(msg.sender);
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
        boughtAmount[to] = boughtAmount[to].add(amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (_isWhiteList[sender] || _isWhiteList[recipient]) {
            return _basicTransfer(sender, recipient, amount);
        }

        bool isTransfer = sender != pair && recipient != pair;
        bool isSell = recipient == pair;
        if (sender == pair || recipient == pair) {
            require(tradingEnabled == true, "Trading not open yet");
        } else if (isTransfer) {
            require(transferEnabled == true, "Transfer not open yet");
        }

        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        if (inSwap || excludedAccount) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (isSell || isTransfer) {
            require(amount <= maxSellTransactionAmount, "Error amount");
            uint256 blkTime = block.timestamp;
            uint256 txLimitRate = getSellLimitRate(sender);

            if (
                blkTime > tradeHistory[sender].lastTradeTime + secondLimitSell
            ) {
                uint256 limitAmount = balanceOf(sender).mul(txLimitRate).div(
                    feeDenominator
                );
                require(
                    amount <= limitAmount,
                    "ERR: Can't sell more than limit rate"
                );
                tradeHistory[sender].lastTradeTime = blkTime;
                tradeHistory[sender].amount = amount;
                tradeHistory[sender].limitAmount = limitAmount;
            } else {
                require(
                    tradeHistory[sender].amount.add(amount) <=
                        tradeHistory[sender].limitAmount,
                    "ERR: Can't sell more than limit rate in One day"
                );
                tradeHistory[sender].amount = tradeHistory[sender].amount.add(
                    amount
                );
            }
        }

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack() && (sender == pair || recipient == pair)) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        (uint256 gonAmountReceived, uint256 gonMgmFee) = shouldTakeFee(
            sender,
            recipient
        )
            ? takeFee(sender, recipient, gonAmount, amount)
            : (gonAmount, 0);
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        if (isSell) {
            tradeHistory[sender].totalSell = tradeHistory[sender].totalSell.add(
                amount
            );
        } else {
            tradeHistory[recipient].totalBuy = tradeHistory[recipient]
                .totalBuy
                .add(gonAmountReceived.div(_gonsPerFragment));
        }

        if (gonMgmFee > 0) {
            affiliate.setAffiliateRevenue(
                isSell ? sender : recipient,
                gonMgmFee.div(_gonsPerFragment),
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

    function getSellLimitRate(address _address) public view returns (uint256) {
        uint256 bonus;
        if (
            prs[_address].enable &&
            tradeHistory[_address].totalSell < prs[_address].amount
        ) {
            bonus = limitSellRateBonusPr;
        } else {
            bonus = affiliate.getF0(_address) == address(0)
                ? 0
                : limitSellRateBonus;
        }
        uint256 reduce = tradeHistory[_address].totalBuy > 0 &&
            tradeHistory[_address].totalBuy < tradeHistory[_address].totalSell
            ? limitSellRateReduce
            : 0;
        return limitSellRate.add(limitSellRateBonus).sub(reduce);
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount,
        uint256 amount
    ) internal returns (uint256, uint256) {
        uint256 _totalFee;
        uint256 _firePitFee;
        uint256 _mgmFee;
        uint256 taxedGons = gonAmount;

        if (recipient == pair) {
            //Sell
            _totalFee = totalFeeS;
            _firePitFee = firePitFeeS;
            _mgmFee = affiliate.getTotalAffiliateSell();

            uint256 _boughtAmount = boughtAmount[sender];
            if (_boughtAmount == 0) {
                uint256 affiliateAmount = gonAmount.mul(_mgmFee).div(
                    feeDenominator
                );
                _gonBalances[address(affiliate)] = _gonBalances[
                    address(affiliate)
                ].add(affiliateAmount);

                emit Transfer(
                    sender,
                    address(affiliate),
                    affiliateAmount.div(_gonsPerFragment)
                );
                return (gonAmount.sub(affiliateAmount), affiliateAmount);
            }

            uint256 taxedAmount = amount > _boughtAmount
                ? _boughtAmount
                : amount;
            boughtAmount[sender] = _boughtAmount.sub(taxedAmount);
            taxedGons = taxedAmount.mul(_gonsPerFragment);
        } else {
            //Buy or transfer
            _totalFee = totalFeeB;
            _firePitFee = firePitFeeB;
            _mgmFee = affiliate.getTotalAffiliateBuy();
        }

        uint256 feeAmount = taxedGons.mul(_totalFee).div(feeDenominator);
        uint256 affiliateAmount = gonAmount.mul(_mgmFee).div(feeDenominator);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            taxedGons.mul(_firePitFee).div(feeDenominator)
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            taxedGons.mul(_totalFee.sub(_firePitFee)).div(feeDenominator)
        );
        _gonBalances[address(affiliate)] = _gonBalances[address(affiliate)].add(
            affiliateAmount
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        emit Transfer(
            sender,
            address(affiliate),
            affiliateAmount.div(_gonsPerFragment)
        );
        return (gonAmount.sub(feeAmount).sub(affiliateAmount), affiliateAmount);
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        if (amountToSwap == 0) {
            return;
        }

        uint256 amountEthPayout = swapTokenToBnb(amountToSwap, address(this));
        (bool success, ) = payable(treasuryReceiver).call{
            value: amountEthPayout.mul(treasuryFeeRate).div(feeDenominator),
            gas: 30000
        }("");
        (success, ) = payable(insuranceFundReceiver).call{
            value: amountEthPayout.mul(insuranceFundFeeRate).div(
                feeDenominator
            ),
            gas: 30000
        }("");
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        require(
            amountToSwap > 0,
            "There is no token deposited in token contract"
        );
        swapTokenToBnb(amountToSwap, treasuryReceiver);
    }

    function swapTokenToBnb(uint256 amountToSwap, address to)
        internal
        returns (uint256 amountEthPayout)
    {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            to,
            block.timestamp
        );
        amountEthPayout = address(this).balance.sub(balanceBefore);
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

    function setFeeExemp(address[] calldata _addrs, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = flag;
        }
    }

    function setWhiteList(address[] calldata _addrs, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isWhiteList[_addrs[i]] = flag;
        }
    }

    function setPr(
        address[] calldata _addrs,
        uint256[] calldata _amounts,
        bool flag
    ) external onlyOwner {
        require(_addrs.length == _amounts.length, "1");
        for (uint256 i = 0; i < _addrs.length; i++) {
            prs[_addrs[i]].enable = flag;
            prs[_addrs[i]].amount = _amounts[i];
        }
    }

    function setPairAddress(address _pair) public onlyOwner {
        pair = _pair;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function setLimitSaleRate(uint256 _limitSellRate) external onlyOwner {
        limitSellRate = _limitSellRate;
    }

    function setLimitSaleRateBonus(uint256 _limitSellRateBonus)
        external
        onlyOwner
    {
        limitSellRateBonus = _limitSellRateBonus;
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

    function setTransferEnabled(bool enable) external onlyOwner {
        transferEnabled = enable;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    function setMoonBoxAffiliate(address addr) external onlyOwner {
        require(addr != address(0), "Zero address");
        affiliate = IMoonBoxAffiliate(addr);
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

    fallback() external payable {}

    event OperatorSetted(address operatorAddress, bool value);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IMoonBoxAffiliate {
    function setAffiliateRevenue(
        address from,
        uint256 amount,
        bool isBuy
    ) external;

    function claim() external;

    function getAffiliate(address _address) external view returns (uint256, uint256);

    function getF0(address _address) external view returns (address);

    function getTotalAffiliateBuy() external view returns (uint256);

    function getTotalAffiliateSell() external view returns (uint256);

    event SetF0(address f0, address f1);
    event SetAffiliateRevenue(address from, address to, uint32 level, uint256 amount);
    event Claim(address addr, uint256 amount, uint256 amountBnb);
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapPair.sol";
import "./IMoonBoxAffiliate.sol";
import "./IMoonBoxLottery.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract MoonBoxAffiliate is Ownable, ReentrancyGuard, IMoonBoxAffiliate {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Affiliate {
        uint256 amount;
        uint256 totalClaim;
        uint256 totalClaimBnb;
    }

    mapping(address => bool) public _operators;
    uint256 totalAffiliateBuy = 140;
    uint256 totalAffiliateSell = 80;
    uint256[] affiliateBuyLevel = [80, 30, 10, 10, 5, 3, 2];
    uint256[] affiliateSellLevel = [50, 10, 10, 4, 3, 2, 1];
    uint256 holdAmountInBnb = 0.001 * 10**18;
    uint256 constant denominator = 1000;
    mapping(address => address) affiliateLevels;
    mapping(address => Affiliate) affiliates;
    IPancakeSwapPair public pair;
    IPancakeSwapRouter public router;
    uint256 public totalReceived;
    IERC20 public token;
    address public treasuryWallet;
    IMoonBoxLottery public moonboxLottery;

    modifier onlyOperator() {
        require(_operators[msg.sender], "Forbidden");
        _;
    }

    constructor(address _treasuryWallet) {
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        treasuryWallet = _treasuryWallet;
        _operators[msg.sender] = true;
        _operators[address(router)] = true;
    }

    function setF0(address _f1) external {
        require(_f1 != address(0), "0 address");
        require(_f1 != msg.sender, "Add yourself");
        require(affiliateLevels[msg.sender] == address(0), "Already add");
        require(!isContract(_f1), "Invalid address");

        address parentF = _f1;
        for (uint32 i = 1; i <= 8; i++) {
            parentF = affiliateLevels[parentF];
            require(parentF == address(0) || parentF != msg.sender, "Circle");
        }
        affiliateLevels[msg.sender] = _f1;
        emit SetF0(msg.sender, _f1);
    }

    function setAffiliateRevenue(
        address from,
        uint256 amount,
        bool isBuy
    ) external override onlyOperator {
        address f1 = affiliateLevels[from];
        uint256 totalFee = isBuy ? totalAffiliateBuy : totalAffiliateSell;
        uint256 payoutAmount = 0;
        for (uint32 i = 0; i <= 6; i++) {
            if (f1 != address(0)) {
                uint256 levelFee = isBuy
                    ? affiliateBuyLevel[i]
                    : affiliateSellLevel[i];
                if (levelFee == 0) {
                    f1 = affiliateLevels[f1];
                    continue;
                }
                uint256 f1Amount = amount
                    .mul(levelFee.mul(denominator).div(totalFee))
                    .div(denominator);
                affiliates[f1].amount = affiliates[f1].amount.add(f1Amount);
                emit SetAffiliateRevenue(from, f1, i + 1, f1Amount);
                f1 = affiliateLevels[f1];
                payoutAmount = payoutAmount.add(f1Amount);
            } else {
                break;
            }
        }
        totalReceived = totalReceived.add(payoutAmount);
        uint256 unRefAmount = amount.sub(payoutAmount);
        if (unRefAmount > 0) {
            try moonboxLottery.donate(unRefAmount.div(2)) {} catch {}
        }
    }

    function claim() external override nonReentrant {
        uint256 claimAmount = affiliates[msg.sender].amount;
        require(claimAmount > 0, "Not enough balance to claim");
        affiliates[msg.sender].amount = 0;
        affiliates[msg.sender].totalClaim = affiliates[msg.sender]
            .totalClaim
            .add(claimAmount);

        uint256 amountBnbPayout = swapTokenToBnb(claimAmount, msg.sender);
        affiliates[msg.sender].totalClaimBnb = affiliates[msg.sender]
            .totalClaimBnb
            .add(amountBnbPayout);
        emit Claim(msg.sender, claimAmount, amountBnbPayout);
    }

    function setPair(address _pair) external onlyOwner {
        pair = IPancakeSwapPair(pair);
    }

    function setHoldAmountInBnb(uint256 value) external onlyOwner {
        holdAmountInBnb = value;
    }

    function setAffiliateBuyLevel(
        uint256 _totalAffBuy,
        uint256[] calldata _affBuyLevel
    ) external onlyOwner {
        totalAffiliateBuy = _totalAffBuy;
        for (uint32 i = 0; i < 7; i++) {
            affiliateBuyLevel[i] = _affBuyLevel[i];
        }
    }

    function setAffiliateSellLevel(
        uint256 _totalAffSell,
        uint256[] calldata _affSellLevel
    ) external onlyOwner {
        totalAffiliateSell = _totalAffSell;
        for (uint32 i = 0; i < 7; i++) {
            affiliateSellLevel[i] = _affSellLevel[i];
        }
    }

    function getAffiliate(address _address)
        external
        view
        override
        returns (uint256, uint256)
    {
        return (affiliates[_address].amount, affiliates[_address].totalClaim);
    }

    function getF0(address _address) external view override returns (address) {
        return affiliateLevels[_address];
    }

    function getTotalAffiliateBuy() external view override returns (uint256) {
        return totalAffiliateBuy;
    }

    function getTotalAffiliateSell() external view override returns (uint256) {
        return totalAffiliateSell;
    }

    function getAffiliateBuyLevel(uint256 index)
        external
        view
        returns (uint256)
    {
        return affiliateBuyLevel[index];
    }

    function getAffiliateSellLevel(uint256 index)
        external
        view
        returns (uint256)
    {
        return affiliateSellLevel[index];
    }

    function swapTokenToBnb(uint256 amountToSwap, address to)
        internal
        returns (uint256 amountEthPayout)
    {
        uint256 balanceBefore = to.balance;
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            to,
            block.timestamp
        );
        amountEthPayout = to.balance.sub(balanceBefore);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
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
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "zero address");
        token = IERC20(_token);
    }

    function setTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != address(0), "zero address");
        treasuryWallet = _treasuryWallet;
    }

    function setLottery(address _moonboxLottery) external onlyOwner {
        require(_moonboxLottery != address(0), "zero address");
        moonboxLottery = IMoonBoxLottery(_moonboxLottery);
    }

    function approveToken(address token, address spender) external onlyOwner {
        IERC20(token).approve(spender, uint256(-1));
    }

    function withdrawToTreasury() external onlyOwner {
        uint256 swapAmount = token.balanceOf(address(this)).sub(totalReceived);
        require(
            swapAmount > 0,
            "There is no token deposited in token contract"
        );
        swapTokenToBnb(swapAmount, treasuryWallet);
    }

    function withdrawToken(address tokenAddress, address recepient)
        external
        onlyOwner
    {
        IERC20 erc20 = IERC20(tokenAddress);
        require(
            erc20.transfer(recepient, erc20.balanceOf(address(this))),
            "Failure withdraw"
        );
    }

    function withdrawBnb() external onlyOwner {
        address payable sender = payable(msg.sender);
        sender.transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IMoonBoxLottery {
    function donate(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapPair.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract MoonBoxLottery is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Lottery {
        uint256 periodNumber;
        uint256 totalPlayer;
        uint256 totalReward;
        uint256 totalPoll;
        mapping(address => uint256) winners;
        mapping(address => bool) winnerClaims;
        uint32 status; //0: not found, 1: opening, 2: finish
    }

    uint256 public denominator = 1000;
    uint256 public pReward = 600;
    uint256 public pToTreasury = 400;

    uint256 public ticketPriceBnb = 0.017 * 10**18;
    uint256 public periodNumber;
    mapping(uint256 => Lottery) public lotteries;

    IERC20 public token;
    IPancakeSwapPair public pair;
    address public treasuryWallet;

    constructor(address _token, address _treasuryWallet) {
        token = IERC20(_token);
        treasuryWallet = _treasuryWallet;
    }

    function buyTicket(uint256 numberOfTicket) external nonReentrant {
        require(numberOfTicket >= 1, "Invalid number of ticket");

        Lottery storage lottery = lotteries[periodNumber];
        require(lottery.status == 1, "Lottery not opening");

        uint256 ticketPrice = ticketPriceToken().mul(numberOfTicket);
        uint256 amountToTreasury = ticketPrice.mul(pToTreasury).div(
            denominator
        );
        lotteries[periodNumber].totalPlayer += 1;
        lotteries[periodNumber].totalReward = lottery.totalReward.add(
            (ticketPrice.sub(amountToTreasury)).mul(pReward).div(denominator)
        );
        lotteries[periodNumber].totalPoll = lottery.totalPoll.add(
            ticketPrice.sub(amountToTreasury)
        );

        require(
            token.balanceOf(msg.sender) >= ticketPrice,
            "Not enough balance"
        );
        require(
            token.transferFrom(msg.sender, address(this), ticketPrice),
            "Failure"
        );
        require(
            token.transfer(treasuryWallet, amountToTreasury),
            "Failure"
        );

        emit BuyTicket(msg.sender, numberOfTicket, ticketPrice);
    }

    function donate(uint256 amount) external {
        Lottery storage lottery = lotteries[periodNumber];
        if (lottery.status == 1 && token.balanceOf(msg.sender) >= amount) {
            lotteries[periodNumber].totalReward = lottery.totalReward.add(
                amount
            );
            lotteries[periodNumber].totalPoll = lottery.totalPoll.add(amount);
            token.transferFrom(msg.sender, address(this), amount);
            emit Donate(periodNumber, amount);
        }
    }

    function claim(uint256 _periodNumber) external nonReentrant {
        Lottery storage lottery = lotteries[_periodNumber];
        require(lottery.status == 2, "Not ready to claim");
        require(lottery.winners[msg.sender] > 0, "Not a winner");
        require(lottery.winnerClaims[msg.sender] == false, "Already claim");

        lotteries[_periodNumber].winnerClaims[msg.sender] = true;

        require(
            token.transfer(msg.sender, lottery.winners[msg.sender]),
            "Failure"
        );
        emit ClaimReward(
            msg.sender,
            _periodNumber,
            lottery.winners[msg.sender]
        );
    }

    function finishLottery(address[] calldata winners) external onlyOwner {
        Lottery storage lottery = lotteries[periodNumber];
        require(lottery.status == 1, "Not ready to finish");

        lotteries[periodNumber].status = 2;
        uint256[] memory amounts = new uint256[](winners.length);
        uint256 winAmount = lottery.totalReward.div(winners.length);
        for (uint32 i = 0; i < winners.length; i++) {
            require(winners[i] != address(0), "1");
            require(lottery.winners[winners[i]] == 0, "2");
            lotteries[periodNumber].winners[winners[i]] = winAmount;
            amounts[i] = winAmount;
        }
        emit LotteryFinish(periodNumber, winners, amounts);
    }

    function createNewLottery() external onlyOwner {
        if (periodNumber == 0) {
            periodNumber = periodNumber.add(1);
            lotteries[periodNumber].periodNumber = periodNumber;
            lotteries[periodNumber].status = 1;
            emit NewLottery(periodNumber, 0);
        } else {
            Lottery storage preLottery = lotteries[periodNumber];
            require(preLottery.status == 2, "1");
            periodNumber = periodNumber.add(1);
            lotteries[periodNumber].periodNumber = periodNumber;
            lotteries[periodNumber].totalReward = preLottery.totalPoll.sub(
                preLottery.totalReward
            );
            lotteries[periodNumber].totalPoll = lotteries[periodNumber]
                .totalReward;
            lotteries[periodNumber].status = 1;
            emit NewLottery(periodNumber, lotteries[periodNumber].totalReward);
        }
    }

    function ticketPriceToken() public view returns (uint256) {
        uint256 decimal = token.getDecimal();
        (uint256 _reserve0, uint256 _reserve1, ) = pair.getReserves();
        uint256 priceInBnb = pair.token0() == address(token)
            ? _reserve1.mul(10**decimal).div(_reserve0)
            : _reserve0.mul(10**decimal).div(_reserve1);
        return ticketPriceBnb.div(priceInBnb).mul(10**decimal);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "0 address");
        token = IERC20(_token);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "0 address");
        pair = IPancakeSwapPair(_pair);
    }

    function setTicketPriceBnb(uint256 price) external onlyOwner {
        require(price > 0, "0 price");
        ticketPriceBnb = price;
    }

    function setPReward(uint256 value) external onlyOwner {
        require(value > 0, "0");
        pReward = value;
    }

    function setPToTreasure(uint256 value) external onlyOwner {
        require(value > 0, "0");
        pToTreasury = value;
    }

    function withdrawToken(address tokenAddress, address recepient)
        external
        onlyOwner
    {
        IERC20 erc20 = IERC20(tokenAddress);
        require(
            erc20.transfer(recepient, erc20.balanceOf(address(this))),
            "Failure withdraw"
        );
    }

    function withdrawBnb() external onlyOwner {
        address payable sender = payable(msg.sender);
        sender.transfer(address(this).balance);
    }

    event BuyTicket(address buyer, uint256 numOfTicket, uint256 amount);
    event ClaimReward(address winner, uint256 periodNumber, uint256 amount);
    event LotteryFinish(
        uint256 periodNumber,
        address[] winners,
        uint256[] amounts
    );
    event NewLottery(uint256 periodNumber, uint256 initAmount);
    event Donate(uint256 periodNumber, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IPancakeSwapRouter.sol";

contract MoonBoxCashBack is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    enum Package {
        SILVER,
        GOLD,
        PLATINUM,
        DIAMOND,
        IMMORTAL
    }

    struct CashBack {
        Package packageType;
        uint256 amountBnb;
        uint256 returnAmountBnb;
        bool enable;
    }

    struct Log {
        uint256 id;
        address buyer;
        Package package;
        uint256 amount;
    }

    mapping(uint256 => Log) logs;
    mapping(Package => CashBack) cashBacks;
    mapping(address => uint256) unClaimAmount;

    uint256 public logId;
    uint256 public totalUnClaim;
    uint256 public totalClaim;
    bool public enable;

    IPancakeSwapRouter public router;
    IERC20 public token;

    constructor(address _token) {
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        token = IERC20(_token);
        enable = true;
    }

    function buy(Package _package) external payable nonReentrant {
        require(enable, "Disable");
        CashBack storage cashBack = cashBacks[_package];
        require(cashBack.enable, "Disable");
        require(!isContract(msg.sender), "No");
        uint256 remainingAmount = address(this).balance.sub(
            totalUnClaim.sub(totalClaim)
        );
        require(cashBack.returnAmountBnb <= remainingAmount, "Not enough fund");
        require(msg.value >= cashBack.amountBnb, "Not enough balance");

        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(token);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: cashBack.amountBnb
        }(0, path, msg.sender, block.timestamp);

        logId = logId.add(1);
        logs[logId] = Log(
            logId,
            msg.sender,
            _package,
            cashBack.returnAmountBnb
        );
        unClaimAmount[msg.sender] = unClaimAmount[msg.sender].add(
            cashBack.returnAmountBnb
        );
        totalUnClaim = totalUnClaim.add(cashBack.returnAmountBnb);
        emit Buy(
            msg.sender,
            _package,
            cashBack.amountBnb,
            cashBack.returnAmountBnb
        );
    }

    function claim() external nonReentrant {
        require(enable, "Disable");

        uint256 claimAmount = unClaimAmount[msg.sender];
        require(claimAmount > 0, "Nothing to withdraw");
        unClaimAmount[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{
            value: claimAmount,
            gas: 30000
        }("");
        require(success, "Fail");
        emit Claim(msg.sender, claimAmount);
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "zero address");
        token = IERC20(_token);
    }

    function setCashBack(
        Package _package,
        uint256 _amountBnb,
        uint256 _returnAmountBnb,
        bool _enable
    ) external onlyOwner {
        cashBacks[_package].amountBnb = _amountBnb;
        cashBacks[_package].returnAmountBnb = _returnAmountBnb;
        cashBacks[_package].enable = _enable;
    }

    function setEnable(bool _enable) external onlyOwner {
        enable = _enable;
    }

    function withdrawToken(address tokenAddress, address recepient)
        external
        onlyOwner
    {
        IERC20 erc20 = IERC20(tokenAddress);
        require(
            erc20.transfer(recepient, erc20.balanceOf(address(this))),
            "Failure withdraw"
        );
    }

    function withdrawBnb() external onlyOwner {
        address payable sender = payable(msg.sender);
        sender.transfer(address(this).balance);
    }

    event Buy(
        address buyer,
        Package package,
        uint256 amount,
        uint256 cashbackAmount
    );
    event Claim(address buyer, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeMathInt.sol";
import "./IERC20.sol";
import "./IPancakeSwapPair.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapFactory.sol";
import "./IMoonBoxAffiliate.sol";

contract MoonBox is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "MoonBox";
    string public _symbol = "MoonBox";
    uint8 public _decimals = 5;

    IPancakeSwapPair public pairContract;
    mapping(address => bool) _isFeeExempt;
    mapping(address => bool) _isWhiteList;
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

    uint256 public limitSellRate = 100;
    uint256 public limitSellRateBonus = 100;
    uint256 public limitSellRateReduce = 100;
    uint256 public limitSellRateBonusPr = 100;
    uint256 public secondLimitSell = 420;
    uint256 public maxSellTransactionAmount = 2500000 * 10**DECIMALS;

    struct Trader {
        uint256 lastTradeTime;
        uint256 amount;
        uint256 limitAmount;
        uint256 totalBuy;
        uint256 totalSell;
    }

    struct Pr {
        bool enable;
        uint256 amount;
    }

    mapping(address => Trader) public tradeHistory;
    mapping(address => uint256) public boughtAmount;
    mapping(address => Pr) public prs;

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
    bool public transferEnabled = true;

    //Rate fee
    uint256 public treasuryFeeRate = 500;
    uint256 public insuranceFundFeeRate = 500;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public treasuryReceiver;
    address public insuranceFundReceiver;
    address public firePit;
    IPancakeSwapRouter public router;
    IMoonBoxAffiliate affiliate;
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

    constructor(address _affiliate)
        ERC20Detailed("MoonBox", "MoonBox", uint8(DECIMALS))
        Ownable()
    {
        require(_affiliate != address(0), "Zero address");
        router = IPancakeSwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        treasuryReceiver = 0xB9DffCE05FD93f82981242Ab8c2949D5230f4d1F;
        insuranceFundReceiver = 0xA24E8a58df3011f522EbCaDA803a690a7920ED6e;
        firePit = 0xE6F1F6638EBaC6c9c0c681FA3B7D48DC3d723c69;

        affiliate = IMoonBoxAffiliate(_affiliate);

        _allowedFragments[address(this)][address(router)] = uint256(-1);
        _allowedFragments[address(this)][pair] = uint256(-1);
        _allowedFragments[address(this)][address(this)] = uint256(-1);
        _allowedFragments[_affiliate][address(router)] = uint256(-1);
        _allowedFragments[_affiliate][pair] = uint256(-1);
        _allowedFragments[_affiliate][_affiliate] = uint256(-1);
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
        _isFeeExempt[address(router)] = true;
        _isFeeExempt[_affiliate] = true;

        _isWhiteList[msg.sender] = true;

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
        boughtAmount[to] = boughtAmount[to].add(amount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        if (_isWhiteList[sender] || _isWhiteList[recipient]) {
            return _basicTransfer(sender, recipient, amount);
        }

        bool isTransfer = sender != pair && recipient != pair;
        bool isSell = recipient == pair;
        if (sender == pair || recipient == pair) {
            require(tradingEnabled == true, "Trading not open yet");
        } else if (isTransfer) {
            require(transferEnabled == true, "Transfer not open yet");
        }

        bool excludedAccount = _isFeeExempt[sender] || _isFeeExempt[recipient];
        if (inSwap || excludedAccount) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (isSell || isTransfer) {
            require(amount <= maxSellTransactionAmount, "Error amount");
            uint256 blkTime = block.timestamp;
            uint256 txLimitRate = getSellLimitRate(sender);

            if (
                blkTime > tradeHistory[sender].lastTradeTime + secondLimitSell
            ) {
                uint256 limitAmount = balanceOf(sender).mul(txLimitRate).div(
                    feeDenominator
                );
                require(
                    amount <= limitAmount,
                    "ERR: Can't sell more than limit rate"
                );
                tradeHistory[sender].lastTradeTime = blkTime;
                tradeHistory[sender].amount = amount;
                tradeHistory[sender].limitAmount = limitAmount;
            } else {
                require(
                    tradeHistory[sender].amount.add(amount) <=
                        tradeHistory[sender].limitAmount,
                    "ERR: Can't sell more than limit rate in One day"
                );
                tradeHistory[sender].amount = tradeHistory[sender].amount.add(
                    amount
                );
            }
        }

        if (shouldRebase()) {
            rebase();
        }

        if (shouldSwapBack() && (sender == pair || recipient == pair)) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        (uint256 gonAmountReceived, uint256 gonMgmFee) = shouldTakeFee(
            sender,
            recipient
        )
            ? takeFee(sender, recipient, gonAmount, amount)
            : (gonAmount, 0);
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        if (isSell) {
            tradeHistory[sender].totalSell = tradeHistory[sender].totalSell.add(
                amount
            );
        } else {
            tradeHistory[recipient].totalBuy = tradeHistory[recipient]
                .totalBuy
                .add(gonAmountReceived.div(_gonsPerFragment));
        }

        if (gonMgmFee > 0) {
            affiliate.setAffiliateRevenue(
                isSell ? sender : recipient,
                gonMgmFee.div(_gonsPerFragment),
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

    function getSellLimitRate(address _address) public view returns (uint256) {
        if (
            prs[_address].enable &&
            tradeHistory[_address].totalSell < prs[_address].amount
        ) {
            return limitSellRate.add(limitSellRateBonusPr);
        }
        uint256 bonus = affiliate.getF0(_address) == address(0)
            ? 0
            : limitSellRateBonus;
        uint256 reduce = tradeHistory[_address].totalBuy > 0 &&
            tradeHistory[_address].totalBuy < tradeHistory[_address].totalSell
            ? limitSellRateReduce
            : 0;
        return limitSellRate.add(bonus).sub(reduce);
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount,
        uint256 amount
    ) internal returns (uint256, uint256) {
        uint256 _totalFee;
        uint256 _firePitFee;
        uint256 _mgmFee;
        uint256 taxedGons = gonAmount;

        if (recipient == pair) {
            //Sell
            _totalFee = totalFeeS;
            _firePitFee = firePitFeeS;
            _mgmFee = affiliate.getTotalAffiliateSell();

            uint256 _boughtAmount = boughtAmount[sender];
            if (_boughtAmount == 0) {
                uint256 affiliateAmount = gonAmount.mul(_mgmFee).div(
                    feeDenominator
                );
                _gonBalances[address(affiliate)] = _gonBalances[
                    address(affiliate)
                ].add(affiliateAmount);

                emit Transfer(
                    sender,
                    address(affiliate),
                    affiliateAmount.div(_gonsPerFragment)
                );
                return (gonAmount.sub(affiliateAmount), affiliateAmount);
            }

            uint256 taxedAmount = amount > _boughtAmount
                ? _boughtAmount
                : amount;
            boughtAmount[sender] = _boughtAmount.sub(taxedAmount);
            taxedGons = taxedAmount.mul(_gonsPerFragment);
        } else {
            //Buy or transfer
            _totalFee = totalFeeB;
            _firePitFee = firePitFeeB;
            _mgmFee = affiliate.getTotalAffiliateBuy();
        }

        uint256 feeAmount = taxedGons.mul(_totalFee).div(feeDenominator);
        uint256 affiliateAmount = gonAmount.mul(_mgmFee).div(feeDenominator);

        _gonBalances[firePit] = _gonBalances[firePit].add(
            taxedGons.mul(_firePitFee).div(feeDenominator)
        );
        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            taxedGons.mul(_totalFee.sub(_firePitFee)).div(feeDenominator)
        );
        _gonBalances[address(affiliate)] = _gonBalances[address(affiliate)].add(
            affiliateAmount
        );

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));

        emit Transfer(
            sender,
            address(affiliate),
            affiliateAmount.div(_gonsPerFragment)
        );
        return (gonAmount.sub(feeAmount).sub(affiliateAmount), affiliateAmount);
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );

        if (amountToSwap == 0) {
            return;
        }

        uint256 amountEthPayout = swapTokenToBnb(amountToSwap, address(this));
        (bool success, ) = payable(treasuryReceiver).call{
            value: amountEthPayout.mul(treasuryFeeRate).div(feeDenominator),
            gas: 30000
        }("");
        (success, ) = payable(insuranceFundReceiver).call{
            value: amountEthPayout.mul(insuranceFundFeeRate).div(
                feeDenominator
            ),
            gas: 30000
        }("");
    }

    function withdrawAllToTreasury() external swapping onlyOwner {
        uint256 amountToSwap = _gonBalances[address(this)].div(
            _gonsPerFragment
        );
        require(
            amountToSwap > 0,
            "There is no token deposited in token contract"
        );
        swapTokenToBnb(amountToSwap, treasuryReceiver);
    }

    function swapTokenToBnb(uint256 amountToSwap, address to)
        internal
        returns (uint256 amountEthPayout)
    {
        uint256 balanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            to,
            block.timestamp
        );
        amountEthPayout = address(this).balance.sub(balanceBefore);
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

    function setFeeExemp(address[] calldata _addrs, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = flag;
        }
    }

    function setWhiteList(address[] calldata _addrs, bool flag)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isWhiteList[_addrs[i]] = flag;
        }
    }

    function setFeeS(
        uint256 _treasuryFeeS,
        uint256 _insuranceFundFeeS,
        uint256 _firePitFeeS
    ) external onlyOwner {
        treasuryFeeS = _treasuryFeeS;
        insuranceFundFeeS = _insuranceFundFeeS;
        firePitFeeS = _firePitFeeS;
        totalFeeS = treasuryFeeS.add(insuranceFundFeeS).add(firePitFeeS);
    }

    function setFeeB(
        uint256 _treasuryFeeB,
        uint256 _insuranceFundFeeB,
        uint256 _firePitFeeB
    ) external onlyOwner {
        treasuryFeeB = _treasuryFeeB;
        insuranceFundFeeB = _insuranceFundFeeB;
        firePitFeeB = _firePitFeeB;
        totalFeeB = treasuryFeeB.add(insuranceFundFeeB).add(firePitFeeB);
    }

    function setPr(
        address[] calldata _addrs,
        uint256[] calldata _amounts,
        bool flag
    ) external onlyOwner {
        require(_addrs.length == _amounts.length, "1");
        for (uint256 i = 0; i < _addrs.length; i++) {
            prs[_addrs[i]].enable = flag;
            prs[_addrs[i]].amount = _amounts[i];
        }
    }

    function setPairAddress(address _pair) public onlyOwner {
        pair = _pair;
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function setLimitSaleRate(uint256 _limitSellRate) external onlyOwner {
        limitSellRate = _limitSellRate;
    }

    function setLimitSaleRateBonus(uint256 _limitSellRateBonus)
        external
        onlyOwner
    {
        limitSellRateBonus = _limitSellRateBonus;
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

    function setTransferEnabled(bool enable) external onlyOwner {
        transferEnabled = enable;
    }

    function setMaxSellTransaction(uint256 _maxTxn) external onlyOwner {
        maxSellTransactionAmount = _maxTxn;
    }

    function setMoonBoxAffiliate(address addr) external onlyOwner {
        require(addr != address(0), "Zero address");
        affiliate = IMoonBoxAffiliate(addr);
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

    fallback() external payable {}

    event OperatorSetted(address operatorAddress, bool value);
}