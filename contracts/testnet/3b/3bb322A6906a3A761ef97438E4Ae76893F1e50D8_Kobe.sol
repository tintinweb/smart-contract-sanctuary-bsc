/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-15
 */

pragma solidity ^0.8.9; // solhint-disable-line

contract Kobe {
    uint256 EGGS_TO_HATCH_1MINERS=1;
    //uint256 private EGGS_TO_HATCH_1MINERS = 2592000; 
    uint256 PSN = 10000;
    uint256 PSNH = 5000;
    bool private initialized = false;
    address private devAddress = 0x5Fc3B14bdDB53a7f6cc4917cc36D8160dBE92b1a; 
    mapping(address => uint256) private hatcheryMiners;
    mapping(address => uint256) private claimedEggs;
    mapping(address => uint256) private lastHatch;
    mapping(address => address) private referrals; 
    mapping(address => uint256) private investments;
    mapping(address => uint256) private withdrawals;
    uint256 private marketEggs;
    uint256 private totalUsers;
    uint256 private totalInvestment;
    uint256 private refPercents = 13;

    event buyEvent(address indexed user, uint256 amount, address referrer);
    event sellEvent(address indexed user, uint256 amount);
    event hatchEvent(address indexed user, uint256 eggs, uint256 miners);

    constructor() public {   
        hatcheryMiners[msg.sender] = 1;
    }

    function hatchEggs(address ref) public {
        require(initialized);

        if(ref == msg.sender || ref == address(0) || hatcheryMiners[ref] == 0) {
            ref = devAddress;
        } 

        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }
        
        uint256 eggsUsed = getMyEggs(msg.sender);
        uint256 newMiners = eggsUsed / EGGS_TO_HATCH_1MINERS;
        hatcheryMiners[msg.sender] = hatcheryMiners[msg.sender] + newMiners;
    
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
 
        if (referrals[msg.sender] != address(0)) {
            address _ref = referrals[msg.sender];
            claimedEggs[_ref] = claimedEggs[_ref] + eggsUsed * refPercents / 100; 
        } 

        marketEggs = marketEggs + eggsUsed / 5;
        emit hatchEvent(msg.sender, eggsUsed, newMiners);
    }

    function sellEggs() public {
        require(initialized);
        uint256 hasEggs = getMyEggs(msg.sender);
        uint256 eggValue = calculateEggSell(hasEggs);
        uint256 fee = devFee(eggValue);
        claimedEggs[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketEggs = marketEggs + hasEggs;
        payable(devAddress).transfer(fee);
        payable(msg.sender).transfer(eggValue - fee);
        withdrawals[msg.sender] = withdrawals[msg.sender] + eggValue - fee;
        emit sellEvent(msg.sender, eggValue);
    }

    function buyEggs(address ref) public payable {
        require(initialized);
        require(msg.value>=10**17);
        require(ref != msg.sender && ref != address(0) && hatcheryMiners[ref] > 0);
        
        if (referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
            totalUsers += 1;
        }
        uint256 eggsBought = calculateEggBuy( msg.value, address(this).balance -  msg.value );
        eggsBought = eggsBought - devFee(eggsBought);
        uint256 fee = devFee(msg.value);
        payable(devAddress).transfer(fee); 
        claimedEggs[msg.sender] =  claimedEggs[msg.sender] + eggsBought;
        hatchEggs(ref);
        totalInvestment = totalInvestment + msg.value;
        investments[msg.sender] = investments[msg.sender] + msg.value;
        emit buyEvent(msg.sender, msg.value, ref);
    }
 
    function calculateTrade(
        uint256 rt,
        uint256 rs,
        uint256 bs
    ) public view returns (uint256) { 
        if(rt==0) return 0;
        return (PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
    }

    function calculateEggSell(uint256 eggs) public view returns (uint256) {
        return calculateTrade(eggs, marketEggs, address(this).balance);
    }

    function calculateEggBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
        return calculateTrade(eth, contractBalance, marketEggs);
    }

    function calculateEggBuySimple(uint256 eth) public view returns (uint256) {
        return calculateEggBuy(eth, address(this).balance);
    }

    function devFee(uint256 amount) public pure returns (uint256) {
        return amount * 60 / 1000;
    }

    function seedMarket() public payable {
        require(msg.sender == devAddress, "invalid call");
        require(marketEggs == 0);
        initialized = true;
        marketEggs = 259200000000;
    } 

    function getBalance() public view returns (uint256) {
        return address(this).balance; 
    }

    function getMyMiners(address adr) public view returns (uint256) {
        return hatcheryMiners[adr];
    }

    function getMyEggs(address adr) public view returns (uint256) {
        return claimedEggs[adr] + getEggsSinceLastHatch(adr);
    }

    function getEggsSinceLastHatch(address adr) public view returns (uint256) {
        uint256 secondsPassed = min(EGGS_TO_HATCH_1MINERS, block.timestamp - lastHatch[adr] );
        return secondsPassed * hatcheryMiners[adr];
    }

    function getContractData(address adr) public view returns ( uint256[] memory ){
        uint[] memory d = new uint[](13);
        d[0] = getMyMiners(adr);
        d[1] = getMyEggs(adr);
        d[2] = calculateEggSell(getMyEggs(adr));
        d[3] = getEggsSinceLastHatch(adr); 
        d[5] = investments[adr];
        d[6] = withdrawals[adr];
        d[7] = lastHatch[adr];
        d[8] = getBalance();
        d[9] = marketEggs;
        d[10] = totalUsers;
        d[11] = totalInvestment;
        d[12] = calculateEggSell(2592000) * 105 * getMyMiners(adr) / 100;
        return d;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}