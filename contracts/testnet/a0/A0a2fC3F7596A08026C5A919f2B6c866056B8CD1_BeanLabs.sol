/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT

    /*
     *      BeanLabs    TEST CONTRACT DO NOT BUY!
     */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity 0.8.17;

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

contract BeanLabs is Context, Ownable {
    using SafeMath for uint256;

    uint256 private potions_TO_Hire_1chemist = 900000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 10;
    bool private initialized = false;
    address payable private recAdd;
    address payable private development;
    address payable private treasury;
    mapping (address => uint256) private Factory;
    mapping (address => uint256) private claimedpotions;
    mapping (address => uint256) private lastHire;
    mapping (address => uint256) private lastsell;
    mapping (address => uint256) private lastboostchemisttime;
    mapping (address => uint256) private lastinstabrew;
    mapping (address => uint256) private lastinstabatch;
    mapping (address => uint256) private referralcount;
    mapping (address => uint256) private labLevel;
    mapping (address => uint256) private exppoints;
    mapping (address => uint256) private boostpoints;
    mapping (address => uint256) private lotterytickets;
    mapping (address => address) private referrals;
    uint256 private marketpotions;
    uint256 private lastmarketpotionburn;
    uint256 private lastreorganization;
    uint256 public lastrebasepercent;
    uint256 public maxTicketLimit;
    uint256 public lastburnpercent;
    uint256 public lotteryticketpriceinEth;
    address[] public users;
    uint public numUsers;

    constructor() {
        recAdd = payable(msg.sender);
        development = payable(msg.sender);
        treasury = payable(msg.sender);
        lastreorganization = 0;
    }
    
    function Expandlab(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 potionsUsed = getMypotions(msg.sender);
        uint256 newchemist = SafeMath.div(potionsUsed,potions_TO_Hire_1chemist) / 100 * getpotionquality(msg.sender);
        Factory[msg.sender] = SafeMath.add(Factory[msg.sender],newchemist);
        claimedpotions[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        
        //send referral potions
        claimedpotions[referrals[msg.sender]] = SafeMath.add(claimedpotions[referrals[msg.sender]],SafeMath.div(potionsUsed,20));
        
        //boost market to nerf labs hoarding potions
        marketpotions=SafeMath.add(marketpotions,SafeMath.div(potionsUsed,5));

        // Only increase the user's experience points if the last hire was at least .... ago
         if (block.timestamp >= lastHire[msg.sender] + 120) {
         exppoints[msg.sender] = exppoints[msg.sender] + 1;
        }
    }
    
    function expandlabafterbuy(address ref) private {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
            referralcount[ref] = SafeMath.add(referralcount[ref], 1);
            users.push(msg.sender);
            numUsers = users.length;
        }
        
        uint256 potionsUsed = getMypotions(msg.sender);
        uint256 newchemist = SafeMath.div(potionsUsed,potions_TO_Hire_1chemist);
        Factory[msg.sender] = SafeMath.add(Factory[msg.sender],newchemist);
        claimedpotions[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        
        //send referral potions
        claimedpotions[referrals[msg.sender]] = SafeMath.add(claimedpotions[referrals[msg.sender]],SafeMath.div(potionsUsed,20));
        
        //boost market to nerf labs hoarding potions
        marketpotions=SafeMath.add(marketpotions,SafeMath.div(potionsUsed,4));
    }

    function Sellpotions() public {
        require(initialized);
        uint256 haspotions = getMypotions(msg.sender);
        uint256 potionsValue = (calculatepotionsell(haspotions) / 100) * getpotionquality(msg.sender);
        uint256 fee = devFee(potionsValue) * getSellStatus(msg.sender);
        claimedpotions[msg.sender] = 0;
        lastHire[msg.sender] = block.timestamp;
        lastsell[msg.sender] = block.timestamp;
        marketpotions = SafeMath.add(marketpotions,SafeMath.div(haspotions,2));
        recAdd.transfer(fee / 4);
        development.transfer(fee / 4);
        treasury.transfer(fee - (fee / 2));

        payable (msg.sender).transfer(SafeMath.sub(potionsValue,fee));
    }
    
    function PotionRewards(address adr) public view returns(uint256) {
        uint256 haspotions = getMypotions(adr);
        uint256 potionsValue = calculatepotionsell(haspotions);
        return potionsValue;
    }
    
    function Hirechemists(address ref) public payable {
        uint256 tvl = address(this).balance;  // get the TVL
        uint256 maxPayment = tvl / 5;  // calculate the maximum payment allowed (2/10th of the TVL)
        require(msg.value <= maxPayment && msg.value >= 0.0001 ether, "Payment must be less than 2/10th of the TVL and more than or equal to 0.001 BNB");
        require(initialized);
        uint256 potionsBought = calculateexpandlab(msg.value,SafeMath.sub(address(this).balance,msg.value));
        potionsBought = SafeMath.sub(potionsBought,devFee(potionsBought));
        uint256 fee = devFee(msg.value);
        recAdd.transfer(fee / 4);
        development.transfer(fee / 4);
        treasury.transfer(fee - (fee / 2));
        claimedpotions[msg.sender] = SafeMath.add(claimedpotions[msg.sender],potionsBought);
        expandlabafterbuy(ref);
    }

    function contributeToTVL () public payable {
    }

    function GetLastSale (address adr) public view returns(uint256) {
        return lastsell[adr];
    }
    
    function getSellStatus (address adr) public view returns (uint256) {
        uint256 currentTimestamp = block.timestamp;
        uint256 timeDifference = currentTimestamp.sub(lastsell[adr]);
        if (lastinstabatch[adr] > lastHire[adr] && lastinstabatch[adr] > lastsell[adr]) {
            return 1;
        } else if (timeDifference > 360) {
            return 1;
        } else if (timeDifference > 180) {
            return 2;
        } else if (timeDifference > 120) {
            return 3;
        } else if (timeDifference > 60) {
            return 5;
        } else if (timeDifference > 30) {
            return 7;
        } else return 9;
    }

    function getpotionquality (address adr) public view returns (uint256) {
        uint256 currenttimestamp = block.timestamp;
        uint256 timedifference = currenttimestamp.sub(lastHire[adr]);
        if (lastinstabrew[adr] > lastHire[adr] && lastinstabrew[adr] > lastsell[adr]) {
            return 100; 
        } else if (timedifference < 60) {
            return 50; // state 1 (starting to brew)
        } else if (timedifference < 120) {
            return 75; // state 2
        } else if (timedifference < 140) {
            return 85; // state 3
        } else if (timedifference < 180) {
            return 100; // state 4 (optimal)
        } else if (timedifference < 240) {
            return 90; // state 5 
        } else if (timedifference < 300) {
            return 70; //stage 6
        } else if (timedifference > 1600000000) {
            return 100; // first buy
        } else return 55; // state 7 (degraded)
    }
    
    function setDevFee(uint256 newDevFee) public onlyOwner {
        require(newDevFee <= 10, "new Dev fee must be equal to or lower than 10");
        devFeeVal = newDevFee;
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculatepotionsell(uint256 potions) public view returns(uint256) {
        return calculateTrade(potions,marketpotions,address(this).balance);
    }
    
    function calculateexpandlab(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketpotions);
    }
    
    function calculateexpandlabSimple(uint256 eth) public view returns(uint256) {
        return calculateexpandlab(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function settreasurywallet(address adr) public onlyOwner {
        treasury = payable(adr);
    }

    function setdevelopmentwallet(address adr) public onlyOwner {
        development = payable(adr);
    }

    function getTreasuryWallet() public view returns (address payable) {
        return treasury;
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketpotions == 0);
        initialized = true;
        marketpotions = 108000000000;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMychemists(address adr) public view returns(uint256) {
        return Factory[adr];
    }
    
    function getMypotions(address adr) public view returns(uint256) {
        return SafeMath.add(claimedpotions[adr],getpotionsSinceLastHire(adr));
    }

    function getPotionvalue(address adr) public view returns(uint256) {
        uint256 mypotions = getMypotions(adr);
        uint256 potionValue = (calculatepotionsell(mypotions) / 100) * getpotionquality(adr);
        return potionValue;
    }
    
    function getpotionsSinceLastHire(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(potions_TO_Hire_1chemist,SafeMath.sub(block.timestamp,lastHire[adr]));
        uint256 timeBetweenHireAndReorganization = lastreorganization > lastHire[adr] ? SafeMath.sub(lastreorganization, lastHire[adr]) : 0;
        uint256 reduction;

        if (lastreorganization > lastHire[adr]) {
            // Only reduce the potions made between the hire and the reorganization
            reduction = SafeMath.mul(timeBetweenHireAndReorganization, Factory[adr]).div(100).mul(lastrebasepercent);
        } else {
            reduction = 0;
        }

        secondsPassed = SafeMath.sub(secondsPassed, reduction);

        return SafeMath.mul(secondsPassed, Factory[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function timesincelastreorganize() public view returns (uint256) {
        return block.timestamp - lastreorganization;
    }

    function timesincelastburn() public view returns (uint256) {
        return block.timestamp - lastmarketpotionburn;
    }

    function getrefcount(address adr) public view returns(uint256) {
        return referralcount[adr];
    }

    function getPotionsPerDay(address adr) public view returns(uint256) {
        uint256 potionsSinceLastHire = getpotionsSinceLastHire(adr);
        uint256 secondsSinceLastHire = SafeMath.sub(block.timestamp, lastHire[adr]);
        return SafeMath.mul(potionsSinceLastHire, 86400) / secondsSinceLastHire;
    }   

    function getpotionprice() public view returns (uint256) {
        return calculatepotionsell(1);
    }

    function getchemistprice() public view returns (uint256) {
        return SafeMath.mul(potions_TO_Hire_1chemist, getpotionprice());
    }

    function getUsers() public view returns (address[] memory) {
        return users;
    }

    function getLabLevel(address user) public view returns (uint256) {
        return labLevel[user];
    }

    function getboostpoints(address user) public view returns (uint256) {
        return boostpoints[user];
    }

    function getexppoints(address user) public view returns (uint256) {
        return exppoints[user];
    }

    function getlotterytickets(address user) public view returns (uint256) {
        return lotterytickets[user];
    }

    function getLabValue(address adr) public view returns (uint256) {
        uint256 chemistCount = Factory[adr];
        uint256 chemistPrice = getchemistprice();
        return chemistCount.mul(chemistPrice);
    }

    function LevelupLab() public {
      require(exppoints[msg.sender] >= 10, "Not enough experience points");
      labLevel[msg.sender] = labLevel[msg.sender] + 1;
      boostpoints[msg.sender] = boostpoints[msg.sender] + 1;
      exppoints[msg.sender] = exppoints[msg.sender] - 10;
    }

    function instabrew() public {
      require(boostpoints[msg.sender] >= 1, "Not enough boost points");
      lastinstabrew[msg.sender] = block.timestamp;
      boostpoints[msg.sender] = boostpoints[msg.sender] - 1;
    }

    function instabatch() public {
      require(boostpoints[msg.sender] >= 2, "Not enough boost points");
      lastinstabatch[msg.sender] = block.timestamp;
      boostpoints[msg.sender] = boostpoints[msg.sender] - 2;
    }

    function BoostChemists() public {
        require(boostpoints[msg.sender] >= 3, "Not enough boost points");

        uint256 currentChemists = Factory[msg.sender];
        uint256 increaseAmount = currentChemists.mul(5).div(100);
        Factory[msg.sender] = SafeMath.add(currentChemists, increaseAmount);
        boostpoints[msg.sender] = SafeMath.sub(boostpoints[msg.sender], 3);
        lastboostchemisttime[msg.sender] = block.timestamp;
    }

    function increaseEXPafterrebase(address user) private {
        // Add 1 to the user's lab level
        exppoints[user] = exppoints[user] + 5;
    }

    function increaseEXPafterburn(address user) private {
        // Add 1 to the user's lab level
        exppoints[user] = exppoints[user] + 2;
    }

    function buyLotteryTicketWithBoostpoints() public {
        require(boostpoints[msg.sender] >= 1, "Not enough boostpoints");
        require(lotterytickets[msg.sender] <= maxTicketLimit, "you already have the max amount of tickets");
        boostpoints[msg.sender] = boostpoints[msg.sender] - 1;
        lotterytickets[msg.sender] = lotterytickets[msg.sender] + 1;
    }

    function buyLotteryTicketWithEth() public payable {
        require(msg.value == lotteryticketpriceinEth, "Incorrect ETH value");
        require(lotterytickets[msg.sender] <= maxTicketLimit, "you already have the max amount of tickets");
        lotterytickets[msg.sender]++;
        recAdd.transfer(msg.value);
    }

    function setEthTicketPrice(uint256 newPrice) public {
        require(newPrice > 0, "Price must be greater than 0");
        lotteryticketpriceinEth = newPrice;
    }

    function setTicketLimit(uint256 newLimit) public onlyOwner {
        maxTicketLimit = newLimit;
    }

    function resetLotteryTickets() public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            if (lotterytickets[users[i]] > 0) {
                lotterytickets[users[i]] = 0;
            }
        }
    }

    function showAllUsersWithTickets() public view returns (address[] memory, uint[] memory,uint) {
        address[] memory addresses = new address[](users.length);
        uint[] memory ticketCounts = new uint[](users.length);
        uint count = 0;
        for (uint i = 0; i < users.length; i++) {
            if (lotterytickets[users[i]] > 0) {
                addresses[count] = users[i];
                ticketCounts[count] = lotterytickets[users[i]];
                count++;
            }
        }
        return (addresses, ticketCounts,count);
    }
    
    function burnmarketpotions(uint256 percentremainingafterburn) public onlyOwner {
         require(block.timestamp > lastmarketpotionburn + 120);
         require(percentremainingafterburn >= 70 && percentremainingafterburn < 100);
         marketpotions = SafeMath.mul(marketpotions, percentremainingafterburn).div(100);
         lastmarketpotionburn = block.timestamp;
         lastburnpercent = 100 - percentremainingafterburn;

         for (uint i = 0; i < numUsers; i++) {
            if (Factory[users[i]] > 0) {

                // Increases all user's EXP by 2
                increaseEXPafterburn(users[i]);
            }
        }
    }

    function reorganize(uint rebasepercent) public onlyOwner {
        require(rebasepercent <= 90);
        require(block.timestamp >= lastreorganization + 120);

        // Update lastreorganization with the current block timestamp
        lastreorganization = block.timestamp;
        lastrebasepercent = rebasepercent;

        for (uint i = 0; i < numUsers; i++) {
            if (Factory[users[i]] > 0) {
                // Calculate the number of chemists to remove based on the rebasepercent parameter
                uint chemistsToRemove = SafeMath.mul(Factory[users[i]], rebasepercent) / 100;
                // Subtract the calculated number of chemists from the user's total
                Factory[users[i]] = SafeMath.sub(Factory[users[i]],chemistsToRemove);
                // Increase the user's lab level by 1
                increaseEXPafterrebase(users[i]);
            }
        }

        // Calculate the number of market potions to remove based on the rebasepercent parameter
        uint marketPotionsToRemove = SafeMath.mul(marketpotions, rebasepercent) / 100;
        // Subtract the calculated number of market potions from the total
        marketpotions = SafeMath.sub(marketpotions,marketPotionsToRemove);
    }
}