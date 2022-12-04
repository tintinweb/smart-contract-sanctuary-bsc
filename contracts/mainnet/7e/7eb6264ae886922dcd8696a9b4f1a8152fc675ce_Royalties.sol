/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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
    uint256 public communityClaimed = 0;
    uint256 public creatorClaimed = 0;

    uint256 public creatorRoyalties = 10; // percentage from total NFT price
    uint256 public communityRoyalties = 0; // percentage from total NFT price

    uint256 public collectionSize = 10000;

    address public tokenFeesAddress;
    address public creatorAddress;
    address public artist;

    mapping(uint256 => uint256) private communityClaims;

    mapping(address => uint256) private addressClaims;

    event CommunityClaimed(uint256 tokenID);
    event CreatorClaimed(uint256 amount);
    event Received(address, uint);


    constructor() {
        tokenFeesAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        creatorAddress = 0xAEff790029DeBf3B956A65Fa915097347Ef63eb6;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @dev set royalties address (weth)
    function setTokenFeesAddress(address _tokenFeesAddress) external onlyOwner {
        tokenFeesAddress = _tokenFeesAddress;
    }

    /// @dev set creator address, can be another contract
    function setCreatorAddress(address _creatorAddress) external onlyOwner {
        creatorAddress = _creatorAddress;
    }

    /// @dev set only smaller collection size, can't increase size
    function setCollectionSize(uint256 _collectionSize) external onlyOwner {
        require(
            _collectionSize < collectionSize,
            "Cannot increase collection size"
        );
        collectionSize = _collectionSize;
    }

    /// @dev set creator royalties
    function setCreatorRoyalties(uint256 _creatorRoyalties) external onlyOwner {
        creatorRoyalties = _creatorRoyalties;
    }

    /// @dev get total royalties
    /// @return total royalties
    function getTotalRoyalties() public view returns (uint256) {
        return creatorRoyalties ;
    }

    function getRoyalties() public view returns (uint256) {
        return (creatorRoyalties);
    }

    /// @dev get total collected
    /// @return total collected
    function getTotalCollected() public view returns (uint256) {
        uint256 balance = ERC20(tokenFeesAddress).balanceOf(address(this));
        return balance + creatorClaimed;
    }

    /// @dev get creator balance
    /// @return creator total balance
    function getCreatorBalance() public view returns (uint256) {
        uint256 _creatorRoyalties = (creatorRoyalties * 100) /
            getTotalRoyalties();
        return (getTotalCollected() * _creatorRoyalties) / 100 - creatorClaimed;
    }

    /// @dev get address tot claims
    /// @return address total claims
    function getAddressClaims(address account) public view returns (uint256) {
        return addressClaims[account];
    }

    /// @dev claim creator royalties
    function claimCreator() external {
        uint256 balance = getCreatorBalance();
        require(balance > 0, "No balance to claim");
        creatorClaimed = creatorClaimed + balance;
        ERC20(tokenFeesAddress).transfer(creatorAddress, balance);

        uint256 native = address(this).balance;
        (bool os, ) = payable(creatorAddress).call{value: native}("");
        require(os);

        emit CreatorClaimed(balance);
    }

    function withdraw() external {
        uint256 balance = address(this).balance;
        (bool os, ) = payable(creatorAddress).call{value: balance}("");
        require(os);
    }
}