/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Team {
    // 管理员
    address public _owner;
    modifier Owner() {
        require(_owner == msg.sender);
        _;
    }
    // 白名单
    address private _WhiteListContract;
    modifier WhiteList() {
        require(_WhiteListContract == msg.sender);
        _;
    }
    // 顶级
    address public lord;
    mapping(address => address) private _team;
    mapping(address => bool) public _WhetherBoughtGold;

    event Bind(address _from, address to_);

    constructor(address lord_) {
        lord = lord_;
        _team[lord_] = lord_;
        _WhetherBoughtGold[lord_] = true;
        _owner = msg.sender;
    }

    // 修改管理员
    function setOwner(address owner_) public Owner returns (bool) {
        _owner = owner_;
        return true;
    }

    // 修改白名单
    function setWhiteListContract(address WhiteListContract_)
        public
        Owner
        returns (bool)
    {
        _WhiteListContract = WhiteListContract_;
        return true;
    }

    // 当前中介白名单
    function WhiteListContract() public view returns (address) {
        return _WhiteListContract;
    }

    // 返回上级
    function team(address from_) public view returns (address) {
        return _team[from_];
    }

    // 绑定上级
    function bindParent(address to_) public returns (bool) {
        require(
            msg.sender != to_,
            "Team: The binding address is your own address"
        );
        require(to_ != address(0), "Team: The binding address is zero");
        require(
            _WhetherBoughtGold[to_],
            "Team: Address changed but NFT was not purchased"
        );
        require(
            _verify_leader_valid(msg.sender, to_),
            "Team: Failed to bind parent-child relationship"
        );
        _team[msg.sender] = to_;
        emit Bind(msg.sender, to_);
        return true;
    }

    // 设置
    function setWhetherBoughtGold(address owner_)
        public
        WhiteList
        returns (bool)
    {
        _WhetherBoughtGold[owner_] = true;
        return true;
    }

    function _verify_leader_valid(address from, address to)
        internal
        view
        returns (bool)
    {
        address to_leader = team(to);
        if (to_leader == address(0) || to_leader == lord) {
            return true;
        }
        if (to_leader == from) {
            return false;
        }
        return _verify_leader_valid(from, to_leader);
    }
}