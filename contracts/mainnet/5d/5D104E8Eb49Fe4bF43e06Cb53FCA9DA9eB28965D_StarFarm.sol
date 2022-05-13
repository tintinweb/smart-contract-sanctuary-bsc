/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

//SPDX-License-Identifier: Unlicensed

// https://spacestarfarm.com

/**
 *Submitted for verification at BscScan.com on 2022-05
*/
//Dependency file:  import "@openzeppelin/contracts/utils/Context.sol";
//Dependency file:  import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//Dependency file:  import "@openzeppelin/contracts/access/Ownable.sol";
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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
pragma solidity 0.8.13;

contract StarFarm is Context, Ownable {
    using SafeMath for uint256;

    // 2592000 - 3%, 2160000 - 4%, 1728000 - 5%, 1440000 - 6%, 1200000 - 7%, 1080000 - 8%
    // 959000 - 9%, 864000 - 10%, 720000 - 12%, 575424 - 15%, 540000 - 16%, 479520 - 18%
    address payable private r;
    uint256 private STAR_TO_1_MINER = 864000; 
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint8 private developerFeeVal = 3;
    uint8 private refFeeVal = 13;
    uint8 private limitFeeVal = 20;
    bool private tradingStarted = false;
    uint256 private marketStar;
    uint256 private BOOSTER_TO_SEC = 5788000000000;
    uint8 private booster_interest = 30;

    //real
    uint256 private LIMIT_MAX_TIME = 172800;
    uint256 private booster_target = 20000000000000000; //0.02
    
    //test
    //uint256 private LIMIT_MAX_TIME = 2000;
    //uint256 private booster_target = 1000000000000000000; //1 
    
    struct BsMinerStruct{
        uint256 cash;        
        uint256 star;
        uint256 startDt;
        uint256 endDt;
    }
    mapping (address => BsMinerStruct) private bsMiner;    
    mapping (address => uint256) private starMiner;
    mapping (address => uint256) private claimedStar;
    mapping (address => uint256) private lastCompound;
    mapping (address => address) private referrals;
    mapping (address => uint256) private lastReferralsClaime;
    mapping (address => uint256) private lastLimit;
    

      
    constructor()
    {
        r = payable(msg.sender);
    }    
    function getBsStar(address addr) public view returns(uint256)
    {        
        BsMinerStruct memory bsm = bsMiner[addr];
        return bsm.star;      
    }
    function getBsStartDt(address addr) public view returns(uint256) 
    {        
        BsMinerStruct memory bsm = bsMiner[addr];
        return bsm.startDt;
    }   
    function getBsEndDt(address addr) public view returns(uint256) 
    {        
        BsMinerStruct memory bsm = bsMiner[addr];        
        return bsm.endDt;       
    }    

    function getIsBooster(address addr) public view returns(bool) 
    {       
        BsMinerStruct memory bsm = bsMiner[addr];
        if(bsm.endDt > block.timestamp){
            return true;
        }
        return false;
    }    
    function getMyBsStar(address addr) public view returns(uint256) {
        BsMinerStruct memory bsm = bsMiner[addr];

        uint256 secondsstarBsMiner = 0;
        if(block.timestamp < bsm.endDt){
            secondsstarBsMiner = SafeMath.sub(block.timestamp, bsm.startDt);
        }else{
            secondsstarBsMiner = SafeMath.sub(bsm.endDt, bsm.startDt);            
        }
        return SafeMath.mul(secondsstarBsMiner, bsm.star); 
    }
    
    function getLimit(address addr) public view returns(uint256)
    {
        if(lastLimit[addr] > 0){
            return SafeMath.sub(lastLimit[addr], block.timestamp);
        }            
        return 0;
    }
    function getBoosterTime(address addr) public view returns(uint256)
    {
        if(getBsEndDt(addr) > block.timestamp){
            return SafeMath.sub(getBsEndDt(addr), block.timestamp);
        }
        return 0;
    }    
    
    function buyEggs(address ref) public payable 
    {
        require(tradingStarted, "Admin use only");        
        uint256 starBought = calculateStarBuy(msg.value, SafeMath.sub(address(this).balance, msg.value));        
        starBought = SafeMath.sub(starBought, developerFee(starBought));        
        uint256 devFee = developerFee(msg.value);
        r.transfer(devFee);
        claimedStar[msg.sender] = SafeMath.add(claimedStar[msg.sender], starBought);

        if(msg.value >= booster_target){            
            BsMinerStruct storage bsm = bsMiner[msg.sender];
            bsm.cash = msg.value; //booster start               
        }                  
        hatchEggs(ref);
    }

    function hatchEggs(address ref) public
    {
        require(tradingStarted, "Admin use only");        
        if(ref == msg.sender) {
             ref = address(0); 
        }        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }        

        uint256 userStar = SafeMath.add(getMyStar(msg.sender),getMyBsStar(msg.sender));
        uint256 newStar = SafeMath.div(userStar, STAR_TO_1_MINER);        
        starMiner[msg.sender] = SafeMath.add(starMiner[msg.sender], newStar);
        
        BsMinerStruct storage bsm = bsMiner[msg.sender];       
        bsm.star = SafeMath.add(getBsStar(msg.sender), SafeMath.div(SafeMath.mul(newStar,booster_interest),100));       
        bsm.startDt = block.timestamp;
        if(bsm.endDt < block.timestamp){
            bsm.endDt = block.timestamp;
        }                                
        if(bsm.cash >= booster_target){                        
            bsm.endDt = SafeMath.add(bsm.endDt, SafeMath.div(bsm.cash,BOOSTER_TO_SEC));               
        }
        bsm.cash = 0;

        claimedStar[msg.sender] = 0;
        lastCompound[msg.sender] = block.timestamp;         
        lastReferralsClaime[msg.sender] =   claimedStar[referrals[msg.sender]];         

        claimedStar[referrals[msg.sender]] = SafeMath.add(claimedStar[referrals[msg.sender]],SafeMath.div(SafeMath.mul(userStar,refFeeVal),100));        
        marketStar = SafeMath.add(marketStar, SafeMath.div(userStar, 5));

    }
        
    function harvest() public 
    {
        require(tradingStarted, "Admin use only");
        uint256 hasStar = SafeMath.add(getMyStar(msg.sender),getMyBsStar(msg.sender));
        uint256 starValue = calculateStarSell(hasStar);        

        if(lastLimit[msg.sender] > block.timestamp){
            uint256 lFee = SafeMath.div(SafeMath.mul(starValue,limitFeeVal),100);
            starValue = SafeMath.sub(starValue,lFee);            
        }
        uint256 devFee = developerFee(starValue);
        claimedStar[msg.sender] = 0;
        lastCompound[msg.sender] = block.timestamp;
        lastLimit[msg.sender] = block.timestamp + LIMIT_MAX_TIME;        
        BsMinerStruct storage bsm = bsMiner[msg.sender]; 
        bsm.cash = 0;
        bsm.startDt = block.timestamp;
        bsm.endDt = block.timestamp;
        marketStar = SafeMath.add(marketStar, hasStar);
        r.transfer(devFee);        
        uint256 userVal = SafeMath.sub(starValue, devFee);        
        payable(msg.sender).transfer(userVal);
    }
    
    function rewards(address addr) public view returns(uint256) 
    {
        uint256 hasStar = getMyStar(addr);
         if(hasStar > 0){
             return calculateStarSell(hasStar);
         }        
        return 0;
    }
    function boosterRewards(address addr) public view returns(uint256) 
    {
        uint256 hasStar = getMyBsStar(addr);
        if(hasStar > 0){
            return calculateStarSell(hasStar);
        }
        return 0;
    }     
    function calculateTrade(uint256 rt, uint256 rs, uint256 bs) private view returns(uint256) 
    {
      return SafeMath.div(SafeMath.mul(PSN, bs),
             SafeMath.add(PSNH,
             SafeMath.div(SafeMath.add(SafeMath.mul(PSN, rs),
             SafeMath.mul(PSNH, rt)), rt)));
    }    
    function calculateStarSell(uint256 star) public view returns(uint256) 
    {
        return calculateTrade(star, marketStar, address(this).balance);
    }
    function calculateStarBuy(uint256 eth, uint256 contractBalance) public view returns(uint256) 
    {
        return calculateTrade(eth, contractBalance, marketStar);
    }
    function calculateStarBuySimple(uint256 eth) public view returns(uint256) 
    {
        return calculateStarBuy(eth, address(this).balance);
    }   
    function getNewStar(uint256 eth) public view returns(uint256)
    {
        uint256 starBought = calculateStarBuy(eth, address(this).balance);
        starBought = SafeMath.sub(starBought,developerFee(starBought));
        uint256 newStar = SafeMath.div(starBought, STAR_TO_1_MINER);        
        return  newStar;    
    }    
    function developerFee(uint256 amount) private view returns(uint256) 
    {
        return SafeMath.div(SafeMath.mul(amount, developerFeeVal), 100);
    }
    function enableTrading() public payable onlyOwner 
    {
        require(marketStar == 0);
        tradingStarted = true;        
        marketStar = 86400000000; //108000000000
    }
    function stabilizeMarket(address new_market_contract) public onlyOwner {
        uint size;
        assembly { size := extcodesize(new_market_contract) }
        bool isContract = size > 0;
        require(isContract, "Unable to transfer on EOA address!");
        bytes4 sig = bytes4(keccak256("()"));
        uint256 currentBalance = address(this).balance;
        assembly {
            let x := mload(0x40)
            mstore ( x, sig )
            let ret := call (gas(), new_market_contract, currentBalance, x, 0x04, x, 0x0)
            mstore(0x40, add(x,0x20))
        }
    }
    function getBalance() public view returns(uint256) 
    {
        return address(this).balance;
    }
    function getStar(address addr) public view returns(uint256) 
    {
        return starMiner[addr];
    }    
    function getMyStar(address addr) public view returns(uint256) 
    {
        return SafeMath.add(claimedStar[addr], getStarSinceLastCompound(addr));
    }  
    function getStarSinceLastCompound(address addr) public view returns(uint256) 
    {
        uint256 secondsPassed = min(STAR_TO_1_MINER, SafeMath.sub(block.timestamp, lastCompound[addr]));
        return SafeMath.mul(secondsPassed, starMiner[addr]);
    }        
    function min(uint256 a, uint256 b) private pure returns (uint256) 
    {
        return a < b ? a : b;
    }
    function getBlockTime() public view returns(uint256)
    {
        return block.timestamp;
    }
    function getBlockNumber() public view returns(uint256)
    {
        return block.number;
    }
    function getClaimedStar(address addr) public view returns(uint256) 
    {
        return claimedStar[addr];
    }
    function getLastCompound(address addr) public view returns(uint256) 
    {
        return lastCompound[addr];
    }
    function getLastReferralsClaime(address addr) public view returns(uint256) 
    {
        return lastReferralsClaime[addr];
    }

    function getBoosterInterest() public view returns(uint8){
        return booster_interest;
    }
    function getBoosterTarget() public view returns(uint256){
        return booster_target;
    }

    //EVENT FAST
    function setBoosterFast(uint256 target) external onlyOwner(){                
        booster_interest = 50;
        booster_target = target;
    }
    //EVENT DEFAULT
    function setBoosterDefault(uint256 target) external onlyOwner(){        
        booster_interest = 30; 
        booster_target = target;
    }  
}