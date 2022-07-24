/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
        * @dev Returns the remaining number of tokens that `spender` will be
        * allowed to spend on behalf of `owner` through {transferFrom}. This is
        * zero by default.
        *
        * This value changes when {approve} or {transferFrom} are called.
        */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        *
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
        *
        * - The divisor cannot be zero.
        */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(address(msg.sender));
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
    * @dev Collection of functions related to the address type
    */
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
        assembly { codehash := extcodehash(account) }
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
        * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
        * `errorMessage` as a fallback revert reason when `target` reverts.
        *
        * _Available since v3.1._
        */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
        * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
        * with `errorMessage` as a fallback revert reason when `target` reverts.
        *
        * _Available since v3.1._
        */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/**
    * @dev Contract module which provides a basic access control mechanism, where
    * there is an account (an owner) that can be granted exclusive access to
    * specific functions.
    *
    * By default, the owner account will be the one that deploys the contract. This
    * can later be changed with {transferOwnership}.
    *
    * This module is used through inheritance. It will make available the modifier
    * `onlyOwner`, which can be applied to your functions to restrict their use to
    * the owner.
    */
abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    bool private _isOwnershipRenounced = false;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event NewDelay(uint256 indexed newDelay);

    /**
        * @dev Initializes the contract setting the deployer as the initial owner.
        */
    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
        * @dev Returns the address of the current owner.
        */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
        * @dev Throws if called by any account other than the owner.
        */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    /**
        * @dev Transfers ownership of the contract to a new account (`newOwner`).
        * Can only be called by the current owner.
        */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
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

contract testCoin31 is Context, IERC20, Ownable{
    using SafeMath for uint256;

    string public _name;
    string public _symbol;
    uint8 private _decimals;
    uint256 public _totalSupply;
    uint256 public _maxTotalSupply;
    bool public executeAirDrop = false;

    // uint256 private mounth = 2592000;
    uint256 private mounth = 600;

    uint8 private numberOfSeedPayouts = 0;
    uint8 private numberOfPrivate1Payouts = 0;
    uint8 private numberOfPrivate2Payouts = 0;
    uint8 private numberOfMarketingPayouts = 0;
    uint8 private numberOfFutureDevelopPayouts = 0;
    uint8 private numberOfTeamPayouts = 0;
    uint8 private numberOfAdvisorPayouts = 0;
    uint8 private numberOfStakingPayouts = 0;

    uint8 private maxNumberOfSeedPayouts = 12;
    uint8 private maxNumberOfPrivate1Payouts = 12;
    uint8 private maxNumberOfPrivate2Payouts = 12;
    uint8 private maxNumberOfMarketingPayouts = 24;
    uint8 private maxNumberOfFutureDevelopPayouts = 36;
    uint8 private maxNumberOfTeamPayouts = 24;
    uint8 private maxNumberOfAdvisorPayouts = 12;
    uint8 private maxNumberOfStakingPayouts = 1;

    uint private unlockSeed = block.timestamp + (19 * mounth);
    uint private unlockPrivate1 = block.timestamp + (19 * mounth);
    uint private unlockPrivate2 = block.timestamp + (7 * mounth);
    uint private unlockMarketing = block.timestamp + (7 * mounth);
    uint private unlockFutureDevelop = block.timestamp + (7 * mounth);
    uint private unlockTeam = block.timestamp + (25 * mounth);
    uint private unlockAdvisor = block.timestamp + (13 * mounth);
    uint private unlockStaking = block.timestamp + (6 * mounth);


    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint)) allowed;

    // address tokenOwner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    address private tokenOwner = 0x64D8a090f97512fb9bF77A919051a488514A796C;

    address private seed1=0x9456df6ed44d485b51CECe8A22c6F65eb5b2e43e;
    address private seed2=0x0e33ed7166C15eDD80D8Bcc65a0c7454a0C929d0;

    address private private1_1 = 0x64633266095CA7BdA1da3b4f648f5313A1d4b880;
    address private private1_2 = 0x4c3c3019F3BBbf7162Ae23981063e450e12280AC;
    address private private1_3 = 0xE07b751Bab9E6f18fe6f5B672668D3542FA0fbd5;
    address private private1_4 = 0x1615A50d837DbdC34afF2415Cc1Ca7B53278F26B;
    address private private1_5 = 0x4687BD5917f31acf638802508e97182F6D7C6809;

    address private private2_1 = 0x6bE641627465A8a2Fc64420cD2e0206c3D36D5B2;
    address private private2_2 = 0xc14b3311811F7C1F6b2706B24362CD5851Af0A89;
    address private private2_3 = 0xd499ACD127497BF2601B741C276D30Ec01aEdb32;
    address private private2_4 = 0xAa2759B9d7FdD0cdb7A63c769b16459Ffef9F37d;
    address private private2_5 = 0x3a5f98526e3eD4D3862dd4C136ae8dD4f379d196;
    address private private2_6 = 0xF4f02Ce2285929043af4B4050171a1EF685e21F1;
    address private private2_7 = 0xEbded3Ee3e9FD4477064fa964b4034A8799ABb50;
    address private private2_8 = 0xC6223c6b74103918Eb7bFc726D8b9F5C74d18B9E;
    address private private2_9 = 0x7Ec4ea066DeFBe83C04F2a77ECafdc0b0E6B6dbd;
    address private private2_10 = 0x8b8afA04fc297Cb83c7a90DE6eD737b4D2235727;
    address private private2_11 = 0x314d37000ff07478A1d51ABf3750c71aA72309f8;
    address private private2_12 = 0x58BBE4429f4B0bf4Da9Be459316e8e8Fa9859973;
    address private private2_13 = 0x0354eB8B75f7D2737894A1f4d0Fc8Daba7Fd3cdd;
    address private private2_14 = 0xDFbE0333A1DF91C782bC527e4E34660270f548CE;

    address private liquidity = 0x6B85c25bb839862baa609199c306d29a9727cdeD;

    address private marketing = 0xA48593E9EA20d8630974B3F143f04b92B685bCbD;

    address private futureDevelop = 0xEDb0958fE33A29Ba4a08e0A261EBd247A54667E3;

    address private team = 0xB6d627A6F39E12fC33855bB7d7657399fD6FBC3d;

    address private advisor = 0x3298D245fEF3304F00F225590A88fE6BD7a6e13b;

    address private staking = 0x91445b1227Cf0a09A01efB05704b0629dD4E406e;

    IPancakeRouter02 public immutable pcsV2Router;
    address public immutable pcsV2Pair;

    address public router = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BSC TestNet

    constructor () {
        // Initialization. Start
        _name = "TestTelegramToken31"; // Token name
        _symbol = "TTTE31"; // Token symbol
        _decimals = 18;
        _maxTotalSupply = uint256(1000000000 * 10**_decimals);

        _totalSupply = 0;

        mint(liquidity, 17000000);
        

        IPancakeRouter02 _pcsV2Router = IPancakeRouter02(router);
        pcsV2Pair = IPancakeFactory(_pcsV2Router.factory()).createPair(address(this), _pcsV2Router.WETH());
        pcsV2Router = _pcsV2Router;
       

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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if(balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            balances[recipient] += amount;
            Transfer(msg.sender, recipient, amount);
            return true;
        }
        return false;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if(balances[sender] >= amount && balances[recipient] + amount >= balances[recipient]) {
            balances[sender] -= amount; 
            balances[recipient] += amount;
            Transfer(sender, recipient, amount);
            return true;
        } 
        return false;
    }

    function mint(address recipient, uint256 amount) private {
        balances[recipient] += uint256(amount * 10**_decimals);
        _totalSupply += uint256(amount * 10**_decimals);
        Transfer(address(this), recipient, amount * 10**_decimals);
    }

    function burn(uint256 amount) public {
        if (balances[msg.sender] >= uint256(amount * 10**_decimals)) {
            balances[msg.sender] -= uint256(amount * 10**_decimals);
            balances[address(0)] += uint256(amount * 10**_decimals);
            Transfer(msg.sender, address(0), amount * 10**_decimals);
            _totalSupply -= uint256(amount * 10**_decimals);
        } else {
            balances[address(0)] += balances[msg.sender];
            Transfer(msg.sender, address(0), balances[msg.sender]);
            _totalSupply -= balances[msg.sender];
            balances[msg.sender] = 0;
        }
    }



    function makeAirDrop(address [] memory airDropAddress) public onlyOwner mAirDrop() {
        uint amountAirDrop = 3000000 / airDropAddress.length;
        executeAirDrop = true;
        for(uint i = 0; i < airDropAddress.length; i++){
            mint(airDropAddress[i], amountAirDrop);
        }
    }

    function paySeed() public paymentCondition(maxNumberOfSeedPayouts, numberOfSeedPayouts, unlockSeed){
        mint(seed1, 1250000);
        mint(seed2, 1250000);
        numberOfSeedPayouts += 1;
        unlockSeed += mounth;
    }

    function payPrivate1() public paymentCondition(maxNumberOfPrivate1Payouts, numberOfPrivate1Payouts, unlockPrivate1){
        mint(private1_1, 833333);
        mint(private1_2, 833333);
        mint(private1_3, 833333);
        mint(private1_4, 833333);
        mint(private1_5, 833333);
        numberOfPrivate1Payouts += 1;
        unlockPrivate1 += mounth;
    }

    function payPrivate2() public paymentCondition(maxNumberOfPrivate2Payouts, numberOfPrivate2Payouts, unlockPrivate2){
        mint(private2_1, 416666);
        mint(private2_2, 416666);
        mint(private2_3, 416666);
        mint(private2_4, 416666);
        mint(private2_5, 416666);
        mint(private2_6, 416666);
        mint(private2_7, 416666);
        mint(private2_8, 416666);
        mint(private2_9, 416666);
        mint(private2_10, 416666);
        mint(private2_11, 416666);
        mint(private2_12, 416666);
        mint(private2_13, 416666);
        mint(private2_14, 416666);
        numberOfPrivate2Payouts += 1;
        unlockPrivate2 += mounth;
    }

    function payMarketing() public paymentCondition(maxNumberOfMarketingPayouts, numberOfMarketingPayouts, unlockMarketing){
        mint(marketing, 6250000);
        numberOfMarketingPayouts += 1;
        unlockMarketing += mounth;
    }

    function payFutureDevelop() public paymentCondition(maxNumberOfFutureDevelopPayouts, numberOfFutureDevelopPayouts, unlockFutureDevelop){
        mint(futureDevelop, 9722222);
        numberOfFutureDevelopPayouts += 1;
        unlockFutureDevelop += mounth;
    }

    function payTeam() public paymentCondition(maxNumberOfTeamPayouts, numberOfTeamPayouts, unlockTeam){
        mint(team, 4166666);
        numberOfTeamPayouts += 1;
        unlockTeam += mounth;
    }

    function payAdvisor() public paymentCondition(maxNumberOfAdvisorPayouts, numberOfAdvisorPayouts, unlockAdvisor){
        mint(advisor, 2500000);
        numberOfAdvisorPayouts += 1;
        unlockAdvisor += mounth;
    }

    function payStaking() public paymentCondition(maxNumberOfStakingPayouts, numberOfStakingPayouts, unlockStaking){
        mint(staking, 200000000);
        numberOfStakingPayouts += 1;
        unlockStaking += mounth;
    }

    modifier paymentCondition(uint maxNumberOfPayouts, uint numberOfPayouts, uint time) {
        if (numberOfPayouts == 0) {
           require(block.timestamp >=time, "vesting");
        }
        require(block.timestamp >= time, "Transfer will be available later.");
        require(numberOfPayouts <= maxNumberOfPayouts, "Transfer has already been made.");
        _;
    }

    modifier mAirDrop() {
        require(executeAirDrop == false, "Transfer has already been made.");
        _;
    }

}