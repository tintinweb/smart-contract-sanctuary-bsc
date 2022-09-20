// SPDX-License-Identifier: MIT

/* 
 * \file    timeLock.sol
 * \brief   Small contract offering a lock service. 
 *          It ensures that the beneficiary doesn't spend his/her tokens too quickly.
 *
 * \brief   Release note
 * \version 1.0
 * \date    2022/09/20
 * \details The beginning
 *
 * \todo    Patience and enjoy.
 */

pragma solidity ^0.8.17;

import "../ERC20.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract timeLock {
    struct releaseData {
        address tokenAddress;
        address beneficiary;
    	   uint256 totalAmount;
        uint256 remainingAmount;
        uint16 numberOfRelease;

        uint[] releaseTime;
        uint8[] state;
    }
    
    releaseData[] public _releaseData;

    uint8 public constant STATE_ON_HOLD     = 0;
    uint8 public constant STATE_IN_PROGRESS = 1;
    uint8 public constant STATE_PERFORMED   = 2;

    event requestForPeriodicLock(address tokenIn, address beneficiary, uint16 nbOfRelease, uint256 totalAmount, uint128 periodicity);
    event resultOfRelease(address tokenAddress, address beneficiary, uint16 nbOfRelease, uint256 amountOfRelease);

    function version() public pure returns (string memory) {
    	   return "1.0";
    }

    function periodicLock(address tokenIn, address beneficiary, uint256 totalAmount, uint128 periodicity, uint16 numberOfRelease) public {
        require(_releaseData.length < (type(uint256).max)-1, "[timeLock] periodicLock : the service is full");
        uint256 balanceBefore = ERC20(tokenIn).balanceOf(address(this));
        require(ERC20(tokenIn).allowance(msg.sender, address(this)) >= totalAmount, "[timeLock] periodicLock : the allowance is insufficient");
        require(ERC20(tokenIn).transferFrom(msg.sender, address(this), totalAmount), "[timeLock] periodicLock : transfer failed");

        require((ERC20(tokenIn).balanceOf(address(this))-balanceBefore) >= totalAmount, "[timeLock] periodicLock : token not received");
        releaseData memory intReleaseData;
        
        intReleaseData.tokenAddress = tokenIn;
        intReleaseData.beneficiary = beneficiary;
        intReleaseData.totalAmount = totalAmount;
        intReleaseData.remainingAmount = totalAmount;
        intReleaseData.numberOfRelease = numberOfRelease;

        intReleaseData.releaseTime = new uint[](numberOfRelease);
        intReleaseData.state = new uint8[](numberOfRelease);

        intReleaseData.releaseTime[0] = block.timestamp + periodicity;
        intReleaseData.state[0] = STATE_ON_HOLD;
        for (uint8 i=1 ; i<numberOfRelease ; i++) {
            intReleaseData.releaseTime[i] = intReleaseData.releaseTime[i-1] + periodicity;
            intReleaseData.state[i] = STATE_ON_HOLD;
        }

        _releaseData.push(intReleaseData);
        
        emit requestForPeriodicLock(intReleaseData.tokenAddress, intReleaseData.beneficiary, intReleaseData.numberOfRelease, intReleaseData.remainingAmount, periodicity);
    }
    
    function release(uint256 index) public {
        require(index < _releaseData.length, "[timeLock] release : index is invalid");
        require(_releaseData[index].remainingAmount > 0, "[timeLock] release : no tokens to release");
        uint256 periodicAmount = _releaseData[index].totalAmount/_releaseData[index].numberOfRelease;
        uint256 amountOfRelease = 0;

        uint8 i;
        for (i=0 ; i<_releaseData[index].numberOfRelease ; i++) {
            if (_releaseData[index].state[i] != STATE_PERFORMED) {
                if (block.timestamp >= _releaseData[index].releaseTime[i]) {     /// Note : useless when state = 1 but reduces the code...  
                    amountOfRelease += periodicAmount;
                    _releaseData[index].state[i] = STATE_IN_PROGRESS;
                    if ((_releaseData[index].remainingAmount-amountOfRelease) < periodicAmount) {
                        amountOfRelease += _releaseData[index].remainingAmount-amountOfRelease;
                        break;
                    }
                } else {
                    break;
                }
            }
        }

        require(amountOfRelease > 0, "[timeLock] release : current time is before release time");
    
        ERC20(_releaseData[index].tokenAddress).transfer(_releaseData[index].beneficiary, amountOfRelease);

        /// The transfer succeeded, we update _releaseData
        _releaseData[index].remainingAmount -= amountOfRelease;

        uint16 nb = 0;
        for (i=0 ; i<_releaseData[index].numberOfRelease ; i++) {
            if (_releaseData[index].state[i] == STATE_IN_PROGRESS) {
                    _releaseData[index].state[i] = STATE_PERFORMED;
                    nb++;
            }
        }

        emit resultOfRelease(_releaseData[index].tokenAddress, _releaseData[index].beneficiary, nb, amountOfRelease);
    }

    function getDataIndex(address beneficiary) public view returns (uint256[] memory indexList) {
        uint256 j = 0;
        for (uint256 i=0 ; i<_releaseData.length ; i++) {
            if (_releaseData[i].beneficiary == beneficiary) {
                j++;
            }
        }

        indexList = new uint256[](j);
        j = 0;
        for (uint256 i=0 ; i<_releaseData.length ; i++) {
            if (_releaseData[i].beneficiary == beneficiary) {
                indexList[j] = i;
                j++;
            }
        }

        return (indexList);
    }

    function getDataSize() public view returns (uint256 size) {
        size = _releaseData.length;
        
        return (size);
    }

    function getData(uint256 index) public view returns (address token, string memory tokenSymbol, address beneficiary, uint256 totalAmount, uint256 remainingAmount, uint16 numberOfRelease) {
        require(index < _releaseData.length, "[timeLock] getData : there is no data at this location");

        return (_releaseData[index].tokenAddress, ERC20(_releaseData[index].tokenAddress).symbol(), _releaseData[index].beneficiary, _releaseData[index].totalAmount, _releaseData[index].remainingAmount, _releaseData[index].numberOfRelease);
    }
    
    function getPlanning(uint256 index, uint16 releaseIndex) public view returns (uint releaseTime, uint8 performed) {
        require(index < _releaseData.length, "[timeLock] getPlanning : there is no data at this location");

        return (_releaseData[index].releaseTime[releaseIndex], _releaseData[index].state[releaseIndex]);
    }
}