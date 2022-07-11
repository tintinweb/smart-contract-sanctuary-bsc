/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8;

contract BaiTap2 {
    address _owner;
    uint256 maxStudent;
    uint256 price; 
    uint256 decimal = 18; // 1 BNB -> 1000000000000000000 Gwei;
    uint256 deadline;
    uint256 totalReceive = 0;
    uint256 totalWithdraw = 0;
    uint256 balance = 0;
    address payable withdrawAddress;
    mapping(address => bool) public whitelist;
    uint256 totalWhitelist = 0;
    mapping(address => bool) public paidlist;
    uint256 totalPaidlist = 0;

    modifier onlyOwner() {
        require(msg.sender == onwer(), "The caller is not owner");
        _;
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender] == true);
        _;
    }

    constructor(uint256 _maxStudent, uint256 _price, uint256 _deadline) {
        _owner = msg.sender;
        maxStudent = _maxStudent;
        price = _price;
        deadline = _deadline;
        withdrawAddress = payable(msg.sender);
    }

    function addWhitelist(address[] calldata _whitelist) external onlyOwner() {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            address wl = _whitelist[i];
            if (whitelist[wl] == false) {
                ++totalWhitelist;
            }
            whitelist[wl] = true;
        }
    }

    function removeWhitelist(address[] calldata _whitelist) external onlyOwner() {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            address wl = _whitelist[i];
            if (whitelist[wl] == true) {
                --totalWhitelist;
            }
            whitelist[wl] = false;
        }
    }

    receive() external payable onlyWhitelist {
        require(totalPaidlist <= maxStudent &&
                msg.value == price &&
                block.timestamp <= deadline &&
                paidlist[msg.sender] == false);

        paidlist[msg.sender] == true;
        ++totalPaidlist;
        totalReceive += msg.value;
        balance += msg.value;
    }

    function statistic() public view returns(uint256 _maxStudent,
                                             uint256 _totalWhitelist,
                                             uint256 _totalPaidlist,
                                             uint256 _price,
                                             uint256 _totalReceive) {
        return (maxStudent,
                totalWhitelist,
                totalPaidlist,
                price,
                totalReceive);
    }

    function withdraw(uint256 _amount) external onlyOwner() {
        require(_amount <= totalReceive, "The amount must be less than or equal contract balance");
        payable(msg.sender).transfer(_amount);
        balance -= _amount;
        totalWithdraw += _amount;
    }

    function onwer() public view virtual returns(address) {
        return _owner;
    }

}