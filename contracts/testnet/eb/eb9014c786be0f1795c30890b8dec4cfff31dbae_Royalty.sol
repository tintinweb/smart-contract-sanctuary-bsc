// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";


contract Royalty is Context, Ownable {    
    using SafeERC20 for IERC20;

    struct RoyaltyUnit {
        address receiver;
        uint256 percent;
    }

    RoyaltyUnit[] public royaltyCollection;

    uint256 constant totalPercent = 1e4;

    event SetRoyalty(address receiver, uint256 percent);
    event PayRoyalty(address receiver, address token, uint256 amount);
 
    constructor(address cOwner) Ownable (cOwner) {
        
    }

    function setRoyalty(address receiver, uint256 percent) external onlyOwner {
        require(receiver != address(0), "invalid fee receiver address");
        require(percent <= totalPercent, "invalid percent");
        
        bool newReceiver = true;
        for (uint256 i = 0; i < royaltyCollection.length; i++) {
            if (royaltyCollection[i].receiver == receiver) {
                royaltyCollection[i].percent = percent;
                newReceiver = false;
                break;
            }
        }

        if (newReceiver) {
            RoyaltyUnit memory rlt = RoyaltyUnit({
                                    receiver: receiver,
                                    percent: percent
                                });
            royaltyCollection.push(rlt);
        }

        emit SetRoyalty(receiver, percent);
    }


    function payRoyalty(address token) external onlyOwner() {
        require(token != address(0), "invalid fee token address");
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "insufficient token amount");

        uint256 total = 0;
        for (uint256 i = 0; i < royaltyCollection.length; i++) {
            total = total + royaltyCollection[i].percent;
            require(total <= totalPercent, "invalid percent");
            uint256 amount = (balance * royaltyCollection[i].percent) / totalPercent;
            _transfer(royaltyCollection[i].receiver, amount, token);

            emit PayRoyalty(royaltyCollection[i].receiver, token, amount);
        }
    }

    function _transfer(
    address _to,
    uint256 _amount,
    address _paymentToken
  ) internal {
        IERC20(_paymentToken).safeTransfer(_to, _amount);
  }
}