// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMetopianSBTFactoryV2.sol";
import "./ISpaceRegistration.sol";

contract MetopianSBTFactoryV2 is IMetopianSBTFactoryV2, Ownable {
    event Issue(uint256 typeId, uint256 spaceId);
    event Update(uint256 typeId);

    ISpaceRegistration spaceRegistration =
        ISpaceRegistration(0x28F569e8E38659fbE5d84D18cDA901B157D6Dd84);
        
    // ISpaceRegistration spaceRegistration =
    //     ISpaceRegistration(0x6D9e5B24F3a82a42F3698c1664004E9f1fBD9cEA);

    struct TokenTypeStorage {
        uint256 spaceId;
        string description;
        mapping(string => uint256) fieldIndices;
        string[] fields;
        string[] values;
    }

    TokenTypeStorage[] private tokenTypes;
    mapping(uint256 => uint256[]) private spaceAssets;

    function issue(
        uint256 spaceId,
        string memory description,
        string[] memory fields,
        string[] memory values
    ) public {
        require(spaceRegistration.isAdmin(spaceId, msg.sender), "auth failed");
        TokenTypeStorage storage typeStorage = tokenTypes.push();
        typeStorage.spaceId = spaceId;
        typeStorage.description = description;
        spaceAssets[spaceId].push(tokenTypes.length - 1);
        updateTypeAttrs(typeStorage, fields, values);
        emit Issue(tokenTypes.length - 1, spaceId);
    }

    function updateTypeAttrs(
        TokenTypeStorage storage typeStorage,
        string[] memory fields,
        string[] memory values
    ) private {
        for (uint256 i = 0; i < fields.length; i++) {
            if (typeStorage.fieldIndices[fields[i]] > 0) {
                typeStorage.values[typeStorage.fieldIndices[fields[i]] -1] = values[i];
            } else {
                typeStorage.fields.push(fields[i]);
                typeStorage.values.push(values[i]);
                typeStorage.fieldIndices[fields[i]] = typeStorage.fields.length;
            }
        }
    }

    function update(
        uint256 id,
        string memory description,
        string[] memory fields,
        string[] memory values
    ) public {
        require(
            spaceRegistration.isAdmin(tokenTypes[id].spaceId, msg.sender),
            "auth failed"
        );
        TokenTypeStorage storage typeStorage = tokenTypes[id];
        typeStorage.description = description;
        updateTypeAttrs(typeStorage, fields, values);
        emit Update(id);
    }

    function updateSpaceRegistration(address addr) public onlyOwner {
        spaceRegistration = ISpaceRegistration(addr);
    }

    function tokenType(uint256 id)
        public
        view
        override
        returns (TokenType memory _type)
    {
        ISpaceRegistration.SpaceParam memory space = spaceRegistration
            .spaceParam(tokenTypes[id].spaceId);
        _type.spaceId = tokenTypes[id].spaceId;
        _type.description = tokenTypes[id].description;
        _type.fields = tokenTypes[id].fields;
        _type.values = tokenTypes[id].values;
        _type.spaceName = space.name;
        _type.spaceLogo = space.logo;
        return _type;
    }

    function tokenTypeBySpace(uint256 spaceId)
        public
        view
        returns (TokenType[] memory)
    {
        ISpaceRegistration.SpaceParam memory space = spaceRegistration
            .spaceParam(spaceId);
        TokenType[] memory result = new TokenType[](
            spaceAssets[spaceId].length
        );
        for (uint256 i = 0; i < spaceAssets[spaceId].length; i++) {
            TokenType memory _type;
            _type.spaceId = tokenTypes[spaceAssets[spaceId][i]].spaceId;
            _type.description = tokenTypes[spaceAssets[spaceId][i]].description;
            _type.fields = tokenTypes[spaceAssets[spaceId][i]].fields;
            _type.values = tokenTypes[spaceAssets[spaceId][i]].values;
            _type.spaceName = space.name;
            _type.spaceLogo = space.logo;
            result[i] = _type;
        }
        return result;
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

interface IMetopianSBTFactoryV2 {
    struct TokenType{
        uint spaceId;
        string spaceName;
        string spaceLogo;
        string description;
        string[] fields;
        string[] values;
    }

    function tokenType(uint id) external view returns(TokenType memory);
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