/**
 * @title Distributor Vault
 * @dev DistributorVault contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

import "./Ownable.sol";
import "./SafeERC20.sol";

pragma solidity 0.6.12;

contract DistributorVault is Ownable {
    using SafeERC20 for IERC20;

    function withdrawTokens(address _token, address _to, uint256 _amount) external onlyOwner {
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function giveAllowancesMax(address _token, address _to) external onlyOwner {
        IERC20(_token).safeApprove(_to, uint256(-1));
    }

    function giveAllowances(address _token, address _to, uint256 max) external onlyOwner {
        IERC20(_token).safeApprove(_to, uint256(max));
    }

    function removeAllowances(address _token, address _to) external onlyOwner {
        IERC20(_token).safeApprove(_to, 0);
    }

}