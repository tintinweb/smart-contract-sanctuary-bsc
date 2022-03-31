//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./IUniswapV2Router02.sol";
import "./IERC20.sol";
import "./Ownable.sol";

interface IFarm {
    function deposit(address token, uint256 amount) external;
}
contract FarmManager is Ownable {

    // Farm Structure
    struct Farm {
        bool isYieldFarm;
        address rewardToken;
        uint allocationPoints;
        uint index;
    }
    mapping ( address => Farm ) public yieldFarms;
    address[] public allYieldFarms;

    // Total Allocation Points For Farm Rewards
    uint256 public totalAllocationPoints;

    // total rewards
    uint256 public totalRewards;

    mapping ( address => uint256 ) tokenRewardsForFarm;
    mapping ( address => uint256 ) bnbRewardsForFarm;

    function numFarms() external view returns (uint256) {
        return allYieldFarms.length;
    }

    function getAllFarms() external view returns (address[] memory) {
        return allYieldFarms;
    }

    function getTotalRewardsForFarm(address farm) external view returns (uint256, uint256) {
        return (bnbRewardsForFarm[farm], tokenRewardsForFarm[farm]);
    }

    receive() external payable {}
    
    function distribute() external {

        if (address(this).balance < 10**15) {
            return;
        }

        totalRewards += address(this).balance;
        uint256[] memory distributions = _fetchDistribution(address(this).balance);
        for (uint i = 0; i < allYieldFarms.length; i++) {
            if (distributions[i] >= 10**8) {
                bnbRewardsForFarm[allYieldFarms[i]] += distributions[i];
                (bool s,) = payable(allYieldFarms[i]).call{value: distributions[i]}("");
                require(s);
            }
        }
        delete distributions;
    }

    function distribute(address token) external {
        uint256[] memory distributions = _fetchDistribution(IERC20(token).balanceOf(address(this)));
        for (uint i = 0; i < allYieldFarms.length; i++) {
            if (distributions[i] > 0) {
                (bool s) = IERC20(token).transfer(allYieldFarms[i], distributions[i]);
                require(s);
            }
        }
        delete distributions;
    }

    function donateToFarm(address token, address farm, uint256 amount) external {
        require(
            yieldFarms[farm].isYieldFarm,
            'Not Yield Farm'
        );

        IERC20(token).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        if (token == yieldFarms[farm].rewardToken) {
            tokenRewardsForFarm[farm] += amount;
        }

        IERC20(token).approve(farm, amount);
        IFarm(farm).deposit(token, amount);
    }


    /**
        Iterates through sources and fractions out amount
        Between them based on their allocation score
     */
    function _fetchDistribution(uint256 amount) internal view returns (uint256[] memory) {
        uint256[] memory distributions = new uint256[](allYieldFarms.length);
        for (uint i = 0; i < allYieldFarms.length; i++) {
            distributions[i] = ( amount * yieldFarms[allYieldFarms[i]].allocationPoints / totalAllocationPoints ) - 1;
        }
        return distributions;
    }


    function changeAllocation(address farm, uint newAllocation) external onlyOwner {
        require(
            yieldFarms[farm].isYieldFarm,
            'Not Yield Farm'
        );
        totalAllocationPoints = totalAllocationPoints - yieldFarms[farm].allocationPoints + newAllocation;
        yieldFarms[farm].allocationPoints = newAllocation;
    }

    function addYieldFarm(address farm, address rewardToken, uint allocation) external onlyOwner {
        require(
            !yieldFarms[farm].isYieldFarm,
            'Already Yield Farm'
        );

        yieldFarms[farm] = Farm({
            isYieldFarm: true,
            rewardToken: rewardToken,
            allocationPoints: allocation,
            index: allYieldFarms.length
        });

        totalAllocationPoints += allocation;

        allYieldFarms.push(farm);
    }

    function removeYieldFarm(address farm) external onlyOwner {
        require(
            yieldFarms[farm].isYieldFarm,
            'Not Yield Farm'
        );

        totalAllocationPoints -= yieldFarms[farm].allocationPoints;

        yieldFarms[
            allYieldFarms[allYieldFarms.length - 1]
        ].index = yieldFarms[farm].index;

        allYieldFarms[
            yieldFarms[farm].index
        ] = allYieldFarms[allYieldFarms.length - 1];

        allYieldFarms.pop();
        delete yieldFarms[farm];

    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }



}