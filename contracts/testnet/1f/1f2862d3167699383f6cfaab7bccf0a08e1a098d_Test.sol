/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT

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

pragma solidity 0.8.9;

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

contract Test is Context, Ownable {
    using SafeMath for uint256;

    uint256 private APR_DAILY = 8;
    uint256 private MINERSV2_TO_CRAFT_1MINER = (100 days) / APR_DAILY; //in a day... 60*60*24 = 86400 //

    uint256 private treasuryFeeValBase = 5;
    uint256 private treasuryFeeVal = 20;

    uint256 private days_rehire_avoid_downgrade = (7 days);

    //Lvl
    uint256 private lvl1_multiplier = 100;
    uint256 private lvl2_multiplier = 130;
    uint256 private lvl3_multiplier = 160; //max lvl
    uint256 private lvl4_multiplier = 180; //only for giveaways
    uint256 private lvl5_multiplier = 200; //only for giveaways (internal)
    uint256 private lvlx_denominator = 100;
    uint256 private upgrade_lvl_cost_pc = 20; //10% for upgrade cost

    //Rewards to claim max capacity
    uint256 private chest_capacity = (2 days); 

    //Antiwhale/bot
    uint256 private min_balance_math_bnb = 0; //Min contract balance for math //Nerf bots
    uint256 private min_resources_burn_launch_pc = 80; //%
    uint256 private denominator_resources_burn_launch_pc = 100; //%
    address private BURN_ADDRESS = address(0);

    bool private initialized = false;
    address payable private recAdd; //Treasury address
    mapping (address => uint256) private hatcheryMiners;
    mapping (address => uint256) private claimedMinersV2;
    mapping (address => uint256) private lastCraft;
    mapping (address => uint256) private lastSell;
    mapping (address => address) private referrals;
    mapping (address => uint8) private levels;
    mapping (address => bool) private chest_capacity_exempt;
    uint256 private marketMinersV2;
    
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;

    constructor() {
        recAdd = payable(msg.sender);
    }
    
    //Payables and externals//////////////////////////

    function craftMinersV2(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 minersV2Used = getMyMinersV2(msg.sender);
        uint256 newMiners = SafeMath.div(minersV2Used,MINERSV2_TO_CRAFT_1MINER);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedMinersV2[msg.sender] = 0;
        lastCraft[msg.sender] = block.timestamp;
        
        //send referral minersV2
        claimedMinersV2[referrals[msg.sender]] = SafeMath.add(claimedMinersV2[referrals[msg.sender]],SafeMath.div(minersV2Used,8));
        
        //boost market to nerf miners hoarding
        marketMinersV2=SafeMath.add(marketMinersV2,SafeMath.div(minersV2Used,5));
    }
    
    function sellMinersV2() external {
        require(initialized);
        uint256 hasMinersV2 = getMyMinersV2(msg.sender);
        uint256 minersV2Value = calculateMinersV2Sell(hasMinersV2);
        uint256 fee = treasuryFeeBase(minersV2Value);
        claimedMinersV2[msg.sender] = 0;
        lastCraft[msg.sender] = block.timestamp;
        marketMinersV2 = SafeMath.add(marketMinersV2,hasMinersV2);
        recAdd.transfer(fee);
        payable (msg.sender).transfer(SafeMath.sub(minersV2Value,fee));
        if(levels[msg.sender] > 1 && apply_lvl_downgrade(msg.sender)){
            levels[msg.sender] -= 1;
        }
        lastSell[msg.sender] = block.timestamp;
    }
    
    function upgradeLvl() external payable {
        require(initialized);
        require(hatcheryMiners[msg.sender] >= 0, "first buy some minersV2");
        require(levels[msg.sender] < 3, "max lvl reached");
        require(calculateUpgradePrice(msg.sender) <= msg.value, "you have to pay a percent of your investment to upgrade your lvl");
        uint256 fee = treasuryFee(msg.value, msg.sender);
        recAdd.transfer(fee);
        levels[msg.sender] += 1;
    }

    function buyMinersV2(address ref) external payable {
        require(initialized);
        _buyMinersV2(msg.sender, ref);
    }

    function _buyMinersV2(address _sender, address ref) private {
        uint256 payment = msg.value;
        uint256 treasuryFeeValue = 0; //You pay here for the lvls upgraded
        if(levels[_sender] == 0){
            levels[_sender] = 1;
        }
        if(levels[_sender] > 1){
            treasuryFeeValue = SafeMath.sub(payment, apply_lvls_penalty(payment, _sender));
            payment -= treasuryFeeValue;
        }
        uint256 minersV2Bought = calculateMinersV2Buy(payment, SafeMath.sub(getBalanceMath(), payment));
        uint256 fee = treasuryFeeBase(payment);
        recAdd.transfer(SafeMath.add(fee, treasuryFeeValue));
        claimedMinersV2[_sender] = SafeMath.add(claimedMinersV2[_sender],minersV2Bought);
        craftMinersV2(ref);
    }

    //Owner/////////////////////////////

    function seedMarket(uint256 pc_resources_burn, uint256 _min_balance_math_bnb) public payable onlyOwner {
        require(marketMinersV2 == 0);
        require(pc_resources_burn >= min_resources_burn_launch_pc);
        require(pc_resources_burn < 100);
        initialized = true;
        marketMinersV2 = 100 * MINERSV2_TO_CRAFT_1MINER;
        min_balance_math_bnb = (denominator_resources_burn_launch_pc).sub(pc_resources_burn).mul(msg.value.div(pc_resources_burn)); //min_balance/ammount = (100/80) -1//to burn 80% for example
        _buyMinersV2(BURN_ADDRESS, BURN_ADDRESS);        
        min_balance_math_bnb = _min_balance_math_bnb;
    }

    function setlvl_multiplier(uint8 lvl, uint256 multiplier) public onlyOwner {
        require(multiplier >= 100 && multiplier <= 200, "not a valid multiplier");
        require(lvl != 5, "only for giveaway");
        if(lvl == 1){
            lvl1_multiplier = multiplier;
        }
        if(lvl == 2){
            lvl2_multiplier = multiplier;
        }
        if(lvl == 3){
            lvl3_multiplier = multiplier;
        }
        if(lvl == 4){
            lvl4_multiplier = multiplier;
        }
        // if(lvl == 5){
        //     lvl5_multiplier = multiplier;
        // }
    }

    function assign_lvl4_giveaway(address winner) public onlyOwner {
        require(winner != owner(), "nope");
        
        levels[winner] = 4;
    }

    function assign_lvl5_giveaway(address winner, uint256 multiplier) public onlyOwner {
        require(winner != owner(), "nope");
        
        levels[winner] = 5;
        lvl5_multiplier = multiplier;
    }
    
    function assign_lvl_upgrade_percent(uint256 percent) public onlyOwner {
        require(percent <= 50, "upgrade payment cant be higher than 1/2 of investment");
        upgrade_lvl_cost_pc = percent;
    }

    function assign_address_exempt_chest_capacity(address addr, bool is_exempt) public onlyOwner {
        _assign_address_exempt_chest_capacity(addr, is_exempt);
    }

    function _assign_address_exempt_chest_capacity(address addr, bool is_exempt) private {
        chest_capacity_exempt[addr] = is_exempt;
    }

    //Views///////////////////////////

    //BNB you have to pay for upgrade lvl
    function calculateUpgradePrice(address adr) public view returns(uint256){
        return treasuryFee(calculateMinersV2Sell(hatcheryMiners[adr]), adr);
    }

    //Value of your miners in BNB
    function calculateMinersV2Sell(uint256 minersV2) public view returns(uint256) {
        return calculateTrade(minersV2,marketMinersV2,getBalanceMath());
    }

    //Investment amount after applying lvls penalty
    function apply_lvls_penalty(uint256 amount, address _sender) public view returns(uint256){
        uint8 lvl = levels[_sender];
        while(lvl > 1)
        {
            //(invest * % penalty) / (invest + (invest * % penalty)) -> real x/y penalty to apply over invest. invest -= invest * x/y
            uint256 penalty_amount = treasuryFee(amount, _sender);//
            amount -= SafeMath.div(SafeMath.mul(amount, penalty_amount), SafeMath.add(amount, penalty_amount));
            lvl--;
        }
        return amount;
    }

    //Determines if lvl downgrade will be applied if the address sell
    function apply_lvl_downgrade(address adr) public view returns(bool){
        return (lastSell[adr] == 0 || SafeMath.sub(block.timestamp, lastSell[adr]) < days_rehire_avoid_downgrade);
    }

    //Acumulated resources value (BNB)
    function minersV2RewardsBNB(address adr) public view returns(uint256) {
        uint256 hasMinersV2 = getMyMinersV2(adr);
        uint256 minersV2Value = calculateMinersV2Sell(hasMinersV2);
        return minersV2Value;
    }

    //Value (BNB) of rewards generated on 24h
    function minersV2DailyRewardsBNB(address adr) external view returns (uint256) {
        return SafeMath.div(SafeMath.mul(getlvl_multiplier(adr), SafeMath.mul((1 days),hatcheryMiners[adr])), lvlx_denominator);
    }

    //Contract balance
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    //Contract balance corrected for math (antibot)
    function getBalanceMath() public view returns(uint256){
        return max(SafeMath.mul(min_balance_math_bnb, 100000000), getBalance());
    }
    
    //Amount of miners
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }
    
    //Amount of resources acumulated
    function getMyMinersV2(address adr) public view returns(uint256) {
        return SafeMath.add(claimedMinersV2[adr],getMinersV2SinceLastCraft(adr));
    }
    
    //Time left until your both chest are filled
    function chestCapacityCheck(uint256 timediff) public view returns(uint256){
        if(chest_capacity_exempt[msg.sender] == true){
            return timediff;
        }
        else{
            return min(chest_capacity, timediff);
        }
    }

    //Number of chest filled
    function nChestFilled(address adr) public view returns(uint256){
        uint256 timediff = SafeMath.sub(block.timestamp,lastCraft[adr]);
        if(chest_capacity < timediff){
            return 2;
        }
        else{
            if(chest_capacity.div(2) > timediff){
                return 0;
            }
            else{
                return 1;
            }
        }
    }

    //Get address lvl multiplier (bonus over base APR)
    function getlvl_multiplier(address adr) public view returns(uint256){
        if(levels[adr] == 1){
            return lvl1_multiplier;
        }
        if(levels[adr] == 2){
            return lvl2_multiplier;
        }
        if(levels[adr] == 3){
            return lvl3_multiplier;
        }
        if(levels[adr] == 4){
            return lvl4_multiplier;
        }
        if(levels[adr] == 5){
            return lvl5_multiplier;
        }
        return lvl1_multiplier;
    }

    //Get multiplier from lvl (bonus over base APR)
    function getlvl_multiplier_from_lvl(uint8 lvl) public view returns(uint256){
        if(lvl == 1){
            return lvl1_multiplier;
        }
        if(lvl == 2){
            return lvl2_multiplier;
        }
        if(lvl == 3){
            return lvl3_multiplier;
        }
        if(lvl == 4){
            return lvl4_multiplier;
        }
        if(lvl == 5){
            return lvl5_multiplier;
        }
        return lvl1_multiplier;
    }

    //Private view/////////

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function treasuryFeeBase(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,treasuryFeeValBase),100);
    }

    function calculateMinersV2Buy(uint256 eth,uint256 contractBalance) private view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketMinersV2);
    }
    
    function getMinersV2SinceLastCraft(address adr) private view returns(uint256) {
        uint256 secondsPassed=min(MINERSV2_TO_CRAFT_1MINER,chestCapacityCheck(SafeMath.sub(block.timestamp,lastCraft[adr])));
        return SafeMath.div(SafeMath.mul(getlvl_multiplier(adr), SafeMath.mul(secondsPassed,hatcheryMiners[adr])), lvlx_denominator);
    }

    //For lvl upgrade
    function treasuryFee(uint256 amount, address adr) private view returns(uint256) {
        uint256 feeApply = treasuryFeeValBase;
        if(levels[adr] > 1){ 
            //You have to pay the level upgrade when you upgrade your level but also on next buys
            feeApply = treasuryFeeVal;
        }
        return SafeMath.div(SafeMath.mul(amount,feeApply),100);
    }

    //Aux/////////////////

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? b : a;
    }
}