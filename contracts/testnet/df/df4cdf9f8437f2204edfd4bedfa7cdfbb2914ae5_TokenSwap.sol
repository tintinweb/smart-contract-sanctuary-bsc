/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TokenSwap {
    IBEP20 public token1;
    address public owner1;
    IBEP20 public token2;
    address public owner2;
    uint256 ratio;
    
    constructor()
    {
        token1 = IBEP20(0x8516Fc284AEEaa0374E66037BD2309349FF728eA);//busd
        owner1 = 0xF46B081e7C4E42D679719AD4884Bd6b05eaF41fF; // investors wallet
        token2 = IBEP20(0x4C4d752dAcc8ec21ba783285b7a8603560941db0);//final
        owner2 = 0xe15505C74B9122185bFC6a27fe3c8D8c144f2e9f; //presale wallet
    }//1000000000000000000


    function swap(uint256 amount) public {
        require(msg.sender == owner1 || msg.sender == owner2, "Not authorized");
        require(
            token1.allowance(owner1, address(this)) >= amount,
            "Token 1 allowance too low"
        );
        require(
            token2.allowance(owner2, address(this)) >= amount*ratio,
            "Token 2 allowance too low"
        );

        //set ratio
            uint256 presalebalance= token2.balanceOf(owner2) ;
            uint256 decimals=10**18 ;
            if (0<presalebalance && presalebalance<10500*decimals) ratio = 40; //2k 8.5
                else if (10500<presalebalance && presalebalance<13500*decimals) ratio = 60; //3k 10.5
                    else if (13500<presalebalance && presalebalance<17500*decimals) ratio = 80; //4k 13.5
                        else ratio = 100 ; //5k 17.5

        //swap
        _safeTransferFrom(token1, owner1, owner2, amount);
        _safeTransferFrom(token2, owner2, owner1, amount*ratio);
    }

    function _safeTransferFrom(
        IBEP20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}