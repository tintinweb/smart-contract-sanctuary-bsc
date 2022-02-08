/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity  0.8.0;
//SPDX-License-Identifier:UNLICENSED

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
}

contract diamondGame {
    address owner;  //合约所有者
    address administrator; //管理员
    address payable register_address = payable(0x550027328283bF936CBe6D91fB2F4b405Cf45f0E);
    uint  register_fee = 30000000000000000;

    event Register(address _add, address _invite, uint _quantity);

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == administrator, "Permission denied");
        _;
    }

    constructor() {
        owner = msg.sender;
        administrator = msg.sender;
    }

    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }

    function setRegister(address payable _add, uint _qua) external onlyOwner {
        register_address = _add;
        register_fee = _qua;
    }

    //注册
    function register(address _invite) public payable {
        address payable sender = payable(msg.sender);
        register_address.transfer(register_fee);
        if (msg.value > register_fee) {
            sender.transfer(msg.value - register_fee);
        }
        emit Register(msg.sender, _invite, register_fee);
    }
}