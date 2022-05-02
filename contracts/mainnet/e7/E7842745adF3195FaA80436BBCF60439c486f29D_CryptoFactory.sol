/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

/*


  /$$$$$$                                  /$$               /$$$$$$$$                  /$$                                  
 /$$__  $$                                | $$              | $$_____/                 | $$                                  
| $$  \__/  /$$$$$$  /$$   /$$  /$$$$$$  /$$$$$$    /$$$$$$ | $$    /$$$$$$   /$$$$$$$/$$$$$$    /$$$$$$   /$$$$$$  /$$   /$$
| $$       /$$__  $$| $$  | $$ /$$__  $$|_  $$_/   /$$__  $$| $$$$$|____  $$ /$$_____/_  $$_/   /$$__  $$ /$$__  $$| $$  | $$
| $$      | $$  \__/| $$  | $$| $$  \ $$  | $$    | $$  \ $$| $$__/ /$$$$$$$| $$       | $$    | $$  \ $$| $$  \__/| $$  | $$
| $$    $$| $$      | $$  | $$| $$  | $$  | $$ /$$| $$  | $$| $$   /$$__  $$| $$       | $$ /$$| $$  | $$| $$      | $$  | $$
|  $$$$$$/| $$      |  $$$$$$$| $$$$$$$/  |  $$$$/|  $$$$$$/| $$  |  $$$$$$$|  $$$$$$$ |  $$$$/|  $$$$$$/| $$      |  $$$$$$$
 \______/ |__/       \____  $$| $$____/    \___/   \______/ |__/   \_______/ \_______/  \___/   \______/ |__/       \____  $$
                     /$$  | $$| $$                                                                                  /$$  | $$
                    |  $$$$$$/| $$                                                                                 |  $$$$$$/
                     \______/ |__/                                                                                  \______/ 

Website: cryptofactory.site
Telegram: https://t.me/CryptoFactoryBNB
Discord: https://discord.gg/8d4cQNeMSe
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
}

contract CryptoFactory is Context, Ownable {

    // Formula values
    uint256 private constant PSN = 10000;
    uint256 private PSNH = 5000;

    //Development + Marketing fee
    uint256 private constant devFeeVal = 6;

    uint256 public constant GEARS_TO_HIRE_WORKER = 864000; // 86400/864000 / 0.1 => 10% Daily return

    modifier initialized {
      require(_initialized, "Contract not initialized");
      _;
    }

    struct User {
        uint256 currentDeposit;
        uint256 workers; 
        uint256 claimedGears;
        uint256 lastHire;
        uint256 refferalBonus;
        uint256 awardBonus;
        uint256 totalWithdrawn;
        uint256 hireInRow;
    }

    bool private _initialized;
    mapping (address => User) private users;
    uint256 private gearsAvailable;

    bool public luckyHourActive = false;
    uint256 public luckyHourPercent = 0;
    
    function hireWorkers(address ref) public initialized {

        if (ref == msg.sender) {
            ref = address(0);
        }

        User storage user = users[msg.sender];
        
        uint256 gearsUsed = getMyGears();
        uint256 myGearRewards = getGearsSLH(msg.sender);

        if (luckyHourActive) {
          uint256 additionalGears = SafeMath.div(SafeMath.mul(myGearRewards,luckyHourPercent), 100);
          myGearRewards = SafeMath.add(myGearRewards, additionalGears);
        }

        user.claimedGears += myGearRewards;

        uint256 newWorkers = users[msg.sender].claimedGears / GEARS_TO_HIRE_WORKER;
        
        user.claimedGears -=(GEARS_TO_HIRE_WORKER * newWorkers);
        user.workers += newWorkers;
        user.lastHire = block.timestamp;
        user.hireInRow += 1;
        
        //send referral gears
        users[ref].claimedGears += gearsUsed/8;
        users[ref].refferalBonus += gearsUsed/8;

        //boost market to nerf miners hoarding
        gearsAvailable += gearsUsed/3;
    }
    
    function sellGears() public initialized {
        uint256 hasGears = getMyGears();
        uint256 gearValue = calculateGearSell(hasGears);
        uint256 fee = devFee(gearValue);

        //Reset user gears
        users[msg.sender].claimedGears = 0;
        users[msg.sender].lastHire = block.timestamp;
        users[msg.sender].hireInRow = 0;

        gearsAvailable += hasGears;

        payable(owner()).transfer(fee);
        payable (msg.sender).transfer(gearValue-fee);
    }
    
    function buyGears(address ref) external payable initialized {
        _buyGears(ref, msg.value);
    }

    function seedMarket() external payable onlyOwner {
        require(!_initialized, "Already initialized");
        _initialized = true;
        gearsAvailable = 108000000000;
    }

    function awardUser(address addr, uint256 gearAmount) external onlyOwner initialized {
        users[addr].claimedGears = SafeMath.add(users[addr].claimedGears, gearAmount);
        users[addr].awardBonus = SafeMath.add(users[addr].awardBonus, gearAmount);
    }
    
    function _buyGears(address ref, uint256 amount) private
    {
        User storage user = users[msg.sender];
        uint256 gearsBought = calculateGearBuy(amount, address(this).balance-amount);
        gearsBought -= devFee(gearsBought);

        user.currentDeposit = SafeMath.add(user.currentDeposit, msg.value); //Total BNB deposited to contract from user
        user.claimedGears = SafeMath.add(user.claimedGears, gearsBought);

        uint256 fee = devFee(amount);
        payable(owner()).transfer(fee);
        
        hireWorkers(ref);
    }

    function gearToBNB(address adr) external view returns (uint256) {
        uint256 gearValue;
        try  this.calculateGearSell(getUserGears(adr)) returns (uint256 value) {gearValue=value;} catch{}
        return gearValue;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns (uint256) {
        return (PSN*bs)/(PSNH+(PSN*rs+PSNH*rt)/rt);
    }
    
    function calculateGearSell(uint256 gears) public view returns (uint256) {
        return calculateTrade(gears,gearsAvailable,address(this).balance);
    }
    
    function calculateGearBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, gearsAvailable);
    }
    
    function calculateGearBuySimple(uint256 eth) external view returns (uint256) {
        return calculateGearBuy(eth,address(this).balance);
    }

    function getGearsSLH(address adr) public view returns (uint256) {
        uint256 lastRehire = users[adr].lastHire;
        uint256 secs = block.timestamp - lastRehire;
        uint256 secondsPassed = min(GEARS_TO_HIRE_WORKER, secs);
        return SafeMath.mul(secondsPassed, users[adr].workers);        
    }    

    function devFee(uint256 amount) private view returns (uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function getMyGears() public view returns (uint256) {
        return SafeMath.add(users[msg.sender].claimedGears, getGearsSLH(msg.sender));
    }

    function getUserGears(address addr) public view returns (uint256) {
        return SafeMath.add(users[addr].claimedGears, getGearsSLH(addr)); 
    } 

    function getUserInfo(address addr) public view returns (User memory) {
        return users[addr];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }    

    function turnLuckyHour(bool status, uint256 percentage) external onlyOwner initialized {
        luckyHourActive = status;
        luckyHourPercent = percentage;
    } 
}