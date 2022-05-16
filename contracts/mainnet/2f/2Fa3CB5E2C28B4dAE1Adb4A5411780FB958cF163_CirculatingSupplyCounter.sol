// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20_Smol {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

contract CirculatingSupplyCounter {
    function getTotalSupplyExcluding(IERC20_Smol token, address[] memory excludedAddresses)
        external
        view
        returns (uint256 circulatingSupply)
    {
        circulatingSupply = token.totalSupply();
        for (uint256 i = 0; i < excludedAddresses.length; i++) {
            circulatingSupply -= token.balanceOf(excludedAddresses[i]);
        }
    }
}