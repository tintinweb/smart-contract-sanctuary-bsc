// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
OFFICIAL WEBSITE: https://honeypot.game

 /$$   /$$                                                     /$$            /$$$$$$
| $$  | $$                                                    | $$           /$$__  $$
| $$  | $$  /$$$$$$  /$$$$$$$  /$$   /$$  /$$$$$$   /$$$$$$  /$$$$$$        | $$  \__/  /$$$$$$  /$$$$$$/$$$$   /$$$$$$
| $$$$$$$$ /$$__  $$| $$__  $$| $$  | $$ /$$__  $$ /$$__  $$|_  $$_/        | $$ /$$$$ |____  $$| $$_  $$_  $$ /$$__  $$
| $$__  $$| $$  \ $$| $$  \ $$| $$  | $$| $$  \ $$| $$  \ $$  | $$          | $$|_  $$  /$$$$$$$| $$ \ $$ \ $$| $$$$$$$$
| $$  | $$| $$  | $$| $$  | $$| $$  | $$| $$  | $$| $$  | $$  | $$ /$$      | $$  \ $$ /$$__  $$| $$ | $$ | $$| $$_____/
| $$  | $$|  $$$$$$/| $$  | $$|  $$$$$$$| $$$$$$$/|  $$$$$$/  |  $$$$/      |  $$$$$$/|  $$$$$$$| $$ | $$ | $$|  $$$$$$$
|__/  |__/ \______/ |__/  |__/ \____  $$| $$____/  \______/    \___/         \______/  \_______/|__/ |__/ |__/ \_______/
                               /$$  | $$| $$
                              |  $$$$$$/| $$
                               \______/ |__/
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./interface/IApiaryLand.sol";
import "./interface/IBeeItem.sol";
import "./interface/IHoneyBank.sol";
import "./interface/IHoneypotGame.sol";

/**
* @title Main contract for apiary creation and interaction
* @author Rustam Mamedov
*/
contract HoneypotGame is IHoneypotGame, ERC1155Holder, Ownable {
    // Structs
    struct User {
        address account;
        string[] accountAliases;
        address upline;
        uint registrationTimestamp;
        uint partnerLevel;
        uint[10] partnerEarnReward;
        uint[10] partnerMissedReward;
        uint[10] partnerCount;
        bool banned;
    }

    // Constants
    uint constant public REWARDABLE_LINES = 10;
    uint constant public EARLY_BIRD_BONUSES = 1000;

    // Events
    event UserRegistration(address account, address upline);
    event BuyBees(address account, uint[] beeIds, uint[] amounts);
    event BuyItems(address account, uint[] itemIds, uint[] amounts);
    event BuySlotPacks(address account, uint packs);
    event BuyAlias(address account, string ref);
    event PartnerLevelUpdate(address account, uint oldLevel, uint newLevel);
    event ClaimProfit(address account, uint profit);
    event PartnerReward(address account, address referral, uint line, uint reward);
    event MissedPartnerReward(address account, address referral, uint line, uint reward);
    event AddItemsForSale(uint[] itemIds, uint[] prices);
    event RegistrationPriceUpdate(uint newValue);
    event SlotPriceUpdate(uint newValue);
    event BeePricesUpdate(uint[7] newValues);
    event PartnerRewardPercentsUpdate(uint[10] newValues);
    event AliasPriceUpdate(uint newValue);
    event Ban(address account, string reason);
    event Unban(address account);

    // State
    IApiaryLand public land;
    IBeeItem public item;
    IHoneyBank public bank;

    uint public registrationPrice;
    uint public aliasPrice;
    uint public slotPrice;
    uint[7] beePrices;
    uint[] salableItems;
    uint[10] partnerRewardPercents;
    mapping(uint => uint) itemPrices;
    mapping(address => User) users;
    mapping(string => address) aliasAddress;
    uint public totalUsers;

    // Modifiers
    modifier notBanned() {
        require(!users[msg.sender].banned, "Account is banned");
        _;
    }

    constructor(IApiaryLand _land, IBeeItem _item, IHoneyBank _bank) {
        land = _land;
        item = _item;
        bank = _bank;

        registrationPrice = 5000 ether;
        slotPrice = 250 ether;
        aliasPrice = 2500 ether;
        beePrices = [20000 ether, 50000 ether, 75000 ether, 120000 ether, 160000 ether, 200000 ether, 250000 ether];
        partnerRewardPercents = [500, 400, 300, 200, 100, 100, 100, 100, 100, 100]; // 1 % = 100

        // Admin preset
        users[msg.sender].account = msg.sender;
        users[msg.sender].registrationTimestamp = block.timestamp;
        users[msg.sender].partnerLevel = REWARDABLE_LINES;
        totalUsers++;
    }

    /**
     * @dev Register user account, create apiary and subtract registration fee
     *
     * @param upline account that invite msg.sender
     */
    function register(address upline) external {
        require(!isRegistered(msg.sender), "User is already registered");
        require(isRegistered(upline), "Upline is not registered");

        // Register user
        users[msg.sender].account = msg.sender;
        users[msg.sender].upline = upline;
        users[msg.sender].registrationTimestamp = block.timestamp;

        // Update upline partner counts
        address[] memory uplines = getUplines(msg.sender, REWARDABLE_LINES);
        for(uint line; line < uplines.length && uplines[line] != address(0); line++) {
            users[uplines[line]].partnerCount[line]++;
        }

        // Take registration fee
        bank.subtract(msg.sender, getRegistrationPrice());

        // Create apiary
        land.createApiary(msg.sender);

        totalUsers++;
        emit UserRegistration(msg.sender, upline);
    }

    /**
     * @dev Buy bees
     *
     * @notice msg.sender must be registered
     *
     * @param beeIds array of bee ids to buy
     * @param amounts array that correspond to bee amounts from beeIds
     */
    function buyBees(uint[] memory beeIds, uint[] memory amounts) external notBanned {
        uint totalCost;
        for(uint i; i < beeIds.length; i++) {
            totalCost += beePrices[beeIds[i] - 1] * amounts[i];
        }

        require(totalCost > 0, "totalCost must be >0");
        bank.subtract(msg.sender, totalCost);
        land.addBees(msg.sender, beeIds, amounts);
        sendPartnerReward(msg.sender, totalCost);

        emit BuyBees(msg.sender, beeIds, amounts);
    }

    /**
     * @dev Buy items
     *
     * @param itemIds array of item ids
     * @param amounts array of amount of items corresponding to itemIds
     */
    function buyItems(uint[] memory itemIds, uint[] memory amounts) external notBanned {
        require(itemIds.length == amounts.length, "itemIds.length must be equal to amounts.length");
        require(itemIds.length > 0, "packs must be > 0");

        uint totalCost;
        for(uint i; i < itemIds.length; i++) {
            require(itemIds[i] != 0, "item id can not be 0");
            require(amounts[i] != 0, "items amount can not be 0");
            require(itemPrices[itemIds[i]] != 0, "item is not salable");
            totalCost += itemPrices[itemIds[i]] * amounts[i];
        }

        bank.subtract(msg.sender, totalCost);
        item.mintBatch(msg.sender, itemIds, amounts);
        sendPartnerReward(msg.sender, totalCost);

        emit BuyItems(msg.sender, itemIds, amounts);
    }

    /**
     * @dev Buy slot packs
     *
     * @notice msg.sender must be registered
     *
     * @param packs 1 pack = 10 slots
     */
    function buySlotPacks(uint packs) external notBanned {
        require(packs > 0, "packs must be > 0");

        uint totalCost = packs * 10 * slotPrice;
        bank.subtract(msg.sender, totalCost);
        land.addSlots(msg.sender, packs * 10);

        emit BuySlotPacks(msg.sender, packs);
    }

    /**
     * @dev Set items to owner apiary. Items that no longer in use will be returned to user
     * and new items will be taken from user.
     *
     * @notice msg.sender must be registered
     *
     * @param itemIds array of item ids that must be set. Each item must be appropriate for beeId (item index + 1)
     */
    function setApiaryItems(uint[7] memory itemIds) external notBanned {
        (uint[7] memory notUsedItems, uint[7] memory newItems) = land.setApiaryItems(msg.sender, itemIds);
        for(uint i; i < notUsedItems.length; i++) {
            if (notUsedItems[i] != 0) {
                item.safeTransferFrom(address(this), msg.sender, notUsedItems[i], 1, "");
            }
            if (newItems[i] != 0) {
                item.safeTransferFrom(msg.sender, address(this), newItems[i], 1, "");
            }
        }
        recalcUserPartnerLevel(msg.sender);
    }

    /**
     * @dev Claim available profit
     *
     * @notice msg.sender must be registered
     *
     */
    function claimProfit() external notBanned {
        uint profit = land.claimProfit(msg.sender);
        require(profit > 0, "Can't claim 0 profit");
        bank.add(msg.sender, profit);

        emit ClaimProfit(msg.sender, profit);
    }

    /**
     * @dev Buy alias for custom invite links
     *
     * @param ref alias
     *
     * @notice msg.sender must be registered
     *
     */
    function buyAlias(string memory ref) external notBanned {
        require(users[msg.sender].account == msg.sender, "Only registered user");
        require(users[msg.sender].accountAliases.length < 10, "Max 10 aliases");
        bytes memory refBytes = bytes(ref);
        require(refBytes.length >= 3 && refBytes.length <= 20, "ref size must be >= 3 and <= 20");
        require(aliasAddress[ref] == address(0), "Alias is already taken");
        for(uint i; i < refBytes.length; i++) {
            require(
                uint8(refBytes[i]) >= 48 && uint8(refBytes[i]) <= 57 ||  // 0-9
                uint8(refBytes[i]) >= 65 && uint8(refBytes[i]) <= 90 ||  // a-z
                uint8(refBytes[i]) >= 97 && uint8(refBytes[i]) <= 122    // A-Z
            , "Only alphanumeric symbols");
        }

        aliasAddress[ref] = msg.sender;
        users[msg.sender].accountAliases.push(ref);
        bank.subtract(msg.sender, aliasPrice);

        emit BuyAlias(msg.sender, ref);
    }

    /**
     * @dev Add items for sale
     *
     * @notice Can be accessed only by contract admin
     *
     * @param itemIds array of item ids to publish for sale
     * @param prices array of itemIds prices
     */
    function addItemsForSale(uint[] memory itemIds, uint[] memory prices) external onlyOwner {
        require(itemIds.length == prices.length, "itemIds.length must be equal to prices.length");
        require(itemIds.length > 0, "itemIds.length must be > 0");
        for(uint i; i < itemIds.length; i++) {
            require(itemPrices[itemIds[i]] == 0, "Item is already presented");
            require(itemIds[i] > 0, "itemIds[i] must be > 0");
            require(prices[i] > 0, "prices[i] must be > 0");

            salableItems.push(itemIds[i]);
            itemPrices[itemIds[i]] = prices[i];
        }
        emit AddItemsForSale(itemIds, prices);
    }

    /**
     * @dev Update registration price value
     *
     * @notice Can be accessed only by contract admin
     *
     * @param _registrationPrice new registration price
     */
    function setRegistrationPrice(uint _registrationPrice) external onlyOwner {
        registrationPrice = _registrationPrice;
        emit RegistrationPriceUpdate(_registrationPrice);
    }

    /**
     * @dev Update slot price
     *
     * @notice Can be accessed only by contract admin
     *
     * @param _slotPrice new slot price
     */
    function setSlotPrice(uint _slotPrice) external onlyOwner {
        slotPrice = _slotPrice;
        emit SlotPriceUpdate(_slotPrice);
    }

    /**
     * @dev Update bee prices
     *
     * @notice Can be accessed only by contract admin
     *
     * @param _beePrices new bee prices
     */
    function setBeePrices(uint[7] memory _beePrices) external onlyOwner {
        beePrices = _beePrices;
        emit BeePricesUpdate(_beePrices);
    }

    /**
     * @dev Update partner reward percents
     *
     * @notice Can be accessed only by contract admin
     *
     * @param _partnerRewardPercents new partner reward percents
     */
    function setPartnerRewardPercents(uint[10] memory _partnerRewardPercents) external onlyOwner {
        partnerRewardPercents = _partnerRewardPercents;
        emit PartnerRewardPercentsUpdate(_partnerRewardPercents);
    }

    /**
     * @dev Update alias price
     *
     * @notice Can be accessed only by contract admin
     *
     * @param _aliasPrice new alias price
     */
    function setAliasPrice(uint _aliasPrice) external onlyOwner {
        aliasPrice = _aliasPrice;
        emit AliasPriceUpdate(_aliasPrice);
    }

    /**
     * @dev Add user to ban list by address
     *
     * @notice Can be accessed only by contract admin
     *
     * @param account address that must be banned
     * @param reason ban reason
     */
    function ban(address account, string memory reason) external onlyOwner {
        users[account].banned = true;
        emit Ban(account, reason);
    }

    /**
     * @dev Remove user from ban list by address
     *
     * @notice Can be accessed only by contract admin
     *
     * @param account address that must be unbanned
     */
    function unban(address account) external onlyOwner {
        users[account].banned = false;
        emit Unban(account);
    }

    /**
     * @dev Send partner reward to uplines
     *
     * @param referral user who made a buy
     * @param spentAmount tokens amount that was spent
     */
    function sendPartnerReward(address referral, uint spentAmount) private {
        address[] memory upline = getUplines(referral, REWARDABLE_LINES);
        for(uint i; i < upline.length && upline[i] != address(0); i++) {
            uint reward = spentAmount * partnerRewardPercents[i] / 10000;
            if(users[upline[i]].partnerLevel > i && !users[upline[i]].banned) {
                users[upline[i]].partnerEarnReward[i] += reward;
                bank.add(users[upline[i]].account, reward);
                emit PartnerReward(users[upline[i]].account, referral, i + 1, reward);
            } else {
                users[upline[i]].partnerMissedReward[i] += reward;
                emit MissedPartnerReward(users[upline[i]].account, referral, i + 1, reward);
            }
        }
    }

    /**
     * @dev Recalculate user partner level based on bees with items
     */
    function recalcUserPartnerLevel(address account) private {
        if (account == owner()) {
            return;
        }

        (uint[7] memory bees, uint[7] memory items, bool isSet) = land.getBeesAndItems(account);
        uint level;
        for(uint i; i < bees.length; i++) {
            if(bees[i] > 0 && items[i] > 0) {
                level++;
            }
        }

        if(level == 7 && isSet) {
            level = REWARDABLE_LINES;
        }

        if (users[msg.sender].partnerLevel != level) {
            emit PartnerLevelUpdate(msg.sender, users[msg.sender].partnerLevel, level);
            users[msg.sender].partnerLevel = level;
        }
    }

    /**
     * @dev Get partner reward percents
     */
    function getPartnerRewardPercents() external view returns(uint[10] memory) {
        return partnerRewardPercents;
    }

    /**
     * @dev Get user address by alias
     *
     * @param ref alias
     *
     * @return resolved address
     */
    function getAddressByAlias(string memory ref) external view returns(address) {
        return aliasAddress[ref];
    }

    /**
     * @dev Get bee prices
     */
    function getBeePrices() external view returns(uint[7] memory) {
        return beePrices;
    }

    /**
     * @dev Get PartnerAccount
     */
    function getUser(address account) external view returns(User memory) {
        return users[account];
    }

    /**
     * @dev Get salable items with prices
     */
    function getSalableItems() external view returns(uint[] memory, uint[] memory) {
        uint[] memory prices = new uint[](salableItems.length);
        for(uint i; i < salableItems.length; i++) {
            prices[i] = itemPrices[salableItems[i]];
        }
        return (salableItems, prices);
    }

    /**
     * @dev Get user upline addresses
     *
     * @param account user address
     * @param amount amount of uplines
     * @return array of upline addresses in order of upline value
     */
    function getUplines(address account, uint amount) public view returns(address[] memory) {
        address[] memory result = new address[](amount);

        uint uplineIndex = 0;
        address uplineAddress = users[account].upline;
        while(uplineAddress != address(0) && uplineIndex < amount) {
            result[uplineIndex++] = uplineAddress;
            uplineAddress = users[uplineAddress].upline;
        }

        return result;
    }

    /**
     * @dev Check is user registered
     *
     * @param account user address for check
     * @return true/false
     */
    function isRegistered(address account) public view returns(bool) {
        return account != address(0) && users[account].account == account;
    }

    /**
     * @dev Get registration timestamp
     *
     * @param account user address
     * @return 0 - if not registered, any other value is registration timestamp
     */
    function getRegistrationTimestamp(address account) external view returns(uint) {
        return users[account].registrationTimestamp;
    }

    /**
     * @dev Get registration price
     *
     * @return uint registration price
     */
    function getRegistrationPrice() public view returns (uint) {
        if (totalUsers > EARLY_BIRD_BONUSES) {
            return registrationPrice;
        } else {
            return registrationPrice / 2;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IApiaryLand {
    function createApiary(address account) external;
    function addBees(address owner, uint[] memory beeIds, uint[] memory amounts) external;
    function addSlots(address owner, uint amount) external;
    function setApiaryItems(address owner, uint[7] memory itemIds) external returns(uint[7] memory, uint[7] memory);
    function getBeesAndItems(address owner) external view returns(uint[7] memory, uint[7] memory, bool);
    function claimProfit(address owner) external returns(uint);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IBeeItem is IERC1155 {
    function mintBatch(address to, uint[] memory ids, uint[] memory amounts) external;
    function mint(address to, uint id, uint amount) external;
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IHoneyBank {
    function balanceOf(address account) external returns(uint);
    function subtract(address from, uint amount) external;
    function add(address to, uint amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IHoneypotGame {
    function getRegistrationTimestamp(address account) external view returns(uint);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}