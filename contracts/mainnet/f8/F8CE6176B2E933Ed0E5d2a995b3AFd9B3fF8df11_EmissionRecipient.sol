//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

interface IOPTX {
    function emitShares() external;
}

contract EmissionRecipient {

    address public immutable OPTX;

    address public monthlyPool;
    address public threeMonthlyPool;
    address public sixMonthlyPool;
    address public yearlyPool;

    uint256 public monthlyPoolRate = 52200000000; // 0.15% per day
    uint256 public threeMonthlyPoolRate = 87000000000; // 0.25% per day
    uint256 public sixMonthlyPoolRate = 175000000000; // 0.5% per day
    uint256 public yearlyPoolRate = 350000000000;  // 1% per day

    uint256 public lastReward;

    modifier onlyOwner() {
        require(
            msg.sender == IToken(OPTX).getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(address OPTX_) {
        lastReward = block.number;
        OPTX = OPTX_;
    }

    function resetEmissions() external onlyOwner {
        lastReward = block.number;
    }

    function setLastRewardStartTime(uint startBlock) external onlyOwner {
        lastReward = startBlock;
    }

    function setPools(
        address nMonthly,
        address nThreeMonthly,
        address nSixMonthly,
        address nYearly
    ) external onlyOwner {
        monthlyPool = nMonthly;
        threeMonthlyPool = nThreeMonthly;
        sixMonthlyPool = nSixMonthly;
        yearlyPool = nYearly;
    }

    function setRates(
        uint256 nMonthly,
        uint256 nThreeMonthly,
        uint256 nSixMonthly,
        uint256 nYearly
    ) external onlyOwner {
        monthlyPoolRate = nMonthly;
        threeMonthlyPoolRate = nThreeMonthly;
        sixMonthlyPoolRate = nSixMonthly;
        yearlyPoolRate = nYearly;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawAmount(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    function trigger() external {

        // amount to reward
        (
        uint month, uint threeMonth, uint sixMonth, uint year        
        ) = amountToDistribute();
        
        // reset timer
        lastReward = block.number;

        // send reward to the vault
        _send(monthlyPool, month);
        _send(threeMonthlyPool, threeMonth);
        _send(sixMonthlyPool, sixMonth);
        _send(yearlyPool, year);
    }

    function amountInPool(address pool) public view returns (uint256) {
        if (pool == address(0)) {
            return 0;
        }
        return IERC20(OPTX).balanceOf(pool);
    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function qtyPerBlock(address pool, uint256 dailyReturn) public view returns (uint256) {
        return ( amountInPool(pool) * dailyReturn ) / 10**18;
    }

    function amountToDistribute() public view returns (uint256, uint256, uint256, uint256) {
        uint nTime = timeSince();
        return(
            qtyPerBlock(monthlyPool, monthlyPoolRate) * nTime,
            qtyPerBlock(threeMonthlyPool, threeMonthlyPoolRate) * nTime,
            qtyPerBlock(sixMonthlyPool, sixMonthlyPoolRate) * nTime,
            qtyPerBlock(yearlyPool, yearlyPoolRate) * nTime
        );
    }

    function totalToDistributePerBlock() public view returns (uint256) {
        (uint m, uint t, uint s, uint y) = amountToDistribute();
        return m + t + s + y;
    }

    function totalToDistribute() external view returns (uint256) {
        return timeSince() * totalToDistributePerBlock();
    }

    function _send(address to, uint amount) internal {
        uint bal = IERC20(OPTX).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(OPTX).transfer(to, amount); 
    }
}