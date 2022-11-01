/**
 *Submitted for verification at BscScan.com on 2022-11-01
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Token {

    modifier ensure(uint32 deadline) {
        require(deadline > block.timestamp, "EXPIRED");
        _;
    }

    event paySignature(bytes32 sign);

    function benzPay(
        address token,
        address to,
        uint32 amount,
        bytes32 sign,
        uint32 deadline
    ) public ensure(deadline) {

        IERC20 fromToken = IERC20(token);
        fromToken.transferFrom(msg.sender, to, amount);
        emit paySignature(sign);
      
    }
}