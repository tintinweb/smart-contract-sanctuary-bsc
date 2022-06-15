/**
 *Submitted for verification at BscScan.com on 2022-06-15
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

contract Recv {
    IERC20 public tokenCPG;
    IERC20 public tokenPCE;

    constructor (IERC20 _tokenCPG) {
        tokenCPG = _tokenCPG;
        tokenPCE = IERC20(0x85973C97919c999E5D3d8832290152a3ACdf8a6E); //NOTICE Peace
    }

    function withdraw() public {
        uint256 tokenPCEBalance = tokenPCE.balanceOf(address(this));
        if (tokenPCEBalance > 0) {
            tokenPCE.transfer(address(tokenCPG), tokenPCEBalance);
        }
        uint256 tokenCPGBalance = tokenCPG.balanceOf(address(this));
        if (tokenCPGBalance > 0) {
            tokenCPG.transfer(address(tokenCPG), tokenCPGBalance);
        }
    }
}




contract CPGPool is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public pancakeswapV2Pair;

    address[] public LPLists; 

    uint[] public LPSwapTokenMins;  

    uint[] public _LPBaseRates;
    uint[] public _LPRates;
    uint public totalLPRate;

    uint[] private _layerHashRate = [10,5,5,5,4,4,4,3,3,3,2,2]; 
    uint public _layerHashMax = 12;

    address public pancakeswapV2Router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);  

    address public peaceToken = address(0x85973C97919c999E5D3d8832290152a3ACdf8a6E); //NOTICE Peace
    address public peaceUsdPair = address(0x4b3b5b1335D33E0a9eBD583dB9845ad17094eCa7); //Peace-usd
    address public usdToken = address(0x55d398326f99059fF775485246999027B3197955); //usd

    address internal CPTToken = address(0xD66734e3663D3Eb36F1e7819bc20bfb9c5B5ba62); //CPT       
    address public baseAddr;             

    event StartPool(address indexed user, uint256 amount);
    event StopPool(address indexed user, uint256 amount);
    event InviteAmount(address indexed user, uint256 addAmount, uint256 subAmount);

    struct UserInfo {
        uint256 amount;
        uint256 inviteAmount;
        uint256 rewardDebt; 
        bool isStart;       
    }

    struct PoolInfo {
        uint256 lastRewardBlock;  
        uint256 accPerShare; 
        uint256 totalAmount;    
    }

    uint public totalReward;    
    uint256 public perBlock;   
    PoolInfo public poolInfo;   
    mapping(address => UserInfo) public userInfos;  
    

    bool public paused = false;  
    uint256 public startBlock;   
    uint256 public halvingPeriod = 0;  

    uint private poolUserIndex;     
    address[] private userLists;    
    bool islocked;

    uint private checkPoolUserMax = 30;  

    modifier notPause() {
        require(paused == false, "Mining has been suspended");
        _;
    }
    modifier lock() {
        islocked = true;
        _;
        islocked = false;
    }

    constructor()  {
        pancakeswapV2Pair = IPancakeFactory(IPancakeRouter02(pancakeswapV2Router).factory())
            .createPair(address(this), peaceToken);

        initLPLists();

        baseAddr = owner;
    }

    function initLPLists() private {
        LPLists.push(pancakeswapV2Pair);
        LPSwapTokenMins.push(200*1e18);
        _LPRates.push(0);
        _LPBaseRates.push(0);

        LPLists.push(peaceUsdPair);
        LPSwapTokenMins.push(200*1e18);
        _LPRates.push(0);
        _LPBaseRates.push(0);
    }


    function initPool(uint _totalReward, uint256 _perBlock, uint256 _startBlock)  internal {
        totalReward = _totalReward;
        perBlock = _perBlock;
        startBlock = _startBlock;
        poolInfo = PoolInfo({
            lastRewardBlock : _startBlock,
            accPerShare : 0,
            totalAmount : 0
        });
    }
    function totalSupplyLP() public view returns (uint256) {
        return poolInfo.totalAmount;
    }
    function totalBlockReward() public view returns (uint256) {
        if(perBlock==0 || startBlock ==0) return 0;
        return getBlockReward(startBlock);
    }
    function balanceOfProfit(address _user) public view returns (uint256) {
        return pending(_user);
    }
    function balanceOfLP(address _user) public view returns (uint256) {
        return userInfos[_user].amount;
    }
    function balanceOfLPInvite(address _user) public view returns (uint256) {
        return userInfos[_user].inviteAmount;
    }
    function setHalvingPeriod(uint256 _blockCount) public onlyOwner {
        halvingPeriod = _blockCount;
    }
    function setPerBlock(uint256 _newPerBlock) public onlyOwner {
        require((perBlock==0 || startBlock ==0), "Mining started");
        perBlock = _newPerBlock;
    }
    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require((perBlock==0 || startBlock ==0), "Mining started");
        startBlock = _startBlock;
        poolInfo.lastRewardBlock = _startBlock;
    }

    function setPause() public onlyOwner {
        paused = !paused;
    }
    function phase(uint256 blockNumber) public view returns (uint256) {
        if (halvingPeriod == 0) {
            return 0;
        }
        if (blockNumber > startBlock) {
            return (blockNumber.sub(startBlock).sub(1)).div(halvingPeriod);
        }
        return 0;
    }

    function reward(uint256 blockNumber) public view returns (uint256) {
        uint256 _phase = phase(blockNumber);
        return perBlock.div(2 ** _phase);
    }
    function getBlockReward(uint256 _lastRewardBlock) public view returns (uint256) {
        uint256 blockReward = 0;
        uint256 n = phase(_lastRewardBlock);
        uint256 m = phase(block.number);
        while (n < m) {
            n++;
            uint256 r = n.mul(halvingPeriod).add(startBlock);
            blockReward = blockReward.add((r.sub(_lastRewardBlock)).mul(reward(r)));
            _lastRewardBlock = r;
        }
        blockReward = blockReward.add((block.number.sub(_lastRewardBlock)).mul(reward(block.number)));
        return blockReward;
    }

    function updatePool() public {
        PoolInfo storage pool = poolInfo;
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        uint256 _totalBlockReward = getBlockReward(startBlock);
        if(_totalBlockReward>= totalReward) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockReward = getBlockReward(pool.lastRewardBlock);
        if (blockReward <= 0) {
            return;
        }
        if(blockReward <= totalReward) {
            pool.accPerShare = pool.accPerShare.add(blockReward.mul(1e12).div(lpSupply));
        }
        
        pool.lastRewardBlock = block.number;
    }

    function pending(address _user) internal view returns (uint256){
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfos[_user];
        uint256 accPerShare = pool.accPerShare;
        uint256 lpSupply = pool.totalAmount;  
        if (user.amount > 0 && user.isStart) {
            if (block.number > pool.lastRewardBlock) {
                uint256 blockReward = getBlockReward(pool.lastRewardBlock);
                accPerShare = accPerShare.add(blockReward.mul(1e12).div(lpSupply));
                return (user.amount+user.inviteAmount).mul(accPerShare).div(1e12).sub(user.rewardDebt);
            }
            if (block.number == pool.lastRewardBlock) {
                return (user.amount+user.inviteAmount).mul(accPerShare).div(1e12).sub(user.rewardDebt);
            }
        }
        return 0;
    }

    function removeUserList(address _user) private {
        for(uint i=0;i<userLists.length;i++){
            if(userLists[i] == _user) {
                if(i < userLists.length -1)
                    userLists[i] = userLists[userLists.length -1];
                userLists.pop();
                break;
            }
        }
    }

    function setLayerHashMax(uint layerHashMax_) public onlyOwner {
        _layerHashMax = layerHashMax_;
    }

    function setLayerHashRate(uint layerHashMax_, uint[] memory rates_) public onlyOwner {
        require(rates_.length == layerHashMax_, "rates_ length error");
        
        _layerHashRate = rates_;
        _layerHashMax = layerHashMax_;
    }

    function setLPAddrs(address[] memory lpAddrs_, uint[] memory mins_) public onlyOwner {
        require(mins_.length == lpAddrs_.length, "mins_/lpAddrs_ length error");
  
        LPLists = lpAddrs_;
        LPSwapTokenMins = mins_;
    }

    function setLPBaseRate(uint[] memory LPBaseRates_) public onlyOwner {
        require(LPBaseRates_.length == LPLists.length, "LPBaseRate_/LPLists length error");

        _LPBaseRates = LPBaseRates_;
    }

    function addLP(address lpAddr, uint minAmount, uint LPBaseRate_) public onlyOwner {
        require(minAmount > 0, "minAmount error");

        for (uint256 i = 0; i < LPLists.length; i++) {
            if (LPLists[i] == lpAddr) {
                LPSwapTokenMins[i] = minAmount;
                _LPBaseRates[i] = LPBaseRate_;
                return;
            }
        }

        LPLists.push(lpAddr);
        _LPRates.push(0);
        _LPBaseRates.push(0);
        LPSwapTokenMins.push(minAmount);
    }

    function setSwapTokenMinAmount(uint[] memory mins_) public onlyOwner {
        require(mins_.length == LPLists.length, "swapAddrs_ length error");

        LPSwapTokenMins = mins_;
    }



    function getLPTotalAmount(address account) public view returns(uint) {
        uint _totalLPBase;
        for (uint j = 0; j < _LPBaseRates.length; j++) {
            _totalLPBase += _LPBaseRates[j];
        }

        uint liquidity;
        for (uint j = 0; j < LPLists.length; j++) {
            uint _lpAmount = IPancakePair(LPLists[j]).balanceOf(account);
            liquidity += _lpAmount.mul(_LPRates[j]+_LPBaseRates[j]).div(totalLPRate+_totalLPBase);
        }
        return liquidity;
    }

    function _checkPoolUser() internal lock {
        if(startBlock ==0 || perBlock==0 ||  block.number<startBlock || LPLists.length == 0) return;
        PoolInfo storage pool = poolInfo;
        uint _len = userLists.length;
        if(poolUserIndex>= _len) poolUserIndex=0;
        uint i= poolUserIndex;
        uint k;
        
        IERC20Ext _iee = IERC20Ext(CPTToken);

        while(i< _len) {
            address _u = userLists[i];
            if(_u == baseAddr && userInfos[_u].isStart) {
                i++;
            } else {

                uint liquidity = getLPTotalAmount(_u);
                uint _amount = userInfos[_u].amount;
                if(liquidity==0 || liquidity < _amount) {

                    uint inviteAmount = userInfos[_u].inviteAmount;
                    userInfos[_u].amount = 0;
                    userInfos[_u].inviteAmount = 0;
                    userInfos[_u].isStart = false;
                    userInfos[_u].rewardDebt = 0;
                    emit InviteAmount(_u, 0, inviteAmount);

                    uint _oldTotalAmount;
                    address cur = _u;
                    for (uint j = 0; j < _layerHashMax; j++) {
                        cur = _iee.inviter(cur);
                        if (cur == address(0)) {
                            break;
                        }
                        uint _oldAmount = _amount * _layerHashRate[j] / 100;
                        if(userInfos[cur].inviteAmount < _oldAmount) {
                            _oldAmount = userInfos[cur].inviteAmount;
                        }
                        userInfos[cur].inviteAmount = userInfos[cur].inviteAmount.sub(_oldAmount);
                        emit InviteAmount(cur, 0, _oldAmount);
                        _oldTotalAmount += _oldAmount;
                    }

                    
                    uint _totalAmount = pool.totalAmount;
                    pool.totalAmount = _totalAmount.sub(_amount).sub(_oldTotalAmount).sub(inviteAmount);

                    if(i < userLists.length -1) 
                        userLists[i] = userLists[userLists.length -1];
                    userLists.pop();
                    _len = userLists.length;
                }
                else {
                    i++;
                }
                k++;
            }
            if(k>=checkPoolUserMax) break;
        }
        if(i>=userLists.length){
            poolUserIndex=0;
        }else {
            poolUserIndex=i;
        }
        
    }
    function checkSwapTokenAmount(address) public virtual view returns(bool) {
        return false;
    }
    function deposit(uint _amount, address _user) internal returns(uint){
        if(startBlock ==0 || perBlock==0 ||  block.number<startBlock) return 0;
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfos[_user];
        
        uint amount = user.amount;
        uint256 pendingAmount;
        updatePool();
        if(amount>0 && (_user == baseAddr || _amount>=amount)) {
            pendingAmount = (amount + user.inviteAmount).mul(pool.accPerShare).div(1e12).sub(user.rewardDebt);
        }

        if(_user != baseAddr || (_user == baseAddr && amount==0)) {
            user.amount = _amount;
            uint _totalAmount = pool.totalAmount;

            if (_user == baseAddr) {
                user.inviteAmount = _amount.mul(100).div(100);//x1
                emit InviteAmount(_user, _amount, 0);
                _totalAmount = _totalAmount.add(user.inviteAmount);
            }

            pool.totalAmount = _totalAmount.sub(amount).add(_amount);

            if(_amount != amount && _layerHashMax > 0) {
                IERC20Ext _iee = IERC20Ext(CPTToken);
                address cur = _user;
                for (uint j = 0; j < _layerHashMax; j++) {
                    cur = _iee.inviter(cur);
                    if (cur == address(0)) {
                        break;
                    }

		            uint _inviteAmount = userInfos[cur].inviteAmount;

                    //checkSwapTokenAmount(
                    if(!checkSwapTokenAmount(cur)){
			            userInfos[cur].inviteAmount = 0;
                        emit InviteAmount(cur, 0, _inviteAmount);
                        _totalAmount = pool.totalAmount;
                        pool.totalAmount = _totalAmount.sub(_inviteAmount);
                        continue;
                    }

                    uint _newAmount = (_amount * _layerHashRate[j]).div(100);
                    uint _oldAmount = (amount * _layerHashRate[j]).div(100);
                    if(_inviteAmount < _oldAmount) {
                        _oldAmount = _inviteAmount;
                    }
                    userInfos[cur].inviteAmount = _inviteAmount.sub(_oldAmount).add(_newAmount);
                    emit InviteAmount(cur, _newAmount, _oldAmount);

                    _totalAmount = pool.totalAmount;
                    pool.totalAmount = _totalAmount.sub(_oldAmount).add(_newAmount);
                }
            }

            if(user.amount == 0) {
                
                _totalAmount = pool.totalAmount;
                pool.totalAmount = _totalAmount.sub(user.inviteAmount);
                uint clearAmount = user.inviteAmount;
                user.inviteAmount = 0;
                emit InviteAmount(_user, 0, clearAmount);

                if(user.isStart) {
                    user.isStart = false;
                    removeUserList(_user);
                }
                emit StopPool(_user, _amount);
            }else {
                if(!user.isStart) {
                    userLists.push(_user);
                    user.isStart = true;
                    emit StartPool(_user, _amount);
                }
            }
        }
        user.rewardDebt = (user.amount + user.inviteAmount).mul(pool.accPerShare).div(1e12);
        return pendingAmount;
    }

    function setCheckPoolUserMax(uint _count) public onlyOwner {
        require(_count > 1, "max must be gte 1");

        checkPoolUserMax = _count;
    }
}
contract CPG is CPGPool {
    using SafeMath for uint;
    using Address for address;

    string public name = "CPG";
    string public symbol = "CPG";
    uint8  public decimals = 18;

    uint private _totalSupply;
    bool private inSwapAndLiquify;
    

    uint private _technologyRate = 5;       
    address private _technologyAddr= address(0x6E7e31Dab82cDFe79d1EADa37cCFcBdD391a61EA);       
    uint private _operationRate = 5;       
    address private _operationAddr= address(0xCeE0dD76E97f50E6e81F9D07A7E55130332A0d72);       
    uint private _daoRate = 20;            
    address private _daoAddr= address(0x70Ab97693D32e4ba7eB2691BD830FCBbe8594e77);             
    uint private _destoryRate = 0;            
    
    Recv public RECV ;

    uint public minAddLiquidityNumber = 1 * 10 ** 18;  
    uint public _liquidityRate = 20;        
  
    address public _destoryAddr = address(0x000000000000000000000000000000000000dEaD);             
    uint public _destoryAmount;

    
    uint public mintRemainderRaward;              
    uint public mintRawardAmount;                
    
    uint public tokenPrice;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // event AddedBlackList(address _user);
    // event RemovedBlackList(address _user);
    event AddedWhiteList(address _user);
    event RemovedWhiteList(address _user);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 swapAmount,
        uint256 tokensIntoLiqudity
    );

    mapping (address => uint)                       private  _balances;
    mapping (address => mapping (address => uint))  private  _allowances;
    // mapping (address => bool) public isBlackListed;   
    mapping (address => bool) public isWhiteListed;   
    mapping (address => bool) public isProfitWhiteListed;   
    
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    constructor(uint256 _perBlock, uint256 _startBlock) 
    {
        _approve(address(this), pancakeswapV2Router, type(uint).max);

        RECV = new Recv(IERC20(address(this)));
        mintRemainderRaward = 20850000 * 10**18;
        _totalSupply = mintRemainderRaward;

        _mint(owner, 150000 * 10**18);

        isWhiteListed[owner] = true;
        isWhiteListed[address(this)] = true;
        initPool(mintRemainderRaward, _perBlock, _startBlock);
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
        // require(!isBlackListed[sender], "ERC20: approve from black list");
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


    function _takeOtherFee(uint256 tAmount) internal returns(uint allocatedAmount){
        uint curTAmount = 0;
        if(_technologyRate>0) {
            curTAmount = tAmount.div(1000).mul(_technologyRate); 
            _balances[_technologyAddr] = _balances[_technologyAddr].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }
        
        if(_operationRate>0) {
            curTAmount = tAmount.div(1000).mul(_operationRate); 
            _balances[_operationAddr] = _balances[_operationAddr].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }
        
        if(_daoRate>0) {
            curTAmount = tAmount.div(1000).mul(_daoRate); 
            _balances[_daoAddr] = _balances[_daoAddr].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }

        if(_destoryRate>0) {
            curTAmount = tAmount.div(1000).mul(_destoryRate); 
            _totalSupply = _totalSupply.sub(curTAmount, "ERC20: destory amount exceeds totalSupply");
            _balances[_destoryAddr] = _balances[_destoryAddr].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }
    }
    function _takeLiquidityFee(uint256 tAmount) internal returns(uint allocatedAmount){
        uint curTAmount = 0;
        if(_liquidityRate>0) {
            curTAmount = tAmount.div(1000).mul(_liquidityRate); 
            _balances[address(this)] = _balances[address(this)].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }   

        if(_technologyRate>0) {
            curTAmount = tAmount.div(1000).mul(_technologyRate); 
            _balances[_technologyAddr] = _balances[_technologyAddr].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }
        
        if(_operationRate>0) {
            curTAmount = tAmount.div(1000).mul(_operationRate); 
            _balances[_operationAddr] = _balances[_operationAddr].add(curTAmount);
            allocatedAmount = allocatedAmount.add(curTAmount);   
        }

    }
    function _checkPool(address src, bool _isHarvest) internal {
        if(!paused && perBlock>0 && startBlock>0  && mintRemainderRaward>0 && !src.isContract()&&LPLists.length>0){

            uint _lpAmount = getLPTotalAmount(src);

            if(_isHarvest || _lpAmount != balanceOfLP(src))
            {
                uint _amount = deposit(_lpAmount, src);
                if(_amount>0 && mintRemainderRaward>0) {
                    if(_amount>mintRemainderRaward) {
                        _amount = mintRemainderRaward;
                    }
                    mintRemainderRaward = mintRemainderRaward.sub(_amount, "ERC20: transfer amount exceeds balance");
                    mintRawardAmount = mintRawardAmount.add(_amount);
                    if(src == baseAddr) {
                        _totalSupply = _totalSupply.sub(_amount, "ERC20: destory amount exceeds totalSupply");
                        _balances[_destoryAddr] = _balances[_destoryAddr].add(_amount);
                        emit Transfer(src, _destoryAddr, _amount);
                    }else {
                        uint bal =_amount;
                        if(!isWhiteListed[src]) {

                            uint otherAmount = bal.div(1000).mul(_daoRate); 
                            _balances[_daoAddr] = _balances[_daoAddr].add(otherAmount);
                            bal = bal.sub(otherAmount);
                        }
                        _balances[src] = _balances[src].add(bal);
                        emit Transfer(address(this), src, bal);
                    }
                    
                }
                
            }
        }
    }    
    function _sellFee(address sender, address recipient, uint amount) private {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint bal = amount;
        if(!isWhiteListed[sender]) {
            uint lpAmount = _takeLiquidityFee(amount);
            bal = amount.sub(lpAmount);
        }

        _balances[recipient] = _balances[recipient].add(bal);
        emit Transfer(sender, recipient, bal);
    }
    function _buyFee(address sender, address recipient, uint amount) private {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint bal = amount;
        if(!isWhiteListed[recipient]) {
            uint otherAmount = _takeOtherFee(amount);
            bal = amount.sub(otherAmount);
        }

        _balances[recipient] = _balances[recipient].add(bal);
        emit Transfer(sender, recipient, bal);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        // require(!isBlackListed[sender], "ERC20: transfer from the black list");
        // require(!isBlackListed[recipient], "ERC20: transfer to the black list");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount>0, "ERC20: Transfer amount must be greater than zero");
        if(_liquidityRate>0 && _balances[address(this)]>0 && sender != address(this)  
            && sender != pancakeswapV2Pair 
            && sender != pancakeswapV2Router
            && recipient != pancakeswapV2Pair 
            && !inSwapAndLiquify) {
            _checkLiquidity();
        }
        if(!paused && !islocked && !inSwapAndLiquify) { 
            _checkPoolUser();
        }
        
        bool isHarvest;         
        if(recipient == address(this) && amount == 10 ** 14) {
            isHarvest = true;
            _checkPool(sender, isHarvest);
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return;
        }
            
        if (!inSwapAndLiquify && sender == pancakeswapV2Pair &&  recipient != pancakeswapV2Router){
            _buyFee(sender, recipient, amount);
            updatePrice();
        } 
        else if(!inSwapAndLiquify && recipient == pancakeswapV2Pair  &&  sender != pancakeswapV2Router ) {
            _sellFee(sender,recipient, amount);
            updatePrice();
        }else {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }

    }
    function _swapTokensForTokens(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = peaceToken;
        IPancakeRouter02(pancakeswapV2Router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(RECV),
            block.timestamp
        );
        RECV.withdraw();
    }
    function _addLiquidity(uint256 tokenAmount, uint256 swapAmount) private {
        if(IERC20(peaceToken).allowance(address(this), pancakeswapV2Router)<swapAmount) {
            IERC20(peaceToken).approve(pancakeswapV2Router, type(uint).max);
        }
        IPancakeRouter02(pancakeswapV2Router).addLiquidity(
            address(this),
            peaceToken,
            tokenAmount,
            swapAmount,
            0, 
            0, 
            _destoryAddr,//destory
            block.timestamp
        );
    }

    function _checkLiquidity() private lockTheSwap {
        uint amount = _balances[address(this)];
        if(amount>= minAddLiquidityNumber) {
            uint half = amount.div(2);
            uint otherHalf = amount.sub(half);
            _swapTokensForTokens(half);
            uint newBalance = IERC20(peaceToken).balanceOf(address(this));
            if(newBalance>0) {
                _addLiquidity(otherHalf, newBalance);
                emit SwapAndLiquify(half, newBalance, otherHalf);
            }
            
        }
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function destory() public {
        uint _lpAmount = getLPTotalAmount(_destoryAddr);
        if(_lpAmount>_destoryAmount){
            uint _amount = _lpAmount.sub(_destoryAmount).mul(50).div(100);

            uint _poolAmount = poolInfo.totalAmount;
            poolInfo.totalAmount = _poolAmount.add(_amount);

            uint _baseAmount = userInfos[baseAddr].inviteAmount;
            userInfos[baseAddr].inviteAmount = _baseAmount.add(_amount);
            _destoryAmount = _lpAmount;
        }
    }

    function updatePrice() public {
        uint price = getTokenPrice();//CBG
        
        uint _total;
        uint tokenBalance1;
        for (uint256 i = 0; i < LPLists.length; i++) {
            if(LPLists[i]==peaceUsdPair){
                _LPRates[i] = IERC20(usdToken).balanceOf(peaceUsdPair);
            }else{
                tokenBalance1 = balanceOf(LPLists[i]); //CBG
                _LPRates[i] = tokenBalance1.div(1e8).mul(price);
            }
            _total += _LPRates[i];
        }
        totalLPRate = _total;
        tokenPrice = price;
    }
    
    function getPeacePrice() public view returns(uint) {
        uint usdBalance = IERC20(usdToken).balanceOf(peaceUsdPair); 
        uint peaceBalance = IERC20(peaceToken).balanceOf(peaceUsdPair); 
        if(peaceBalance==0){
            return 0;
        }
        uint peacePrice = usdBalance.mul(1e8).div(peaceBalance);
        return peacePrice;
    }

    //CBG
    function getTokenPrice() public view returns(uint) {
        uint peacePrice = getPeacePrice();

        uint peaceBalance1 = IERC20(peaceToken).balanceOf(pancakeswapV2Pair); 
        uint tokenBalance1 = balanceOf(pancakeswapV2Pair); 
        if(tokenBalance1==0){
            return 0;
        }
        uint tokenPrice1 = peaceBalance1.mul(peacePrice).div(tokenBalance1);
        return tokenPrice1;
    }

    function checkSwapTokenAmount(address account) public override view returns(bool) {
        
        for (uint256 i = 0; i < LPLists.length; i++) {
            uint _totalSupplyLP = IPancakePair(LPLists[i]).totalSupply();  
            if(_totalSupplyLP==0)continue;
            uint balance1;
            if(LPLists[i]==peaceUsdPair){
                balance1 = IERC20(usdToken).balanceOf(peaceUsdPair);
            }else{
                uint price = getTokenPrice();//CBG
                //CBG->usd
                balance1 = balanceOf(LPLists[i]).div(1e8).mul(price);
            }
            uint liquidity = IPancakePair(LPLists[i]).balanceOf(account); 
            uint amount1 = liquidity.mul(balance1).div(_totalSupplyLP);
            if(amount1>=LPSwapTokenMins[i]){
                return true;
            }
        }
        return false;
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

    function addProfitWhiteList (address[] memory _evilUser) public onlyOwner {
        require(_evilUser.length > 0);
        for (uint256 i = 0; i < _evilUser.length; i++) {
            if (_evilUser[i] != address(0) && !isProfitWhiteListed[_evilUser[i]]) {
                isProfitWhiteListed[_evilUser[i]] = true;
            }
        }
    }

    function removeProfitWhiteList (address[] memory _clearedUser) public onlyOwner {
        require(_clearedUser.length > 0);
        for (uint256 i = 0; i < _clearedUser.length; i++) {
            if (isProfitWhiteListed[_clearedUser[i]]) {
                isProfitWhiteListed[_clearedUser[i]] = false;
            }
        }
    }
    function setBaseAddr(address _baseAddr) public onlyOwner {
        require(_baseAddr!=address(0), "Base address to the zero address");
        require(baseAddr == owner, "Base address can only be set once");
        baseAddr = _baseAddr;
    }
    //
    function setLiquidityRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _liquidityRate = rate_;
    }

    // function setFundRate(uint rate_) public onlyOwner {
    //     require(rate_<1000, "Rate cannot exceed 1000");

    //     _fundRate = rate_;
    // }
    function setDestoryRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _destoryRate = rate_;
    }
    function setTechnologyRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _technologyRate = rate_;
    }

    function setOperationRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _operationRate = rate_;
    }
    function setDaoRate(uint rate_) public onlyOwner {
        require(rate_<1000, "Rate cannot exceed 1000");

        _daoRate = rate_;
    }
    function setMinAddLiquidityNum(uint num_) public onlyOwner {
        require(num_>=1_000_000_000_000_000, "Minimum LP liquidity cannot be less than 0.001");

        minAddLiquidityNumber = num_;
    }

    function setTechnologyAddr(address account) public onlyOwner {
        _technologyAddr = account;
    }
    function setOperationAddr(address account) public onlyOwner {
        _operationAddr = account;
    }
    function setDaoAddr(address account) public onlyOwner {
        _daoAddr = account;
    }

}