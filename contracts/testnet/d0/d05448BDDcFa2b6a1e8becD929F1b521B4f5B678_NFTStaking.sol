// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "../interface/IERC_721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "../interface/IBVG.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract NFTStaking is ERC721HolderUpgradeable,OwnableUpgradeable {
    IBEP20 public BVG;
    uint public startTime;
    uint constant miningTime = 30 days;
    uint public totalClaimed;
    uint constant totalSupply = 50000000 ether;
    uint public rate;
    uint constant acc = 1e10;
    I721 public OAT;
    I721 public IGO;
    I721 public info;
    mapping(address =>mapping(uint => address)) public cardOwner;
    uint public IGOPower;
    mapping(uint => uint) public OATPower;
    function initialize() public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
        rate = totalSupply / miningTime;
        OATPower[1658] = 585;
        OATPower[1473] = 375;
        OATPower[1423] = 846;
        OATPower[1300] = 1270;
        OATPower[1196] = 274;
        OAT = I721(0x9F471abCddc810E561873b35b8aad7d78e21a48e);
        IGO = I721(0x927a7f35587BC7E59991CCCdd2D4aDd1f0e7bc66);
        info = I721(0xaf84c52D2117dADBD22FC440825e901E8d4E3BD2);
        BVG = IBEP20(0x31C5F8C0cd7eE0daA37Df1174114252B3E780E12);
        IGOPower = 12700;
    }
    
    struct UserInfo {
        uint power;
        uint debt;
        uint toClaim;
        uint claimed;
        uint[] IGOList;
        uint[] OATList; 
    }
    mapping(address => UserInfo) public userInfo;
    uint public debt;
    uint public totalPower;
    uint public lastTime;
    uint public lastDebt;
    event Claim(address indexed player, uint indexed amount);
    event Stake(address indexed player,uint indexed tokenId);
    event UnStake(address indexed player, uint indexed tokenId);
    
    modifier checkEnd(){
        if(block.timestamp >= startTime + miningTime && lastDebt ==0){
            lastDebt = coutingDebt();
        }
        _;
    }
    function calculateReward(address player) public view returns (uint){
        UserInfo storage user = userInfo[player];
        if (user.power == 0 && user.toClaim == 0) {
            return 0;
        }
        uint rew = user.power * (coutingDebt() - user.debt) / acc;
        return (rew + user.toClaim);
    }
    
    function setStartTime(uint time_) external onlyOwner{
        require(startTime == 0,'starting');
        require(block.timestamp < time_ + miningTime ,'out of time');
        require(time_ != 0 ,'startTime can not be zero');
        startTime = time_;
    }
    
    function coutingDebt() public view returns(uint _debt){
        if (lastDebt != 0){
            return lastDebt;
        }
        _debt = totalPower > 0 ? rate * (block.timestamp -lastTime) * acc / totalPower + debt : 0 + debt;
    }
    
    function stakeIGO(uint tokenId) external{
        require(block.timestamp >= startTime && startTime != 0,'not start');
        require(cardOwner[address(IGO)][tokenId] == address(0),'staked');
        require(block.timestamp < startTime + miningTime, 'mining over');
        IGO.safeTransferFrom(msg.sender,address(this),tokenId);
        cardOwner[address(IGO)][tokenId] = msg.sender;
        if(userInfo[msg.sender].power > 0){
            userInfo[msg.sender].toClaim = calculateReward(msg.sender);
        }
        userInfo[msg.sender].IGOList.push(tokenId);
        uint tempDebt = coutingDebt();
        userInfo[msg.sender].debt = tempDebt;
        userInfo[msg.sender].power += IGOPower;
        debt = tempDebt;
        totalPower += IGOPower;
        lastTime = block.timestamp;
        emit Stake(msg.sender,tokenId);
    }
    
    function stakeOAT(uint tokenId) external{
        require(block.timestamp >= startTime && startTime != 0,'not start');
        require(cardOwner[address(OAT)][tokenId] == address(0),'staked');
        require(block.timestamp < startTime + miningTime, 'mining over');
        OAT.safeTransferFrom(msg.sender,address(this),tokenId);
        cardOwner[address(OAT)][tokenId] = msg.sender;
        if(userInfo[msg.sender].power > 0){
            userInfo[msg.sender].toClaim = calculateReward(msg.sender);
        }
        uint tempPower = OATPower[OAT.cid(tokenId)];
        userInfo[msg.sender].OATList.push(tokenId);
        uint tempDebt = coutingDebt();
        userInfo[msg.sender].debt = tempDebt;
        userInfo[msg.sender].power += tempPower;
        debt = tempDebt;
        totalPower += tempPower;
        lastTime = block.timestamp;
        emit Stake(msg.sender,tokenId);
    }
    
    function unStakeIGO(uint tokenId) external{
        require(cardOwner[address(IGO)][tokenId] == msg.sender,'not card owner');
        delete cardOwner[address(IGO)][tokenId];
        uint tempRew = calculateReward(msg.sender);
        if(tempRew > 0){
            userInfo[msg.sender].toClaim = tempRew;
        }
        uint tempDebt = coutingDebt();
        userInfo[msg.sender].debt = tempDebt;
        userInfo[msg.sender].power -= IGOPower;
        debt = tempDebt;
        totalPower -= IGOPower;
        lastTime = block.timestamp;
        uint index;
        uint length = userInfo[msg.sender].IGOList.length;
        for(uint i = 0; i < length; i ++){
            if(userInfo[msg.sender].IGOList[i] == tokenId){
                index = i;
                break;
            }
        }
        userInfo[msg.sender].IGOList[index] = userInfo[msg.sender].IGOList[length -1];
        userInfo[msg.sender].IGOList.pop();
        IGO.safeTransferFrom(address(this),msg.sender,tokenId);
        emit UnStake(msg.sender,tokenId);
    }
    function unStakeOAT(uint tokenId) external{
        require(cardOwner[address(OAT)][tokenId] == msg.sender,'not card owner');
        delete cardOwner[address(OAT)][tokenId];
        uint tempRew = calculateReward(msg.sender);
        if(tempRew > 0){
            userInfo[msg.sender].toClaim = tempRew;
        }
        uint tempDebt = coutingDebt();
        uint tempPower = OATPower[OAT.cid(tokenId)];
        userInfo[msg.sender].debt = tempDebt;
        userInfo[msg.sender].power -= tempPower;
        debt = tempDebt;
        totalPower -= tempPower;
        lastTime = block.timestamp;
        uint index;
        uint length = userInfo[msg.sender].OATList.length;
        for(uint i = 0; i < length; i ++){
            if(userInfo[msg.sender].OATList[i] == tokenId){
                index = i;
                break;
            }
        }
        userInfo[msg.sender].OATList[index] = userInfo[msg.sender].OATList[length -1];
        userInfo[msg.sender].OATList.pop();
        OAT.safeTransferFrom(address(this),msg.sender,tokenId);
        emit UnStake(msg.sender,tokenId);
    }
    
    function claimReward() external{
        uint rew;
        rew = calculateReward(msg.sender);
        require(rew > 0, 'no reward');
        userInfo[msg.sender].claimed += rew;
        userInfo[msg.sender].debt = coutingDebt();
        userInfo[msg.sender].toClaim = 0;
        totalClaimed += rew;
        BVG.mint(msg.sender, rew);
        emit Claim(msg.sender, rew);
    }
    
    function checkUserOATList(address addr) public view returns(uint[] memory, uint[] memory){
        uint[] memory list = new uint[](userInfo[addr].OATList.length);
        for(uint i = 0; i < list.length; i ++){
            list[i] = OAT.cid(userInfo[addr].OATList[i]);
        }
        return (userInfo[addr].OATList,list);
    }
    
    function checkUserIGOList(address addr) public view returns(uint[] memory){
        return userInfo[addr].IGOList;
    }
    function withDrawToken(address token_,address wallet,uint amount)external onlyOwner{
        IERC20(token_).transfer(wallet,amount);
    }
    
    function withDrawBNB(address wallet) external onlyOwner{
        payable(wallet).transfer(address(this).balance);
    }
    function checkUserOATCid(address addr, uint cid_) public view returns(uint[] memory){
        uint[] memory list;
        uint balance = OAT.balanceOf(addr);
        if(balance == 0){
            return list;
        }
        uint amount;
        uint id;
        for(uint i = 0; i < balance; i ++){
            id =OAT.tokenOfOwnerByIndex(addr,i);
            if(info.cid(id) == cid_){
                amount++;
            }
        }
        list = new uint[](amount);
        for(uint i = 0; i < balance; i ++){
            id = OAT.tokenOfOwnerByIndex(addr,i);
            if(info.cid(id) == cid_){
                amount--;
                list[amount] = id;
            }
        }
        return list;
    }
    
    function checkUserCid(address NFTAddr,address addr, uint cid_) public view returns(uint[] memory){
        uint[] memory list;
        uint balance = I721(NFTAddr).balanceOf(addr);
        if(balance == 0){
            return list;
        }
        uint amount;
        uint id;
        for(uint i = 0; i < balance; i ++){
            id = I721(NFTAddr).tokenOfOwnerByIndex(addr,i);
            if(I721(NFTAddr).cid(id) == cid_){
                amount++;
            }
        }
        list = new uint[](amount);
        for(uint i = 0; i < balance; i ++){
            id = I721(NFTAddr).tokenOfOwnerByIndex(addr,i);
            if(I721(NFTAddr).cid(id) == cid_){
                amount--;
                list[amount] = id;
            }
        }
        return list;
    }
    
    
}

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.4;
interface IBEP20 {
    function decimals() external view returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    function mint(address addr_, uint amount_) external;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface I721 {
    function balanceOf(address owner) external view returns(uint256);
    function cardIdMap(uint) external view returns(uint); // tokenId => cardId
    function cardInfoes(uint) external returns(uint cardId, string memory name, uint currentAmount, uint maxAmount, string memory _tokenURI);
    function tokenURI(uint256 tokenId_) external view returns(string memory);
    function mint(address player_, uint cardId_) external returns(uint256);
    function mintWithId(address player_, uint id_, uint tokenId_) external returns (bool);
    function mintMulti(address player_, uint cardId_, uint amount_) external returns(uint256);
    function burn(uint tokenId_) external returns (bool);
    function burnMulti(uint[] calldata tokenIds_) external returns (bool);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function burned() external view returns (uint256);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function cid(uint256 tokenId) external view returns (uint256);
}