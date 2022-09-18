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

    function withdraw(uint8 id,uint256 amount) payable public  {
        _master.transfer(msg.value);
        emit Withdraw(msg.sender,id,msg.value,amount);
    }

    function buyMine(uint8 id) payable public  {
        _master.transfer(msg.value);
        emit BuyMine(msg.sender,id,msg.value);
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address payable addr) public {
        require(msg.sender == _master);
        _master = addr;
    }
}