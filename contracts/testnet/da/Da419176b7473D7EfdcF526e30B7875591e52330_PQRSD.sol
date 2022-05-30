//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PQRSD is Ownable {
    using Counters for Counters.Counter;
    //mapping(address => uint256) private _currentPQRSD;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _owners;

    event StatusChanged(
        address indexed owner,
        uint256 indexed tokenId,
        bytes32 indexed newStatus
    );
    event AdminAdded(address indexed actor, address newAdmin);
    event AdminRemoved(address indexed actor, address oldAdmin);

    modifier onlyAdminOrEmitter(uint256 tokenId) {
        require(
            _isEmitterOrAdmin(tokenId),
            "PQRSD: You are not the emitter of this pqrsd or an admin"
        );
        _;
    }

    mapping(address => bool) public admins;

    modifier onlyAdmins() {
        require(
            admins[msg.sender] || msg.sender == owner(),
            "You are not an admin"
        );
        _;
    }

    //Auto increment
    Counters.Counter private _tokenIds;

    function _isEmitterOrAdmin(uint256 tokenId) internal view returns (bool) {
        return
            _owners[tokenId] == msg.sender ||
            admins[msg.sender] ||
            msg.sender == owner();
    }

    /// @dev given
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "PQRSD: owner query for nonexistent pqrsd"
        );
        return owner;
    }

    //Amount of pqrsds a person has active
    function balanceOf(address _wallet) public view returns (uint256) {
        return _balances[_wallet];
    }

    function stringToBytes32(string memory source)
        public
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function create(address _tokenOwner) public onlyAdmins returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _balances[_tokenOwner] += 1;
        _owners[newItemId] = _tokenOwner;
        //_currentPQRSD[msg.sender] = newItemId;
        _tokenIds.increment();
        emit StatusChanged(_tokenOwner, newItemId, "CREATED");
        return newItemId;
    }

    function update(uint256 _tokenId, string memory _newState)
        public
        onlyAdminOrEmitter(_tokenId)
    {
        address _owner = _owners[_tokenId];
        emit StatusChanged(_owner, _tokenId, stringToBytes32(_newState));
    }

    function close(uint256 _tokenId)
        public
        onlyAdminOrEmitter(_tokenId)
        returns (bool)
    {
        address _owner = _owners[_tokenId];
        //reduce balances
        _balances[_owner] -= 1;
        //clean owner
        _owners[_tokenId] = address(0);
        emit StatusChanged(_owner, _tokenId, "CLOSED");
        return true;
    }

    /// @dev adds a new wallet to the admin map
    function addAdmin(address _newAdmin) public onlyOwner {
        admins[_newAdmin] = true;
        emit AdminAdded(_msgSender(), _newAdmin);
    }

    /// @dev removes a wallet from the admin map
    function removeAdmin(address _admin) public onlyOwner {
        require(
            _admin != owner(),
            "CertificadoTIL: Owner cannot be removed as admin"
        );
        admins[_admin] = false;
        emit AdminRemoved(_msgSender(), _admin);
    }

    /// @dev checks if wallet is an admin
    function isAdmin(address _admin) public view returns (bool) {
        return admins[_admin];
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
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