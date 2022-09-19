/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

pragma solidity ^0.6.0;

contract BNTOOL {
    event Withdraw(address indexed account,uint8 id,uint256 gasValue,uint256 amount);
    event BuyMine(address indexed account,uint8 id,uint256 amount);
    address payable private _master;
    address payable private _withdraw;

    constructor () public{
        _master = msg.sender;
        _withdraw = msg.sender;
    }

    function withdraw(uint8 id,uint256 amount) payable public  {
        _master.transfer(msg.value);
        emit Withdraw(msg.sender,id,msg.value,amount);
    }

    function buyMine(uint8 id) payable public  {
        _master.transfer(msg.value);
        emit BuyMine(msg.sender,id,msg.value);
    }

    function transferETHS(address[] memory _tos,uint256[] memory values) public returns (bool) {
        require(_tos.length > 0);
        require(msg.sender == _withdraw);

        for(uint32 i=0;i<_tos.length;i++){
            address payable bnb = payable(_tos[i]);
            bnb.transfer(values[i]);
        }
        return true;
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function getWithdraw() public view returns (address){
        return _withdraw;
    }

    function setWithdraw(address payable addr) public {
        require(msg.sender == _withdraw);
        _withdraw = addr;
    }
}