// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./Ownable.sol";

interface ITokenSetting {
    function getCreationFee() view external returns (uint256);

    function setCreationFee(uint _creationFee) external;

    function getTotalSupplyFee() view external returns (uint256);

    function setTotalSupplyFee(uint _totalSupplyFee) external;

    function getTokenFeeAddress() view external returns (address);

    function setTokenFeeAddress(address payable _tokenFeeAddress) external;
}

contract TokenSetting is Ownable {

    struct Setting {
        uint256 CREATION_FEE;
        uint256 TOTAL_SUPPLY_FEE;
        address payable TOKEN_FEE_ADDRESS;
    }

    Setting public SETTING;

    constructor() {
        SETTING.CREATION_FEE = 0.1 ether;
        SETTING.TOTAL_SUPPLY_FEE = 0;
        SETTING.TOKEN_FEE_ADDRESS = payable(msg.sender);
    }

    function getCreationFee() view external returns (uint256) {
        return SETTING.CREATION_FEE;
    }

    function setCreationFee(uint256 _creationFee) external onlyOwner {
        SETTING.CREATION_FEE = _creationFee;
    }

    function getTotalSupplyFee() view external returns (uint256) {
        return SETTING.TOTAL_SUPPLY_FEE;
    }

    function setTotalSupplyFee(uint256 _totalSupplyFee) external onlyOwner {
        require(_totalSupplyFee <= 1000, 'TOKEN SETTING: INVALID TOTAL SUPPLY FEE');
        SETTING.TOTAL_SUPPLY_FEE = _totalSupplyFee;
    }

    function getTokenFeeAddress() view external returns (address) {
        return SETTING.TOKEN_FEE_ADDRESS;
    }

    function setTokenFeeAddress(address payable _tokenFeeAddress) external onlyOwner {
        SETTING.TOKEN_FEE_ADDRESS = _tokenFeeAddress;
    }

    function getSettingInfo() external view returns (uint256 creationFee, uint256 totalSupplyFee, address payable tokenFeeAddress) {
        return (SETTING.CREATION_FEE, SETTING.TOTAL_SUPPLY_FEE, SETTING.TOKEN_FEE_ADDRESS);
    }

    function setSettingInfo(uint256 _creationFee, uint256 _totalSupplyFee, address payable _tokenFeeAddress) external onlyOwner {
        require(_totalSupplyFee <= 1000, 'TOKEN SETTING: INVALID TOTAL SUPPLY FEE');
        SETTING.CREATION_FEE = _creationFee;
        SETTING.TOTAL_SUPPLY_FEE = _totalSupplyFee;
        SETTING.TOKEN_FEE_ADDRESS = payable(_tokenFeeAddress);
    }
}