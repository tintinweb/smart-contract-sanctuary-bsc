/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function AddRewards(uint _amount) external returns(bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract LockupVault {

    IBEP20 public kinectAddress = IBEP20(0x0ED74270c058Fe588d5a56Ed49a47E1a8db136E6);
    IBEP20 public dividendVaultAddress = IBEP20(0x099b0D74b2ECa9EF3cf9337d32d44C3C24d2B17E);

    uint256 public lastPayout;
    uint256 public payoutRate = 5; //5% a day
    uint256 public distributionInterval = 3600;

    // Events
    event RewardsDistributed(uint256 rewardAmount);
    event UpdatePayoutRate(uint256 payout);
    event UpdateDistributionInterval(uint256 interval);

    constructor(IBEP20 _dividendVaultAddress){
        dividendVaultAddress = _dividendVaultAddress;
        lastPayout = block.timestamp;
    }

    function payoutDivs() public {
        uint256 dividendBalance = IBEP20(kinectAddress).balanceOf(address(this));

        if (block.timestamp - lastPayout > distributionInterval && dividendBalance > 0) {

            //A portion of the dividend is paid out according to the rate
            uint256 share = dividendBalance * payoutRate / 100 / 24 hours;
            //divide the profit by seconds in the day
            uint256 profit = share * (block.timestamp - lastPayout);

            if (profit > dividendBalance){
                profit = dividendBalance;
            }

            lastPayout = block.timestamp;

            dividendVaultAddress.AddRewards(profit);

            emit RewardsDistributed(profit);

        }
    }

}