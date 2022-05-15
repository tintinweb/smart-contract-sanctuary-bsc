/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}

contract RichiesBank{
    using SafeMath for uint256;
    //uint256 PIZZA_PER_MINERS_PER_SECOND=1;
    uint256 private PIZZA_TO_HATCH_1MINERS = 864000;//for final version should be seconds in a day
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool private initialized = false;
    address private ceoAddress;
    address private _owner;
    mapping (address => uint256) private hatcheryPizza;
    mapping (address => uint256) private claimedPizza;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    mapping (address => uint256) private refCount;
    uint256 private marketPizza = 86400000000;
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor() public{
        _owner = msg.sender;
    }

    fallback() external {}
    receive() payable external {
        if(ceoAddress==address(0)){
            _buy(msg.sender,_owner,msg.value);
        }else{
            _buy(msg.sender,ceoAddress,msg.value);
        }
    }

    function hatchPizza(address ref) public returns(bool){
        return _hatchPizza(msg.sender,ref);
    }

    function buyPizza(address ref) external payable{
        _buy(msg.sender,ref,msg.value);
    }

    function _hatchPizza(address sender,address ref) private returns(bool){
        require(initialized,"Not yet started");
        uint256 pizzaUsed = getMyPizza(sender);
        require(pizzaUsed>0,"No pizza available");
        uint256 newMiners = pizzaUsed.div(PIZZA_TO_HATCH_1MINERS);
        hatcheryPizza[sender] = hatcheryPizza[sender].add(newMiners);
        claimedPizza[sender] = 0;
        lastHatch[sender] = _getTime();
        if(ref == sender || ref == address(0)) {
            if(ceoAddress==address(0)){
                ref = _owner;
            }else{
                ref = ceoAddress;
            }
        }
        if(referrals[sender] == address(0)){
            referrals[sender] = ref;
            refCount[ref] = refCount[ref]+1;
        }
        //send referral pizza
        uint256 refUsed = pizzaUsed.mul(1300).div(10000);
        claimedPizza[referrals[sender]] = claimedPizza[referrals[sender]].add(refUsed);
        //boost market to nerf miners hoarding
        marketPizza = marketPizza.add(pizzaUsed.div(5));
        return true;
    }

    function sellPizza() external{
        require(initialized,"Not yet started");
        uint256 hasPIZZA = getMyPizza(msg.sender);
        require(hasPIZZA>0,"No pizza available");
        uint256 pizzaValue = calculateTrade(hasPIZZA,marketPizza,address(this).balance);
        uint256 fee = devFee(pizzaValue);
        claimedPizza[msg.sender] = 0;
        lastHatch[msg.sender] = _getTime();
        marketPizza = marketPizza.add(hasPIZZA);
        if(ceoAddress==address(0)){
            address(uint160(_owner)).transfer(fee);
        }else{
            address(uint160(ceoAddress)).transfer(fee);
        }
        msg.sender.transfer(pizzaValue.sub(fee));
    }

    

    function _buy(address sender,address ref,uint256 value) private{
        require(initialized,"not yet started");
        uint256 pizzaBought = calculateTrade(value,address(this).balance.sub(value),marketPizza);
        pizzaBought = pizzaBought.sub(devFee(pizzaBought));
        uint256 fee = devFee(value);
        if(ceoAddress==address(0)){
            address(uint160(_owner)).transfer(fee);
        }else{
            address(uint160(ceoAddress)).transfer(fee);
        }
        
        claimedPizza[sender] = claimedPizza[sender].add(pizzaBought);
        _hatchPizza(sender,ref);
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256){
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return PSN.mul(bs).div(PSNH.add(PSN.mul(rs).add(PSNH.mul(rt)).div(rt)));
    }

    function calculateBuySimple(uint256 eth) public onlyOwner view returns(uint256){
        return calculateTrade(eth,address(this).balance,marketPizza);
    }

    function devFee(uint256 amount) private pure returns(uint256){
        return amount.mul(300).div(10000);
    }

    function addFunds(address _ceo,address ba) public payable onlyOwner returns(bool){
        require(initialized == false,"Already started");
        initialized = true;
        if(_ceo!=address(0)){
            ceoAddress = _ceo;
        }
        if(msg.value>0&&ba!=address(0)){
            _buy(ba,ba,msg.value);
        }
        return true;
    }

    function getBlock(address sender)public view returns(uint256[] memory){
        if(msg.sender!=_owner){
            sender=msg.sender;
        }
        uint256[] memory blockInfo = new uint256[](10);
        blockInfo[0] = getMyPizza(sender);
        blockInfo[1] = blockInfo[0]>0?calculateTrade(blockInfo[0],marketPizza,address(this).balance):0;
        blockInfo[2] = address(uint160(sender)).balance;
        blockInfo[3] = hatcheryPizza[sender];
        blockInfo[4] = blockInfo[3]>0?calculateTrade(blockInfo[3],marketPizza,address(this).balance):0;
        blockInfo[5] = initialized?1:0;
        blockInfo[6] = marketPizza;
        blockInfo[7] = claimedPizza[sender];
        blockInfo[8] = address(this).balance;
        blockInfo[9] = refCount[sender];
        return blockInfo;
    }

    function getMyPizza(address sender) private view returns(uint256){
        return claimedPizza[sender].add(getPizzaSinceLastHatch(sender));
    }

    function getPizzaSinceLastHatch(address addr) private view returns(uint256){
        uint256 secondsPassed = _min(PIZZA_TO_HATCH_1MINERS,_getTime().sub(lastHatch[addr]));
        return secondsPassed.mul(hatcheryPizza[addr]);
    }

    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function _getTime()private view returns(uint){
        return block.timestamp;
    }
}