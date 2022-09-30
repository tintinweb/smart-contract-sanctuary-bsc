/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.6.0 <0.8.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }



    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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

// File: @openzeppelin/contracts/math/SafeMath.sol



pragma solidity >=0.6.0 <0.8.0;

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
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     * 
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity >=0.6.2 <0.8.0;

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
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



pragma solidity >=0.6.0 <0.8.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}




interface IERC721 is IERC165 {
   
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

   
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

   
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

   
    function balanceOf(address owner) external view returns (uint256 balance);

  
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function mint(address to,uint material,uint amount) external;
    function publicMint(address to,uint amount) external;

    function totalSupply() external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);

 
    function setApprovalForAll(address operator, bool _approved) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}


interface Relationship {
    struct Player {
        uint256 id;
        address[] directRecommendAddress;
        address referrer;
    }
    function bind(address user,address _referrerAddress) external;

    function isUserExists(address user) external view returns(bool);

    function getReferralRelationship(address _user) external view returns(Player memory);
}


pragma solidity >=0.6.0 <0.8.0;

contract tokenPool is Ownable ,IERC721Receiver{
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeERC20 for IERC20;

    struct UserInfo {

        mapping(uint8=>uint256) totalAmount;
        mapping(uint8=>uint256) amount;

        mapping(uint8=>uint256) unlockTime;

        mapping(uint8=>uint8)  periodAnnualized;


        mapping(uint8=>uint256) pendingAmount;
        mapping(uint8=>uint256) remainingAmount;
 
    }

    struct PoolInfo {
        address lpToken; // Address of LP or TOKEN token contract.
        uint256 tokenAmount; // Total amount of deposited tokens.
        mapping(uint8=>uint8)  periodAnnualized;

    }

    address public mintTokenAddress;

    // Info of each pool.
    PoolInfo[] public poolInfos;
    mapping(address => uint256) public lpTokenRegistry;

    address public MNMAddress=0xFBA61A45c0364F86fbDF4Ff7177412AA5bFF15b9;
    address public USDTAddress=0x55d398326f99059fF775485246999027B3197955;
    address public relationshipAddress=0xA628FC1EBa896DC70bbEcE2242Cd2f87304f0365;
    address public idoContract;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) userInfo;
    mapping(address => uint256) public realizedReward;

    mapping(address => uint256) public referralRewards;

    // The block number when mintTokenAddress mining starts.
    // Remaining mining amount.
    uint256 public remainingAmount = 0;
    //Bonus muliplier for token makers.

    uint256 public totalMinter;

    uint256 public totalClaim;




    event NewMining(
        address indexed user,
        uint256 amount,
        uint256 start,
        uint256 per
    );
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event WithdrawRemaining(address indexed user, uint256 amount);
    

    constructor(address _token) public {
        mintTokenAddress = _token;
    }


    modifier onlyIDOContract() {
        require(idoContract == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external override returns (bytes4){}


    // ============ Modifiers ============

    modifier lpTokenExist(address _lpToken) {
        require(lpTokenRegistry[_lpToken] > 0, "Mining: LP token not exist");
        _;
    }

    modifier lpTokenNotExist(address _lpToken) {
        require(
            lpTokenRegistry[_lpToken] == 0,
            "Mining: LP token already exist"
        );
        _;
    }

    // ============ Helper ============

    function poolLength() external view returns (uint256) {
        return poolInfos.length;
    }

    function getPid(address _lpToken)
        public
        view
        lpTokenExist(_lpToken)
        returns (uint256)
    {
        return lpTokenRegistry[_lpToken] - 1;
    }

    function getUserLpBalance(address _lpToken, address _user,uint8 _period)
        public
        view
        returns (uint256)
    {
        uint256 pid = getPid(_lpToken);
        return userInfo[pid][_user].amount[_period];
    }


    

    function getUserUnlockTime(address _lpToken, address _user,uint8 _period)
        public
        view
        returns (uint256)
    {
        uint256 pid = getPid(_lpToken);
        
        return userInfo[pid][_user].unlockTime[_period];
    }

    function getUserPeriodAnnualized(address _lpToken, address _user,uint8 _period)
        public
        view
        returns (uint256)
    {
        uint256 pid = getPid(_lpToken);
        return userInfo[pid][_user].periodAnnualized[_period];
    }

    // ============ Ownable ============

    
    function addLpToken(
        address _lpToken
    ) public lpTokenNotExist(_lpToken) onlyOwner {
        require(_lpToken != address(0), "Mining: zero address not allowed");
        poolInfos.push(
            PoolInfo({
                lpToken: _lpToken,
                tokenAmount: 0
            })
        );
        lpTokenRegistry[_lpToken] = poolInfos.length;
    }


    function getRealizedReward(address _user) external view returns (uint256) {
        return realizedReward[_user];
    }


    function setMintTokenAddress(address _addr) public onlyOwner(){
           mintTokenAddress=_addr;
    }

    function setIDOContractAddress(address _addr) public onlyOwner(){
           idoContract=_addr;
    }
    function setPeriod(address _lpToken,uint8 _period,uint8 _annualized)public onlyOwner{
        uint256 pid = getPid(_lpToken);
        PoolInfo storage pool = poolInfos[pid];
        pool.periodAnnualized[_period]=_annualized;
    }
    

    function addPoolAmount(uint256 _tokenAmount) public onlyOwner(){
        uint256 balBefore = IERC20(mintTokenAddress).balanceOf(address(this));
        IERC20(mintTokenAddress).safeTransferFrom(msg.sender, address(this), _tokenAmount);
        uint256 balAfter = IERC20(mintTokenAddress).balanceOf(address(this));
        require(
            balAfter.sub(balBefore) == _tokenAmount,
            "Mining: unexpected balance"
        );
        remainingAmount= remainingAmount.add(_tokenAmount);
    }

    function withdrawRemaining() external onlyOwner {
        if (remainingAmount == 0) {
            return;
        }
        uint256 amt = remainingAmount;
        remainingAmount = 0;
        IERC20(mintTokenAddress).transfer(_msgSender(), amt);
        emit WithdrawRemaining(_msgSender(), amt);
    }


    function getPendingReward(address _lpToken, address _user,uint8 _period)
        public
        view
        returns (uint256)
    {
        uint256 pid = getPid(_lpToken);
        UserInfo storage user = userInfo[pid][_user];
        uint256 returnCount=1;
        uint256 returnAmount;
        if (user.unlockTime[_period]>block.timestamp){
            return 0;
        }
        if (block.timestamp>user.unlockTime[_period]){
            returnCount=returnCount.add((block.timestamp-user.unlockTime[_period]).div(24 hours));
        }
        if (user.totalAmount[_period].mul(1).div(100).mul(returnCount)>user.remainingAmount[_period]){
            returnAmount=user.remainingAmount[_period];
        }else{
            returnAmount=user.totalAmount[_period].mul(1).div(100).mul(returnCount);
        }
        return returnAmount;
    }

    function getRemainingAmount() external view returns (uint256) {
        return remainingAmount;
    }



    // ============ Deposit & Withdraw & Claim ============

    function deposit(address _lpToken, uint256 _amount,uint8 _period,address _referrerAddress) public {     
        require(_amount>=1000*10**18,"deposit amount must >1000");
        uint256 pid = getPid(_lpToken);
        PoolInfo storage pool = poolInfos[pid];
        require(pool.periodAnnualized[_period]!=0,"period does not exist");
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.remainingAmount[_period]==0,"you have pledged");
        Relationship(relationshipAddress).bind(msg.sender,_referrerAddress);
        IERC20(pool.lpToken).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount[_period]=_amount;
        user.periodAnnualized[_period]=pool.periodAnnualized[_period];

        user.unlockTime[_period]=block.timestamp+(86400-block.timestamp%86400);
 
        user.totalAmount[_period]=_amount.add(_amount.mul(user.periodAnnualized[_period]).div(100));
        user.remainingAmount[_period]=user.totalAmount[_period];
        remainingAmount=remainingAmount.sub(_amount.mul(user.periodAnnualized[_period]).div(100)).sub(user.totalAmount[_period].mul(30).div(100));

        require(remainingAmount>0,"Insufficient mining pool quota");

        if (pool.lpToken == mintTokenAddress) {
            pool.tokenAmount = pool.tokenAmount.add(_amount);
        }
        emit Deposit(msg.sender, pid, _amount);
        totalMinter+=1;
    }

    function depositByContract(address player,address _lpToken, uint256 _amount,uint8 _period) public onlyIDOContract{     
        uint256 pid = getPid(_lpToken);
        PoolInfo storage pool = poolInfos[pid];
        require(pool.periodAnnualized[_period]!=0,"period does not exist");
        UserInfo storage user = userInfo[pid][player];
        require(user.remainingAmount[_period]==0,"you have pledged");
        IERC20(pool.lpToken).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount[_period]=_amount;
        user.periodAnnualized[_period]=pool.periodAnnualized[_period];

        user.unlockTime[_period]=block.timestamp+(86400-block.timestamp%86400);
 
        user.totalAmount[_period]=_amount.add(_amount.mul(user.periodAnnualized[_period]).div(100));
        user.remainingAmount[_period]=user.totalAmount[_period];
        remainingAmount=remainingAmount.sub(_amount.mul(user.periodAnnualized[_period]).div(100)).sub(user.totalAmount[_period].mul(30).div(100));

        require(remainingAmount>0,"Insufficient mining pool quota");

        if (pool.lpToken == mintTokenAddress) {
            pool.tokenAmount = pool.tokenAmount.add(_amount);
        }
        emit Deposit(player, pid, _amount);
        totalMinter+=1;
    }


    function claim(address _lpToken,uint8 _period)public {
        uint256 pid = getPid(_lpToken);
        PoolInfo storage pool = poolInfos[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        
        require(user.unlockTime[_period]<block.timestamp&&user.unlockTime[_period]!=0,"unlockTime err");
        uint256 pendingReward=getPendingReward(_lpToken,msg.sender,_period);
        if (pendingReward > 0) {
            safeTOKENTransfer(msg.sender, pendingReward, pool.tokenAmount);
            dividendsToReferrer(msg.sender,pendingReward.mul(30).div(100),pool.tokenAmount,pid,_period);
            user.remainingAmount[_period]=user.remainingAmount[_period].sub(pendingReward);
            if(user.remainingAmount[_period]==0){
                pool.tokenAmount=pool.tokenAmount.sub(user.amount[_period]);
                user.amount[_period]=0;

            }
            user.unlockTime[_period]=block.timestamp+(86400-block.timestamp%86400);
        }
        
    }
    function dividendsToReferrer(address from,uint256 Amount,uint256 poolTokenAmount,uint256 pid,uint8 _period)private{
        uint8 i=1;
        address userAddress=from;
        while (true) {
            address referalAddress=Relationship(relationshipAddress).getReferralRelationship(userAddress).referrer; 
            if (i==9){
                break;
            }
            uint AmountDividend=getAmountDividend(Amount,i);
            if(userInfo[pid][referalAddress].amount[_period]==0){
                safeTOKENTransfer(address(0xdead),AmountDividend,poolTokenAmount);
            }else{
                safeTOKENTransfer(referalAddress,AmountDividend,poolTokenAmount);
            }
            referralRewards[referalAddress] = referralRewards[referalAddress].add(AmountDividend);
            userAddress =referalAddress;
            i++;
        }
    }

    function getAmountDividend(uint256 amount,uint8 i)private pure returns(uint256){
        uint amountDividend;
         if(i==1){
             amountDividend=amount.mul(10).div(30);
         }else if (i==2){
             amountDividend=amount.mul(8).div(30);
         }else if (i==3){
             amountDividend=amount.mul(7).div(30);
         }else if (i==4){
             amountDividend=amount.mul(5).div(30);
         }
         return amountDividend;
    }


    function setRelationshipAddress(address _addr) public onlyOwner{
        relationshipAddress=_addr;
    }

    // Safe TOKEN transfer function, just in case if rounding error causes pool to not have enough TOKEN.
    function safeTOKENTransfer(
        address _to,
        uint256 _amount,
        uint256 _poolTOKENAmount
    ) internal {
        if (_amount==0){
            return;
        }
        uint256 tokenBalance = IERC20(mintTokenAddress).balanceOf(address(this));
        tokenBalance = tokenBalance.sub(_poolTOKENAmount);
        if (_amount > tokenBalance) {
            _amount = tokenBalance;
        }
        IERC20(mintTokenAddress).transfer(_to, _amount);
        realizedReward[_to] = realizedReward[_to].add(_amount);
        emit Claim(_to, _amount);
    }
}