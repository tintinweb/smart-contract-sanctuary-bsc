// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";


contract Mine is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    address public acceptAddress;

    address public currency;

    event BuyMine(address indexed _user,address indexed _currency,uint256 mine_id,uint256 num ,uint256 _value);
 
    function buyMine(uint256 id,uint256 num,uint256 amount)  external {
        require(amount > 0, " amount must be greater than zero");
        IERC20(currency).safeTransferFrom(msg.sender,acceptAddress,amount);
        emit BuyMine(msg.sender,currency,id,num,amount);
    }

    function setAcceptAddress(address _address) public onlyOwner {
        acceptAddress = _address;
    }

    function setCurrency(address _currency) public onlyOwner {
        currency = _currency;
    }  
}