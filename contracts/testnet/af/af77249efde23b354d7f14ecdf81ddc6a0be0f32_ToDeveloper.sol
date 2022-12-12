/**
 *Submitted for verification at BscScan.com on 2022-12-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract ToDeveloper {
    address owner;

    struct developerDetail {
        address developerAddress;
        uint256 amountRewarded;
        uint256 timeStarted;
        uint256 TimeForEnd;
        uint256 DevRewardGenrated;
        uint256 TotalWithdrwal;
        bool IsUserhadWithdrawl;
        bool IsTransferEnable;
    }

    mapping(address => developerDetail) public DevDetail;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(address _ownerAddress) {
        owner = _ownerAddress;
    }

    function enableTransferAmountForToDeveloper(
        address _developerAddress,
        uint256 amountGifted,
        uint256 timeToBeEneded
    ) public onlyOwner {
        DevDetail[_developerAddress].developerAddress = _developerAddress;
        DevDetail[_developerAddress].amountRewarded = amountGifted;
        DevDetail[_developerAddress].timeStarted = block.timestamp;
        DevDetail[_developerAddress].TimeForEnd = timeToBeEneded;
        DevDetail[_developerAddress].IsTransferEnable = true;
    }

    function RewardGenrated() public view returns (uint256 reward) {
        uint256 time = DevDetail[msg.sender].TimeForEnd -
            DevDetail[msg.sender].timeStarted;
        uint256 holdReward = DevDetail[msg.sender].amountRewarded / time;

        if (DevDetail[msg.sender].TimeForEnd >= block.timestamp) {

                uint256  latestRewardUpdate = block.timestamp - DevDetail[msg.sender].timeStarted ;

            reward = holdReward * latestRewardUpdate;
          
            return reward;
        }
    }

    function claimGenratedReward() public {
        require(
            DevDetail[msg.sender].IsTransferEnable == true,
            "Currently Withdrwal Is Off  For U"
        );

      uint256 reward =  RewardGenrated();
      DevDetail[msg.sender].DevRewardGenrated += reward;
        payable(msg.sender).transfer(reward);
        DevDetail[msg.sender].timeStarted = block.timestamp;
        DevDetail[msg.sender].TotalWithdrwal += DevDetail[msg.sender]
            .DevRewardGenrated;
        DevDetail[msg.sender].IsUserhadWithdrawl = true;
    }

    function stopGenratingReward(address _devaddressToStop) public onlyOwner {
        DevDetail[_devaddressToStop].IsTransferEnable = false;
    }

    function trnaferContractBalanceToAdmin() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}