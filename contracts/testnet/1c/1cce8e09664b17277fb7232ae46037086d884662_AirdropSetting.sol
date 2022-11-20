// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

import "./Ownable.sol";

interface IAirdropSetting {
    function getFeeAmount() view external returns (uint256);

    function getFeeAddress() view external returns (address);
}

contract AirdropSetting is Ownable {

    struct Setting {
        uint256 FEE_AMOUNT;
        address payable FEE_ADDRESS;
    }

    Setting public SETTING;

    constructor() {
        SETTING.FEE_AMOUNT = 0.1 ether;
        SETTING.FEE_ADDRESS = payable(msg.sender);
    }

    function getFeeAmount() view external returns (uint256) {
        return SETTING.FEE_AMOUNT;
    }

    function setFeeAmount(uint256 _feeAmount) external onlyOwner {
        SETTING.FEE_AMOUNT = _feeAmount;
    }

    function getFeeAddress() view external returns (address) {
        return SETTING.FEE_ADDRESS;
    }

    function setFeeAddress(address payable _feeAddress) external onlyOwner {
        SETTING.FEE_ADDRESS = _feeAddress;
    }

    function getSettingInfo() external view returns (uint256 feeAmount, address payable feeAddress) {
        return (SETTING.FEE_AMOUNT, SETTING.FEE_ADDRESS);
    }

    function setSettingInfo(uint256 _feeAmount, address payable _feeAddress) external onlyOwner {
        SETTING.FEE_AMOUNT = _feeAmount;
        SETTING.FEE_ADDRESS = payable(_feeAddress);
    }
}