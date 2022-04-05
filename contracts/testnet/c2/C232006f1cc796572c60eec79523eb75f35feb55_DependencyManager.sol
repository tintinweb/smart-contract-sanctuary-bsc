// contracts/utils/DependencyManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DependencyManager is Ownable {
    address public bitmonNFT;
    address public superchargerNFT;
    address public bitmonSpawner;
    address public bitmonGeneScientist;
    address public marketManager;
    address public randomProvider;
    address public saleManager;

    /**
     * @dev Get Bitmon NFT
     */
    function getBitmonNFT() external view returns (address) {
        return bitmonNFT;
    }

    /**
     * @dev Set Bitmon NFT
     */
    function setBitmonNFT(address _bitmonNFT) external onlyOwner {
        require(_bitmonNFT != address(0), "zero address");
        bitmonNFT = _bitmonNFT;
    }

    /**
     * @dev Get Supercharger NFT
     */
    function getSuperchargerNFT() external view returns (address) {
        return superchargerNFT;
    }

    /**
     * @dev Set Supercharger NFT
     */
    function setSuperchargerNFT(address _superchargerNFT) external onlyOwner {
        require(_superchargerNFT != address(0), "zero address");
        superchargerNFT = _superchargerNFT;
    }

    /**
     * @dev Get Bitmon Spawner
     */
    function getBitmonSpawner() external view returns (address) {
        return bitmonSpawner;
    }

    /**
     * @dev Set Bitmon Spawner
     */
    function setBitmonSpawner(address _bitmonSpawner) external onlyOwner {
        require(_bitmonSpawner != address(0), "zero address");
        bitmonSpawner = _bitmonSpawner;
    }

    /**
     * @dev Get Bitmon Gene Scientist
     */
    function getBitmonGeneScientist() external view returns (address) {
        return bitmonGeneScientist;
    }

    /**
     * @dev Set Bitmon Gene Scientist
     */
    function setBitmonGeneScientist(address _bitmonGeneScientist) external onlyOwner {
        require(_bitmonGeneScientist != address(0), "zero address");
        bitmonGeneScientist = _bitmonGeneScientist;
    }

    /**
     * @dev Get Market Manager
     */
    function getMarketManager() external view returns (address) {
        return marketManager;
    }

    /**
     * @dev Set MarketManager
     */
    function setMarketManager(address _marketManager) external onlyOwner {
        require(_marketManager != address(0), "zero address");
        marketManager = _marketManager;
    }

    /**
     * @dev Get Random Provider
     */
    function getRandomProvider() external view returns (address) {
        return randomProvider;
    }

    /**
     * @dev Set Random Provider
     */
    function setRandomProvider(address _randomProvider) external onlyOwner {
        require(_randomProvider != address(0), "zero address");
        randomProvider = _randomProvider;
    }

    /**
     * @dev Get Sale Manager
     */
    function getSaleManager() external view returns (address) {
        return saleManager;
    }

    /**
     * @dev Set Sale Manager
     */
    function setSaleManager(address _saleManager) external onlyOwner {
        require(_saleManager != address(0), "zero address");
        saleManager = _saleManager;
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