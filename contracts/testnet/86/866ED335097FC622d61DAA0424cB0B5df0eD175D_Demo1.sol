/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

contract Demo1 {
    event WithdrawReward(address usrAddr);

    function sfj()external{
        emit WithdrawReward(msg.sender);
    }
}