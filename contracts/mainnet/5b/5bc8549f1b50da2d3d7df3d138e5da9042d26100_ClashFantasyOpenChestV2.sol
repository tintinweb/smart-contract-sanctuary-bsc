// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IClashFantasyChest {
    function getChestHasEnergyByChestId(uint256 _chestId) external view returns (uint256, uint256);
}

interface IClashFantasyCards {
    function mint(address to,uint256[] memory aditionalIds, uint hasMana, uint256 _typeOf ) external; 
}

interface IClashFantasy {
    function burn(address _address, uint256 _tokenId, uint256 _amount, uint256 _aditionalId) external;
    function balanceOf(address _address, uint256 _tokenId) external view returns(uint256);
    function currentToken() external view returns(uint256 current);
    function getInternalUserTokenById(address _address, uint256 _tokenId) external view returns(uint256 token,uint256 amount,uint256 aditionalId,bool burned,bool exists);
}

contract ClashFantasyOpenChestV2 is Initializable {

    using SafeMath for uint; 

    IClashFantasy private contractBase;
    
    IClashFantasyChest private contractBaseChest;

    IClashFantasyCards private contractCards;
    address private adminContract;

    uint private lootChestCount;

    bool private validatePreSale;

    bool _enableOpenChest;

    uint256 private initialNumber;

    struct openChestSkeleton {
        uint256 tokenId;
        uint256 createTime;
        bool delivered;
        bool exists;
        uint256 aditionalId;
        uint256 rarityId;
        uint256 amount;
        uint256 hasEnergy;
    }

    struct LootChest {
        uint256 typeOf;
        LootChestInfo[] info;
    }

    struct LootChestInfo {
        uint256 amount;
        uint256 percentage;
    }

    struct CardInfo {
        uint256 cardId;
        bytes32 name;
    }

    mapping(address => mapping(uint256 => openChestSkeleton)) private arrayOpenChest;

    mapping(uint256 => LootChest) private lootChest;

    mapping(uint256 => CardInfo[]) cards;

    modifier onlyAdminOwner {
        require(adminContract == msg.sender, "Only the contract admin owner can call this function");
        _;
    }

    modifier isOpenChestPaused() {
        require(_enableOpenChest == false, "Clash Fantasy Open Chest Paused");
        _;
    }

    modifier validateChest(uint256 _tokenId) {
        uint256 _balanceOf = contractBase.balanceOf(msg.sender, _tokenId);
        require(_balanceOf >= 1, "Check balance token");
        _;
    }

    function initialize(IClashFantasy _contractBase, IClashFantasyChest _contractbaseChest, IClashFantasyCards _contractCards) public initializer {
        contractBase = _contractBase;
        contractBaseChest = _contractbaseChest;
        contractCards = _contractCards;

        adminContract = msg.sender;

        validatePreSale = false;

        _enableOpenChest = false;

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

    function listCards(uint256 _typeOf) public view returns(CardInfo[] memory){
        return cards[_typeOf];
    }    

    function addCardBatch(
        uint256 _typeOf,
        uint256[] memory _cardId,
        bytes32[] memory _name
    ) 
        public
        onlyAdminOwner
    {
        require(_cardId.length == _name.length);

        for (uint256 i = 0; i < _cardId.length; ++i) {
            cards[_typeOf].push(CardInfo(_cardId[i], _name[i])); 
        }
    }

    function addCard(uint256 _typeOf, uint256 _cardId, bytes32 _name) 
        public 
        onlyAdminOwner 
    {
        cards[_typeOf].push(CardInfo(_cardId, _name));
    }

    function getTokenIdInfo(uint256 _tokenId, address _from) 
        public view returns(uint256, uint256, bool)
    {
        openChestSkeleton storage user = arrayOpenChest[_from][_tokenId];
        return (user.tokenId, user.createTime, user.exists);
    }

    function unlockChest(uint256 _tokenId)
        public
        isOpenChestPaused
        validateChest(_tokenId)
    {
        require(arrayOpenChest[msg.sender][_tokenId].exists == false, "Chest already unlocked");
        initialNumber++;

        uint256 aditionalId = verifyBurned(_tokenId);
        (uint256 hasEnergy,) = contractBaseChest.getChestHasEnergyByChestId(aditionalId);
        (uint256 rarity, uint256 amount) = getChestChoosen(aditionalId);
        arrayOpenChest[msg.sender][_tokenId] = openChestSkeleton(_tokenId, block.timestamp, false, true, aditionalId, rarity, amount,hasEnergy);

    }

    function openChest(uint256 _tokenId) 
        public
        isOpenChestPaused
        validateChest(_tokenId)
    {
        require(arrayOpenChest[msg.sender][_tokenId].exists, "Chest need first to be unlocked");

        openChestWithoutPresale(_tokenId );
    }

    function random(uint256 _aditional) private view returns (uint256) {
        return uint256(keccak256((abi.encodePacked(block.difficulty, block.timestamp, _aditional))));
    }

    function openChestWithoutPresale(uint256 _tokenId) 
        private
    { 
        openChestSkeleton storage user = arrayOpenChest[msg.sender][_tokenId];
        uint256 aditionalId = user.aditionalId;
        uint256 choosen = user.rarityId;
        uint256 amount = user.amount;
        uint256 hasEnergy = user.hasEnergy;
        
        uint256[] memory _ids = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            uint256 card_choosen = random(i) % cards[choosen].length;
            _ids[i] = cards[choosen][card_choosen].cardId;
        }
        contractCards.mint(msg.sender, _ids, hasEnergy, choosen);
        contractBase.burn(msg.sender, _tokenId, 1 , aditionalId);
         
        delete arrayOpenChest[msg.sender][_tokenId];
    }

    function getChestChoosen(uint256 _aditionalId) 
        private view returns(uint256, uint256)
    {
        uint256 _typeOf = getTypeOf(_aditionalId);
        ( uint256[] memory percentage, uint256[] memory amount) = getLootChestArray(_typeOf);
        uint256 choosen = returnRandomChestOpen(percentage);
        return (choosen, amount[choosen]);
    }

    function getTypeOf(uint256 _aditional) 
        private
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

    function checkExpiry(uint256 _timestamp, uint256 _chestTime) 
        private
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

    function verifyBurned(uint256 _tokenId) 
        private
        view
        returns (uint256)
    {
        (,,uint256 aditionalId, bool burned,) = contractBase.getInternalUserTokenById(msg.sender, _tokenId);
        require(burned == false, "Chest already Open");
        return (aditionalId);  
    }

    function returnRandomChestOpen(uint[] memory data) 
        private
        view
        returns(uint256)
    {
        uint count = 0;
        uint[] memory myArray = new uint[](100);
        for (uint i = 0; i < data.length; i++) {
            for (uint j = 0; j < data[i]; j++) {
                myArray[count] = i;
                count++;
            }
        }
        
        uint purchasenumber = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender, initialNumber))) % 100;
        return (myArray[purchasenumber]);
    }

    function returnRandomCards(uint _tokenId, uint _aditional, uint256 amountCards) 
        private
        view
        returns(uint256)
    {
        uint256 choose =  SafeMath.mod(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, _tokenId, _aditional))) , amountCards);        
        return choose;
    }

    function getLootChestArray(uint256 _typeOf)
        private
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

    function setIsOpenChestPaused(bool _state) public onlyAdminOwner {
        _enableOpenChest = _state;
    }

    function getIsOpenChestPaused() public view returns (bool) {
        return _enableOpenChest;
    }

    function removeCard(uint256 _typeOf, uint256 _index)  
        public
        onlyAdminOwner
        returns(CardInfo[] memory) 
    {
        CardInfo[] storage cardType = cards[_typeOf];
        uint256 _length = cardType.length;
        if (_index >= _length) revert();

        for (uint i = _index; i<_length-1; i++){
            cardType[i] = cardType[i+1];
        }
        cardType.pop();
        return cardType;
    }

    function getAdmin() public view returns(address){
        return adminContract;
    }
    
    function version() public pure returns(string memory) {
        return "v2";
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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