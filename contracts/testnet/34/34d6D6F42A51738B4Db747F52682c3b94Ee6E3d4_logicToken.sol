/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
interface IERC20{
    function allowance(address _owner,address _spender) external view returns(uint256 remaining);
    function transfer(address _to,uint256 _value) external  returns(bool success);
    function transferFrom(address _from,address _to,uint256 _value) external returns(bool success);
} 
contract logicToken{

    //  https://testnet.bscscan.com/token/0xcdd10C8A98c041F8a8e53565CeCEc3227fBbc482  测试链token地址
    address public usdtToken = 0xcdd10C8A98c041F8a8e53565CeCEc3227fBbc482; 
    
    mapping(address => uint) uBalance;   //哪个地址充值了多少USDT到合约

    uint public itotalperiod;  //总共多少期
     
     struct UserInfo{
         uint key;
         address addr;       //地址
         uint amount;       //金额
         uint blockChain;   //记录区块
     }
     //这个hash 记录的列表数据  可以循环itotalperiod 这个从1开始 作为key 读取列表
     mapping(uint => UserInfo)  UserInfoList;  //记录hash

    function setusdtToken(address _token) public {
        usdtToken = _token;
    }
     //充值U   传入充值数量
     function rechargeU(uint _amount) public {
        require(IERC20(usdtToken).allowance(msg.sender,address(this)) >= _amount,"please  approve ");
        uBalance[msg.sender] = uBalance[msg.sender] + _amount;
     }
     //提现U    传入提现数量
     function withdrawU(uint _amount) public {
        require(uBalance[msg.sender] >= _amount, "falied ");
        IERC20(usdtToken).transfer(msg.sender,_amount); 
     }
     //写入记录
     function setUserInfo(address _addr,uint _amount) public {
         itotalperiod = itotalperiod + 1;
         UserInfo storage user = UserInfoList[itotalperiod];
         user.key = itotalperiod;
         user.addr = _addr;
         user.amount = _amount;
         user.blockChain = block.number;
     }

}