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

pragma solidity ^0.8.0;

interface IPartnership {
    function createNFT(string memory _URI, bool _hasWhiteList, address _owner, string memory _name, string memory _symbol) external returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../interfaces/IPartnership.sol";

contract PartnershipRouter is Ownable{
    uint public count;
    mapping(uint => address) public nftPartner;
    address public factory;

    event NewPartnershipNFT(uint _id, address _nft);
    event ChangeFactory(address _old, address _new);

    constructor(address _factory) {
        factory = _factory;
    }

    function createPartnershipCollection(string memory _URI, bool _hasWhiteList, address _owner, string memory _name, string memory _symbol) external onlyOwner {
        count++;
        address _collection = IPartnership(factory).createNFT(_URI, _hasWhiteList, _owner, _name, _symbol);
        nftPartner[count] = _collection;
        emit NewPartnershipNFT(count, _collection);
    }

    function changeFactory(address _factory) external onlyOwner {
        require(_factory != address (0), "PartnershipRouter: !zero");
        address _old = factory;
        factory = _factory;
        emit ChangeFactory(_old, _factory);
    }

    function getAllNFT(uint256 _page, uint256 _limit) external view returns(address[] memory _result, uint _length) {
        uint _from = _page * _limit;
        _length = count;
        uint _to = _min((_page + 1) * _limit, _length);
        address[] memory _result = new address[](_to - _from);
        for (uint i = 0; _from < _to; i++) {
            _result[i] = nftPartner[i+1];
            ++_from;
        }
        return (_result, _length);
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}