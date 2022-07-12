// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BigpadInfo is Ownable {

    uint256 private devFeePercentage = 3;

    address[] private presaleAddresses;

    function addPresaleAddress(address _presale) external returns (uint256) {
        presaleAddresses.push(_presale);
        return presaleAddresses.length - 1;
    }

    function getPresalesCount() external view returns (uint256) {
        return presaleAddresses.length;
    }

    function getPresaleAddress(uint256 bigpadId) external view returns (address) {
        return presaleAddresses[bigpadId];
    }

    function getDevFeePercentage() external view returns (uint256) {
        return devFeePercentage;
    }

    function setDevFeePercentage(uint256 _devFeePercentage) external onlyOwner {
        devFeePercentage = _devFeePercentage;
    }

}