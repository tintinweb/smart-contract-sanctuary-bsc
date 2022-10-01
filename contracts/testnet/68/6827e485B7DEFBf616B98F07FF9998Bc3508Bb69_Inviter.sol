/**
 *Submitted for verification at BscScan.com on 2022-10-01
*/

//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

contract Inviter {
    /**
     * 对应上级地址
     */
    mapping(address => address) public parentOf;

    /**
     * 对应下级地址列表
     */
    mapping(address => address[]) public childsOf;

    /**
     * 成员
     */
    mapping(address => uint) memberOf;

    /**
     * 持有伞下用户数量
     */
    mapping(address => uint) public accountAmountOf;

    /**
     * 所有成员
     */
    address[] public memberList;

    // define events
    event Invested(address parent, address member);

    /**
     * 绑定邀请地址
     * @param _account 上级地址
     */
    function invest(address _account) public {
        // require(memberOf[_account] == 1, "1101");
        require(memberOf[msg.sender] == 0, "1110");
        memberOf[msg.sender] = 1;
        parentOf[msg.sender] = _account;
        childsOf[_account].push(msg.sender);
        memberList.push(msg.sender);
        accountAmountOf[_account]++;
        emit Invested(_account, msg.sender);
    }

    /**
     * 是属于成员
     */
    function isMember(address _account) public view returns (bool) {
        return memberOf[_account] == 1;
    }

    /**
     * 通过索引查询会员地址
     * @param _index 索引位
     */
    function getMemberByIndex(uint256 _index) public view returns (address) {
        return memberList[_index];
    }

    /**
     * 计算会员总数
     */
    function getMemberCount() public view returns (uint256) {
        return memberList.length;
    }
}