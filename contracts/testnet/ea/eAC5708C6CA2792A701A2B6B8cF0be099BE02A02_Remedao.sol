/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

// SPDX-License-Identifier: Unlicensed
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

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

library Arrays {
    function findDownerBound(uint256[] storage array, uint256 element)
        internal
        view
        returns (uint256)
    {
        if (array.length == 0) {
            return 0;
        }
        uint256 low = 0;
        uint256 high = array.length - 1;
        while (low <= high) {
            uint256 mid = (low + high) / 2;
            if (array[mid] == element) {
                return mid;
            } else if (array[mid] > element) {
                if (mid == 0) {
                    return 0;
                } else {
                    high = mid - 1;
                }
            } else {
                low = mid + 1;
            }
        }
        return low == 0 ? low : low - 1;
    }
}

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

abstract contract IERC20Metadata is IERC20 {
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

interface IRemedao is IERC20 {
    function TOTAL_GONS() external view returns (uint256);

    function currentMemeEpoch() external view returns (uint256);

    function gonOf(address who) external view returns (uint256);

    function gonOfAt(address account, uint256 epoch)
        external
        view
        returns (uint256);

    function gonsPerFragment() external view returns (uint256);
}

interface IRemedaoVote {
    function lockVote(uint256 epoch, address who) external view returns (bool);

    function highestVote(uint256 epoch) external view returns (address);

    function getVote(address _address, uint256 epoch)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint8
        );
}

contract Remedao is IERC20Metadata, Ownable, IRemedao {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using Arrays for uint256[];

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;

    uint256 internal constant DECIMALS = 10;
    uint256 constant MAX_UINT256 = ~uint256(0);
    uint8 constant RATE_DECIMALS = 7;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        15 * 10**5 * 10**DECIMALS;

    mapping(address => bool) _isFeeExempt;
    mapping(address => uint256) private _gonBalances;
    mapping(address => mapping(address => uint256)) private _allowedFragments;
    mapping(address => bool) public blacklist;
    mapping(address => mapping(uint256 => uint256)) public sell;
    mapping(address => mapping(uint256 => uint256)) public maxSellInEpoch;

    bool inSwap = false;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier validRecipient(address to) {
        require(to != address(0x0));
        _;
    }
    bool public isStartRebase = false;
    uint256 public treasuryFee = 25;
    uint256 public insuranceFundFee = 25;
    uint256 public memeFee = 50;
    uint256 public totalFee = treasuryFee.add(insuranceFundFee).add(memeFee);
    uint256 public constant feeDenominator = 1000;

    uint256 public maxSell = 10;
    uint256 public constant maxSellDenominator = 1000;

    address public treasuryReceiver =
        0x0000a9fDB9d4F7949d5b8060e4E93c7107729999;
    address public insuranceFundReceiver =
        0x4444d2A65D1F75F56f8b9d3f4d3fe55631bd6666;
    address lockAddress;
    uint256 lockMaxBalance = 5 * 10**5 * 10**DECIMALS;
    address offChainGameReceiver = 0x6666b7426c5b2437FeB18359387CAF6251B1aaaa;

    address public pairAddress;

    IPancakeSwapPair public pairContract;
    IPancakeSwapRouter public router;
    address public pair;

    uint256 public constant override TOTAL_GONS =
        MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);
    uint256 private constant MAX_SUPPLY = 12 * 10**11 * 10**DECIMALS;

    bool public _autoRebase = false;
    uint256 public _rebaseStartTime;
    uint256 public _memeStartTime;

    uint256 public _totalSupply = INITIAL_FRAGMENTS_SUPPLY;

    uint256 public override gonsPerFragment = TOTAL_GONS.div(_totalSupply);
    uint256 public _rebaseEpoch = 0;

    IRemedaoVote public voteContract;

    event Rebase(uint256 indexed epoch, uint256 totalSupply);

    constructor() IERC20Metadata("Remedao", "RMD", uint8(DECIMALS)) Ownable() {
        router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        //router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

        _memeStartTime = block.timestamp;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[treasuryReceiver] = true;
        _gonBalances[treasuryReceiver] = TOTAL_GONS;
        _allowedFragments[address(this)][address(router)] = MAX_UINT256;

        emit Transfer(address(0), treasuryReceiver, _totalSupply);
        _updateAccountSnapshot(treasuryReceiver);
    }

    function setVoteContract(address _address)
        external
        onlyOwner
        returns (bool)
    {
        require(isContract(_address));
        voteContract = IRemedaoVote(_address);
        if (address(this).balance != 0) {
            (bool success, ) = payable(address(voteContract)).call{
                value: address(this).balance,
                gas: 30000
            }("");
            return success;
        }
        return true;
    }

    function rebase() internal {
        if (!shouldRebase()) return;
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _rebaseStartTime;
        uint256 epoch = currentRebaseEpoch();
        uint256 times = epoch - _rebaseEpoch;

        if (deltaTimeFromInit < (365 days)) {
            rebaseRate = 2500;
        } else if (deltaTimeFromInit >= (5 * 365 days)) {
            rebaseRate = 5;
        } else if (deltaTimeFromInit >= ((15 * 365 days) / 10)) {
            rebaseRate = 25;
        } else if (deltaTimeFromInit >= (365 days)) {
            rebaseRate = 250;
        }

        _totalSupply = _totalSupply
            .mul(((10**RATE_DECIMALS).add(rebaseRate))**times)
            .div((10**RATE_DECIMALS)**times);

        gonsPerFragment = TOTAL_GONS.div(_totalSupply);
        pairContract.sync();
        _rebaseEpoch = epoch;
        if (lockAddress != address(0)) {
            if (balanceOf(lockAddress) > lockMaxBalance) {
                _gonBalances[lockAddress] = lockMaxBalance.mul(gonsPerFragment);
                _gonBalances[offChainGameReceiver] = _gonBalances[
                    offChainGameReceiver
                ].add(
                        _gonBalances[lockAddress] -
                            lockMaxBalance.mul(gonsPerFragment)
                    );
                _updateAccountSnapshot(lockAddress);
                _updateAccountSnapshot(offChainGameReceiver);
            }
        }
        emit Rebase(epoch, _totalSupply);
    }

    function currentRebaseEpoch() public view returns (uint256) {
        return (block.timestamp - _rebaseStartTime).div(16 minutes);
    }

    function currentMemeEpoch() public view override returns (uint256) {
        return (block.timestamp - _memeStartTime).div(1 minutes).add(1);
    }

    function shouldRebase() internal view returns (bool) {
        uint256 epoch = currentRebaseEpoch();
        return
            isStartRebase &&
            _autoRebase &&
            (_totalSupply < MAX_SUPPLY) &&
            msg.sender != pair &&
            !inSwap &&
            epoch > _rebaseEpoch;
    }

    function _sellToken(uint256 amountToSwap) internal returns (uint256) {
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
        return address(this).balance.sub(balanceBefore);
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

    function manualRebase() external {
        require(shouldRebase(), "Too early to rebase");
        rebase();
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
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
        uint256 gonAmount = amount.mul(gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(gonAmount);
        _gonBalances[to] = _gonBalances[to].add(gonAmount);
        return true;
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "blacklist");
        uint256 gonAmount = amount.mul(gonsPerFragment);
        uint256 epoch = currentMemeEpoch();
        if (address(voteContract) != address(0)) {
            require(!voteContract.lockVote(epoch, sender));
        }
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        rebase();
        if (shouldSwapBack()) {
            swapBack();
        }
        if (recipient == address(pair) && !_isFeeExempt[sender]) {
            uint256 currentMaxSell = _gonBalances[sender].mul(maxSell).div(
                maxSellDenominator
            );
            maxSellInEpoch[sender][epoch] = currentMaxSell >
                maxSellInEpoch[sender][epoch]
                ? currentMaxSell
                : maxSellInEpoch[sender][epoch];
            require(
                sell[sender][epoch].add(gonAmount) <=
                    maxSellInEpoch[sender][epoch]
            );
            sell[sender][epoch] = sell[sender][epoch].add(gonAmount);
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );

        _updateAccountSnapshot(sender);
        _updateAccountSnapshot(recipient);

        emit Transfer(
            sender,
            recipient,
            gonAmountReceived.div(gonsPerFragment)
        );
        return true;
    }

    function takeFee(address sender, uint256 gonAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = gonAmount.div(feeDenominator).mul(totalFee);

        _gonBalances[address(this)] = _gonBalances[address(this)].add(
            gonAmount.mul(treasuryFee.add(insuranceFundFee).add(memeFee)).div(
                feeDenominator
            )
        );
        emit Transfer(sender, address(this), feeAmount.div(gonsPerFragment));
        return gonAmount.sub(feeAmount);
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = _gonBalances[address(this)].div(gonsPerFragment);

        if (amountToSwap == 0) {
            return;
        }
        uint256 amountETH = _sellToken(amountToSwap);
        uint256 _memeDenominator = treasuryFee.add(insuranceFundFee).add(
            memeFee
        );
        (bool success, ) = payable(treasuryReceiver).call{
            value: amountETH.mul(treasuryFee).div(_memeDenominator),
            gas: 30000
        }("");
        (success, ) = payable(insuranceFundReceiver).call{
            value: amountETH.mul(insuranceFundFee).div(_memeDenominator),
            gas: 30000
        }("");
        if (address(voteContract) != address(0)) {
            (success, ) = payable(address(voteContract)).call{
                value: amountETH.mul(memeFee).div(_memeDenominator),
                gas: 30000
            }("");
        }
    }

    function startRebase() external onlyOwner {
        require(!isStartRebase);
        isStartRebase = true;
        _autoRebase = true;
        _rebaseStartTime = block.timestamp;
    }

    function shouldTakeFee(address from, address to)
        internal
        view
        returns (bool)
    {
        return (pair == from || pair == to) && !_isFeeExempt[from];
    }

    function shouldSwapBack() internal view returns (bool) {
        return !inSwap && msg.sender != pair;
    }

    function setAutoRebase(bool _flag) external onlyOwner {
        if (_flag) {
            _autoRebase = _flag;
        } else {
            _autoRebase = _flag;
        }
    }

    function setLockAddress(address _address) external onlyOwner {
        lockAddress = _address;
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

    function isNotInSwap() external view returns (bool) {
        return !inSwap;
    }

    function setFeeReceivers(
        address _treasuryReceiver,
        address _insuranceFundReceiver,
        address _offChainGameReceiver
    ) external onlyOwner {
        treasuryReceiver = _treasuryReceiver;
        insuranceFundReceiver = _insuranceFundReceiver;
        offChainGameReceiver = _offChainGameReceiver;
    }

    function setMaxSell(uint256 _maxSell) external onlyOwner {
        require(maxSell <= 1000);
        maxSell = _maxSell;
    }

    function setFee(
        uint256 _treasuryFee,
        uint256 _insuranceFundFee,
        uint256 _memeFee
    ) external onlyOwner {
        require(_treasuryFee + _insuranceFundFee + _memeFee < 150);
        treasuryFee = _treasuryFee;
        insuranceFundFee = _insuranceFundFee;
        memeFee = _memeFee;
        totalFee = treasuryFee.add(insuranceFundFee).add(memeFee);
    }

    function setWhitelist(address _addr, bool _flag) external onlyOwner {
        _isFeeExempt[_addr] = _flag;
    }

    function setBotBlacklist(address _botAddress, bool _flag)
        external
        onlyOwner
    {
        require(isContract(_botAddress), "only contract address");
        blacklist[_botAddress] = _flag;
    }

    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
        pair = pairAddress;
        pairContract = IPancakeSwapPair(pair);
    }

    function setLP(address _address) external onlyOwner {
        pairContract = IPancakeSwapPair(_address);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view override returns (uint256) {
        return _gonBalances[who].div(gonsPerFragment);
    }

    function gonOf(address who) public view override returns (uint256) {
        return _gonBalances[who];
    }

    function gonOfAt(address account, uint256 snapshotId)
        public
        view
        override
        returns (uint256)
    {
        return _valueAt(snapshotId, _accountBalanceSnapshots[account]);
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots)
        private
        view
        returns (uint256)
    {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(
            snapshotId <= currentMemeEpoch(),
            "ERC20Snapshot: nonexistent id"
        );
        uint256 index = snapshots.ids.findDownerBound(snapshotId);
        if (index == 0 && snapshots.ids[0] > snapshotId) {
            return 0;
        } else {
            return snapshots.values[index];
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], gonOf(account));
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
        uint256 currentId = currentMemeEpoch();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        } else {
            snapshots.values[snapshots.values.length - 1] = currentValue;
        }
    }

    function _lastSnapshotId(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    receive() external payable {}
}