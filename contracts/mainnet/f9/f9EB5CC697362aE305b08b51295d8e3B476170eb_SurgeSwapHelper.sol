/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

//SPDX-License-Identifier: MIT

/**
 * Contract: SurgeSwap helper
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint8);
}


contract SurgeSwapHelper is ReentrancyGuard{
    //SRG pair data
    address public SRG; 
    ISRG public SRGI;

    constructor(address _srgAddress)
    {
        SRG = _srgAddress;
    }

    function SRG20forSRG20(
        uint256 tokenAmount,
        uint256 deadline,
        address SRG20Spent
    ) external nonReentrant returns (bool){

        // Sell the SRG20Spent and figure out how much SRG we got
        uint256 balanceBefore = IERC20(SRG).balanceOf(address(this));
        bool s1 = ISRG20(SRG20Spent)._sell(tokenAmount, deadline, 0);
        require(s1,"Failed to sell SRG20Spent");
        uint256 balanceAfter = IERC20(SRG).balanceOf(address(this));
        uint256 change = balanceAfter - balanceBefore;
        
        //transfer the SRG20Received to the msg sender
        s1 = IERC20(SRG).transfer(msg.sender, change); 
        require(s1, "Failed to transfer the SRG20Received!");
        return true;
    }


    function SRG20forETH(
        uint256 tokenAmount,
        uint256 deadline,
        uint256 minETHOut,
        address SRG20Spent,
        address user
    ) external nonReentrant returns (bool){

        uint256 balanceBefore = IERC20(SRG).balanceOf(address(this));
        bool s1 = ISRG20(SRG20Spent)._sell(tokenAmount, deadline, 0);
        require(s1,"Failed to sell SRG20Spent");
        uint256 balanceAfter = IERC20(SRG).balanceOf(address(this));
        uint256 change = balanceAfter - balanceBefore;
        
        uint256 balanceBeforeETH = address(this).balance;
        s1 = ISRG(SRG)._sell(change, deadline, minETHOut);
        require(s1, "Failed to sell SRG!");
        uint256 balanceAfterETH = address(this).balance;
        uint256 changeETH = balanceAfterETH - balanceBeforeETH;

        sendETH(payable(user), changeETH);

        return true;
    }

    function sendETH(address payable recipient, uint256 amount) public {
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
    
    receive() external payable{}
}