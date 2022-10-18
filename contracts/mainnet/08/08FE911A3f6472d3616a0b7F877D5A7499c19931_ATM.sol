// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./WithdrawAble.sol";
import "./DateTimeLibrary.sol";

// interface IERC20 {
//     function totalSupply() external view returns (uint256);
//     function balanceOf(address account) external view returns (uint256);
//     function transfer(address to, uint256 amount) external returns (bool);
//     function allowance(address owner, address spender) external view returns (uint256);
//     function approve(address spender, uint256 amount) external returns (bool);
//     function transferFrom(
//         address from,
//         address to,
//         uint256 amount
//     ) external returns (bool);
//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(address indexed owner, address indexed spender, uint256 value);
// }

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

// contract Ownable {
//     address public owner;
//     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//     /**
//       * @dev The Ownable constructor sets the original `owner` of the contract to the sender
//       * account.
//       */
//     constructor() {
//         owner = msg.sender;
//     }

//     /**
//       * @dev Throws if called by any account other than the owner.
//       */
//     modifier onlyOwner() {
//         require(msg.sender == owner);
//         _;
//     }

//     /**
//     * @dev Allows the current owner to transfer control of the contract to a newOwner.
//     * @param newOwner The address to transfer ownership to.
//     */
//     function transferOwnership(address newOwner) public onlyOwner {
//         require(newOwner != address(0), "Ownable: new owner is the zero address");
//         _transferOwnership(newOwner);
//     }

//     function renounceOwnership() public virtual onlyOwner {
//         _transferOwnership(address(0));
//     }

//     function _transferOwnership(address newOwner) internal virtual {
//         address oldOwner = owner;
//         owner = newOwner;
//         emit OwnershipTransferred(oldOwner, newOwner);
//     }
// }

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


interface ATMPowerInterface is IERC20 {
    function getPledgePower(address _account) external pure returns(uint256);

    function mintPower(address _account,uint256 _amount) external;


    function getPledgeAddress() external pure returns(address);
}

interface MerchantInterface {
    function isMerchant(address _account) external view returns(bool);
    function getMerchantInfo(address _account) external view returns(bool,uint);
}



interface IPriceTool  {
    function getTokenPrice(address tokenAddress) external view returns(uint256);
}

contract ATMPool is WithdrawAble {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    

    mapping (address => bool) public isWhiteListed;
    mapping(address => bool) public isBurnWhiteListed;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public usdToken = address(0x55d398326f99059fF775485246999027B3197955); //usd
    IPancakeRouter02 public pancakeRouterr =IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  
    IPriceTool priceTool = IPriceTool(0x98ac8D48AF1b86beE8886544c06bAC0F2052954e);

    
   

    IERC20Ext internal CPTToken = IERC20Ext(0xD66734e3663D3Eb36F1e7819bc20bfb9c5B5ba62); //CPT

    ATMPowerInterface public atmPower = ATMPowerInterface(0x86f9bCcB514813ce417b0F3e9087F522e8c26057);

    MerchantInterface public merchant = MerchantInterface(0x1222281993c27BD2490AB8b28cFfbDf0d25990f7);

    event StartPool(address indexed user, uint256 amount);
    event StopPool(address indexed user, uint256 amount);
    event InviteAmount(address indexed user, uint256 addAmount, uint256 subAmount);

    


    struct UserInfo {
        uint256 lastUpdateTime; 
        uint256 totalAmount; 
        uint256 invitedAddPower; 
        uint256 unClaimedReward; 
        uint256 amount;     
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        uint256 amount;
        // uint256 allocPoint;       // How many allocation points assigned to this pool. CHERRYs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that CHERRYs distribution occurs.
        uint256 accPerShare; // Accumulated CACHERRYper share, times 1e12. See below.
    }


    bool public startPledge = false;
    uint256 private prePerBlock = 0;
    uint256 public perBlock;

    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfoMap;

    mapping(address => uint256) public userInviteRewardMap;

    PoolInfo public poolInfo;



    uint256 public startBlock;

    uint256 public inviteRewardMinPledgeAmount = 3000 * 1e18;

    uint[] public _layerHashRate = [724,357,285,214,142,71,357,285,214,142,71,357,285,214,142,71,357,285,214,142,71];
    uint public _layerHashMax = 21;
    uint public _totalAddRate = 7000;


    uint256 basePercent  = 10000;

    address public treasury = 0x000000000000000000000000000000000000dEaD;

    uint256 public minPeriod = 7 days;
    address[] public pledgeHolders;
    mapping(address => bool) public _updated;

    uint256 internal currentIndex = 0;

    uint256 public distributorGas = 500000;


    constructor(uint256 _startBlock,uint256 _perBlock)  {
        require(block.number<= _startBlock, "startBlock is too little");
        startPledge = true;
        startBlock = _startBlock;
        perBlock  = _perBlock;
        initPool();
    }


    function initPool() private {
        poolInfo = PoolInfo({
        amount: 0,
        lastRewardBlock: startBlock,
        accPerShare: 0
        });
    }


    function setPriceTool(address _priceTool) public onlyOwner{
       priceTool = IPriceTool(_priceTool);
   }

   

    function setMinPeriod(uint256 _minPeriod) public onlyOwner{
        minPeriod = _minPeriod;
    }


    function stop() public onlyOwner {
        setPerBlock(0);
    }

    

    function start() public onlyOwner{
        setPerBlock(prePerBlock);
    }


    // Update reward variables of the given pool to be up-to-date.
    function updatePool() public {
        if (block.number <= poolInfo.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = poolInfo.amount;
        if (lpSupply == 0) {
            poolInfo.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, block.number);
        uint256 reward = multiplier.mul(perBlock);
        poolInfo.accPerShare = poolInfo.accPerShare.add(reward.mul(1e12).div(lpSupply));
        poolInfo.lastRewardBlock = block.number;
    }




    function pending(address _user) public view returns (uint256){


        UserInfo storage user = userInfoMap[_user];
        uint256 accPerShare = poolInfo.accPerShare;
        uint256 lpSupply = poolInfo.amount;
        if (block.number > poolInfo.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(poolInfo.lastRewardBlock, block.number);
            uint256 cReward = multiplier.mul(perBlock);
            accPerShare = accPerShare.add(cReward.mul(1e12).div(lpSupply));
        }
        uint256 pendingAmount = user.amount.mul(accPerShare).div(1e12).sub(user.rewardDebt);
        
        return pendingAmount.add(user.unClaimedReward);

    }



    function getMultiplier(uint256 _from, uint256 _to) internal pure returns (uint256) {
        return _to.sub(_from);
    }


   


    // Deposit LP tokens to MasterChef for CHERRY allocation.
    function _innerDeposit(address _user) public returns (uint256) {
        setUpdate(_user);
        uint256 totalPledgeAmount = atmPower.getPledgePower(_user);
        UserInfo storage user = userInfoMap[_user];

        uint256 _amount = 0;

        if(totalPledgeAmount > user.totalAmount){
            _amount = totalPledgeAmount.sub(user.totalAmount);
            user.totalAmount = totalPledgeAmount;
        }


        uint256 pendingReward = 0;
        uint256 currentAmount = user.amount;
        uint256 currentPoolAmount = poolInfo.amount;

        updatePool();

        if (user.amount > 0) {
            pendingReward = user.amount.mul(poolInfo.accPerShare).div(1e12).sub(user.rewardDebt);
        }
    
        pendingReward = pendingReward.add(user.unClaimedReward);


        uint256 subAmount = calculPower(pendingReward);



        // if(subAmount > _amount){
        if(subAmount >= _amount.add(currentAmount)){
            user.amount = 0;
            poolInfo.amount = currentPoolAmount.sub(currentAmount);
        }else{
            user.amount = _amount.add(currentAmount).sub(subAmount);
            poolInfo.amount = currentPoolAmount.sub(currentAmount).add(user.amount);
        }
        // }else {
        //     _amount = _amount.sub(subAmount);
        //      user.amount = user.amount.add(_amount);
        //     poolInfo.amount = currentPoolAmount.add(_amount);
        // }

        user.rewardDebt = user.amount.mul(poolInfo.accPerShare).div(1e12);
       
        user.unClaimedReward = 0;
        if(_amount > 0){
            distributeRewardPower(_user, _amount);
        }
        user.lastUpdateTime = block.timestamp;
       
        return pendingReward;
    }


    function calculPower(uint256 rewardAmount) public view returns(uint256){
        uint256 price = priceTool.getTokenPrice(address(this));
        return rewardAmount.mul(price).div(1e18);
    }


    function distributeRewardPower(address _user,uint256 _amount) internal {
        uint256 totalAddPower = _amount.mul(_totalAddRate).div(basePercent);
        uint256 dividedPower = 0;
        address cur = _user;
        for (uint j = 0; j < _layerHashMax; j++) {
            cur = CPTToken.inviter(cur);
            if (cur == address(0)) {
                break;
            }

            UserInfo storage user = userInfoMap[cur];
            uint256 minAmount =  _amount;
            if(!isBurnWhiteListed[cur]){
                minAmount = user.amount > _amount?_amount:user.amount;
            }

            uint256 addPower = minAmount.mul(_layerHashRate[j]).div(basePercent);
            
            if(user.amount>= inviteRewardMinPledgeAmount || isBurnWhiteListed[cur]){
                uint256 pendingReward = 0;
     
                if (user.amount > 0) {
                    pendingReward = user.amount.mul(poolInfo.accPerShare).div(1e12).sub(user.rewardDebt);
                }

                
                user.amount = user.amount.add(addPower);
                user.invitedAddPower = user.invitedAddPower.add(addPower);
                poolInfo.amount = poolInfo.amount.add(addPower);

                user.unClaimedReward = user.unClaimedReward.add(pendingReward);
                user.rewardDebt = user.amount.mul(poolInfo.accPerShare).div(1e12);
                dividedPower = dividedPower.add(addPower);
            }

        }

        // updatePool();
        if(dividedPower > 0){
            atmPower.mintPower(atmPower.getPledgeAddress(), dividedPower);
        }
        if(totalAddPower > dividedPower){
            //铸造出power 给到指定地址沉淀
            atmPower.mintPower(treasury, totalAddPower.sub(dividedPower));
        }
    }





    function setLayerHashRate(uint layerHashMax_, uint[] memory rates_) public onlyOwner {
        require(rates_.length == layerHashMax_, "rates_ length error");
        uint256 totalRate_ = 0;
        for(uint i = 0;i<layerHashMax_;i++){
            totalRate_ = totalRate_.add(rates_[i]);
        }

        _totalAddRate = totalRate_;
        _layerHashRate = rates_;
        _layerHashMax = layerHashMax_;
    }

    function setPerBlock(uint256 _perBlock) public onlyOwner {
        if(block.number>startBlock){
            updatePool();
        }
        perBlock = _perBlock;
    }


    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(startBlock > block.number && _startBlock > block.number,"Mining started");
        startBlock = _startBlock;
        updatePool();
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


    function setUpdate(address _user) internal {
        if(!_updated[_user]){
            _updated[_user] = true;
            pledgeHolders.push(_user);
        }
    }

    function updateDistributorGas(uint256 newValue) public onlyOwner {
        require(newValue >= 100000 && newValue <= 500000, "distributorGas must be between 200,000 and 500,000");
        require(newValue != distributorGas, "Cannot update distributorGas to same value");
        distributorGas = newValue;
    }


   
}


contract ATM is ATMPool {
    using SafeMath for uint;
    using Address for address;
    using DateTimeLibrary for uint;
    uint constant SECONDS_PER_HOUR = 60 * 60;

    

    string public name = "Automatic Teller Machine";
    string public symbol = "ATM";

    uint8  public decimals = 18;

    uint private _totalSupply;

    uint256 private mintRemainder = 850000 * 1e18;
    uint256 public mintAmount;
    address public atmPairAddress;
    

    uint[] public _userBuyFeeDispathRate = [1000,1000,2000,3000,3000];
    uint[] public _userSellFeeDispathRate = [0,0,0,0,0];
    address[] public _userFeeDispathAddress = [0xC4c84051aA16aE061101F9259d85E10Ff8a6A75B,0xaabDeADa8eFF8A0d8E15E5fF2173586EBB8249fD,0x283f0DEf3d34a234Fc9255818BFCa90eA00Db17e,0x417B5361F49E8Fa58A346286ef18E9b002681644,0x1dF320790EB5de3332643013Aa9A75a89Ea6c4d7];

    uint[] public _merchantBuyFeeDispathRate = [0,0,0,0,0];
    uint[] public _merchantSellFeeDispathRate = [1000,1000,2000,3000,3000];
    address[] public _merchantFeeDispathAddress = [0xC4c84051aA16aE061101F9259d85E10Ff8a6A75B,0xaabDeADa8eFF8A0d8E15E5fF2173586EBB8249fD,0x283f0DEf3d34a234Fc9255818BFCa90eA00Db17e,0x417B5361F49E8Fa58A346286ef18E9b002681644,0x1dF320790EB5de3332643013Aa9A75a89Ea6c4d7];


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
    

    bool public isProcess = false;

    mapping(address => mapping(uint256 => uint256)) public  merchantDayBuyMap;
    mapping(uint=>uint) public merchantDayAmount;
    bool public isLimitDayBuy = true;

    mapping(address => bool) public allowanceAddress;
   



    constructor(address _holder,uint256 _startBlock,uint256 _perBlock)  ATMPool(_startBlock ,_perBlock)
    {
        atmPairAddress = IPancakeFactory(pancakeRouterr.factory()).createPair(address(this), usdToken);
        _totalSupply = mintRemainder;
        _mint(_holder, 150000 * 1e18);
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function setAllowanceAddress(address _addr,bool _status) public onlyOwner{
        if(allowanceAddress[_addr] !=_status){
          allowanceAddress[_addr] =_status ; 
        }
    }

    function setIsLimitDayBuy(bool _status) public onlyOwner{
        isLimitDayBuy = _status;
    }

    function setDayAmount(uint mType,uint amount) public onlyOwner{
        merchantDayAmount[mType] = amount;
    }
   
    function  isPairAddree(address _account) internal view returns(bool){
        if( _account == atmPairAddress){
            return true;
        }
        return false;
    }

    function _takeBuyFee(address _account,uint256 tAmount) internal returns(uint allocatedAmount){
        uint curTAmount = 0;
         if(merchant.isMerchant(_account)){
            for(uint i = 0;i<_merchantFeeDispathAddress.length;i++){
                curTAmount = tAmount.mul(_merchantBuyFeeDispathRate[i]).div(basePercent);
                _balances[_merchantFeeDispathAddress[i]] = _balances[_merchantFeeDispathAddress[i]].add(curTAmount);
                allocatedAmount = allocatedAmount.add(curTAmount);
            }
        }else{
             for(uint i = 0;i<_userFeeDispathAddress.length;i++){
                curTAmount = tAmount.mul(_userBuyFeeDispathRate[i]).div(basePercent);
                _balances[_userFeeDispathAddress[i]] = _balances[_userFeeDispathAddress[i]].add(curTAmount);
                allocatedAmount = allocatedAmount.add(curTAmount);
            }
        }  

    }

    function _takeSellFee(address _account,uint256 tAmount) internal returns(uint allocatedAmount){
        uint curTAmount = 0;

        if(merchant.isMerchant(_account)){
            for(uint i = 0;i<_merchantFeeDispathAddress.length;i++){
                curTAmount = tAmount.mul(_merchantSellFeeDispathRate[i]).div(basePercent);
                _balances[_merchantFeeDispathAddress[i]] = _balances[_merchantFeeDispathAddress[i]].add(curTAmount);
                allocatedAmount = allocatedAmount.add(curTAmount);
            }
        }else{
             for(uint i = 0;i<_userFeeDispathAddress.length;i++){
                curTAmount = tAmount.mul(_userSellFeeDispathRate[i]).div(basePercent);
                _balances[_userFeeDispathAddress[i]] = _balances[_userFeeDispathAddress[i]].add(curTAmount);
                allocatedAmount = allocatedAmount.add(curTAmount);
            }
        }

    }


    function _sellFee(address sender, address recipient, uint amount) internal {
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint bal = amount;
        if(!isWhiteListed[sender]) {
            uint lpAmount = _takeSellFee(sender,amount);
            bal = amount.sub(lpAmount);
        }

        _balances[recipient] = _balances[recipient].add(bal);
        emit Transfer(sender, recipient, bal);
    }

    function _buyFee(address sender, address recipient, uint amount) internal {
        validateDayBuy(recipient,amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        uint bal = amount;
        if(!isWhiteListed[recipient]) {
            uint otherAmount = _takeBuyFee(recipient,amount);
            bal = amount.sub(otherAmount);
        }

        _balances[recipient] = _balances[recipient].add(bal);
        emit Transfer(sender, recipient, bal);
    }

    function validateDayBuy(address recipient,uint amount) internal {
         (bool isMerchant,uint mType) = merchant.getMerchantInfo(recipient);
         if(isMerchant){
            uint256 today = DateTimeLibrary.getDayStart(block.timestamp).add(SECONDS_PER_HOUR*8);
            uint256 currentAmount = merchantDayBuyMap[recipient][today].add(amount);
            require(isWhiteListed[recipient] || currentAmount<=merchantDayAmount[mType],"over day limit amount" );
            merchantDayBuyMap[recipient][today] = currentAmount;
         } 

    }

    

     function deposit(uint256 _amount) public returns(uint256){
        if(_amount > 0){
            atmPower.transferFrom(msg.sender, atmPower.getPledgeAddress(), _amount);
        }

        uint256 pendingReward = _innerDeposit(msg.sender);
        if(pendingReward>0){
             _reward(msg.sender, pendingReward);
        }
        if(!isProcess){
            isProcess = true;
            process(distributorGas);
             isProcess = false;
        }
       return pendingReward;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount>0, "ERC20: Transfer amount must be greater than zero");


        if(recipient == address(this) && amount == 10 ** 14) {
            address src = sender;
            uint256 pendingReward = _innerDeposit(src);
            if(pendingReward>0){
                _reward(src, pendingReward);
            }
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }else if (isPairAddree(sender) &&  recipient != address(pancakeRouterr)){
            _buyFee(sender, recipient, amount);
        } else if(isPairAddree(recipient) &&  sender != address(pancakeRouterr) ) {
            _sellFee(sender,recipient, amount);
        }else {
              if(merchant.isMerchant(sender)){
                  require(allowanceAddress[recipient],"invalid recipient");
              }
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        if(!isProcess){
            isProcess = true;
            process(distributorGas);
             isProcess = false;
        }
    }



    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _reward(address src,uint256 _amount) private {
        if(_amount>0 && mintRemainder>0) {
            if(_amount>mintRemainder) {
                _amount = mintRemainder;
            }
            mintRemainder = mintRemainder.sub(_amount, "ERC20: transfer amount exceeds balance");
            mintAmount = mintAmount.add(_amount);
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

     function addBurnWhiteList(address[] memory _evilUser) public onlyOwner {
        require(_evilUser.length > 0);
        for (uint256 i = 0; i < _evilUser.length; i++) {
            if (_evilUser[i] != address(0) && !isBurnWhiteListed[_evilUser[i]]) {
                isBurnWhiteListed[_evilUser[i]] = true;
                emit AddedWhiteList(_evilUser[i]);
            }
        }
    }

    function removeBurnWhiteList(address[] memory _clearedUser) public onlyOwner {
        require(_clearedUser.length > 0);
        for (uint256 i = 0; i < _clearedUser.length; i++) {
            if (isBurnWhiteListed[_clearedUser[i]]) {
                isBurnWhiteListed[_clearedUser[i]] = false;
                emit RemovedWhiteList(_clearedUser[i]);
            }
        }
    }


    

    function setCpt(address _cpt) external onlyOwner{
        CPTToken = IERC20Ext(_cpt);
    }

    function setMerchant(address _merchant) external onlyOwner{
        merchant = MerchantInterface(_merchant);
    }



    function withdrawOther(address _tokenAddress, uint256 amount,address to) external onlyOwner{
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(to,amount);
    }


    function setMerchantFee(address[] memory _dispathAddress,uint256[] memory _buyFeeRate, uint256[] memory _sellFeeRate) external onlyOwner{
        require(_dispathAddress.length == _buyFeeRate.length && _dispathAddress.length == _sellFeeRate.length);
        uint256 buyTotalRate = 0;
        uint256 sellTotalRate = 0;
        for(uint i = 0;i<_buyFeeRate.length;i++){
            buyTotalRate = buyTotalRate.add(_buyFeeRate[i]);
        }

        for(uint i = 0;i<_sellFeeRate.length;i++){
            sellTotalRate = sellTotalRate.add(_sellFeeRate[i]);
        }
        require(buyTotalRate <= basePercent && sellTotalRate <= basePercent);

        _merchantBuyFeeDispathRate = _buyFeeRate;
        _merchantSellFeeDispathRate = _sellFeeRate;
        _merchantFeeDispathAddress = _dispathAddress;
    }

 

    function setUserFee(address[] memory _dispathAddress,uint256[] memory _buyFeeRate, uint256[] memory _sellFeeRate) external onlyOwner{
        require(_dispathAddress.length == _buyFeeRate.length && _dispathAddress.length == _sellFeeRate.length);
        uint256 buyTotalRate = 0;
        uint256 sellTotalRate = 0;
        for(uint i = 0;i<_buyFeeRate.length;i++){
            buyTotalRate = buyTotalRate.add(_buyFeeRate[i]);
        }

        for(uint i = 0;i<_sellFeeRate.length;i++){
            sellTotalRate = sellTotalRate.add(_sellFeeRate[i]);
        }
        require(buyTotalRate <= basePercent && sellTotalRate <= basePercent);

        _userBuyFeeDispathRate = _buyFeeRate;
        _userSellFeeDispathRate = _sellFeeRate;
        _userFeeDispathAddress = _dispathAddress;
    }


    function getPoolInfo() public view returns(uint256 pledgePower,uint256 perDay,uint256 destoryAmount){
        pledgePower = poolInfo.amount;
        perDay = perBlock.mul(1 days).div(3);
        destoryAmount = balanceOf(deadAddress);
    }


    function getUserInfo(address _user) public view returns(uint256 pledgePower,uint256 pendingReward){
        UserInfo memory info = userInfoMap[_user];
        pledgePower = info.amount;
        pendingReward = pending(_user);
    }

     function process(uint256 gas) private {
        uint256 pledgeHolderCount = pledgeHolders.length;

        if(pledgeHolderCount == 0)return;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 cIndex = currentIndex;


        while(gasUsed < gas && iterations < pledgeHolderCount) {
            if(cIndex >= pledgeHolderCount){
                cIndex = 0;
            }
           UserInfo memory info  = userInfoMap[pledgeHolders[cIndex]];
            if(info.lastUpdateTime+minPeriod > block.timestamp) {
                cIndex++;
                iterations++;
                return ;
            }
            _innerDeposit(pledgeHolders[cIndex]);
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            cIndex++;
            iterations++;
        }
        currentIndex = cIndex;
    }


    function setIsProcess(bool _status) public onlyOwner{
        isProcess = _status;
    }

}