// SPDX-License-Identifier: UNLICENSED

// This contract generates Sale contracts and registers them in the SaleFactory.
// Ideally you should not interact with this contract directly, and use the Sale app instead so warnings can be shown where necessary.

pragma solidity 0.8.17;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./TransferHelper.sol";
import "./SaleHelper.sol";
import "./Sale.sol";

interface ISaleFactory {
    function registerSale(address _saleAddress) external;

    function saleIsRegistered(address _saleAddress) external view returns (bool);
}

contract SaleGenerator is Ownable {
    using SafeMath for uint256;

    ISaleFactory public SALE_FACTORY;
    ISaleSetting public SALE_SETTING;

    event CreateSale(address saleOwner, address saleAddress, uint256 creationFee);

    struct SaleParams {
        uint256 amount;
        uint256 tokenPrice; // number sale token per base token
        uint256 limitPerBuyer; // number base token per user
        uint256 hardCap;
        uint256 softCap;
        uint256 startTime;
        uint256 endTime;
    }

    constructor() {
        SALE_FACTORY = ISaleFactory(0xE0d591740f3F304aCdc3d73dC74f853FA952fDdb);
        SALE_SETTING = ISaleSetting(0x21E10C1509a13e5e0bD88Eb6F7586266F8764c7f);
    }

    /**
     * @notice Creates a new Sale contract and registers it in the SaleFactory
     */
    function createSale(
        address payable _saleOwner,
        IERC20 _saleToken,
        IERC20 _baseToken,
        bool[3] memory _activeInfo,
        uint256[7] memory unitParams,
        uint256[] memory _vestingPeriod,
        uint256[] memory _vestingPercent
    ) public payable {
        SaleParams memory params;
        params.amount = unitParams[0];
        params.tokenPrice = unitParams[1];
        params.limitPerBuyer = unitParams[2];
        params.hardCap = unitParams[3];
        params.softCap = unitParams[4];
        params.startTime = unitParams[5];
        params.endTime = unitParams[6];

        require(params.limitPerBuyer > 0, 'SALE GENERATOR: INVALID LIMIT PER BUYER');
        require(SALE_SETTING.baseTokenIsValid(address(_baseToken)), 'SALE GENERATOR: INVALID BASE TOKEN');

        // Charge fee for contract creation
        require(msg.value == SALE_SETTING.getCreationFee(), 'SALE GENERATOR: FEE NOT MET');
        SALE_SETTING.getBaseFeeAddress().transfer(SALE_SETTING.getCreationFee());

        require(params.amount >= 10000, 'SALE GENERATOR: MIN DIVIS');
        require(params.softCap > 0, 'SALE GENERATOR: INVALID SOFT CAP');
        require(params.hardCap > params.softCap, 'SALE GENERATOR: INVALID HARD CAP');
        require(params.endTime > params.startTime, 'SALE GENERATOR: INVALID END TIME');
        require(params.startTime.add(SALE_SETTING.getMaxSaleLength()) >= params.endTime, 'SALE GENERATOR: INVALID SALE LENGTH');
        require(params.tokenPrice.mul(params.hardCap) > 0, 'SALE GENERATOR: INVALID PARAMS');
        // ensure no overflow for future calculations
        uint256 tokenRequiredForSale = SaleHelper.calculateAmountRequired(params.amount, SALE_SETTING.getTokenFeePercent());

        if (_activeInfo[2]) {
            // Validate Vesting
            require(_vestingPeriod.length > 0, 'INVALID VESTING PERIOD');
            require(_vestingPeriod.length == _vestingPercent.length, 'INVALID VESTING DATA');
            uint256 totalVestingPercent = 0;
            for (uint256 i = 0; i < _vestingPercent.length; i++) {
                totalVestingPercent = totalVestingPercent.add(_vestingPercent[i]);
            }
            require(totalVestingPercent == 1000, 'INVALID VESTING PERCENT');
        } else {
            delete _vestingPeriod;
            delete _vestingPercent;
        }

        Sale newSale = new Sale(address(this));
        TransferHelper.safeTransferFrom(address(_saleToken), address(msg.sender), address(newSale), tokenRequiredForSale);
        newSale.setMainInfo(_saleOwner, params.amount, params.tokenPrice, params.limitPerBuyer, params.hardCap, params.softCap, params.startTime, params.endTime);
        newSale.setFeeInfo(_baseToken, _saleToken, SALE_SETTING.getBaseFeePercent(), SALE_SETTING.getTokenFeePercent(), SALE_SETTING.getBaseFeeAddress(), SALE_SETTING.getTokenFeeAddress());
        newSale.setRoundInfo(_activeInfo[0], _activeInfo[1]);
        newSale.setVestingInfo(_activeInfo[2], _vestingPeriod, _vestingPercent);

        SALE_FACTORY.registerSale(address(newSale));
        emit CreateSale(_saleOwner, address(newSale), msg.value);
    }

}