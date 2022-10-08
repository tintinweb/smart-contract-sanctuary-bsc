/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract PawthCharityVault {

    address constant pawthCharityMultiSig = 0x78C28f40E21bd06aEE1a0780692b576623b008df;

    function withdrawEth () external {
        (bool sent, ) = pawthCharityMultiSig.call{value: address(this).balance}("");
        require(sent, "Failed to send eth to multisig");
    }

    function withdrawToken (address token_) external {
        IERC20 token = IERC20(token_);
        token.transfer(pawthCharityMultiSig, token.balanceOf(address(this)));
    }

    // accept ETH
    receive() external payable {}
}