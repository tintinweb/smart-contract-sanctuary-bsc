// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BNBCaptain is Ownable {
    uint256 public constant TREASURES_TO_HIRE_1SAILOR = 2592000;
    uint256 private constant PSN = 10000;
    uint256 private constant PSNH = 5000;
    uint256 private constant developerFee = 5;
    bool public initialized = false;
    address payable public ceoAddress;
    mapping(address => uint256) public hasSailors;
    mapping(address => uint256) public claimedTreasures;
    mapping(address => uint256) public lastHire;
    mapping(address => address) public referrers;
    uint256 private marketTreasures;

    constructor() {
        ceoAddress = payable(owner());
    }

    function hireSailors() public {
        require(initialized);

        uint256 treasuresUsed = getMyTreasures();
        uint256 newSailors = treasuresUsed / TREASURES_TO_HIRE_1SAILOR;
        hasSailors[msg.sender] += newSailors;
        claimedTreasures[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;

        // send referral treasures
        address referrer = referrers[msg.sender];
        claimedTreasures[referrer] += treasuresUsed / 10;

        //boost market to nerf sailors hoarding
        marketTreasures += treasuresUsed / 5;
    }

    function sellTreasures() public {
        require(initialized);
        uint256 hasTreasures = getMyTreasures();
        uint256 treasuresValue = calculateTreasureSell(hasTreasures);
        uint256 fee = devFee(treasuresValue);
        claimedTreasures[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        marketTreasures += hasTreasures;
        ceoAddress.transfer(fee);
        payable(msg.sender).transfer(treasuresValue - fee);
    }

    function buyTreasures(address ref) public payable {
        require(initialized);
        require(msg.value >= 0.01 ether, "At least 0.01 BNB");

        uint256 treasuresBought = calculateTreasureBuy(
            msg.value,
            address(this).balance - msg.value
        );
        treasuresBought -= devFee(treasuresBought);
        uint256 fee = devFee(msg.value);
        ceoAddress.transfer(fee);
        claimedTreasures[msg.sender] += treasuresBought;
        setReferrer(ref);
        hireSailors();
    }

    function setReferrer(address ref) private {
        if (referrers[msg.sender] != address(0)) return;

        if (ref == msg.sender || ref == address(0) || hasSailors[ref] == 0) {
            referrers[msg.sender] = ceoAddress;
        } else {
            referrers[msg.sender] = ref;
        }
    }

    // trade balancing algorithm
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public pure returns (uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return (PSN * bs) / (PSNH + ((PSN * rs + PSNH * rt) / rt));
    }

    function calculateTreasureSell(uint256 treasures)
        public
        view
        returns (uint256)
    {
        if (treasures > 0) {
            return
                calculateTrade(
                    treasures,
                    marketTreasures,
                    address(this).balance
                );
        } else {
            return 0;
        }
    }

    function calculateTreasureBuy(uint256 bnbAmount, uint256 contractBalance)
        public
        view
        returns (uint256)
    {
        return calculateTrade(bnbAmount, contractBalance, marketTreasures);
    }

    function calculateTreasureBuySimple(uint256 bnbAmount)
        public
        view
        returns (uint256)
    {
        return calculateTreasureBuy(bnbAmount, address(this).balance);
    }

    function calculateHireSailors(uint256 bnbAmount)
        public
        view
        returns (uint256)
    {
        uint256 treasuresBought = calculateTreasureBuy(
            bnbAmount,
            address(this).balance
        );
        treasuresBought -= devFee(treasuresBought);
        uint256 treasuresUsed = getMyTreasures();
        treasuresUsed += treasuresBought;
        uint256 newSailors = treasuresUsed / TREASURES_TO_HIRE_1SAILOR;
        return newSailors;
    }

    function devFee(uint256 amount) private pure returns (uint256) {
        return (amount * developerFee) / 100;
    }

    function seedMarket() public payable onlyOwner {
        require(marketTreasures == 0);
        initialized = true;
        marketTreasures = 259200000000;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMySailors() public view returns (uint256) {
        return hasSailors[msg.sender];
    }

    function getMyTreasures() public view returns (uint256) {
        return
            claimedTreasures[msg.sender] + getTreasureSinceLastHire(msg.sender);
    }

    function getSecondsPassed(address adr) public view returns (uint256) {
        if (lastHire[adr] == 0) return 0;

        return min(TREASURES_TO_HIRE_1SAILOR, block.timestamp - lastHire[adr]);
    }

    function getTreasureSinceLastHire(address adr)
        public
        view
        returns (uint256)
    {
        return getSecondsPassed(adr) * hasSailors[adr];
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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