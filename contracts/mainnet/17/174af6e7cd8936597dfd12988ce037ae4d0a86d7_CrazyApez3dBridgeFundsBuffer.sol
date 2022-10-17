/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

/*  
 * CrazyApez3D BridgeFundsBuffer
 * 
 * Written by: MrGreenCrypto
 * Co-Founder of CodeCraftrs.com
 * 
 * SPDX-License-Identifier: None
 */
pragma solidity 0.8.17;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract CrazyApez3dBridgeFundsBuffer {
    address private MrGreen = 0xe6497e1F2C5418978D5fC2cD32AA23315E7a41Fb;
    address private apez = 0x69692C182E80BCF35B2868839D81BD5bd1126969;
    mapping(address => bool) private hasAdminRights;

    modifier onlyOwner() {if(!hasAdminRights[msg.sender]) return; _;}

    constructor() {
        hasAdminRights[MrGreen] = true;
    }

    receive() external payable {}

    function sendBridgedFundsToCrazyApezContract() external {
        bool success;
        (success,) = address(apez).call{value: address(this).balance}("");
    }

    function rescueAnyToken(address token) external onlyOwner {
        IBEP20(token).transfer(MrGreen, IBEP20(token).balanceOf(address(this)));
    }
    
    function rescueBNB() external onlyOwner {
        payable(MrGreen).transfer(address(this).balance);
    }
}