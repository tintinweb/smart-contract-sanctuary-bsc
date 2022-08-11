/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

pragma solidity ^0.4.25;

interface IToken {
  function transfer(address _to, uint256 _value) external;
  function transferFrom(address _from, address _to, uint256 _value) external  returns (bool success) ;
  function burn(uint256 _value) external returns (bool success);
  function balanceOf(address account) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function totalSupply() external view returns (uint256);
  function mint(address _to,uint256 _mintAmount) external;
  function limitSupply() external view returns (uint256);
}

contract Airdrop {
function batch(address token, address [] toAddr, uint256 [] value) public returns (bool){
    require(toAddr.length == value.length && toAddr.length >= 1);
    for(uint256 i = 0 ; i < toAddr.length; i++){
        if(!IToken(token).transferFrom(msg.sender,toAddr[i], value[i]*(10**18))) {  revert(); }
        }
    }
}