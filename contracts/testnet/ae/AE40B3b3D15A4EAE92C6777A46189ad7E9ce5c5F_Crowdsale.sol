/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

pragma solidity 0.4.25;

interface token {
    function transfer(address receiver, uint amount) external;
    function balanceOf(address account) external view returns (uint256);
}


contract Crowdsale {
    token public tokenReward;
    address public beneficiary = msg.sender; 
    uint public price; 

    mapping(address => uint256) public balance; 


    constructor(

        uint TokenPrice,
        address Tokenaddress

    )  public {

        price = TokenPrice ; 
        tokenReward = token(Tokenaddress); 
    }
  
    function () payable public {

        uint amount = msg.value;
        tokenReward.transfer(msg.sender, amount * price / 1e16);
        
         
    }

    function backToken(address _token) public{
       token t = token(_token);
       uint amount = t.balanceOf(address(this));
       t.transfer(beneficiary,amount);
    }
    
    function backEth() public{
        beneficiary.transfer(address(this).balance);
    }
}