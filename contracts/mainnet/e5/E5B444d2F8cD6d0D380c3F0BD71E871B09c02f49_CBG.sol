/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
      */
    constructor() {
        owner = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20Ext is IERC20 {
    function isBlackListed(address owner) external view returns (bool);
    function inviter(address owner) external view returns (address);
}

interface IPancakeRouter01 {
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
}

interface IPancakeRouter02 is IPancakeRouter01 {
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

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface IPancakePair {
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

interface ILPTool  {
    function addLP(address lpAddr) external;
    function removeLP(address lpAddr) external;
    function getLpTotalValue(address lpAddress) external view returns(uint256);
    function getLpPrice(address lpAddress) external view returns(uint256);
    function getTokenPrice(address tokenAddress) external view returns(uint256);
}

contract Recv {
    IERC20 public tokenCBG;
    IERC20 public tokenPCE;

    constructor (IERC20 _tokenCBG) {
        tokenCBG = _tokenCBG;
        tokenPCE = IERC20(0x85973C97919c999E5D3d8832290152a3ACdf8a6E); //NOTICE Peace
    }

    function withdraw() public {
        uint256 tokenPCEBalance = tokenPCE.balanceOf(address(this));
        if (tokenPCEBalance > 0) {
            tokenPCE.transfer(address(tokenCBG), tokenPCEBalance);
        }
        uint256 tokenCBGBalance = tokenCBG.balanceOf(address(this));
        if (tokenCBGBalance > 0) {
            tokenCBG.transfer(address(tokenCBG), tokenCBGBalance);
        }
    }
}


contract CBGPool is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public cbgUsdPair;



    uint[] public _layerHashRate = [56,29,23,17,11,6,29,23,17,11,6,29,23,17,11,6,29,23,17,11,6];
    uint public _layerHashMax = 21;

    uint256 public userPercent = 600;

    address public pancakeswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public peaceToken = address(0x85973C97919c999E5D3d8832290152a3ACdf8a6E); //NOTICE Peace
    address public peaceUsdPair = address(0x4b3b5b1335D33E0a9eBD583dB9845ad17094eCa7); //Peace-usd
    address public usdToken = address(0x55d398326f99059fF775485246999027B3197955); //usd
    IERC20Ext internal CPTToken = IERC20Ext(0xD66734e3663D3Eb36F1e7819bc20bfb9c5B5ba62); //CPT

    address public destoryTriggerAddress =0x307F0D071F8cbD1E9ecC43017059438e69EFa23d;
    address public treasuryAddress = 0x1033478255AC6805242cD770A9a689Bb2a033565;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    ILPTool public lpTool;
    uint256 public destoryPercent = 1000;



    event StartPool(address indexed user, uint256 amount);
    event StopPool(address indexed user, uint256 amount);
    event InviteAmount(address indexed user, uint256 addAmount, uint256 subAmount);


    struct UserInfo {
        // uint256 inviteReward; //待领取的邀请获取的奖励
        uint256 amount;     // How many LP tokens the user has.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 amount;            //参与挖矿的lp数量
        uint256 allocPoint;       // How many allocation points assigned to this pool. CHERRYs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CHERRYs distribution occurs.
        uint256 accPerShare; // Accumulated CACHERRYper share, times 1e12. See below.
        bool isStart;
    }



    uint256 public perBlock;

    // Info of each user that stakes LP tokens.
    mapping (address => mapping (address => UserInfo)) public userInfoMap;

    mapping(address => uint256) public userInviteRewardMap;

    mapping(address => PoolInfo) public poolInfoMap;
    address[] public lpAddressList;
    mapping(address => bool) public isDestoryNullLp;

    uint256 public totalAllocPoint = 0;

    uint256 public startBlock;
    bool public autoAdjustAlloc = false;
    bool islocked;
    uint256 public inviteRewardLpValue = 400 * 1e18;

    // uint private checkPoolUserMax = 30;

    modifier lock() {
        islocked = true;
        _;
        islocked = false;
    }

    constructor(uint256 _startBlock,uint256 _perBlock,ILPTool _tool)  {
        cbgUsdPair = IPancakeFactory(IPancakeRouter02(pancakeswapV2Router).factory())
        .createPair(address(this), peaceToken);

        startBlock = _startBlock;
        perBlock = _perBlock;
        lpTool = _tool;

        initPool();
    }


    function initPool() private {
        poolInfoMap[cbgUsdPair] = PoolInfo({
        amount: 0,
        allocPoint: 0,
        lastRewardBlock: startBlock,
        accPerShare: 0,
        isStart:true
        });
        lpAddressList.push(cbgUsdPair);
        lpTool.addLP(cbgUsdPair);
    }


    function add(uint256 _allocPoint, address _lpToken) public onlyOwner {

        massUpdatePools();

        lpTool.addLP(_lpToken);
        if(autoAdjustAlloc){
            _allocPoint = getLpAllocPoint(_lpToken);
        }

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfoMap[_lpToken] = PoolInfo({
        amount: 0,
        allocPoint: _allocPoint,
        lastRewardBlock: lastRewardBlock,
        accPerShare: 0,
        isStart:true
        });
        lpAddressList.push(_lpToken);

    }



    // 修改权重,只有非自动调节是才可用
    function set(address _lpToken, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if(_allocPoint == 0){
            stopLp(_lpToken);
            return;
        }
        require(!autoAdjustAlloc,"AutoAdjust");

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfoMap[_lpToken].allocPoint;
        poolInfoMap[_lpToken].allocPoint = _allocPoint;
        poolInfoMap[_lpToken].isStart = true;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
        }
    }

    function stopLp(address _lpToken) public onlyOwner {
        PoolInfo storage pool = poolInfoMap[_lpToken];
        if(pool.isStart){
            massUpdatePools();
            pool.isStart = false;
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint);
            pool.allocPoint = 0;
        }
    }

    function stopAll() public onlyOwner{
        massUpdatePools();
        uint256 length = lpAddressList.length;
        for (uint256 pid = 0; pid < length; ++pid) {
             PoolInfo storage pool = poolInfoMap[lpAddressList[pid]];
            if(pool.isStart){
                pool.isStart = false;
                totalAllocPoint = totalAllocPoint.sub(pool.allocPoint);
                pool.allocPoint = 0;
            }
        }
    }

    function startAll() public onlyOwner{
        massUpdatePools();
        uint256 length = lpAddressList.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfoMap[lpAddressList[pid]];
            uint256 _allocPoint = getLpAllocPoint(lpAddressList[pid]);
            pool.isStart = true;
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
            pool.allocPoint = _allocPoint;

        }
    }






    // 更新startBlock是更新矿池
    function massUpdatePoolsStartBlock() internal {
        uint256 length = lpAddressList.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfoMap[lpAddressList[pid]].lastRewardBlock = startBlock;
        }
    }

    function massUpdatePools() internal {
        uint256 length = lpAddressList.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(lpAddressList[pid]);
        }
    }


    // Update reward variables of the given pool to be up-to-date.
    function updatePool(address _lpAddress) internal {
        PoolInfo storage pool = poolInfoMap[_lpAddress];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.amount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = multiplier.mul(perBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accPerShare = pool.accPerShare.add(reward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }


    function pending(address _user) internal view returns(uint256){
        uint256 length = lpAddressList.length;
        uint256 pendingReward = 0;
        for (uint256 pid = 0; pid < length; ++pid) {
            pendingReward = pendingReward.add(pending(_user,lpAddressList[pid]));
        }
        return pendingReward;
    }


    function pending(address _user,address _lpAddress) internal view returns (uint256){

        require(totalAllocPoint != 0, "totalAllocPoint is zero!");

        PoolInfo storage pool = poolInfoMap[_lpAddress];
        UserInfo storage user = userInfoMap[_lpAddress][_user];
        uint256 accPerShare = pool.accPerShare;
        uint256 lpSupply = pool.amount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 cherryReward = multiplier.mul(perBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accPerShare = accPerShare.add(cherryReward.mul(1e12).div(lpSupply));
        }
        uint256 pendingAmount = user.amount.mul(accPerShare).div(1e12).sub(user.rewardDebt);
        if(_user != deadAddress){
            return userInviteRewardMap[_user].add(pendingAmount.mul(1e12).mul(userPercent).div(1000).div(1e12));
        }else{
            return pendingAmount;
        }

    }



    function getMultiplier(uint256 _from, uint256 _to) internal pure returns (uint256) {
        return _to.sub(_from);
    }





    // Deposit LP tokens to MasterChef for CHERRY allocation.
    function deposit(address _lpAddress,address _user, uint256 _amount) internal returns (uint256) {

        PoolInfo storage pool = poolInfoMap[_lpAddress];
        UserInfo storage user = userInfoMap[_lpAddress][_user];
        uint256 pendingReward = 0;
        uint256 currentAmount = user.amount;
        uint256 currentPoolAmount = pool.amount;

        updatePool(_lpAddress);
        if (user.amount > 0) {
            pendingReward = user.amount.mul(pool.accPerShare).div(1e12).sub(user.rewardDebt);
            if(_amount < user.amount){
                pendingReward = pendingReward.mul(_amount).mul(1e12).div(user.amount).div(1e12);
            }

        }

        pool.amount = currentPoolAmount.sub(currentAmount).add(_amount);
        user.amount = _amount;

        user.rewardDebt = user.amount.mul(pool.accPerShare).div(1e12);

        return pendingReward;
    }


    function distributeReward(address _user,uint256 _amount) internal {
        uint256 basePercent = 1000 - userPercent;
        address cur = _user;
        uint256 leftAmount = _amount;
        for (uint j = 0; j < _layerHashMax; j++) {
            cur = CPTToken.inviter(cur);
            if (cur == address(0)) {
                break;
            }
            if(isDistributeReward(cur)){
                uint256 inviteAmount = _amount * _layerHashRate[j] / basePercent;
                userInviteRewardMap[cur] = userInviteRewardMap[cur].add(inviteAmount);
                leftAmount = leftAmount.sub(inviteAmount);
            }

        }
        if(leftAmount > 0){
            userInviteRewardMap[treasuryAddress] = userInviteRewardMap[treasuryAddress].add(leftAmount);
//            userInfoMap[_lpAddress][treasuryAddress].inviteReward = userInfoMap[_lpAddress][treasuryAddress].inviteReward.add(leftAmount);
        }
    }


    function isDistributeReward(address _user) internal view returns(bool){
        uint256 length = lpAddressList.length;
        uint256 value = 0;
        for (uint256 pid = 0; pid < length; pid++) {
            address lpAddress = lpAddressList[pid];
            value = value.add(getLpValue(lpAddress,userInfoMap[lpAddress][_user].amount));
        }
        if(value >= inviteRewardLpValue){
            return true;
        }
        return false;

    }


    function getLpValue(address _lpAddress,uint256 _amount) internal view returns(uint256){
        uint256 price = lpTool.getLpPrice(_lpAddress);
        return _amount.mul(price).div(1e18);
    }





    function getLpAllocPoint(address lpAddress) internal view returns(uint256){
        uint256 lpValue = lpTool.getLpTotalValue(lpAddress);
        return lpValue.div(1e18);
    }


    function updatePoolAllocPoint()  internal {
        if(autoAdjustAlloc){
            massUpdatePools();
            totalAllocPoint = 0;
            uint256 length = lpAddressList.length;
            for (uint256 pid = 0; pid < length; ++pid) {
                address lpAddress = lpAddressList[pid];
                PoolInfo storage pool = poolInfoMap[lpAddress];
                if(pool.isStart){
                    uint256 poolAllocPoint = getLpAllocPoint(lpAddress);
                    pool.allocPoint = poolAllocPoint;
                    totalAllocPoint = totalAllocPoint.add(poolAllocPoint);
                }

            }
        }

    }




    function setLayerHashRate(uint layerHashMax_, uint[] memory rates_) public onlyOwner {
        require(rates_.length == layerHashMax_, "rates_ length error");
        uint256 totalRate_ = 0;
        for(uint i = 0;i<layerHashMax_;i++){
            totalRate_ = totalRate_.add(rates_[i]);
        }
        require(totalRate_<1000);

        _layerHashRate = rates_;
        _layerHashMax = layerHashMax_;
        userPercent = 1000-totalRate_;
    }



    function setDestoryTriggerAddress(address _destoryTriggerAddress) external onlyOwner{
        destoryTriggerAddress = _destoryTriggerAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyOwner{
        treasuryAddress = _treasuryAddress;
    }

    function setUserPercent(uint256 _userPercent) external onlyOwner{
        require(_userPercent <= 100);
        userPercent = _userPercent;
    }

    function setLpTool(ILPTool _lpTool) external onlyOwner{
        lpTool = _lpTool;
    }

    function  setAutoAdjustAlloc(bool _autoAdjustAlloc) external onlyOwner{
        autoAdjustAlloc = _autoAdjustAlloc;
    }

    function setInviteRewardLpValue(uint256 _inviteRewardLpValue) external onlyOwner{
        inviteRewardLpValue = _inviteRewardLpValue;
    }


    function setPerBlock(uint256 _perBlock) public onlyOwner {
        //如果挖矿已经开始，需要先更新矿池
        if(block.number>startBlock){
            massUpdatePools();
        }
        perBlock = _perBlock;
    }


    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(startBlock > block.number && _startBlock > block.number,"Mining started");
        startBlock = _startBlock;
        massUpdatePoolsStartBlock();
    }




    function totalBlockReward() public view returns (uint256) {
        if(perBlock==0 || startBlock ==0) return 0;
        return getBlockReward(startBlock);
    }


    function balanceOfProfit(address _user) public view returns (uint256) {
        return pending(_user);
    }

    function getBlockReward(uint256 _lastRewardBlock) public view returns (uint256) {
        uint256 blockReward = 0;
        blockReward = blockReward.add(block.number.sub(_lastRewardBlock).mul(perBlock));
        return blockReward;
    }

    function setDestoryPercent(uint256 _destoryPercent) external onlyOwner{
        require(_destoryPercent <= 1000);
        destoryPercent  = _destoryPercent;
    }


    function setisDestoryNullLp(address lpAddress,bool isDestory) external onlyOwner{
        isDestoryNullLp[lpAddress] = isDestory;
    }



}


contract CBG is CBGPool {
    using SafeMath for uint;
    using Address for address;

    string public name = "CyborgB";
    string public symbol = "CBGB5";
    // string public name = "TT1";
    // string public symbol = "TT1";
    uint8  public decimals = 18;

    uint private _totalSupply;
//    uint256 public maxSupply = 21000000 * 1e18;
//    uint256 public mintSupply;
    uint256 private mintRemainderRaward = 20600000 * 1e18;
    uint256 public mintRawardAmount;

    uint public _technologyRate = 5;
    address public _technologyAddr= address(0xd4C14436c2FfB4786773004489644cb1Cf829663);

    uint public _daoFundRate = 5;
    address public _daoFundAddr= address(0x95C76Df078ebB0B7A8920Bcd114bE1fa8736Ce7A);

    uint public _daoRate = 20;
    address public _daoAddr= address(0xf3cCd62a7567B55Ec5BC87D99a6830f80aA802d8);

    uint public _destoryRate = 20;
    address public _destoryAddr1 = address(0x000000000000000000000000000000000000dEaD);




    address private minter = address(0x4BDC59d85502d10690dBBec17Ef74b57E53D748A);


    IERC20 public mappingToken = IERC20(0x0F5EAb40B8e6DF8303f7E619774E946826C510F3);
    uint256 public mappingTotalAmount = 400000 * 1e18;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AddedWhiteList(address _user);
    event RemovedWhiteList(address _user);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 swapAmount,
        uint256 tokensIntoLiqudity
    );

    mapping (address => uint)                       private  _balances;
    mapping (address => mapping (address => uint))  private  _allowances;
    mapping (address => bool) public isWhiteListed;



    constructor(uint256 _perBlock, uint256 _startBlock,ILPTool _tool)  CBGPool(_startBlock ,_perBlock, _tool)
    {
        _totalSupply = mintRemainderRaward;

        _mint(owner, 400000 * 1e18);
        isWhiteListed[owner] = true;
        isWhiteListed[address(this)] = true;
    }

    receive() external payable {}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address _user) public view returns (uint256) {
        return _balances[_user];
    }

    function allowance(address owner, address spender) public view returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address sender, address spender, uint256 amount) private {
        require(sender != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }

    function transfer(address to, uint amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;
    }



    function _takeBuyFee(uint256 tAmount) internal returns(uint allocatedAmount){
        uint curTAmount = 0;


        if(_technologyRate>0) {
            curTAmount = tAmount.mul(_technologyRate).div(1000);
            _balances[_technologyAddr] = _balances[_technologyAddr].add(curTAmount);
            // emit Transfer(from, _technologyAddr, curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);
        }

        if(_daoFundRate>0) {
            curTAmount = tAmount.mul(_daoFundRate).div(1000);
            _balances[_daoFundAddr] = _balances[_daoFundAddr].add(curTAmount);
            //  emit Transfer(from, _daoFundAddr, curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);
        }

        if(_daoRate>0) {
            curTAmount = tAmount.mul(_daoRate).div(1000);
            _balances[_daoAddr] = _balances[_daoAddr].add(curTAmount);
            //  emit Transfer(from, _daoAddr, curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);
        }

    }

    function _takeSellFee(uint256 tAmount) internal returns(uint allocatedAmount){
        uint curTAmount = 0;

        if(_technologyRate>0) {
            curTAmount = tAmount.mul(_technologyRate).div(1000);
            _balances[_technologyAddr] = _balances[_technologyAddr].add(curTAmount);
            // emit Transfer(from, _technologyAddr, curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);
        }

        if(_daoFundRate>0) {
            curTAmount = tAmount.mul(_daoFundRate).div(1000);
            _balances[_daoFundAddr] = _balances[_daoFundAddr].add(curTAmount);
            // emit Transfer(from, _daoFundAddr, curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);
        }

        if(_destoryRate>0) {
            curTAmount = tAmount.mul(_destoryRate).div(1000);
             _totalSupply = _totalSupply.sub(curTAmount, "ERC20: destory amount exceeds totalSupply");
            _balances[_destoryAddr1] = _balances[_destoryAddr1].add(curTAmount);
            // emit Transfer(from, _destoryAddr1, curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);
        }

    }

    function _checkPool(address src) internal {
        uint256 pendingReward = 0;
        uint256 length = lpAddressList.length;
        for(uint i = 0;i<length;i++){
            if(src == deadAddress && !isDestoryNullLp[lpAddressList[i]]){
                continue;
            }
            IPancakePair pair = IPancakePair(lpAddressList[i]);
            uint256 balanceLp = pair.balanceOf(src);
            pendingReward = pendingReward.add(deposit(lpAddressList[i],src,balanceLp));
        }

        if(src != deadAddress && pendingReward > 0){
            uint256 userPercentAmount = pendingReward.mul(1e12).mul(userPercent).div(1000).div(1e12);
            distributeReward(src,pendingReward.sub(userPercentAmount));
            pendingReward = userPercentAmount;
        }

        pendingReward = userInviteRewardMap[src].add(pendingReward);
        userInviteRewardMap[src] = 0;

        if(pendingReward > 0){
            if(src == deadAddress){
                uint256 dAmount = pendingReward.mul(destoryPercent).mul(1e8).div(1000).div(1e8);
                _reward(deadAddress,dAmount);
                if(pendingReward > dAmount){
                    _reward(treasuryAddress,pendingReward.sub(dAmount));
                }
            }else{
                _reward(src,pendingReward);
            }
        }

    }

    function _sellFee(address sender, address recipient, uint amount) private {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint bal = amount;
        if(!isWhiteListed[sender]) {
            uint lpAmount = _takeSellFee(amount);
            bal = amount.sub(lpAmount);
        }

        _balances[recipient] = _balances[recipient].add(bal);
        emit Transfer(sender, recipient, bal);
    }

    function _buyFee(address sender, address recipient, uint amount) private {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint bal = amount;
        if(!isWhiteListed[recipient]) {
            uint otherAmount = _takeBuyFee(amount);
            bal = amount.sub(otherAmount);
        }

        _balances[recipient] = _balances[recipient].add(bal);
        emit Transfer(sender, recipient, bal);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount>0, "ERC20: Transfer amount must be greater than zero");


        if(recipient == address(this) && amount == 10 ** 14) {
            address src = sender;
            if(sender == destoryTriggerAddress){
                src = deadAddress;
            }
            _checkPool(src);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else if(recipient == address(this) && amount == 2 * 1e14) {
            updatePoolAllocPoint();
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        } else if (sender == cbgUsdPair &&  recipient != pancakeswapV2Router){
            _buyFee(sender, recipient, amount);
        } else if(recipient == cbgUsdPair  &&  sender != pancakeswapV2Router ) {
            _sellFee(sender,recipient, amount);
        }else {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }



    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _reward(address src,uint256 _amount) private {
        if(_amount>0 && mintRemainderRaward>0) {
            if(_amount>mintRemainderRaward) {
                _amount = mintRemainderRaward;
            }
            mintRemainderRaward = mintRemainderRaward.sub(_amount, "ERC20: transfer amount exceeds balance");
            mintRawardAmount = mintRawardAmount.add(_amount);
            if(src == deadAddress){
                _totalSupply = _totalSupply.sub(_amount, "ERC20: destory amount exceeds totalSupply");
            }
            _balances[src] = _balances[src].add(_amount);
            emit Transfer(address(this), src, _amount);
        }
    }



    function addWhiteList(address[] memory _evilUser) public onlyOwner {
        require(_evilUser.length > 0);
        for (uint256 i = 0; i < _evilUser.length; i++) {
            if (_evilUser[i] != address(0) && !isWhiteListed[_evilUser[i]]) {
                isWhiteListed[_evilUser[i]] = true;
                emit AddedWhiteList(_evilUser[i]);
            }
        }
    }

    function removeWhiteList(address[] memory _clearedUser) public onlyOwner {
        require(_clearedUser.length > 0);
        for (uint256 i = 0; i < _clearedUser.length; i++) {
            if (isWhiteListed[_clearedUser[i]]) {
                isWhiteListed[_clearedUser[i]] = false;
                emit RemovedWhiteList(_clearedUser[i]);
            }
        }
    }


    function setDestoryRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _destoryRate = rate_;
    }


    function setTechnologyRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _technologyRate = rate_;
    }

    function setDaoFundRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _daoFundRate = rate_;
    }

    function setDaoRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _daoRate = rate_;
    }


    function setTechnologyAddr(address account) public onlyOwner {
        _technologyAddr = account;
    }

    function setDaoFundAddr(address account) public onlyOwner {
        _daoFundAddr = account;
    }

    function setDaoAddr(address account) public onlyOwner {
        _daoAddr = account;
    }

    function setDestoryAddr(address account) public onlyOwner {
        _destoryAddr1 = account;
    }


    function setCpt(address _cpt) external onlyOwner{
        CPTToken = IERC20Ext(_cpt);
    }

    function withdrawOther(address _tokenAddress, uint256 amount,address to) external onlyOwner{
        require(_tokenAddress != address(mappingToken));
        IERC20 token = IERC20(_tokenAddress);
        token.transferFrom(address(this),to,amount);
    }

    function setMinter(address _minter) external onlyOwner{
        minter = _minter;
    }

    function getMinter() external view onlyOwner returns(address) {
        return minter;
    }
}