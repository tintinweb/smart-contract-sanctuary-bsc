//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";

interface IToken {
    function getOwner() external view returns (address);
    function burn(uint256 amount) external returns (bool);
}

contract EmissionRecipient {

    address public immutable accumulator;

    address public pool;

    uint256 public rate = 700000000000;  // 2% per day

    uint256 public lastReward;

    modifier onlyOwner() {
        require(
            msg.sender == IToken(accumulator).getOwner(),
            'Only Owner'
        );
        _;
    }

    constructor(address accumulator_) {
        lastReward = block.number;
        accumulator = accumulator_;
    }

    function resetEmissions() external onlyOwner {
        lastReward = block.number;
    }

    function setLastRewardStartTime(uint startBlock) external onlyOwner {
        lastReward = startBlock;
    }

    function setPools(
        address pool_
    ) external onlyOwner {
        pool = pool_;
    }

    function setRates(
        uint rate_
    ) external onlyOwner {
        rate = rate_;
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
        uint amount
        ) = amountToDistribute();
        
        // reset timer
        lastReward = block.number;

        // send reward to the vault
        _send(pool, amount);
        
    }

    function amountInPool(address pool_) public view returns (uint256) {
        if (pool_ == address(0)) {
            return 0;
        }
        return IERC20(accumulator).balanceOf(pool_);
    }

    function timeSince() public view returns (uint256) {
        return lastReward < block.number ? block.number - lastReward : 0;
    }

    function qtyPerBlock(address pool_, uint256 dailyReturn) public view returns (uint256) {
        return ( amountInPool(pool_) * dailyReturn ) / 10**18;
    }

    function amountToDistribute() public view returns (uint256) {
        uint nTime = timeSince();
        return(
            qtyPerBlock(pool, rate) * nTime
        );
    }

    function _send(address to, uint amount) internal {
        uint bal = IERC20(accumulator).balanceOf(address(this));
        if (amount > bal) {
            amount = bal;
        }
        if (amount == 0) {
            return;
        }
        IERC20(accumulator).transfer(to, amount); 
    }
}