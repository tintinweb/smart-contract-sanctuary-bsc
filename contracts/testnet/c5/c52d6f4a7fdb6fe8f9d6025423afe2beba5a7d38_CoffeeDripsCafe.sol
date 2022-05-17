/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// File: contracts/coffeedrips.sol


pragma solidity 0.4.26;

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


contract CoffeeDripsCafe{

    address BUSD = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //change its testnest

    bool public LAUNCHED = false;
    uint256 PSN=10000;
    uint256 PSNH=5000;
    uint256 public SHOTS_TO_HATCH_1MINERS=864000;
    address public WALLET_PROJECT;
    address public WALLET_PROJECTINS;
	address public WALLET_DEV;
    address public WALLET_BIZ;
    uint constant public INVEST_MIN_AMOUNT = 1;
    uint public deployDate;
    
    struct Client {
            address referrer;
            uint256 cafe;
            uint256 totalContribution;
            uint256 referralsNumber;
            uint256 invest;
            uint256 BreweNo;
        }
    
    struct Cafe{
            uint256 streetNumber;
            uint256 tips;
        }
    mapping (address => Client) internal clients;
    mapping (address => Cafe) internal cafes;
    mapping (address => uint256) public claimedLattes; //claimedrockets
    mapping (address => uint256) public coffeeMachines;
    mapping (address => uint256) public lastDrink;
    uint256 public marketShots; // marketEggs marketRockets

    constructor(address _walletProjecttvl, address _walletDev, address _walletBiz) public{
        
		WALLET_PROJECT = msg.sender;
        WALLET_PROJECTINS = _walletProjecttvl; //0xFFB81A19000a1A08cBA72fB13DBF59A37Eb9C35f
		WALLET_DEV = _walletDev; //0x72514C459E28D93dd80a70826Cf98246B704bdC9
        WALLET_BIZ = _walletBiz; //0x889ae06e1d622fc06Cb9aeb0961203DA51312AB5
        deployDate = SafeMath.sub(now,7 days);

        Cafe storage cafe = cafes[WALLET_PROJECT];
        cafe.streetNumber= 1;
        cafe.tips = 0;


	}

    //hatch
    function doubleShots(address ref) public {
       require(LAUNCHED);
       
       uint256 shotsUsed = getMyShots();
       uint256 newBrewers=SafeMath.div(shotsUsed,SHOTS_TO_HATCH_1MINERS);
       coffeeMachines[msg.sender] = SafeMath.add(coffeeMachines[msg.sender],newBrewers);
       claimedLattes[msg.sender] = 0;
       lastDrink[msg.sender]=now;
       clients[msg.sender].BreweNo += 1;

       claimedLattes[ref]=SafeMath.add(claimedLattes[ref],SafeMath.div(SafeMath.mul(shotsUsed,10),100));
       cafes[ref].tips += SafeMath.div(SafeMath.mul(shotsUsed,5),100);
       clients[ref].totalContribution += SafeMath.div(SafeMath.mul(shotsUsed,5),100);
       clients[ref].referralsNumber += 1;

       marketShots=SafeMath.add(marketShots,SafeMath.div(shotsUsed,5));

    }

   //sell
    function drinkLatte() public  {
        require(LAUNCHED);
        uint daysDiff =  SafeMath.sub(now,deployDate) / 60 / 60 / 24;
        require(daysDiff > 7 days, 'Selling of shots has not started');
        uint256 hasShots = getMyShots();
        uint256 shotsValue=calculateShotSell(hasShots,getCompoundMagic(msg.sender));
        uint256 fee = pFee(shotsValue,3);
        uint256 biz = pFee(shotsValue,1);
        claimedLattes[msg.sender]=0;
        lastDrink[msg.sender]=now;
        clients[msg.sender].BreweNo = 0;
        marketShots = SafeMath.add(marketShots,hasShots);
        ERC20(BUSD).transfer(WALLET_DEV, fee);
        ERC20(BUSD).transfer(WALLET_BIZ, biz);
        ERC20(BUSD).transfer(WALLET_PROJECTINS, biz);
        ERC20(BUSD).transfer(msg.sender, SafeMath.sub(shotsValue,(fee+biz+fee)));
        
    }

    //buy
    function buyShots(address ref, uint256 amount) public payable {
        require(LAUNCHED);

        Client storage client= clients[msg.sender];
        if(ref == msg.sender || ref == address(0) || coffeeMachines[ref] == 0) {
            client.referrer = WALLET_PROJECT;
            client.cafe = 1;
        }else{
            client.referrer = ref;
            uint256  cafetoJoin = clients[ref].cafe;
            client.cafe = cafetoJoin;
        }

        ERC20(BUSD).transferFrom(address(msg.sender), address(this), amount);
        uint256 balance = ERC20(BUSD).balanceOf(address(this));
        uint256 shotsBought=calculateShotsToBuy(amount,SafeMath.sub(balance,amount));
        client.invest += amount;
        shotsBought=SafeMath.sub(shotsBought,SafeMath.add(SafeMath.add(pFee(shotsBought,3),pFee(shotsBought,1)),pFee(shotsBought,1)));
        uint256 fee = pFee(amount,3);
        uint256 biz = pFee(amount,1);
        ERC20(BUSD).transfer(WALLET_DEV, fee);
        ERC20(BUSD).transfer(WALLET_BIZ, biz);
        ERC20(BUSD).transfer(WALLET_PROJECTINS, biz);
        claimedLattes[msg.sender]=SafeMath.add(claimedLattes[msg.sender],shotsBought);
        doubleShots(ref);
       
    }
    function getCompoundMagic(address adr) public view returns (uint256) {
        uint scbd;

        uint daysCompound = SafeMath.sub(now,lastDrink[adr])/ 60 / 60 / 24;
        uint timesBrewed = clients[adr].BreweNo;

        if(daysCompound == 0 days &&  timesBrewed  == 0){
            scbd=10000;
        }else if(daysCompound >= 6 days &&  timesBrewed >= 6){
            scbd=10000;
        }else if(daysCompound >= 5 days &&  timesBrewed  >= 5){
            scbd=8000;
        }else if(daysCompound >= 4 days &&  timesBrewed  >= 4){
            scbd=7000;
        }else if(daysCompound >= 3 days &&  timesBrewed  >= 3){
            scbd=6000;
        }else if(daysCompound >= 2 days &&  timesBrewed  >= 2){
            scbd=5000;
        }else if(daysCompound >= 1 days &&  timesBrewed  >= 1){
            scbd=4000;
        }else{
            scbd=3000;
        }

        return scbd;
    }


    function getClientCafe(address _ref) public view returns (uint256) {
        uint256 _streetNumber = cafes[_ref].streetNumber;
        return _streetNumber;
    }
    function pFee(uint256 amount, uint256 pf) public pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount,pf),100);
    }

    function calculateShotsToBuy(uint256 amount,uint256 contractBalance) public view returns(uint256){
        return calculateTrade(amount,contractBalance,marketShots, PSN);
    }
  
    function calculateShotSell(uint256 shots, uint256 cbd) public view returns(uint256){
        return calculateTrade(shots,marketShots,ERC20(BUSD).balanceOf(address(this)), cbd);
    }
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs, uint256 cbd) public view returns(uint256){

        return SafeMath.div(SafeMath.mul(cbd,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(cbd,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    function getMyShots() public view returns(uint256){
        return SafeMath.add(claimedLattes[msg.sender],getShotsSinceLastDrink(msg.sender));
    }
    function getShotsSinceLastDrink(address adr) public view returns(uint256){
        uint256 secondsPassed=min(SHOTS_TO_HATCH_1MINERS,SafeMath.sub(now,lastDrink[adr]));
        return SafeMath.mul(secondsPassed,coffeeMachines[adr]);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    function seedMarket() public payable{
        require(msg.sender == WALLET_PROJECT, 'Project has not launched yet');
        require(marketShots==0);
        LAUNCHED=true;
        marketShots=86400000000;
    }
    function getBalance() public view returns(uint256){
        return ERC20(BUSD).balanceOf(address(this));
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