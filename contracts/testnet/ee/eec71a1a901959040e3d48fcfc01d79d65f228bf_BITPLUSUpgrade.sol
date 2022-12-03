/**
 *Submitted for verification at BscScan.com on 2022-12-03
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

interface BITPLUS {
  function investorCusData(address addr) external view returns(uint userType,
                                                          address parentAssociate,
                                                          address referer,
                                                          address leftUser,
                                                          uint diamondRank);

  function investorRef(address addr) external view returns(address referer);  

  function investorDiamondRank(address addr) external view returns(uint diamondRank); 

  function investorCusDataUpgrade(address addr) external view returns(address referer,
                                                          uint diamondRank,
                                                          uint mdLeftUsers,
                                                          uint mdRightUsers,
                                                          uint diamondCount,
                                                          uint doubleDiamondCount,
                                                          uint tripleDiamondCount,
                                                          uint blackDiamondCount);    

                                                                                                              

  function updateUserReport(address addr,
                            uint tokenAmt, 
                            uint bnbAmount,
                            uint ptype, 
                            uint income_type, 
                            uint report_type) external returns (bool success);     

  function updateInvestorData(address addr,uint amount, uint updateType) external returns (bool success);                                                                              
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

contract BITPLUSUpgrade is Ownable { 
   
  struct diamondUserLeft{
    uint diamond;
    uint director;
    uint seniorDirector;
    uint regionalDirector;
    uint nationalDirector;
    uint internationalDirector;
    uint worldDirector;
    uint globalDirector;
    uint crownDirector;
    uint royalDirector;
    uint presidentDirector;
  }
  struct diamondUserRight{
    uint diamond;
    uint director;
    uint seniorDirector;
    uint regionalDirector;
    uint nationalDirector;
    uint internationalDirector;
    uint worldDirector;
    uint globalDirector;
    uint crownDirector;
    uint royalDirector;
    uint presidentDirector;
  }

  struct investorRole{
    bool diamond;
    bool director;
    bool seniorDirector;
    bool regionalDirector;
    bool nationalDirector;
    bool internationalDirector;
    bool worldDirector;
    bool globalDirector;
    bool crownDirector;
    bool royalDirector;
    bool presidentDirector;
  }

  struct investorRoleTillTime{
    uint diamondTill;
    uint directorTill;
    uint seniorDirectorTill;
    uint regionalDirectorTill;
    uint nationalDirectorTill;
    uint internationalDirectorTill;
    uint worldDirectorTill;
    uint globalDirectorTill;
    uint crownDirectorTill;
    uint royalDirectorTill;
    uint presidentDirectorTill;
  }



  struct investorRoleAt{
    uint diamondAt;
    uint directorAt;
    uint seniorDirectorAt;
    uint regionalDirectorAt;
    uint nationalDirectorAt;
    uint internationalDirectorAt;
    uint worldDirectorAt;
    uint globalDirectorAt;
    uint crownDirectorAt;
    uint royalDirectorAt;
    uint presidentDirectorAt;
  }

  uint systemIncome;
  uint public decimalVal = (10**18);
  uint public oneDay = 86400; 
  address nullAddr = 0x0000000000000000000000000000000000000000;
  address bitplusContractAddr;
  address public busdToken = 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee; //testnet
  uint public tokenPrice = 20;
  uint public tokenDecimal = 100;
  
 

  mapping (address => diamondUserLeft) public diamondUserLefts;
  mapping (address => diamondUserRight) public diamondUserRights;
  mapping (address => investorRoleTillTime) public investorRoleTillTimes;
  mapping (address => investorRoleAt) public investorRoleAts;
  mapping (address => investorRole) public investorRoles;

  address[] public diamondList;
  address[] public directorList;
  address[] public seniorDirectorList;
  address[] public regionalDirectorList;
  address[] public nationalDirectorList;
  address[] public internationalDirectorList;
  address[] public worldDirectorList;
  address[] public globalDirectorList;
  address[] public crownDirectorList;
  address[] public royalDirectorList;
  address[] public presidentDirectorList;



  uint public directorCollectAmt;
  uint public seniorDirectorCollectAmt;
  uint public regionalDirectorAmt;
  uint public nationalDirectorAmt;
  uint public internationalDirectorAmt;
  uint public worldDirectorAmt;
  uint public globalDirectorAmt;
  uint public crownDirectorAmt;
  uint public royalDirectorAmt;
  uint public presidentDirectorAmt;

  uint public parentDirectorLimitFirst = 1;
  uint public parentDirectorLimitSecond = 2;
  uint public parentDirectorLimitThird = 3;
  uint public parentDirectorLimitFourth = 4;



  constructor(address _bitplusContractAddr) {
    bitplusContractAddr = _bitplusContractAddr;
  }

  function calculateToken(uint getAmt) public view returns(uint tokenAmt){
    tokenAmt = (getAmt*tokenPrice)/tokenDecimal;
  }

  function multiplyDecimal(uint _getAmt) public view returns(uint newAmt){
    newAmt = _getAmt*decimalVal;
  }

  function updateBitplusContractAddr(address _bitplusContractAddr) external{
    bitplusContractAddr = _bitplusContractAddr;
  }

    /*
      become A Diamond
    */

    function becomeDiamond(uint bnbAmount) external {
        BITPLUS bitPlusObj = BITPLUS(bitplusContractAddr);
        (uint userTypeMsgSender,
        address parentAssociateMsgSender,
        address refererMsgSender,
        address leftUserMsgSender,
        uint diamondRankMsgSender
        ) = bitPlusObj.investorCusData(msg.sender);

        
        require(bnbAmount==1000,"Insufficient BNB amount");
        require(userTypeMsgSender==3,"User Should be Associate");
        //require(BEP20(busdToken).allowance(msg.sender,contractAddr)>=bnbAmount,"insufficient allowance");
        //require(BEP20(busdToken).balanceOf(msg.sender)>=bnbAmount,"insufficient balance");
        bnbAmount = multiplyDecimal(bnbAmount);

        // transfer to contract
        //BEP20(busdToken).transferFrom(msg.sender,bitplusContractAddr,bnbAmount);


        uint tokenAmt = calculateToken(bnbAmount);
        bitPlusObj.updateInvestorData(msg.sender,tokenAmt,0);
        //investors[msg.sender].token += tokenAmt;
        bitPlusObj.updateInvestorData(msg.sender,tokenAmt,1);
        //investors[msg.sender].userType=4;
        investorRoles[msg.sender].diamond=true;

        bitPlusObj.updateUserReport(msg.sender,tokenAmt,bnbAmount,4,0,0);
        //allReportList[msg.sender].push(allReport(tokenAmt,bnbAmount,block.timestamp,4,0,0,0));

        directorCollectAmt += multiplyDecimal(100) ;
        seniorDirectorCollectAmt += multiplyDecimal(90);
        regionalDirectorAmt += multiplyDecimal(80);
        nationalDirectorAmt += multiplyDecimal(70);
        internationalDirectorAmt += multiplyDecimal(60);
        worldDirectorAmt += multiplyDecimal(50);
        globalDirectorAmt += multiplyDecimal(40);
        crownDirectorAmt += multiplyDecimal(30);
        royalDirectorAmt += multiplyDecimal(20);
        presidentDirectorAmt += multiplyDecimal(10);

        diamondList.push(msg.sender);
        updateDiamondUsers(parentAssociateMsgSender,msg.sender);

        updateDiamondRank(msg.sender,1);

        address directReferral = refererMsgSender;
       
        uint diamondRankDirRef = bitPlusObj.investorDiamondRank(directReferral);
        
        uint generalInc;
        if(diamondRankDirRef==5){
           generalInc = multiplyDecimal(350);
        }
        else if(diamondRankDirRef==4){
           generalInc = multiplyDecimal(300);   
          
        }
        else if(diamondRankDirRef==3){
           generalInc = multiplyDecimal(250);   
        }
        else if(diamondRankDirRef==2){
           generalInc = multiplyDecimal(200);   
        }
        else if(diamondRankDirRef==1){
           generalInc = multiplyDecimal(150);   
        }
        if(generalInc>0){
          bitPlusObj.updateInvestorData(directReferral,generalInc,3);
          //investorsData[directReferral].generalIncome += generalInc;
          bitPlusObj.updateUserReport(directReferral,generalInc,bnbAmount,0,4,1);
          //allReportList[directReferral].push(allReport(generalInc,0,block.timestamp,0,0,4,1));
        }

        
    }


    /*
      distributeRankAndRecognitionIncome
    */
  
    function distributeRankAndRecognitionIncome() external onlyOwner{
      BITPLUS bitPlusObj = BITPLUS(bitplusContractAddr);
      // director Income
      if(directorList.length>0) {
        uint validDirector;
        
        for(uint i=0; i<directorList.length;i++){
          if(investorRoleTillTimes[directorList[i]].directorTill>=block.timestamp){
              validDirector++;
          }
        }
        if(validDirector>0){
          uint collectAmt = directorCollectAmt/validDirector;
          for(uint i=0; i<directorList.length;i++){
            address index = directorList[i];
            if(investorRoleTillTimes[index].directorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }

      }
      directorCollectAmt = 0;


      // senior director Income
      if(seniorDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<seniorDirectorList.length;i++){
          if(investorRoleTillTimes[seniorDirectorList[i]].seniorDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = seniorDirectorCollectAmt/valid;
          for(uint i=0; i<seniorDirectorList.length;i++){
            address index = seniorDirectorList[i];
            if(investorRoleTillTimes[index].seniorDirectorTill>=block.timestamp){
                 bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      seniorDirectorCollectAmt = 0;

      // REGIONAL DIRECTOR Income
      if(regionalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<regionalDirectorList.length;i++){
          if(investorRoleTillTimes[regionalDirectorList[i]].regionalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = regionalDirectorAmt/valid;
          for(uint i=0; i<regionalDirectorList.length;i++){
            address index = regionalDirectorList[i];
            if(investorRoleTillTimes[index].regionalDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      regionalDirectorAmt = 0;

      // NATIONAL DIRECTOR Income
      if(nationalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<nationalDirectorList.length;i++){
          if(investorRoleTillTimes[nationalDirectorList[i]].nationalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = nationalDirectorAmt/valid;
          for(uint i=0; i<nationalDirectorList.length;i++){
            address index = nationalDirectorList[i];
            if(investorRoleTillTimes[index].nationalDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }

      }
      nationalDirectorAmt = 0;


      // INTERNATIONAL DIRECTOR Income
      if(internationalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<internationalDirectorList.length;i++){
          if(investorRoleTillTimes[internationalDirectorList[i]].internationalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = nationalDirectorAmt/valid;
          for(uint i=0; i<internationalDirectorList.length;i++){
            address index = internationalDirectorList[i];
            if(investorRoleTillTimes[index].internationalDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      nationalDirectorAmt = 0;


      // WORLD DIRECTOR Income
      if(worldDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<worldDirectorList.length;i++){
          if(investorRoleTillTimes[worldDirectorList[i]].worldDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = worldDirectorAmt/valid;
          for(uint i=0; i<worldDirectorList.length;i++){
            address index = worldDirectorList[i];
            if(investorRoleTillTimes[index].worldDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      worldDirectorAmt = 0;

     


      // GLOBAL DIRECTOR Income
      if(globalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<globalDirectorList.length;i++){
          if(investorRoleTillTimes[globalDirectorList[i]].globalDirectorTill>=block.timestamp){
              valid++;
          }
        }

        if(valid>0) {
          uint collectAmt = globalDirectorAmt/valid;
          for(uint i=0; i<globalDirectorList.length;i++){
             address index = globalDirectorList[i];
            if(investorRoleTillTimes[index].globalDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      globalDirectorAmt = 0;

      // CROWN DIRECTOR Income
      if(crownDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<crownDirectorList.length;i++){
          if(investorRoleTillTimes[crownDirectorList[i]].crownDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = crownDirectorAmt/valid;
          for(uint i=0; i<crownDirectorList.length;i++){
             address index = crownDirectorList[i];
            if(investorRoleTillTimes[index].crownDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      crownDirectorAmt = 0;



      // ROYAL DIRECTOR Income
      if(royalDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<royalDirectorList.length;i++){
          if(investorRoleTillTimes[royalDirectorList[i]].royalDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = royalDirectorAmt/valid;
          for(uint i=0; i<royalDirectorList.length;i++){
            address index = royalDirectorList[i];
            if(investorRoleTillTimes[index].royalDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      royalDirectorAmt = 0;


      // PRESIDENT DIRECTOR Income
      if(presidentDirectorList.length>0) {
        uint valid;
        
        for(uint i=0; i<presidentDirectorList.length;i++){
          if(investorRoleTillTimes[presidentDirectorList[i]].presidentDirectorTill>=block.timestamp){
              valid++;
          }
        }
        if(valid>0) {
          uint collectAmt = presidentDirectorAmt/valid;
          for(uint i=0; i<presidentDirectorList.length;i++){
             address index = presidentDirectorList[i];
            if(investorRoleTillTimes[index].presidentDirectorTill>=block.timestamp){
                bitPlusObj.updateInvestorData(index,collectAmt,2);
                //investors[index].diamondIncome += collectAmt;
                bitPlusObj.updateUserReport(index,collectAmt,0,0,3,1);
                //allReportList[index].push(allReport(collectAmt,0,block.timestamp,0,0,3,1));
            }
          }
        }
      }
      presidentDirectorAmt = 0;
    }

  




    function updateDiamondRank(address userAddr,uint updateCountType) internal { 
      BITPLUS bitPlusObj = BITPLUS(bitplusContractAddr);
      address refererUserAddr = bitPlusObj.investorRef(userAddr);

       address parent = refererUserAddr;


       
       if(parent != address(nullAddr)){

        (address refererParent,
        uint diamondRankParent,
        uint mdLeftUsersParent,
        uint mdRightUsereParent,
        uint diamondCountParent,
        uint doubleDiamondCountParent,
        uint tripleDiamondCountParent,
        uint blackDiamondCountParent) = bitPlusObj.investorCusDataUpgrade(parent);


         uint tenGenInc = multiplyDecimal(10);
         if(updateCountType==1){
            bitPlusObj.updateInvestorData(parent,1,4);
            //investorsData[parent].diamondCount++;
         }
         else if(updateCountType==2){
            //investorsData[parent].doubleDiamondCount++;
            bitPlusObj.updateInvestorData(parent,1,5);
            if(diamondRankParent==2){
              bitPlusObj.updateInvestorData(parent,tenGenInc,3);
              //investorsData[parent].generalIncome += tenGenInc;
              bitPlusObj.updateUserReport(parent,tenGenInc,0,0,4,1);
              //allReportList[parent].push(allReport(tenGenInc,0,block.timestamp,0,0,4,1));
            }
         }
         else if(updateCountType==3){
            //investorsData[parent].tripleDiamondCount++;
            bitPlusObj.updateInvestorData(parent,1,6);
            if(diamondRankParent==3){
              bitPlusObj.updateInvestorData(parent,tenGenInc,3);
              //investorsData[parent].generalIncome += tenGenInc;
              bitPlusObj.updateUserReport(parent,tenGenInc,0,0,4,1);
              //allReportList[parent].push(allReport(tenGenInc,0,block.timestamp,0,0,4,1));
            }
         }
         else if(updateCountType==4){
            //investorsData[parent].blackDiamondCount++;
            bitPlusObj.updateInvestorData(parent,1,7);
            if(diamondRankParent==4){
              bitPlusObj.updateInvestorData(parent,tenGenInc,3);
              //investorsData[parent].generalIncome += tenGenInc;
              bitPlusObj.updateUserReport(parent,tenGenInc,0,0,4,1);
              //allReportList[parent].push(allReport(tenGenInc,0,block.timestamp,0,0,4,1));
            }
         }
        
        // convert to Double diamond User
        if(diamondRankParent==1 
            && diamondCountParent>=1 
            && (mdLeftUsersParent+mdRightUsereParent)>2){
            bitPlusObj.updateInvestorData(parent,2,8);
            //investorsData[parent].diamondRank = 2; 
            updateDiamondRank(parent,2);
        }
        // convert to triple diamond User
        else if(diamondRankParent==2 
            && doubleDiamondCountParent>=2 
            && (mdLeftUsersParent+mdRightUsereParent)>4){
            bitPlusObj.updateInvestorData(parent,3,8);
            //investorsData[parent].diamondRank = 3;
            updateDiamondRank(parent,3);  
        }
        // convert to black diamond User
        else if(diamondRankParent==3 
            && tripleDiamondCountParent>=3 
            && (mdLeftUsersParent+mdRightUsereParent)>6){
            bitPlusObj.updateInvestorData(parent,4,8);
            //investorsData[parent].diamondRank = 4;
            updateDiamondRank(parent,4);   
        }
          // convert to blue diamond User
        else if(diamondRankParent==4 
            && blackDiamondCountParent>=4 
            && (mdLeftUsersParent+mdRightUsereParent)>7){
            bitPlusObj.updateInvestorData(parent,5,8);
            //investorsData[parent].diamondRank = 5;
            address getParent = refererParent;
              if(diamondRankParent==2){
                bitPlusObj.updateInvestorData(getParent,tenGenInc,3);
                //investorsData[getParent].generalIncome += tenGenInc;
                bitPlusObj.updateUserReport(getParent,tenGenInc,0,0,4,1);
                //allReportList[getParent].push(allReport(tenGenInc,0,block.timestamp,0,0,4,1));
              }
        }

       }

    }

    function userNextRole(address userAddr) internal returns (uint nextRole) {
        if(diamondUserLefts[userAddr].diamond>=12 
          && diamondUserRights[userAddr].diamond>=12 
          && !investorRoles[userAddr].presidentDirector){
          nextRole = 10;
          investorRoles[userAddr].presidentDirector=true;
          investorRoleTillTimes[userAddr].presidentDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].presidentDirectorAt = block.timestamp;
          
          presidentDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=11 
                && diamondUserRights[userAddr].diamond>=11 
                && !investorRoles[userAddr].royalDirector){
          nextRole = 9;
          investorRoles[userAddr].royalDirector=true;
          investorRoleTillTimes[userAddr].royalDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].royalDirectorAt = block.timestamp;
          royalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=10 
                && diamondUserRights[userAddr].diamond>=10 
                && !investorRoles[userAddr].crownDirector){
          nextRole = 8;
          investorRoles[userAddr].crownDirector=true;
          investorRoleTillTimes[userAddr].crownDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].crownDirectorAt = block.timestamp;
          crownDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=9 
                && diamondUserRights[userAddr].diamond>=9 
                && !investorRoles[userAddr].globalDirector){
          nextRole = 7;
          investorRoles[userAddr].globalDirector=true;
          investorRoleTillTimes[userAddr].globalDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].globalDirectorAt = block.timestamp;
          globalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=8 
                && diamondUserRights[userAddr].diamond>=8 
                && !investorRoles[userAddr].worldDirector){
          nextRole = 6;
          investorRoles[userAddr].worldDirector=true;
          investorRoleTillTimes[userAddr].worldDirectorTill = block.timestamp+(4380*oneDay);
          investorRoleAts[userAddr].worldDirectorAt = block.timestamp;
          worldDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=7 
                && diamondUserRights[userAddr].diamond>=7 
                && !investorRoles[userAddr].internationalDirector){
          nextRole = 5;
          investorRoles[userAddr].internationalDirector=true;
          investorRoleTillTimes[userAddr].internationalDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].internationalDirectorAt = block.timestamp;
          internationalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=6 
                && diamondUserRights[userAddr].diamond>=6 
                && !investorRoles[userAddr].nationalDirector){
          nextRole = 4;
          investorRoles[userAddr].nationalDirector=true;
          investorRoleTillTimes[userAddr].nationalDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].nationalDirectorAt = block.timestamp;
          nationalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=5 
                && diamondUserRights[userAddr].diamond>=5 
                && !investorRoles[userAddr].regionalDirector){
          nextRole = 3;
          investorRoles[userAddr].regionalDirector=true;
          investorRoleTillTimes[userAddr].regionalDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].regionalDirectorAt = block.timestamp;
          regionalDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=3 
                && diamondUserRights[userAddr].diamond>=3 
                && !investorRoles[userAddr].seniorDirector){
          nextRole = 2;
          investorRoles[userAddr].seniorDirector=true;
          investorRoleTillTimes[userAddr].seniorDirectorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].seniorDirectorAt = block.timestamp;
          seniorDirectorList.push(userAddr);
        }
        else if(diamondUserLefts[userAddr].diamond>=1 
                && diamondUserRights[userAddr].diamond>=1 
                && !investorRoles[userAddr].director){
          nextRole = 1;
          investorRoles[userAddr].director=true;
          investorRoleTillTimes[userAddr].directorTill = block.timestamp+(60*oneDay);
          investorRoleAts[userAddr].directorAt = block.timestamp;
          directorList.push(userAddr);
        }
    }


    function updateDiamondUsers(address refAddr,address userAddr) internal {
      BITPLUS bitPlusObj = BITPLUS(bitplusContractAddr);
      if(refAddr!=address(nullAddr)) {

        (uint userTypeRefAddr,
        address parentAssociateRefAddr,
        address refererRefAddr,
        address leftUserRefAddr,
        uint diamondRankRefAddr
        ) = bitPlusObj.investorCusData(refAddr);

        if(userTypeRefAddr==4){
          if(leftUserRefAddr == userAddr){
            diamondUserLefts[refAddr].diamond++;
          }
          else {
            diamondUserRights[refAddr].diamond++;
          }
          
          
          uint nextRole = userNextRole(refAddr);
          if(nextRole>0 && nextRole<5){
            updateRoleCount(refAddr,nextRole);
          }
        }
      
        updateDiamondUsers(parentAssociateRefAddr,refAddr);
      }
    }  




    function updateRoleCount(address user,uint newRole) internal {
      BITPLUS bitPlusObj = BITPLUS(bitplusContractAddr);   
       (uint userTypeUser,
        address parentAssociateUser,
        address refererUser,
        address leftUserUser,
        uint diamondRankUser
        ) = bitPlusObj.investorCusData(user); 

        address parentAssociate = parentAssociateUser;


        (uint userTypeParAso,
        address parentAssociateParAso,
        address refererParAso,
        address leftUserParAso,
        uint diamondRankParAso
        ) = bitPlusObj.investorCusData(parentAssociate); 

      // update director Count
      if(newRole==1){

        if(leftUserParAso == user){
          diamondUserLefts[parentAssociate].director++;
        }
        else {
          diamondUserRights[parentAssociate].director++;
        }
        
        // update time for senior directors
        if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].director >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill =  investorRoleAts[parentAssociate].seniorDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitThird && diamondUserRights[parentAssociate].director >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill = investorRoleAts[parentAssociate].seniorDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].director >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill = investorRoleAts[parentAssociate].seniorDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].director>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].director >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].seniorDirectorTill = investorRoleAts[parentAssociate].seniorDirectorAt+(120*oneDay);
        }
      }
      else if(newRole==2){
         
        if(leftUserParAso == user){
          diamondUserLefts[parentAssociate].seniorDirector++;
        }
        else {
          diamondUserRights[parentAssociate].seniorDirector++;
        }
        
        // update time for regional directors
        if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill =  investorRoleAts[parentAssociate].regionalDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitThird && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill = investorRoleAts[parentAssociate].regionalDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill = investorRoleAts[parentAssociate].regionalDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].seniorDirector>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].seniorDirector >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].regionalDirectorTill = investorRoleAts[parentAssociate].regionalDirectorAt+(120*oneDay);
        }

      }
      else if(newRole==3){
        if(leftUserParAso == user){
          diamondUserLefts[parentAssociate].regionalDirector++;
        }
        else {
          diamondUserRights[parentAssociate].regionalDirector++;
        }

        // update time for national directors
        if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill =  investorRoleAts[parentAssociate].nationalDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitThird && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill = investorRoleAts[parentAssociate].nationalDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill = investorRoleAts[parentAssociate].nationalDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].regionalDirector>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].regionalDirector >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].nationalDirectorTill = investorRoleAts[parentAssociate].nationalDirectorAt+(120*oneDay);
        }
        
      }
      else if(newRole==4){
        
        if(leftUserParAso == user){
          diamondUserLefts[parentAssociate].nationalDirector++;
        }
        else {
          diamondUserRights[parentAssociate].nationalDirector++;
        }

        // update time for international directors
        if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitFourth && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitFourth){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill =  investorRoleAts[parentAssociate].internationalDirectorAt+(4380*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitThird && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitThird){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill = investorRoleAts[parentAssociate].internationalDirectorAt+(500*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitSecond && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitSecond){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill = investorRoleAts[parentAssociate].internationalDirectorAt+(240*oneDay);
        }
        else if(diamondUserLefts[parentAssociate].nationalDirector>=parentDirectorLimitFirst && diamondUserRights[parentAssociate].nationalDirector >=parentDirectorLimitFirst){
             investorRoleTillTimes[parentAssociate].internationalDirectorTill = investorRoleAts[parentAssociate].internationalDirectorAt+(120*oneDay);
        }
      }
    }


  


    function validAllTypeDirectors() public view returns (uint director,
                                                          uint seniorDirector,
                                                          uint regionalDirector,
                                                          uint nationalDirector,
                                                          uint internationalDirector,
                                                          uint worldDirector,
                                                          uint globalDirector,
                                                          uint crownDirector,
                                                          uint royalDirector,
                                                          uint presidentDirector) {
      
      if(directorList.length>0) {
        for(uint i=0; i<directorList.length;i++){
          if(investorRoleTillTimes[directorList[i]].directorTill>=block.timestamp){
              director++;
          }
        }
      }

      if(seniorDirectorList.length>0) {
        for(uint i=0; i<seniorDirectorList.length;i++){
          if(investorRoleTillTimes[seniorDirectorList[i]].seniorDirectorTill>=block.timestamp){
              seniorDirector++;
          }
        }
      }
      
      if(regionalDirectorList.length>0) {
        for(uint i=0; i<regionalDirectorList.length;i++){
          if(investorRoleTillTimes[regionalDirectorList[i]].regionalDirectorTill>=block.timestamp){
              regionalDirector++;
          }
        }
      }
      
      if(nationalDirectorList.length>0) {
        for(uint i=0; i<nationalDirectorList.length;i++){
          if(investorRoleTillTimes[nationalDirectorList[i]].nationalDirectorTill>=block.timestamp){
              nationalDirector++;
          }
        }
      }
      
      if(internationalDirectorList.length>0) {
        for(uint i=0; i<internationalDirectorList.length;i++){
          if(investorRoleTillTimes[internationalDirectorList[i]].internationalDirectorTill>=block.timestamp){
              internationalDirector++;
          }
        }
      }

      if(worldDirectorList.length>0) {
        for(uint i=0; i<worldDirectorList.length;i++){
          if(investorRoleTillTimes[worldDirectorList[i]].worldDirectorTill>=block.timestamp){
              worldDirector++;
          }
        }
      }
      
      if(globalDirectorList.length>0) {
        for(uint i=0; i<globalDirectorList.length;i++){
          if(investorRoleTillTimes[globalDirectorList[i]].globalDirectorTill>=block.timestamp){
              globalDirector++;
          }
        }
      }
      
      if(crownDirectorList.length>0) {
        for(uint i=0; i<crownDirectorList.length;i++){
          if(investorRoleTillTimes[crownDirectorList[i]].crownDirectorTill>=block.timestamp){
              crownDirector++;
          }
        }
      }
      
      if(royalDirectorList.length>0) {
        for(uint i=0; i<royalDirectorList.length;i++){
          if(investorRoleTillTimes[royalDirectorList[i]].royalDirectorTill>=block.timestamp){
              royalDirector++;
          }
        }
      }
     
      if(presidentDirectorList.length>0) {
        for(uint i=0; i<presidentDirectorList.length;i++){
          if(investorRoleTillTimes[presidentDirectorList[i]].presidentDirectorTill>=block.timestamp){
              presidentDirector++;
          }
        }
      }
     
    }


}