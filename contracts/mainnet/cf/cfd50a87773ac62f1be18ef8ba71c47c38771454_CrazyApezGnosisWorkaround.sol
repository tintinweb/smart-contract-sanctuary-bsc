/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

/*  
 * CrazyApez3D GnosisWorkaround
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

interface IApez {
    function rescueBnb() external;
}

contract CrazyApezGnosisWorkaround {
    address private MrGreen = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address private _admin = 0x4E6262e06705A1ae471Fcb305C445804ffe9162d;
    IApez private apez = IApez(0x69692C182E80BCF35B2868839D81BD5bd1126969);
    mapping(address => bool) private hasAdminRights;

    modifier onlyOwner() {if(!hasAdminRights[msg.sender]) return; _;}

    constructor() {
        hasAdminRights[MrGreen] = true;
        hasAdminRights[_admin] = true;
    }

    receive() external payable {}

    function setAdminAddress(address adminWallet, bool status) external onlyOwner {
        hasAdminRights[adminWallet] = status;
    }

    function getSomeFundsForCrazyApezLeave1BNB() external onlyOwner {
        bool success;
        apez.rescueBnb();
        uint256 fundsToSend = address(this).balance - 1 ether;
        if(address(this).balance > 1 ether) (success,) = address(_admin).call{value: fundsToSend}("");
        (success,) = address(apez).call{value: address(this).balance}("");
    }

    function getSomeFundsForCrazyApezLeaveXBNB(uint256 xBNB) external onlyOwner {
        bool success;
        apez.rescueBnb();
        uint256 fundsToSend = address(this).balance - xBNB * 1 ether;
        if(address(this).balance > 1 ether) (success,) = address(_admin).call{value: fundsToSend}("");
        (success,) = address(apez).call{value: address(this).balance}("");
    }
}