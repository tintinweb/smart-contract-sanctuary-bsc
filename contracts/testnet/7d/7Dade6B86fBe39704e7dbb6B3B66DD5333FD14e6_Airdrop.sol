/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

pragma solidity ^0.4.26;

interface Token {
    //ERC20 transfer()抽象方法
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract Airdrop {
    address tokenContractAddress;
    Token public airdropToken;
    uint public airdropNum = 10 ether;
    mapping (address => bool) public blackList;
    address owner;
   constructor(address _tokenContractAddress) public {
    require(_tokenContractAddress != address(0));
    owner = msg.sender;

    tokenContractAddress = _tokenContractAddress;
    airdropToken = Token(tokenContractAddress);
}
    //空投(fallback函数)
    function () payable public {
        require(msg.value >= 0, '转账金额不能小于0');
        require(blackList[msg.sender] == false, '你已领过空投');
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
    require(_address != address(0), '无效的接收地址');
    _address.transfer(this.balance);
}
}