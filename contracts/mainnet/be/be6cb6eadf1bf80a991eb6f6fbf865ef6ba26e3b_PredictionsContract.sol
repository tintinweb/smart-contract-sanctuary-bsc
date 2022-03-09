// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

interface IPrediction {
    function claimable(uint256 epoch, address user) external view returns (bool);
    function refundable(uint256 epoch, address user) external view returns (bool);
    function getRound(uint256 epoch) external view returns (bool completed, uint256 totalAmount, uint256 bullAmount, uint256 bearAmount, int256 lockPrice, int256 closePrice);
    function getBet(address userAddress, uint256 epoch) external view returns (uint8 position, uint256 amount, uint256 refereeAmount, uint256 referrerAmount, bool claimed);
    function claimFromProxy(address userAddress, uint256[] calldata epochs) external;
    function betBullFromProxy(address userAddress, uint256 epoch) external payable;
    function betBearFromProxy(address userAddress, uint256 epoch) external payable;
    function claimTreasuryFromProxy(address userAddress) external;
    function claimHostedPartnerTreasuryFromProxy(address userAddress) external;
    function claimReferenceBonusFromProxy(address userAddress) external;
    function hasReferenceBonus(address userAddress) external view returns (bool);
    function hostedPartnerTreasuryAmount(address partnerAddress) external view returns (uint256);
}

//prediction contracts are owned by the PredictionFactory contract
contract PredictionsContract is Ownable {

    mapping(uint => address) private predictions;

    //add events to keep added predictions

    //--------

    modifier isPrediction(uint _id) {
        require(predictions[_id] != address(0), "not prediction");
        _;
    }

    function addPrediction(uint id, address predictionAddress) external onlyOwner {
        require(predictionAddress != address(0), "address 0");
        predictions[id] = predictionAddress;
    }

    function removePrediction(uint id) external onlyOwner {
        predictions[id] = address(0);
    }

    function claim(uint id, uint256[] calldata epochs) external isPrediction(id) {
        IPrediction(predictions[id]).claimFromProxy(msg.sender, epochs);
    }

    function betBull(uint id, uint256 epoch) external payable isPrediction(id) {
        IPrediction(predictions[id]).betBullFromProxy{value:msg.value}(msg.sender, epoch);
    }

    function betBear(uint id, uint256 epoch) external payable isPrediction(id) {
        IPrediction(predictions[id]).betBearFromProxy{value:msg.value}(msg.sender, epoch);
    }

    function claimable(uint id, uint256 epoch, address user) external view isPrediction(id) returns (bool) {
        return IPrediction(predictions[id]).claimable(epoch, user);
    }

    function refundable(uint id, uint256 epoch, address user) external view isPrediction(id) returns (bool) {
        return IPrediction(predictions[id]).refundable(epoch, user);
    }

    function getRound(uint id, uint256 epoch) external view returns (bool completed, uint256 totalAmount, uint256 bullAmount, uint256 bearAmount, int256 lockPrice, int256 closePrice) {
        (completed, totalAmount, bullAmount, bearAmount, lockPrice, closePrice) = IPrediction(predictions[id]).getRound(epoch);
    }

    function getBet(uint id, uint256 epoch, address user) external view isPrediction(id) returns (uint8 position, uint256 amount, uint256 refereeAmount, uint256 referrerAmount, bool claimed) {
        (position, amount, refereeAmount, referrerAmount, claimed) = IPrediction(predictions[id]).getBet(user, epoch);
    }

    function claimTreasury(uint id) external isPrediction(id) {
        IPrediction(predictions[id]).claimTreasuryFromProxy(msg.sender);
    }
    
    function claimHostedPartnerTreasury(uint id) external isPrediction(id) {
        IPrediction(predictions[id]).claimHostedPartnerTreasuryFromProxy(msg.sender);
    }

    function claimReferenceBonus(uint id) external isPrediction(id) {
        IPrediction(predictions[id]).claimReferenceBonusFromProxy(msg.sender);
    }

    function hasReferenceBonus(uint id, address user) external view isPrediction(id) returns (bool) {
        return IPrediction(predictions[id]).hasReferenceBonus(user);
    }

    function hostedPartnerTreasuryAmount(uint id, address partnerAddress) external view returns (uint256) {
        return IPrediction(predictions[id]).hostedPartnerTreasuryAmount(partnerAddress);
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