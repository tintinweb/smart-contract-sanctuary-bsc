import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract GoldGrinder is Ownable {

    uint256 private GOLD_TO_HIRE_1MINER = 12.5 *1 days;//1.08M golds to hire 1 miner
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 2;
    bool private _initialized;
    address payable private recAdd;
    mapping (address => uint256) public goldMiners;
    mapping (address => uint256) private claimedGold;
    mapping (address => uint256) private lastHireTime;
    mapping (address => address) private referrals;
    uint256 private marketGold = 100000*GOLD_TO_HIRE_1MINER;

    mapping (address => bool) private hasParticipated;
    uint256 public uniqueUsers;

    modifier initialized {
      require(_initialized, "Contract not initialized");
      _;
   }
    constructor() {
        recAdd = payable(msg.sender);
    }
    
    function hireMiner(address ref) public initialized {
        
        if(ref != msg.sender && referrals[msg.sender] == address(0) && ref!= address(0)) {
            referrals[msg.sender] = ref;
        }
        
        uint256 goldUsed = getMyGold(msg.sender);
        uint256 newMiners = goldUsed/GOLD_TO_HIRE_1MINER;
        goldMiners[msg.sender] += newMiners;
        claimedGold[msg.sender] -= (GOLD_TO_HIRE_1MINER * newMiners);
        lastHireTime[msg.sender] = block.timestamp;
        
        //send referral gold
        claimedGold[referrals[msg.sender]] += goldUsed/8;
        
        //boost market to nerf miners hoarding
        marketGold += goldUsed/5;

        if(!hasParticipated[msg.sender]) {
            hasParticipated[msg.sender] = true;
            uniqueUsers++;
        }
    }
    
    function sellGold() public initialized{
        uint256 hasGold = getMyGold(msg.sender);
        uint256 goldValue = calculateGoldSell(hasGold);
        uint256 fee = devFee(goldValue);
        claimedGold[msg.sender] = 0;
        lastHireTime[msg.sender] = block.timestamp;
        marketGold += hasGold;
        recAdd.transfer(fee);
        payable (msg.sender).transfer(goldValue-fee);
        if(goldMiners[msg.sender] == 0) uniqueUsers--;
    }
    
    function buyGold(address ref) public payable initialized {
        uint256 goldBought = calculateGoldBuy(msg.value,address(this).balance-msg.value);
        goldBought -= devFee(goldBought);
        uint256 fee = devFee(msg.value);
        recAdd.transfer(fee);
        claimedGold[msg.sender] += goldBought;
        hireMiner(ref);
    }

    function seedMarket() public payable onlyOwner  {
        require(!_initialized, "Already initialized");
        _initialized = true;
    }
    
    function goldRewardsToBNB(address adr) public view returns(uint256) {
        uint256 hasGold = getMyGold(adr);
        uint256 goldValue = calculateGoldSell(hasGold);
        return goldValue;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return (PSN*bs)/(PSNH+(PSN*rs+PSNH*rt)/rt);
    }
    
    function calculateGoldSell(uint256 gold) public view returns(uint256) {
        return calculateTrade(gold,marketGold,address(this).balance);
    }
    
    function calculateGoldBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketGold);
    }
    
    function calculateGoldBuySimple(uint256 eth) public view returns(uint256) {
        return calculateGoldBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return amount*devFeeVal/100;
    }
    
    function getMyGold(address adr) public view returns(uint256) {
        return claimedGold[adr]+ getGoldSincelastHireTime(adr);
    }
    
    function getGoldSincelastHireTime(address adr) public view returns(uint256) {
        uint256 secondsPassed=Math.min(GOLD_TO_HIRE_1MINER,block.timestamp-lastHireTime[adr]);
        return secondsPassed*goldMiners[adr];
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
// OpenZeppelin Contracts v4.4.1 (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
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