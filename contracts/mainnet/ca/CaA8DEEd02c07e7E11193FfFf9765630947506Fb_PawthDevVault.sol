/**
 *Submitted for verification at BscScan.com on 2022-09-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract PawthDevVault {

    address constant pawthDevMultiSig = 0xF10B1D6e1cD1DE1f11daf1f609b152b8B125426D;

    function withdrawEth () external {
        (bool sent, ) = pawthDevMultiSig.call{value: address(this).balance}("");
        require(sent, "Failed to send eth to multisig");
    }

    function withdrawToken (address token_) external {
        IERC20 token = IERC20(token_);
        token.transfer(pawthDevMultiSig, token.balanceOf(address(this)));
    }

    // accept ETH
    receive() external payable {}
}