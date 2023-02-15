/**
 *Submitted for verification at BscScan.com on 2023-01-19
 */

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract BUSDOneTax {
    BNBOneInterface public stakingInfo =
        BNBOneInterface(0x2121Fac779c83e83943554522E3D32D29FeD55FE);
    token public BUSD = token(0xbD47e66cD1FEE13095cf71f2Ed32b04102854562);

    uint256 public tax = 10;
    uint256 public divider = 100;
    mapping(address => uint256) public coveredAmount;

    address public taxTo = 0x968966b720F3535f6F7bB7D67cC1397E0C81aC1a;
    address public taxTo2 = 0x968966b720F3535f6F7bB7D67cC1397E0C81aC1a;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function payTax(uint256 amount) public {
        (, , uint112 totalClaimed, , ) = stakingInfo.stakeInfo(msg.sender);

        BUSD.transferFrom(msg.sender, taxTo, amount / 2);
        BUSD.transferFrom(msg.sender, taxTo2, amount / 2);

        if (coveredAmount[msg.sender] == 0) {
            coveredAmount[msg.sender] =
                totalClaimed +
                ((amount * divider) / tax);
        } else {
            coveredAmount[msg.sender] += ((amount * divider) / tax);
        }
    }

    function changeTaxto(uint256 index, address n) public {
        require(msg.sender == owner);
        if (index == 0) {
            taxTo = n;
        } else {
            taxTo2 = n;
        }
    }
}

interface BNBOneInterface {
    function stakeInfo(
        address
    )
        external
        view
        returns (
            uint112 totalReturn,
            uint112 activeStakes,
            uint112 totalClaimed,
            uint256 claimable,
            uint112 cps
        );
}

interface token {
    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}