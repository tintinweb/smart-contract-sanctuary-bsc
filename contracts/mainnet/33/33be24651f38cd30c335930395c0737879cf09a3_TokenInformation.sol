/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// Built off of https://github.com/DeltaBalances/DeltaBalances.github.io/blob/master/smart_contract/deltabalances.sol
//https://github.com/wbobeirne/eth-balance-checker/blob/master/contracts/BalanceChecker.sol
pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

// ERC20 contract interface
contract Token {
  function decimals() public view returns (uint8);
  function symbol() public view returns (string memory);
  function name() public view returns (string memory);
  function balanceOf(address) public view returns (uint256);
}

contract TokenRouter {
  function getAmountsOut(uint, address[] memory) public view returns (uint[] memory);
}

contract TokenInformation {

  struct TokenInformationStruct {
    uint decimal;
    string symbol;
    string name;    
    uint256 balance;
    uint256[] prices;
  }

  TokenInformationStruct[] tokeninfo;

  /* Fallback function, don't accept any ETH */
  function() public payable {
    revert("BalanceChecker does not accept payments");
  }

 function tokenPrice(address router, uint amountIn, address[] tokens) public view returns (uint[] memory amounts) {
    // check if token is actually a contract
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(router) } // contract code size
    return TokenRouter(router).getAmountsOut(amountIn, tokens);
  }

  /*
    Check the token balance of a wallet in a token contract

    Returns the balance of the token for user. Avoids possible errors:
      - return 0 on non-contract address 
      - returns 0 if the contract doesn't implement balanceOf
  */
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

  /*
    Check the token balances of a wallet for multiple tokens.
    Pass 0x0 as a "token" address to get ETH balance.

    Possible error throws:
      - extremely large arrays for user and or tokens (gas cost too high) 
          
    Returns a one-dimensional that's user.length * tokens.length long. The
    array is ordered by all of the 0th users token balances, then the 1th
    user, and so on.
  */
  function balances(address[] users, address[] tokens) external view returns (uint[]) {
    uint[] memory addrBalances = new uint[](tokens.length * users.length);
    
    for(uint i = 0; i < users.length; i++) {
      for (uint j = 0; j < tokens.length; j++) {
        uint addrIdx = j + tokens.length * i;
        if (tokens[j] != address(0x0)) { 
          addrBalances[addrIdx] = tokenBalance(users[i], tokens[j]);
        } else {
          addrBalances[addrIdx] = users[i].balance; // ETH balance    
        }
      }  
    }
    return addrBalances;
  }

  function getInfoToken(address token, address user, address tokenSwapOne, address tokenSwapTwo, address router) public view returns (TokenInformationStruct[] memory){
     // check if token is actually a contract
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size

    TokenInformationStruct memory tokeninfostruct;
    
    tokeninfostruct.decimal = Token(token).decimals();
    tokeninfostruct.symbol = Token(token).symbol();
    tokeninfostruct.name = Token(token).name();    
    tokeninfostruct.balance = Token(token).balanceOf(user);

    uint amountIn = 1*(10**tokeninfostruct.decimal);

    //tokens[0] = ["abc"];
    address[] memory tokenList = new address[](3);
    tokenList[0] = token;
    tokenList[1] = tokenSwapOne;
    tokenList[2] = tokenSwapTwo;

    tokeninfostruct.prices = TokenRouter(router).getAmountsOut(amountIn, tokenList);

    tokeninfo.push(tokeninfostruct);

    return tokeninfo;
  }


}