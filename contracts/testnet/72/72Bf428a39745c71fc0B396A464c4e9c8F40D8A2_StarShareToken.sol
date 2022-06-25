// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


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
      uint256 investDay;
      uint256 lastHarvestDate;
    }
    struct TodayTotalInvestment{
      uint256 thatDay;
      uint256 InvestmentThatDay;
    }

    struct PreviousReward{
      uint256 previousRewardAmount;
      uint256 lastDay;
      uint256 previousTotalInvestment;
      uint256 previousUserInvestment;
    }

    TodayTotalInvestment[] _todayTotalInvestment_starbusdpair;
    TodayTotalInvestment[] _todayTotalInvestment_starpair;
    TodayTotalInvestment[] _todayTotalInvestment_sharebusdpair;

    IUniswapV2Router02 public _uniswaprouter;
    IUniswapV2Factory public  _factory;  
    address private _starBusdPair;
    address private _starPair;
    address private _shareBusdPair; 
    uint256 private _lpRecieved;
    uint256 private _maxSupply;
    uint256 private shareperdaystarlp = 34664000000000000000;
    uint256 private shareperdaystarbusdlp = 17500000000000000000;
    uint256 private shareperdaysharebusdlp = 17500000000000000000;
    uint256 rewardPeriod = 2 minutes;
    uint256 startTime;

    uint256 private _allUsersInvestment_starbusdpair;
    uint256 private _allUsersInvestment_starpair;
    uint256 private _allUsersInvestment_sharebusdpair;

    mapping (uint256 => uint256 ) public history_starBusdPair; // Daily details of total investmnet for the day. 
    // mapping (address => mapping (uint256 => uint256) ) public investorHistory_starBusdPair;  // Investor history day wise to find day wise share of the user. 
    mapping (address => UserDetails) public userDetails_starBusdPair; // storing total investment, last claim date etc;
    mapping (uint256 => uint256 ) public history_starPair; // Daily details of total investmnet for the day. 
    // mapping (address => mapping (uint256 => uint256) ) public investorHistory_starPair;  // Investor history day wise to find day wise share of the user. 
    mapping (address => UserDetails) public userDetails_starPair; // storing total investment, last claim date etc;
    mapping (uint256 => uint256 ) public history_shareBusdPair; // Daily details of total investmnet for the day. 
    // mapping (address => mapping (uint256 => uint256) ) public investorHistory_shareBusdPair;  // Investor history day wise to find day wise share of the user. 
    mapping (address => UserDetails) public userDetails_shareBusdPair; // storing total investment, last claim date etc;
    mapping (address => PreviousReward) public previousReward_shareBusdPair;
    mapping (address => PreviousReward) public previousReward_starBusdPair;
    mapping (address => PreviousReward) public previousReward_starPair;

    constructor(address contractowner) ERC20("StarShare", "strShare") Ownable(msg.sender) {
    _maxSupply=   73002 * (10 ** uint256(decimals()));
    _mint(address(this), _maxSupply);
    _mint (contractowner, 100*10**uint256(decimals()));
  }

  function intialize(address starsharelp, address starbusd, address sharebusd) public onlyOwner{
    _starPair = starsharelp;
    _starBusdPair = starbusd;
    _shareBusdPair = sharebusd;
    startTime = block.timestamp;
  }
  function invest_starBusdPair(uint256 amount, address tokenAddress) public {
    require(tokenAddress == _starBusdPair," Not a valid token");
    require (IERC20(tokenAddress).allowance(msg.sender,address(this))>=amount,"Not enough allowance");

    IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
    uint256 today = (block.timestamp - startTime)/rewardPeriod;

    // updateHistory_starBusdPair(today);
    history_starBusdPair[today] = history_starBusdPair[today] + amount;
    UserDetails memory details = getDetails_starBusdPair(msg.sender);
    PreviousReward memory _preReward = getpreviousReward_starBusdPair(msg.sender);
    
    if(details.totalInvestment != 0)
    {
      uint256 investTotallastDay = getThatDayInvestment_starBusdPair(details);
      
      if(_preReward.previousRewardAmount == 0 && details.lastHarvestDate == 0){
        uint256 onedayReward= calculationnn(details.totalInvestment, investTotallastDay);
        uint256 firstDays = today - details.investDay;
        _preReward.previousRewardAmount = onedayReward * firstDays;
        _preReward.lastDay = today;
        _preReward.previousTotalInvestment = _allUsersInvestment_starbusdpair;
        _preReward.previousUserInvestment = details.totalInvestment;
        savepreviousReward_starBusdPair(msg.sender, _preReward);
      }
      else{
        uint256 restOfHarvestDay = details.lastHarvestDate - details.investDay;
        if(restOfHarvestDay > 0){
          uint256 onedayReward= calculationnn(details.totalInvestment, investTotallastDay);
          uint256 firstDays = today - details.lastHarvestDate;
          _preReward.previousRewardAmount += onedayReward * firstDays;
          _preReward.lastDay = today;
          _preReward.previousTotalInvestment = _allUsersInvestment_starbusdpair;
          _preReward.previousUserInvestment = details.totalInvestment;
          savepreviousReward_starBusdPair(msg.sender, _preReward);
        }
      }
    }
    if(_todayTotalInvestment_starbusdpair.length == 0){
      _todayTotalInvestment_starbusdpair.push(TodayTotalInvestment(today, amount));
    }
    else{
      for(uint256 i=0; i<_todayTotalInvestment_starbusdpair.length;i++)
      {
        if(today != _todayTotalInvestment_starbusdpair[i].thatDay){
          _todayTotalInvestment_starbusdpair.push(TodayTotalInvestment(today, _allUsersInvestment_starpair));
        }
        else{
          _todayTotalInvestment_starbusdpair[i].InvestmentThatDay += amount; 
        }
      }
    }
    
    // investorHistory_starBusdPair[msg.sender][today] = investorHistory_starBusdPair[msg.sender][today] + amount;

    if(details.totalInvestment == 0 )
    {
        details.lastClaimedDay = today;
        details.lastWithdrawDay = today;
    }
    details.investDay = today;
    details.lastHarvestDate =0;
    details.totalInvestment +=amount;
    _allUsersInvestment_starbusdpair += amount;
    saveDetails_starBusdPair(msg.sender, details);
  }
  function invest_shareBusdPair(uint256 amount, address tokenAddress) public {
    require(tokenAddress == _shareBusdPair," Not a valid token");
    require (IERC20(tokenAddress).allowance(msg.sender,address(this))>=amount,"Not enough allowance");
    IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
    uint256 today = (block.timestamp - startTime)/rewardPeriod;

    // updateHistory_shareBusdPair(today);
    history_shareBusdPair[today] = history_shareBusdPair[today] + amount;
    UserDetails memory details = getDetails_shareBusdPair(msg.sender);
    PreviousReward memory _preReward = getpreviousReward_shareBusdPair(msg.sender);
    
    if(details.totalInvestment != 0)
    {
      uint256 investTotallastDay = getThatDayInvestment_shareBusdPair(details);
      if(_preReward.previousRewardAmount == 0 && details.lastHarvestDate == 0){
        uint256 onedayReward= calculationnn(details.totalInvestment, investTotallastDay);
        uint256 firstDays = today - details.investDay;
        _preReward.previousRewardAmount = onedayReward * firstDays;
        _preReward.lastDay = today;
        _preReward.previousTotalInvestment = _allUsersInvestment_sharebusdpair;
        _preReward.previousUserInvestment = details.totalInvestment;
        savepreviousReward_shareBusdPair(msg.sender, _preReward);
      }
      else{
        uint256 restOfHarvestDay = details.lastHarvestDate - details.investDay;
        if(restOfHarvestDay > 0){
          uint256 onedayReward= calculationnn(details.totalInvestment, investTotallastDay);
          uint256 firstDays = today - details.investDay;
          _preReward.previousRewardAmount += onedayReward * firstDays;
          _preReward.lastDay = today;
          _preReward.previousTotalInvestment = _allUsersInvestment_sharebusdpair;
          _preReward.previousUserInvestment = details.totalInvestment;
          savepreviousReward_shareBusdPair(msg.sender, _preReward);
        }
      }
    }

    if(_todayTotalInvestment_sharebusdpair.length == 0){
      _todayTotalInvestment_sharebusdpair.push(TodayTotalInvestment(today, amount));
    }
    else{
      for(uint256 i=0; i<_todayTotalInvestment_sharebusdpair.length;i++)
      {
        if(today != _todayTotalInvestment_sharebusdpair[i].thatDay){
          _todayTotalInvestment_sharebusdpair.push(TodayTotalInvestment(today, _allUsersInvestment_starpair));
        }
        else{
          _todayTotalInvestment_sharebusdpair[i].InvestmentThatDay += amount; 
        }
      }
    }

    // investorHistory_shareBusdPair[msg.sender][today] = investorHistory_shareBusdPair[msg.sender][today] + amount;

    if(details.totalInvestment == 0 )
    {
        details.lastClaimedDay = today;
        details.lastWithdrawDay = today;
    }
    details.investDay = today;
    details.totalInvestment +=amount;
    details.lastHarvestDate =0;
    _allUsersInvestment_sharebusdpair += amount;
    saveDetails_shareBusdPair(msg.sender, details);
  }
  function invest_starPair(uint256 amount, address tokenAddress) public {
    require(tokenAddress == _starPair," Not a valid token");
    require (IERC20(tokenAddress).allowance(msg.sender,address(this))>=amount,"Not enough allowance");
    IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
    uint256 today = (block.timestamp - startTime)/rewardPeriod;

    // updateHistory_starPair(today);
    history_starPair[today] = history_starPair[today] + amount;
    UserDetails memory details = getDetails_starPair(msg.sender);
    PreviousReward memory _preReward = getpreviousReward_starPair(msg.sender);
    
    if(details.totalInvestment != 0)
    {
      uint256 investTotallastDay = getThatDayInvestment_starPair(details);
      
      if(_preReward.previousRewardAmount == 0 && details.lastHarvestDate == 0){
        uint256 onedayReward= calculationnn(details.totalInvestment, investTotallastDay);
        uint256 firstDays = today - details.investDay;
        _preReward.previousRewardAmount = onedayReward * firstDays;
        _preReward.lastDay = today;
        _preReward.previousTotalInvestment = _allUsersInvestment_starpair;
        _preReward.previousUserInvestment = details.totalInvestment;
        savepreviousReward_starPair(msg.sender, _preReward);
      }
      else{
        uint256 restOfHarvestDay = details.lastHarvestDate - details.investDay;
        if(restOfHarvestDay > 0){
          uint256 onedayReward= calculationnn(details.totalInvestment, investTotallastDay);
          uint256 firstDays = today - details.investDay;
          _preReward.previousRewardAmount += onedayReward * firstDays;
          _preReward.lastDay = today;
          _preReward.previousTotalInvestment = _allUsersInvestment_starpair;
          _preReward.previousUserInvestment = details.totalInvestment;
          savepreviousReward_starPair(msg.sender, _preReward);
        }
      }
    }

    if(_todayTotalInvestment_starpair.length == 0){
      _todayTotalInvestment_starpair.push(TodayTotalInvestment(today, amount));
    }
    else{
      for(uint256 i=0; i<_todayTotalInvestment_starpair.length;i++)
      {
        if(today != _todayTotalInvestment_starpair[i].thatDay){
          _todayTotalInvestment_starpair.push(TodayTotalInvestment(today, _allUsersInvestment_starpair));
        }
        else{
          _todayTotalInvestment_starpair[i].InvestmentThatDay += amount; 
        }
      }
    }

    // investorHistory_starPair[msg.sender][today] = investorHistory_starPair[msg.sender][today] + amount;

    if(details.totalInvestment == 0 )
    {
      details.lastClaimedDay = today;
      details.lastWithdrawDay = today;
    }

    details.investDay = today;
    details.totalInvestment +=amount;
    details.lastHarvestDate =0;
    _allUsersInvestment_starpair += amount;
    saveDetails_starPair(msg.sender, details);
  }
  function calculationnn(uint256 userTotalInvestment, uint256 investthattime) private view returns(uint256 reward) {
    uint256 sharepercentage = ( userTotalInvestment * 100 ) / investthattime;
    reward = ( shareperdaystarbusdlp * sharepercentage ) / 100;
    return reward;
  }
  function calculateRewards_starBusdPair(address user) public view returns (uint256 rewards){
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    UserDetails memory details = getDetails_starBusdPair(user);
    PreviousReward memory _preReward = getpreviousReward_starBusdPair(user);
    rewards = 0 ;
    uint256 investTotallastDay = getThatDayInvestment_starBusdPair(details);
    if(_preReward.previousRewardAmount == 0 && details.lastHarvestDate == 0)
    {
      uint256 rewardPerday = calculationnn(details.totalInvestment, investTotallastDay);
      uint256 totalDays = today - details.investDay;
      rewards = rewardPerday * totalDays;
    }
    else{
      uint256 restOfHarvestDay = details.lastHarvestDate - details.investDay;
      if(restOfHarvestDay > 0){
        uint256 rewardPerday = calculationnn(details.totalInvestment, investTotallastDay);
        uint256 totalDays = today - (details.lastHarvestDate);
        uint256 getLatest = rewardPerday * totalDays;
        rewards = _preReward.previousRewardAmount + getLatest;
      }
    }
    return rewards;
  }
  function calculateRewards_shareBusdPair(address user) public view returns (uint256 rewards){
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    UserDetails memory details = getDetails_shareBusdPair(user);
    PreviousReward memory _preReward = getpreviousReward_shareBusdPair(user);
    rewards = 0 ;
    uint256 investTotallastDay = getThatDayInvestment_shareBusdPair(details);
    
    if(_preReward.previousRewardAmount == 0 && details.lastHarvestDate == 0)
    {
      uint256 rewardPerday = calculationnn(details.totalInvestment, investTotallastDay);
      uint256 totalDays = today - details.investDay;
      rewards = rewardPerday * totalDays;
    }
    else{
      uint256 restOfHarvestDay = details.lastHarvestDate - details.investDay;
      if(restOfHarvestDay > 0){
        uint256 rewardPerday = calculationnn(details.totalInvestment, investTotallastDay);
        uint256 totalDays = today - (details.lastHarvestDate);
        uint256 getLatest = rewardPerday * totalDays;
        rewards = _preReward.previousRewardAmount + getLatest;
      }
    }
    return rewards; 
  }
  function calculateRewards_starPair(address user) public view returns (uint256 rewards){
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    UserDetails memory details = getDetails_starPair(user);
    PreviousReward memory _preReward = getpreviousReward_starPair(user);
    rewards = 0 ;
    uint256 investTotallastDay = getThatDayInvestment_starPair(details);
    
    if(_preReward.previousRewardAmount == 0 && details.lastHarvestDate == 0)
    {
      uint256 rewardPerday = calculationnn(details.totalInvestment, investTotallastDay);
      uint256 totalDays = today - details.investDay;
      rewards = rewardPerday * totalDays;
    }
    else{
      uint256 restOfHarvestDay = details.lastHarvestDate - details.investDay;
      if(restOfHarvestDay > 0){
        uint256 rewardPerday = calculationnn(details.totalInvestment, investTotallastDay);
        uint256 totalDays = today - (details.lastHarvestDate);
        uint256 getLatest = rewardPerday * totalDays;
        rewards = _preReward.previousRewardAmount + getLatest;
      }
    }
    return rewards; 
  }
  function claimRewards_starBusdPair () public {
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    uint256 rewards = calculateRewards_starBusdPair(msg.sender);
    if(rewards > 0)
    {
      IERC20(address(this)).transfer(msg.sender, rewards);
      UserDetails memory details = getDetails_starBusdPair(msg.sender);
      PreviousReward memory _preReward = getpreviousReward_starBusdPair(msg.sender);
      details.lastClaimedDay = today;
      details.totalClaimedRewards += rewards;
      _preReward.previousRewardAmount = 0;
      details.lastHarvestDate =today;
      saveDetails_starBusdPair(msg.sender, details);
      savepreviousReward_starBusdPair(msg.sender,_preReward);
    }
  }
  function claimReward_shareBusdPair () public {
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    // updateHistory_shareBusdPair(today);
    uint256 rewards = calculateRewards_shareBusdPair(msg.sender);
    if(rewards > 0)
    {
        IERC20(address(this)).transfer(msg.sender, rewards);
        UserDetails memory details = getDetails_shareBusdPair(msg.sender);
        PreviousReward memory _preReward = getpreviousReward_shareBusdPair(msg.sender);
        details.lastClaimedDay = today;
        details.totalClaimedRewards +=rewards;
        _preReward.previousRewardAmount = 0;
        details.lastHarvestDate = today;
        savepreviousReward_shareBusdPair(msg.sender,_preReward);
        saveDetails_shareBusdPair(msg.sender, details);
    }
  }
  function claimRewards_starPair() public {

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    // updateHistory_starPair(today);
    uint256 rewards = calculateRewards_starPair(msg.sender);
    if(rewards > 0)
    {
        IERC20(address(this)).transfer(msg.sender, rewards);
        UserDetails memory details = getDetails_starPair(msg.sender);
        PreviousReward memory _preReward = getpreviousReward_starPair(msg.sender);
        details.lastClaimedDay = today;
        details.totalClaimedRewards +=rewards;
        _preReward.previousRewardAmount = 0;
        details.lastHarvestDate =today;
        savepreviousReward_starPair(msg.sender, _preReward);
        saveDetails_starPair(msg.sender, details);
    }
  }
  function withdraw_starBusdPair(uint256 amount) public {
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    // updateHistory_starBusdPair(today);
    claimRewards_starBusdPair();
    UserDetails memory details = getDetails_starBusdPair(msg.sender);
    require(amount <= details.totalInvestment, "Insufficent Investment");
    IERC20(_starBusdPair).transfer(msg.sender, amount);
    // history_starBusdPair[today] -= amount;
    // investorHistory_starBusdPair[msg.sender][today] = investorHistory_starBusdPair[msg.sender][today] - amount;
    details.totalInvestment = details.totalInvestment - amount;
    _allUsersInvestment_starbusdpair = _allUsersInvestment_starbusdpair - amount;
    details.lastClaimedDay = today;
    details.lastWithdrawDay = today;
    saveDetails_starBusdPair(msg.sender, details);
  }
  function withdraw_shareBusdPair(uint256 amount) public {
    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    // updateHistory_shareBusdPair(today);
    claimReward_shareBusdPair();
    UserDetails memory details = getDetails_shareBusdPair(msg.sender);
    require(amount <= details.totalInvestment, "Insufficent Investment");
    IERC20(_shareBusdPair).transfer(msg.sender, amount);
    // history_shareBusdPair[today] -= amount; 
    // investorHistory_shareBusdPair[msg.sender][today] = investorHistory_shareBusdPair[msg.sender][today] - amount;
    details.totalInvestment = details.totalInvestment - amount;
    _allUsersInvestment_sharebusdpair = _allUsersInvestment_sharebusdpair - amount;
    details.lastClaimedDay = today;
    details.lastWithdrawDay = today;
    saveDetails_shareBusdPair(msg.sender, details);
  }
  function withdraw_starPair(uint256 amount) public {

    uint256 today = (block.timestamp - startTime)/rewardPeriod;
    // updateHistory_starPair(today);
    claimRewards_starPair();
    UserDetails memory details = getDetails_starPair(msg.sender);
    require(amount <= details.totalInvestment, "Insufficent Investment");
    IERC20(_starPair).transfer(msg.sender, amount);
    // history_starPair[today] -= amount;
    // investorHistory_starPair[msg.sender][today] = investorHistory_starPair[msg.sender][today] - amount;
    details.totalInvestment = details.totalInvestment - amount;
    _allUsersInvestment_starpair = _allUsersInvestment_starpair - amount;
    details.lastClaimedDay = today;
    details.lastWithdrawDay = today;
    saveDetails_starPair(msg.sender, details);
  }
  function getThatDayInvestment_starPair(UserDetails memory details) private view returns(uint256 totalInvestment){
    totalInvestment = 0;
    for(uint256 i = 0; i < _todayTotalInvestment_starpair.length; i++){
      if(_todayTotalInvestment_starpair[i].thatDay == details.investDay){
        totalInvestment = _todayTotalInvestment_starpair[i].InvestmentThatDay;
      }
    }
    return totalInvestment;
  }
  function getThatDayInvestment_shareBusdPair(UserDetails memory details) private view returns(uint256 totalInvestment){
     totalInvestment = 0;
    for(uint256 i = 0; i < _todayTotalInvestment_sharebusdpair.length; i++){
      if(_todayTotalInvestment_sharebusdpair[i].thatDay == details.investDay){
        totalInvestment = _todayTotalInvestment_sharebusdpair[i].InvestmentThatDay;
      }
    }
    return totalInvestment;
  }
  function getThatDayInvestment_starBusdPair(UserDetails memory details) private view returns(uint256 totalInvestment){
    totalInvestment = 0;
    for(uint256 i = 0; i < _todayTotalInvestment_starbusdpair.length; i++){
      if(_todayTotalInvestment_starbusdpair[i].thatDay == details.investDay){
        totalInvestment = _todayTotalInvestment_starbusdpair[i].InvestmentThatDay;
      }
    }
    return totalInvestment;
  }
  // function updateHistory_starPair(uint256 day) private {
  //   if(day > 0 && history_starPair[day]==0)
  //   {
  //       for(uint i = day; i>0; i--)
  //       {
  //           if(history_starPair[i]>0)
  //           {
  //               history_starPair[day]= history_starPair[i];
  //               break;
  //           }
  //       }            
  //   }
  //   UserDetails memory details = getDetails_starPair(msg.sender);
  //   if(investorHistory_starPair[msg.sender][day]==0)
  //   {
  //       for(uint i = day; i>details.lastWithdrawDay; i--)
  //       {
  //           if(investorHistory_starPair[msg.sender][i]>0)
  //           {
  //               investorHistory_starPair[msg.sender][day]=investorHistory_starPair[msg.sender][i] ;
  //               break;
  //           }
  //       }
  //   }
  // }
  // function updateHistory_shareBusdPair(uint256 day) private {
  //   if(day > 0 && history_shareBusdPair[day]==0)
  //   {
  //       for(uint i = day; i>0; i--)
  //       {
  //           if(history_shareBusdPair[i]>0)
  //           {
  //               history_shareBusdPair[day]= history_shareBusdPair[i];
  //               break;
  //           }
  //       }            
  //   }
  //   UserDetails memory details = getDetails_shareBusdPair(msg.sender);
  //   if(investorHistory_shareBusdPair[msg.sender][day]==0)
  //   {
  //       for(uint i = day; i>details.lastWithdrawDay; i--)
  //       {
  //           if(investorHistory_shareBusdPair[msg.sender][i]>0)
  //           {
  //               investorHistory_shareBusdPair[msg.sender][day]=investorHistory_shareBusdPair[msg.sender][i] ;
  //               break;
  //           }
  //       }
  //   }
  // }
  // function updateHistory_starBusdPair(uint256 day) private {
  //   if(day > 0 && history_starBusdPair[day]==0)
  //   {
  //       for(uint i = day; i>0; i--)
  //       {
  //           if(history_starBusdPair[i]>0)
  //           {
  //               history_starBusdPair[day]= history_starBusdPair[i];
  //               break;
  //           }
  //       }            
  //   }
  //   UserDetails memory details = getDetails_starBusdPair(msg.sender);
  //   if(investorHistory_starBusdPair[msg.sender][day]==0)
  //   {
  //       for(uint i = day; i>details.lastWithdrawDay; i--)
  //       {
  //           if(investorHistory_starBusdPair[msg.sender][i]>0)
  //           {
  //               investorHistory_starBusdPair[msg.sender][day]=investorHistory_starBusdPair[msg.sender][i] ;
  //               break;
  //           }
  //       }
  //   }
  // }
  function getpreviousReward_starBusdPair(address user) public view returns(PreviousReward memory details){
    return previousReward_starBusdPair[user];
  }
  function savepreviousReward_starBusdPair(address user, PreviousReward memory _reward) private {
    previousReward_starBusdPair[user]= _reward;
  }
  function getpreviousReward_shareBusdPair(address user) public view returns(PreviousReward memory details){
      return previousReward_shareBusdPair[user];
  }
  function savepreviousReward_shareBusdPair(address user, PreviousReward memory _reward) private {
        previousReward_shareBusdPair[user]= _reward;
  }
  function getpreviousReward_starPair(address user) public view returns(PreviousReward memory details){
      return previousReward_starPair[user];
  }
  function savepreviousReward_starPair(address user, PreviousReward memory _reward) private {
        previousReward_starPair[user]= _reward;
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
  function saveDetails_starBusdPair(address user, UserDetails memory details) private {
        userDetails_starBusdPair[user]= details;
  }
  function saveDetails_shareBusdPair(address user, UserDetails memory details) private {
        userDetails_shareBusdPair[user]= details;
  }
  function saveDetails_starPair(address user, UserDetails memory details) private {
        userDetails_starPair[user]= details;
  }
  function getshareperdaystarpair() public view returns(uint256 shareperday){
    return shareperdaystarlp;
  }
  function getshareperdaystarbusdpair() public view returns(uint256 shareperday){
    return shareperdaystarbusdlp;
  }
  function getshareperdaysharebusdpair() public view returns(uint256 shareperday){
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