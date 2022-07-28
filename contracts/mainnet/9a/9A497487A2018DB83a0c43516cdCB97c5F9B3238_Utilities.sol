// SPDX-License-Identifier: MIT
// last updated v1.0.0

pragma solidity ^0.8.4;

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract Utilities {

  function getBalance(address _owner) public view returns (uint256) {
    return _owner.balance;
  }

  function getTokenBalance(address _owner, address _token) public view returns (uint256) {
    return ERC20(_token).balanceOf(_owner);
  }

  function isContract(address _address) public view returns (bool) {
    return _address.code.length > 0;
  }

  function sortTokens(address tokenA, address tokenB) public pure returns (address token0, address token1) {
    require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
  }

  function pairFor(address tokenA, address tokenB) public pure returns (address pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = address(uint160(uint256(keccak256(abi.encodePacked(
      hex'ff',
      address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73),
      keccak256(abi.encodePacked(token0, token1)),
      hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
    )))));
  }
}