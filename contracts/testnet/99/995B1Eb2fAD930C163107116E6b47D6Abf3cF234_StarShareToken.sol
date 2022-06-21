// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
//import "./ConsoleLog.sol";


/*
  this is share token contract. shares will distributed to platinum NFTs and people who deposit Str-BUSD-LP, share-BUSD-LP, Str-Share-LP. 
  Shares will be avaialble for 2 years where supply will 73002. 2 token will sent to owner on deployement so that Pools can intiated. Owner need to set all LP addresses 
  for the contract to function properly. 

  Total of 51100 shares will be given as rewards and distribution is as follow. 
  TopStr-BUSD LP	25.00%
  TopShare-BUSD LP	25.00%
  TopStr-TopShare LP	49.52%
  2nd phase cards	0.48%

  so contract will add daily claimed amount to the deposited record and tokens will be transfered to user when he claims rewards. 



*/
contract StarShareToken is ERC20, Ownable {
  using SafeMath for uint256;

    event rewardstransfered(address reciever, uint256 rewards);
    event calculaterewardscalled(address token);
    event dividedbyzero(address asset);

    struct UserDetails {
        uint256 totalInvestment;
        uint256 lastClaimedDay;
        uint256 totalClaimedRewards;
        uint256 lastWithdrawDay;
    }

    IUniswapV2Router02 public _uniswaprouter;
    IUniswapV2Factory public  _factory;  
    address private _starBusdPair;
    address private _starPair;
    address private _shareBusdPair; 
    uint256 private _lpRecieved;
    uint256 private _maxSupply;
    uint256 private shareperdaystarlp = 17500000000000000000;
    uint256 private shareperdaystarbusdlp = 17500000000000000000;
    uint256 private shareperdaysharebusdlp = 34664000000000000000;
    uint256 rewardPeriod = 5 minutes;
    uint256 startTime;

    uint256 private _allUsersInvestment_starbusdpair;
    uint256 private _allUsersInvestment_starpair;
    uint256 private _allUsersInvestment_sharebusdpair;


    mapping (uint256 => uint256 ) public history_starBusdPair; // Daily details of total investmnet for the day. 
    mapping (address => mapping (uint256 => uint256) ) public investorHistory_starBusdPair;  // Investor history day wise to find day wise share of the user. 
    mapping (address => UserDetails) public userDetails_starBusdPair; // storing total investment, last claim date etc;
    mapping (uint256 => uint256 ) public history_starPair; // Daily details of total investmnet for the day. 
    mapping (address => mapping (uint256 => uint256) ) public investorHistory_starPair;  // Investor history day wise to find day wise share of the user. 
    mapping (address => UserDetails) public userDetails_starPair; // storing total investment, last claim date etc;
    mapping (uint256 => uint256 ) public history_shareBusdPair; // Daily details of total investmnet for the day. 
    mapping (address => mapping (uint256 => uint256) ) public investorHistory_shareBusdPair;  // Investor history day wise to find day wise share of the user. 
    mapping (address => UserDetails) public userDetails_shareBusdPair; // storing total investment, last claim date etc;


    constructor(address contractowner) ERC20("StarShare", "strShare") Ownable(msg.sender) {
    _maxSupply=   73002 * (10 ** uint256(decimals()));
    _mint(address(this), _maxSupply);
    _mint (contractowner, 10*10**uint256(decimals()));
  }

  function intialize(address starsharelp, address starbusd, address sharebusd) public onlyOwner{
    _starPair = starsharelp;
    _starBusdPair = starbusd;
    _shareBusdPair = sharebusd;
    startTime = block.timestamp;
  }
  function invest_starBusdPair(uint256 amount, address tokenAddress) public {
    require(tokenAddress == _starBusdPair," Not a valid token");
    //require (IERC20(tokenAddress).allowance(msg.sender,address(this))>=amount,"Not enough allowance");

    //IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);

    uint256 today = (block.timestamp - startTime)/rewardPeriod;

    updateHistory_starBusdPair(today);
    history_starBusdPair[today] = history_starBusdPair[today] + amount;
    UserDetails memory details = getDetails_starBusdPair(msg.sender);
    investorHistory_starBusdPair[msg.sender][today] = investorHistory_starBusdPair[msg.sender][today] + amount;

    if(details.totalInvestment == 0 )
    {
        details.lastClaimedDay = today;
        details.lastWithdrawDay = today;
    }
    details.totalInvestment +=amount;
    _allUsersInvestment_starbusdpair += amount;
    saveDetails_starBusdPair(msg.sender, details);
  }

  function invest_shareBusdPair(uint256 amount, address tokenAddress) public {
    require(tokenAddress == _shareBusdPair," Not a valid token");
    //require (IERC20(tokenAddress).allowance(msg.sender,address(this))>=amount,"Not enough allowance");
    //IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
    uint256 today = (block.timestamp - startTime)/rewardPeriod;

    updateHistory_shareBusdPair(today);
    history_shareBusdPair[today] = history_shareBusdPair[today] + amount;
    UserDetails memory details = getDetails_shareBusdPair(msg.sender);
    investorHistory_shareBusdPair[msg.sender][today] = investorHistory_shareBusdPair[msg.sender][today] + amount;

    if(details.totalInvestment == 0 )
    {
        details.lastClaimedDay = today;
        details.lastWithdrawDay = today;
    }
    details.totalInvestment +=amount;
    _allUsersInvestment_sharebusdpair += amount;
    saveDetails_shareBusdPair(msg.sender, details);
  }

  function invest_starPair(uint256 amount, address tokenAddress) public {
    require(tokenAddress == _shareBusdPair," Not a valid token");
    //require (IERC20(tokenAddress).allowance(msg.sender,address(this))>=amount,"Not enough allowance");
    //IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
    uint256 today = (block.timestamp - startTime)/rewardPeriod;

    updateHistory_starPair(today);
    history_starPair[today] = history_starPair[today] + amount;
    UserDetails memory details = getDetails_starPair(msg.sender);
    investorHistory_starPair[msg.sender][today] = investorHistory_starPair[msg.sender][today] + amount;

    if(details.totalInvestment == 0 )
    {
        details.lastClaimedDay = today;
        details.lastWithdrawDay = today;
    }
    details.totalInvestment +=amount;
    _allUsersInvestment_starpair += amount;
    saveDetails_starPair(msg.sender, details);
  }

  function calculateRewards_starBusdPair(address user) public view returns (uint256 rewards){

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    UserDetails memory details = getDetails_starBusdPair(user);
    rewards = 0 ;
    uint256 userTotalInvestment = details.totalInvestment;
    for(uint256 i = details.lastClaimedDay; i <today; i++)
    {
        uint256 totalInvest = history_starBusdPair[i];
        if(totalInvest > 0)
        {
          uint256 sharepercentage = ( userTotalInvestment * 100 ) / _allUsersInvestment_starbusdpair;
          uint256 reward = ( shareperdaystarbusdlp * sharepercentage ) / 100;
          rewards +=reward;
        }
    }
    return rewards; 
  }

  function calculateRewards_shareBusdPair(address user) public view returns (uint256 rewards){
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    UserDetails memory details = getDetails_shareBusdPair(user);
    rewards = 0 ;
    uint256 userTotalInvestment = details.totalInvestment;
    for(uint256 i = details.lastClaimedDay; i <today; i++)
    {
      uint256 sharepercentage = ( userTotalInvestment * 100 ) / _allUsersInvestment_sharebusdpair;
      uint256 reward = ( shareperdaysharebusdlp * sharepercentage ) / 100;
      rewards +=reward;
    }
    return rewards; 
  }

  function calculateRewards_starPair(address user) public view returns (uint256 rewards){
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    UserDetails memory details = getDetails_starPair(user);
    rewards = 0 ;
    uint256 userTotalInvestment = details.totalInvestment;
    for(uint256 i = details.lastClaimedDay; i <today; i++)
    {
      uint256 sharepercentage = ( userTotalInvestment * 100 ) / _allUsersInvestment_starpair;
      uint256 reward = ( shareperdaystarlp * sharepercentage ) / 100;
      rewards +=reward;
    }
    return rewards; 
  }

  // function calculateRewards_starBusdPair(address user) public view returns (uint256 rewards){

  //   uint256 today = (block.timestamp - startTime)/rewardPeriod;
  //   UserDetails memory details = getDetails_starBusdPair(user);
  //   rewards = 0 ;
  //   for(uint256 i = details.lastClaimedDay; i <today; i++)
  //   {
  //       uint256 totalInvest = history_starBusdPair[i];
  //       if(totalInvest > 0)
  //       {
  //         uint256 userInvest = investorHistory_starBusdPair[user][i];
  //         uint256 sharepercentage = (userInvest*100)/totalInvest;
  //         uint256 reward = (shareperdaystarbusdlp*sharepercentage)/100;
  //         rewards +=reward;
  //       }
  //   }
  //   return rewards; 
  // }

  // function calculateRewards_shareBusdPair(address user) public view returns (uint256 rewards){
  //   uint256 today = (block.timestamp - startTime)/rewardPeriod;
  //   UserDetails memory details = getDetails_shareBusdPair(user);
  //   rewards = 0 ;
  //   for(uint256 i = details.lastClaimedDay; i <today; i++)
  //   {
  //       uint256 totalInvest = history_shareBusdPair[i];
  //       if(totalInvest > 0)
  //       {
  //         uint256 userInvest = investorHistory_shareBusdPair[user][i];
  //         uint256 sharepercentage = (userInvest*100)/totalInvest;
  //         uint256 reward = (shareperdaysharebusdlp*sharepercentage)/100;
  //         rewards += reward;
  //       }
  //   }
  //   return rewards; 
  // }

  // function calculateRewards_starPair(address user) public view returns (uint256 rewards){
  //   uint256 today = (block.timestamp - startTime)/rewardPeriod;
  //   UserDetails memory details = getDetails_starPair(user);
  //   rewards = 0 ;
  //   for(uint256 i = details.lastClaimedDay; i <today; i++)
  //   {
  //       uint256 totalInvest = history_starPair[i];
  //       if(totalInvest > 0)
  //       {
  //         uint256 userInvest = investorHistory_starPair[user][i];
  //         uint256 sharepercentage = (userInvest*100)/totalInvest;
  //         uint256 reward = (shareperdaystarlp*sharepercentage)/100;
  //         rewards +=reward;
  //       }
  //   }
  //   return rewards; 
  // }

  function claimRewards_starBusdPair () public {

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    updateHistory_starBusdPair(today);
    uint256 rewards = calculateRewards_starBusdPair(msg.sender);
    if(rewards > 0)
    {
        IERC20(address(this)).transfer(msg.sender, rewards);
        UserDetails memory details = getDetails_starBusdPair(msg.sender);
        details.lastClaimedDay = today;
        details.totalClaimedRewards +=rewards;
        saveDetails_starBusdPair(msg.sender, details);
    }
  }

  function claimReward_shareBusdPair () public {

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    updateHistory_shareBusdPair(today);
    uint256 rewards = calculateRewards_shareBusdPair(msg.sender);
    if(rewards > 0)
    {
        IERC20(address(this)).transfer(msg.sender, rewards);
        UserDetails memory details = getDetails_shareBusdPair(msg.sender);
        details.lastClaimedDay = today;
        details.totalClaimedRewards +=rewards;
        saveDetails_shareBusdPair(msg.sender, details);
    }
  }

  function claimRewards_starPair() public {

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    updateHistory_starPair(today);
    uint256 rewards = calculateRewards_starPair(msg.sender);
    if(rewards > 0)
    {
        IERC20(address(this)).transfer(msg.sender, rewards);
        UserDetails memory details = getDetails_starPair(msg.sender);
        details.lastClaimedDay = today;
        details.totalClaimedRewards +=rewards;
        saveDetails_starPair(msg.sender, details);
    }
  }
  function withdraw_starBusdPair(uint256 amount) public {
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    updateHistory_starBusdPair(today);
    claimRewards_starBusdPair();
    UserDetails memory details = getDetails_starBusdPair(msg.sender);
    require(amount <= details.totalInvestment, "Insufficent Investment");
    IERC20(_starBusdPair).transfer(msg.sender, amount);
    history_starBusdPair[today] -= amount;
    investorHistory_starBusdPair[msg.sender][today] = investorHistory_starBusdPair[msg.sender][today] - amount;
    details.totalInvestment -=amount;
    _allUsersInvestment_starbusdpair -= amount;
    details.lastClaimedDay = today;
    details.lastWithdrawDay = today;
    saveDetails_starBusdPair(msg.sender, details);
  }
  function withdraw_shareBusdPair(uint256 amount) public {
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    updateHistory_shareBusdPair(today);
    claimReward_shareBusdPair();
    UserDetails memory details = getDetails_shareBusdPair(msg.sender);
    require(amount <= details.totalInvestment, "Insufficent Investment");
    IERC20(_shareBusdPair).transfer(msg.sender, amount);
    history_shareBusdPair[today] -= amount;
    investorHistory_shareBusdPair[msg.sender][today] = investorHistory_shareBusdPair[msg.sender][today] - amount;
    details.totalInvestment -=amount;
    _allUsersInvestment_sharebusdpair -= amount;
    details.lastClaimedDay = today;
    details.lastWithdrawDay = today;
    saveDetails_shareBusdPair(msg.sender, details);
  }
  function withdraw_starPair(uint256 amount) public {

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    updateHistory_starPair(today);
    claimRewards_starPair();
    UserDetails memory details = getDetails_starPair(msg.sender);
    require(amount <= details.totalInvestment, "Insufficent Investment");
    IERC20(_starPair).transfer(msg.sender, amount);
    history_starPair[today] -= amount;
    investorHistory_starPair[msg.sender][today] = investorHistory_starPair[msg.sender][today] - amount;
    details.totalInvestment -=amount;
    _allUsersInvestment_starpair -= amount;
    details.lastClaimedDay = today;
    details.lastWithdrawDay = today;
    saveDetails_starPair(msg.sender, details);

  }

  function updateHistory_starPair(uint256 day) private {
    if(day > 0 && history_starPair[day]==0)
    {
        for(uint i = day; i>0; i--)
        {
            if(history_starPair[i]>0)
            {
                history_starPair[day]= history_starPair[i];
                break;
            }
        }            
    }
    UserDetails memory details = getDetails_starPair(msg.sender);
    if(investorHistory_starPair[msg.sender][day]==0)
    {
        for(uint i = day; i>details.lastWithdrawDay; i--)
        {
            if(investorHistory_starPair[msg.sender][i]>0)
            {
                investorHistory_starPair[msg.sender][day]=investorHistory_starPair[msg.sender][i] ;
                break;
            }
        }
    }
  }
  function updateHistory_shareBusdPair(uint256 day) private {
    if(day > 0 && history_shareBusdPair[day]==0)
    {
        for(uint i = day; i>0; i--)
        {
            if(history_shareBusdPair[i]>0)
            {
                history_shareBusdPair[day]= history_shareBusdPair[i];
                break;
            }
        }            
    }
    UserDetails memory details = getDetails_shareBusdPair(msg.sender);
    if(investorHistory_shareBusdPair[msg.sender][day]==0)
    {
        for(uint i = day; i>details.lastWithdrawDay; i--)
        {
            if(investorHistory_shareBusdPair[msg.sender][i]>0)
            {
                investorHistory_shareBusdPair[msg.sender][day]=investorHistory_shareBusdPair[msg.sender][i] ;
                break;
            }
        }
    }
  }

  function updateHistory_starBusdPair(uint256 day) private {
    if(day > 0 && history_starBusdPair[day]==0)
    {
        for(uint i = day; i>0; i--)
        {
            if(history_starBusdPair[i]>0)
            {
                history_starBusdPair[day]= history_starBusdPair[i];
                break;
            }
        }            
    }
    UserDetails memory details = getDetails_starBusdPair(msg.sender);
    if(investorHistory_starBusdPair[msg.sender][day]==0)
    {
        for(uint i = day; i>details.lastWithdrawDay; i--)
        {
            if(investorHistory_starBusdPair[msg.sender][i]>0)
            {
                investorHistory_starBusdPair[msg.sender][day]=investorHistory_starBusdPair[msg.sender][i] ;
                break;
            }
        }
    }
  }
  function getDetails_starBusdPair(address user) public view returns(UserDetails memory details){
      return userDetails_starBusdPair[user];
  }
  function getDetails_shareBusdPair(address user) public view returns(UserDetails memory details){
    return userDetails_shareBusdPair[user];
  }
  function getDetails_starPair(address user) public view returns(UserDetails memory details){
      return userDetails_starPair[user];
  }
  function saveDetails_starBusdPair(address user, UserDetails memory details) public {
        userDetails_starBusdPair[user]= details;
  }
  function saveDetails_shareBusdPair(address user, UserDetails memory details) public {
        userDetails_shareBusdPair[user]= details;
  }
  function saveDetails_starPair(address user, UserDetails memory details) public {
        userDetails_starPair[user]= details;
  }
  function getshareperdaystarpair() public view returns(uint256 shareperday)
  {
    return shareperdaystarlp;
  }

  function getshareperdaystarbusdpair() public view returns(uint256 shareperday)
  {
    return shareperdaystarbusdlp;
  }

  function getshareperdaysharebusdpair() public view returns(uint256 shareperday)
  {
    return shareperdaysharebusdlp;
  }

  function setshareperdaystarpair(uint256 shareperday) public onlyOwner{
    shareperdaystarlp = shareperday;
  }

  function setshareperdaystarbusdpair(uint256 shareperday) public onlyOwner{
    shareperdaystarbusdlp = shareperday;
  }

  function setshareperdaysharebusdpair(uint256 shareperday) public onlyOwner{
    shareperdaysharebusdlp = shareperday; 
  }

  function getstarbusdpair() public view returns (address pair){
    return _starBusdPair;
  }
  function getstarpair() public view returns (address starpair){
    return _starPair;
  }
  function getsharebusdpair() public view returns(address sharebusdpair){
    return _shareBusdPair;
  } 

  function getAllUsersInvestmentsharebusdpair() public view returns(uint256 totalInvest){
    return _allUsersInvestment_sharebusdpair;
  } 

  function getAllUsersInvestmentstarbusdpair() public view returns(uint256 totalInvest){
    return _allUsersInvestment_starbusdpair;
  } 

  function getAllUsersInvestmentstarpair() public view returns(uint256 totalInvest){
    return _allUsersInvestment_starpair;
  } 

  function setsharebusdpair(address sharebusdpair) public onlyOwner{
    _shareBusdPair = sharebusdpair;
  }

  function setstarbusdpair(address starbusd) public onlyOwner {
    _starBusdPair = starbusd;
  }
  function setstarpair(address starPair) public onlyOwner {
      _starPair= starPair;
  } 
}