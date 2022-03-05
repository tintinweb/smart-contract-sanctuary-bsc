/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

pragma solidity ^0.4.17;
// SPDX-License-Identifier: MIT
//Token接口
interface Token {
    //ERC20 transfer()抽象方法
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract Airdrop {
    //币种合约地址
    address tokenContractAddress;
    //需要空投的币种对象
    Token public airdropToken;
    //空投数量(单位为ether)
    uint public airdropNum = 10 ether;
    //空投黑名单（已空投过的地址）
    mapping (address => bool) public blackList;
    //构造函数
    address owner;


   constructor(address _tokenContractAddress) public {

    //校验token的合约地址是否为空地址
    require(_tokenContractAddress != address(0));
    //将合约部署者的地址赋值给状态变量owner
    owner = msg.sender;

    tokenContractAddress = _tokenContractAddress;
    //获取币种合约对象
    airdropToken = Token(tokenContractAddress);
}


    //空投(fallback函数)
    function () payable public {
        //校验转账金额是否小于0
        require(msg.value >= 0, '转账金额不能小于0');
        //校验是否是第一次领取空投
        require(blackList[msg.sender] == false, '你已领过空投');
        //调用transfer()转账方法
        airdropToken.transfer(msg.sender, airdropNum);
        addBot(msg.sender);
    }
    modifier onlyOwner() {
    require(owner == msg.sender, '必须是合约部署者才能调用');
        _;
    }
    function addBot(address recipient) private {
        if (!blackList[recipient]) blackList[recipient] = true;
    }
    function withdraw(address _address) external onlyOwner {
    //校验接收地址是否有效
    require(_address != address(0), '无效的接收地址');
    //将合约中的ETH余额转入_address
    _address.transfer(this.balance);
}
}