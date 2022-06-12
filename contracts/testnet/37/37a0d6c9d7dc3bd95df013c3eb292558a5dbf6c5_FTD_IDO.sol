/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function mintToken(address _to, uint256 _value) external;
}


contract FTD_IDO {
    address public  owner;
    address public  administrator;
    mapping(string => uint) public datas;
    mapping(string => address) public dataAddress;
    mapping(address => uint) public subscribeMap; //是否认购
    event Subscribe(address _add, uint _qua);
    event Withdraw(address token, address user, uint amount, address to);

    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == administrator, "Permission denied");
        _;
    }
    constructor() {
        owner = msg.sender;
        administrator = msg.sender;
        datas["open"] = 1;
        datas["price"] = 100 * 1e18;
        dataAddress["USDT"] = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
        dataAddress["NFT"] = 0x54e4e2e8E14D4C6B7c637572dd2a951e3D658738;
        subscribeMap[msg.sender] = 1;
    }


    function changeOwner(address _add) external onlyOwner {
        require(_add != address(0));
        owner = _add;
    }

    function changeAdministrator(address _add) external onlyOwner {
        require(_add != address(0));
        administrator = _add;
    }

    function setDatas(string calldata _str, uint _val) external onlyOwner {
        datas[_str] = _val;
    }

    function setDataAddress(string calldata _str, address _add) external onlyOwner {
        dataAddress[_str] = _add;
    }

    function subscribe(uint _quantity,address _inviter) external {
        require(datas["open"] == 1, "IDO closed!");
        require(msg.sender != _inviter,"Can't invite yourself!");
        require(subscribeMap[_inviter] > 0,"Inviter not subscribed!");
        Token(dataAddress["USDT"]).transferFrom(msg.sender, address(this),_quantity * datas["price"]);
        Token(dataAddress["nft"]).mintToken(msg.sender,_quantity);
        subscribeMap[msg.sender] += _quantity;
    }

    function withdrawToken(address _token, address _add, uint _amount) external onlyOwner {
        Token(_token).transfer(_add, _amount);
        emit Withdraw(_token, msg.sender, _amount, _add);
    }
}