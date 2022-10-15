/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IFactory{
    function allPairs(uint pid) external returns(address pairAddress);
    function allPairsLength() external returns(uint allPairsLength);
    function setDevFee(address pair, uint8 fee) external;
    function setSwapFee(address pair, uint32 fee) external;
    function setFeeToSetter(address newFeeToSetter) external;
}

interface IPair{
    function devFee() external returns(uint32 fee);
    function swapFee() external returns(uint32 fee);
}

contract FactoryAdmin{
    address public constant LITTLERABBIT_DEPLOYER = 0xe44E3f7bf371F0eF20B5721ad0da8739655132fD;
    IFactory public constant FACTORY = IFactory(0x1De61197F8ac147DDc5652F50161c2c39428898E);
    uint8  public constant NEW_DEV_FEE  = 3;
    uint32 public constant NEW_SWAP_FEE = 2;
    event FeeUpdated(address pair, uint8 newDevFee, uint32 newSwapFee);

    modifier onlyDeployer{
        require(msg.sender == LITTLERABBIT_DEPLOYER, '!deployer');
        _;
    }

    function updateFeeBulk(uint firstPID, uint count) external onlyDeployer{
        require(count > 0, 'Nothing to update');
        uint allPairsLength = FACTORY.allPairsLength();
        require(firstPID < allPairsLength, 'overflow');
        uint to = allPairsLength < firstPID + count ? allPairsLength : firstPID + count;

        for (uint currentPid = firstPID; currentPid < to; currentPid++){
            updateFee(FACTORY.allPairs(currentPid));
        }
    }

    function updateFee(address pair) public onlyDeployer{
        FACTORY.setDevFee(pair, NEW_DEV_FEE);
        FACTORY.setSwapFee(pair, NEW_SWAP_FEE);
        emit FeeUpdated(pair, NEW_DEV_FEE, NEW_SWAP_FEE);
    }

    function updateFeeManual(address pair, uint8 _devFee, uint32 _swapFee) external onlyDeployer{
        FACTORY.setDevFee(pair, _devFee);
        FACTORY.setSwapFee(pair, _swapFee);
        emit FeeUpdated(pair, _devFee, _swapFee);
    }

    function exit() external onlyDeployer{
        FACTORY.setFeeToSetter(LITTLERABBIT_DEPLOYER);
    }
}