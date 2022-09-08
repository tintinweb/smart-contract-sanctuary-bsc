/**
 *Submitted for verification at BscScan.com on 2022-09-07
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

// File: contracts/Stakepool.sol


pragma solidity ^0.8.4;




interface ERC20 {
  function balanceOf(address owner) external view returns (uint);
  function allowance(address owner, address spender) external view returns (uint);
  function approve(address spender, uint value) external returns (bool);
  function transfer(address to, uint value) external returns (bool);
  function transferFrom(address from, address to, uint value) external returns (bool); 
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
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function walletOfOwner(address _owner) external view returns (uint256[] memory);
  
} 


abstract contract ReentrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract StakingPool is Ownable, ReentrancyGuard {
    
    using Address for address;
    using SafeMath for uint256;
   // using SafeERC20 for IERC20;
  
    /**
     * @dev Emitted when funding Staking Pool balance.
     * @param sender address of the funder
     * @param amount amount of token sent
     * @param poolBalance current pool balance.
     */
    event FundStakingPool(address sender, uint256 amount, uint256 poolBalance);

     /**
     * @dev Emitted when deposit Staking Pool.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event DepositStakingPool(address sender, uint256 depositBalance, uint256 rewardInfo);

     /**
     * @dev Emitted when withdraw Staking Pool.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event WithdrawStakingPool(address sender, uint256 depositBalance, uint256 rewardInfo);

     /**
     * @dev Emitted when Claiming Staking Pool Reward.
     * @param sender address of the deposit sender
     * @param depositBalance current deposit balance
     * @param rewardInfo current reward info.
     */
    event ClaimStakingPoolReward(address sender, uint256 depositBalance, uint256 rewardInfo);


    IERC721 Bronze;
    IERC721 Silver;
    IERC721 Gold;
    IERC721 Platinum;
    IERC721 Premium;
   
    uint public constant PCT_BASE = 100000; 
    uint public constant DAYS_IN_YEAR = 365; 
    uint public constant SECONDS_IN_DAY = 86400; 
   
    ERC20 public immutable token;
    uint public immutable aprLevel1;

    uint256 public feesPool;
    uint256 public poolBalance;
    uint256 public totalStaked;

    struct timelock_funds{
    address NftOwner;
    uint amount;
    uint time;
  }

    struct referral{
    address ref;
    uint amount;
    uint refFunds;
    }

    struct refferal_withdraw {
    address ref_address;
    uint256 totalWithdraw;
    }

    mapping(address => uint8) public Bronzeclaimed;
    mapping(address => uint8) public Silverclaimed;
    mapping(address => uint8) public Goldclaimed;
    mapping(address => uint8) public Platinumclaimed;
    mapping(address => uint8) public Premiumclaimed;

    mapping(address => timelock_funds) public airdrop;
    mapping(address => refferal_withdraw) public refTotalWithdraw;
    mapping(address => referral) public refer;
    // The deposit balances of users
    mapping(address => uint256) public balances;
    
    // The dates of users' last deposit/withdraw
    mapping(address => uint256) public lastActionTime;
    
    // Unclaimed reward 
    mapping(address => uint256) public unclaimedReward;
    
    //Array of stakers' addresses
     address[] public stakerList;

    

    /**
     * @dev Staking Pool constructor
     * @param _tokenAddress  contract address of the token used for stacking
     */



    constructor(address _tokenAddress, address _NFTBronze, address _NFTSilver, address _NFTGold, address _NFTPlatinum, address _NFTPremium) {
        Bronze = IERC721(_NFTBronze);
        Silver = IERC721(_NFTSilver);
        Gold = IERC721(_NFTGold);
        Platinum = IERC721(_NFTPlatinum);
        Premium = IERC721(_NFTPremium);
        require(_tokenAddress.isContract(), "not a contract address");
        token = ERC20(_tokenAddress);
        aprLevel1 = 576000;  
    }


    function claimAirdropBronze() internal{
    uint NFTid = Bronze.walletOfOwner(msg.sender)[0];
    uint NftOwned = Bronze.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Bronzeclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Bronzeclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=200){
    uint airdropAmount = 25 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 200 && NFTid <=400){
    uint airdropAmount = 50 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 400 && NFTid <=600){
    uint airdropAmount = 100 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 600 && NFTid <=800){
    uint airdropAmount = 200 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 800 && NFTid <=1000){
    uint airdropAmount = 300 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1000 && NFTid <=1200){
    uint airdropAmount = 400 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1200 && NFTid <=1400){
    uint airdropAmount = 500 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1400 && NFTid <=1600){
    uint airdropAmount = 1000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1600 && NFTid <=1800){
    uint airdropAmount = 2000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 1800 && NFTid <=2000){
    uint airdropAmount = 3000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 2000 && NFTid <=2200){
    uint airdropAmount = 4000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

    if(NFTid > 2200 && NFTid <=2400){
    uint airdropAmount = 5000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 160 days);
    }

  }

  function claimAirdropSilver() internal{
    uint NFTid = Silver.walletOfOwner(msg.sender)[0];
    uint NftOwned = Silver.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Silverclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Silverclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=200){
    uint airdropAmount = 6000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 200 && NFTid <=400){
    uint airdropAmount = 7000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 400 && NFTid <=600){
    uint airdropAmount = 8000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 600 && NFTid <=800){
    uint airdropAmount = 9000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }

    if(NFTid > 800 && NFTid <=1000){
    uint airdropAmount = 10000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 150 days);
    }
  }

  function claimAirdropGold() internal{
    uint NFTid = Gold.walletOfOwner(msg.sender)[0];
    uint NftOwned = Gold.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Goldclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Goldclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=200){
    uint airdropAmount = 12000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 200 && NFTid <=400){
    uint airdropAmount = 15000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 400 && NFTid <=600){
    uint airdropAmount = 20000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 600 && NFTid <=800){
    uint airdropAmount = 25000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 800 && NFTid <=1000){
    uint airdropAmount = 30000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 1000 && NFTid <=1200){
    uint airdropAmount = 35000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 1200 && NFTid <=1400){
    uint airdropAmount = 40000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }

    if(NFTid > 1400 && NFTid <=1600){
    uint airdropAmount = 50000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 140 days);
    }
  }

  function claimAirdropPlatinum() internal{
    uint NFTid = Platinum.walletOfOwner(msg.sender)[0];
    uint NftOwned = Platinum.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Platinumclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Platinumclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=100){
    uint airdropAmount = 60000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 100 && NFTid <=200){
    uint airdropAmount = 70000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 200 && NFTid <=300){
    uint airdropAmount = 80000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 300 && NFTid <=400){
    uint airdropAmount = 90000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 400 && NFTid <=500){
    uint airdropAmount = 100000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 500 && NFTid <=600){
    uint airdropAmount = 200000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }
  }

  function claimAirdropPremium() internal{
    uint NFTid = Premium.walletOfOwner(msg.sender)[0];
    uint NftOwned = Premium.walletOfOwner(msg.sender).length;
    require(NftOwned > 0, "Not owned NFT from NFT collection");
    require(Premiumclaimed[msg.sender] != 1, "Already claimed your airdrop");
    Premiumclaimed[msg.sender] = 1;

    //AIRDROP TOKENS TO USER THAT IS LOCKED 
    if(NFTid > 0 && NFTid <=20){
    uint airdropAmount = 400000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 20 && NFTid <=40){
    uint airdropAmount = 500000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 40 && NFTid <=60){
    uint airdropAmount = 700000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 60 && NFTid <=80){
    uint airdropAmount = 800000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }

    if(NFTid > 80 && NFTid <=100){
    uint airdropAmount = 1000000 *10**18;
    uint currentAmount = airdrop[msg.sender].amount;
    airdrop[msg.sender] = timelock_funds(msg.sender, SafeMath.add(airdropAmount, currentAmount), block.timestamp + 130 days);
    }
  }


    function claimAirdrop() external {

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
     */
     function deposit(address _ref) public {
        uint _amount = airdrop[msg.sender].amount;
        uint256 reward = addUnclaimedRewards();
        uint256 _balance = balances[msg.sender];
        balances[msg.sender] = _balance.add(_amount);
        totalStaked = totalStaked.add(_amount);
        poolBalance = poolBalance.add(_amount);
        lastActionTime[msg.sender] = block.timestamp;
        airdrop[msg.sender].amount = 0;
        addStakerAddress(msg.sender);


        uint256 refTimes = refer[_ref].amount;
        if(refTimes >= 0 && refTimes <= 5){
        uint val = SafeMath.mul(_amount, 7);
        refer[_ref].refFunds = SafeMath.div(val, 100);
        refer[_ref].amount++;
        }
        else if(refTimes > 5 && refTimes <= 10){
        uint val = SafeMath.mul(_amount, 4);
        refer[_ref].refFunds = SafeMath.div(val, 100);
        refer[_ref].amount++;
        } 
        else if(refTimes >10){
        uint val = SafeMath.mul(_amount, 2);
        refer[_ref].refFunds = SafeMath.div(val, 100);
        refer[_ref].amount++;
        }

        emit DepositStakingPool(msg.sender, balances[msg.sender], reward);
    }

    function depositPostStaking (uint256 _amount) public {
        require(token.transferFrom(msg.sender, address(this), _amount), "transfer failed");
        
        uint256 reward = addUnclaimedRewards();

        uint256 _balance = balances[msg.sender];
        balances[msg.sender] = _balance.add(_amount);
        totalStaked = totalStaked.add(_amount);

        poolBalance = poolBalance.add(_amount);
        lastActionTime[msg.sender] = block.timestamp;

        addStakerAddress(msg.sender);

        emit DepositStakingPool(msg.sender, balances[msg.sender], reward);
    }


    /**
     * @dev This method is used to withdraw tokens
     *
     */
     function withdraw() public {
        uint currentTime = airdrop[msg.sender].time;
        uint _amount = balances[msg.sender];
        uint _lockTime = currentTime;
        require(_amount > 0, "can't withdraw 0 amount");
        require(block.timestamp >= _lockTime, "Staking period has not ended");
        require(balances[msg.sender] >= _amount, "not enough user's balance");
        require(poolBalance >= _amount, "not enough pool balance");

        token.approve(address(this), _amount);

        require(token.transferFrom(address(this), msg.sender, _amount), "transfer failed");

        uint256 reward = addUnclaimedRewards();
       
        balances[msg.sender] = 0;
        totalStaked = totalStaked.sub(_amount);
        poolBalance = poolBalance.sub(_amount);

        lastActionTime[msg.sender] = block.timestamp;

        emit WithdrawStakingPool(msg.sender, balances[msg.sender], reward);
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

        emit ClaimStakingPoolReward(msg.sender, balances[msg.sender], rewardToSend);
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
        uint _lockTime = airdrop[msg.sender].time;
        uint stakingPeriod = _lockTime;
        uint annualPercetangeRate =  aprLevel1;
        uint256 totalReward = unclaimedReward[_userAddress] + balances[_userAddress] * annualPercetangeRate * stakingPeriod / _lockTime / PCT_BASE;
        return (stakingPeriod, annualPercetangeRate, totalReward);
     }


    /**
    * @dev Fund the pool balance to be used by the staking pool
    * @notice must be an owner
    * @param _amount amount to fund.
    */
    function fund(uint256 _amount) public onlyOwner {
      require(token.transferFrom(msg.sender, address(this),  _amount), "transfer failed");
      poolBalance = poolBalance.add(_amount);
      emit FundStakingPool(msg.sender, _amount, poolBalance);
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

    function Ref_Withdraw() external noReentrant {

        uint256 value = refer[msg.sender].refFunds;
        token.approve(address(this), value);
        token.transfer(msg.sender,value);
        uint amount = refer[msg.sender].amount;
        refer[msg.sender].refFunds = 0;
        uint256 lastWithdraw = refTotalWithdraw[msg.sender].totalWithdraw;
        uint256 totalValue = SafeMath.add(value,lastWithdraw);
        refTotalWithdraw[msg.sender] = refferal_withdraw(msg.sender,totalValue);
        poolBalance = poolBalance.sub(amount);

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