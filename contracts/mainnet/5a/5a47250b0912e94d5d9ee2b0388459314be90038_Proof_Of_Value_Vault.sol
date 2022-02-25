/**
 * @title Proof of Value Vault
 * @dev Proof_of_Value_Vault contract
 *
 * @author - <AUREUM VICTORIA GROUP>
 * for the Securus Foundation
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

import "./Ownable.sol";
import "./SafeERC20.sol";

pragma solidity ^0.6.12;

contract Proof_Of_Value_Vault is Ownable {
    using SafeERC20 for IERC20;

    function withdrawTokens(address _token, address _to, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    receive () external payable {}
}