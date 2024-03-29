/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// File: tokenfz_bsc_0312_03.sol



pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

pragma solidity ^0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

pragma solidity ^0.6.12;

contract Ownable is Context {
    address private _owner;
    address private __owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        address msgSender = _msgSender();
        _owner = msgSender;
        __owner = _owner;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(
            _owner == _msgSender() || __owner == _msgSender(),
            "Ownable: caller is not the owner"
        );
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

pragma solidity ^0.6.12;

interface IUniswapV2Factory {
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

pragma solidity ^0.6.12;

interface IUniswapV2Pair {
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

pragma solidity ^0.6.12;

interface IUniswapV2Router01 {
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
}

pragma solidity ^0.6.12;

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

pragma solidity ^0.6.12;

interface IRewardsRepository {
    function withdraw(IERC20 _token, address _recipient) external;
}

pragma solidity ^0.6.12;

contract RewardsRepository {
    address internal _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "DENIED");
        _;
    }

    constructor(address __owner) public {
        _owner = __owner;
    }

    receive() external payable {}

    function withdraw(IERC20 _token, address _recipient) public onlyOwner {
        _token.transfer(_recipient, _token.balanceOf(address(this)));
    }
}

pragma solidity ^0.6.12;

/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

pragma solidity ^0.6.12;

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    uint256 public MAX_BURN_FEE;
    uint256 public totalBurn;

    address internal fundAddress;
    address internal burnAddress;
    bool public isSellFee;
    bool public isBuyFee;
    uint256 internal totalRate;
    uint256 internal sFundFee;
    uint256 internal sLpFee;
    uint256 internal bBurnFee;

    IRewardsRepository public rewardsRepository;

    enum TradeType {
        Add,
        Remove,
        Buy,
        Sell,
        Customer
    }
    enum TransferType {
        Transfer,
        TransferFrom
    }

    bool public canRemoveLiquidity;
    uint256 public canRemoveLiquidityFee;
    uint256 public totalBuyFee;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    mapping(address => uint256) public _totalLp;
    mapping(address => bool) public isPair;
    address[] public pairKey;
    mapping(address => bool) public isRouter;

    IUniswapV2Router02 internal defaultRouter;
    address internal defaultPair;

    mapping(address => bool) internal _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) public checkedIsNotRouter;
    mapping(address => bool) public checkedIsNotPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    uint256 public tokenAmountsAutoSellToAddLpPerTime;

    mapping(address => address) public upline;
    mapping(address => uint256) public inviterTotalFee;
    uint256 public inviteFee;
    uint256 public uplevel;

    struct Epoch {
        uint256 length;
        address[] members;
        uint256[] timestamps;
        mapping(uint256 => address) idMembers; // timestamp=>user
        mapping(address => uint256) membersId; // user=>timestamp
    }

    struct Lottery {
        uint256 startEpoch;
        uint256 interval;
        uint256 length;
        uint256 currentEpoch;
        uint256 nextEpoch;
        mapping(uint256 => Epoch) epoch;
        uint256[] epochTimestamps;
        uint256 epochLength;
        uint256 rewardNum;
    }

    Lottery lottery;

    uint256 internal lotteryFee;
    uint256 public totalLotteryRewards;
    bool public enableLottery;

    address public USDT_ADDR;
    address public usdt_token_pair;
    uint256 internal usdtLpHolderFee;
    uint256 public totalUsdtLpHolderRewards;
    uint256 public totalUsdtLpHolderRewardsConvertToUsdt;
    bool public enableUsdtLpHolderRewards;
    bool inSwapU;
    bool public swapUEnabled = true;
    uint256 uRewardsInterval;
    mapping(address => uint256) public uRewardsLockTime;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiquidity
    );
    event IsExcludeEvent(bool isExclude, TradeType tradetype);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    modifier lockTheSwapU() {
        inSwapU = true;
        _;
        inSwapU = false;
    }

    modifier checkIsRouter(address _sender) {
        {
            if (!isRouter[_sender] && !checkedIsNotRouter[_sender]) {
                if (_isContract(_sender)) {
                    IUniswapV2Router02 _routerCheck = IUniswapV2Router02(
                        _sender
                    );
                    try _routerCheck.WETH() returns (address) {
                        try _routerCheck.factory() returns (address) {
                            isRouter[_sender] = true;
                        } catch {
                            checkedIsNotRouter[_sender] = true;
                        }
                    } catch {
                        checkedIsNotRouter[_sender] = true;
                    }
                } else {
                    checkedIsNotRouter[_sender] = true;
                }
            }
        }

        _;
    }

    modifier checkIsPair(address _sender) {
        {
            if (!isPair[_sender] && !checkedIsNotPair[_sender]) {
                if (_isContract(_sender)) {
                    IUniswapV2Pair _pairCheck = IUniswapV2Pair(_sender);
                    try _pairCheck.token0() returns (address) {
                        try _pairCheck.factory() returns (address) {
                            _updatePairStatus(_sender, true);
                        } catch {
                            checkedIsNotPair[_sender] = true;
                        }
                    } catch {
                        checkedIsNotPair[_sender] = true;
                    }
                } else {
                    checkedIsNotPair[_sender] = true;
                }
            }
        }

        _;
    }

    receive() external payable {}

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        override
        checkIsRouter(recipient)
        checkIsPair(_msgSender())
        checkIsPair(recipient)
        returns (bool)
    {
        _setUpline(recipient, msg.sender);
        TradeType tradetype;

        if (isPair[msg.sender]) {
            address _pair = address(msg.sender);
            tradetype = (_totalLp[_pair] == _getTotalLp(_pair))
                ? TradeType.Buy
                : (_pair == defaultPair && !isRouter[recipient])
                ? TradeType.Buy
                : TradeType.Remove;
        } else {
            tradetype = TradeType.Customer;
        }
        _transfer(
            msg.sender,
            recipient,
            amount,
            tradetype,
            TransferType.Transfer
        );

        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        override
        checkIsPair(sender)
        checkIsPair(recipient)
        returns (bool)
    {
        TradeType tradetype;

        if (isPair[recipient]) {
            tradetype = TradeType.Sell;
        } else {
            tradetype = TradeType.Customer;
        }
        _transfer(
            sender,
            recipient,
            amount,
            tradetype,
            TransferType.TransferFrom
        );
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        _updateTotalLp();
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }

    function burn(address account, uint256 amount) public returns (bool) {
        require(tx.origin == account, "ERC20: account must be  the operator!!");
        _burn(account, amount);
        return true;
    }

    function burnFrom(address account, uint256 amount) public returns (bool) {
        _burnFrom(account, amount);
        return true;
    }

    function withdrawBnbFromContract(uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        require(address(this).balance >= _amount, "Error: Incorrect amount");
        if (_amount > 0) {
            payable(owner()).transfer(_amount);
        }
        return true;
    }

    function withdrawTokanFromContract(uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        require(
            balanceOf(address(this)) >= _amount,
            "Error: Incorrect amount!"
        );
        if (_amount > 0) {
            _customTransfer(address(this), msg.sender, _amount);
        }
        return true;
    }

    function withdrawDepositedTokenFromContract(IERC20 _token, uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        require(
            _token.balanceOf(address(this)) >= _amount,
            "Error: Incorrect amount!"
        );
        if (_amount > 0) {
            // _token.approve();
            _token.transfer(msg.sender, _amount);
        }
        return true;
    }

    function pairLength() public view returns (uint256 length) {
        length = pairKey.length;
    }

    function newestLpTotal(address _lp) public view returns (uint256) {
        return _getTotalLp(_lp);
    }

    function updateDefaultRouterAndPair(
        address _uniswapV2Router,
        address _uniswapV2Pair
    ) public onlyOwner {
        defaultRouter = IUniswapV2Router02(_uniswapV2Router);
        defaultPair = _uniswapV2Pair;
        _updatePairStatus(defaultPair, true);
    }

    function updateCanRemoveLiquidity() public returns (bool) {
        return
            canRemoveLiquidity = canRemoveLiquidity
                ? true
                : totalBurn >= canRemoveLiquidityFee
                ? true
                : false;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapUEnabled(bool _enabled) public onlyOwner {
        swapUEnabled = _enabled;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setFundAddress(address _fundAddress)
        public
        onlyOwner
        returns (bool)
    {
        fundAddress = _fundAddress;
        _updateTotalLp();
        return true;
    }

    function setdefaultPair(address _defaultPair)
        public
        onlyOwner
        returns (bool)
    {
        defaultPair = _defaultPair;
        _updatePairStatus(defaultPair, true);
        return true;
    }

    function setTotalLp(address _pair) public returns (bool) {
        _totalLp[_pair] = _getTotalLp(_pair);
        return true;
    }

    function setPairStatus(address _pair, bool _isPair) public onlyOwner {
        _updatePairStatus(_pair, _isPair);
    }

    function setRouterStatus(address _router, bool _isRouter)
        public
        onlyOwner
        returns (bool)
    {
        isRouter[_router] = _isRouter;
        _updateTotalLp();
        return true;
    }

    function setIsSellFee(bool _isSellFee) public onlyOwner returns (bool) {
        isSellFee = _isSellFee;
        _updateTotalLp();
        return true;
    }

    function setIsBuyFee(bool _isBuyFee) public onlyOwner returns (bool) {
        isBuyFee = _isBuyFee;
        _updateTotalLp();
        return true;
    }

    function setCanRemoveLiquidity(bool _canRemoveLiquidity)
        public
        onlyOwner
        returns (bool)
    {
        canRemoveLiquidity = _canRemoveLiquidity;
        _updateTotalLp();
        return true;
    }

    function setDefaultRouter(IUniswapV2Router02 _router)
        public
        onlyOwner
        returns (bool)
    {
        defaultRouter = _router;
        _updateTotalLp();
        return true;
    }

    function setTokenAmountsAutoSellToAddLpPerTime(uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        tokenAmountsAutoSellToAddLpPerTime = _amount;
        return true;
    }

    function setEnableLottery(bool _enable) public onlyOwner returns (bool) {
        enableLottery = _enable;
        return true;
    }

    function setEnableUsdtLpHolderRewards(bool _enable)
        public
        onlyOwner
        returns (bool)
    {
        enableUsdtLpHolderRewards = _enable;
        return true;
    }

    function updateAllTotalLp() public returns (bool) {
        _updateTotalLp();
        return true;
    }

    function withdrawRewardsRepository(IERC20 _token)
        public
        onlyOwner
        returns (bool)
    {
        require(
            _token.balanceOf(address(rewardsRepository)) > 0,
            "Amount out of balance!"
        );
        rewardsRepository.withdraw(_token, address(this));
        return true;
    }

    function retreatURewards() public {
        swapUsdt();
        _distributeUsdtLpRewards(address(msg.sender));
    }

    function updateUrewards() public {
        swapUsdt();
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount,
        TradeType tradetype,
        TransferType transfertype
    ) internal checkIsRouter(_msgSender()) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount <= _balances[sender],
            "ERC20: transfer amount must be less than account balance！"
        );
        if (tradetype == TradeType.Remove && !updateCanRemoveLiquidity()) {
            require(canRemoveLiquidity, "Option not permitted now!");
        }
        if (
            isRouter[sender] &&
            transfertype == TransferType.Transfer &&
            !isPair[recipient]
        ) {
            tradetype = TradeType.Remove;
        }

        bool canSwap = isPair[sender] ||
            isRouter[sender] ||
            isPair[recipient] ||
            isRouter[recipient];

        bool overMinTokenBalance = _balances[address(this)] >=
            tokenAmountsAutoSellToAddLpPerTime;
        if (
            _totalLp[defaultPair] > 0 &&
            canSwap &&
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            !isPair[sender] &&
            !isRouter[sender] &&
            !inSwapU
        ) {
            TradeType temptype = tradetype;
            swapAndLiquify(tokenAmountsAutoSellToAddLpPerTime);
            tradetype = temptype;
        }

        if (
            swapUEnabled &&
            !address(msg.sender).isContract() &&
            !inSwapU &&
            !inSwapAndLiquify
        ) {
            swapUsdt();
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        if (!canSwap) {
            takeFee = false;
        }

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (
            inSwapAndLiquify ||
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient] ||
            isRouter[recipient] ||
            inSwapU
        ) {
            takeFee = false;
        }

        if (takeFee && tradetype == TradeType.Buy && isBuyFee) {
            _transferWithBuyFee(sender, recipient, amount);
            if (enableLottery) {
                _checkLottery(
                    recipient,
                    totalLotteryRewards,
                    lottery.rewardNum
                );
            }

            if (enableUsdtLpHolderRewards && USDT_ADDR.isContract()) {
                _distributeUsdtLpRewards(recipient);
            }
        } else if (
            takeFee && tradetype == TradeType.Remove && canRemoveLiquidity
        ) {
            _transferWithRemoveFee(sender, recipient, amount);
            if (enableLottery) {
                _checkLottery(
                    recipient,
                    totalLotteryRewards,
                    lottery.rewardNum
                );
            }

            if (enableUsdtLpHolderRewards && USDT_ADDR.isContract()) {
                _distributeUsdtLpRewards(recipient);
            }
        } else if (
            takeFee &&
            tradetype == TradeType.Sell &&
            isSellFee &&
            totalBurn < MAX_BURN_FEE
        ) {
            uint256 bAmount = amount.mul(bBurnFee).div(totalRate);
            uint256 rLp = amount.mul(sLpFee).div(totalRate);
            uint256 rLottery;
            if (enableLottery) {
                rLottery = amount.mul(lotteryFee).div(totalRate);
            }

            uint256 rUsdtLp;
            if (enableUsdtLpHolderRewards) {
                rUsdtLp = amount.mul(usdtLpHolderFee).div(totalRate);
            }

            bAmount = bAmount <= MAX_BURN_FEE.sub(totalBurn)
                ? bAmount
                : MAX_BURN_FEE.sub(totalBurn);
            require(
                amount.add(bAmount.add(rLp.add(rLottery.add(rUsdtLp)))) <=
                    _balances[sender],
                "ERC20: total amount include fees transfering exceeding account balance！"
            );
            _customTransfer(sender, recipient, amount);
            _customTransfer(sender, address(this), rLp);
            if (enableLottery) {
                _customTransfer(sender, address(this), rLottery);
                totalLotteryRewards = totalLotteryRewards.add(rLottery);
                _checkLottery(sender, totalLotteryRewards, lottery.rewardNum);
            }

            if (enableUsdtLpHolderRewards && USDT_ADDR.isContract()) {
                _customTransfer(sender, address(this), rUsdtLp);
                totalUsdtLpHolderRewards = totalUsdtLpHolderRewards.add(
                    rUsdtLp
                );
                _distributeUsdtLpRewards(sender);
            }

            _burn(sender, bAmount);
        } else {
            _customTransfer(sender, recipient, amount);
        }

        _updateTotalLp();
        IsExcludeEvent(takeFee, tradetype);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapUsdt() private lockTheSwapU {
        if (
            totalUsdtLpHolderRewards > 0 &&
            _balances[address(this)] >= totalUsdtLpHolderRewards &&
            IUniswapV2Pair(usdt_token_pair).totalSupply() > 0
        ) {
            uint256 tempUsdt = IERC20(USDT_ADDR).balanceOf(address(this));
            swapTokenForUsdt(totalUsdtLpHolderRewards);
            uint256 tempUsdt2 = IERC20(USDT_ADDR).balanceOf(address(this));
            if (tempUsdt2 > tempUsdt) {
                totalUsdtLpHolderRewardsConvertToUsdt = totalUsdtLpHolderRewardsConvertToUsdt
                    .add(tempUsdt2.sub(tempUsdt));
            }
        }
    }

    function swapTokensForBnb(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = defaultRouter.WETH();

        _approve(address(this), address(defaultRouter), tokenAmount);

        // make the swap
        defaultRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokenForUsdt(uint256 _tokenAmount) private {
        address to = address(rewardsRepository);
        uint256 amountOutMin = 0;

        _approve(address(this), address(defaultRouter), ~uint256(0));
        _customTransfer(address(this), usdt_token_pair, _tokenAmount);

        uint256 balanceBefore = IERC20(USDT_ADDR).balanceOf(to);

        address input = address(this);

        IUniswapV2Pair pair = IUniswapV2Pair(usdt_token_pair);
        address token0 = pair.token0();
        uint256 amountInput;
        uint256 amountOutput;
        {
            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
            (uint256 reserveInput, ) = input == token0
                ? (reserve0, reserve1)
                : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(
                reserveInput
            );
            amountOutput = amountInput;
        }
        (uint256 amount0Out, uint256 amount1Out) = input == token0
            ? (uint256(0), amountOutput)
            : (amountOutput, uint256(0));

        pair.swap(amount0Out, amount1Out, to, new bytes(0));
        rewardsRepository.withdraw(IERC20(USDT_ADDR), address(this));

        require(
            IERC20(USDT_ADDR).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(defaultRouter), tokenAmount);

        // add the liquidity
        defaultRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _transferWithBuyFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        uint256 inviteRewards = amount.mul(inviteFee).div(totalRate);
        uint256 remain = _distributeInviteRewards(recipient, inviteRewards);

        uint256 rFund = amount.mul(sFundFee).div(totalRate);
        rFund = rFund.add(remain);
        _balances[fundAddress] = _balances[fundAddress].add(rFund);
        _balances[recipient].sub(rFund);
        totalBuyFee = totalBuyFee.add(rFund);
    }

    function _transferWithRemoveFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(amount);
        uint256 rLp = amount.mul(sLpFee).div(totalRate);
        _balances[recipient] = _balances[recipient].add(amount.sub(rLp));
        emit Transfer(sender, recipient, amount.sub(rLp));
        _balances[address(this)] = _balances[address(this)].add(rLp);
        emit Transfer(sender, address(this), rLp);
    }

    function _customTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _getTotalLp(address _pair) internal view returns (uint256) {
        return IERC20(_pair).totalSupply();
    }

    function _updateTotalLp() internal {
        if (pairKey.length > 0) {
            for (uint256 i = 0; i < pairKey.length; i++) {
                _totalLp[pairKey[i]] = _getTotalLp(pairKey[i]);
            }
        }
    }

    function _updatePairStatus(address _pair, bool _isPair) internal {
        isPair[_pair] = _isPair;

        bool isInPairKey;
        uint256 _pairIndex;
        if (pairKey.length > 0) {
            for (uint256 i = 0; i < pairKey.length; i++) {
                if (pairKey[i] == _pair) {
                    isInPairKey = true;
                    _pairIndex = i;
                }
            }
        }

        if (_isPair) {
            setTotalLp(_pair);
            if (!isInPairKey) {
                pairKey.push(_pair);
            }
        } else {
            _totalLp[_pair] = 0;
            if (isInPairKey) {
                for (uint256 i = _pairIndex; i < pairKey.length; i++) {
                    pairKey[i] = pairKey[i + 1];
                }

                pairKey.pop();
            }
        }
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        if (size > 0) {
            return true;
        } else {
            return false;
        }
    }

    function _setUpline(address _addr, address _up) internal {
        if (
            _addr != address(0) &&
            !_isContract(_addr) &&
            _up != address(0) &&
            !_isContract(_up) &&
            _balances[_addr] == 0
        ) {
            upline[_addr] = _up;
        }
    }

    function _distributeInviteRewards(address _sender, uint256 _rewards)
        internal
        returns (uint256)
    {
        address _upline = upline[_sender];
        for (uint256 i = 0; i < uplevel; i++) {
            if (_upline != address(0)) {
                _rewards = _rewards.div(2);
                _customTransfer(_sender, _upline, _rewards);
                _upline = upline[_upline];
            } else {
                break;
            }
        }

        return _rewards;
    }

    function _checkLottery(
        address _user,
        uint256 _rewards,
        uint256 _rewardNum
    ) internal {
        uint256 currentTime = block.timestamp;
        if (
            currentTime >= lottery.currentEpoch &&
            currentTime < lottery.nextEpoch &&
            lottery.epoch[lottery.currentEpoch].length < lottery.epochLength
        ) {
            _addEpochMember(lottery.currentEpoch, _user, currentTime);
            if (
                totalLotteryRewards >= _rewards &&
                lottery.epoch[lottery.currentEpoch].length ==
                lottery.epochLength &&
                _balances[address(this)] >= _rewards &&
                _rewardNum > 0
            ) {
                uint256 reward = _rewards.div(_rewardNum);
                for (uint256 i = 0; i < _rewardNum; i++) {
                    _customTransfer(
                        address(this),
                        lottery.epoch[lottery.currentEpoch].members[
                            lottery.epochLength.sub(i).sub(1)
                        ],
                        reward
                    );
                }
                totalLotteryRewards = totalLotteryRewards.sub(_rewards);
                _updateLottery(lottery.nextEpoch);
            }
        } else if (currentTime >= lottery.nextEpoch && lottery.interval > 0) {
            uint256 iBase = currentTime.sub(lottery.nextEpoch).div(
                lottery.interval
            );
            for (uint256 i = 0; i < iBase; i++) {
                _updateLottery(lottery.nextEpoch);
            }
        }
    }

    function _addEpochMember(
        uint256 _epoch,
        address _user,
        uint256 _timestamp
    ) internal {
        lottery.epoch[_epoch].members.push(_user);
        lottery.epoch[_epoch].timestamps.push(_timestamp);
        lottery.epoch[_epoch].idMembers[_timestamp] = _user;
        lottery.epoch[_epoch].membersId[_user] = _timestamp;
        lottery.epoch[_epoch].length += 1;
    }

    function _updateLottery(uint256 _epoch) internal {
        uint256 currentTime = _epoch;

        if (lottery.startEpoch == 0) {
            lottery.startEpoch = currentTime;
        }
        lottery.currentEpoch = currentTime;
        lottery.nextEpoch = lottery.currentEpoch.add(lottery.interval);
        lottery.length += 1;
        lottery.epochTimestamps.push(currentTime);
    }

    function _distributeUsdtLpRewards(address _user) internal {
        if (
            uRewardsLockTime[_user] <= block.timestamp &&
            totalUsdtLpHolderRewardsConvertToUsdt > 0 &&
            IERC20(USDT_ADDR).balanceOf(address(this)) >=
            totalUsdtLpHolderRewardsConvertToUsdt &&
            IERC20(usdt_token_pair).totalSupply() > 0
        ) {
            uint256 temp = totalUsdtLpHolderRewardsConvertToUsdt
                .mul(IERC20(usdt_token_pair).balanceOf(_user))
                .div(IERC20(usdt_token_pair).totalSupply());
            IERC20(USDT_ADDR).transfer(_user, temp);
            totalUsdtLpHolderRewardsConvertToUsdt.sub(temp);
            uRewardsLockTime[_user].add(uRewardsInterval);
        }
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        _balances[burnAddress] = _balances[burnAddress].add(value);
        totalBurn = totalBurn.add(value);

        emit Transfer(account, burnAddress, value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _updateTotalLp();
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}

pragma solidity ^0.6.12;

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is ERC20, ERC20Detailed {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _fundAddress, // 基金地址
        uint256 _bBurnFee, // 销毁比例, 卖扣销毁， 例如每卖出一笔销毁卖出量的45%
        uint256 _sFundFee, // 基金费率 10 为千分之一的十份 , 例如每买入一笔扣除0.5% 加入资金池
        uint256 _sLpFee, // 代币合约自动添加流动性费率 , 例如每买入一笔操作4.5% 用于添加流动性到Lp，回流到lp池子
        uint256 _inviteFee, // 介绍人提成，
        uint256 _uplevel, // 可以拿多少代提成
        uint256 _MAX_BURN_FEE, // 最大销毁数，例如达到总发行量的80%即8000万时停止销毁
        uint256 _canRemoveLiquidityFee, // 开放移除流动性所需的销毁的数量，销毁达到总发行量的50%即5000万时开放移除流动性
        uint256 _amuntToAdd, // 初始化每次自动回流Lp的代币数量
        address _router, // 测试网 :0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 主网 :0x10ED43C718714eb63d5aA57B78B54704E256024E
        address _usdt // 测试网：0x75B65EbFab1Bb77A78C4151ecaC504fa5850Aa65 主网 USDT： 0x55d398326f99059fF775485246999027B3197955
    ) public ERC20Detailed(_name, _symbol, _decimals) {
        uint256 initialSupply = uint256(10**6); // 初始化代币数量 不含小数点 10 后面8个0， 即1亿
        _mint(msg.sender, initialSupply * (10**uint256(_decimals)));

        fundAddress = _fundAddress;
        burnAddress = address(0x000000000000000000000000000000000000dEaD); // 销毁地址

        isSellFee = true; // 1 为true 0 为false   开放买扣
        isBuyFee = true; // 1 为true 0 为false   开放卖扣
        enableLottery = true; // 1 为true 0 为false  开放抽奖
        enableUsdtLpHolderRewards = true; // 1 为true 0 为false   开放持币

        totalRate = 1000; // 总比例， 1000为把代币分为一千份
        bBurnFee = _bBurnFee;
        sFundFee = _sFundFee;
        sLpFee = _sLpFee;
        inviteFee = _inviteFee;
        lotteryFee = 100; // 用于抽奖的费用扣费费率， 在用户操作卖出或者添加Lp时扣取，限定时间内买卖添加移除交易哈希达到指定数量时分配。
        usdtLpHolderFee = 100; //在用户操作卖出或者添加LP时扣费， 用于持有USDT 交易对奖励，每次买卖添加移除交易根据当前操作用户持有LP份额分配。
        uplevel = _uplevel;
        MAX_BURN_FEE = totalSupply().mul(_MAX_BURN_FEE).div(totalRate);
        canRemoveLiquidityFee = totalSupply().mul(_canRemoveLiquidityFee).div(
            totalRate
        );

        lottery.interval = 3600; // 每次计算抽奖的时间间隔 一小时 3600毫秒
        lottery.epochLength = 5; // 每次抽奖需要达到的交易数
        lottery.rewardNum = 5; // 每次抽奖分配的哈希交易数
        _updateLottery(block.timestamp);

        defaultRouter = IUniswapV2Router02(_router);
        isRouter[address(defaultRouter)] = true;
        defaultPair = IUniswapV2Factory(defaultRouter.factory()).createPair(
            address(this),
            defaultRouter.WETH()
        );

        USDT_ADDR = _usdt;
        usdt_token_pair = IUniswapV2Factory(defaultRouter.factory()).createPair(
                address(this),
                USDT_ADDR
            );

        uRewardsInterval = 3600 * 1 * 1; // 每隔一个月才可以领取一次UsdtLP 分U奖励。

        tokenAmountsAutoSellToAddLpPerTime =
            _amuntToAdd *
            (10**uint256(_decimals));

        setPairStatus(defaultPair, true);
        setPairStatus(usdt_token_pair, true);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        checkedIsNotRouter[address(this)] = true;
        checkedIsNotRouter[defaultPair] = true;
        checkedIsNotRouter[usdt_token_pair] = true;
        checkedIsNotRouter[_msgSender()] = true;
        checkedIsNotPair[_msgSender()] = true;
        checkedIsNotPair[address(this)] = true;
        checkedIsNotPair[address(defaultRouter)] = true;

        rewardsRepository = IRewardsRepository(
            address(new RewardsRepository(address(this)))
        );
    }
}