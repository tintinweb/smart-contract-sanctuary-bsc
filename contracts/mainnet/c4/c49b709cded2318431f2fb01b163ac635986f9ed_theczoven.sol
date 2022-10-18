/**
 *Submitted for verification at BscScan.com on 2022-10-18
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

contract theczoven {    
    address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; // Mainnet
    uint256 public EGGS_TO_HATCH_1MINERS=4320000; // 2% daily
    uint256 PSN=10000;
    uint256 PSNH=5000;
	address addr0 = address(0x0);
	address private owner;
    address public ceoAddress;
    address public devAddress;
    address public marAddress;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedEggs;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;	
	mapping(address => bool) private whitelisted; 
    uint256 public marketEggs;   
    uint public startTime = 1666652100; // Mainnet - Monday, October 24, 2022 10:55:00 PM   
	bool public whitelistActive = true; // enabled at launch
    uint256 public whitelistMaxInvest = 500 ether; /** 500 BUSD  **/
    uint256 public minInvest = 1 ether; /** 1 BUSD  **/
	
    constructor() public{
        owner = msg.sender;
        devAddress = msg.sender;
        ceoAddress = address(0x40978F49DaA36ab1F43ce6c2cd86D54D9Ff76ab0); // c
        marAddress = address(0xA60013A3389447d8b61A9390cB6a8868844A9177); // w
        marketEggs = 432000000000;        
    }
	
    function hatchEggs(address ref) public {
        require(block.timestamp > startTime);
        if(ref == msg.sender) {
            ref = 0;
        }
       if(referrals[msg.sender]==0 && referrals[msg.sender]!=msg.sender && hatcheryMiners[ref] > 0) {
            referrals[msg.sender]=ref;
        }
        uint256 eggsUsed=getMyEggs();
        uint256 newMiners=SafeMath.div(eggsUsed,EGGS_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender]=SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
		
		if(!whitelistActive){ //referrals will only be enabled after whitelist period

            //send referral eggs
            address ref1 = referrals[msg.sender];
            if (ref1 != addr0) {
                claimedEggs[ref1] = SafeMath.add(
                    claimedEggs[ref1],
                    SafeMath.div(SafeMath.mul(eggsUsed, 10), 100)
                );
                address ref2 = referrals[ref1];
                if (ref2 != addr0 && ref2 != msg.sender) {
                    claimedEggs[ref2] = SafeMath.add(
                        claimedEggs[ref2],
                        SafeMath.div(SafeMath.mul(eggsUsed, 2), 100)
                    );
                }
            }
        }
        
        //boost market to nerf miners hoarding
        marketEggs=SafeMath.add(marketEggs,SafeMath.div(eggsUsed,5));
    }
    function sellEggs() public {
        require(block.timestamp > startTime);
        uint256 hasEggs=getMyEggs();
        uint256 eggValue=calculateEggSell(hasEggs);
        uint256 fee=devFee(eggValue);
        uint256 fee2=fee/3;
        claimedEggs[msg.sender]=0;
        lastHatch[msg.sender]=now;
        marketEggs=SafeMath.add(marketEggs,hasEggs);
        ERC20(busd).transfer(devAddress, fee2);
        ERC20(busd).transfer(ceoAddress, fee2);
		ERC20(busd).transfer(marAddress, fee2);
        ERC20(busd).transfer(address(msg.sender), SafeMath.sub(eggValue,fee));
    }
    function buyEggs(address ref, uint256 amount) public {
        require(block.timestamp > startTime);
        require(amount >= minInvest, "Mininum investment not met.");
		//if whitelist is active, only whitelisted addresses can invest in the project. 
        if (whitelistActive) {
            require(whitelisted[msg.sender], "Address is not Whitelisted.");
            require(amount <= whitelistMaxInvest, "Maxium investment exceeded.");
        }

        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
        
        uint256 balance = ERC20(busd).balanceOf(address(this));
        uint256 eggsBought=calculateEggBuy(amount,SafeMath.sub(balance,amount));
        eggsBought=SafeMath.sub(eggsBought,devFee(eggsBought));
        uint256 fee=devFee(amount);
        uint256 fee2=fee/3;
        ERC20(busd).transfer(devAddress, fee2);
        ERC20(busd).transfer(ceoAddress, fee2);
		ERC20(busd).transfer(marAddress, fee2);
        claimedEggs[msg.sender]=SafeMath.add(claimedEggs[msg.sender],eggsBought);
        hatchEggs(ref);
    }
    //magic trade balancing algorithm
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) public view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function calculateEggSell(uint256 eggs) public view returns(uint256) {
        return calculateTrade(eggs,marketEggs,ERC20(busd).balanceOf(address(this)));
    }
    function calculateEggBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketEggs);
    }
    function calculateEggBuySimple(uint256 eth) public view returns(uint256){
        return calculateEggBuy(eth,ERC20(busd).balanceOf(address(this)));
    }
    function devFee(uint256 amount) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,5),100);
    }
    function seedMarket(uint256 amount) public {
        ERC20(busd).transferFrom(address(msg.sender), address(this), amount);
    }
    function getBalance() public view returns(uint256) {
        return ERC20(busd).balanceOf(address(this));
    }
    function getMyMiners() public view returns(uint256) {
        return hatcheryMiners[msg.sender];
    }
    function getMyEggs() public view returns(uint256) {
        return SafeMath.add(claimedEggs[msg.sender],getEggsSinceLastHatch(msg.sender));
    }
    function getEggsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(EGGS_TO_HATCH_1MINERS,SafeMath.sub(now,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
	
	// change ownership.
    function changeOwnership(address value) external {
        require(msg.sender == owner, "Admin use only.");
        owner = value;
    }    

     //enable/disable whitelist.
    function setWhitelistActive(bool isActive) public {
        require(msg.sender == owner, "Admin use only.");
        whitelistActive = isActive;
    }

    //single entry.
    function whitelistAddress(address addr, bool value) public {
        require(msg.sender == owner, "Admin use only.");
        whitelisted[addr] = value;
    }  

    //multiple entry.
    function whitelistAddresses(address[] memory addr, bool whitelist) public {
        require(msg.sender == owner, "Admin use only.");
        for(uint256 i = 0; i < addr.length; i++){
            whitelisted[addr[i]] = whitelist;
        }
    }

    //check if whitelisted.
    function isWhitelisted(address Wallet) public view returns(bool whitelist){
        whitelist = whitelisted[Wallet];
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