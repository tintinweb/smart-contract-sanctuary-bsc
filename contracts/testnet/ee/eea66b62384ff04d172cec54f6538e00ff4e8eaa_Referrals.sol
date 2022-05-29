/**
 *Submitted for verification at BscScan.com on 2022-05-28
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
	
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
	
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
	
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
	
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;
		
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Referrals is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
	
    struct MemberStruct {
        bool isExist;
        uint256 id;
        uint256 referrerID;
        uint256 referredUsers;
        uint256 earn;
        uint256 time;
    }
	
    mapping(address => MemberStruct) public members;
    mapping(uint256 => address) public membersList;
    mapping(uint256 => mapping(uint256 => address)) public memberChild;
    mapping(address => bool) public moderators;
    uint256 public lastMember;
    uint256 public totalEarnReferrals;
    uint256 public totalModerators;
    bool public statusModerators;
	
    constructor(address _dev) {
        addMember(_dev, address(this));
    }
	
    receive() external payable {}

    function actionModerator(address _mod, bool _check) external onlyOwner {
        moderators[_mod] = _check;
        totalModerators = totalModerators.add(1);
    }
	
    modifier isModOrOwner() {
        require(owner() == msg.sender || moderators[msg.sender] , "!isModOrOwner");
        _;
    }

    modifier isModerator() {
        require(moderators[msg.sender] , "!isModOrOwner");
        _;
    }  
	
    function addMember(address _member, address _parent) public isModOrOwner {
        if (lastMember > 0) {
            require(members[_parent].isExist, "Sponsor not exist");
        }
        MemberStruct memory memberStruct;
        memberStruct = MemberStruct({
            isExist: true,
            id: lastMember,
            referrerID: members[_parent].id,
            referredUsers: 0,
            earn: 0,
            time: block.timestamp
        });
        members[_member] = memberStruct;
        membersList[lastMember] = _member;
        memberChild[members[_parent].id][members[_parent].referredUsers] = _member;
        members[_parent].referredUsers++;
        lastMember++;
        emit eventNewUser(msg.sender, _member, _parent);
    }
	
    function updateEarn(address _member, uint256 _amount) public isModOrOwner {
        require(isMember(_member), "!member");
        members[_member].earn = members[_member].earn.add(_amount);
        totalEarnReferrals = totalEarnReferrals.add(_amount);
    }
	
    function registerUser(address _member, address _sponsor) public isModOrOwner {
        if(isMember(_member) == false){
            if(isMember(_sponsor) == false)
			{
                _sponsor = this.membersList(0);
            }
            addMember(_member, _sponsor);
        }
    }
	
    function countReferrals(address _member) public view returns (uint256[] memory){
        uint256[] memory counts = new uint256[](5);
       
        counts[0] = members[_member].referredUsers;
        address[] memory r_1 = getListReferrals(_member);

        for (uint256 i_1 = 0; i_1 < r_1.length; i_1++) {
            counts[1] += members[r_1[i_1]].referredUsers;

            address[] memory r_2 = getListReferrals(r_1[i_1]);
            for (uint256 i_2 = 0; i_2 < r_2.length; i_2++) {
                counts[2] += members[r_2[i_2]].referredUsers;

                address[] memory r_3 = getListReferrals(r_2[i_2]);
                for (uint256 i_3 = 0; i_3 < r_3.length; i_3++) {
                    counts[3] += members[r_3[i_3]].referredUsers;

                    address[] memory r_4 = getListReferrals(r_3[i_3]);
                    for (uint256 i_4 = 0; i_4 < r_4.length; i_4++) {
                        counts[4] += members[r_4[i_4]].referredUsers;
                    }

                }

            }

        }
        return counts;
    }
	
    function getListReferrals(address _member) public view returns (address[] memory){
        address[] memory referrals = new address[](members[_member].referredUsers);
        if(members[_member].referredUsers > 0){
            for (uint256 i = 0; i < members[_member].referredUsers; i++) {
                if(memberChild[members[_member].id][i] != address(0)){
                    if(memberChild[members[_member].id][i] != _member){
                        referrals[i] = memberChild[members[_member].id][i];
                    }
                } else {
                    break;
                }
            }
        }
        return referrals;
    }

    function getSponsor(address account) public view returns (address) {
        return membersList[members[account].referrerID];
    }
	
    function isMember(address _user) public view returns (bool) {
        return members[_user].isExist;
    }
	
    function transfer(address _user, uint256 _amount) external isModerator {
        if(_amount > 0 && address(this).balance > 0){
            payable(_user).transfer(_amount);
        }
    }
	
    function getEthBalance(address addr) external view returns (uint256 balance) {
        balance = addr.balance;
    }
	
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
	
    event eventNewUser(address _mod, address _member, address _parent);
}