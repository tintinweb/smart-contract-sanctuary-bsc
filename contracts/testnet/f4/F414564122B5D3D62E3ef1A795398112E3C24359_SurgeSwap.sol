/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

//SPDX-License-Identifier: MIT

/**
 * Contract: SurgeSwap
 * Developed by: Heisenman
 * Team: t.me/ALBINO_RHINOOO, t.me/Heisenman, t.me/STFGNZ
 * Trade without dex fees. $SURGE is the inception of the next generation of decentralized protocols.
 *
 * Socials:
 * TG: https://t.me/SURGEPROTOCOL
 * Website: https://surgeprotocol.io/
 * Twitter: https://twitter.com/SURGEPROTOCOL
 */

pragma solidity 0.8.19;



interface ISRG {
    function _buy(uint256 minTokenOut, uint256 deadline)
        payable
        external
        returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount)
        external
        returns (bool);

}

interface ISRG20 {
    function _buy(
        uint256 buyAmount,
        uint256 minTokenOut,
        uint256 deadline
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
}



contract SurgeSwap{

    //SRG pair data
    address public SRG; //change this according to chain
    

    constructor(address _srgAddress)
    {
        SRG = _srgAddress;
    }

    ISRG public SRGI = ISRG(SRG); //interface to interact with SRG

    function swapExactETHforSRG20(
        uint256 deadline,
        uint256 minSRG20Out,
        address SRG20
    ) external payable  returns (bool){
        
        // Buy the SRG with the ETH and figure out how much we got
        uint256 balanceBefore = SRGI.balanceOf(address(this));
        bool temp1 = SRGI._buy{value: msg.value}( 0,deadline);
        require(temp1,"Failed to buy SRG!");
        uint256 balanceAfter = SRGI.balanceOf(address(this));
        uint256 change = balanceAfter - balanceBefore;

        //Approve the SRG20 to buy
        temp1 = SRGI.approve(payable(SRG20), change);
        require(temp1,"Could not approve the SRG20");

        //Buy the SRG20 using SRG and figure out how much we got
        uint256 balanceBefore20 = ISRG20(SRG20).balanceOf(address(this));
        temp1 = ISRG20(SRG20)._buy(change, minSRG20Out, deadline);
        require(temp1,"Failed to buy the SRG20!");
        uint256 balanceAfter20 = ISRG20(SRG20).balanceOf(address(this));
        uint256 change20 = balanceAfter20-balanceBefore20;

        //transfer the received SRG20 to the msg sender
        temp1 = ISRG20(SRG20).transfer(msg.sender, change20);
        require(temp1,"Failed to send the SRG20!");

        return true;
    }

    function getBalance() external view returns(uint256){
        return SRGI.balanceOf(address(this));
    }

    receive() external  payable {}

    function buySRG() external returns(bool){
        // Buy the SRG with the ETH and figure out how much we got
        bool temp1 = SRGI._buy{value: address(this).balance}( 0,1000000000000000000);
        return temp1;
    }

}