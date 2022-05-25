/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// File: contracts/common/interfaces/IOperator.sol

pragma solidity ^0.8.0;

interface IOperator {
    event AddNewOperator(address indexed operator);

    function operators(address) external view returns (bool);

    function addOperator(address account) external;

    function removeOperator(address account) external;
}

// File: contracts/interfaces/IAccessoryManager.sol

pragma solidity ^0.8.0;

interface IAccessoryManager {
    struct Accessory {
		bool active;
		string name;
        uint8 maxStar;
	}
    function getAllAccessory() view external returns (Accessory[] memory accessories);
    function addAccessory(string memory name, uint8 maxStar) external returns(uint256 id);
    function isExitedAccessory(uint256 id) view external returns(bool);
    function deactiveAccessory(uint256 id) external;
    function activeAccessory(uint256 id) external;
    function getMaxStar(uint id) view external returns(uint8);
}
// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/*
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

// File: contracts/common/Operator.sol

pragma solidity ^0.8.0;



contract Operator is IOperator, Ownable {
  mapping(address => bool) public override operators;

  constructor() {
    operators[msg.sender] = true;
  }

  modifier onlyOperator() {
    require(operators[msg.sender], "Unauthorized");
    _;
  }

  function addOperator(address account) external override onlyOwner {
    require(!operators[account], "Account was operator");
    operators[account] = true;
  }

  function removeOperator(address account) external override onlyOwner {
    require(operators[account], "Account is not operator");
    operators[account] = false;
  }
}

// File: @openzeppelin/contracts/security/Pausable.sol



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

// File: contracts/AccessoryManager.sol

pragma solidity ^0.8.0;




contract AccessoryManager is IAccessoryManager, Operator, Pausable {
    mapping(uint => Accessory) public accessories;
    uint private len;

    modifier onlyExisted(uint id) {
        require(id < len, "Accessory is not existed");
        _;
    }

    function addAccessory(
        string memory name,
        uint8 maxStar
    ) external override onlyOperator whenNotPaused returns (uint id) {
        id = len;
        Accessory storage accessory = accessories[id];
        accessory.name = name;
        accessory.active = true;
        accessory.maxStar = maxStar;
        len++;
    }

    function updateMaxStar(uint id, uint8 maxStar) external onlyOperator onlyExisted(id) whenNotPaused {
        Accessory storage accessory = accessories[id];
        accessory.maxStar = maxStar;
    }

    function getAllAccessory() external view override returns (Accessory[] memory ) {
        Accessory[] memory _accessories = new Accessory[](len);
        for (uint i; i < len; i++) {
            _accessories[i] = accessories[i];
        }
        return _accessories;
    }

    function deactiveAccessory(uint id) external override onlyOperator onlyExisted(id) whenNotPaused {
        Accessory storage accessory = accessories[id];
        accessory.active = false;
    }

    function activeAccessory(uint id) external override onlyOperator onlyExisted(id) whenNotPaused {
        Accessory storage accessory = accessories[id];
        accessory.active = true;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function isExitedAccessory(uint id) view external override returns(bool) {
        Accessory storage accessory = accessories[id];
        return accessory.active;
    }

    function getMaxStar(uint id) view external override returns(uint8) {
        Accessory storage accessory = accessories[id];
        return accessory.maxStar;
    }

}