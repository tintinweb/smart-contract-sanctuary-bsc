/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

//SPDX-License-Identifier: Unlicensed;
pragma solidity ^0.8.7; 
//
interface BUSD {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address owner, address spender) external view returns(uint256);

    function transfer(address recipient, uint amount) external view returns(bool);
    function approve(address spender, uint amount) external view returns(bool);
    function transferFrom(address sender,address recipient, uint amount) external view returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
}
contract ecommerceWongbebo {
   BUSD public BUSd;
    address private owner;

    mapping (address =>uint) public stakingBalance;

    constructor() {
        BUSd = BUSD(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        // this token address is BUSD deployed on Binance testnet
       // You can use any other ERC20 token smart contarct address here
        owner = msg.sender;
    }
   
   function depositeToken(uint $BUSD) public {

          BUSd.transferFrom(msg.sender, address(this), $BUSD * 10 ** 18);

       stakingBalance[msg.sender] = stakingBalance[msg.sender] + $BUSD * 10 ** 18;
   }
   //0xAbA43F3d3f070F702EF8BD7e1Eb6BD4B1Be2c7F0

    //withdraw from contract to user account
    function unstakeToken() public  {
        uint balance  = stakingBalance[msg.sender];
        //condition
        require(balance > 0, "withdraw amount can not be 0");

        BUSd.transfer(msg.sender,balance);

        stakingBalance[msg.sender] = 0;
    }
}