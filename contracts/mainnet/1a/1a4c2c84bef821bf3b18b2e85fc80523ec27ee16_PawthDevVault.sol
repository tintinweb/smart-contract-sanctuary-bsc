/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

contract PawthDevVault {

    address constant pawthDevMultiSig = 0xF10B1D6e1cD1DE1f11daf1f609b152b8B125426D;

    function withdraw () public {
        require (msg.sender == pawthDevMultiSig, "Not authorized");
        (bool sent, ) = pawthDevMultiSig.call{value: address(this).balance}("");
        require(sent, "Failed to send eth to treasury");
    }

    // accept ETH
    receive() external payable {}
}