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

    IUniswapV2Router02 public _uniswaprouter;
    IUniswapV2Factory public  _factory;  
    address private _starBusdpair;
    address private _starPair;
    address private _shareBusdpair; 
    uint256 private _lpRecieved;
    uint256 private _maxSupply;
    uint256 private shareperdaystarlp = 17500000000000000000;
    uint256 private shareperdaystarbusdlp = 17500000000000000000;
    uint256 private shareperdaysharebusdlp = 34664000000000000000;

    uint256 private lastrewardcal; 

    address[] starlpdepositors;
    address[] starbusdlpdepositors;
    address[] sharebusddepositor;

    struct userDeposit{
        address walletAddress;
        address assetAddress;
        uint256 totalDeposits;
        uint256 totalClaimedRewards;
        uint256 amounttoclaim; 
        uint256 timeofstake;
        uint256 lastclaimtime;
    }

    struct assetDetail{
      uint32 totaldepsitors;
      uint256 totalamount;
    }

    mapping (bytes32 => userDeposit) private userDeposits;
    mapping (address => assetDetail) private assetDetails; 

    constructor(address contractowner) ERC20("StarShare", "strShare") Ownable(msg.sender) {
    _maxSupply=   73002 * (10 ** uint256(decimals()));
    _mint(address(this), _maxSupply);
    _mint (contractowner, 2*10**uint256(decimals()));
    IUniswapV2Router02 uniswaprouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    _uniswaprouter=uniswaprouter;
    lastrewardcal = block.timestamp;
    //_token1 = tokenToPairAddress;
    //CreateLendingPool(_token1);
  }

  function intialize(address starsharelp, address starbusd, address sharebusd) public onlyOwner{
    _starPair = starsharelp;
    _starBusdpair = starbusd;
    _shareBusdpair = sharebusd;
  }
  function addtoarray(address lptokenaddress, address investor) private {
    if(lptokenaddress == _starBusdpair)
    {
      starbusdlpdepositors.push(investor);
    }
    else if(lptokenaddress==_starPair)
    {
      starlpdepositors.push(investor);
    }           
    else{
      sharebusddepositor.push(investor);
    }
  }
 
  function submitlps(address lptokenaddress ,uint256 lpamount) public {

    require (lptokenaddress == _starBusdpair||lptokenaddress==_starPair||lptokenaddress == _shareBusdpair, "Not valid Lp address");

    IERC20(lptokenaddress).transferFrom(msg.sender,address(this),lpamount);

    userDeposit memory deposit = getDeposit(lptokenaddress, msg.sender);
    assetDetail memory asset = getassetDetails(lptokenaddress);
    asset.totalamount+=lpamount;
    if(deposit.totalDeposits<=0)
    {
      deposit.walletAddress= msg.sender;
      deposit.assetAddress = lptokenaddress;
      deposit.totalDeposits +=lpamount;
      deposit.totalClaimedRewards = 0;
      deposit. amounttoclaim=0;
      deposit.timeofstake= block.timestamp;
      deposit.lastclaimtime= block.timestamp;
      asset.totaldepsitors++;
      addtoarray(lptokenaddress, msg.sender);
    }
    else
    {
      deposit.totalDeposits +=lpamount;
      deposit.timeofstake= block.timestamp;
      //claimRewards(lptokenaddress);
    }
    saveDeposit(deposit);
    saveassetDetails(asset,lptokenaddress);
  }


  function getEarnedRewards(address lptokenaddress, address user) public view returns(uint256 rewards){
    require (lptokenaddress == _starBusdpair||lptokenaddress==_starPair||lptokenaddress == _shareBusdpair, "Not valid Lp address");

    uint256 dayssinceclaim = (block.timestamp-lastrewardcal).div(1 minutes);

    require (dayssinceclaim>0, "Reward is ditributed every 1 minute");

    userDeposit memory deposit = getDeposit(lptokenaddress, user);

    if(lptokenaddress==_starPair)
    {

      uint256 totaldeposit = assetDetails[lptokenaddress].totalamount;

      if(totaldeposit>0)
      {

        uint256 sharepercentage = (deposit.totalDeposits.mul(100)).div(totaldeposit);

        return (shareperdaystarlp.mul(sharepercentage.div(100))).mul(dayssinceclaim);
      }
      return 0;

    }
    else if(lptokenaddress == _starBusdpair)
    {
      uint256 totaldeposit = assetDetails[lptokenaddress].totalamount;
      if(totaldeposit>0)
      { 
        uint256 sharepercentage = (deposit.totalDeposits.mul(100)).div(totaldeposit);

        return (shareperdaystarbusdlp.mul(sharepercentage.div(100))).mul(dayssinceclaim);
      }
      return 0;
    }

      else
    {
      uint256 totaldeposit = assetDetails[lptokenaddress].totalamount;
      if(totaldeposit>0)
      {
        uint256 sharepercentage = (deposit.totalDeposits.mul(100)).div(totaldeposit);

        return (shareperdaysharebusdlp.mul(sharepercentage.div(100))).mul(dayssinceclaim);
      }
      return 0;
    }

  }

  function claimRewards(address lptokenaddress) public {
    require (lptokenaddress == _starBusdpair||lptokenaddress==_starPair||lptokenaddress == _shareBusdpair, "Not valid Lp address");
    if((block.timestamp-lastrewardcal).div(1 minutes)>=1) // need to upgraded to 1 day. 1 minute is fo rtesting. 
    {
      emit calculaterewardscalled(lptokenaddress);
      calculaterewards(lptokenaddress);
    }
    userDeposit memory deposit = getDeposit(lptokenaddress, msg.sender);
    
    _transfer(address(this), msg.sender, deposit.amounttoclaim);
    deposit.totalClaimedRewards +=deposit.amounttoclaim;
    deposit.amounttoclaim = 0;
    saveDeposit(deposit);

    emit rewardstransfered(msg.sender,deposit.amounttoclaim);

  }

  function withddrawDeposit(address token, uint256 amount) public {
    require (token == _starBusdpair||token==_starPair||token == _shareBusdpair, "Not valid Lp address");

    claimRewards(token);
    userDeposit memory deposit = getDeposit(token, msg.sender);
    require (deposit.totalDeposits >= amount,"This much amount is not staked");
    IERC20(token).transfer(msg.sender,amount);
    deposit.totalDeposits -= amount;
    saveDeposit(deposit);
    if(deposit.totalDeposits == 0 )
    {
      removeFromArray(token,msg.sender);
    }
  }
  
  function removeFromArray(address tokenAddress, address investor) private {
    bool isavailable = false;
    uint256 index;
    if(tokenAddress==_starPair){
      for(uint i =0 ; i<starlpdepositors.length; i++){
        if(starlpdepositors[i]==investor)
        {
          isavailable = true;
          index = i;
          break;
        }
      }
      if(isavailable){
        starlpdepositors[index]= starlpdepositors[starlpdepositors.length - 1];
        starlpdepositors.pop();
      }
    }
    else if(tokenAddress == _starBusdpair){
      for(uint i =0 ; i<starbusdlpdepositors.length; i++){
        if(starbusdlpdepositors[i]==investor)
        {
          isavailable = true;
          index = i;
          break;
        }
      }
      if(isavailable){
        starbusdlpdepositors[index]= starbusdlpdepositors[starbusdlpdepositors.length - 1];
        starbusdlpdepositors.pop();
      }
    }
    else{
      for(uint i =0 ; i<sharebusddepositor.length; i++){
         if(sharebusddepositor[i]==investor)
        {
          isavailable = true;
          index = i;
          break;
        }
      }
      if(isavailable){
        sharebusddepositor[index]= sharebusddepositor[sharebusddepositor.length - 1];
        sharebusddepositor.pop();
      }
    }
  }

  function calculaterewards(address lptokenaddress) private{
    require (lptokenaddress == _starBusdpair||lptokenaddress==_starPair||lptokenaddress == _shareBusdpair, "Not valid Lp address");

    uint256 dayssinceclaim = (block.timestamp-lastrewardcal).div(1 minutes);

    require (dayssinceclaim>0, "Reward is ditributed every 1 minute");

    if(lptokenaddress==_starPair)
    {

      uint256 totaldeposit = assetDetails[lptokenaddress].totalamount;
      for(uint i =0 ; i<starlpdepositors.length; i++)
      {
        userDeposit memory deposit = getDeposit(lptokenaddress, starlpdepositors[i]);

        uint256 sharepercentage = (deposit.totalDeposits.mul(100)).div(totaldeposit);

        uint256 rewards = (shareperdaystarlp.mul(sharepercentage.div(100))).mul(dayssinceclaim);

        deposit.amounttoclaim+=rewards;
        deposit.lastclaimtime = block.timestamp;

        saveDeposit(deposit);

      }
      lastrewardcal = block.timestamp;
    }
    else if(lptokenaddress == _starBusdpair)
    {
      uint256 totaldeposit = assetDetails[lptokenaddress].totalamount;
      for(uint i =0 ; i<starbusdlpdepositors.length; i++)
      {
        userDeposit memory deposit = getDeposit(lptokenaddress, starbusdlpdepositors[i]);

        uint256 sharepercentage = (deposit.totalDeposits.mul(100)).div(totaldeposit);

        uint256 rewards = (shareperdaystarbusdlp.mul(sharepercentage.div(100))).mul(dayssinceclaim);

        deposit.amounttoclaim+=rewards;
        deposit.lastclaimtime = block.timestamp;

        saveDeposit(deposit);
      }
      lastrewardcal = block.timestamp;

    }
    else
    {
      uint256 totaldeposit = assetDetails[lptokenaddress].totalamount;
      for(uint i =0 ; i<sharebusddepositor.length; i++)
      {
        userDeposit memory deposit = getDeposit(lptokenaddress, sharebusddepositor[i]);

        uint256 sharepercentage = (deposit.totalDeposits.mul(100)).div(totaldeposit);

        uint256 rewards = (shareperdaysharebusdlp.mul(sharepercentage.div(100))).mul(dayssinceclaim);

        deposit.amounttoclaim+=rewards;
        deposit.lastclaimtime = block.timestamp;
        
        saveDeposit(deposit);
      }
      lastrewardcal = block.timestamp;

    }
  
    
    
    //rewards = dayssinceclaim * shareperday;
    //return rewards;

  }

  function getPrivateUniqueKey(address assetAddress, address walletAddress) private pure returns (bytes32){
        
        return keccak256(abi.encodePacked(assetAddress, walletAddress));
  }

  function getDeposit(address assetAddress, address walletAddress) public view returns (userDeposit memory){
        
        return userDeposits[getPrivateUniqueKey(assetAddress, walletAddress)];
  }

  function saveDeposit(userDeposit memory deposit) private returns (userDeposit memory){

        userDeposits[getPrivateUniqueKey(deposit.assetAddress, deposit.walletAddress)] = deposit;

        return deposit;
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
    return _starBusdpair;
  }
  function getstarpair() public view returns (address starpair){
    return _starPair;
  }
  function getsharebusdpair() public view returns(address sharebusdpair){
    return _shareBusdpair;
  } 

  function setsharebusdpair(address sharebusdpair) public onlyOwner{
    _shareBusdpair = sharebusdpair;
  }

  function setstarbusdpair(address starbusd) public onlyOwner {
    _starBusdpair = starbusd;
  }
  function setstarpair(address starPair) public onlyOwner {
      _starPair= starPair;
  } 

  function getassetDetails(address assetAddress) public view returns (assetDetail memory){
        
        return assetDetails[assetAddress];
  }

  function saveassetDetails(assetDetail memory assetdetails, address asset) private returns (assetDetail memory){

        assetDetails[asset] = assetdetails;

        return assetdetails;
  }
  
}