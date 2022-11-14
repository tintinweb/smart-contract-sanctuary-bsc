/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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

    constructor(address newOwner) {
        _setOwner(newOwner);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }   

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

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

contract staking is Ownable {
    using SafeMath for uint256;

    address public treasury;

    uint256 public divider=10000;

    uint256 public rewardPercentage=54750;

    uint256 public refferalFee=100;

    uint256 public bonusUsd=50;

    uint256 public bonusWithdrawUsdLimit=1000;

    bool public hasStart=true;    

    uint256 public totalInvestedToken;
    uint256 public precision = 1e8;
    uint256 public totalWithdrawToken;    
    address [] private investors;  

    uint256 public minimumAmount=0.00001 ether;

    uint256 public maximumAmount=1000000 ether;
    
    struct depoite{
        uint256 amount;
        uint256 depositeTime;
        uint256 checkPointToken;
    }

    struct user {
        depoite[] deposites;
        uint256 totalRewardWithdrawToken;
        uint256 checkToken;
        uint256 withdrawCheckToken;
        uint256 bonus;
    }

    struct refRewards {
        uint256 totalRewards;
        uint256 totalEarn;
    }    
    mapping (address=>refRewards) public refferralRewards;
    mapping (address=>user) public investor;

	event NewDeposit(address indexed user, uint256 amount);
    event Compund(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);
	event RewardWithdraw(address indexed user,uint256 amount);
    AggregatorV3Interface public priceFeedBnb;
    constructor() Ownable(0x43bab6269f1dF083f4FeBD5be81A91DF11e2cf3b){  // paste owner address in ownable
        priceFeedBnb = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);  
    }

    function setBonusUsd(uint256 _usd) public onlyOwner{
        bonusUsd = _usd;
    }

   function setBonusWithdrawUsdLimit(uint256 _usd) public onlyOwner{
        bonusWithdrawUsdLimit = _usd;
    }    

    function toggleSale(bool _sale) public onlyOwner{
        hasStart=_sale;
    }


    function fetchInvestors() public view returns(address [] memory){
		return investors;
	}

	function checkExitsAddress(address _userAdd) private view returns (bool){
       bool found=false;
        for (uint i=0; i<investors.length; i++) {
            if(investors[i]==_userAdd){
                found=true;
                break;
            }
        }
        return found;
    }        

    function getLatestPriceBnb() public view returns (uint256) {
        (,int price,,,) = priceFeedBnb.latestRoundData();
        return uint256(price).div(1e8);
    }   

    function setTax(uint256 _refferralFees) public  onlyOwner{
        refferalFee=_refferralFees;
    }

    function setRewardPercentage(uint256 _rewardPercentage) public  onlyOwner{
        rewardPercentage=_rewardPercentage;        
    }


    function setMinMaxAmount(uint256 _min,uint256 _max) public onlyOwner{
        minimumAmount = _min;
        maximumAmount = _max;
    }       

    function invest(address reffer) public payable {
        require(hasStart,"Sale is not satrted yet");
        require(maximumAmount>=msg.value,"Amount less then maximum amount");
        require(minimumAmount<=msg.value,"Amount greater then minimum amount");        
        user storage users=investor[msg.sender];
                
        if(reffer!=address(0) && reffer!=msg.sender){
            uint256 RefferalTax=msg.value.mul(refferalFee).div(divider);            
            refferralRewards[reffer].totalRewards += RefferalTax;
            refferralRewards[reffer].totalEarn += RefferalTax;
        }        

        if(!checkExitsAddress(msg.sender)){
            users.bonus = usdToBnbAmount(bonusUsd);
            investors.push(msg.sender);
        }
         
        payable(owner()).transfer(msg.value);        

        users.deposites.push(depoite(msg.value, block.timestamp,block.timestamp));
        totalInvestedToken=totalInvestedToken.add(msg.value);
        users.checkToken=block.timestamp;
        emit NewDeposit(msg.sender, msg.value);
    }

 
    function bnbToUsdAmount(uint256 _amount) public view returns(uint256){                
        uint256 bnbToUsd = _amount.mul(getLatestPriceBnb());                  
        return bnbToUsd.div(1e18);
    }

    function usdToBnbAmount(uint256 _usd) public view returns(uint256){                  
        uint256 usdToBnb = _usd.mul(precision).div(getLatestPriceBnb());                  
        return usdToBnb.mul(1e18).div(precision);
    }    

    
    function claimRefferalRewards() public {        
        require(refferralRewards[msg.sender].totalRewards>0,"You don't have rewards yet");
        require(refferralRewards[msg.sender].totalRewards<=getContractBNBBalacne(),"Not Enough Balance for withdrwal from contract please try after some time");
        uint256 rewards = refferralRewards[msg.sender].totalRewards;
        payable(msg.sender).transfer(rewards);
        refferralRewards[msg.sender].totalRewards -= rewards;
        emit Withdrawn(msg.sender, rewards); 
    }


    function reinvest() public payable {
        require(hasStart,"Sale is not satrted yet");
        user storage users =investor[msg.sender];        
        (uint256 amount)=calclulateReward(msg.sender);
        
        require(amount>0,"Compund Amount very low");
        users.deposites.push(depoite(amount, block.timestamp,block.timestamp));
        totalInvestedToken=totalInvestedToken.add(amount);
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            investor[msg.sender].deposites[i].checkPointToken=block.timestamp;
        }
        users.withdrawCheckToken=block.timestamp;
        
        users.checkToken=block.timestamp;                
        emit Compund(msg.sender, amount);
    }
   
    function withdrawTokens() public {
        require(hasStart,"Sale is not Started yet");
        uint256 totalDeposite=getUserTotalDepositeToken(msg.sender);
        uint256 totalRewards=calclulateReward(msg.sender);
        uint256 totalWithdrawAmount = totalDeposite.add(totalRewards);

        require(totalWithdrawAmount>0,"No Deposite Found");
        require(totalWithdrawAmount<=getContractBNBBalacne(),"Not Enough Balance for withdrwal from contract please try after some time");                
        totalWithdrawToken += totalDeposite;
        user storage users =investor[msg.sender];
        payable(msg.sender).transfer(totalWithdrawAmount);

        if(users.bonus > 0){
            if(bnbToUsdAmount(totalRewards) >= bonusWithdrawUsdLimit){
                payable(msg.sender).transfer(users.bonus);
                users.bonus = 0;
            }
        }

        users.totalRewardWithdrawToken=totalWithdrawAmount;
        for(uint256 i=0;i<investor[msg.sender].deposites.length;i++){
            investor[msg.sender].deposites[i].amount=0;
            investor[msg.sender].deposites[i].checkPointToken=0;
        }        
        emit Withdrawn(msg.sender, totalDeposite);        
    }
    
    function calclulateReward(address _user) public view returns(uint256){
        uint256 totalRewardToken;
        user storage users=investor[_user];
        for(uint256 i=0;i<users.deposites.length;i++){
            if(users.deposites[i].amount>0){                
                uint256 depositeAmount=users.deposites[i].amount;
                uint256 time = block.timestamp.sub(users.deposites[i].checkPointToken);
                totalRewardToken += depositeAmount.mul(rewardPercentage).div(divider).mul(time).div(1 days).div(365);            
            }
        }
        return(totalRewardToken);
    }

    function calculatePerDayRewards() public view returns(uint256 depositeAmount){
        uint256 totalDepositedAmount = totalInvestedToken.sub(totalWithdrawToken);
        depositeAmount = totalDepositedAmount.mul(rewardPercentage).div(divider).div(365);            
    }

    function getUserTotalDepositeToken(address _user) public view returns(uint256 _totalInvestment){
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            _totalInvestment=_totalInvestment.add(investor[_user].deposites[i].amount);
        }
    }
    
    function getUserTotalRewardWithdrawToken(address _user) public view returns(uint256 _totalWithdraw){
        _totalWithdraw=investor[_user].totalRewardWithdrawToken;
    }    

    function getContractBNBBalacne() public view returns(uint256 totalBNB){
        totalBNB=address(this).balance;
    }
    function withdrawBNB() public onlyOwner{
        payable(owner()).transfer(getContractBNBBalacne());
    }
    function getUserDepositeHistoryToken( address _user) public view  returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](investor[_user].deposites.length);
        uint256[] memory time = new uint256[](investor[_user].deposites.length);
        for(uint256 i=0;i<investor[_user].deposites.length;i++){
            amount[i]=investor[_user].deposites[i].amount;
            time[i]=investor[_user].deposites[i].depositeTime;
        }
        return(amount,time);
    }

    function getUserRefferalRewards(address _address) public view returns(uint256 totalRewards, uint256 totalEarn){        
        totalRewards = refferralRewards[_address].totalRewards;        
        totalEarn = refferralRewards[_address].totalEarn;
    }
    receive() external payable {
      
    }
     
}