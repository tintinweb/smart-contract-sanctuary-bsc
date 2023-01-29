/**
 *Submitted for verification at BscScan.com on 2023-01-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EnergyGalaxy {
    address public immutable ADMIN_WALLET;
    uint public totalGalaxy = 0;
    uint public freePlanetsCount = 200;
    uint[7] private nominalPrices = [500, 1250, 2250, 5000, 12500, 25000, 62500]; 

    struct Planets {
        uint lastVisit;
        uint gemBalance;
        uint essentialsBalance;
        uint startTime;
        uint[7] essentionsByPlanet;
        uint[3][7] planetsOwn;
        bool init;
        uint [7] planetsPriceUpLevel;
        uint refGems;
        uint refEss;
        uint refs;
        uint myInvestment;
        uint myWithdrawals;
        address parentRef;
        bool endAction;
    }

    // mapping from users addresses to Planets struct
    mapping(address => Planets) possessions;
    
    constructor(address _adminWallet  ){
        ADMIN_WALLET = _adminWallet;
    }

// buy GEMS 
    function buyGemstones(address ref) external payable{
        uint gemsAmount = msg.value / 1e14;

       possessions[msg.sender].gemBalance += gemsAmount;
        // referral conditions
        if(possessions[msg.sender].parentRef != address(0)){
            address level_1 = possessions[msg.sender].parentRef;
            possessions[level_1].gemBalance += (gemsAmount * 3) /100;
            possessions[level_1].refGems += (gemsAmount * 3) /100;
            possessions[level_1].essentialsBalance += (gemsAmount * 4) /100 * 100;
            possessions[level_1].refEss += (gemsAmount * 4) /100 * 100;
           

            if(possessions[level_1].parentRef != address(0)){
                address level_2 = possessions[level_1].parentRef;
                possessions[level_2].gemBalance += (gemsAmount * 2) /100;
                possessions[level_2].refGems += (gemsAmount * 2) /100;
                possessions[level_2].essentialsBalance += (gemsAmount * 3) /100 * 100;
                possessions[level_2].refEss += (gemsAmount * 3) /100 * 100;
             

                if(possessions[level_2].parentRef != address(0)){
                    address level_3 = possessions[level_2].parentRef;
                    possessions[level_3].gemBalance += (gemsAmount * 1) /100;
                    possessions[level_3].refGems += (gemsAmount * 1) /100;
                    possessions[level_3].essentialsBalance += (gemsAmount * 3) /100 * 100;
                    possessions[level_3].refEss += (gemsAmount * 3) /100 * 100;
                   

                    if(possessions[level_3].parentRef != address(0)){
                        address level_4 = possessions[level_3].parentRef;
                        possessions[level_4].gemBalance += (gemsAmount * 1) /100;
                        possessions[level_4].refGems += (gemsAmount * 1) /100;
                        possessions[level_4].essentialsBalance += (gemsAmount * 2) /100 * 100;
                        possessions[level_4].refEss += (gemsAmount * 2) /100 * 100;
                       

                        if(possessions[level_4].parentRef != address(0)){
                            address level_5 = possessions[level_4].parentRef;
                            possessions[level_5].gemBalance += (gemsAmount * 1) /100;
                            possessions[level_5].refGems += (gemsAmount * 1) /100;
                            possessions[level_5].essentialsBalance += (gemsAmount * 1) /100 * 100;
                            possessions[level_5].refEss += (gemsAmount * 1) /100 * 100;
                           
                        }
                    }

                }
            }
        }else{
            possessions[msg.sender].parentRef = ref;
            // referral conditions
            address level_1 = possessions[msg.sender].parentRef;
            possessions[level_1].gemBalance += (gemsAmount * 3) /100;
            possessions[level_1].refGems += (gemsAmount * 3) /100;
            possessions[level_1].essentialsBalance += (gemsAmount * 4) /100 * 100;
            possessions[level_1].refEss += (gemsAmount * 4) /100 * 100;
            possessions[level_1].refs++;

            if(possessions[level_1].parentRef != address(0)){
                address level_2 = possessions[level_1].parentRef;
                possessions[level_2].gemBalance += (gemsAmount * 2) /100;
                possessions[level_2].refGems += (gemsAmount * 2) /100;
                possessions[level_2].essentialsBalance += (gemsAmount * 3) /100 * 100;
                possessions[level_2].refEss += (gemsAmount * 3) /100 * 100;
                 possessions[level_2].refs++;

                if(possessions[level_2].parentRef != address(0)){
                    address level_3 = possessions[level_2].parentRef;
                    possessions[level_3].gemBalance += (gemsAmount * 1) /100;
                    possessions[level_3].refGems += (gemsAmount * 1) /100;
                    possessions[level_3].essentialsBalance += (gemsAmount * 3) /100 * 100;
                    possessions[level_3].refEss += (gemsAmount * 3) /100 * 100;
                     possessions[level_3].refs++;

                     if(possessions[level_3].parentRef != address(0)){
                        address level_4 = possessions[level_3].parentRef;
                        possessions[level_4].gemBalance += (gemsAmount * 1) /100;
                        possessions[level_4].refGems += (gemsAmount * 1) /100;
                        possessions[level_4].essentialsBalance += (gemsAmount * 2) /100 * 100;
                        possessions[level_4].refEss += (gemsAmount * 2) /100 * 100;
                         possessions[level_4].refs++;

                        if(possessions[level_4].parentRef != address(0)){
                            address level_5 = possessions[level_4].parentRef;
                            possessions[level_5].gemBalance += (gemsAmount * 1) /100;
                            possessions[level_5].refGems += (gemsAmount * 1) /100;
                            possessions[level_5].essentialsBalance += (gemsAmount * 1) /100 * 100;
                            possessions[level_5].refEss += (gemsAmount * 1) /100 * 100;
                            possessions[level_5].refs++;
                        }
                    }

                }
            }
        }

         
         possessions[msg.sender].myInvestment += msg.value;
        payable(ADMIN_WALLET).transfer((msg.value * 9) / 100);
        
    }

// buy galaxy planet
    function buyPlanet(uint _index) external {
        require(_index < 7, "Index number doesn't exist");
        require(possessions[msg.sender].planetsOwn[_index][0] == 0, "It's not a first planet purchase!");
        require(nominalPrices[_index] <= possessions[msg.sender].gemBalance, "Not enough GEM balance!");

        possessions[msg.sender].gemBalance += countUserCurrentEssentials() / 10;
        for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
            }
        }
  
        possessions[msg.sender].gemBalance -= nominalPrices[_index];
        possessions[msg.sender].startTime = block.timestamp;
        possessions[msg.sender].planetsOwn[_index][0] = block.timestamp; //buy time
        possessions[msg.sender].planetsOwn[_index][1] = 1; //level
        possessions[msg.sender].planetsOwn[_index][2] = 100; //persent
        if(!possessions[msg.sender].init){
           
            possessions[msg.sender].planetsPriceUpLevel = [500, 1250, 2250, 5000, 12500, 25000, 62500] ;   
            possessions[msg.sender].essentionsByPlanet = [105, 225, 630, 1200, 3125, 6750, 18750];
            if(freePlanetsCount > 0){
                if(_index == 1 && !possessions[msg.sender].endAction){
                    possessions[msg.sender].planetsOwn[0][0] = block.timestamp; //buy time
                    possessions[msg.sender].planetsOwn[0][1] = 1; //level
                    possessions[msg.sender].planetsOwn[0][2] = 100; //persent
                    freePlanetsCount--;
                    totalGalaxy++;
                }
            }

        }
        possessions[msg.sender].init = true;
        possessions[msg.sender].endAction = true;
         totalGalaxy++;
    
    }

// up planet level by Id
    function levelUp(uint _index) external {
        require(_index < 7, "Index number doesn't exist");
        require(possessions[msg.sender].planetsOwn[_index][1] < 10, "Last Level!");
        require(possessions[msg.sender].gemBalance >=  possessions[msg.sender].planetsPriceUpLevel[_index], "Not enough Gems");
        require(possessions[msg.sender].planetsOwn[_index][0] != 0, "This planet was not buy");
        
        possessions[msg.sender].gemBalance -= possessions[msg.sender].planetsPriceUpLevel[_index] ;

        possessions[msg.sender].gemBalance += countUserCurrentEssentials() / 10;
        possessions[msg.sender].startTime = block.timestamp;
         for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
            }
        }
      
         possessions[msg.sender].planetsOwn[_index][1]++ ;
    }

// claim earned essentials and recalculate level price in all own planets
    function claimEssentials() external {
         require(possessions[msg.sender].init, "You have not bought any planet!");
       possessions[msg.sender].essentialsBalance += countUserCurrentEssentials();
       possessions[msg.sender].startTime = block.timestamp;
         for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
              possessions[msg.sender].planetsOwn[i][2] -= 3; // persent minus option
              possessions[msg.sender].planetsPriceUpLevel[i] = possessions[msg.sender].planetsPriceUpLevel[i] * 97 / 100;
              possessions[msg.sender].essentionsByPlanet[i] = possessions[msg.sender].essentionsByPlanet[i] * 97 / 100;
            }
        }
    }

// reinvest essentials to GEMs
    function reinvestEss() external {
        require(possessions[msg.sender].init, "You have not bought any planet!");
        uint gems = countUserCurrentEssentials() / 10;
        possessions[msg.sender].gemBalance += gems;
        possessions[msg.sender].startTime = block.timestamp;
         for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
            }
        }
    }

// count current essentials amount
    function countUserCurrentEssentials() private view returns(uint){
        uint oneDay = 86400; 
        uint finalTime;
        uint start = possessions[msg.sender].startTime;

        if(start != 0){
            finalTime = start + oneDay;
        }
        uint summaryEss;

        if(finalTime > block.timestamp){

            for (uint i = 0; i < 7; i++) {
                uint planetTime = possessions[msg.sender].planetsOwn[i][0];
                if (planetTime != 0) {

                    uint time = (block.timestamp - planetTime) / 864 ;
                    uint price = possessions[msg.sender].essentionsByPlanet[i];
                    uint level = possessions[msg.sender].planetsOwn[i][1];
                    summaryEss +=  (time * price * level) / 100;
                }
            }
        }else{
            for (uint i = 0; i < 7; i++) {
                uint planetTime = possessions[msg.sender].planetsOwn[i][0];
                if (planetTime != 0) {
                    uint price = possessions[msg.sender].essentionsByPlanet[i];
                    uint level = possessions[msg.sender].planetsOwn[i][1];
                    summaryEss +=   price * level;
                }
            }
        }
        return summaryEss;
    }

// retrieve all user data
   function getEss() public view returns(Planets memory) {
        return possessions[msg.sender];
    }

// withdraw award to user
    function withdrawAward() external {
        address user = msg.sender;
        require(possessions[user].essentialsBalance > 0, 'You have not essentials!');
        uint256 amount = possessions[user].essentialsBalance * 1e13;
        require(amount < address(this).balance, 'Not enough balance in system');
        possessions[user].essentialsBalance = 0;
        possessions[user].myWithdrawals += amount;
        payable(user).transfer(amount);
    }

// retrieve planet level by id
    function getPlanetLevel(uint _index)external view returns(uint){
        return possessions[msg.sender].planetsOwn[_index][1];
    }

// retrieve planet owner status by id
    function getMyPlanets(uint _index) external view returns(bool){
        if(possessions[msg.sender].planetsOwn[_index][0] == 0){return false;}
        return true;
    }

// retrieve planets price to up level
    function getEssentialsAwards() external view returns(uint[7] memory){
        return possessions[msg.sender].essentionsByPlanet;
    }

// retrieve essentials award array
    function getPlanetsPriceUpLevel() external view returns(uint[7] memory){
        return possessions[msg.sender].planetsPriceUpLevel;
    }

// retrieve current essentials award
    function getEssPerDay() external view returns(uint256){
        uint256 totalEss = 0;
        for(uint i = 0; i < 7; i++){
            totalEss += possessions[msg.sender].essentionsByPlanet[i] * possessions[msg.sender].planetsOwn[i][1] ;
        }
        return totalEss;
    }

// retrieve calc essentials with -3% after will claim
    function getWillClaimedEssPerDay() external view returns(uint256){
        uint256 totalEss = 0;
        for(uint i = 0; i < 7; i++){
            totalEss += (possessions[msg.sender].essentionsByPlanet[i] * 97 / 100) * possessions[msg.sender].planetsOwn[i][1] ;
        }
        return totalEss;
    }

// retrieve current essentials award
    function getGemstonesBalance()public view returns(uint){
        return possessions[msg.sender].gemBalance;
    }

// retrieve user essentials balance
    function getEssentialsBalance()public view returns(uint){
        return possessions[msg.sender].essentialsBalance;
    }

// retrieve user GEM balance
    function getTotalGalaxy()public view returns(uint){
        return totalGalaxy;
    }

// retrieve smart contract balance    
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

// retrieve user  summary investment value in BNB    
    function getMyInvestemnts() public view returns(uint){
        return possessions[msg.sender].myInvestment;
    }

// retrieve user summary withrawal value in BNB    
     function getMyWithdrawals() public view returns(uint){
        return possessions[msg.sender].myWithdrawals;
    }
   
// retrieve referral award GEMs     
    function getrefGems() public view returns(uint){
        return possessions[msg.sender].refGems;
    }

// retrieve start time timestamp at first planet purchase     
    function getStart()public view returns(uint){
        return possessions[msg.sender].startTime;
    }

// retrieve referral award essentials    
    function getrefEss() public view returns(uint){
        return possessions[msg.sender].refEss;
    }

// retrieve referral participants    
    function getRefs() public view returns(uint){
        return possessions[msg.sender].refs;
    }

// check out either user bought a planet        
    function checkInit() public view returns(bool){
        return possessions[msg.sender].init;
    }

// retrieve free planets count     
    function getFrePlanets() public view returns(uint){
        return freePlanetsCount;
    }


}