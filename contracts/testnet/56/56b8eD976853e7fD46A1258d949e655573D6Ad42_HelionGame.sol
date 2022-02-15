/**
 *Submitted for verification at BscScan.com on 2022-02-14
*/

pragma solidity 0.8.11;



contract HelionGame{

//User parameters


  mapping (address => uint256) energy;
  mapping (address => uint256) xp;
  mapping (address => uint256) reach; //How many pixels i.e km users can attack from their location
  mapping (address => uint256) sector; //grid location e.g. A=0, b=1,c=2,d=3
  mapping (address => uint256) userX; //user current position x
  mapping (address => uint256) userY; //user current position y
  mapping (address => uint256) USDBalance;
  mapping (address => uint256) bombers;
  mapping (address => uint256) fighters;
  mapping (address => uint256) destroyers;
  mapping (address => uint256) carriers; //carriers steal uranium and titanium during attack
  mapping (address => uint256) hackers; //hackers can hack user balance during attack and steal usd
  mapping (address => uint256[]) tradeAgreements; //passive usd generation
  mapping (address => uint256) uranium;
  mapping (address => uint256) titanium;
  
  mapping (uint256=>address[]) whosWhere;
  mapping (address=>uint256) whosWhereIndex; //index for each address to avoid for loop 

//Maximum location in one sector is x=99 and y=99. Minimum is x=0 and y=0;
//Current existing grids= alpha:0 beta:1 charlie:3 delta:4
//Locations

  uint256[] allowedGrids=[0,1,2,3];

  uint256[] CityX=[49,49,49,49];
  uint256[] CityY=[49,49,49,49];

  uint256[] TitaniumOreX=[23,57,88,89];
  uint256[] TitaniumOreY=[23,89,88,3];
  uint256[] TitaniumOrePerMiningOperation=[200,250,350,450];

  uint256[] UraniumOreX=[45,66,80,90];
  uint256[] UraniumOreY=[21,12,54,77];
  uint256[] UraniumOrePerMiningOperation=[150,200,250,300];

//Teams

  mapping (address => uint256) teamNumber;
  mapping (uint256 => address) teamLeader;
  mapping (uint256 => address[]) teamMembers;

//Location controlled by team number
  mapping (uint256 => uint256[]) X1;
  mapping (uint256 => uint256[]) X2;
  mapping (uint256 => uint256[]) Y1;
  mapping (uint256 => uint256[]) Y2;


//Backend User Parameters

  mapping (address => uint256) antennaLevel;


  
  /*

  0: Successful attack by you
  1: Failed atk by you
  2: Successful atk on you
  3: failed atk on you
  4: shield recharge
  5: shield upgrade
  6: antenna ugprade
  7: bombers constructed
  8: fighters constructed
  9: destroyer constructed
  10: tradeagreements bought
  11: joined team
  12: created team
  13: approved join request to your team
  14: received join request to your team
  15: mined titanium
  16: mined uranium
  17: received attack request on user
  18: approved attack request on user
  19: requested attack on user
  20: successful team attack on user by your team
  21: failed team attack on user by your team
  22: successful team attack on you by other team
  23: failed team attack on you by other team
  24: left team


  */


//Defence Systems




//Static variables
  uint256 BNBPerEnergy=10000000000000;
  
  //Ships damage
  uint256 fighterDamage=20;
  uint256 bomberDamage=100;
  uint256 destroyerDamage=200;


  //Energy costs
  uint256 AttackCost=100;


  uint256 FighterConstructionPerUnitCost=10;
  uint256 BomberConstructionPerUnitCost=50;
  uint256 DestroyerConstructionPerUnitCost=100;

  uint256 miningUraniumCost=100;
  uint256 miningTitaniumCost=100;

  uint256 travelCostPerUnit=10;  
  uint256 changeGridCost=100;

  uint256 createTeamCost=5000;

  //USD Costs
  uint256 usdFighterConstructionPerUnitCost=100;
  uint256 usdBomberConstructionPerUnitCost=250;
  uint256 usdDestroyerConstructionPerUnitCost=750;
  uint256 antennaUpgradePerUnitCost=1000;


  //Resource Costs
  uint256 uraniumFighterConstructionPerUnitCost=10;
  uint256 uraniumBomberConstructionPerUnitCost=100;
  uint256 uraniumDestroyerConstructionPerUnitCost=1000;

  uint256 titaniumFighterConstructionPerUnitCost=100;
  uint256 titaniumBomberConstructionPerUnitCost=50;
  uint256 titaniumDestroyerConstructionPerUnitCost=500;

function getUserLevel (address user) public view returns(uint256) {
  return (xp[user]/1000);
}

function getUserDamage (address user) public view returns(uint256){
  return ((fighterDamage*fighters[user])+(bomberDamage*bombers[user])+(destroyerDamage*destroyers[user]));
}



function getEnergy (address user) public view returns (uint256){
  return energy[user];
}

function getUSD (address user) public view returns (uint256){
  return USDBalance[user];
}

function getXP (address user) public view returns (uint256){
  return xp[user];
}

function getReach (address user) public view returns (uint256){
  return reach[user];
}

function getFighters (address user) public view returns(uint256){
  return fighters[user];
}

function getBombers (address user) public view returns (uint256){
  return bombers[user];
}

function getDestroyers (address user) public view returns (uint256){
  return destroyers[user];
}

function getAntennaLevel (address user) public view returns (uint256){
    return antennaLevel[user];
}

function getCarriers (address user) public view returns (uint256) {
  return carriers[user];
}

function getHackers (address user) public view returns (uint256){
  return hackers[user];
}






function buyEnergy() public payable{
  require(msg.value>=BNBPerEnergy,"Too small!");
  energy[msg.sender]+=msg.value/BNBPerEnergy;
  if(antennaLevel[msg.sender]==0){
      whosWhere[0].push(msg.sender);
      whosWhereIndex[msg.sender]=whosWhere[0].length-1;
    //User is new lets setup.
    USDBalance[msg.sender]=1000;
    antennaLevel[msg.sender]=1;
  }
}

function sellEnergy(uint256 amount) public{
  require(amount>energy[msg.sender],"Not enough energy");
  
  address payable requestor=payable(msg.sender);
  requestor.transfer(amount);
}



function removeFromSector(uint256 index,uint256 sSector) internal {
  require(index < whosWhere[sSector].length);
  whosWhere[sSector][index] = whosWhere[sSector][whosWhere[sSector].length-1];
  whosWhere[sSector].pop();
}

function changeGrid(uint256 newGrid) public{ //Changing sector
  require(newGrid==0||newGrid==1||newGrid==2||newGrid==3,"Invalid grid");
  require(energy[msg.sender]>=changeGridCost,"Not enough energy");
  energy[msg.sender]-=changeGridCost;


  removeFromSector(whosWhereIndex[msg.sender],sector[msg.sender]);
  sector[msg.sender]=newGrid;
  whosWhere[newGrid].push(msg.sender);

}

function travel(uint256 x,uint256 y) public{
  uint256 distanceX;
  uint256 distanceY;

  if(userX[msg.sender]>x){
    distanceX=userX[msg.sender]-x;

    } else {
    distanceX=x-userX[msg.sender];
    }

  if(userY[msg.sender]>y){
   distanceY=userY[msg.sender]-y;

    } else {
    distanceY=y-userY[msg.sender];
    }
  require (energy[msg.sender]>((travelCostPerUnit*distanceX)+(travelCostPerUnit*distanceY)),"Not enough energy");
  energy[msg.sender]-= ((travelCostPerUnit*distanceX)+(travelCostPerUnit*distanceY));
  if(userX[msg.sender]>x){
    userX[msg.sender]-=x;

    } else {
    userX[msg.sender]+=x;
    }

  if(userY[msg.sender]>y){
    userY[msg.sender]-=y;

    } else {
    userY[msg.sender]+=y;
    }


}


function battle(address victim,uint256 pfighters,uint256 pbombers,uint256 pdestroyers,uint256 pcarriers,uint256 phackers) public {
  require(fighters[msg.sender]>=pfighters,"Not enough fighters");
  require(bombers[msg.sender]>=pbombers,"Not enough bombers");
  require(destroyers[msg.sender]>=pdestroyers,"Not enough destroyers");
  require (carriers[msg.sender]>=pcarriers,"Not enough carriers");
  require (hackers[msg.sender]>=phackers,"Not enough hackers");
  carriers[msg.sender]-=pcarriers;
  hackers[msg.sender]-=phackers;
  fighters[msg.sender]-=pfighters;
  bombers[msg.sender]-=pbombers;
  destroyers[msg.sender]-=pdestroyers;
  require(energy[msg.sender]>=AttackCost,"Not enough energy");
  energy[msg.sender]-=AttackCost;

  uint256 distanceX;
  uint256 distanceY;

  if(userX[msg.sender]>userX[victim]){
    distanceX=userX[msg.sender]-userX[victim];

    } else {
    distanceX=userX[victim]-userX[msg.sender];
    }

  if(userY[msg.sender]>userY[victim]){
   distanceY=userY[msg.sender]-userY[victim];

    } else {
    distanceY=userY[victim]-userY[msg.sender];
    }

  require(distanceX>=antennaLevel[msg.sender],"Not enough reach");
  require(distanceY>=antennaLevel[msg.sender],"Not enough reach");
  require(sector[msg.sender]==sector[victim],"Users not within sector");


  // battle between victim fighters and attackers units
  uint256 atkFightersPostBattle;
  uint256 atkBombersPostBattle;
  uint256 atkDestroyersPostBattle;
  if(pfighters>fighters[victim]){
    atkFightersPostBattle=pfighters-fighters[victim];
    fighters[victim]=0;
  } else {
    atkFightersPostBattle=0;
    fighters[victim]-=pfighters;
  }

 //2 fighters kan kill 1 bomber;
  if(pbombers>(fighters[victim]/2)){
    atkBombersPostBattle=pbombers-(fighters[victim]/2);
    fighters[victim]=0;
  } else {
    atkBombersPostBattle=0;
  }

//10 fighters kan kill 1 destroyer;
  if(pdestroyers>(fighters[victim]/10)){
    atkDestroyersPostBattle=pdestroyers-(fighters[victim]/10);
    fighters[victim]=0;
  } else {
    atkDestroyersPostBattle=0;
  }
  
  //end battle




  if ((fighterDamage*atkFightersPostBattle)+(bomberDamage*atkBombersPostBattle)+(destroyerDamage*atkDestroyersPostBattle)>0){

    uint256 energyGain;

    if((fighterDamage*atkFightersPostBattle)+(bomberDamage*atkBombersPostBattle)+(destroyerDamage*atkDestroyersPostBattle)>energy[victim]){
      energyGain=energy[victim];
    } else {
      energyGain=(fighterDamage*atkFightersPostBattle)+(bomberDamage*atkBombersPostBattle)+(destroyerDamage*atkDestroyersPostBattle);
    }

    energy[victim]-=energyGain;
    energy[msg.sender]+=energyGain;

    uranium[victim]-=pcarriers*5;
    titanium[victim]-=pcarriers*15;
    uranium[msg.sender]+=pcarriers*5;
    titanium[msg.sender]+=pcarriers*15;

    USDBalance[victim]-=phackers*10;
    USDBalance[msg.sender]+=phackers*10;

    carriers[msg.sender]+=pcarriers;
    hackers[msg.sender]+=phackers;
    fighters[msg.sender]+=atkFightersPostBattle;
    bombers[msg.sender]+=atkBombersPostBattle;
    destroyers[msg.sender]+=atkDestroyersPostBattle;    
    xp[msg.sender]+=50;

  }


}



}