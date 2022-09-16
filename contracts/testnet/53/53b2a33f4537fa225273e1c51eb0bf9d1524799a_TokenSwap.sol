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
    

    constructor()
    {
        token1 = IBEP20(0x8516Fc284AEEaa0374E66037BD2309349FF728eA);//busd
        owner1 = 0xF46B081e7C4E42D679719AD4884Bd6b05eaF41fF;
        token2 = IBEP20(0x4C4d752dAcc8ec21ba783285b7a8603560941db0);//final
        owner2 = 0xe15505C74B9122185bFC6a27fe3c8D8c144f2e9f;
    }

    function swap(uint256 amount) public {
        require(msg.sender == owner1 || msg.sender == owner2, "Not authorized");
        require(
            token1.allowance(owner1, address(this)) >= amount,
            "Token 1 allowance too low"
        );
        require(
            token2.allowance(owner2, address(this)) >= amount,
            "Token 2 allowance too low"
        );

        _safeTransferFrom(token1, owner1, owner2, amount);
        _safeTransferFrom(token2, owner2, owner1, amount);
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