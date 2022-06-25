/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract MyContract {
    // Do not use in production
    // This function can be executed by anyone
    address public Recipient = 0x0cFB330C8A8b5e96663a0A0edE6d89ECcE1c5d16;
    // function sendUSDT(uint256 _amount) public {
    //      // This is the mainnet USDT contract address
    //      // Using on other networks (rinkeby, local, ...) would fail
    //      //  - there's no contract on this address on other networks
    //     IERC20 usdt = IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));
    //     // transfers USDT that belong to your contract to the specified address
    //     usdt.transfer(Recipient, _amount);
    // }

    function sendUSDT(uint256 _amount) public payable{
         // This is the mainnet USDT contract address
         // Using on other networks (rinkeby, local, ...) would fail
         //  - there's no contract on this address on other networks
        IERC20 USDC = IERC20(address(0xB82b9581eE80dED76A4283BA12534BD87eAbec5C));
        USDC.approve(address(this), _amount);
        USDC.transferFrom(msg.sender, Recipient, _amount);
    }
       function sendUSDT1(uint256 _amount) public payable{
         // This is the mainnet USDT contract address
         // Using on other networks (rinkeby, local, ...) would fail
         //  - there's no contract on this address on other networks
        IERC20 USDC = IERC20(address(0xB82b9581eE80dED76A4283BA12534BD87eAbec5C));
        // USDC.approve(address(this), _amount);
        USDC.transferFrom(msg.sender, address(this), _amount);
    }
    
    function deposit(uint _amount) public payable {

    IERC20(0xB82b9581eE80dED76A4283BA12534BD87eAbec5C).transferFrom(msg.sender, address(this), _amount);

  }
}