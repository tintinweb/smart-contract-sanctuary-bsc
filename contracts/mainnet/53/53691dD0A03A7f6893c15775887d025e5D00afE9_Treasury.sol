// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeERC20Upgradeable.sol";

contract Treasury is Ownable {
     using SafeERC20Upgradeable for IERC20Upgradeable;

    function withdrawTokens(address _token, address _to, uint256 _amount) external onlyOwner {
        IERC20Upgradeable(_token).safeTransfer(_to, _amount);
    }

    function withdrawNative(address payable _to, uint256 _amount) external onlyOwner {
        _to.transfer(_amount);
    }

    receive () external payable {}
}