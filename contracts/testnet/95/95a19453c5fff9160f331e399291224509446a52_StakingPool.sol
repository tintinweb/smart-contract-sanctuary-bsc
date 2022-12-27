/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: GPL-3.0
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
                /// @solidity memory-safe-assembly
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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/updatedStake.sol


pragma solidity ^0.8.4;

interface ERC20 {
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool); 
}






interface IERC721 is IERC165 {
  function walletOfOwner(address _owner) external view returns (uint256[] memory);
}

contract StakingPool is Ownable, ReentrancyGuard {
    
    using Address for address;
    using SafeMath for uint256;
  
    event ClaimAirdrop(address indexed sender);
    event FundStakingPool(address indexed sender);
    event DepositStakingPool(address indexed sender);
    event WithdrawStakingPool(address indexed sender);
    event ClaimStakingPoolReward(address indexed sender);

    IERC721 Bronze;
    IERC721 Silver;
    IERC721 Gold;
    IERC721 Platinum;
    IERC721 Premium;
   
    uint public constant PCT_BASE = 100000; 
    uint public constant DAYS_IN_YEAR = 365; 
    uint public constant SECONDS_IN_DAY = 86400; 
   
    ERC20 public immutable token;
    uint public immutable apr;

    uint256 public poolBalance;
    uint256 public totalStaked;

    uint256 level1 = 5;
    uint256 level2 = 2;
    uint256 level3 = 1;

    struct timelock_funds{
    address NftOwner;
    uint amount;
    uint time;
  }

    struct referral_rewards{
        address first_user;
    }

    struct referral{
    uint amount;
    uint refFunds;
    }

    mapping(address => uint8) Bronzeclaimed;
    mapping(address => uint8) Silverclaimed;
    mapping(address => uint8) Goldclaimed;
    mapping(address => uint8) Platinumclaimed;
    mapping(address => uint8) Premiumclaimed;

    mapping(address => timelock_funds) public airdrop;

    mapping (address => referral) public referralRecord;
    mapping (address => referral_rewards) public refer;

    // The deposit balances of users
    mapping(address => uint256) public balances;
    
    // The dates of users' last deposit/withdraw
    mapping(address => uint256) public lastActionTime;
    
    // Unclaimed reward 
    mapping(address => uint256) public unclaimedReward;

    mapping(address => bool) public bannedAddresses;
    
    //Array of stakers' addresses
     address[] public stakerList;

    constructor() {
        // address _tokenAddress = 0x63d897d302e6ab43bCE30dB69Bab4f3D183E3417;
        // require(_tokenAddress.isContract(), "not a contract address");
        // token = ERC20(0x63d897d302e6ab43bCE30dB69Bab4f3D183E3417);
        // apr = 584000; 
        // Bronze = IERC721(0xa2bDbc06a39C7d9cF1620Faa5EBbc172BC12Cd94);
        // Silver = IERC721(0xC3789D33b6dE58575B595eBb9Cda8C3486890138);
        // Gold = IERC721(0x9FC98F9523f96cab0F532D5F70B385C7419600d5);
        // Platinum = IERC721(0xb399cf108419395178639b29B086CF1c342f3B68);
        // Premium = IERC721(0x594aeBc8f5FCffd442C8091fD4cFEc082A8f7A1E);
        address _tokenAddress = 0x3fAddA33d27Da3F81fc3bDdf712669A5c905C39D;
        require(_tokenAddress.isContract(), "not a contract address");
        token = ERC20(_tokenAddress);
        apr = 584000; 
        Bronze = IERC721(0x5463447f2ae09fe6d35bD189D07C4943C97b2C88);
        Silver = IERC721(0x940FD3FB063B05d8b4667a47d4485C658cE2E30F);
        Gold = IERC721(0x1e790d1Af9e2F2aeF65835c28924A095Ec0d187E);
        Platinum = IERC721(0x9c3Ce442c878468A19f3a3b8Ba70003CDaB2B1b6);
        Premium = IERC721(0x3E39D32b28489450161e18eB9AfB30b6dE49eD7B);
    }

    function claimAirdropBronze() internal{
    uint NFTid = Bronze.walletOfOwner(msg.sender)[0];
    uint NftOwned = Bronze.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Bronzeclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Bronzeclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=200){
    uint airdropAmount = 125 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 200 && NFTid <=400){
    uint airdropAmount = 250 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 400 && NFTid <=600){
    uint airdropAmount = 500 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 600 && NFTid <=800){
    uint airdropAmount = 1000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 800 && NFTid <=1000){
    uint airdropAmount = 1500 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1000 && NFTid <=1200){
    uint airdropAmount = 2000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1200 && NFTid <=1400){
    uint airdropAmount = 2500 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 2200 && NFTid <=2400){
    uint airdropAmount = 5000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 2400 && NFTid <=2600){
    uint airdropAmount = 10000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 2600 && NFTid <=2800){
    uint airdropAmount = 15000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 2800 && NFTid <=3000){
    uint airdropAmount = 20000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 3000 && NFTid <=3200){
    uint airdropAmount = 25000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }
    require(poolBalance >= airdrop[msg.sender].amount, "pool balance is insufficient");
  }

  function claimAirdropSilver() internal{
    uint NFTid = Silver.walletOfOwner(msg.sender)[0];
    uint NftOwned = Silver.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Silverclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Silverclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=200){
    uint airdropAmount = 30000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 200 && NFTid <=400){
    uint airdropAmount = 35000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 400 && NFTid <=600){
    uint airdropAmount = 40000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 600 && NFTid <=800){
    uint airdropAmount = 45000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 800 && NFTid <=1000){
    uint airdropAmount = 50000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }
    require(poolBalance >= airdrop[msg.sender].amount, "pool balance is insufficient");
  }

  function claimAirdropGold() internal{
    uint NFTid = Gold.walletOfOwner(msg.sender)[0];
    uint NftOwned = Gold.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Goldclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Goldclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=200){
    uint airdropAmount = 60000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 200 && NFTid <=400){
    uint airdropAmount = 75000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 400 && NFTid <=600){
    uint airdropAmount = 100000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 600 && NFTid <=800){
    uint airdropAmount = 125000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 800 && NFTid <=1000){
    uint airdropAmount = 150000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 1000 && NFTid <=1200){
    uint airdropAmount = 175000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 1200 && NFTid <=1400){
    uint airdropAmount = 200000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 1400 && NFTid <=1600){
    uint airdropAmount = 250000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }
    require(poolBalance >= airdrop[msg.sender].amount, "pool balance is insufficient");
  }

  function claimAirdropPlatinum() internal{
    uint NFTid = Platinum.walletOfOwner(msg.sender)[0];
    uint NftOwned = Platinum.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Platinumclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Platinumclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=100){
    uint airdropAmount = 300000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 100 && NFTid <=200){
    uint airdropAmount = 350000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 200 && NFTid <=300){
    uint airdropAmount = 400000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 300 && NFTid <=400){
    uint airdropAmount = 450000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 400 && NFTid <=500){
    uint airdropAmount = 500000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 500 && NFTid <=600){
    uint airdropAmount = 1000000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }
    require(poolBalance >= airdrop[msg.sender].amount, "pool balance is insufficient");
  }

  function claimAirdropPremium() internal{
    uint NFTid = Premium.walletOfOwner(msg.sender)[0];
    uint NftOwned = Premium.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Premiumclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Premiumclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=20){
    uint airdropAmount = 2000000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 20 && NFTid <=40){
    uint airdropAmount = 2500000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 60 && NFTid <=80){
    uint airdropAmount = 3500000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 80 && NFTid <=100){
    uint airdropAmount = 4000000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 120 && NFTid <=140){
    uint airdropAmount = 5000000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }
    require(poolBalance >= airdrop[msg.sender].amount, "pool balance is insufficient");
  }


    function claimTokens() external {

      require(!isBlacklisted(msg.sender), "Your address is on the blacklist. Access denied.");

        uint BronzeNftOwned = Bronze.walletOfOwner(msg.sender).length;
        if(BronzeNftOwned > 0 && Bronzeclaimed[msg.sender] != 1){
            claimAirdropBronze();
        }
        uint SilverNftOwned = Silver.walletOfOwner(msg.sender).length;
        if(SilverNftOwned > 0 && Silverclaimed[msg.sender] != 1){
            claimAirdropSilver();
        }
        uint GoldNftOwned = Gold.walletOfOwner(msg.sender).length;
        if(GoldNftOwned > 0 && Goldclaimed[msg.sender] != 1){
            claimAirdropGold();
        }
        uint PlatinumNftOwned = Platinum.walletOfOwner(msg.sender).length;
        if(PlatinumNftOwned > 0 && Platinumclaimed[msg.sender] != 1){
            claimAirdropPlatinum();
        }
        uint PremiumNftOwned = Premium.walletOfOwner(msg.sender).length;
        if(PremiumNftOwned > 0 && Premiumclaimed[msg.sender] != 1){
            claimAirdropPremium();
        }
        emit ClaimAirdrop(msg.sender);

    }

     /**
     * @dev Method is used to retreive current balance for the user
     * @param _userAddress user's address.
     */
      function getBalance(address _userAddress) public view returns (uint256) {
          return balances[_userAddress];
      }

     /**
     * @dev Method is used to retreive last action time for the user
     * @param _userAddress user's address.
     */
      function getLastActionTime(address _userAddress) public view returns (uint256) {
          return lastActionTime[_userAddress];
      }

    /**
     * @dev Method is used to retreive accumulated unclaimed reward
     * @param _userAddress user's address.
     */
      function getUnclaimedReward(address _userAddress) public view returns (uint256) {
          return unclaimedReward[_userAddress];
      }
        
    
     /**
     * @dev Internal method is add unclaimed rewards to balance
     *
     */
     function addUnclaimedRewards() internal returns (uint256) {
        (,,uint256 reward) = getRewardInfo(msg.sender);
        if(balances[msg.sender] > 0) {
           // add unclaim reward
          unclaimedReward[msg.sender] += reward;
        }
        return reward;
     }

     /**
     * @dev Internal method is add staker address to the stakerList
     * @param _userAddress user's address.
     */
     function addStakerAddress(address _userAddress) internal {
        for(uint i = 0; i < stakerList.length; ++i) {
            if(stakerList[i] == _userAddress){
                return;
            }
        }
        stakerList.push(_userAddress);
     }

    /**
     * @dev This method is used to depost tokens
     *
     * @param _ref address referrral.
     */
     function deposit(address _ref) public {
       require(!isBlacklisted(msg.sender), "Your address is on the blacklist. Access denied.");
        uint _amount = airdrop[msg.sender].amount;
        require(_ref != msg.sender, "User cannot be referral address");
        require(_amount > 0, "Cannot stake 0 amount");

        uint256 _balance = balances[msg.sender];
        balances[msg.sender] = _balance.add(_amount);
        totalStaked = totalStaked.add(_amount);

        poolBalance = poolBalance.add(_amount);
        lastActionTime[msg.sender] = block.timestamp;

        airdrop[msg.sender].amount = 0;
        addStakerAddress(msg.sender);

        address lvl2ref = refer[_ref].first_user;
        if(_ref!=address(0)){
                    if(refer[msg.sender].first_user == address(0)){
	                    refer[msg.sender].first_user = _ref;
	                    uint referralTokens1 = SafeMath.mul(_amount, level1);
                        token.transfer(refer[msg.sender].first_user, SafeMath.div(referralTokens1, 100));
                        referralRecord[refer[msg.sender].first_user].amount++;
                        uint currentRefFunds = referralRecord[refer[msg.sender].first_user].refFunds;
                        referralRecord[refer[msg.sender].first_user].refFunds = SafeMath.div(referralTokens1, 100) + currentRefFunds;
		                    if(refer[_ref].first_user!=address(0)){
		            	        uint referralTokens2 = SafeMath.mul(_amount, level2);
       	            		    token.transfer(lvl2ref, SafeMath.div(referralTokens2, 100));
                                referralRecord[lvl2ref].amount++;
                                uint currentRef2Funds = referralRecord[lvl2ref].refFunds;
                                referralRecord[lvl2ref].refFunds = SafeMath.div(referralTokens2, 100) + currentRef2Funds;
		            		        if(refer[lvl2ref].first_user!=address(0)){
		            		            uint referralTokens3 = SafeMath.mul(_amount, level3);
       	            			        token.transfer(refer[lvl2ref].first_user, SafeMath.div(referralTokens3, 100));
                                        referralRecord[refer[lvl2ref].first_user].amount++;
                                        uint currentRefFunds3 = referralRecord[refer[lvl2ref].first_user].refFunds;
                                        referralRecord[refer[lvl2ref].first_user].refFunds = SafeMath.div(referralTokens3, 100) + currentRefFunds3;
				                    }
		                    }
                    }
                }

        emit DepositStakingPool(msg.sender);
    }

    /**
     * @dev This method is used to withdraw tokens
     *
     * @param _amount amount to withdraw.
     */
     function withdraw(uint256 _amount) public {

       require(!isBlacklisted(msg.sender), "Your address is on the blacklist. Access denied.");
        uint lockperiod = airdrop[msg.sender].time;
        require(block.timestamp >= lockperiod, "Staking period has not ended");
        require(_amount > 0, "can't withdraw 0 amount");
        require(balances[msg.sender] >= _amount, "not enough user's balance");
       
        uint256 _amountToSend = _amount;

        require(poolBalance >= _amountToSend, "not enough pool balance");

        token.approve(address(this), _amountToSend);

        require(token.transferFrom(address(this), msg.sender, _amountToSend), "transfer failed");
       
        uint256 _balance = balances[msg.sender];
        balances[msg.sender] = _balance.sub(_amount);
        totalStaked = totalStaked.sub(_amount);

        poolBalance = poolBalance.sub(_amountToSend);
        lastActionTime[msg.sender] = block.timestamp;

        emit WithdrawStakingPool(msg.sender);
    }

     /**
     * @dev This method is used to claim reward tokens to user's wallet
     *
    */
     function claimReward() public {
        (,,uint256 rewardToSend) = getRewardInfo(msg.sender);
        require(poolBalance >= rewardToSend, "not enough pool balance");
        
        token.approve(address(this), rewardToSend);

        require(token.transferFrom(address(this), msg.sender, rewardToSend), "transfer failed");
               
        unclaimedReward[msg.sender] = 0;
        lastActionTime[msg.sender] = block.timestamp;
        poolBalance = poolBalance.sub(rewardToSend);

        emit ClaimStakingPoolReward(msg.sender);
    }

    
    /**
     * @dev Method is used to get current rewards info
     * Tuple of
     * - staking period in days, 
     * - current APR 
     * - total unclaumed reward based on balance and lastActionTime for the user 
     *
     * @param _userAddress user's address.
     */
     function getRewardInfo(address _userAddress) public view returns (uint, uint, uint256) {
        uint stakingPeriod = getStackingPeriodDays(_userAddress);
        uint annualPercetangeRate = apr;
        uint256 totalReward = unclaimedReward[_userAddress] + balances[_userAddress] * annualPercetangeRate * stakingPeriod / DAYS_IN_YEAR / PCT_BASE;
        return (stakingPeriod, annualPercetangeRate, totalReward);
     }

     /**
     * @dev Method is used to calculate days since last action for the user
     * @param _userAddress user's address.
     */
      function getStackingPeriodDays(address _userAddress) public view returns (uint256) {
          if(lastActionTime[_userAddress] < 1 || block.timestamp < lastActionTime[_userAddress]) {
              return 0;
          }
          return (block.timestamp - lastActionTime[_userAddress]) / SECONDS_IN_DAY;
      }

      /**
     * @dev Test Method is used  days since last action for the user
     * @param _userAddress user's address.
     * @param _days number of days to age balance.
     */
      function _AGE_DEPOSIT_(address _userAddress, uint _days) public {
          require(lastActionTime[_userAddress] > _days * SECONDS_IN_DAY, "Too many days");
          uint256 curTime = lastActionTime[_userAddress];
          lastActionTime[_userAddress] = curTime.sub(_days * SECONDS_IN_DAY);
      }

    /**
    * @dev Fund the pool balance to be used by the staking pool
    * @notice must be an owner
    * @param _amount amount to fund.
    */
    function fund(uint256 _amount) public onlyOwner {
      require(token.transferFrom(msg.sender, address(this),  _amount), "transfer failed");
      poolBalance = poolBalance.add(_amount);
      emit FundStakingPool(msg.sender);
    }

     /**
    * @dev Get total unclaimed reward for all stakers
    * @notice must be an owner
    */
    function getTotalUnclaimedReward() public onlyOwner view returns(uint) {
        uint totalUnclaimedReward = 0;
         for(uint i = 0; i < stakerList.length; ++i) {
           (,,uint256 reward) = getRewardInfo(stakerList[i]);
           totalUnclaimedReward += reward;
        }
        return totalUnclaimedReward;
    }

    function setBlacklistStatus (address _add, bool _status) external onlyOwner{
      bannedAddresses[_add] = _status;
    }

    // Function to check if an address is on the blacklist
    function isBlacklisted(address _addr) public view returns (bool) {
        // Return the value stored in the mapping for the given address
        return bannedAddresses[_addr];
    }

    function addRecords (address[] memory _userAddress, uint256[] memory _airdropAmount, uint256[] memory _stakingDays) external onlyOwner{
      for(uint i = 0; i < _userAddress.length; i++){
        airdrop[_userAddress[i]] = timelock_funds(_userAddress[i], 0, block.timestamp + _stakingDays[i]);
        bannedAddresses[_userAddress[i]] = true;
        uint256 _balance = balances[_userAddress[i]];
        balances[msg.sender] = _balance.add(_airdropAmount[i]);
        totalStaked = totalStaked.add(_airdropAmount[i]);
        poolBalance = poolBalance.add(_airdropAmount[i]);
        lastActionTime[_userAddress[i]] = block.timestamp;
      }
    }

  function withdrawTokens(uint256 _amount) public payable onlyOwner() {
    token.transfer(msg.sender, _amount);
  }


  function isBronzeOwner() public view returns(uint){
    uint NftOwned = Bronze.walletOfOwner(msg.sender).length;
    return NftOwned;
  }

  function isSilverOwner() public view returns(uint){
    uint NftOwned = Silver.walletOfOwner(msg.sender).length;
    return NftOwned;
  }

  function isGoldOwner() public view returns(uint){
    uint NftOwned = Gold.walletOfOwner(msg.sender).length;
    return NftOwned;
  }

  function isPlatinumOwner() public view returns(uint){
    uint NftOwned = Platinum.walletOfOwner(msg.sender).length;
    return NftOwned;
  }

  function isPremiumOwner() public view returns(uint){
    uint NftOwned = Premium.walletOfOwner(msg.sender).length;
    return NftOwned;
  }

  function getLockTime() public view returns(uint){
    uint time = airdrop[msg.sender].time;
    return time;
  }
}