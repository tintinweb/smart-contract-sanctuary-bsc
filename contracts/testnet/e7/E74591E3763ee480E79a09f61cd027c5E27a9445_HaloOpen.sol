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
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interface/IHalo.sol";

contract HaloOpen is OwnableUpgradeable{
    IHalo public box;
    IHalo1155 public ticket;
    IERC20 public BVG;
    uint creationAmount;
    uint normalAmount;
    uint boxAmount;
    uint shredAmount;
    uint public homePlanet;
    uint public pioneerPlanet;
    uint public totalBox;
    uint public BvgPrice;
    uint randomSeed;
    uint[] extractNeed;
    mapping(address => uint) public extractTimes;
    uint public extractCreationAmount;
    uint public lastDay;
    uint public currentDay;
    struct OpenInfo{
        address mostOpen;
        uint openAmount;
        address mostCost;
        uint costAmount;
        address lastExtract;
    }
    struct UserInfo{
        uint openAmount;
        uint costAmount;
    }
    mapping(uint => uint) public rewardPool;
    mapping(uint => OpenInfo) public openInfo;
    mapping(uint => mapping(address => UserInfo)) public userInfo;
    mapping(uint => mapping(address => bool)) public isClaimed;
    event Reward(address indexed addr, uint indexed reward, uint indexed amount);//1 for creation 2 for normal 3 for box 4 for shred
    function initialize() public initializer{
        __Context_init_unchained();
        __Ownable_init_unchained();
        BvgPrice = 1e14;
        totalBox = 200000;
        boxAmount = 50000;
        creationAmount = 200;
        normalAmount = 10000;
        shredAmount = 139800;
        homePlanet = 5;
        pioneerPlanet = 20;
        extractCreationAmount = 50;
        extractNeed = [4,8,16,32];
    }
    modifier refershTime(){
        uint time = block.timestamp - ( block.timestamp % 86400);
        if(time != currentDay){
            lastDay = currentDay;
            currentDay = time;
        }
        _;
    }
    function rand(uint256 _length) internal returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, randomSeed)));
        randomSeed ++;
        return random % _length + 1;
    }
    function setExtractNeed(uint[] memory need) external onlyOwner{
        extractNeed = need;
    }
    function setBVG(address addr) external onlyOwner{
        BVG = IERC20(addr);
    }
    
    function setTicket(address addr) external onlyOwner{
        ticket = IHalo1155(addr);
    }
    
    function setBox(address addr) external onlyOwner{
        box = IHalo(addr);
    }
    
    function openBox(uint tokenId) external refershTime{
        box.burn(tokenId);
        uint res = rand(boxAmount + creationAmount + normalAmount + shredAmount);
        if(res > shredAmount + boxAmount + normalAmount){
            ticket.mint(msg.sender,2,1);
            creationAmount --;
            emit Reward(msg.sender,2,1);
        }else if(res > shredAmount + boxAmount){
            ticket.mint(msg.sender,6,1);
            normalAmount --;
            emit Reward(msg.sender,6,1);
        }else if(res > shredAmount){
            ticket.mint(msg.sender,1,1);
            boxAmount --;
            emit Reward(msg.sender,1,1);
        }else{
            ticket.mint(msg.sender,7,1);
            emit Reward(msg.sender,7,1);
        }
        userInfo[currentDay][msg.sender].openAmount++;
        if(userInfo[currentDay][msg.sender].openAmount > openInfo[currentDay].openAmount){
            openInfo[currentDay].mostOpen = msg.sender;
            openInfo[currentDay].openAmount = userInfo[currentDay][msg.sender].openAmount;
        }
        rewardPool[currentDay] += 20000 ether;
        
    }
    
    function extractNormal(uint amount) external refershTime{
        require(amount == 2 || amount == 4,'wrong amount');
        ticket.burn(msg.sender,7,amount);
        if(amount == 2){
            uint out = rand(100);
            if(out > 80){
                ticket.mint(msg.sender,1,1);
                emit Reward(msg.sender,1,1);
            }else{
                ticket.mint(msg.sender,7,1);
                BVG.transfer(msg.sender,5 ether * 1e18 / BvgPrice);
                emit Reward(msg.sender,7,1);
            }
        }else{
            uint out = rand(100);
            if(out > 85){
                ticket.mint(msg.sender,6,1);
                emit Reward(msg.sender,6,1);
            }else{
                ticket.mint(msg.sender,7,2);
                emit Reward(msg.sender,7,2);
                BVG.transfer(msg.sender,10 ether * 1e18 / BvgPrice);
            }
        }
        userInfo[currentDay][msg.sender].costAmount += amount;
        if(userInfo[currentDay][msg.sender].costAmount > openInfo[currentDay].costAmount){
            openInfo[currentDay].costAmount = userInfo[currentDay][msg.sender].costAmount;
            openInfo[currentDay].mostCost = msg.sender;
        }
        openInfo[currentDay].lastExtract = msg.sender;
        rewardPool[currentDay] += 5000 ether;
    }
    
    function extractCreation() external refershTime{
        require(extractCreationAmount > 0,'no creationAmount');
        uint times = extractTimes[msg.sender];
        uint need = extractNeed[times];
        ticket.burn(msg.sender,7,need);
        uint out = rand(100);
        if(times == 0){
            if (out > 95 && extractCreationAmount > 0){
                ticket.mint(msg.sender,2,1);
                extractCreationAmount --;
                emit Reward(msg.sender,2,1);
            }else{
                BVG.transfer(msg.sender,5 ether * 1e18 / BvgPrice);
                extractTimes[msg.sender]++;
                emit Reward(msg.sender,0,5 ether * 1e18 / BvgPrice);
            }
        }else if(times == 1){
            if (out > 80 && extractCreationAmount > 0){
                ticket.mint(msg.sender,2,1);
                extractCreationAmount --;
                extractTimes[msg.sender] = 0;
                emit Reward(msg.sender,2,1);
            }else{
                BVG.transfer(msg.sender,10 ether * 1e18 / BvgPrice);
                extractTimes[msg.sender]++;
                emit Reward(msg.sender,0,10 ether * 1e18 / BvgPrice);
            }
        }else if(times == 2){
            if (out > 50 && extractCreationAmount > 0){
                ticket.mint(msg.sender,2,1);
                extractCreationAmount --;
                extractTimes[msg.sender] = 0;
                emit Reward(msg.sender,2,1);
            }else{
                BVG.transfer(msg.sender,20 ether * 1e18 / BvgPrice);
                extractTimes[msg.sender]++;
                emit Reward(msg.sender,0,20 ether * 1e18 / BvgPrice);
            }
        }else{
            ticket.mint(msg.sender,2,1);
            extractCreationAmount --;
            extractTimes[msg.sender] = 0;
            emit Reward(msg.sender,2,1);
        }
        userInfo[currentDay][msg.sender].costAmount += need;
        if(userInfo[currentDay][msg.sender].costAmount > openInfo[currentDay].costAmount){
            openInfo[currentDay].costAmount = userInfo[currentDay][msg.sender].costAmount;
            openInfo[currentDay].mostCost = msg.sender;
        }
        openInfo[currentDay].lastExtract = msg.sender;
        rewardPool[currentDay] += 5000 ether;
    }
    
    function extractPioneerPlanet(uint amount) external refershTime{
        require(amount == 8 || amount == 20,'wrong amount');
        uint out = rand(1000);
        ticket.burn(msg.sender,7,amount);
        if(amount == 8){
            if(out >850){
                ticket.mint(msg.sender,3,1);
                pioneerPlanet--;
                emit Reward(msg.sender,3,1);
            }else{
                BVG.transfer(msg.sender,20 ether * 1e18 / BvgPrice);
                emit Reward(msg.sender,0,20 ether * 1e18 / BvgPrice);
            }
        }else{
            if(out >925){
                ticket.mint(msg.sender,4,1);
                homePlanet--;
                emit Reward(msg.sender,4,1);
            }else{
                BVG.transfer(msg.sender,50 ether * 1e18 / BvgPrice);
                emit Reward(msg.sender,0,50 ether * 1e18 / BvgPrice);
            }
        }
        userInfo[currentDay][msg.sender].costAmount += amount;
        if(userInfo[currentDay][msg.sender].costAmount > openInfo[currentDay].costAmount){
            openInfo[currentDay].costAmount = userInfo[currentDay][msg.sender].costAmount;
            openInfo[currentDay].mostCost = msg.sender;
        }
        rewardPool[currentDay] += 5000 ether;
        openInfo[currentDay].lastExtract = msg.sender;
    }
    
    function coutingReward(address addr) public view returns(uint){
        uint rew;
        if(isClaimed[lastDay][addr]){
            return 0;
        }
        if(addr == openInfo[lastDay].lastExtract){
            rew += rewardPool[lastDay] / 2;
        }
        if(addr == openInfo[lastDay].mostCost){
            rew += rewardPool[lastDay] * 3 / 10;
        }
        if(addr == openInfo[lastDay].mostOpen){
            rew += rewardPool[lastDay] * 2 / 10;
        }
        return rew;
    }
    
    function claimReward() external{
        require(coutingReward(msg.sender) > 0,'no reward');
        BVG.transfer(msg.sender,coutingReward(msg.sender));
        isClaimed[lastDay][msg.sender] = true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHalo{
    function mintBatch(address player, uint amount) external;
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    
    function burn(uint tokenId_) external returns (bool);
}
interface IHalo1155{

    function mint(address to_, uint cardId_, uint amount_) external returns (bool);

    function balanceOf(address account, uint256 tokenId) external view returns (uint);

    function burn(address account, uint256 id, uint256 value) external;

    function checkItemEffect(uint id_) external view returns (uint[3] memory);
    
    function itemLevel(uint id_) external view returns (uint);
    
    function itemExp(uint id_) external view returns(uint);
    
    
}