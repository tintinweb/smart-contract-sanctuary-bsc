/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;


abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

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

contract PowerPool is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 power;
        uint256 rewardDebt;
        uint256 rewardAmount;
        uint256 inviteePower;
        uint256 dynRewardAmount;
        uint256 lastdynRewardAmount;
    }

    uint256 public lastRewardBlock = 0;
    uint256 public accCafePerShare = 0;
    uint256 public totalPower = 0;


    IUniswapV2Router02 public immutable uniswapV2Router;
    IBEP20 public immutable rewardToken;
    IBEP20 public immutable stakeToken;

    uint256 public rewardPerBlock;
    uint256 public startBlock;
    uint256 public bonusEndBlock;

    
    uint256 public dynBlockLength;
    uint256 public dynRewardBlock;

    uint256 public fixedPrice = 1*10**18;
    bool public priceSwitch = false;
    bool public dynHandSwitch = false;

    mapping(address => UserInfo) public userInfo;
    mapping(address => address) public inviter;
    mapping(address => address[]) public invitee;
    mapping(address => bool) private _updated;
    address[] staker;

    uint256 stakerate = 7000;

    uint256 v1rate = 1200;
    uint256 v2rate = 800;
    uint256 v3rate = 600;
    uint256 v4rate = 400;


    event Stake(address indexed user,uint256 amount);
    event Withdraw(address indexed user,uint256 amount);
    event AddInviter(address indexed invitee,address indexed inviter);


    constructor(
        address _stakeToken,
        address _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _dynBlockLength
        ) {
        //0x10ED43C718714eb63d5aA57B78B54704E256024E
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        uniswapV2Router = _uniswapV2Router;
        stakeToken=IBEP20(_stakeToken);
        rewardToken=IBEP20(_rewardToken);

        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        dynBlockLength = _dynBlockLength;
        dynRewardBlock = _startBlock;

    }
    function getPriceByUSDT(IBEP20 token) public view returns(uint256) {
        if(priceSwitch) {
            return fixedPrice;
        }
        address[] memory path;
        path = new address[](2);
        path[0] = address(token);
        path[1] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);
        uint256[] memory amounts=uniswapV2Router.getAmountsOut(1*10**token.decimals(),path);
        return amounts[1];
    }

    function getPriceByBNB(IBEP20 token) public view returns(uint256) {
        if(priceSwitch) {
            return 5*10**17;
        }
        address[] memory path1;
        address[] memory path2;
        path1 = new address[](2);
        path1[0] = address(token);                      
        path1[1] = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);         //bnb
        uint256[] memory amounts1=uniswapV2Router.getAmountsOut(1*10**token.decimals(),path1);

        path2 = new address[](2);
        path2[0] = address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);         //bnb
        path2[1] = address(0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684);         //usdt
        uint256[] memory amounts2=uniswapV2Router.getAmountsOut(amounts1[1],path2);
        return amounts2[1];
    }
    function stake(uint256 _amount) public {
            uint256 price=getPriceByUSDT(stakeToken);
            uint256 power = _amount.mul(price).mul(3).div(10**stakeToken.decimals());
            updateUserInfo(msg.sender, power , false);

            address cur = msg.sender;
            //inviter fee
            for (int256 i = 0; i < 3; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 100;
            } else if(i == 1){
                rate = 50;
            } else {
                rate = 30;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            uint256 curTPower = power.div(1000).mul(rate);
            updateUserInfo(cur, curTPower , true);
        }
        if(!dynHandSwitch)
        {
            processDynReward();
        }
        stakeToken.safeTransferFrom(address(msg.sender), address(0) , _amount);
        emit Stake(msg.sender, _amount);
    }

    function withdrawStatReward() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint256 pending = user.power.mul(accCafePerShare).div(1e12).sub(user.rewardDebt);
        uint256 totalRewardToken = pending + user.rewardAmount;
        uint256 rewardTokenPrice = getPriceByUSDT(rewardToken);
        uint256 canExtractTokens = user.power.div(rewardTokenPrice).mul(10**rewardToken.decimals());
        uint256 amount=0;
        if(totalRewardToken>=canExtractTokens){
            totalPower=totalPower.sub(user.power);
            user.power=0;
            user.rewardAmount = 0;
            user.dynRewardAmount=0;
            amount=canExtractTokens;
        }else{
            uint256 extractPower = totalRewardToken.mul(rewardTokenPrice).div(10**rewardToken.decimals());
            user.power=user.power.sub(extractPower);
            user.rewardAmount=0;
            totalPower=totalPower.sub(extractPower);
            amount=totalRewardToken;
        }
        user.rewardDebt = user.power.mul(accCafePerShare).div(1e12);
        rewardToken.safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender,amount);
        
    }

    function withdrawDynReward() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();
        uint256 pending = user.power.mul(accCafePerShare).div(1e12).sub(user.rewardDebt);
        user.rewardAmount=user.rewardAmount.add(pending);
        uint256 totalRewardToken = user.dynRewardAmount;
        uint256 rewardTokenPrice = getPriceByUSDT(rewardToken);
        uint256 canExtractTokens = user.power.div(rewardTokenPrice).mul(10**rewardToken.decimals());
        uint256 amount=0;
        if(totalRewardToken>=canExtractTokens){
            totalPower=totalPower.sub(user.power);
            user.power=0;
            user.rewardAmount = 0;
            user.dynRewardAmount=0;
            amount=canExtractTokens;
        }else{
            uint256 extractPower = totalRewardToken.mul(rewardTokenPrice).div(10**rewardToken.decimals());
            user.power=user.power.sub(extractPower);
            user.dynRewardAmount=0;
            totalPower=totalPower.sub(extractPower);
            amount=totalRewardToken;
        }
        user.rewardDebt = user.power.mul(accCafePerShare).div(1e12);
        rewardToken.safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender,amount);
    }

    function pendingReward(address _user) external view returns(uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _accCafePerShare = accCafePerShare;
        if(block.number>lastRewardBlock && totalPower != 0) {
            uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
            uint256 cafeReward = multiplier.mul(rewardPerBlock.mul(stakerate).div(10000));
            _accCafePerShare = _accCafePerShare.add(cafeReward.mul(1e12).div(totalPower));
        }
        return user.power.mul(_accCafePerShare).div(1e12).sub(user.rewardDebt).add(user.rewardAmount);
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }
    function updatePool() public {
        if(block.number <= lastRewardBlock) {
            return;
        }
        if(totalPower == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 cafeReward = multiplier.mul(rewardPerBlock.mul(stakerate).div(10000));
        accCafePerShare = accCafePerShare.add(cafeReward.mul(1e12).div(totalPower));
        lastRewardBlock = block.number;
    }

    function updateUserInfo(address _user,uint256 _power,bool flag) private {
        UserInfo storage user = userInfo[_user];
        updatePool();
        if(user.power>0) {
            uint256 pending = user.power.mul(accCafePerShare).div(1e12).sub(user.rewardDebt);
            if(pending>0) {
                user.rewardAmount=user.rewardAmount.add(pending);
            }
        }
        if(flag) {
            user.inviteePower=user.inviteePower.add(_power);
        }
        user.power=user.power.add(_power);
        totalPower=totalPower.add(_power);
        user.rewardDebt = user.power.mul(accCafePerShare).div(1e12);
        if(!_updated[_user]) {
            _updated[_user]=true;
            staker.push(_user);
        }
    }

    function switchPrice(bool _priceSwitch) external onlyOwner {
        priceSwitch = _priceSwitch;
    }

    function setfixPrice(uint256 _fixPrice) external onlyOwner {
        fixedPrice = _fixPrice;
    }

    function setDynHandSwitch() external onlyOwner {
        dynHandSwitch = !dynHandSwitch;
    }

    function addInviter(address _inviter) external {
        require(inviter[msg.sender] == address(0),"existed inviter");
        inviter[msg.sender]=_inviter;
        invitee[_inviter].push(msg.sender);
    }


    function getUserPower(address _user) external view returns(uint256) {
        return userInfo[_user].power;
    }

    function getUserDynReward(address _user) external view returns(uint256) {
        return userInfo[_user].dynRewardAmount;
    }

    function getUserLastDynReward(address _user) external view returns(uint256) {
        return userInfo[_user].lastdynRewardAmount;
    }

    function processDynReward() public {
        uint256 blockNumber = dynRewardBlock.add(dynBlockLength);
        //Execute once within dynBlockLength
        if(blockNumber <= block.number) {
        dynRewardBlock=blockNumber;
        uint n=staker.length;
        address[] memory v1;
        address[] memory v2;
        address[] memory v3;
        address[] memory v4;
        (v1,v2,v3,v4)=getRankAddress();



        for(uint s=0;s<n;s++) {
            if(v4[s]!=address(0x0)) 
            {
                v1[s]=address(0x0);
                v2[s]=address(0x0);
                v3[s]=address(0x0);
            }else if(v3[s]!=address(0x0)){
                v1[s]=address(0x0);
                v2[s]=address(0x0);
            }else if(v2[s]!=address(0x0)){
                v1[s]=address(0x0);
            }
        }
        uint256 v1TotalPower;
        uint256 v2TotalPower;
        uint256 v3TotalPower;
        uint256 v4TotalPower;
        for(uint s=0;s<n;s++){
            if(v1[s]!=address(0x0)){
                v1TotalPower=v1TotalPower.add(userInfo[v1[s]].power);
            }else if(v2[s]!=address(0x0)){
                v2TotalPower=v2TotalPower.add(userInfo[v2[s]].power);
            }else if(v3[s]!=address(0x0)){
                v3TotalPower=v3TotalPower.add(userInfo[v3[s]].power);
            }else if(v4[s]!=address(0x0)){
                v4TotalPower=v4TotalPower.add(userInfo[v4[s]].power);
            }
        }
        uint256 v1cafeReward = dynBlockLength.mul(rewardPerBlock.mul(v1rate).div(10000));
        if(v1TotalPower==0){
                    v1cafeReward=0;
        }else{
                    v1cafeReward=v1cafeReward.mul(1e12).div(v1TotalPower);
        }
        uint256 v2cafeReward = dynBlockLength.mul(rewardPerBlock.mul(v2rate).div(10000));
        if(v2TotalPower==0){
            v2cafeReward=0;
        }else{
                    v2cafeReward=v2cafeReward.mul(1e12).div(v2TotalPower);    
        }    
        uint256 v4cafeReward = dynBlockLength.mul(rewardPerBlock.mul(v4rate).div(10000));
        if(v4TotalPower==0){
            v4cafeReward=0;
        }else{
                    v4cafeReward=v4cafeReward.mul(1e12).div(v4TotalPower);
        }
        uint256 v3cafeReward = dynBlockLength.mul(rewardPerBlock.mul(v3rate).div(10000));
        if(v3TotalPower==0){
            v3cafeReward=0;
        }else{
        v3cafeReward=v3cafeReward.mul(1e12).div(v3TotalPower);
        }

        //分配动态奖金给每一个用户
        for(uint s=0;s<n;s++)
        {
            if(v1[s]!=address(0x0))
            {
            address user=v1[s];
            uint256 rewards=userInfo[user].power.mul(v1cafeReward).div(1e12);
            userInfo[user].dynRewardAmount=userInfo[user].dynRewardAmount.add(rewards);
            userInfo[user].lastdynRewardAmount=rewards;
            }else if(v2[s]!=address(0x0))
            {
                address user=v2[s];
            uint256 rewards=userInfo[user].power.mul(v2cafeReward).div(1e12);
            userInfo[user].dynRewardAmount=userInfo[user].dynRewardAmount.add(rewards);
            userInfo[user].lastdynRewardAmount=rewards;
            }else if(v3[s]!=address(0x0))
            {
            address user = v3[s];
            uint256 rewards=userInfo[user].power.mul(v3cafeReward).div(1e12);
            userInfo[user].dynRewardAmount=userInfo[user].dynRewardAmount.add(rewards);
            userInfo[user].lastdynRewardAmount=rewards;
            }else if(v4[s]!=address(0x0))
            {
                address user=v4[s];
            uint256 rewards=userInfo[user].power.mul(v4cafeReward).div(1e12);
            userInfo[user].dynRewardAmount=userInfo[user].dynRewardAmount.add(rewards);
            userInfo[user].lastdynRewardAmount=rewards;
            }
        }        

    }
    }


    function getUserRank(address user) view public returns(uint) {
        uint rank = 0;
        uint n=staker.length;
        address[] memory v1;
        address[] memory v2;
        address[] memory v3;
        address[] memory v4;
        (v1,v2,v3,v4)=getRankAddress();
        for(uint s=0;s<n;s++){
            if(staker[s]==user) {
                if(v4[s]!=address(0x0)) {
                    rank=4;
                }else if(v3[s]!=address(0x0)){
                    rank=3;
                }else if(v2[s]!=address(0x0)){
                    rank=2;
                }else if(v1[s]!=address(0x0)){
                    rank=1;
                }
                break;
            }
        }
        return rank;
    }


    function countRankAmount() view public returns(uint,uint,uint,uint) {
        uint v1Num=0;
        uint v2Num=0;
        uint v3Num=0;
        uint v4Num=0;
        uint n=staker.length;
        address[] memory v1;
        address[] memory v2;
        address[] memory v3;
        address[] memory v4;
        (v1,v2,v3,v4)=getRankAddress();

        for(uint s=0;s<n;s++){
            if(v4[s]!=address(0x0)){
                v4Num++;
            }else if(v3[s]!=address(0x0)){
                v3Num++;
            }else if(v2[s]!=address(0x0)){
                v2Num++;
            }else if(v1[s]!=address(0x0)){
                v1Num++;
            }
        }
        return (v1Num,v2Num,v3Num,v4Num);
    }
    
    function checkIsExist(address[] memory stakers,address user) pure public returns(bool) 
    {
        for(uint i=0;i<stakers.length;i++)
        {
            if(stakers[i]==user)
            {
                return true;
            }
        }
        return false;
    }

    function getRankAddress() private view returns(address[] memory,address[] memory,address[] memory,address[] memory) {
       uint n=staker.length;
        address[] memory v1=new address[](n); 
        for(uint i=0;i<n;i++)
        {
            if(userInfo[staker[i]].power>1 * 10**4 * 10 **18)
            {
                v1[i]=staker[i];
            }
        }

        bool flag = true;

        address[] memory v2=new address[](n); 
        for(uint256 i=0;i<staker.length;i++)
        {
            flag=true;
            uint256 k=0;
            for(uint256 j=0;j<invitee[staker[i]].length && flag;j++)
            {
                if(checkIsExist(v1,invitee[staker[i]][j]))
                {
                    k++;
                }
                if(k>=2)
                {
                    v2[i]=staker[i];
                    flag=false;
                    break;
                }
            }
        }

        address[] memory v3=new address[](n);
        for(uint256 i=0;i<staker.length;i++)
        {
            flag=true;
            uint256 k=0;
            for(uint256 j=0;j<invitee[staker[i]].length && flag;j++)
            {
                if(checkIsExist(v2,invitee[staker[i]][j]))
                {
                    k++;
                }
                if(k>=2)
                {
                    v3[i]=staker[i];
                    flag=false;
                    break;
                }
            }
        }

        address[] memory v4=new address[](n);
        for(uint256 i=0;i<staker.length;i++)
        {
            flag=true;
            uint256 k=0;
            for(uint256 j=0;j<invitee[staker[i]].length && flag;j++)
            {
                if(checkIsExist(v3,invitee[staker[i]][j]))
                {
                    k++;
                }
                if(k>=2)
                {
                    v4[i]=staker[i];
                    flag=false;
                    break;
                }
            }
        }
        return (v1,v2,v3,v4);
    }
}