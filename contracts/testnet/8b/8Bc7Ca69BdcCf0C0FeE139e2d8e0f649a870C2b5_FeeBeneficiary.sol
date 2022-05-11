// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";

contract FeeBeneficiary is Ownable {
    uint256 public feePercentage;
    address public feeTo;

    uint256 public feeLiquidity;
    address public liquidity;
    
    constructor(address _feeTo, uint256 _feePercentage) {
        setFee(_feeTo == address(0) ? address(this) : _feeTo, _feePercentage);
    }

    function setFee(address _feeTo, uint256 _feePercentage) public onlyOwner {
        feeTo = _feeTo;
        feePercentage = _feePercentage;
    }
    

    function setFeeLiquidity(address _liquidity, uint256 _feeLiquidity) public onlyOwner {
        liquidity = _liquidity;
        feeLiquidity = _feeLiquidity;
    }

    //function call by marketplaceFixedPrice
    function chargeFee(IERC20 _token, uint256 _totalAmount) public returns (uint256) {
        uint256 fee = (_totalAmount * feePercentage) / 100;
        uint256 feeLQ = (_totalAmount * feeLiquidity) / 100;

        if (feeTo!= address(this)) {
            _token.transfer(feeTo, fee);
        }

        if (liquidity!= address(this)) {
            _token.transfer(liquidity, feeLQ);
        }

        uint256 resultingAmount = _totalAmount - fee - feeLQ;
        return resultingAmount;
        
    }
    //function call by marketplaceAuction
    function getResultingAmount(uint256 _totalAmount, IERC20 _token) public returns (uint256) {
        uint256 fee = (_totalAmount * feePercentage) / 100;
        uint256 feeLQ = (_totalAmount * feeLiquidity) / 100;

        if (feeTo!= address(this)) {
            _token.transfer(feeTo, fee);
        }

        if (liquidity!= address(this)) {
            _token.transfer(liquidity, feeLQ);
        }

        uint256 resultingAmount = _totalAmount - fee - feeLQ;
        return resultingAmount;
    }

    function _getFeeLiquidity() public view returns(uint){
        return feeLiquidity;
    }

    function _getFee() public view returns(uint){
        return feePercentage;
    }
}