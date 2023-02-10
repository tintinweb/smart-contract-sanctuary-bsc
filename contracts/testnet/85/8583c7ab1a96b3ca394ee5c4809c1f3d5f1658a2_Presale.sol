/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Erc20_SD {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}

contract Presale {
    Erc20_SD buytoken;
    Erc20_SD selltoken;
    uint256 public tokenprice;
    constructor(address _buytoken, address _selltoken) {
        buytoken = Erc20_SD(_buytoken);
        selltoken = Erc20_SD(_selltoken);
        tokenprice=10;
    }
    function buy(uint256 _amount) public {
      uint256 value=_amount*tokenprice;
      buytoken.transferFrom(msg.sender,address(this),_amount);
      selltoken.transfer(msg.sender,value);
    }
}