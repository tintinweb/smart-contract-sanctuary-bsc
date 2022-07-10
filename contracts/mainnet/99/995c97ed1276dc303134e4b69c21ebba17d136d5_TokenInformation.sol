/**
 *Submitted for verification at BscScan.com on 2022-07-10
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
  function totalSupply() external view returns (uint256);
}

interface TokenRouter {
  function getAmountsOut(uint, address[] calldata) external view returns (uint[] memory);
  function getPair(address tokenA, address tokenB) external view returns (address pair);
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
  TokenInformationStruct tokeninfo;

  function getPairInfo(address factory, address tokenA, address tokenB) public view returns (address pair){
    return TokenRouter(factory).getPair(tokenA, tokenB);
  }

  function getTotalSupply(address[] memory tokens) public view returns (uint256[] memory){
    // check if token is actually a contract
    uint256 tokenCode;
    address t;

    uint[] memory supply = new uint[](tokens.length);
    
    // is it a contract and does it implement balanceOf
      for(uint i = 0; i < tokens.length; i++) {
        t = tokens[i];
        assembly { tokenCode := extcodesize(t) } // contract code size
        if (tokenCode > 0) {
          supply[i] = Token(tokens[i]).totalSupply();
        } else {
          supply[i] = 0;
        }
      } 
      return supply;   
  }

  function getInfoTokens(address[] memory tokens, address user, address tokenSwapOne, address tokenSwapTwo, address router, address factory) public view returns (TokenInformationStruct[] memory){
      TokenInformationStruct[] memory secondtokeninfostruct = new TokenInformationStruct[](tokens.length);

      for(uint i = 0; i < tokens.length; i++){
          secondtokeninfostruct[i] = getInfoToken(tokens[i], user, tokenSwapOne, tokenSwapTwo, router, factory);
      }
      return secondtokeninfostruct;
  }
  

  function getInfoToken(address token, address user, address tokenSwapOne, address tokenSwapTwo, address router, address factory) public view returns (TokenInformationStruct memory){
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

    address token_pair = TokenRouter(factory).getPair(tokenSwapOne, token);

    if (token_pair == address(0)){
      uint256[]memory array_value = new uint256[](3);
      array_value[0] = 0;
      array_value[1] = 0;
      array_value[2] = 0;
      tokeninfostruct.prices = array_value;
    }
    else{
      tokeninfostruct.prices = TokenRouter(router).getAmountsOut(amountIn, tokenList);
    }
    
    return tokeninfostruct;
  }
}