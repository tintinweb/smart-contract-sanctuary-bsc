/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

pragma solidity ^0.8.13;

contract MDTv1_refund {
    address MDTv1_address = 0x24436520c319695E8c435Ea32Aa275f55E2a3F07;
    function setAddress(address _MDTv1_address) external{
        MDTv1_address = _MDTv1_address;
    }
    function getUserInfoTotals(address _address) external view returns(bool elegible) {
        MDTv1 mdtv1 = MDTv1(MDTv1_address);
        (, uint256 total_deposits, uint256 total_payouts, , , ,) = mdtv1.userInfoTotals(_address);
        if(total_deposits - total_payouts > 0) {
            return true;
        } else {
            return false;
        }
    }
}
interface MDTv1 {
    function userInfoTotals(address _addr) external pure returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure,uint256 total_downline_deposit, uint256 airdrops_total, uint256 airdrops_received);
}