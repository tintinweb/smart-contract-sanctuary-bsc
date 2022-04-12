/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.1;

interface Amadeus_IA_intf{
    function decimals() external view returns(uint8);
    function balanceOf(address _address) external view returns(uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);

}
contract Sale_ICO_Amadeus_IA{
    address onwer;
    uint256 price;
    Amadeus_IA_intf Amadeus_token_ICO;
    uint256 tokenSold;

    event Sold(address buyer, uint256 amount);

    constructor (uint256 _price, address _addressToken) public{
        onwer= msg.sender;
        price= _price;
        Amadeus_token_ICO= Amadeus_IA_intf(_addressToken);
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a==0){
            return 0;
        }
        uint256 c= a*b;
        require(c/a==b);
        return c;
    }
    function buy(uint256 _numTokens) public payable{
        require(msg.value == mul(price, _numTokens));
        uint256 scaledAmount= mul(_numTokens, uint256(10) ** Amadeus_token_ICO.decimals());
        require(Amadeus_token_ICO.balanceOf(address(this))>=scaledAmount);
        tokenSold += _numTokens;
        require(Amadeus_token_ICO.transfer(msg.sender, scaledAmount));
        emit Sold(msg.sender, _numTokens);


    }
function  getFraction ( uint  percent ,   uint   base )   internal  pure returns ( uint  portion )   { 

     uint256  temp =  percent *   base   *   10   +   5 ; 
     uint256 result= temp /   1000;
     require(base >result);
     return  result; 
}
    function endSold() public {
        require(msg.sender==onwer);
        uint256 comition= getFraction(15, Amadeus_token_ICO.balanceOf(address(this)));
        require(Amadeus_token_ICO.transfer(onwer, Amadeus_token_ICO.balanceOf(address(this)) - comition));
        msg.sender.transfer(address(this).balance);
    }
}