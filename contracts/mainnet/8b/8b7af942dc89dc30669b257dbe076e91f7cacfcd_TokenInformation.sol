/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

//https://github.com/DeltaBalances/DeltaBalances.github.io/blob/master/smart_contract/deltabalances.sol
//https://github.com/wbobeirne/eth-balance-checker/blob/master/contracts/BalanceChecker.sol
//https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol

interface Token {
  function decimals() external view returns (uint256);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function balanceOf(address account) external view returns (uint256);
}

interface TokenRouter {
  function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory);
}

contract TokenInformation {

  struct TokenInformationStruct {
    address token;
    string symbol;
    string name; 
    uint decimal;   
    uint256 balance;
    uint256[] prices;
  }
  TokenInformationStruct[] tokeninfo;

  struct SecondTokenInfomationStruct {
    TokenInformationStruct[] tis;
  }

  function getInfoTokens(address[] calldata tokens, address user, address tokenSwapOne, address tokenSwapTwo, address router) public returns (SecondTokenInfomationStruct[] memory){
      SecondTokenInfomationStruct[] memory secondtokeninfostruct = new SecondTokenInfomationStruct[](tokens.length);

      for(uint i = 0; i < tokens.length; i++){
          secondtokeninfostruct[i].tis = getInfoToken(tokens[i], user, tokenSwapOne, tokenSwapTwo, router);
      }
      return secondtokeninfostruct;
  }
  

  function getInfoToken(address token, address user, address tokenSwapOne, address tokenSwapTwo, address router) public returns (TokenInformationStruct[] memory){
     // check if token is actually a contract
    uint256 tokenCode;
    assembly { tokenCode := extcodesize(token) } // contract code size
    
    TokenInformationStruct memory tokeninfostruct;
    
    tokeninfostruct.token = token;
    tokeninfostruct.symbol = Token(token).symbol();
    tokeninfostruct.name = Token(token).name();   
    tokeninfostruct.decimal = Token(token).decimals(); 
    tokeninfostruct.balance = Token(token).balanceOf(user);
    
    uint amountIn = 1*(10**tokeninfostruct.decimal);

    address[] memory tokenList = new address[](3);
    tokenList[0] = token;
    tokenList[1] = tokenSwapOne;
    tokenList[2] = tokenSwapTwo;

    tokeninfostruct.prices = TokenRouter(router).getAmountsOut(amountIn, tokenList);

    tokeninfo.push(tokeninfostruct);
    return tokeninfo;
  }
}