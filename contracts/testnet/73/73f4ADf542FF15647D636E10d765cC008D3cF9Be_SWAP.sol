// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ISWAP.sol";
import "./USDTContract.sol";
import "./KSWAPContract.sol";
import "./SafeMath.sol";
import "./CPEContract.sol";
import "./KingContract.sol";
import "./UContract.sol";
import "./Ownable.sol";
import "./ShopContract.sol";

contract SWAP is
    ISWAP,
    KSWAPContract,
    USDTContract,
    CPEContract,
    KingContract,
    UContract,
    Ownable,
    ShopContract
{
    uint256 private _tokenTotalSupply;
    uint256 private _kTotal;
    uint256 private _cpeTotal;
    uint256 private _businessBuyCnt = 0;
    address private _project1Address;
    address private _project2Address;
    mapping(address => Orders[]) private _buyRecord;
    mapping(address => Orders[]) private _sellRecord;

    using SafeMath for uint256;
    using AddressTool for address;

    constructor() {
        address temp;
        _approveUSDT(temp._getKswapAddress());
        _approveU(temp._getKswapAddress());
    }

    function initPool(uint256 usdtAmount)
        external
        override
        onlyMinter
        returns (bool)
    {
        require(usdtAmount > 0);
        require(_businessBuyCnt == 0, "not Cnt");
        _transferFromUSDT(msg.sender, address(this), usdtAmount);
        uint256 kingAmount = _UsdtToKing(usdtAmount);
        _kTotal = _kTotal.add(kingAmount);
        _cpeTotal = _cpeTotal.add(usdtAmount);
        _businessBuyCnt = _businessBuyCnt.add(1);
        _buyRecord[msg.sender].push(
            Orders({
                number: usdtAmount,
                price: kingAmount.mul(1000000).div(usdtAmount),
                totalAmount: kingAmount
            })
        );
        return true;
    }

    function getCurrentPrice() external view override returns (uint256) {
        if (_cpeTotal == 0) {
            return 0;
        } else {
            return _kTotal.mul(1000000).div(_cpeTotal);
        }
    }

    function getKTotal() external view override returns (uint256) {
        return _kTotal;
    }

    function getCPETotal() external view override returns (uint256) {
        return _cpeTotal;
    }

    function getHistoryBuyOrder()
        external
        view
        override
        returns (Orders[] memory)
    {
        return _buyRecord[msg.sender];
    }

    function getHistorySellOrder()
        external
        view
        override
        returns (Orders[] memory)
    {
        return _sellRecord[msg.sender];
    }

    function sellCPE(uint256 amount) external override returns (bool) {
        require(amount > 0);
        require(_project1Address != address(0));
        require(_project2Address != address(0));
        uint256 balanceCPE = _balanceOfCPE(msg.sender);
        require(balanceCPE >= amount, "Insufficient balance");
        uint256 poolKing = _balanceOfKing(address(this));
        uint256 cepPrice = _getCurrentPrice();
        uint256 kAmount = amount.mul(900000).mul(cepPrice).div(1000000).div(
            1000000
        );
        require(poolKing >= kAmount, "Insufficient balance Pool");
        address cpeSender = _getSenderCPE();
        _transferFromCPE(
            msg.sender,
            cpeSender,
            amount.mul(970000).div(1000000)
        );
        _transferFromCPE(
            msg.sender,
            _project1Address,
            amount.mul(15000).div(1000000)
        );
        _transferFromCPE(
            msg.sender,
            _project2Address,
            amount.mul(15000).div(1000000)
        );
        _transferKing(msg.sender, kAmount);
        _kTotal = _kTotal.sub(kAmount);
        _cpeTotal = _cpeTotal.sub(amount.mul(970000).div(1000000));
        _sellRecord[msg.sender].push(
            Orders({
                number: amount,
                price: kAmount.mul(1000000).div(amount),
                totalAmount: kAmount
            })
        );
        return true;
    }

    function buyCPE(uint256 ordersNo) external override returns (bool) {
        require(ordersNo > 0, "ordersNo error");
        require(_project1Address != address(0));
        require(_project2Address != address(0));
        (
            uint256 ordersAmount,
            address buyerAddress,
            address recommenderAddress,
            address businessAddress,
            address businessRecommenderAddress
        ) = _getOrdersOfBuyCPEInfo(ordersNo);
        require(ordersAmount > 0, "ordersAmount not Exists");
        require(buyerAddress != address(0), "buyerAddress not Exists");
        require(
            recommenderAddress != address(0),
            "recommenderAddress not Exists"
        );
        require(businessAddress != address(0), "businessAddress not Exists");
        require(
            businessRecommenderAddress != address(0),
            "businessRecommenderAddress not Exists"
        );
        uint256 usdtAmount = ordersAmount.mul(250000).div(1000000);
        address cpeSender = _getSenderCPE();
        _transferFromUSDT(msg.sender, address(this), usdtAmount);
        uint256 kingAmount = _UsdtToKing(usdtAmount);
        uint256 cpePrice = _getCurrentPrice();
        uint256 cpeAmount = kingAmount.mul(1000000).div(cpePrice);
        uint256 mySelfNumber = cpeAmount.mul(688000).div(1000000);
        _transferFromCPE(cpeSender, msg.sender, mySelfNumber);
        if (recommenderAddress != address(0)) {
            _transferFromCPE(
                cpeSender,
                recommenderAddress,
                cpeAmount.mul(172000).div(1000000)
            );
        }
        _transferFromCPE(
            cpeSender,
            businessAddress,
            cpeAmount.mul(30000).div(1000000)
        );
        if (businessRecommenderAddress != address(0)) {
            _transferFromCPE(
                cpeSender,
                businessRecommenderAddress,
                cpeAmount.mul(10000).div(1000000)
            );
        }
        _transferFromCPE(
            cpeSender,
            _project1Address,
            cpeAmount.mul(15000).div(1000000)
        );
        _transferFromCPE(
            cpeSender,
            _project2Address,
            cpeAmount.mul(15000).div(1000000)
        );
        _kTotal = _kTotal.add(kingAmount);
        _cpeTotal = _cpeTotal.add(cpeAmount.mul(930000).div(1000000));
        _buyRecord[buyerAddress].push(
            Orders({
                number: mySelfNumber,
                price: kingAmount.mul(1000000).div(mySelfNumber),
                totalAmount: kingAmount
            })
        );
        return true;
    }

    function setProject1Address(address project1Address)
        external
        override
        onlyMinter
        returns (address)
    {
        _project1Address = project1Address;
        return _project1Address;
    }

    function setProject2Address(address project2Address)
        external
        override
        onlyMinter
        returns (address)
    {
        _project2Address = project2Address;
        return _project2Address;
    }

    function _getCurrentPrice() internal view returns (uint256) {
        if (_cpeTotal == 0) {
            return 0;
        } else {
            return _kTotal.mul(1000000).div(_cpeTotal);
        }
    }

    function _UsdtToKing(uint256 usdtAmount) internal returns (uint256) {
        uint256 amountOut = _get_Usdt_U_AmountsOut(usdtAmount);
        uint256 amountOutMin = amountOut.mul(950000).div(1000000);
        uint256[] memory amounts = _swap_Usdt_U_ExactTokensForTokens(
            usdtAmount,
            amountOutMin,
            address(this)
        );
        uint256 amountUOut = amounts[1];
        amountOut = _get_U_King_AmountsOut(amountUOut);
        amountOutMin = amountOut.mul(950000).div(1000000);
        amounts = _swap_U_King_ExactTokensForTokens(
            amountUOut,
            amountOutMin,
            address(this)
        );
        return amounts[1];
    }
}