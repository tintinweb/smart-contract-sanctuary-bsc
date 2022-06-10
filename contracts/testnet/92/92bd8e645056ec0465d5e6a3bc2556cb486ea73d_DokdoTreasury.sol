//SPDX-License-Identifier: MIT

/*

                                                                  dddddddd                 
DDDDDDDDDDDDD                         kkkkkkkk                    d::::::d                 
D::::::::::::DDD                      k::::::k                    d::::::d                 
D:::::::::::::::DD                    k::::::k                    d::::::d                 
DDD:::::DDDDD:::::D                   k::::::k                    d:::::d                  
  D:::::D    D:::::D    ooooooooooo    k:::::k    kkkkkkk ddddddddd:::::d    ooooooooooo   
  D:::::D     D:::::D oo:::::::::::oo  k:::::k   k:::::kdd::::::::::::::d  oo:::::::::::oo 
  D:::::D     D:::::Do:::::::::::::::o k:::::k  k:::::kd::::::::::::::::d o:::::::::::::::o
  D:::::D     D:::::Do:::::ooooo:::::o k:::::k k:::::kd:::::::ddddd:::::d o:::::ooooo:::::o
  D:::::D     D:::::Do::::o     o::::o k::::::k:::::k d::::::d    d:::::d o::::o     o::::o
  D:::::D     D:::::Do::::o     o::::o k:::::::::::k  d:::::d     d:::::d o::::o     o::::o
  D:::::D     D:::::Do::::o     o::::o k:::::::::::k  d:::::d     d:::::d o::::o     o::::o
  D:::::D    D:::::D o::::o     o::::o k::::::k:::::k d:::::d     d:::::d o::::o     o::::o
DDD:::::DDDDD:::::D  o:::::ooooo:::::ok::::::k k:::::kd::::::ddddd::::::ddo:::::ooooo:::::o
D:::::::::::::::DD   o:::::::::::::::ok::::::k  k:::::kd:::::::::::::::::do:::::::::::::::o
D::::::::::::DDD      oo:::::::::::oo k::::::k   k:::::kd:::::::::ddd::::d oo:::::::::::oo 
DDDDDDDDDDDDD           ooooooooooo   kkkkkkkk    kkkkkkkddddddddd   ddddd   ooooooooooo   
                                                                                           
Dokdo Team - 2022

https://dokdo.sh/

*/

pragma solidity ^0.8.8;

import "./dokdo.sol";

// ----------------------------------------------------------------------------

// Dokdo Team Time Lock Contract

// ----------------------------------------------------------------------------

contract DokdoTreasury is DokdoAuth  {
    using SafeMath for uint;
    Dokdo token;
    uint lastCompleteRelease;
    uint restRelease;
    uint constant releasePerMonth = 2 * 10**23;
    
    constructor(address payable addrToken, address _owner) DokdoAuth(_owner) {
        token = Dokdo(addrToken);
        restRelease = 0;
        lastCompleteRelease = block.timestamp;
    }
    
    function getLockedTokenAmount() public view returns (uint) {
        return token.balanceOf(address(this));
    }
    
    function getAllowedAmount() public view returns (uint) {
        uint amount = restRelease;
        if (block.timestamp < lastCompleteRelease) return amount;
        
        uint lockedAmount = getLockedTokenAmount();

        uint months = (block.timestamp - lastCompleteRelease) / (30 days) + 1;
        uint possible = lockedAmount.sub(restRelease).div(releasePerMonth);
        if (possible > months) {
            possible = months;
        }
        amount = amount.add(possible.mul(releasePerMonth));
        return amount;
    }
    
    function withdraw(uint amount) external onlyOwner {
        uint allowedAmount = getAllowedAmount();

        require(allowedAmount >= amount, 'not enough tokens');

        if (token.transfer(msg.sender, amount)) {
            restRelease = allowedAmount.sub(amount);
            while(block.timestamp > lastCompleteRelease) {
                lastCompleteRelease += 30 days;
            }
        }
    }

}