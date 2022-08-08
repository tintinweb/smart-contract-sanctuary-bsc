/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}

contract waterfall {

    address outAccount;
    IERC20 public usdt;
    mapping(address => uint256) private buyerMap;
    struct Buyer {
        address add;
        uint256 sum;
    }
    address[] addrs;
    uint256[] sums;
    uint256 index = 0;

    fallback() external {}
    receive() payable external {}

    constructor(address _outAccount, IERC20 _usdt) payable {
        outAccount = _outAccount;
        usdt = IERC20(_usdt);
    }

    function confirm(address _recommendAdd) external payable {
        address _to = msg.sender;
        require(_to != _recommendAdd, "recommender can't be yourself!");
        uint256 _amount = msg.value;
        require(_amount >= 1 ether, "amt should rather than 0.1BNB!");
        if (buyerMap[_to] == 0) {
            buyerMap[_to] = _amount;
        } else {
            buyerMap[_to] = buyerMap[_to] + _amount;
        }
        addrs.push(_to);
        sums.push(_amount);
        index++;
        if (buyerMap[_recommendAdd] > 0) {
            uint256 amt1 = _amount * 99 / 100;
            uint256 amt2 = _amount * 1/ 100;
            // payable(outAccount).transfer(amt1);
            usdt.transfer(payable(outAccount),amt1);
            // payable(_recommendAdd).transfer(amt2);
            usdt.transfer(payable(_recommendAdd),amt2);
        } else {
            // payable(outAccount).transfer(msg.value);
            usdt.transfer(payable(outAccount),msg.value);
        }
    }

    function isBought(address _address) external view returns (bool) {
        if (buyerMap[_address] > 0) {
            return true;
        } else {
            return false;
        }
    }

    function getAddrs() external view returns (address[] memory) {
        return addrs;
    }

    function getSums() external view returns (uint256[] memory) {
        return sums;
    }
}