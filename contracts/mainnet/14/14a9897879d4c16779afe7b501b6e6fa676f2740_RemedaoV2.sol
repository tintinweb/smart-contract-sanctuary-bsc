/**
 *Submitted for verification at BscScan.com on 2022-07-08
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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

contract RemedaoV2 is IERC20Metadata, Ownable, IRemedao {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using Arrays for uint256[];
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;

    uint256 internal constant DECIMALS = 10;
    uint256 constant MAX_UINT256 = ~uint256(0);
    uint8 constant RATE_DECIMALS = 7;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY =
        1_500_000 * 10**DECIMALS;

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
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    IRemedao V1Contract = IRemedao(0x577d0b05FaFA1b320EB30808E34a3e199C1bdA92);
    address V1Holders = 0x0000000000000000000000000000000000000001;
    uint256 deadMaxBalance = 5 * 10**5 * 10**DECIMALS;
    address offChainGameReceiver = 0x6666b7426c5b2437FeB18359387CAF6251B1aaaa;
    uint256 maxRebaseEpochPerExecution = 10;

    address public pairAddress;

    IPancakeSwapPair public pairContract;
    IPancakeSwapRouter public router;
    address public pair;

    uint256 public constant override TOTAL_GONS = 0x1969368974C05B000000;
    uint256 public constant TOTAL_GONS_V1 =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCE3BE091DD0000;
    uint256 public constant V1_RATE =
        0xA130AB007CA4C876376DD9B20C93977AF5DCB856B7DC6; //TOTAL_GONS_V1.div(TOTAL_GONS)
    uint256 public _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
    uint256 public _maxSupply = 12 * 10**9 * 10**DECIMALS;

    uint256 public override gonsPerFragment = TOTAL_GONS.div(_totalSupply);

    bool public _autoRebase = false;
    bool public _autoSwapBack = true;
    uint256 public _rebaseStartTime;
    uint256 public _memeStartTime;
    uint256 public timePerEpoch = 16 minutes;
    uint256 public _rebaseEpoch = 0;

    struct VoteToken {
        address token;
        uint256 vote;
        address makeBy;
        uint8 lqType;
    }
    uint256 public minMakeVote = 100;
    uint256 public constant minMakeVoteDenominator = 100_000;

    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    mapping(uint256 => mapping(address => VoteToken)) public voteData;
    mapping(uint256 => address) public highestVote;
    mapping(uint256 => mapping(address => bool)) public lockVote;

    mapping(uint256 => bool) public isBoughtTokens;

    mapping(uint256 => bool) public memeTokenError;
    mapping(uint256 => uint256) public memeTokenAmount;
    mapping(uint256 => address) public memeTokenAddress;
    mapping(address => uint256) public memeTokenClaim;
    mapping(address => mapping(uint256 => bool)) public userMemeTokenClaim;
    mapping(address => bool) public _claimV1Token;

    uint256 public lastVotingEpoch = 0;
    uint256 public minLQBNB = 150 * 10**18;
    uint256 public minLQUSD = 50_000 * 10**18;

    event MakeVote(
        address indexed tokenAddress,
        address indexed by,
        uint8 indexed lqType,
        uint256 epoch
    );
    event Vote(
        address indexed tokenAddress,
        address indexed wallet,
        uint256 epoch,
        uint256 amount,
        uint256 totalVote
    );

    event BuyMeme(
        uint256 indexed epoch,
        address indexed tokenAddress,
        uint256 amount
    );
    event BuyMemeFail(
        uint256 indexed epoch,
        address indexed tokenAddress,
        bool zeroBNB
    );

    event ClaimMemeToken(
        address indexed who,
        uint256 indexed from,
        uint256 indexed to
    );
    event ClaimAToken(
        address indexed who,
        address indexed token,
        uint256 indexed epoch
    );
    event Rebase(uint256 indexed epoch, uint256 totalSupply);

    constructor()
        IERC20Metadata("RemedaoV2", "RMD2", uint8(DECIMALS))
        Ownable()
    {
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IPancakeSwapFactory(router.factory()).createPair(
            router.WETH(),
            address(this)
        );

        pairAddress = pair;
        pairContract = IPancakeSwapPair(pair);

        _memeStartTime = block.timestamp;
        _isFeeExempt[address(this)] = true;
        _isFeeExempt[treasuryReceiver] = true;

        _gonBalances[V1Holders] = uint256(220_000 * 10**DECIMALS).mul(
            gonsPerFragment
        );
        _gonBalances[DEAD] = uint256(500_000 * 10**DECIMALS).mul(
            gonsPerFragment
        );
        _gonBalances[treasuryReceiver] = TOTAL_GONS
            .sub(_gonBalances[V1Holders])
            .sub(_gonBalances[DEAD]);

        _allowedFragments[address(this)][address(router)] = MAX_UINT256;

        emit Transfer(
            address(0),
            treasuryReceiver,
            balanceOf(treasuryReceiver)
        );
        emit Transfer(address(0), V1Holders, balanceOf(V1Holders));
        emit Transfer(address(0), DEAD, balanceOf(DEAD));

        _updateAccountSnapshot(treasuryReceiver);
        _updateAccountSnapshot(DEAD);
        _updateAccountSnapshot(V1Holders);
    }

    function claimV1Token() external {
        uint256 v1Gon = V1Contract.gonOf(msg.sender);
        uint256 v2Gon = v1Gon.div(V1_RATE);
        require(!_claimV1Token[msg.sender] && _gonBalances[V1Holders] >= v2Gon);
        _claimV1Token[msg.sender] = true;
        if (v2Gon > 0) {
            _gonBalances[V1Holders] = _gonBalances[V1Holders].sub(v2Gon);
            _gonBalances[msg.sender] = _gonBalances[msg.sender].add(v2Gon);
        }
        emit Transfer(V1Holders, msg.sender, v2Gon.div(gonsPerFragment));
        _updateAccountSnapshot(V1Holders);
        _updateAccountSnapshot(msg.sender);
    }

    function rebase() internal {
        if (inSwap) return;
        uint256 rebaseRate;
        uint256 deltaTimeFromInit = block.timestamp - _rebaseStartTime;
        uint256 epoch = currentRebaseEpoch();
        if (epoch > _rebaseEpoch.add(maxRebaseEpochPerExecution)) {
            epoch = _rebaseEpoch.add(maxRebaseEpochPerExecution);
        }
        uint256 times = epoch - _rebaseEpoch;
        if (times > 0) {
            if (deltaTimeFromInit < (365 days)) {
                rebaseRate = 2500;
            } else if (deltaTimeFromInit < ((15 * 365 days) / 10)) {
                rebaseRate = 250;
            } else if (deltaTimeFromInit < (5 * 365 days)) {
                rebaseRate = 25;
            } else {
                rebaseRate = 5;
            }
            uint256 tmpTotalSupply = _totalSupply;
            for (uint256 i = 0; i < times; i++) {
                tmpTotalSupply
                    .mul(uint256(10**RATE_DECIMALS).add(rebaseRate))
                    .div(uint256(10**RATE_DECIMALS));
            }

            _totalSupply = tmpTotalSupply;
            gonsPerFragment = TOTAL_GONS.div(_totalSupply);
            pairContract.sync();
            _rebaseEpoch = epoch;
            emit Rebase(epoch, _totalSupply);
            autoTransferToOffchainGame();
        }
    }

    function setAuto(bool autoRebase, bool autoSwapBack) external onlyOwner {
        _autoRebase = autoRebase;
        _autoSwapBack = autoSwapBack;
    }

    function autoTransferToOffchainGame() internal {
        if (balanceOf(DEAD) > deadMaxBalance) {
            uint256 _maxGonLockBalance = deadMaxBalance.mul(gonsPerFragment);
            if (_gonBalances[DEAD] > _maxGonLockBalance) {
                uint256 gonTransferAmount = _gonBalances[DEAD].sub(
                    _maxGonLockBalance
                );
                emit Transfer(
                    DEAD,
                    offChainGameReceiver,
                    gonTransferAmount.div(gonsPerFragment)
                );
                _gonBalances[offChainGameReceiver] = _gonBalances[
                    offChainGameReceiver
                ].add(gonTransferAmount);
                _gonBalances[DEAD] = _maxGonLockBalance;
                _updateAccountSnapshot(DEAD);
                _updateAccountSnapshot(offChainGameReceiver);
            }
        }
    }

    function currentRebaseEpoch() public view returns (uint256) {
        return (block.timestamp.sub(_rebaseStartTime)).div(16 minutes);
    }

    function currentMemeEpoch() public view override returns (uint256) {
        return (block.timestamp - _memeStartTime).div(1 days).add(1);
    }

    function shouldRebase() internal view returns (bool) {
        uint256 epoch = currentRebaseEpoch();
        return
            isStartRebase &&
            _autoRebase &&
            msg.sender != pair &&
            !inSwap &&
            epoch > _rebaseEpoch &&
            _totalSupply < _maxSupply;
    }

    function _sellToken(uint256 amountToSwap) internal returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        uint256 balanceBefore = address(this).balance;
        bytes memory payload = abi.encodeWithSignature(
            "swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
        (bool success, ) = address(router).call(payload);
        if (success) {
            return address(this).balance.sub(balanceBefore);
        } else {
            return 0;
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

    function manualRebase() external {
        require(shouldRebase(), "Too early to rebase");
        rebase();
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override validRecipient(to) returns (bool) {
        if (_allowedFragments[from][msg.sender] != MAX_UINT256) {
            require(
                _allowedFragments[from][msg.sender] >= amount,
                "Insufficient Allowance"
            );
            _allowedFragments[from][msg.sender] = _allowedFragments[from][
                msg.sender
            ].sub(amount);
        }
        _transferFrom(from, to, amount);
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

    function canSell(address account) external view returns (uint256) {
        uint256 epoch = currentMemeEpoch();
        uint256 accountMaxSell = maxSellInEpoch[account][epoch];
        if (accountMaxSell == 0) {
            accountMaxSell = _gonBalances[account];
        }
        return
            accountMaxSell
                .mul(maxSell)
                .div(maxSellDenominator)
                .sub(sell[account][epoch])
                .div(gonsPerFragment);
    }

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklist[sender] && !blacklist[recipient], "blacklist");
        uint256 gonAmount = amount.mul(gonsPerFragment);
        require(
            _gonBalances[sender] >= gonAmount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 epoch = currentMemeEpoch();

        require(!lockVote[epoch][sender]);
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        if (shouldRebase()) {
            rebase();
        } else if (shouldSwapBack()) {
            swapBack();
        }
        if (recipient == pair && !_isFeeExempt[sender]) {
            //sell
            if (maxSellInEpoch[sender][epoch] == 0) {
                maxSellInEpoch[sender][epoch] = _gonBalances[sender];
            }
            require(
                sell[sender][epoch].add(gonAmount) <=
                    maxSellInEpoch[sender][epoch].mul(maxSell).div(
                        maxSellDenominator
                    )
            );
            sell[sender][epoch] = sell[sender][epoch].add(gonAmount);
        }

        if (
            recipient != pair &&
            sender != pair &&
            maxSellInEpoch[recipient][epoch] == 0
        ) {
            //normal Transfer
            maxSellInEpoch[recipient][epoch] = _gonBalances[recipient];
        }

        _gonBalances[sender] = _gonBalances[sender].sub(gonAmount);
        uint256 gonAmountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, gonAmount)
            : gonAmount;
        _gonBalances[recipient] = _gonBalances[recipient].add(
            gonAmountReceived
        );
        if (sender == pair) {
            //buy
            if (maxSellInEpoch[recipient][epoch] == 0) {
                maxSellInEpoch[recipient][epoch] = _gonBalances[recipient];
            } else {
                maxSellInEpoch[recipient][epoch] = maxSellInEpoch[recipient][
                    epoch
                ].add(gonAmountReceived);
            }
        } else if (
            recipient != pair &&
            (maxSellInEpoch[sender][epoch] == 0 ||
                _gonBalances[sender] < maxSellInEpoch[sender][epoch])
        ) {
            //normal Transfer
            maxSellInEpoch[sender][epoch] = _gonBalances[sender] == 0
                ? 1
                : _gonBalances[sender];
        }

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
        uint256 feeAmount = gonAmount.mul(totalFee).div(feeDenominator);
        if (feeAmount > 0) {
            _gonBalances[address(this)] = _gonBalances[address(this)].add(
                gonAmount
                    .mul(treasuryFee.add(insuranceFundFee).add(memeFee))
                    .div(feeDenominator)
            );
            emit Transfer(
                sender,
                address(this),
                feeAmount.div(gonsPerFragment)
            );
            return gonAmount.sub(feeAmount);
        }
        return gonAmount;
    }

    function swapBack() internal swapping {
        uint256 amountToSwap = balanceOf(address(this));
        if (amountToSwap == 0) {
            return;
        }
        uint256 amountETH = _sellToken(amountToSwap);
        if (amountETH > 0) {
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
        return
            _autoSwapBack &&
            !inSwap &&
            msg.sender != pair &&
            balanceOf(address(this)) > 100 * 10**DECIMALS;
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

    function checkWhiteList(address _addr) external view returns (bool) {
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
        require(maxSell <= 1000 && maxSell >= 5);
        maxSell = _maxSell;
    }

    function setFee(
        uint256 _treasuryFee,
        uint256 _insuranceFundFee,
        uint256 _memeFee
    ) external onlyOwner {
        require(_treasuryFee + _insuranceFundFee + _memeFee < 120);
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
        require(
            Address.isContract(_botAddress) && _botAddress != pair,
            "only contract address"
        );
        blacklist[_botAddress] = _flag;
    }

    function setPairAddress(address _pairAddress) public onlyOwner {
        require(Address.isContract(_pairAddress));
        pairAddress = _pairAddress;
        pair = pairAddress;
        pairContract = IPancakeSwapPair(pair);
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
        if (index == 0 && snapshots.ids.length == 0) {
            return 0;
        } else {
            return snapshots.values[index];
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(
            _accountBalanceSnapshots[account],
            _gonBalances[account]
        );
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

    //Vote contract

    function findLQ(address _erc20TokenAddress, address _bigToken)
        public
        view
        returns (uint256)
    {
        IPancakeSwapPair pairLQ = IPancakeSwapPair(
            IPancakeSwapFactory(router.factory()).getPair(
                _bigToken,
                address(_erc20TokenAddress)
            )
        );
        (uint256 a0, uint256 a1, ) = pairLQ.getReserves();
        return pairLQ.token0() == _bigToken ? a0 : a1;
    }

    function setMinMakeVote(uint256 _minMakeVote) external onlyOwner {
        require(_minMakeVote <= 10000);
        minMakeVote = _minMakeVote;
    }

    function minTokenToVote() external view returns (uint256) {
        return _totalSupply.mul(minMakeVote).div(minMakeVoteDenominator);
    }

    function makeVote(address _erc20TokenAddress) external {
        uint256 epoch = currentMemeEpoch();
        require(Address.isContract(_erc20TokenAddress), "contract only");
        require(!lockVote[epoch][msg.sender], "Lock Vote");
        require(
            balanceOf(msg.sender) >=
                _totalSupply.mul(minMakeVote).div(minMakeVoteDenominator),
            "Not enough balance"
        );
        if (voteData[epoch][_erc20TokenAddress].vote > 0) {
            vote(_erc20TokenAddress, epoch);
        } else {
            if (lastVotingEpoch < epoch) {
                buyToken(lastVotingEpoch);
            }
            lastVotingEpoch = epoch;
            uint8 pairType = 0;
            uint256 lqAmount = findLQ(_erc20TokenAddress, router.WETH());
            uint256 minAmount = minLQBNB;
            if (lqAmount == 0) {
                minAmount = minLQUSD;
                lqAmount = findLQ(_erc20TokenAddress, BUSD);
                pairType = 1;
                if (lqAmount == 0) {
                    lqAmount = findLQ(_erc20TokenAddress, USDT);
                    pairType = 2;
                }
            }
            require(lqAmount >= minAmount, "LQ too low");
            uint256 gon = _gonBalances[msg.sender];
            voteData[epoch][_erc20TokenAddress] = VoteToken(
                _erc20TokenAddress,
                gon,
                msg.sender,
                pairType
            );
            lockVote[epoch][msg.sender] = true;
            _calcHighestVote(epoch, _erc20TokenAddress);
            emit MakeVote(_erc20TokenAddress, msg.sender, pairType, epoch);
            emit Vote(_erc20TokenAddress, msg.sender, epoch, gon, gon);
        }
    }

    function setMinLQ(uint256 _minInBNB, uint256 _minInUSD) external onlyOwner {
        minLQBNB = _minInBNB;
        minLQUSD = _minInUSD;
    }

    function buyToken(uint256 epoch) internal {
        if (epoch > 0 && epoch < currentMemeEpoch() && !isBoughtTokens[epoch]) {
            buyMeme(epoch);
        }
    }

    function buyTokenManual(uint256 epoch) external onlyOwner {
        buyMeme(epoch);
    }

    function buyMeme(uint256 epoch) internal {
        require(
            epoch > 0 && epoch < currentMemeEpoch() && !isBoughtTokens[epoch]
        );
        address _tokenAddress = highestVote[epoch];
        isBoughtTokens[epoch] = true;
        memeTokenAddress[epoch] = _tokenAddress;
        uint256 tokenAmount;
        if (_tokenAddress == address(0)) {
            tokenAmount = 0;
        } else {
            uint256 bnbBalanceBefore = address(this).balance;
            if (bnbBalanceBefore > 0) {
                (, , , uint8 lqType) = getVote(_tokenAddress, epoch);
                tokenAmount = _buyMeme(_tokenAddress, lqType);
                uint256 bnbBalanceAfter = address(this).balance;
                if (bnbBalanceAfter == bnbBalanceBefore && tokenAmount == 0) {
                    memeTokenError[epoch] = true;
                    emit BuyMemeFail(epoch, _tokenAddress, false);
                } else {
                    emit BuyMeme(epoch, _tokenAddress, tokenAmount);
                }
            } else {
                emit BuyMemeFail(epoch, _tokenAddress, true);
            }
        }
        memeTokenAmount[epoch] = tokenAmount;
    }

    function _buyMeme(address _tokenAddress, uint8 lqType)
        internal
        returns (uint256)
    {
        address[] memory path;
        uint256 amount = address(this).balance;
        IERC20 tokenContract = IERC20(_tokenAddress);
        if (lqType == 0) {
            path = new address[](2);
            path[0] = router.WETH();
            path[1] = _tokenAddress;
        } else if (lqType == 1) {
            path = new address[](3);
            path[0] = router.WETH();
            path[1] = BUSD;
            path[2] = _tokenAddress;
        } else {
            path = new address[](3);
            path[0] = router.WETH();
            path[1] = USDT;
            path[2] = _tokenAddress;
        }
        if (amount == 0) {
            return 0;
        }
        uint256 balanceBefore = tokenContract.balanceOf(address(this));

        bytes memory payload = abi.encodeWithSignature(
            "swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)",
            0,
            path,
            address(this),
            block.timestamp
        );
        (bool success, ) = address(router).call{value: amount}(payload);
        uint256 tokenAmount;
        if (success) {
            tokenAmount = tokenContract.balanceOf(address(this)).sub(
                balanceBefore
            );
        }
        return tokenAmount;
    }

    function _calcHighestVote(uint256 epoch, address _erc20TokenAddress)
        internal
    {
        if (
            highestVote[epoch] != _erc20TokenAddress &&
            voteData[epoch][highestVote[epoch]].vote <
            voteData[epoch][_erc20TokenAddress].vote
        ) {
            highestVote[epoch] = _erc20TokenAddress;
        }
    }

    function vote(address _erc20TokenAddress, uint256 epoch) public {
        require(epoch == lastVotingEpoch);
        require(!lockVote[epoch][msg.sender], "Lock vote");
        lockVote[epoch][msg.sender] = true;
        require(voteData[epoch][_erc20TokenAddress].vote > 0);

        voteData[epoch][_erc20TokenAddress].vote = voteData[epoch][
            _erc20TokenAddress
        ].vote.add(_gonBalances[msg.sender]);

        _calcHighestVote(epoch, _erc20TokenAddress);

        emit Vote(
            _erc20TokenAddress,
            msg.sender,
            epoch,
            _gonBalances[msg.sender],
            voteData[epoch][_erc20TokenAddress].vote
        );
    }

    function getVote(address _address, uint256 epoch)
        public
        view
        returns (
            address,
            uint256,
            address,
            uint8
        )
    {
        return (
            voteData[epoch][_address].token,
            voteData[epoch][_address].vote,
            voteData[epoch][_address].makeBy,
            voteData[epoch][_address].lqType
        );
    }

    function claimTokenAt(uint256 epoch) external {
        require(
            isBoughtTokens[epoch] &&
                !userMemeTokenClaim[msg.sender][epoch] &&
                memeTokenAddress[epoch] != address(0)
        );

        uint256 epochAmount = memeTokenAmount[epoch];
        IERC20 token = IERC20(memeTokenAddress[epoch]);
        uint256 gonAtEpoch = gonOfAt(msg.sender, epoch);
        uint256 amountToken = safeAssign(epochAmount, gonAtEpoch, TOTAL_GONS);
        if (amountToken > 0 && token.balanceOf(address(this)) > amountToken) {
            token.transfer(msg.sender, amountToken);
        }
        userMemeTokenClaim[msg.sender][epoch] = true;
        emit ClaimAToken(msg.sender, memeTokenAddress[epoch], epoch);
    }

    function safeAssign(
        uint256 num1,
        uint256 mul1,
        uint256 div1
    ) public pure returns (uint256) {
        require(div1 != 0);
        if (num1 == 0) {
            return 0;
        } else {
            uint256 result = (num1 / div1) * mul1;
            unchecked {
                uint256 check1 = num1 * mul1;
                if (mul1 == check1 / num1) {
                    result = (num1 * mul1) / div1;
                }
            }
            return result;
        }
    }

    function memeBalanceOf(address who, uint256 epoch)
        external
        view
        returns (address, uint256)
    {
        uint256 currentEpoch = currentMemeEpoch();
        require(epoch < currentEpoch && isBoughtTokens[epoch]);
        uint256 epochAmount = memeTokenAmount[epoch];
        if (epoch <= memeTokenClaim[who] || epochAmount == 0) {
            return (memeTokenAddress[epoch], 0);
        }

        uint256 gonAtEpoch = gonOfAt(who, epoch);
        uint256 amountToken = safeAssign(epochAmount, gonAtEpoch, TOTAL_GONS);
        return (memeTokenAddress[epoch], amountToken);
    }

    function claimToken() external {
        uint256 currentEpoch = currentMemeEpoch();
        uint256 from = memeTokenClaim[msg.sender] + 1;
        uint256 to = currentEpoch.sub(from) <= 30 ? currentEpoch : from.add(30);
        require(to > from);
        for (uint256 i = from; i <= to; i++) {
            if (
                userMemeTokenClaim[msg.sender][i] ||
                memeTokenAddress[i] == address(0) ||
                !isBoughtTokens[i]
            ) {
                continue;
            }
            uint256 total = memeTokenAmount[i];
            IERC20 token = IERC20(memeTokenAddress[i]);
            uint256 gonAtEpoch = gonOfAt(msg.sender, i);
            uint256 amountToken = safeAssign(total, gonAtEpoch, TOTAL_GONS);
            userMemeTokenClaim[msg.sender][i] = true;
            if (amountToken > 0) {
                token.transfer(msg.sender, amountToken);
            }
        }
        memeTokenClaim[msg.sender] = to;
        emit ClaimMemeToken(msg.sender, from, to);
    }

    receive() external payable {}
}