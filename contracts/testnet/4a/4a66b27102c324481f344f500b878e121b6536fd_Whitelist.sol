/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
contract Whitelist {
    mapping(address => bool) whitelists;
    mapping(string => uint) activeCodes;
    address owner;
    uint public time;
    constructor() {
        owner = msg.sender;
				
	// 合约部署后，将管理员自己添加到白名单
        whitelists[msg.sender] = true;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "should be owner");
        _;
    }
    // 判断 user 是否在白名单里，仅管理员有权限
    function isUserInWhitelist(address user) public onlyOwner view returns (bool) {
        return whitelists[user];
    }

    //获取当前区块时间
    function getDate() public{
        time=block.timestamp;
    }

    /*function getActiveCodes() public{
        aCodes= activeCodes;
    }*/

    // 判断自己是否在白名单里
    // 前端在调用合约的时候，用来判断自己是不是在白名单里，从而可以控制是否显示 mint 按钮
    function amIInWhitelist() public view returns (bool) {
        return isUserInWhitelist(msg.sender);
    }
    // 添加 user 到白名单里，仅管理员有权限
    function addToWhitelist(address user) public onlyOwner {
        whitelists[user] = true;
    }
    // 从白名单里移除 user，仅管理员有权限
    function removeFromWhitelist(address user) public onlyOwner {
        whitelists[user] = false;
    }

    //只有白名单里的地址可以对使用软件进行添加激活码与时间期限 1665244800 1667923200 2,678,400
    function AcodeAddManager(string memory code,uint codeTime) public {
        require(whitelists[msg.sender], "user not in whitelist");
        activeCodes[code]=codeTime;
    }
    //只有白名单里的地址可以对使用软件进行删除激活码与时间期限 1665244800 1667923200 2,678,400
    function AcodeRemoveManager(string memory code) public {
        require(whitelists[msg.sender], "user not in whitelist");
        delete activeCodes[code]; 
        
    }
    //返回时间
    function CodeDate(string memory code) public view returns(uint)
    {       
        return activeCodes[code];
    }
}