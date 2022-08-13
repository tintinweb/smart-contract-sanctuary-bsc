/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


 contract TokenDistributor {
   
    //usdt
    address public USDTAddress = address(0x55d398326f99059fF775485246999027B3197955);

    address public HYAddress;
    address public YDAddress;
    address public NLAddress;





    uint256 private constant MAX = ~uint256(0);




   

    constructor (
        address hyAddress, address ydAddress  , address nlAddress
    ) {
        HYAddress = hyAddress;
        YDAddress = ydAddress;
        NLAddress = nlAddress;
        IERC20(USDTAddress).approve(HYAddress, MAX);
        IERC20(USDTAddress).approve(YDAddress, MAX);
        IERC20(USDTAddress).approve(NLAddress, MAX);
    }


    receive() external payable {}

   
}