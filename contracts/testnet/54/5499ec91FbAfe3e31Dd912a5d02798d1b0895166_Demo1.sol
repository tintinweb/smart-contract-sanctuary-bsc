/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

contract Demo1 {
    event WithdrawReward(address addr1, address addr2);

    function sfj()external{
        emit WithdrawReward(msg.sender, address(this));
    }
}