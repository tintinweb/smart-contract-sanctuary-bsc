/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFaucet { 
    function users(address _addr) external view returns (address upline, uint256 referrals, uint256 total_structure, uint256 direct_bonus, uint256 match_bonus, uint256 deposits, uint256 deposit_time, uint256 payouts, uint256 rolls, uint256 ref_claim_pos, uint256 accumulatedDiv);
    function isNetPositive(address _addr) external view returns (bool);
    function creditsAndDebits(address _addr) external view returns (uint256 _credits, uint256 _debits);
    function isBalanceCovered(address _addr, uint8 _level) external view returns (bool);
    function balanceLevel(address _addr) external view returns (uint8);
    function claimsAvailable(address _addr) external view returns (uint256);
    function payoutOf(address _addr) external view returns(uint256 payout, uint256 max_payout, uint256 net_payout, uint256 sustainability_fee);
    function userInfo(address _addr) external view returns(address upline, uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 direct_bonus, uint256 match_bonus, uint256 last_airdrop);
    function userInfoTotals(address _addr) external view returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure, uint256 airdrops_total, uint256 airdrops_received);
    function contractInfo() external view returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_bnb, uint256 _total_txs, uint256 _total_airdrops);
}

interface IBR34P {
    function balanceOf(address who) external view returns (uint256);
}

contract FaucetReaderV2 {
    IFaucet faucet = IFaucet(0xFFE811714ab35360b67eE195acE7C10D93f89D8C);
    IBR34P br34p = IBR34P(0xa86d305A36cDB815af991834B46aD3d7FbB38523);
    address dev = 0xe8e9720e39e13854657c165CF4eB10b2dfE33570;

    struct UserInfoTotals{
        uint256 referrals; 
        uint256 total_deposits;
        uint256 total_payouts;
        uint256 total_structure;
        uint256 airdrops_total;
        uint256 airdrops_received;
    }

    struct UserInfo{
        address upline;
        uint256 deposit_time;
        uint256 deposits;
        uint256 payouts;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 last_airdrop;
    }

    function getUserInfoTotals(address _addr) internal view returns (UserInfoTotals memory value){
        (uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure, uint256 airdrops_total, uint256 airdrops_received) = faucet.userInfoTotals(_addr);
        value.referrals = referrals;
        value.total_payouts = total_payouts;
        value.total_deposits = total_deposits;
        value.total_structure = total_structure;
        value.airdrops_total = airdrops_total;
        value.airdrops_received = airdrops_received;
    }

    function getUserInfo(address _addr) internal view returns (UserInfo memory value){
        (address upline, uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 direct_bonus, uint256 match_bonus, uint256 last_airdrop) = faucet.userInfo(_addr);
        value.upline = upline;
        value.deposits = deposits;
        value.payouts = payouts;
        value.direct_bonus = direct_bonus;
        value.match_bonus = match_bonus;
        value.last_airdrop = last_airdrop;
        value.deposit_time = deposit_time;
    }

    function isUplineRewardAllowed(address uplineAddr, uint8 level) internal view returns (bool){
        bool br34pBalanceCovered = faucet.isBalanceCovered(uplineAddr, level);
        bool isNetPositive = faucet.isNetPositive(uplineAddr);

        return br34pBalanceCovered && isNetPositive;
    }
   
    function getFullPlayerDetail(address _addr) external view returns (uint256 claimsAvailable, uint256 br34pBalance, uint256 ref_claim_pos, uint256[] memory userStats, address[] memory uplines, bool[] memory uplinesRewardsAllowed, address nextUplineRewarded) {
        UserInfoTotals memory userInfoTotals;
        UserInfo memory userInfo;
        uint256 rolls;

        claimsAvailable = faucet.claimsAvailable(_addr);
        br34pBalance = br34p.balanceOf(_addr);
        
        userInfo = getUserInfo(_addr);
        userInfoTotals = getUserInfoTotals(_addr);
        (, , , , , , , , rolls, ref_claim_pos, ) = faucet.users(_addr);
        

        userStats = new uint256[](12);
        userStats[0] = userInfo.deposits;
        userStats[1] = userInfo.payouts;
        userStats[2] = userInfo.direct_bonus;
        userStats[3] = userInfo.match_bonus;
        userStats[4] = userInfo.last_airdrop;
        userStats[5] = userInfo.deposit_time;
        userStats[6] = userInfoTotals.referrals;
        userStats[7] = userInfoTotals.total_structure;
        userStats[8] = userInfoTotals.airdrops_total;
        userStats[9] = userInfoTotals.airdrops_received;
        userStats[10] = rolls;
        userStats[11] = userInfoTotals.total_payouts;


        uplines = new address[](15);
        uplinesRewardsAllowed = new bool[](15);
 
        address currentUpline = _addr;
        for(uint8 level = 0; level < 15; level++) {
            currentUpline = getUserInfo(currentUpline).upline;

            if(currentUpline == 0x0000000000000000000000000000000000000000){
                break;
            }

            uplinesRewardsAllowed[level] = isUplineRewardAllowed(currentUpline, level);
            uplines[level] = currentUpline;
        }

        for(uint256 level = ref_claim_pos; level < level + 15; level++){
            uint256 position = ref_claim_pos % 15;
            if(uplinesRewardsAllowed[position]){
                nextUplineRewarded = uplines[position];
                break;
            }
        }
    }

}