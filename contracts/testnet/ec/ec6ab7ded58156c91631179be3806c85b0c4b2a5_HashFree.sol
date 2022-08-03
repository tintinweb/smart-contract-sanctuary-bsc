// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

import "./IPancakeSwapPair.sol";
import "./IPancakeSwapRouter.sol";
import "./IPancakeSwapFactory.sol";
import "./IHashFreeFund.sol";
import "./IHashFreeDao.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";

contract HashFree is ERC20Detailed, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    string public _name = "HashFree Token";
    string public _symbol = "HashFree";

    mapping(address => bool) _isFeeExempt;

    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }

    uint256 public constant DECIMALS = 8;
    uint256 public constant MAX_UINT256 = type(uint256).max;
    uint8 public constant RATE_DECIMALS = 8;

    uint256 public liquidityFee = 50; //5%  only for buy
    uint256 public inviteFee = 100; //10% //only for buy
    uint256 public compoundFee = 20; //2% //both for buy & sale
    uint256 public treasuryFee = 50; //5% only for sell
    uint256 public consensusFundFee = 25; //2.5% only for sell
    uint256 public daoFee = 50; //5% dao fee.only for sell
    uint256 public firePitFee = 25; //2.5% only for sell
    uint256 public feeDenominator = 1000;
    uint256 public totalInviteAmount = 0;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    address public autoLiquidityReceiver;
    address public consensusReceiver;
    address public autoSwapBackReceiver;
    address public dividendReceiver;
    address public compoundReceiver;
    address public treasureReceiver;
    address public firePit;
    bool public swapEnabled = true;
    IPancakeSwapRouter public router;
    address public pair;
    address public usdtAddress;
    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private TOTAL_GONS;

    uint256 private constant MAX_SUPPLY = ~uint128(0) / 1e14;
    uint256 public MINIMUM_LIQUIDITY = 0.001 ether; //todo swapback?

    bool public _autoRebase;
    bool public _autoSwapBack;
    bool public _autoAddLiquidity;
    uint256 public _lastRebasedTime;
    uint256 public _lastAddLiquidityTime;
    uint256 public _totalSupply;
    uint256 private _gonsPerFragment;
    uint256 public pairBalance;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    address public hashDaoAddress;
    uint256 public startTradingTime;
    uint256 public autoLiquidityInterval;

    constructor(
        address _swapRouter,
        address _hashDaoAddress,
        uint256 _initSupply,
        uint256 _startTradingTime,
        address _owner
    ) ERC20Detailed(_name, _symbol, uint8(DECIMALS)) Ownable() {
        require(_swapRouter != address(0), "invalid swap router address");
        require(_hashDaoAddress != address(0), "invalid free dao address");
        require(_initSupply > 0, "invalid init supply");
        hashDaoAddress = _hashDaoAddress;
        usdtAddress = IHashFreeDao(_hashDaoAddress).payToken();
        router = IPancakeSwapRouter(_swapRouter);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            usdtAddress,
            address(this)
        );

        firePit = DEAD;
        _totalSupply = _initSupply * 10**DECIMALS;
        TOTAL_GONS = MAX_UINT256 / 1e10 - ((MAX_UINT256 / 1e10) % _totalSupply);
        _gonBalances[_owner] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _autoRebase = true;
        _autoSwapBack = true;
        _autoAddLiquidity = true;
        _isFeeExempt[msg.sender] = true;
        _isFeeExempt[_owner] = true;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[hashDaoAddress] = true;
        setStartTradingTime(_startTradingTime);
        autoLiquidityInterval = 10 minutes;

        // transferOwnership(_owner); //after set feeCollectors
        emit Transfer(address(0x0), _owner, _totalSupply);
    }

    function manualRebase() external {
        require(shouldRebase(), "rebase not required");
        rebase();
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate = 21645;
        uint256 deltaTime = block.timestamp - _lastRebasedTime;
        uint256 times = deltaTime.div(15 minutes);
        uint256 epoch = times.mul(15);
        for (uint256 i = 0; i < times; i++) {
            _totalSupply = _totalSupply
                .mul((10**RATE_DECIMALS).add(rebaseRate))
                .div(10**RATE_DECIMALS);
        }
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        _lastRebasedTime = _lastRebasedTime.add(times.mul(15 minutes));

        emit LogRebase(epoch, _totalSupply);
    }

    function setStartTradingTime(uint256 _time) public onlyOwner {
        startTradingTime = _time;
        if (_time > 0) {
            _lastAddLiquidityTime = _time;
            if (_lastRebasedTime == 0) {
                _lastRebasedTime = _time;
            }
        }
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
        if (_allowedFragments[from][msg.sender] != type(uint256).max) {
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(value, "Insufficient Allowance");
        }
        _transferFrom(from, to, value);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "in_blacklist");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        }

        if (shouldAddLiquidity()) {
            addLiquidity();
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (
            recipient == pair &&
            _isFeeExempt[sender] == false &&
            _isFeeExempt[recipient] == false
        ) {
            //only can sell 99% of balance
            if (gonAmount >= _gonBalances[sender].div(1000).mul(999)) {
                gonAmount = _gonBalances[sender].div(1000).mul(999);
            }
        }
        if (sender == pair) {
            // buy in
            pairBalance = pairBalance.sub(amount);
        } else {
            _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        }
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, gonAmount)
            : gonAmount;

        if (recipient == pair) {
            // sell out
            pairBalance = pairBalance.add(
                gonAmountReceived.div(_gonsPerFragment)
            );
        } else {
            _gonBalances[recipient] = _gonBalances[recipient].add(
                gonAmountReceived
            );
        }
        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(_gonsPerFragment)
        );
        return true;
    }

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 gonAmount = amount.mul(_gonsPerFragment);
        if (from == pair) {
            // buy in
            pairBalance = pairBalance.sub(amount);
        } else {
            _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        }
        if (to == pair) {
            // sell out
            pairBalance = pairBalance.add(amount);
        } else {
            _gonBalances[to] = _gonBalances[to].add(gonAmount);
        }
        return true;
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 gonAmount
    ) internal returns (uint256) {
        uint256 _totalFee = 0;
        uint256 _robotsFee = 550;
        _totalFee = compoundFee;
        _gonBalances[compoundReceiver] = _gonBalances[compoundReceiver].add(
            gonAmount.div(feeDenominator).mul(compoundFee)
        );
        //sell token or transfer token
        if (sender != pair) {
            _totalFee += firePitFee.add(treasuryFee).add(daoFee).add(
                consensusFundFee
            );
            _gonBalances[firePit] = _gonBalances[firePit].add(
                gonAmount.div(feeDenominator).mul(firePitFee)
            );
            _gonBalances[consensusReceiver] = _gonBalances[consensusReceiver]
                .add(gonAmount.div(feeDenominator).mul(consensusFundFee));
            _gonBalances[treasureReceiver] = _gonBalances[treasureReceiver].add(
                gonAmount.div(feeDenominator).mul(treasuryFee)
            );
            uint256 calculateDao = gonAmount.div(feeDenominator).mul(daoFee);
            _gonBalances[dividendReceiver] = _gonBalances[dividendReceiver].add(
                calculateDao
            );
            IHashFreeFund(dividendReceiver).setDaoReward(
                calculateDao.div(_gonsPerFragment)
            );
        }
        if (sender == pair) {
            //when buy token
            _totalFee += inviteFee.add(liquidityFee);
            _gonBalances[autoLiquidityReceiver] = _gonBalances[
                autoLiquidityReceiver
            ].add(gonAmount.div(feeDenominator).mul(liquidityFee));
        }
        if (recipient == pair || sender == pair) {
            // after start trade, exact fee
            require(
                startTradingTime > 0 && block.timestamp >= startTradingTime,
                "can not trade now!"
            );
            if (block.timestamp <= startTradingTime + 6) {
                _totalFee += _robotsFee;
                _gonBalances[autoLiquidityReceiver] = _gonBalances[
                    autoLiquidityReceiver
                ].add(gonAmount.div(feeDenominator).mul(_robotsFee));
            }
        }
        uint256 feeAmount = gonAmount.div(feeDenominator).mul(_totalFee);

        emit Transfer(sender, address(this), feeAmount.div(_gonsPerFragment));
        if (sender == pair) {
            totalInviteAmount = totalInviteAmount.add(
                gonAmount.div(_gonsPerFragment).mul(inviteFee).div(
                    feeDenominator
                )
            );

            (uint8 count, address[] memory _parents) = IHashFreeDao(
                hashDaoAddress
            ).getRelations(recipient);
            if (count > 0) {
                for (uint8 i = 0; i < count; i++) {
                    uint256 _parentFee = gonAmount.mul(5).div(1000);
                    if (i == 0) {
                        _parentFee = gonAmount.mul(4).div(100);
                    }
                    if (i == 1) {
                        _parentFee = gonAmount.mul(2).div(100);
                    }
                    _gonBalances[_parents[i]] = _gonBalances[_parents[i]].add(
                        _parentFee
                    );
                    emit Transfer(
                        recipient,
                        _parents[i],
                        _parentFee.div(_gonsPerFragment)
                    );
                }
            }
        }
        return gonAmount.sub(feeAmount);
    }

    function addLiquidity() internal swapping {
        uint256 autoLiquidityAmount = _gonBalances[autoLiquidityReceiver].div(
            _gonsPerFragment
        );
        IHashFreeFund(autoLiquidityReceiver).swapAndLiquify(autoLiquidityAmount);
        _lastAddLiquidityTime = block.timestamp;
    }

    function swapBack() internal swapping {
        IHashFreeFund(autoSwapBackReceiver).swapBack();
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return !_isFeeExempt[from] && !_isFeeExempt[to];
    }

    function shouldRebase() internal view returns (bool) {
        return
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !_isFeeExempt[msg.sender] &&
            !inSwap &&
            block.timestamp >= (_lastRebasedTime + 15 minutes);
    }

    function shouldAddLiquidity() internal view returns (bool) {
        return
            _autoAddLiquidity &&
            !inSwap &&
            msg.sender != pair &&
            autoLiquidityReceiver != address(0) &&
            _lastAddLiquidityTime > 0 &&
            !_isFeeExempt[msg.sender] &&
            _gonBalances[autoLiquidityReceiver].div(_gonsPerFragment) >
            MINIMUM_LIQUIDITY &&
            block.timestamp >= (_lastAddLiquidityTime + autoLiquidityInterval);
    }

    function shouldSwapBack() internal view returns (bool) {
        return
            _autoSwapBack &&
            !inSwap &&
            msg.sender != pair &&
            !_isFeeExempt[msg.sender] &&
            autoSwapBackReceiver != address(0);
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
            _lastRebasedTime = block.timestamp;
        } else {
            _autoRebase = _flag;
        }
    }

    function setAutoSwapBack(bool _flag) external onlyOwner {
        _autoSwapBack = _flag;
    }

    function setAutoLiquidityInterval(uint256 _minutes) external onlyOwner {
        require(_minutes > 0, "invalid time");
        autoLiquidityInterval = _minutes * 1 minutes;
    }

    function setAutoAddLiquidity(bool _flag) external onlyOwner {
        if (_flag) {
            _autoAddLiquidity = _flag;
            _lastAddLiquidityTime = block.timestamp;
        } else {
            _autoAddLiquidity = _flag;
        }
    }

    function sethashDaoAddress(address _address) external onlyOwner {
        require(_address != address(0), "invalid address");

        hashDaoAddress = _address;
        _isFeeExempt[hashDaoAddress] = true;
    }

    function setFeeReceivers(
        address _consensusReceiver,
        address _treasureReceiver,
        address _compoundReceiver,
        address _autoLiquidityReceiver,
        address _autoSwapBackReceiver,
        address _dividendReceiver
    ) external onlyOwner {
        if (_consensusReceiver != ZERO) {
            consensusReceiver = _consensusReceiver;
            _isFeeExempt[consensusReceiver] = true;
        }
        if (_treasureReceiver != ZERO) {
            treasureReceiver = _treasureReceiver;
            _isFeeExempt[_treasureReceiver] = true;
        }
        if (_compoundReceiver != ZERO) {
            compoundReceiver = _compoundReceiver;
            _isFeeExempt[compoundReceiver] = true;
        }
        if (_autoLiquidityReceiver != ZERO) {
            autoLiquidityReceiver = _autoLiquidityReceiver;
            _isFeeExempt[autoLiquidityReceiver] = true;
            _allowedFragments[autoLiquidityReceiver][address(router)] = type(
                uint256
            ).max;
        }
        if (_autoSwapBackReceiver != ZERO) {
            autoSwapBackReceiver = _autoSwapBackReceiver;
            _isFeeExempt[autoSwapBackReceiver] = true;
            _allowedFragments[autoSwapBackReceiver][address(router)] = type(
                uint256
            ).max;
        }
        if (_dividendReceiver != ZERO) {
            dividendReceiver = _dividendReceiver;
            _isFeeExempt[dividendReceiver] = true;
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

    function setWhitelist(address[] memory _addrs) external onlyOwner {
        for (uint256 i = 0; i < _addrs.length; i++) {
            _isFeeExempt[_addrs[i]] = true;
        }
    }

    function setBlacklist(address _address, bool _flag) external onlyOwner {
        blacklist[_address] = _flag;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) external view override returns (uint256) {
        if (who == pair) {
            return pairBalance;
        } else {
            return _gonBalances[who].div(_gonsPerFragment);
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}