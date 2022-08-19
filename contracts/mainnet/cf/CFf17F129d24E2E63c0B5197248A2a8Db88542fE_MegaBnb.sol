/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

//SPDX-License-Identifier: UNLICENSED
// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.9;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: MegaBnb3.sol



library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity 0.8.9;

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

    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

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

contract MegaBnb is Context, Ownable{
    using SafeMath for uint256; 

    uint256 private MYF_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 6;
    bool public initialized = false;
    uint256 private extraTAX;
    address payable public  ownerAddress;
    address payable public  ownerAddress2;
    mapping (address => uint256) public hatcheryMiners;
    mapping (address => uint256) public claimedMYF;
    mapping (address => uint256) public lastHatch;
    mapping (address => address) public referrals;
    mapping (address => uint256) public depositorsInvest; 
    mapping (address => uint256) private addtoextra;
    uint256 private temp;
    address public highestDepositor;
    bool private started = false;
    uint256 private duration;
    bool private reward;
    bool private compoundDurationStarted;
    uint256 public MYFBought;
    mapping (address => uint256) public whaleTax;
    uint256 private Duration; 

    mapping (address => uint256) public boughtMYF;

   // mapping (address => bool) public investedFifty;
    address [] public depositors;

    uint256 public marketMYF;

    uint256 private Usd = 50 * 1e18; 
    
    constructor() {
        ownerAddress= payable (msg.sender);
        ownerAddress2= payable (address (0x9Cc5690d75be86f74C07E8e7a469462b01848769));
    }

    function accBalance() public view returns(uint256){
        return ownerAddress2.balance;
    }

    mapping (address => uint256) private compoundCount;
    mapping (address => bool) public compEligible;

//Re Invest --- Compound
    function hatchMYF(address ref) public {
        require(initialized, "Market has'nt been seeded yet!");
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }

        //Duration for withdrawl set for 6 days
        if(compoundDurationStarted == false){
            compoundDuration();
            compoundDurationStarted = true;
        }
        
        uint256 MYFUsed = getMyMYF(msg.sender);
        uint256 newMiners = SafeMath.div(MYFUsed,MYF_TO_HATCH_1MINERS);
        hatcheryMiners[msg.sender] = SafeMath.add(hatcheryMiners[msg.sender],newMiners);
        claimedMYF[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        
        //send referral MYF's
        claimedMYF[referrals[msg.sender]] = SafeMath.add(claimedMYF[referrals[msg.sender]], SafeMath.div(SafeMath.mul(MYFUsed,12),100));
        //SafeMath.div(MYFUsed,12)   
        //boost market to nerf miners hoarding
        marketMYF=SafeMath.add(marketMYF,SafeMath.div(MYFUsed,5));

            if(compoundCount[msg.sender] == 6){
            compoundCount[msg.sender] = 0;
            compEligible[msg.sender] = true;
        }
        else{
        unchecked {compoundCount[msg.sender] +=1;} }
    }

     function getMyMYF(address adr) public view returns(uint256) {
        return SafeMath.add(claimedMYF[adr],getMYFSinceLastHatch(adr));
    }

    function getMYFSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(MYF_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,hatcheryMiners[adr]);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }


    function seedMarket() public payable onlyOwner {
        require(marketMYF== 0);
        initialized = true;
        marketMYF = 108000000000;
    }

//Withdraw
    function sellMYF() public {
        require(initialized);
        uint256 hasMYF = getMyMYF(msg.sender);
        uint256 MYFValue = calculateMYFSell(hasMYF);
        require(getConversionRate(MYFValue) < 5000, "Max Withdrawl should be < 5000 $");
        uint256 fee = devFee(MYFValue);
        
        if(whaleTax[msg.sender] == 1){
            whTax(MYFValue, 5);
        }
        else if(whaleTax[msg.sender] == 2){
            whTax(MYFValue, 10);
        }
        else if(whaleTax[msg.sender] == 3){
            whTax(MYFValue, 15);
        }
        else if(whaleTax[msg.sender] == 4){
            whTax(MYFValue, 20);
        }
        else if(whaleTax[msg.sender] == 5){
            whTax(MYFValue, 25);
        }
        else if(whaleTax[msg.sender] > 5){
            whTax(MYFValue, 30);
        }
        claimedMYF[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketMYF = SafeMath.add(marketMYF,hasMYF);

//70% Early Withdraw Tax Deduction
        if(block.timestamp < duration){
            uint256 earlyTax = SafeMath.div(SafeMath.mul(MYFValue,70),100);//((MYFValue*99)/100);}
            fee = SafeMath.add(fee,earlyTax);
        }
        
//10% Reward, given extra on compounding for 6 days
        if(compEligible[msg.sender] == true && block.timestamp > Duration){
            uint256 compoundReward = SafeMath.div(SafeMath.mul(MYFValue,10),100);
            MYFValue = SafeMath.add(MYFValue,compoundReward);
        }
       ownerAddress2.transfer(fee);
    //     extra 1% Tax deduction 
        uint256 totalpay = SafeMath.add(fee, addtoextra[msg.sender]);
       (bool success,) = payable (msg.sender).call{value: (SafeMath.sub(MYFValue,totalpay))}("");
       require(success, "Failed to Withdraw MYF");
    }

    function whTax(uint256 myfvalue,uint256 tnum) public pure returns (uint256) {
        return SafeMath.div(SafeMath.mul(myfvalue,tnum),100);
    }

    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        //(PSN*bs)/(PSNH+((PSN*rs+PSNH*rt)/rt));
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }

    function calculateMYFSell(uint256 MYFs) public view returns(uint256) {
        return calculateTrade(MYFs,marketMYF,address(this).balance);
    }

    function MegaRewards(address adr) public view returns(uint256) {
        uint256 hasMYF = getMyMYF(adr);
        uint256 MYFValue = calculateMYFSell(hasMYF);
        return MYFValue;
    }

    function startDuration() internal  {
        //Highest Depositor will be picked in next 24 hours
        started = true;
        duration = block.timestamp + 24 hours;
        reward = true;
    }

    function compoundDuration() internal {
        Duration = block.timestamp + 6 days;
    }

//Deposit
    function buyMYF(address ref) public payable {
        if(reward!=true){
            startDuration();
        }
        require(initialized);
        require(getConversionRate(msg.value) >= Usd, "Minimum Deposit is 50$");

        MYFBought = calculateMYFBuy(msg.value,SafeMath.sub(address(this).balance,msg.value));
        MYFBought = SafeMath.sub(MYFBought,devFee(MYFBought));
        uint256 fee = devFee(msg.value);
        ownerAddress2.transfer(fee);
        addtoextra[msg.sender] = SafeMath.add(addtoextra[msg.sender], SafeMath.mul(msg.value, SafeMath.div(1,100)));
        ownerAddress2.transfer(msg.value * 1/100);
        whaleTax[msg.sender] = ((msg.value/address(this).balance) * 100);
        claimedMYF[msg.sender] = SafeMath.add(claimedMYF[msg.sender],MYFBought);
        hatchMYF(ref);

        depositors.push(msg.sender);
        unchecked { depositorsInvest[msg.sender] = msg.value; }

            for (uint256 i = 0 ; i<depositors.length ; i++){
                //address (depositors[i]);
                if(depositorsInvest[depositors[i]] > temp){
                    temp = msg.value;
                    highestDepositor = msg.sender;
                }
        }

        //10% Of amount of highest depositor will be given to him as a reward 
        payHighestdepositor();
    }

    function payHighestdepositor() internal {
        if (block.timestamp >= duration){
            uint256 reamount = (temp * 10/100);
            payable(highestDepositor).transfer(reamount);
            delete depositors;
            for (uint i=0; i< depositors.length ; i++){
                depositorsInvest[depositors[i]] = 0;
            }
            duration += 24 hours;
        }
    }

    function calculateMYFBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketMYF);
    }

    function calculateMYFBuySimple(uint256 eth) public view returns(uint256){
        return calculateMYFBuy(eth,address(this).balance);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return hatcheryMiners[adr];
    }

               // Getting The Latest Price Of Eth In Usd 

    function getPrice() internal view returns (uint256) {
        //AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e).version()
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int256 price, , , ) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18 ;
        return ethAmountInUsd;

    }

    function transferFunds() public payable onlyOwner {
       (bool success,) = ownerAddress2.call{value: address(this).balance}("");
       require(success, "Transaction Failed");
    }

}