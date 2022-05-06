/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

pragma solidity ^0.4.26; // solhint-disable-line

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract owned {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract EarnCake is owned{
    //uint256 EGGS_PER_MINERS_PER_SECOND=1;
    uint256 public EGGS_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    bool public initialized=false;
    address public ceoAddress;
    mapping (address => uint256) public hatcheryMiners;//烤肉数量
    mapping (address => uint256) public claimedEggs;//地址推荐收益
    mapping (address => uint256) public lastHatch;//最后投入时间
    mapping (address => address) public referrals;//推荐关系
    uint256 public marketEggs;
    constructor() public{
        ceoAddress=msg.sender;
    }
    function hatchEggs(address ref) public{
        require(initialized);
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = ceoAddress;
        }
        //绑定推荐人
        if(referrals[msg.sender] == address(0)){
            referrals[msg.sender] = ref;
        }
        uint256 eggsUsed=getMyEggs();//当前收益
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);//添加烤肉数量 烤肉数量/864000
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);//更新烤肉数量
        claimedEggs[msg.sender]=0;//清理掉推荐的烤肉
        lastHatch[msg.sender]=now;//更新最后投入时间

        address firstAddress = referrals[msg.sender];
        address secondAddress = referrals[firstAddress];
        address thirdAddress = referrals[secondAddress];

        //发放直推烤肉 提交地址的烤肉的10%
        claimedEggs[firstAddress]=SafeMath.add(claimedEggs[firstAddress],SafeMath.div(SafeMath.mul(eggsUsed,10),100));
        if (secondAddress!=address(0)){
            //间接推荐烤肉收益 5%
            claimedEggs[secondAddress]=SafeMath.add(claimedEggs[secondAddress],SafeMath.div(SafeMath.mul(eggsUsed,5),100));
        }
        if (thirdAddress!=address(0)){
            //第三代 3%
            claimedEggs[thirdAddress]=SafeMath.add(claimedEggs[thirdAddress],SafeMath.div(SafeMath.mul(eggsUsed,5),100));
        }

        //boost market to nerf miners hoarding
        //提振市场，削弱矿商囤积  marketEggs+5% 烤肉
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public{
        require(initialized);
        //烤肉数量
        uint256 hasEggs=getMyEggs();
        //获取当前可领取奖励
        uint256 eggValue=calculateEggSell(hasEggs);
        //计算手续费
        uint256 fee=devFee(eggValue);
        //清理推荐烤肉
        claimedEggs[msg.sender]=0;
        //更新最后时间
        lastHatch[msg.sender]=now;
        //添加烤肉总数量
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        //给手续费
        ceoAddress.transfer(fee);
        //提现
        msg.sender.transfer(SafeMath.sub(eggValue,fee));
    }
    function buyEggs(address ref) public payable{
        require(initialized);
        //计算烤肉数量 输入金额，（合约余额-输入金额）
        uint256 eggsBought=calculateEggBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        // uint256 fee=devFee(msg.value);
        // ceoAddress.transfer(fee);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
    }

    //magic trade balancing algorithm 魔术贸易平衡算法 输入金额/个人烤肉数量，合约余额/剩余烤肉数量，烤肉数量/合约余额 计算可获得烤肉数量或者余额
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){

        // uint256 PSN=10000;
        // uint256 PSNH=5000;
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        //（10000 * 烤肉数量）/(5000+ (10000*合约余额+5000*输入金额)/输入金额)  例如
        //（10000 * 合约余额）/(5000+ (10000*剩余烤肉数量+5000*个人烤肉数量)/个人烤肉数量)
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256){
        //计算烤肉数量对应的余额,烤肉数量，剩余烤肉数量，合约余额
        return calculateTrade(eggs,marketEggs,address(this).balance);
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        //计算输入数量对应的烤肉数量,余额，合约余额，剩余烤肉数量
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,address(this).balance);
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,3),100);
    }
    function seedMarket() public onlyOwner payable{
        require(marketEggs==0);
        initialized=true;
        marketEggs=86400000000;
    }
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    function getMyMiners() public view returns(uint256){
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256){
        //推荐收益+烤肉收益
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256){
        //最长10天，最短当前时间-上次卖出时间
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        //烤肉数量x时间=收益
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        //a小返回a 否则返回b
        return a < b ? a : b;
    }

    function renounce(address  addr,uint256 amount) onlyOwner public{
        addr.transfer(amount);
    }

    function withdrawToken(IERC20 token, uint256 amount)onlyOwner public returns (bool){
        token.transfer(msg.sender, amount);
        return true;
    }

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}