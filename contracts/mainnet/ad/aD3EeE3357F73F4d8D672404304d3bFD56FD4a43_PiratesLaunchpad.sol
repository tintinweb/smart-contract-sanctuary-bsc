/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// Sources flattened with hardhat v2.6.5 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT

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


// File @openzeppelin/contracts/access/[email protected]



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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/security/[email protected]



pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]



pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/utils/[email protected]



pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/utils/[email protected]



pragma solidity ^0.8.0;


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
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts/security/[email protected]



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
     * by making the `nonReentrant` function external, and make it call a
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


// File contracts/interfaces/IAutoBSW.sol


pragma solidity ^0.8.0;

interface IAutoBSW {
    function balanceOf() external view returns(uint);
    function totalShares() external view returns(uint);

    struct UserInfo {
        uint shares; // number of shares for a user
        uint lastDepositedTime; // keeps track of deposited time for potential penalty
        uint BswAtLastUserAction; // keeps track of Bsw deposited at the last user action
        uint lastUserActionTime; // keeps track of the last user action time
    }

    function userInfo(address user) external view returns (UserInfo memory);
}


// File contracts/PiratesLaunchpad.sol


pragma solidity 0.8.4;




interface INFT {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function balanceOf(address owner) external view returns (uint256 balance);
}


contract PiratesLaunchpad is ReentrancyGuard, Ownable, Pausable {
    using SafeERC20 for IERC20;

    struct InstanceNFT {
        INFT NFT;
        address vault;
    }

    struct Bracket {
        uint[] instances;
        uint totalCount;
    }

    struct UserInfoFrontend {
        uint price;
        uint boughtCount;
        uint totalCount;
        uint soldCount;
        uint minStakeAmount;
        uint autoBswBalance;
        uint startBlock;
        bool inQueue;
        bool canCloseQueue;
    }

    struct Queue {
        address caller;
        uint blockNumber;
    }

    IERC20 public dealToken;
    IAutoBSW public autoBsw;
    address public treasuryAddress;

    uint   public priceInDealToken;
    uint   public minStakeAmount;
    uint   public launchStartBlock;
    uint32 public totalCount;
    uint32 public soldCount;

    Bracket[4] public brackets;
    Queue[] public queue;

    mapping(uint => InstanceNFT) public instances;
    mapping(address => uint) public boughtCount; //Bought brackets by user: address => brackets count
    mapping(address => bool) public userInQueue;

    event QueueExecuted(address indexed user, uint bracketIndex, address[] nfts, string[] uris);
    event InstanceNFTUpdated(uint index,  INFT nft, address vault);

    modifier notContract() {
        require(address(msg.sender).code.length == 0, "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    constructor(
        IERC20 _dealToken,
        IAutoBSW _autoBsw,
        address _treasuryAddress,
        uint _launchStartBlock,
        uint _priceInDealToken
    ) {
        require(_launchStartBlock > block.number, "Setting start to the past not allowed");
        require(address(_dealToken) != address(0), "Setting zero address as _dealToken not allowed");
        require(address(_autoBsw)   != address(0), "Setting zero address as _autoBsw not allowed");
        require(_treasuryAddress != address(0), "Setting zero address as _treasuryAddress not allowed");

        dealToken        = _dealToken;
        autoBsw          = _autoBsw;
        treasuryAddress  = _treasuryAddress;
        priceInDealToken = _priceInDealToken;
        launchStartBlock = _launchStartBlock;
        minStakeAmount   = 100 ether;
        totalCount       = 5000;
        soldCount        = 0;

        //Add brackets
        brackets[0].instances.push(0);
        brackets[0].instances.push(2);
        brackets[0].totalCount = 2446;
        brackets[1].instances.push(1);
        brackets[1].instances.push(2);
        brackets[1].totalCount = 2455;
        brackets[2].instances.push(0);
        brackets[2].instances.push(2);
        brackets[2].instances.push(3);
        brackets[2].totalCount = 49;
        brackets[3].instances.push(1);
        brackets[3].instances.push(2);
        brackets[3].instances.push(3);
        brackets[3].totalCount = 50;
    }

    // 0 - pirates
    // 1 - ships
    // 2 - art
    // 3 - sandBox

    function updateInstanceOfNFT(uint _index, INFT _NFT, address _vault) public onlyOwner {
        require(address(_NFT)  != address(0) && _vault != address(0), "Address cant be zero");
        instances[_index].NFT = _NFT;
        instances[_index].vault = _vault;

        emit InstanceNFTUpdated(_index, _NFT, _vault);
    }

    function getUserInfo(address _user) public view returns (UserInfoFrontend memory){
        UserInfoFrontend memory _userInfo;

        _userInfo.price = priceInDealToken;
        _userInfo.startBlock = launchStartBlock;
        _userInfo.boughtCount    = boughtCount[_user];
        _userInfo.totalCount     = totalCount;
        _userInfo.soldCount      = soldCount;
        _userInfo.minStakeAmount = minStakeAmount;
        _userInfo.autoBswBalance = autoBsw.balanceOf() * autoBsw.userInfo(_user).shares / autoBsw.totalShares();
        _userInfo.inQueue = userInQueue[_user];
        uint queueIndex = getUserQueueIndex(_user);
        _userInfo.canCloseQueue = queueIndex < queue.length && queue[queueIndex].blockNumber < block.number ? true : false;
        return _userInfo;
    }

    function getUserQueueIndex(address _user) public view returns(uint){
        for(uint i = 0; i < queue.length; i++){
            if(queue[i].caller == _user){
                return i;
            }
        }
        return queue.length;
    }

    function getQueueSize() public view returns(uint){
        return queue.length;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        require(_treasuryAddress != address(0), "Address cant be zero");
        treasuryAddress = _treasuryAddress;
    }

    function updateStartTimestamp(uint _startBlock) public onlyOwner {
        require(_startBlock > block.number, "Setting start to the past not allowed");
        launchStartBlock = _startBlock;
    }

    function leftToSell() public view returns (uint){
        return totalCount - soldCount - queue.length;
    }

    function manuallyCloseQueue(uint _limit) public onlyOwner {
        uint queueLength = queue.length;
        if(queueLength == 0) return;
        _limit = _limit == 0 || _limit > queueLength ? queueLength : _limit;
        uint i = 0;
        while(i < _limit){
            if (_executeQueue(i)) {
                _limit--;
            } else {
                i++;
                continue;
            }
        }
    }

    function buyNFT() public nonReentrant whenNotPaused notContract {
        if(userInQueue[msg.sender]){
            selfExecuteQueue();
            return;
        }
        require(block.number >= launchStartBlock, "Not started yet");
        require(_checkMinStakeAmount(msg.sender), "Need more staked BSW");
        require(checkLimits(), "limit exceeding");

        boughtCount[msg.sender] += 1;

        dealToken.safeTransferFrom(msg.sender, treasuryAddress, priceInDealToken);

        pushToQueue(msg.sender);
    }

    function selfExecuteQueue() public whenNotPaused notContract returns(bool){
        for(uint i = 0; i < queue.length; i++){
            if(queue[i].caller == msg.sender){
                return _executeQueue(i);
            }
        }
        revert("User isnt in Queue");
    }

    function pushToQueue(address _user) private {
        require(!userInQueue[_user], "User already in Queue");
        userInQueue[_user] = true;
        queue.push(Queue(_user, block.number));
    }

    function _executeQueue(uint _index) internal returns(bool){
        require(_index < queue.length, "Index out of bound");
        Queue memory _queue = queue[_index];
        if(block.number <= _queue.blockNumber) return false;
        if(block.number - _queue.blockNumber > 255){
            queue[_index].blockNumber = block.number;
            return false;
        }
        queue[_index] = queue[queue.length - 1];
        queue.pop();
        bytes32 _hash = keccak256(abi.encodePacked(blockhash(_queue.blockNumber), _queue.caller));
        uint bracketIndex = _getRandomBracket(_hash);
        (string[] memory uris, address[] memory nfts) = _executeBracket(bracketIndex, _queue.caller,  _hash);
        soldCount++;
        userInQueue[_queue.caller] = false;
        emit QueueExecuted(_queue.caller, bracketIndex, nfts, uris);
        return true;
    }

    function _executeBracket(uint _bracketIndex, address _caller, bytes32 _hash) private returns(string[] memory uris, address[] memory nfts) {
        require(_bracketIndex < brackets.length, "Bracket index out of bound");
        Bracket memory _braket = brackets[_bracketIndex];
        uris = new string[](_braket.instances.length);
        nfts = new address[](_braket.instances.length);
        for(uint i = 0; i < _braket.instances.length; i++){
            InstanceNFT memory currentInstance = instances[_braket.instances[i]];
            uint tokenId = _getRandomTokenId(currentInstance, _hash);
            currentInstance.NFT.safeTransferFrom(currentInstance.vault, _caller, tokenId);
            uris[i] = currentInstance.NFT.tokenURI(tokenId);
            nfts[i] = address(currentInstance.NFT);
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function checkLimits() internal view returns (bool){
        return soldCount + queue.length < totalCount;
    }

    function _checkMinStakeAmount(address _user) internal view returns (bool) {
        uint autoBswBalance = autoBsw.balanceOf() * autoBsw.userInfo(_user).shares / autoBsw.totalShares();
        return autoBswBalance >= minStakeAmount;
    }

    // view func to view result by user queue
    function _rand(uint _max, bytes32 _hash) private pure returns(uint randomNumber){
        return uint(_hash) % _max;
    }

    function _getRandomTokenId(
        InstanceNFT memory instance,
        bytes32 _hash
    ) view private returns(uint){
        return instance.NFT.tokenOfOwnerByIndex(instance.vault, _rand(instance.NFT.balanceOf(instance.vault), _hash));
    }

    function _getRandomBracket(bytes32 _hash) private returns(uint bracketIndex) {
        uint random = _rand(leftToSell(), _hash);
        uint count = 0;
        for(uint i = 0; i < brackets.length; i++){
            count += brackets[i].totalCount;
            if(random < count){
                brackets[i].totalCount--;
                return i;
            }
        }
        revert("Wrong random number generate");
    }
}