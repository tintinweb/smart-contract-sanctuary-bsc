/**
 *Submitted for verification at BscScan.com on 2023-01-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EnergyGalaxy {
    address public adminWallet;
    address public refWallet;
    uint public totalGalaxy = 0;

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
    }

    mapping(address => Planets) possessions;

    constructor(address _adminWallet  ){
       // owner = msg.sender;
        adminWallet = _adminWallet;
    }


    function buyGemstones(address ref) external payable{
        //1 gem = 0.001 BNB - 1e15
        uint gemsAmount = msg.value / 1e15;

        possessions[msg.sender].gemBalance += gemsAmount;
        possessions[ref].gemBalance += (gemsAmount * 8) /100;
        possessions[ref].refGems += (gemsAmount * 8) /100;
        possessions[ref].essentialsBalance += (gemsAmount * 3) /100 * 100;
        possessions[ref].refEss += (gemsAmount * 3) /100 * 100;

         possessions[ref].refs += 1;
         possessions[msg.sender].myInvestment += msg.value;
        payable(adminWallet).transfer((msg.value * 9) / 100);
        
    }

    function buyPlanet(uint _index, uint _price, uint _amountReinves) external {
        require(_price <= possessions[msg.sender].gemBalance, "Not enough GEM balance!");

        possessions[msg.sender].gemBalance += _amountReinves;
        for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
            }
        }
  
        possessions[msg.sender].gemBalance -= _price;
        possessions[msg.sender].startTime = block.timestamp;
        possessions[msg.sender].planetsOwn[_index][0] = block.timestamp; //buy time
        possessions[msg.sender].planetsOwn[_index][1] = 1; //level
        possessions[msg.sender].planetsOwn[_index][2] = 100; //persent
        //possessions[msg.sender].essentionsByPlanet = [210, 1100, 2530, 4800, 12500, 27000, 75000];
        if(!possessions[msg.sender].init){
           
            possessions[msg.sender].planetsPriceUpLevel = [100, 500, 1100, 2000, 5000, 10000, 25000];
            possessions[msg.sender].essentionsByPlanet = [210, 1100, 2530, 4800, 12500, 27000, 75000];
        }
        possessions[msg.sender].init = true;
         totalGalaxy++;
    
    }

    function levelUp(uint _index, uint _lvlPrice, uint _amountReinves) external {
        require(possessions[msg.sender].planetsOwn[_index][1] < 10, "Last Level!");
        possessions[msg.sender].gemBalance -= _lvlPrice ;
        possessions[msg.sender].gemBalance += _amountReinves;
        possessions[msg.sender].startTime = block.timestamp;
         for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
            }
        }
      
         possessions[msg.sender].planetsOwn[_index][1]++ ;
         
    }

    function claimEssentials(uint _amount) external {
       possessions[msg.sender].essentialsBalance += _amount;
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

    function reinvestEss(uint _amount) external {
        possessions[msg.sender].gemBalance += _amount;
        possessions[msg.sender].startTime = block.timestamp;
         for(uint i = 0; i < possessions[msg.sender].planetsOwn.length; i++){
            if(possessions[msg.sender].planetsOwn[i][0] > 0){
              possessions[msg.sender].planetsOwn[i][0] = block.timestamp;
            }
        }
    }

   function getEss() public view returns(Planets memory) {
        return possessions[msg.sender];
    }

    function withdrawAward(uint256 ess) external {
        address user = msg.sender;
        require(ess <= possessions[user].essentialsBalance && ess > 0);
        possessions[user].essentialsBalance = 0;
        uint256 amount = ess * 1e13;
        possessions[user].myWithdrawals += amount;
        payable(user).transfer(address(this).balance < amount ? address(this).balance : amount);
    }

    function getPlanetLevel(uint _index)external view returns(uint){
        return possessions[msg.sender].planetsOwn[_index][1];
    }

    function leaveProject(uint _ess) external {
        possessions[msg.sender].startTime = 0;
        possessions[msg.sender].init = false;
        possessions[msg.sender].essentialsBalance += _ess;
        for(uint i = 0; i < 7; i++){
              possessions[msg.sender].planetsOwn[i][0] = 0;
              possessions[msg.sender].planetsOwn[i][1] = 0;
              possessions[msg.sender].planetsOwn[i][2] = 0;
        }
    } 

    function getMyPlanets(uint _index) external view returns(bool){
        if(possessions[msg.sender].planetsOwn[_index][0] == 0){return false;}
        return true;
    }

    function getPlanetsPriceUpLevel() external view returns(uint[7] memory){
        return possessions[msg.sender].planetsPriceUpLevel;
    }

    function getEssPerDay() external view returns(uint256){
        uint256 totalEss = 0;
        for(uint i = 0; i < 7; i++){
            totalEss += possessions[msg.sender].essentionsByPlanet[i] * possessions[msg.sender].planetsOwn[i][1] ;
        }
        return totalEss;
    }

    function getGemstonesBalance()public view returns(uint){
        return possessions[msg.sender].gemBalance;
    }

    function getEssentialsBalance()public view returns(uint){
        return possessions[msg.sender].essentialsBalance;
    }

    function getTotalGalaxy()public view returns(uint){
        return totalGalaxy;
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function getMyInvestemnts() public view returns(uint){
        return possessions[msg.sender].myInvestment;
    }
     function getMyWithdrawals() public view returns(uint){
        return possessions[msg.sender].myWithdrawals;
    }
   
    function getStart()public view returns(uint){
        return possessions[msg.sender].startTime;
    }
    function getrefGems() public view returns(uint){
        return possessions[msg.sender].refGems;
    }
    function getrefEss() public view returns(uint){
        return possessions[msg.sender].refEss;
    }
    function getRefs() public view returns(uint){
        return possessions[msg.sender].refs;
    }
}