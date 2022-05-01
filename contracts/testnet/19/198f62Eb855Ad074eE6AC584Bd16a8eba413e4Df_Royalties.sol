// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address account, uint256 amount) external;
}

interface ERC721 {
    function ownerOf(uint256 tokenId) external returns (address);
}

/// @title Royalties for Non-Fungible Tokens
/// @dev Contract for the split between community royalties and dev royalties
///
contract Royalties is Ownable {
    uint256 public claimedAmount = 0;

    uint256 public royatlyRate = 5; // percentage from total NFT price
    uint256 developerPercentage = 8;
    uint256 public collectionSize = 20000;

    address public tokenFeesAddress; // WAVAX / WBNB / WETH / WMATIC
    address public collectionAddress; // the collection address

    address private developerAddress;

    mapping(address => uint256) private addressClaims;

    event ClaimedOwner(uint256 amount);
    event ClaimedDeveloper(uint256 amount);

    event RoyaltiesCreated(address collectionAddress);

    constructor(
        address _tokenFeesAddress,
        address _developerAddress,
        address _collectionAddress,
        uint256 _collectionSize
    ) {
        tokenFeesAddress = _tokenFeesAddress;
        developerAddress = _developerAddress;
        collectionAddress = _collectionAddress;
        collectionSize = _collectionSize;
        emit RoyaltiesCreated(collectionAddress);
    }

    /// @dev set royalties address (wavax)
    function setTokenFeesAddress(address _tokenFeesAddress) external onlyOwner {
        tokenFeesAddress = _tokenFeesAddress;
    }

    function setDeveloperAddress(address _newAddress) external {
        require(msg.sender == developerAddress, "Not authorized");
        require(_newAddress != address(0), "Invalid new address");
        developerAddress = _newAddress;
    }

    /// @dev set only smaller collection size, can't increase size
    function setCollectionSize(uint256 _collectionSize) external onlyOwner {
        require(_collectionSize < collectionSize, "Cannot increase collection size");
        collectionSize = _collectionSize;
    }

    function setRoyaltieRate(uint256 _royatlyRate) external onlyOwner {
        royatlyRate = _royatlyRate;
    }

    /// @dev get total royalties
    /// @return total royalties
    function getTotalRoyalties() public view returns (uint256) {
        return royatlyRate;
    }

    /// @dev get royalties split
    /// @return royalty rate
    function getRoyalties() public view returns (uint256) {
        return (royatlyRate);
    }

    /// @dev get total collected
    /// @return total collected
    function getTotalCollected() public view returns (uint256) {
        uint256 balance = ERC20(tokenFeesAddress).balanceOf(address(this));
        return balance + claimedAmount;
    }

    /// @dev get balance
    /// @return total balance
    function getBalance() public view returns (uint256) {
        uint256 _royatlyRate = (royatlyRate * 100) / getTotalRoyalties();
        return (getTotalCollected() * _royatlyRate) / 100 - claimedAmount;
    }

    /// @dev get address tot claims
    /// @return address total claims
    function getAddressClaims(address account) public view returns (uint256) {
        return addressClaims[account];
    }

    uint256 ownerReserved;
    uint256 developerReserved;

    /// @dev claim royalties
    function claimOwner() external onlyOwner {
        uint256 balance = getBalance();
        require(balance > 0, "No balance to claim");
        uint256 developerShare = (balance * developerPercentage) / 100;
        uint256 ownerShare = balance - developerShare;
        developerReserved += developerShare;

        ERC20(tokenFeesAddress).transfer(msg.sender, ownerReserved + ownerShare);
        claimedAmount += balance;
        emit ClaimedOwner(ownerReserved + ownerShare);
    }

    /// @dev claim royalties
    function claimDeveloper() external {
		require(msg.sender==developerAddress, "Caller not developer");
        uint256 balance = getBalance();
        require(balance > 0, "No balance to claim");
        require(developerAddress != address(0), "Invalid developer address");
        uint256 developerShare = (balance * developerPercentage) / 100;
        uint256 ownerShare = balance - developerShare;
        ownerReserved += ownerShare;
        ERC20(tokenFeesAddress).transfer(developerAddress, developerReserved + developerShare);
        claimedAmount += balance;
        emit ClaimedDeveloper(developerReserved + developerShare);
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