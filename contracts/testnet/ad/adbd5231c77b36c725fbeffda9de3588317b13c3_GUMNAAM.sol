/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

interface BEP20 {
  //predefined functions
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Ownable {
  address public owner; 

  constructor() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}
contract GUMNAAM is Ownable {   
   


  struct Investor {
    bool registered;
    address referer;
    address leftUser;
    address rightUser;
    address parentAssociate;
    address refererAssociate;
    uint position;
    uint referralIncome;
    uint token;
    uint investedBusd;
    uint userType; //1=customer,2=agent,3=associate,4=diamond
    uint matixPoolId;
    uint matrixIncome;
    uint matchingIncome;
  }


  struct MatrixPool {
      address referral;
      address leftUser;
      address middleUser;
      address rightUser;
      uint belowCount;
  }

  struct matchingData{
    uint leftUsers;
    uint rightUsers;
    uint oldLeftUsers;
    uint oldRightUsers;
  }

  uint systemIncome;
  uint public decimalVal = (10**18);
  uint public oneDay = 86400; 
  uint public totalInvestors;
  uint public totalInvested;
  address nullAddr = 0x0000000000000000000000000000000000000000;
  
  uint public tokenPrice = 20;
  uint public tokenDecimal = 100;
  uint public matrixBaseAmount = 25;
  //address public busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //mainnet
  address public busdToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
  address public contractAddr = address(this);

  uint[] public poolBase ;

  uint[] public refReward;  
  //uint[] public referralLevelIncome; 
  uint[] referralLevelIncome = [160,80,40,20,10,10,10,10,5,5,5,5,5,5,5,5,5,5,5,5]; 

  mapping (address => Investor) public investors;
  mapping (address => matchingData) public matchingdatas;

  mapping (uint => mapping(address => MatrixPool)) public matrixpools;
  mapping (uint => mapping(uint=>address[])) public matrixlevel;

  address [] public binaryAddresses;
  uint public hourlyBinaryUser;


  event registerAt(address user, uint amount, address referer);
  event becomeAssociateAt(address user, address referer, uint amount, uint position);
  event becomeAgentAt(address user, uint amount);
  event TransferOwnership(address user);
  

  constructor() {
    investors[owner].registered = true;
    investors[owner].userType = 3; // make owner as default associate
    poolBase.push(20); // update pool Incomes array
    hourlyBinaryUser++;
    for(uint i = 0; i<14; i++){
        if(i!=0){
          poolBase.push((2**(i-1))*50); // update pool Incomes array
        }
        // add owner at top in all metrix pool
        matrixpools[i][owner].referral=address(nullAddr);
        matrixlevel[i][0].push(owner);
    }

    
    
    
  }
  /*
  register as customer
  */
  function registerCustomer(address referer,uint bnbAmount) external {
        
        require(!investors[msg.sender].registered,"User already registered");
        require(investors[referer].userType>=2,"Invalid Referral");
        require(bnbAmount == 30,"Minimum 30 Busd");
        
        bnbAmount = bnbAmount * decimalVal; 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        if(investors[referer].userType>=3){
            //20 BUSD to sponsor
            investors[referer].referralIncome += 20*decimalVal;
            if(referer!=owner){
              tokenAmt += tokenAmt*20/100; // 20% extra token
            }
        }
        else if(investors[referer].userType==2){
            //10 BUSD to sponsor
            investors[referer].referralIncome += 10*decimalVal;
            if(referer!=owner){
              tokenAmt += tokenAmt*10/100; // 10% extra token
            }
        }
        
        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
       
        investors[msg.sender].registered = true;
        investors[msg.sender].token = tokenAmt;
        investors[msg.sender].referer = referer;
        investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 1; //

        emit registerAt(msg.sender,bnbAmount,referer);
    }

    /*
    become agent for referral
    */

    function becomeAgent(uint bnbAmount) external {
        require(investors[msg.sender].registered,"User Not registered");
        require(bnbAmount == 50,"Minimum 50 Busd");
        
        bnbAmount = bnbAmount * decimalVal; 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        
        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
        
        investors[msg.sender].token += tokenAmt;
        investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 2; //

        emit becomeAgentAt(msg.sender,bnbAmount);
    }

    function updateParentUserCount(address user) internal {

      if(user != address(0x0000000000000000000000000000000000000000)){
        address parent = investors[user].parentAssociate;
        if(investors[parent].leftUser == user){
          matchingdatas[parent].leftUsers++;
        }
        else{
          matchingdatas[parent].rightUsers++;
        }
        updateParentUserCount(parent);
      }
    }

    /*
    get binary parent
    */


    function  getParentAssociate(address refUser,uint position) public view returns (address) {
        if(position==1){
            if(investors[refUser].leftUser == address(nullAddr)){
                return refUser;
            }
            else {
                return getParentAssociate(investors[refUser].leftUser,position);
            }
        }
        else {
             if(investors[refUser].rightUser == address(nullAddr)){
                return refUser;
            }
            else {
                return getParentAssociate(investors[refUser].rightUser,position);
            }
        }
       
    }

    /*
    find pool Matrix Parent    
    */
    function getParentMatixAddr(uint poolId) public view returns (address addr,uint i) {
        for( i=0; i < 5; i++){
            for(uint j=0; j < matrixlevel[poolId][i].length;j++){
                    addr = matrixlevel[poolId][i][j];
                    if(matrixpools[poolId][addr].leftUser==address(nullAddr) ||
                        matrixpools[poolId][addr].middleUser==address(nullAddr) || 
                        matrixpools[poolId][addr].rightUser==address(nullAddr)){
                        return ( addr ,i);
                    }
            }
        }
    }

    /*
    LEFT - 1 
    RIGHT - 2
    */
    function becomeAssociate(address referer,uint bnbAmount,uint position) external {
        
        require(position==1 || position==2,"Invalid Position");
        require(investors[referer].userType>=3,"Invalid Referral");
        require(bnbAmount == 130,"Minimum 130 Busd");
        uint poolId = 0;
        if(investors[msg.sender].registered){
            require(investors[msg.sender].userType==2,"Agent could be associate");
        }
        
        bnbAmount = bnbAmount * decimalVal; 
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        
        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        
        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);
       
        address parentAssociate = getParentAssociate(referer,position);

        if(!investors[msg.sender].registered) {
            investors[msg.sender].referer = referer;
            investors[msg.sender].registered = true;
        }

        if(position==1){
           investors[parentAssociate].leftUser = msg.sender;
        }
        else {
           investors[parentAssociate].rightUser = msg.sender;
        }
        hourlyBinaryUser++;
        
        investors[msg.sender].token += tokenAmt;
        investors[msg.sender].parentAssociate = parentAssociate;
        investors[msg.sender].refererAssociate = referer;
        investors[msg.sender].position = position;
        investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].userType = 3; //


        updateParentUserCount(msg.sender);

        appendMatrix(msg.sender, poolId);

        referralIncome();

        emit becomeAssociateAt(msg.sender, referer, bnbAmount, position);
    }

    /*
    participate in next matrix pool  
    */
    function updateMatixPool(uint bnbAmount) external {
        require(investors[msg.sender].userType>=3,"Become Associate First");
        require(investors[msg.sender].matixPoolId<14,"No More Pool Available");
        uint nextPoolId = investors[msg.sender].matixPoolId + 1;
        require(poolBase[nextPoolId]==bnbAmount,"Insufficient BNB amount");

        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");

        bnbAmount = bnbAmount*decimalVal;

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,contractAddr,bnbAmount);

        uint tokenAmt = (bnbAmount*tokenPrice)/tokenDecimal;

        investors[msg.sender].investedBusd += bnbAmount;
        investors[msg.sender].token += tokenAmt;
        appendMatrix(msg.sender,nextPoolId);
    }

    function referralIncome() internal {
        address rec = investors[msg.sender].referer;
        
        for (uint i = 0; i < 20; i++) {
            if (!investors[rec].registered) {
                break;
            }
            if(investors[rec].userType>=3){
              investors[rec].referralIncome += referralLevelIncome[i]*decimalVal/10;
            }
            rec = investors[rec].referer;
        }
    }
    /*
    add users in pool matrix
    */
    function appendMatrix(address updateAddr,uint poolId) internal {
        
        (address parentMatrixAddr, uint i) = getParentMatixAddr(poolId);
    
        if(matrixpools[poolId][parentMatrixAddr].leftUser==address(nullAddr)){
          matrixpools[poolId][parentMatrixAddr].leftUser = updateAddr;
        }
        else if(matrixpools[poolId][parentMatrixAddr].middleUser==address(nullAddr)){
          matrixpools[poolId][parentMatrixAddr].middleUser = updateAddr;
        }
        else {
          matrixpools[poolId][parentMatrixAddr].rightUser = updateAddr;
        }


        if(matrixpools[poolId][parentMatrixAddr].referral!=address(nullAddr)){
          matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount++;
        }
        matrixpools[poolId][parentMatrixAddr].belowCount++;

        matrixlevel[poolId][i+1].push(updateAddr);
        matrixpools[poolId][updateAddr].referral = parentMatrixAddr;

        // Reborn Process for first pool
        if(poolId==0){
          investors[parentMatrixAddr].matrixIncome += 10*decimalVal; // add pool income to parent
          if(matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount!=11 && matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount!=12){
            // add pool income to grand parent
            investors[matrixpools[poolId][parentMatrixAddr].referral].matrixIncome += 10*decimalVal;
          }
          else{
            // send 11 and 12th child bonus to system which will user for reborn
            systemIncome += 10*decimalVal;
          }
          if(matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount==12){
            // reset below count of reborn address
            matrixpools[poolId][matrixpools[poolId][parentMatrixAddr].referral].belowCount = 0;
            appendMatrix(matrixpools[poolId][parentMatrixAddr].referral, poolId);
          }
        }
        else {
          uint poolAmount = poolBase[poolId];
          uint systemAmt = poolAmount*20/100;
          uint systemAmtDecimal = systemAmt*decimalVal;
          // send 20% to system for all pool expect first
          systemIncome += systemAmtDecimal;

          uint remainingAmt = poolAmount - systemAmt;
          uint distributeAmt = remainingAmt/2;
          distributeAmt = distributeAmt*decimalVal;

          // send half income to parent
          investors[parentMatrixAddr].matrixIncome += distributeAmt;
          // send other half income to grand parent
          investors[matrixpools[poolId][parentMatrixAddr].referral].matrixIncome += distributeAmt;
        }
    
    }



    function showDistributeMatching() public view returns (uint , uint, uint )  {
        
        uint totalMatching;
        for(uint i=0; i<binaryAddresses.length;i++){
          address singleAddr = binaryAddresses[i];
          uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
          uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
          uint matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
          if(matchinVal>0) {
            totalMatching += matchinVal;
          }
        }

        uint distributeIncome = hourlyBinaryUser*60/totalMatching;
        return (distributeIncome,totalMatching,hourlyBinaryUser);
    }


    function showUserMatching(address singleAddr) public view returns (uint matchinVal )  {
        
        uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
        uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
        matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
    }

    function distributeMatchingIncome() external onlyOwner {
        
        uint totalMatching;
        for(uint i=0; i<binaryAddresses.length;i++){
          address singleAddr = binaryAddresses[i];
          uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
          uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
          uint matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
          if(matchinVal>0) {
            totalMatching += matchinVal;
          }
        }

        uint distributeIncome = hourlyBinaryUser*60/totalMatching;

        for(uint i=0; i<binaryAddresses.length;i++){
          address singleAddr = binaryAddresses[i];
          uint leftMatching = matchingdatas[singleAddr].leftUsers - matchingdatas[singleAddr].oldLeftUsers;
          uint rightMatching = matchingdatas[singleAddr].rightUsers - matchingdatas[singleAddr].oldRightUsers;
          uint matchinVal = (rightMatching>leftMatching) ? leftMatching : rightMatching;
          
          
          if(matchinVal>0) {
            investors[singleAddr].matchingIncome +=  distributeIncome*matchinVal;  
            matchingdatas[singleAddr].oldLeftUsers += matchinVal;
            matchingdatas[singleAddr].oldRightUsers += matchinVal;
          }

        }
        
        hourlyBinaryUser = 0;
       
    }


    
}