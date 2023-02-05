// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Provenance is Ownable {
    enum ActionStatus {
        REMOVED,
        ADDED
    }

    struct Producer {
        string name;
        string producer_type;
        bool certification;
        ActionStatus action_status;
    }

    struct Product {
        address producer_address;
        string name;
        uint date_time_of_origin;
        ActionStatus action_status;
    }

    mapping(address => Producer) public producers;
    mapping(string => Product) public products;
    address[] public producer_list;
    string[] public product_list;
    uint256 public producer_count;
    uint256 public product_count;
    
    constructor() {
        producer_count = 0;
        product_count = 0;
    }

    function addProducer(address from, string memory name, string memory producer_type ) public {
      require(producers[from].action_status != ActionStatus.ADDED, "This producer is already exist.");
      producers[from] = Producer(name, producer_type, false, ActionStatus.ADDED);
      producer_list.push(from);
      producer_count ++;
    }

    function findProducer(address recipient) public view returns (Producer memory) {
        return producers[recipient];
    }

    function removeProducer(address recipient) public onlyOwner{
        producers[recipient].action_status = ActionStatus.REMOVED;
    }

    function certifyProducer(address recipient) public onlyOwner {
        producers[recipient].certification = true;
    }

    function addProduct(string memory pub_number, string memory name) public {
        require(products[pub_number].action_status != ActionStatus.ADDED, "This product is already exist.");
        products[pub_number] = Product(msg.sender, name, block.timestamp, ActionStatus.ADDED);
        product_list.push(pub_number);
        product_count ++;
    }

    function removeProduct(string memory pub_number) public onlyOwner {
        products[pub_number].action_status = ActionStatus.REMOVED;
    }
    
    function findProduct(string memory pub_number) public view returns (Product memory) {
        return products[pub_number];
    }

}