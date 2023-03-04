/**
 *Submitted for verification at BscScan.com on 2023-03-04
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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface ISRG {
    function _buy(uint256 minTokenOut, uint256 deadline)
        payable
        external
        returns (bool);
    
    function _sell(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 minBNBOut
    ) external  returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount)
        external
        returns (bool);
    
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


}

interface ISRG20 {
    function _buy(
        uint256 buyAmount,
        uint256 minTokenOut,
        uint256 deadline
    ) external returns (bool);
    
    function _sell(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 minBNBOut
    ) external returns (bool);

    
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount)
        external
        returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}



contract SurgeSwap is ReentrancyGuard{


    //SRG pair data
    address private SRG; //change this according to chain


    constructor(address _srgAddress)
    {
        SRG = _srgAddress;
    }

    ISRG private SRGI = ISRG(SRG); //interface to interact with SRG

    function swapExactETHforSRG20(
        uint256 deadline,
        uint256 minSRG20Out,
        address SRG20
    ) external payable nonReentrant returns (bool){
        
        // Buy the SRG with the ETH and figure out how much we got
        uint256 balanceBefore = SRGI.balanceOf(address(this));
        bool temp1 = SRGI._buy{value: msg.value}( 0,deadline);
        require(temp1,"Failed to buy SRG!");
        uint256 balanceAfter = SRGI.balanceOf(address(this));
        uint256 change = balanceAfter - balanceBefore;

        // Initialize the interface to interact with the SRG20 Contract
        ISRG20 SRG20I = ISRG20(SRG20);

        //Buy the SRG20 using SRG and figure out how much we got
        uint256 balanceBefore20 = SRG20I.balanceOf(address(this));
        temp1 = SRG20I._buy(change, minSRG20Out, deadline);
        require(temp1,"Failed to buy the SRG20!");
        uint256 balanceAfter20 = SRG20I.balanceOf(address(this));
        uint256 change20 = balanceAfter20-balanceBefore20;

        //transfer the received SRG20 to the msg sender
        temp1 = SRG20I.transfer(msg.sender, change20);
        require(temp1,"Failed to send the SRG20!");

        return true;
    }

    function swapExactSRG20forSRG20(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 minSRG20Out,
        address SRG20Spent,
        address SRG20Received
    ) external nonReentrant returns (bool){
        ISRG20 SRG20SpentI = ISRG20(SRG20Spent);
        ISRG20 SRG20ReceivedI = ISRG20(SRG20Received);

        // transfer the SRG20Spent from the msg.sender to the CA
        bool s1 = SRG20SpentI.transferFrom(msg.sender, address(this), tokenAmount);
        require(s1,"Failed to transfer SRG20Spent");

        // Sell the SRG20Spent and figure out how much SRG we got
        uint256 balanceBefore = SRGI.balanceOf(address(this));
        s1 = SRG20SpentI._sell(tokenAmount, deadline, 0);
        require(s1,"Failed to sell SRG20Spent");
        uint256 balanceAfter = SRGI.balanceOf(address(this));
        uint256 change = balanceAfter - balanceBefore;
        
        // approve the SRG20Received contract to be able to buy it
        s1 = SRGI.approve(SRG20Received, change);
        require(s1,"Failed to approve SRG spending!");


        // buy the SRG20Received and figure out how much we got
        uint256 balanceBefore20 = SRG20ReceivedI.balanceOf(address(this));
        s1 = SRG20ReceivedI._buy(change, minSRG20Out, deadline);
        require(s1, "Failed to buy SRG20Received!");
        uint256 balanceAfter20 = SRG20ReceivedI.balanceOf(address(this));
        uint256 change20 = balanceAfter20- balanceBefore20;

        //transfer the SRG20Received to the msg sender
        s1 = SRG20ReceivedI.transfer(msg.sender, change20); 
        require(s1, "Failed to transfer the SRG20Received!");
        return true;
    }

    function swapExactSRG20forETH(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 minETHOut,
        address SRG20Spent
    ) external nonReentrant  returns (bool){
        ISRG20 SRG20SpentI = ISRG20(SRG20Spent);

        // transfer the SRG20Spent from the msg.sender to the CA
        bool s1 = SRG20SpentI.transferFrom(msg.sender, address(this), tokenAmount);
        require(s1,"Failed to transfer SRG20Spent");

        uint256 balanceBefore = SRGI.balanceOf(address(this));
        s1 = SRG20SpentI._sell(tokenAmount, deadline, 0);
        require(s1,"Failed to sell SRG20Spent");
        uint256 balanceAfter = SRGI.balanceOf(address(this));
        uint256 change = balanceAfter - balanceBefore;
        

        uint256 balanceBeforeETH = address(this).balance;
        s1 = SRGI._sell(change, deadline, minETHOut);
        require(s1, "Failed to buy SRG20Received!");
        uint256 balanceAfterETH = address(this).balance;
        uint256 changeETH = balanceAfterETH- balanceBeforeETH;

        sendETH(payable(msg.sender), changeETH);

        return true;
    }

    function sendETH(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

}