// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import "./interfaces/IERC20.sol";
import "./interfaces/IPancakeSwapFactory.sol";
import "./interfaces/IPancakeSwapRouter.sol";
import "./interfaces/Ownable.sol";

import "./interfaces/IMysteryBox.sol";
import "./interfaces/ISeqToken.sol";
import "./interfaces/ISeqNFT.sol";

import "./utils/SafeMath.sol";

contract LiquidityAdder {
    address private immutable _owner;

    constructor() {
        _owner = msg.sender;
    }

    function addLiquidity(
        address rt,
        address seq,
        address usd,
        uint256 balance
    ) external {
        require(msg.sender == _owner, "not owner");

        uint256 seqValue = balance / 2;
        uint256 usdValue = balance - seqValue;

        {
            address[] memory path = new address[](2);
            path[0] = seq;
            path[1] = usd;

            IPancakeSwapRouter(rt)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    usdValue,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
        }
        usdValue = IERC20(usd).balanceOf(address(this));

        if (seqValue > 0 && usdValue > 0) {
            if (IERC20(usd).allowance(address(this), rt) <= usdValue) {
                IERC20(usd).approve(rt, uint256(-1));
            }

            IPancakeSwapRouter(rt).addLiquidity(
                seq,
                usd,
                seqValue,
                usdValue,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
    }
}

contract SeqToken is IERC20, ISeqToken, Ownable {
    using SafeMath for uint256;

    // constants

    uint8 private constant _DECIMALS = 8;

    uint256 private constant _UNIT = 1 * (10**6) * (10**_DECIMALS);
    uint256 private constant _TOTAL_SUPPLY = 200 * _UNIT;
    uint256 private constant _BURN_THRESHOLD = 198 * _UNIT;

    uint256 private constant _TOTAL_FEE =
        _BONUS_FEE +
            _GENESIS_FEE +
            _PRIZE_FEE +
            _R1FEE +
            _R2FEE +
            _BURN_FEE +
            _LIQUIDITY_FEE;

    uint256 private constant _DISTR_FEE =
        _BONUS_FEE + _GENESIS_FEE + _BURN_FEE + _LIQUIDITY_FEE;

    uint256 private constant _BONUS_FEE = 20;
    uint256 private constant _GENESIS_FEE = 5;
    uint256 private constant _PRIZE_FEE = 5;

    uint256 private constant _R1FEE = 15;
    uint256 private constant _R2FEE = 5;

    uint256 private constant _BURN_FEE = 25;
    uint256 private constant _LIQUIDITY_FEE = 5;

    uint256 private constant _FEE_DENOMINATOR = 1000;

    address private constant _DEAD = 0x000000000000000000000000000000000000dEaD;

    // vars

    string public override name = "Sequoia Protocol";
    string public override symbol = "SEQ";
    uint8 public override decimals = uint8(_DECIMALS);
    uint256 public override totalSupply = _TOTAL_SUPPLY;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    // addresses

    address public liquidityAddr; // no key
    address public constant PRIZE_BASE_ADDR = address(1);
    address public constant PRIZE_ADDR = address(2);
    address public constant STORAGE_ADDR = address(6);
    address public constant DISTRIBUTION_ADDR = address(8);

    ISeqNFT public seqNFT;
    IMysteryBox public mysteryBox;

    address public router;
    address public usd;
    address public override pair;
    mapping(address => bool) public pools;

    // daemon addr
    address public bonusAddr;

    // priv addr
    address public operationAddr;
    address public lockedAddr;

    uint256 public presaleTime;

    uint256 private _lastAddLiquidityTime;
    uint256 private _lastDistributionTime;

    mapping(address => bool) public whitelist;

    uint256 public override swapDay;

    // modifier

    bool private _inSwap = false;
    modifier swapping() {
        require(!_inSwap, "swapping");
        _inSwap = true;
        _;
        _inSwap = false;
    }

    // main

    constructor(
        address router_,
        address usd_,
        address operationAddr_,
        address bonusAddr_,
        address lockedAddr_,
        address seqNFT_
    ) {
        pair = IPancakeSwapFactory(IPancakeSwapRouter(router_).factory())
            .createPair(usd_, address(this));

        liquidityAddr = address(new LiquidityAdder());

        router = router_;
        usd = usd_;
        operationAddr = operationAddr_;
        bonusAddr = bonusAddr_;
        lockedAddr = lockedAddr_;
        seqNFT = ISeqNFT(seqNFT_);
        pools[pair] = true;

        // perm
        _allowed[liquidityAddr][address(router_)] = uint256(-1);
        whitelist[lockedAddr_] = true;

        // tokens distribution
        _balances[operationAddr_] = _UNIT * 10;
        emit Transfer(address(0), operationAddr_, _UNIT * 10);

        _balances[STORAGE_ADDR] = _UNIT * 20;
        emit Transfer(address(0), STORAGE_ADDR, _UNIT * 20);

        _balances[lockedAddr] = _TOTAL_SUPPLY - _UNIT * 30;
        emit Transfer(address(0), lockedAddr, _TOTAL_SUPPLY - _UNIT * 30);

        // presale
        _startPresale();

        _lastAddLiquidityTime = block.timestamp;
        _lastDistributionTime = block.timestamp;
    }

    function initialize(address mysteryBox_, address presaleAddr_)
        external
        onlyOwner
    {
        require(address(mysteryBox) == address(0), "initialized");
        mysteryBox = IMysteryBox(mysteryBox_);

        address seqNFT_ = address(seqNFT);
        address lockedAddr_ = lockedAddr;

        // perm
        _allowed[STORAGE_ADDR][mysteryBox_] = uint256(-1);
        _allowed[PRIZE_BASE_ADDR][mysteryBox_] = uint256(-1);
        _allowed[PRIZE_ADDR][mysteryBox_] = uint256(-1);

        _allowed[seqNFT_][mysteryBox_] = uint256(-1);
        _allowed[presaleAddr_][mysteryBox_] = uint256(-1);

        uint256 amount = (_balances[lockedAddr_] - _UNIT * 2) /
            (10**_DECIMALS) /
            1000;
        _basicTransfer(lockedAddr_, seqNFT_, amount * 1000 * (10**_DECIMALS));
        ISeqNFT(seqNFT_).mintStorage(lockedAddr_, amount);
        ISeqNFT(seqNFT_).mintProfit(lockedAddr_);
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {
        _transferFrom(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (_allowed[from][msg.sender] != uint256(-1)) {
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        }

        _transferFrom(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return _balances[owner];
    }

    // ------------ presale ------------

    function isPresale() public view override returns (bool) {
        uint256 time = presaleTime;
        return time == 0 || block.timestamp <= time + 15 days;
    }

    function presaleDays() public view override returns (uint256) {
        uint256 time = presaleTime;
        if (time == 0) {
            return 0;
        }
        return (block.timestamp - time) / (24 * 60 * 60);
    }

    // ------------ admin ------------

    function burnOrBonus() external override {
        address mysteryBox_ = address(mysteryBox);
        require(msg.sender == mysteryBox_, "invalid call");
        uint256 amount = _balances[mysteryBox_];
        _balances[mysteryBox_] = 0;
        _burnOrBonus(amount);
    }

    function startPresale() public onlyOwner {
        _startPresale();
    }

    function setWhitelist(address addr, bool flag) external onlyOwner {
        if (flag) {
            whitelist[addr] = true;
        } else if (whitelist[addr]) {
            delete whitelist[addr];
        }
    }

    function setPool(address addr, bool flag) external onlyOwner {
        if (flag) {
            pools[addr] = true;
        } else if (pools[addr]) {
            delete pools[addr];
        }
    }

    // ------------ private methods ------------

    function _basicTransfer(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        return true;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        require(from != address(0) && to != address(0), "zero address");

        if (_inSwap) {
            return _basicTransfer(from, to, amount);
        }

        if (_isDistribution()) {
            _distribution();
        }

        if (_isAddLiquidity()) {
            _addLiquidity();
        }

        _balances[from] = _balances[from].sub(amount);
        uint256 n = _isTakeFee(from, to)
            ? _takeFee(from, to, amount)
            : amount;
        _balances[to] = _balances[to].add(n);

        emit Transfer(from, to, n);
        return true;
    }

    function _takeFee(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256) {
        require(!isPresale(), "in pre-sale");

        uint256 fee = (amount * _TOTAL_FEE) / _FEE_DENOMINATOR;
        if (pools[from]) {
            if (ISeqNFT(seqNFT).genesisState(to) == 2) {
                fee /= 2;
            }
        } else {
            if (ISeqNFT(seqNFT).genesisState(from) == 2) {
                fee /= 2;
            }
        }
        uint256 left = fee;
        uint256 tmp;

        if (pools[from]) {
            // buy
            uint256 a;
            (address r1, address r2) = mysteryBox.recommenders(to);
            tmp = (fee * _R1FEE) / _TOTAL_FEE;
            left -= tmp;
            if (r1 != address(0)) {
                _balances[r1] += tmp;
                emit FeeRecommend(r1, to, tmp);
            } else {
                a += tmp;
            }
            tmp = (fee * _R2FEE) / _TOTAL_FEE;
            left -= tmp;
            if (r2 != address(0)) {
                _balances[r2] += tmp;
                emit FeeRecommend(r2, to, tmp);
            } else {
                a += tmp;
            }
            if (a > 0) {
                _balances[STORAGE_ADDR] += a;
            }
        } else {
            tmp = (fee * (_R1FEE + _R2FEE)) / _TOTAL_FEE;
            left -= tmp;
            _balances[STORAGE_ADDR] += tmp;
        }

        tmp = (fee * _PRIZE_FEE) / _TOTAL_FEE;
        left -= tmp;
        uint256 day = _endOfDay(block.timestamp) / 1 days;
        if (day > swapDay) {
            swapDay = day;
            _balances[PRIZE_BASE_ADDR] += _balances[PRIZE_ADDR];
            _balances[PRIZE_ADDR] = tmp;
        } else {
            _balances[PRIZE_ADDR] += tmp;
        }

        _balances[DISTRIBUTION_ADDR] += left;

        emit Transfer(from, address(this), fee); // reduce gas?
        return amount - fee;
    }

    function _distribution() private {
        _lastDistributionTime = block.timestamp;
        uint256 fee = _balances[DISTRIBUTION_ADDR];
        if (fee == 0) {
            return;
        }
        _balances[DISTRIBUTION_ADDR] = 0;
        uint256 left = fee;
        uint256 tmp;

        tmp = (fee * _LIQUIDITY_FEE) / _DISTR_FEE;
        left -= tmp;
        _balances[liquidityAddr] += tmp;

        address bonusAddr_ = bonusAddr;
        tmp = (fee * _GENESIS_FEE) / _DISTR_FEE;
        left -= tmp;
        emit FeeSent(bonusAddr_, tmp, 1);

        uint256 tmp2 = (fee * _BONUS_FEE) / _DISTR_FEE;
        left -= tmp2;
        emit FeeSent(bonusAddr_, tmp2, 2);

        _balances[bonusAddr_] += (tmp + tmp2);

        _burnOrBonus(left);
    }

    function _burnOrBonus(uint256 left) private {
        uint256 deadBalance = _balances[_DEAD];
        if (deadBalance >= _BURN_THRESHOLD) {
            address bonusAddr_ = bonusAddr;
            _balances[bonusAddr_] += left;
            emit FeeSent(bonusAddr_, left, 2);
        } else if (deadBalance + left <= _BURN_THRESHOLD) {
            _balances[_DEAD] = deadBalance + left;
            emit FeeSent(_DEAD, left, 0);
        } else {
            uint256 l = deadBalance + left - _BURN_THRESHOLD;
            uint256 r = left - l;

            address bonusAddr_ = bonusAddr;
            _balances[bonusAddr_] += l;
            emit FeeSent(bonusAddr_, l, 2);
            _balances[_DEAD] += r;
            emit FeeSent(_DEAD, r, 0);
        }
    }

    function _addLiquidity() private swapping {
        _lastAddLiquidityTime = block.timestamp;

        address addr = liquidityAddr;

        uint256 balance = _balances[addr];
        if (balance >= 10**_DECIMALS) {
            LiquidityAdder(addr).addLiquidity(
                router,
                address(this),
                usd,
                balance
            );
        }
    }

    function _beginOfDay(uint256 timestamp) private pure returns (uint256) {
        uint256 secs = timestamp % 1 days;
        if (secs < 16 hours) {
            return timestamp - secs - 8 hours;
        } else {
            return timestamp - secs + 16 hours;
        }
    }

    function _endOfDay(uint256 timestamp) private pure returns (uint256) {
        uint256 secs = timestamp % 1 days;
        if (secs < 16 hours) {
            return timestamp - secs + 16 hours;
        } else {
            return timestamp - secs + 40 hours;
        }
    }

    function _startPresale() private {
        require(presaleTime == 0, "in pre-sale");
        presaleTime = _beginOfDay(block.timestamp);
    }

    function _isTakeFee(
        address from,
        address to
    ) private view returns (bool) {
        return (pools[from] || pools[to]) && !whitelist[from];
    }

    function _isDistribution() private view returns (bool) {
        return
            block.timestamp > (_lastDistributionTime + 2 hours) &&
            !pools[msg.sender] &&
            !isPresale();
    }

    function _isAddLiquidity() private view returns (bool) {
        return
            block.timestamp > (_lastAddLiquidityTime + 2 days) &&
            !pools[msg.sender] &&
            !isPresale();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.7.6;

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface ISeqToken {
    event FeeSent(address addr, uint256 amount, uint8 kind);
    event FeeRecommend(address indexed rec, address usr, uint256 amount);

    function isPresale() external view returns (bool);

    function presaleDays() external view returns (uint256);

    function swapDay() external view returns (uint256);

    function pair() external view returns (address);

    function burnOrBonus() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface IMysteryBox {
    function recommenders(address) external view returns (address, address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.7.6;

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errMsg
    ) internal pure returns (uint256) {
        require(b <= a, errMsg);
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

interface ISeqNFT {
    function activateGenesis(address who) external;

    function genesisState(address who) external view returns (uint8);

    function genesisTotal() external view returns (uint256);

    function mintGenesis(address to) external returns (uint256);

    function mintBonus(address to) external returns (uint256);

    function mintProfit(address to) external returns (uint256);

    function mintStorage(address to, uint256 count) external;

    function mintPieceS1(address to) external returns (uint256);

    function mintPieceS2(address to) external returns (uint256);

    function mintPieceS3(address to) external returns (uint256);

    function mintPieceS4(address to) external returns (uint256);

    function mintPieceB1(address to) external returns (uint256);

    function mintPieceB2(address to) external returns (uint256);

    function mintPieceB3(address to) external returns (uint256);

    function mintPieceB4(address to) external returns (uint256);

    function mintPieceB5(address to) external returns (uint256);

    function mintPieceP1(address to) external returns (uint256);

    function mintPieceP2(address to) external returns (uint256);

    function mintPieceP3(address to) external returns (uint256);

    function buildS(address to) external;

    function buildB(address to) external;

    function buildB(address to, uint256 id) external;

    function buildP(address to) external;

    function buildP(
        address to,
        uint256 id,
        uint256 id1,
        uint256 id2
    ) external;

    function upgradeProfit(
        address to,
        uint256 id0,
        uint256 id1
    ) external returns (uint8);

    function burnStorage(address owner, uint256 count) external;
}