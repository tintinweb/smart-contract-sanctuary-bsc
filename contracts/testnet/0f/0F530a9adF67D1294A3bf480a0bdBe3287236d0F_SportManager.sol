// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/ISportManager.sol";

contract SportManager is ISportManager, Ownable {
    uint256 private _currentGameId = 0;
    uint256 private _currentAttributeId = 0;

    Game[] public games;
    Attribute[] public attributes;
    mapping(uint256 => mapping(uint256 => bool)) supportedAttribute;

    function addNewGame(string memory name, bool active)
        external
        override
        onlyOwner
        returns (uint256 gameId)
    {
        gameId = _currentGameId;
        _currentGameId++;
        games.push(Game(gameId, active, name));
        emit AddNewGame(_currentGameId, name);
        if (active) {
            emit ActiveGame(_currentGameId);
        } else {
            emit DeactiveGame(_currentGameId);
        }
    }

    function updateGame(uint256 _gameId, string memory _newName)
        external
        onlyOwner
    {
        games[_gameId].name = _newName;
    }

    function deactiveGame(uint256 gameId) external override onlyOwner {
        Game storage game = games[gameId];
        require(game.active, "SM: deactived");
        game.active = false;
        emit DeactiveGame(gameId);
    }

    function activeGame(uint256 gameId) external override onlyOwner {
        Game storage game = games[gameId];
        require(!game.active, "SM: actived");
        game.active = true;
        emit ActiveGame(gameId);
    }

    function addNewAttribute(Attribute[] memory attribute)
        external
        override
        onlyOwner
    {
        uint256 attributeId = _currentAttributeId;
        for (uint256 i = 0; i < attribute.length; i++) {
            attributes.push(
                Attribute(
                    attributeId,
                    attribute[i].teamOption,
                    attribute[i].attributeSupportFor,
                    attribute[i].name
                )
            );
            attributeId++;
        }
        _currentAttributeId = attributeId;
    }

    function setSupportedAttribute(
        uint256 gameId,
        uint256[] memory attributeIds,
        bool isSupported
    ) external override onlyOwner {
        require(gameId < _currentGameId);
        for (uint256 i = 0; i < attributeIds.length; i++) {
            uint256 attributeId = attributeIds[i];
            if (attributeId < _currentAttributeId) {
                supportedAttribute[gameId][attributeId] = isSupported;
            }
        }
    }

    function checkSupportedGame(uint256 gameId)
        external
        view
        override
        returns (bool)
    {
        if (gameId < _currentGameId) {
            Game storage game = games[gameId];
            return game.active;
        } else {
            return false;
        }
    }

    function checkSupportedAttribute(uint256 gameId, uint256 attributeId)
        external
        view
        override
        returns (bool)
    {
        return supportedAttribute[gameId][attributeId];
    }

    function getAllGame() external view returns (Game[] memory) {
        return games;
    }

    function getAllAttribute() external view returns (Attribute[] memory) {
        return attributes;
    }

    function getAttributesSupported(uint256 gameId)
        external
        view
        returns (Attribute[] memory result, uint256 size)
    {
        result = new Attribute[](attributes.length);
        size = 0;
        for (uint256 i = 0; i < attributes.length; i++) {
            Attribute memory attribute = attributes[i];
            if (supportedAttribute[gameId][attribute.id]) {
                result[size] = attribute;
                size++;
            }
        }
    }

    function getAttributeById(uint256 attributeId)
        public
        view
        override
        returns (Attribute memory)
    {
        return attributes[attributeId];
    }

    function checkTeamOption(uint256 attributeId)
        external
        view
        override
        returns (bool)
    {
        if (attributeId < _currentAttributeId) {
            Attribute storage attribute = attributes[attributeId];
            return attribute.teamOption;
        } else {
            return false;
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface ISportManager {
    struct Game {
        uint256 id;
        bool active;
        string name;
    }

    struct Attribute {
        uint256 id;
        bool teamOption;
        AttributeSupportFor attributeSupportFor;
        string name;
    }

    enum AttributeSupportFor {
        None,
        Team,
        Player,
        All
    }

    event AddNewGame(uint256 indexed gameId, string name);
    event DeactiveGame(uint256 indexed gameId);
    event ActiveGame(uint256 indexed gameId);
    event AddNewAttribute(uint256 indexed attributeId, string name);

    function addNewGame(string memory name, bool active)
        external
        returns (uint256 gameId);

    function deactiveGame(uint256 gameId) external;

    function activeGame(uint256 gameId) external;

    function addNewAttribute(Attribute[] calldata attribute) external;

    function setSupportedAttribute(
        uint256 gameId,
        uint256[] memory attributeIds,
        bool isSupported
    ) external;

    function checkSupportedGame(uint256 gameId) external view returns (bool);

    function checkSupportedAttribute(uint256 gameId, uint256 attributeId)
        external
        view
        returns (bool);

    function checkTeamOption(uint256 attributeId) external view returns (bool);

    function getAttributeById(uint256 attributeId)
        external
        view
        returns (Attribute calldata);
}

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

// SPDX-License-Identifier: MIT

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