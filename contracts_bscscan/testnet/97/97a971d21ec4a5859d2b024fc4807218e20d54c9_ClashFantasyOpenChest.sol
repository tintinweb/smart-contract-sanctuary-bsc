// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface IClashFantasyChest {
    function getChestHasEnergyByChestId(uint256 _chestId) external view returns (uint256, uint256);
}

interface IClashFantasyCards {
    function mint(address to,uint256[] memory amounts,uint256[] memory aditionalIds, uint hasMana, uint256 _typeOf ) external; 
}

interface IClashFantasy {
    function burn(address _address, uint256 _tokenId, uint256 _amount, uint256 _aditionalId) external;
    function balanceOf(address _address, uint256 _tokenId) external view returns(uint256);
    function currentToken() external view returns(uint256 current);
    function getInternalUserTokenById(address _address, uint256 _tokenId) external view returns(uint256 token,uint256 amount,uint256 aditionalId,bool burned,bool exists);
}

contract ClashFantasyOpenChest is Initializable, OwnableUpgradeable {

    IClashFantasy private contractBase;
    IClashFantasyChest private contractBaseChest;
    IClashFantasyCards private contractCards;
    address private adminContract;

    uint private lootChestCount;

    bool private validatePreSale;

    struct openChestSkeleton {
        uint256 tokenId;
        uint256 createTime;
        bool delivered;
        bool exists;
        uint256 aditionalId;
        uint256 rarityId;
        uint256 amount;
    }

    struct ChestTime {
        uint256 timetoOpen;
    }

    struct UserCard {
        uint256 tokenId;
        uint256 amount;
        uint256 hasEnergy;
    }

    UserCard[] _userCards;

    mapping(uint256 => openChestSkeleton) public arrayOpenChest;

    mapping(uint256 => ChestTime) arrayChestTime;

    struct LootChest {
        uint256 typeOf;
        LootChestInfo[] info;
    }

    struct LootChestInfo {
        uint256 amount;
        uint256 percentage;
    }

    mapping(uint256 => LootChest) private lootChest;

    mapping(uint256 => uint256[]) cards;

    modifier onlyAdminOwner {
        require(adminContract == msg.sender, "Only the contract admin owner can call this function");
        _;
    }

    function initialize(IClashFantasy _contractBase, IClashFantasyChest _contractbaseChest, IClashFantasyCards _contractCards) public initializer {
         __Ownable_init();
        contractBase = _contractBase;
        contractBaseChest = _contractbaseChest;
        contractCards = _contractCards;

        adminContract = msg.sender;

        arrayChestTime[0] = ChestTime(10);
        arrayChestTime[1] = ChestTime(10);
        arrayChestTime[2] = ChestTime(10);
        arrayChestTime[3] = ChestTime(10);

        cards[0].push(0);
        cards[0].push(1);
        cards[0].push(2);
        cards[0].push(3);
        cards[0].push(4);
        cards[0].push(5);
        cards[0].push(6);
        cards[0].push(7);
        cards[0].push(8);
        cards[0].push(9);
        cards[0].push(10);

        cards[1].push(0);
        cards[1].push(1);
        cards[1].push(2);

        cards[2].push(0);
        cards[2].push(1);
        cards[2].push(2);

        cards[3].push(0);
        cards[3].push(1);
        cards[3].push(2);

        validatePreSale = false;

        //common
        lootChest[0].typeOf = 0;
        lootChest[0].info.push(LootChestInfo(6, 50));
        lootChest[0].info.push(LootChestInfo(4, 25));
        lootChest[0].info.push(LootChestInfo(3, 15));
        lootChest[0].info.push(LootChestInfo(2, 10));
    
        //rare
        lootChest[1].typeOf = 1;
        lootChest[1].info.push(LootChestInfo(6, 25));
        lootChest[1].info.push(LootChestInfo(4, 50));
        lootChest[1].info.push(LootChestInfo(3, 15));
        lootChest[1].info.push(LootChestInfo(2, 10));

        //epic
        lootChest[2].typeOf = 2;
        lootChest[2].info.push(LootChestInfo(6, 25));
        lootChest[2].info.push(LootChestInfo(4, 15));
        lootChest[2].info.push(LootChestInfo(3, 50));
        lootChest[2].info.push(LootChestInfo(2, 10));

        //mythic
        lootChest[3].typeOf = 3;
        lootChest[3].info.push(LootChestInfo(6, 25));
        lootChest[3].info.push(LootChestInfo(4, 15));
        lootChest[3].info.push(LootChestInfo(3, 10));
        lootChest[3].info.push(LootChestInfo(2, 50));

        lootChestCount = 4;
    }

    function listCards(uint256 _typeOf) public view returns(uint256[] memory){
        return cards[_typeOf];
    }    

    function addCard(uint256 _typeOf ) public onlyAdminOwner {
        uint256 index = cards[_typeOf].length;
        cards[_typeOf].push(index);
    }

    function unlockChest(uint256 _tokenId)
        public
    {
        uint256 aditionalId = verifyBurned(_tokenId);

        require(arrayOpenChest[_tokenId].exists == false, "Chest already unlocked");

        (uint256 rarity, uint256 amount) = getChestChoosen(aditionalId, _tokenId);
        arrayOpenChest[_tokenId] = openChestSkeleton(_tokenId, block.timestamp, false, true, aditionalId, rarity, amount);
    }

    function openChest(uint256 _tokenId) 
        public
    {
        require(arrayOpenChest[_tokenId].exists, "Chest need first to be unlocked");
        uint256 _balanceOf = contractBase.balanceOf(msg.sender, _tokenId);
        require(_balanceOf >= 1, "Check balance token");

        // if(validatePreSale == true) {
            // openChestWithPresale(_tokenId, aditionalId);
        // }else{
        openChestWithoutPresale(_tokenId );
        // }
    }

    function openChestWithoutPresale(uint256 _tokenId) 
        public
    { 
        openChestSkeleton storage user = arrayOpenChest[_tokenId];
        uint256 aditionalId = user.aditionalId;
        uint256 choosen = user.rarityId;
        uint256 amount = user.amount;

        (uint256 hasEnergy,) = contractBaseChest.getChestHasEnergyByChestId(aditionalId);
        uint256 _typeOf = getTypeOf(aditionalId);
        
        uint256[] memory _ids = new uint256[](amount);
        uint256[] memory _amounts = new uint256[](amount);
        for (uint256 i = 0; i < 6; i++) {
            uint256 card_choosen = returnRandomCards(i, aditionalId, cards[choosen].length );
            
            if(i < amount) {
                _ids[i] = card_choosen;
                _amounts[i] = 1;
            }
        }
        contractCards.mint(msg.sender, _amounts, _ids, hasEnergy, _typeOf);
        contractBase.burn(msg.sender, _tokenId, 1 , aditionalId);

        user.exists = false;

    }

    function getChestChoosen(uint256 _aditionalId, uint256 _tokenId) 
        internal view returns(uint256, uint256)
    {
        uint256 _typeOf = getTypeOf(_aditionalId);
        ( uint256[] memory percentage, uint256[] memory amount) = getLootChestArray(_typeOf);
        uint256 choosen = returnRandomChestOpen(_tokenId, _aditionalId, percentage);
        return (choosen, amount[choosen]);
    }

    function getTypeOf(uint256 _aditional) 
        internal
        pure
        returns(uint256)
    {
        if(_aditional == 0 || _aditional == 4) {
            return 0;
        }
        if(_aditional == 1 || _aditional == 5) {
            return 1;
        }
        if(_aditional == 2 || _aditional == 6) {
            return 2;
        }
        if(_aditional == 3 || _aditional == 7) {
            return 3;
        }

        return 0;
    }

    // function openChestWithPresale(uint256 _tokenId,uint256 aditionalId) 
    //     internal
    // {
    //     // if(arrayOpenChest[_tokenId].exists) {
    //         // arrayOpenChest[_tokenId] = openChestSkeleton(_tokenId, currentTime(),  false, true, msg.sender);
    //     // }else{

    //         uint256 createTime = arrayOpenChest[_tokenId].createTime;
    //         bool success = checkExpiry(createTime, arrayChestTime[getTypeOf(aditionalId)].timetoOpen);
    //         require( success , "Time Already");

    //         // ( uint256[] memory percentage , uint256[] memory amount) = contractBaseChest.getLootChestArray(aditionalId);
    //         // (uint256 hasEnergy,) = contractBaseChest.getChestHasEnergyByChestId(aditionalId);
    //         // uint256 random = returnRandomChestOpen(_tokenId, percentage);
    //         // contractBase.burn(msg.sender, _tokenId, 1, aditionalId);
    //         // return (aditionalId,percentage, amount, hasEnergy);
    //     // }
    // }


    function checkExpiry(uint256 _timestamp, uint256 _chestTime) 
        public 
        view 
        returns(bool)
    {
        uint _time = block.timestamp + _chestTime * 1 minutes;

        if (_timestamp <= _time)
        {
            return true;
        }
            else
        {
            return false;
        }     
    }

    function currentTime() 
        internal 
        view 
        returns(uint256) 
    {
        return block.timestamp;
    }

    function verifyBurned(uint256 _tokenId) 
        internal
        view
        returns (uint256)
    {
        (,,uint256 aditionalId, bool burned,) = contractBase.getInternalUserTokenById(msg.sender, _tokenId);
        require(burned == false, "Chest already Open");
        return (aditionalId);  
    }

    function returnRandomChestOpen(uint _tokenId, uint _aditional, uint[] memory data) 
        public
        view
        returns(uint256)
    {
        uint count = 0;
        uint256[] memory myArray = new uint256[](100);
        for (uint i = 0; i < data.length; i++) {
            for (uint j = 0; j < data[i]; j++) {
                myArray[count] = i;
                count++;
            }
        }
        uint256 purchasenumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _tokenId, _aditional))) % 100;

        return (myArray[purchasenumber]);
    }

    function returnRandomCards(uint _tokenId, uint _aditional, uint256 amountCards) 
        public
        view
        returns(uint256)
    {
        uint256 choose =  uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _tokenId, _aditional))) % amountCards;        
        return choose;
    }

    function getLootChestArray(uint256 _typeOf)
        internal
        view
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory percentaje = new uint256[](lootChestCount);
        uint256[] memory amount = new uint256[](lootChestCount);
        for (uint256 i = 0; i < lootChestCount; i++) {
            percentaje[i] = lootChest[_typeOf].info[i].percentage;
            amount[i] = lootChest[_typeOf].info[i].amount;
        }
        return (percentaje, amount);
    }

    function setValidatePreSale(bool _state) public 
        onlyAdminOwner
    {
        validatePreSale = _state;
    }

    
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

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