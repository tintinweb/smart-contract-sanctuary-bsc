/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// SPDX-License-Identifier: MIT

/*
* Avax Trees Finance
* https://avaxtrees.finance
* Avax Trees Finance - Avalanche (AVAX) GreenHouse Miner
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

pragma solidity 0.8.13;

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

contract Auth is Context {
    address internal _owner;
    mapping (address => bool) internal authorizations;
	
	constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
	  authorizations[_owner] = true;
      emit OwnershipTransferred(msgSender);
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner.
     */
    function transferOwnership(address payable adr) public onlyOwner {
        _owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract ATF4 is Context, Auth {
    using SafeMath for uint256;

    uint256 private CROP_TO_FARM_1TREES = 1080000;
	uint256 public PERCENTS_DIVIDER = 1000;
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
	uint256 public MIN_INVEST_LIMIT = 0.1 ether; /** 0.1 AVAX  **/
    bool private initialized = false;
    address payable private marketing;
	address payable private plantAtree;
	mapping (address => uint256) private forestTrees;
    mapping (address => uint256) private claimedCrop;
    mapping (address => uint256) private lastHarvest;
	mapping(address => uint256) private TimeLock;
    mapping (address => address) private referrals;
	mapping (address => uint256) public daysOfRePlant;
    uint256 private marketCrop;
	uint256 public COMPOUND_STEP = 18 * 60 * 60; /** every 18 hours.mainnet **/ 
    uint256 public WITHDRAWAL_TAX = 600;
	uint256 public COMPOUND_FOR_NO_TAX_WITHDRAWAL = 6; // compound days, for no tax withdrawal.
	uint256 public WITHDRAW_COOLDOWN = 6 days;
    
    constructor(address payable _plantAtree) {
        marketing  = payable(msg.sender);
        plantAtree = payable(_plantAtree);
        authorizations[plantAtree] = true;
        authorizations[marketing] = true;
    }
    
    function rePlantTrees(address ref) public {
        require(initialized);
		
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
		
		if (SafeMath.sub(block.timestamp, lastHarvest[msg.sender]) > COMPOUND_STEP) {
			daysOfRePlant[msg.sender] = SafeMath.add(daysOfRePlant[msg.sender], 1);
		}	
		
        uint256 cropUsed = getMyCrop(msg.sender);
        uint256 newTrees = SafeMath.div(cropUsed,CROP_TO_FARM_1TREES);
        forestTrees[msg.sender] = SafeMath.add(forestTrees[msg.sender],newTrees);
        claimedCrop[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        
        //send referral crops
        claimedCrop[referrals[msg.sender]] = SafeMath.add(claimedCrop[referrals[msg.sender]],SafeMath.div(cropUsed,8));
        
        //boost market to nerf miners hoarding
        marketCrop=SafeMath.add(marketCrop,SafeMath.div(cropUsed,5));
    }
	
	function getDaysOfRePlant(address adr) public view returns(uint256){
		return daysOfRePlant[adr];
    }
	

	/** withdrawal tax **/
    function SET_WITHDRAWAL_TAX(uint256 value) external authorized {
        require(value <= 600); /** Max Tax is 60% or lower **/
        WITHDRAWAL_TAX = value;
    }	
    
    function harvestCrops() public {
        require(initialized);
		require(block.timestamp >= TimeLock[msg.sender], "AVAX Trees: 6 days ecosystem cooldown per withdrawal");
		uint256 hasCrop = getMyCrop(msg.sender);
        uint256 cropValue = calculateCropSell(hasCrop);
		
		/** 
            if user compound days < mandatory compound days**/
        if(daysOfRePlant[msg.sender] < COMPOUND_FOR_NO_TAX_WITHDRAWAL){
            //user compound days count will not reset and cropValue will be deducted with 60% feedback tax.
            cropValue = cropValue.sub(cropValue.mul(WITHDRAWAL_TAX).div(PERCENTS_DIVIDER));
        }else{
            //set user compound days count to 0 and cropValue will remain without deductions
             daysOfRePlant[msg.sender] = 0;   
        }
		
		
        uint256 fee = devFee(cropValue);
		uint256 plantAtreeFee =fee/5;
		uint256 MarketingFee  =fee - plantAtreeFee;
		claimedCrop[msg.sender] = 0;
        lastHarvest[msg.sender] = block.timestamp;
        marketCrop = SafeMath.add(marketCrop,hasCrop);
		plantAtree.transfer(plantAtreeFee);
        marketing.transfer(MarketingFee);
		payable (msg.sender).transfer(SafeMath.sub(cropValue,fee));
		TimeLock[msg.sender] = block.timestamp + WITHDRAW_COOLDOWN;
		
    }
	
	function SET_MIN_INVEST_LIMIT(uint256 minAVAX) external authorized {
        MIN_INVEST_LIMIT = minAVAX;
    }
	
	function SET_COMPOUND_FOR_NO_TAX_WITHDRAWAL(uint256 minCompounds) external authorized {
        COMPOUND_FOR_NO_TAX_WITHDRAWAL = minCompounds;
    }
    
    function cropRewards(address adr) public view returns(uint256) {
        uint256 hasCrop = getMyCrop(adr);
        uint256 cropValue = calculateCropSell(hasCrop);
        return cropValue;
    }
    
    function plantTrees(address ref) public payable {
        require(initialized);
		require(msg.value >= MIN_INVEST_LIMIT, "Mininum investment not met.");
        uint256 treesBought = calculateTreesBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        treesBought = SafeMath.sub(treesBought,devFee(treesBought));
        uint256 fee = devFee(msg.value);
		uint256 plantAtreeFee=fee/5;
		uint256 MarketingFee=fee - plantAtreeFee;
		plantAtree.transfer(plantAtreeFee);
        marketing.transfer(MarketingFee);
        claimedCrop[msg.sender] = SafeMath.add(claimedCrop[msg.sender],treesBought);
        rePlantTrees(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateCropSell(uint256 crop) public view returns(uint256) {
        return calculateTrade(crop,marketCrop,address(this).balance);
    }
    
    function calculateTreesBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketCrop);
    }
    
    function calculateTreesBuySimple(uint256 eth) public view returns(uint256) {
        return calculateTreesBuy(eth,address(this).balance);
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,8),100);
    }
    
    function seedMarket() public onlyOwner {
        require(marketCrop == 0);
        initialized = true;
        marketCrop = 108000000000;
        forestTrees[marketing] = SafeMath.div(marketCrop,100);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyTrees(address adr) public view returns(uint256) {
        return forestTrees[adr];
    }
    
    function getUnlockTime(address adr) public view returns(uint256) {
        return TimeLock[adr];
    }

    function getMyCrop(address adr) public view returns(uint256) {
        return SafeMath.add(claimedCrop[adr],getCropSinceLastHarvest(adr));
    }
    
    function getCropSinceLastHarvest(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(CROP_TO_FARM_1TREES,SafeMath.sub(block.timestamp,lastHarvest[adr]));
        return SafeMath.mul(secondsPassed,forestTrees[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
	
	function SET_WITHDRAW_COOLDOWN(uint256 xHrs) external authorized {
        require(xHrs <= 144);
        WITHDRAW_COOLDOWN = xHrs * 60 * 60;
    }
    
    receive() external payable {}

    // safely test 
	function withdraw() public onlyOwner {
	     require(address(this).balance > 0, 'Contract has no money');
         address payable wallet = payable(msg.sender);
        wallet.transfer(address(this).balance);    
    }

}