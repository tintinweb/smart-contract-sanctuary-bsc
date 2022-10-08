// SPDX-License-Identifier: MIT
// Honor Protocol - NFT Metadata Part II (Ecosystem)
// Duan
//-----------------------------------------------------------------------------------------------------------------------------------

pragma solidity >= 0.8.17;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HonorEcosystem is Ownable, ReentrancyGuard {

 address public marketDao; // Marketplace
 address public nftstakeDao; // NFTStaking
 address public fusionDao; // Fusion Staking
 address public ateDao; // Anything to Earn
 address public rentDao; // Rent
 
 struct Ecosystem {
  address seller;
  address staker;
  address fusionstaker;
  address rentowner;
  address renter;
 }
  address Seller; address Staker; address FusionStaker; address RentOwner; address Renter;

 mapping(uint => Ecosystem) ArmyEcosystem;
 mapping(uint => Ecosystem) EmblemEcosystem;
 mapping(uint => Ecosystem) HeroEcosystem;

 constructor(){
 }

 // OWNER - Set DAO Smart Contracts & etc
 function setMarketplace(address _marketDao) external onlyOwner {
    marketDao = _marketDao;
 }
  function setNftStakeDao(address _nftstakeDao) external onlyOwner {
    nftstakeDao = _nftstakeDao;
 }
  function setFusioDao(address _fusionDao) external onlyOwner {
    fusionDao = _fusionDao;
 }
  function setAteDao(address _ateDao) external onlyOwner {
    ateDao = _ateDao;
 }
  function setRentDao(address _rentDao) external onlyOwner {
    rentDao = _rentDao;
 }

 function metadataEcos (address _address, uint ecoType, uint Collection, uint _tokenId) external { // owner
    require(msg.sender == marketDao || msg.sender == nftstakeDao || msg.sender == fusionDao || msg.sender == rentDao || msg.sender == owner() , "Protected, Can only be used by Honor Protocol Dao or owner. - Ecosystems");

    Ecosystem storage Id = ArmyEcosystem[_tokenId];
    Ecosystem storage Id2 = EmblemEcosystem[_tokenId];
    Ecosystem storage Id3 = HeroEcosystem[_tokenId];

    if (ecoType == 1) { // Marketplace Seller
        if (Collection == 1){ 
            Id.seller = _address;
        }
        else if (Collection == 2){
            Id2.seller = _address;
        }
        else if (Collection == 3){
            Id3.seller = _address;
        }
    }
    else if (ecoType == 2) { // NFT Staking
        if (Collection == 1){
            Id.staker = _address;
        }
        else if (Collection == 2){
            Id2.staker = _address;
        }
        else if (Collection == 3){
            Id3.staker = _address;
        }
    }
    else if (ecoType == 3) { // Fusion Staker
        if (Collection == 1){
            Id.fusionstaker = _address;
        }
        else if (Collection == 2){
            Id2.fusionstaker = _address;
        }
         else if (Collection == 3){
            Id3.fusionstaker = _address;
         }
    }
    else if (ecoType == 4) { // Rent Owner
        if (Collection == 1){
            Id.rentowner = _address;
        }
        else if (Collection == 2){
            Id2.rentowner = _address;
        }
        else if (Collection == 3){
            Id3.rentowner = _address;
        }
    }
    else if (ecoType == 5) { // Renter
        if (Collection == 1){
            Id.renter = _address;
        }
        else if (Collection == 2){
            Id2.renter = _address;
        }
        else if (Collection == 3){
            Id3.renter = _address;
        }
    }
 }   

 //-----------------------------------------------------------------------------------------------------------------------------------
 // RETURNS
 function checkEcosystem(uint Collection, uint ecoType, uint _tokenId) public view returns (address ECS) {
    if (Collection == 1){ // ArmyRank
        if (ecoType == 1){ // seller
            return ArmyEcosystem[_tokenId].seller;
        }
        else if (ecoType == 2){ // staker
            return ArmyEcosystem[_tokenId].staker;
        }
        else if (ecoType == 3){ // fusion staker
            return ArmyEcosystem[_tokenId].fusionstaker;
        }
        else if (ecoType == 4){ // rent owner
            return ArmyEcosystem[_tokenId].rentowner;
        }
        else if (ecoType == 5){ // renter
            return ArmyEcosystem[_tokenId].renter;
        }
    }
    else if (Collection == 2){ //Emblem
        if (ecoType == 1){ // seller
            return EmblemEcosystem[_tokenId].seller;
        }
        else if (ecoType == 2){ // staker
            return EmblemEcosystem[_tokenId].staker;
        }
        else if (ecoType == 3){ // fusion staker
            return EmblemEcosystem[_tokenId].fusionstaker;
        }
        else if (ecoType == 4){ // rent owner
            return EmblemEcosystem[_tokenId].rentowner;
        }
        else if (ecoType == 5){ // renter
            return EmblemEcosystem[_tokenId].renter;
        }
    }
    else if (Collection == 3){ // War Hero
        if (ecoType == 1){ // seller
            return HeroEcosystem[_tokenId].seller;
        }
        else if (ecoType == 2){ // staker
            return HeroEcosystem[_tokenId].staker;
        }
        else if (ecoType == 3){ // fusion staker
            return HeroEcosystem[_tokenId].fusionstaker;
        }
        else if (ecoType == 4){ // rent owner
            return HeroEcosystem[_tokenId].rentowner;
        }
        else if (ecoType == 5){ // renter
            return HeroEcosystem[_tokenId].renter;
        }
    }
 }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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