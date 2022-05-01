/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

pragma solidity ^0.4.26; // solhint-disable-line

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract MoleMiner{

    //address busdt = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //Testnet
    address busdt = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // Mainnet
    uint256 public MOLES_TO_HATCH_1MINERS=864000;//for final version should be seconds in a day
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint256[] public REFERRAL_PERCENTS = [10, 2, 0];
    uint256[] public REFERRAL_MINIMUM = [50000000000000000000, 250000000000000000000, 0];
    bool public initialized=false;
    address public ceoAddress;
    address public ceoAddress1;

    struct User {
            address referrer;
            uint256 referrals;
            uint256 invest;
            bool l2;
            bool l3;
        }

    mapping (address => User) internal users;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedMoles;
    mapping (address => uint256) public lastHatch;
    uint256 public marketMoles;
    constructor(address _developer) public{
        ceoAddress=msg.sender;
        ceoAddress1=_developer;
    }
    function hatchMoles() public{  
        require(initialized);
      
        uint256 molesUsed=getMyMoles(msg.sender);
        uint256 bonus =getMyMoles(msg.sender)/100*2;
        uint256 newMiners=SafeMath.div((molesUsed+bonus),MOLES_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedMoles[msg.sender]=0;
        lastHatch[msg.sender]=now;

        //boost market to nerf miners hoarding
        marketMoles=SafeMath.add(marketMoles,SafeMath.div(molesUsed,5));
    }
    function sellMoles() public{
        require(initialized);
        uint256 hasMoles=getMyMoles(msg.sender);
        uint256 moleValue=calculateMolesSell(hasMoles);
        uint256 fee=devFee(moleValue);
         uint256 fee2 = devFee2(moleValue);
        claimedMoles[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketMoles=SafeMath.add(marketMoles,hasMoles);
        ERC20(busdt).transfer(ceoAddress1, fee);
        ERC20(busdt).transfer(ceoAddress, fee2);
        ERC20(busdt).transfer(msg.sender, SafeMath.sub(moleValue,(fee+fee2)));
    }
    function buyMoles(address ref, uint256 amount) public payable{
        require(initialized);

        User storage user = users[msg.sender];
        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            user.referrer = ceoAddress1;
        }else{
            user.referrer = ref;
        }


        ERC20(busdt).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(busdt).balanceOf(address(this));
        uint256 molesBought=calculateMoleBuy(amount,SafeMath.sub(balance,amount));

        user.invest += amount;
        
        molesBought=SafeMath.sub(molesBought,SafeMath.add(devFee(molesBought),devFee2(molesBought)));
        uint256 fee = devFee(amount);
        uint256 fee2 = devFee2(amount);
        ERC20(busdt).transfer(ceoAddress1, fee);
        ERC20(busdt).transfer(ceoAddress, fee2);
        claimedMoles[msg.sender]=SafeMath.add(claimedMoles[msg.sender],molesBought);

        if (user.referrer != address(0)) {
            bool go = false;
            address upline = user.referrer;
            for (uint256 i = 0; i < 3; i++) {
                if (upline != address(0)) {
                    if(i==1)                    {
                        if(users[upline].l2 == true) go = true;
                    }
                    else if(i==2)                    {
                        if(users[upline].l3 == true) go = true;
                    }
                   
                    if(users[upline].invest >= REFERRAL_MINIMUM[i] || go == true){            
                        uint256 amount3 = amount/100*REFERRAL_PERCENTS[i];                      
                        ERC20(busdt).transfer(upline, amount3);
                    }
                    upline = users[upline].referrer;
                    go = false;
                }
            }

        hatchMoles();
        }
    }

    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256){
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateMolesSell(uint256 moles) public view returns(uint256){
        return calculateTrade(moles,marketMoles,ERC20(busdt).balanceOf(address(this)));
    }
    function calculateMoleBuy(uint256 eth,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(eth,contractBalance,marketMoles);
    }
    function calculateMoleBuySimple(uint256 eth) public view returns(uint256){
        return calculateMoleBuy(eth,ERC20(busdt).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,2),100);
    }
    function devFee2(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,7),100);
    }
    function seedMarket() public payable{
        require(msg.sender == ceoAddress, 'invalid call');
        require(marketMoles==0);
        initialized=true;
        marketMoles=86400000000;
    }
    function getBalance() public view returns(uint256){
        return ERC20(busdt).balanceOf(address(this));
    }
    function getMyMiners(address user) public view returns(uint256){
        return hatcheryMiners[user];
    }
    function getMyMoles(address user) public view returns(uint256){
        return SafeMath.add(claimedMoles[user],getMolesSinceLastHatch(user));
    }
    function getMolesSinceLastHatch(address adr) public view returns(uint256){
        uint256 secondsPassed=min(MOLES_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }

    function unlocklevel(address userAddr, bool l2, bool l3) external{
        require(ceoAddress == msg.sender, "only owner");
	    users[userAddr].l2 = l2;
	    users[userAddr].l3 = l3;
    }

    function checkUser(address userAddr) external view returns(uint256 invest, address ref){
	 invest = users[userAddr].invest;
     ref = users[userAddr].referrer;
	}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
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