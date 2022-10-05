/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// 接口
interface ILinkedin {
    function mySuper(address user) external view returns (address);
    function myJuniors(address user) external view returns (address[] memory);
    function getSuperList(address user, uint256 list) external view returns (address[] memory);
}


contract Linkedin is ILinkedin {
    // 我的上级
    mapping (address => address) private _mySuper;
    // 我的下级
    mapping (address => address[]) private _myJuniors;
    

    constructor() {}


    // 绑定关系事件
    event BoundSuper(address my, address mySuper);
    

    // 绑定上级
    function bounSuper(address superAddress) external {
        address my = msg.sender;
        // 不能绑定自己
        require(superAddress != my, "not bound yourself");
        // 不能绑定合约
        require(!isContract(my), "you not contract");
        require(!isContract(superAddress), "super not contract");
        // 不能绑定0地址
        require(superAddress != address(0), "not bound zaro address");
        // 有上级也不能在绑定了
        require(_mySuper[my] == address(0), "haved super");

        // 30级别闭环验证
        address _s = _mySuper[superAddress];
        for(uint256 i; i < 30; i++) {
            require(_s != my, "closed cycle");
            _s = _mySuper[_s];
        }
        _mySuper[my] = superAddress;
        _myJuniors[superAddress].push(my);
        emit BoundSuper(my, superAddress);
    }

    // 判断是不是合约
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    // 查询上级
    function mySuper(address user) external view returns (address) {
        return _mySuper[user];
    }

    // 查询下级
    function myJuniors(address user) external view returns (address[] memory) {
        uint256 len = _myJuniors[user].length;
        address[] memory _juniors = new address[](len);
        for(uint256 i = 0; i < len; i++) {
            _juniors[i] = _myJuniors[user][i];
        }
        return _juniors;
    }

    // 查询连续的上级
    function getSuperList(address user, uint256 list) external view returns (address[] memory) {
        require(list > 0, "zero list error");
        address[] memory _supers = new address[](list);
        address _super = user;
        for(uint256 i = 0; i < list; i++) {
            _super = _mySuper[_super];
            _supers[i] = _super;
        }
        return _supers;
    }
    
}