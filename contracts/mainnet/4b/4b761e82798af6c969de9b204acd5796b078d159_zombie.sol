/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity ^0.4.13;

interface Token {
  function balanceOf(address _owner)  constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) returns (bool success);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract zombie {
  function destroy() public {
    selfdestruct(msg.sender);
}
   function airdrop(address tokenaddr, address master) public {
       Token token = Token(tokenaddr);
       token.transfer(master, token.balanceOf(address(this)));
   }
}



contract zombier {

    event Addr(address indexed _from);
     function withdrawalToken(address _tokenAddress, uint num)  public { 
        Token token = Token(_tokenAddress);
        for(uint j = 0; j < num; j++){
            zombie a = new zombie();
            a.airdrop(_tokenAddress, msg.sender);
            Addr( a);
            a.destroy();
            
        }
       
    }

}