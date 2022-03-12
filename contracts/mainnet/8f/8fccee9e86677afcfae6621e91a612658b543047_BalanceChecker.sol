/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// Built off of https://github.com/DeltaBalances/DeltaBalances.github.io/blob/master/smart_contract/deltabalances.sol
pragma solidity ^0.4.21;

// ERC20 contract interface
contract Token {
  function balanceOf(address) public view returns (uint);
}

contract BalanceChecker {

  
  function tokenBalance(address user, address token) public view returns (uint) {
    // check if token is actually a contract
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
  
    // is it a contract and does it implement balanceOf 
    if (tokenCode > 0 && token.call(bytes4(0x70a08231), user)) {  
      return Token(token).balanceOf(user);
    } else {
      return 0;
    }
  }

 
  function balances(address[] users, address tokens) external view returns (uint[]) {
    uint[] memory addrBalances = new uint[](users.length);
    
     for(uint i = 0; i < users.length; i++) {
          addrBalances[i] = tokenBalance(users[i], tokens);
     }
    return addrBalances;
  }

}