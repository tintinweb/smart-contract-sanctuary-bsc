/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

/**
 *  Auth proxy to decouple its logic from staking contract.
 *
 *  @author Obama
 *
 *  Created on: 27/01/2022
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract Ownable {
    address _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(msg.sender);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BEBOP_auth_proxy is Ownable {
    BebopOnlyOwner delegate;
    address stakingContract;

    modifier ownerOrStaking() {
        require(_owner == msg.sender || stakingContract == msg.sender, "Forbidden!");
        _;
    }

    constructor(address _bebopContract, address _stakingContract) {
        delegate = BebopOnlyOwner(_bebopContract);
        stakingContract = _stakingContract;
    }

    function setStakingContract(address newStakingContract) external onlyOwner {
        stakingContract = newStakingContract;
    }

    function transferBebopOwnership(address newOwner) external onlyOwner {
        delegate.transferOwnership(newOwner);
    }

    function setTxLimit(uint256 amount) external onlyOwner {
        delegate.setTxLimit(amount);
    }

    function setMaxWallet(uint256 numerator, uint256 divisor) external onlyOwner {
        delegate.setMaxWallet(numerator, divisor);
    }

    function setIsFeeExempt(address holder, bool exempt) external ownerOrStaking {
        delegate.setIsFeeExempt(holder, exempt);
    }

    function setIsBlacklisted(address holder, bool blacklisted) external onlyOwner {
        delegate.setIsBlacklisted(holder, blacklisted);
    }

    function setIsTxLimitExempt(address holder, bool exempt) external onlyOwner {
        delegate.setIsTxLimitExempt(holder, exempt);
    }

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator)
    external onlyOwner {
        delegate.setFees(_liquidityFee, _buybackFee, _reflectionFee, _marketingFee, _feeDenominator);
    }

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external onlyOwner {
        delegate.setFeeReceivers(_autoLiquidityReceiver, _marketingFeeReceiver);
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount) external onlyOwner {
        delegate.setSwapBackSettings(_enabled, _amount);
    }

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external onlyOwner {
        delegate.setTargetLiquidity(_target, _denominator);
    }
}

interface BebopOnlyOwner {
    function transferOwnership(address newOwner) external;

    function setTxLimit(uint256 amount) external;

    function setMaxWallet(uint256 numerator, uint256 divisor) external;

    function setIsFeeExempt(address holder, bool exempt) external;

    function setIsBlacklisted(address holder, bool blacklisted) external;

    function setIsTxLimitExempt(address holder, bool exempt) external;

    function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256 _reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external;

    function setFeeReceivers(address _autoLiquidityReceiver, address _marketingFeeReceiver) external;

    function setSwapBackSettings(bool _enabled, uint256 _amount) external;

    function setTargetLiquidity(uint256 _target, uint256 _denominator) external;
}