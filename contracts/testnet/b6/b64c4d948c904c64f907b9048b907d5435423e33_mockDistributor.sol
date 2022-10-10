/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
/**
 * @title mockDistributor
 * @author : saad sarwar
 */


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library Percentages {
    // Get value of a percent of a number
    function calcPortionFromBasisPoints(uint _amount, uint _basisPoints) public pure returns(uint) {
        if(_basisPoints == 0 || _amount == 0) {
            return 0;
        } else {
            uint _portion = _amount * _basisPoints / 10000;
            return _portion;
        }
    }

    // Get basis points (percentage) of _portion relative to _amount
    function calcBasisPoints(uint _amount, uint  _portion) public pure returns(uint) {
        if(_portion == 0 || _amount == 0) {
            return 0;
        } else {
            uint _basisPoints = (_portion * 10000) / _amount;
            return _basisPoints;
        }
    }
}

contract mockDistributor is Ownable {

    using Percentages for uint;

    address public TOKEN = 0xcf468a63992059B77EFee1c7d4954b3A31649C38;

    uint public RESTAKE_PERCENTAGE = 800; // 8 %
    uint public BOOSTER_PERCENTAGE = 100; // 1% for cake booster pool
    uint public DEV_PERCENTAGE = 200; // 2%
    uint public SLIPPAGE = 9500; // 95 % SO, 5 % slippage just to remain on the safe side
    
    constructor(
    ) {
    }

    function adjustRestakePercentage(uint percentage) public onlyOwner() {
        RESTAKE_PERCENTAGE = percentage;
    }

    function adjustDevPercentage(uint percentage) public onlyOwner() {
        DEV_PERCENTAGE = percentage;
    }

    function adjustBoosterPercentage(uint percentage) public onlyOwner() {
        BOOSTER_PERCENTAGE = percentage;
    }
    
    // emergency withdrawal function in case of any bug or v2
    function withdrawTokens() public onlyOwner() {
        IBEP20(TOKEN).transfer(msg.sender, IBEP20(TOKEN).balanceOf(address(this)));
    }

    function compound() public view returns(uint, uint, uint, uint) {
        // require(msg.sender == owner() || msg.sender == BOUNTY, "EZ: not owner or bounty");
        // harvest();
        uint balance = IBEP20(TOKEN).balanceOf(address(this));
        uint forDev = balance.calcPortionFromBasisPoints(DEV_PERCENTAGE);
        uint forRestake = balance.calcPortionFromBasisPoints(RESTAKE_PERCENTAGE);
        uint forBooster = balance.calcPortionFromBasisPoints(BOOSTER_PERCENTAGE);
        uint forDistribution = balance - (forDev + forRestake + forBooster);
        // boost(forBooster);
        // restake(forRestake);
        // IBEP20(TOKEN).transfer(DEV, forDev);
        // IBEP20(TOKEN).transfer(BOUNTY, forDistribution);
        // TOKEN_DISTRIBUTED += forDistribution;
        return (forDev, forRestake, forBooster, forDistribution);
    }
}