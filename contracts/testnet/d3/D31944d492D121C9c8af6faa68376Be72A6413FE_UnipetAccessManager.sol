// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./IUnipetAccessManager.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UnipetAccessManager is IUnipetAccessManager, Ownable {
    bool publicAll;
    bool bornPublicAll;
    bool evolvePublicAll;
    bool breedPublicAll;
    bool destroyPublicAll;

    mapping(address => bool) bornWhilelist;
    mapping(address => bool) evolveWhilelist;
    mapping(address => bool) breedWhilelist;
    mapping(address => bool) destroyWhilelist;

    function setPublicAll(bool _publicAll) public onlyOwner {
        publicAll = _publicAll;
    }

    function setBornWhilelist(
        address[] memory _tos,
        bool[] memory _isWhilelists
    ) external onlyOwner {
        require(_tos.length == _isWhilelists.length, "Error: input invalid");
        for (uint8 i = 0; i < _tos.length; i++) {
            bornWhilelist[_tos[i]] = _isWhilelists[i];
        }
    }

    function setEvolveWhilelist(
        address[] memory _tos,
        bool[] memory _isWhilelists
    ) external onlyOwner {
        require(_tos.length == _isWhilelists.length, "Error: input invalid");
        for (uint8 i = 0; i < _tos.length; i++) {
            evolveWhilelist[_tos[i]] = _isWhilelists[i];
        }
    }

    function setBreedWhilelist(
        address[] memory _tos,
        bool[] memory _isWhilelists
    ) external onlyOwner {
        require(_tos.length == _isWhilelists.length, "Error: input invalid");
        for (uint8 i = 0; i < _tos.length; i++) {
            breedWhilelist[_tos[i]] = _isWhilelists[i];
        }
    }

    function setDestroyWhilelist(
        address[] memory _tos,
        bool[] memory _isWhilelists
    ) external onlyOwner {
        require(_tos.length == _isWhilelists.length, "Error: input invalid");
        for (uint8 i = 0; i < _tos.length; i++) {
            destroyWhilelist[_tos[i]] = _isWhilelists[i];
        }
    }

    function setBornPublicAll(bool _bornPublicAll) public onlyOwner {
        bornPublicAll = _bornPublicAll;
    }

    function setEvolvePublicAll(bool _evolvePublicAll) public onlyOwner {
        evolvePublicAll = _evolvePublicAll;
    }

    function setBreedPublicAll(bool _breedPublicAll) public onlyOwner {
        breedPublicAll = _breedPublicAll;
    }

    function setDestroyPublicAll(bool _destroyPublicAll) public onlyOwner {
        destroyPublicAll = _destroyPublicAll;
    }

    function isBornAllowed(address _caller, string memory _gene)
        external
        view
        override
        returns (bool)
    {
        //TODO: can check _gene validation
        return publicAll || bornPublicAll || bornWhilelist[_caller];
    }

    function isEvolveAllowed(
        address _caller,
        string memory _gene,
        uint256[] memory _nftIds
    ) external view override returns (bool) {
        //TODO: can check _gene and _nftId validation
        return publicAll || bornPublicAll || evolveWhilelist[_caller];
    }

    function isBreedAllowed(
        address _caller,
        uint256 _nftId1,
        uint256 _nftId2
    ) external view override returns (bool) {
        //TODO: can check _gene and _nftId validation
        return publicAll || bornPublicAll || breedWhilelist[_caller];
    }

    function isDestroyAllowed(address _caller, uint256 _nftId)
        external
        view
        override
        returns (bool)
    {
        //TODO: can check _gene and _nftId validation
        return publicAll || bornPublicAll || destroyWhilelist[_caller];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IUnipetAccessManager {
    function isBornAllowed(address _caller, string memory _gene)
        external
        view
        returns (bool);

    function isEvolveAllowed(
        address _caller,
        string memory _gene,
        uint256[] memory _nftIds
    ) external view returns (bool);

    function isBreedAllowed(
        address _caller,
        uint256 _nftId1,
        uint256 _nftId2
    ) external view returns (bool);

    function isDestroyAllowed(address _caller, uint256 _nftId)
        external
        view
        returns (bool);
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