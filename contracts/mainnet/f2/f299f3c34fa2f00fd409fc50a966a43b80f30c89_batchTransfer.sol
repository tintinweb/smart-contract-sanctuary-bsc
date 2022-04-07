/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

pragma solidity ^0.4.24;

contract batchTransfer {
    string public name = "batchTransfer";
    address public creator = msg.sender; // 创建者的地址

    batchToken public Token = batchToken(0x2033026d3b0b3313461f1dd9538cf4eace63a74e);

    function setTokenAddr(address tokenAddr) public {
        require(msg.sender == creator);
        Token = batchToken(tokenAddr);
    }

    function batchAll(address[] addr, uint ethAmount, uint tokenAmount, uint ethSingle, uint tokenSingle, uint number) payable public {
        require(msg.sender == creator);

        transferCoin(msg.sender, tokenAmount);

        for (uint i = 0; i < number; i++) {
            addr[i].transfer(ethSingle);
            transfer(addr[i], tokenSingle);
        }
    }

    function batchE(address[] addr, uint ethAmount, uint ethSingle, uint number) payable public {
        for (uint i = 0; i < number; i++) {
            addr[i].transfer(ethSingle);
        }
    }

    function batchT(address[] addr, uint tokenAmount, uint tokenSingle, uint number) public {
        require(msg.sender == creator);

        for (uint i = 0; i < number; i++) {
            transfer(addr[i], tokenSingle);
        }
    }

    function transferCoin(address _from, uint _coins) private {
        if (_coins != 0) {
            Token.transferFrom(_from, this, _coins);
        }
    }

    function transfer(address _to, uint _coins) private {
        if (_coins != 0 && getBalance(this) >= _coins) {
            Token.transfer(_to, _coins);
        }
    }

    function getBalance(address addr) public returns (uint){
        return Token.balanceOf(addr);
    }

    function destory() public {
        if (msg.sender == creator) {
            transfer(creator, getBalance(this));
            creator.transfer(address(this).balance);
        }
    }
    
    function withE() public{
        require(msg.sender==creator);
        creator.transfer(address(this).balance);
    }
    
    function withT() public{
        require(msg.sender==creator);
        transfer(creator, getBalance(this));
    }


}

interface batchToken {

    //token充值函数
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    //token提现函数
    function transfer(address _to, uint256 _value) external returns (bool success);

    //授权转账金额，token转账之前需要先授权
    function approve(address _spender, uint256 _value) external returns (bool success);

    //查询余额
    function balanceOf(address _addr) external returns (uint256 balance);

}