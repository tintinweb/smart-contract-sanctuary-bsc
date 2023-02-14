// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMetobadgeFactory.sol";
import "./ISpaceRegistration.sol";

contract MetobadgeFactory is IMetobadgeFactory, Ownable {
    event Issue(uint256 indexed typeId, uint256 indexed spaceId);
    event Update(uint256 indexed typeId);

    ISpaceRegistration spaceRegistration;

    constructor(address _spaceRegistration) public {
        spaceRegistration = ISpaceRegistration(_spaceRegistration);
    }

    Collection[] private collections;
    mapping(uint256 => uint256[]) private spaceAssets;

    function issue(
        uint256 spaceId,
        string memory name,
        string memory description,
        uint256 lifespan,
        string memory signerLogo,
        string memory signerName
    ) public {
        require(spaceRegistration.isAdmin(spaceId, msg.sender), "auth failed");
        Collection storage _collection = collections.push();
        _collection.spaceId = spaceId;
        _collection.lifespan = lifespan;
        _collection.description = description;
        _collection.name = name;

        _collection.signerLogo = signerLogo;
        _collection.signerName = signerName;

        spaceAssets[spaceId].push(collections.length - 1);
        emit Issue(collections.length - 1, spaceId);
    }

    function update(
        uint256 id,
        string memory name,
        string memory description,
        uint256 lifespan,
        string memory signerLogo,
        string memory signerName
    ) public {
        require(
            spaceRegistration.isAdmin(collections[id].spaceId, msg.sender),
            "auth failed"
        );
        Collection storage _collection = collections[id];
        _collection.description = description;
        _collection.lifespan = lifespan;
        _collection.name = name;
        _collection.signerLogo = signerLogo;
        _collection.signerName = signerName;

        emit Update(id);
    }

    function updateSpaceRegistration(address addr) public onlyOwner {
        spaceRegistration = ISpaceRegistration(addr);
    }

    function collection(uint256 id)
        public
        view
        override
        returns (Collection memory)
    {
        require(id < collections.length, "invalid id");
        return collections[id];
    }

    function collectionsBySpace(uint256 spaceId)
        public
        view
        returns (uint256[] memory)
    {
        return spaceAssets[spaceId];
    }
    
    function setSpaceRegistration(address _spaceRegistration) public onlyOwner {
        spaceRegistration = ISpaceRegistration(_spaceRegistration);
    }

    function total() public view returns (uint256) {
        return collections.length;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ISpaceRegistration {

    struct SpaceParam{
        string name;
        string logo;
    }

    function spaceParam(uint id) view external returns(SpaceParam memory);

    function checkMerkle(uint id, bytes32 root, bytes32 leaf, bytes32[] calldata _merkleProof) external view returns (bool);

    function verifySignature(uint id, bytes32 message, bytes calldata signature) view external returns(bool);

    function isAdmin(uint id, address addr) view external returns(bool);

    function isCreator(uint id, address addr) view external returns(bool);

}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMetobadgeFactory {
    struct Collection {
        uint256 spaceId;
        string name;
        string description;
        string signerName;
        string signerLogo;
        uint256 lifespan;
    }

    function collection(uint256 id) external view returns (Collection memory);
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