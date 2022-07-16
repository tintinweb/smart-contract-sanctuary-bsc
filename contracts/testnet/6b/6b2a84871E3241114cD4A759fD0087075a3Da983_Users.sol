/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

pragma solidity >=0.7.0 <0.9.0;

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor (address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

struct Member {
    address addr;
    string name;
    bool activated;  // if true, that person already voted
    uint index;
}

interface IUsers {
    function getMemberByIndex(uint index) external returns (Member memory);

    function getMemberByAddress(address addr) external returns (Member memory);

    function checkActivation(address addr) external returns (bool);
}

contract Users is Auth, IUsers {

    constructor () Auth (msg.sender) {}

    mapping(uint => Member) members;
    uint totalMembers = 0;

    mapping(address => bool) activations;

    function joinToGroup(string memory name) public returns (bool) {

        for (uint i = 0; i < totalMembers; i++) {
            require(
                members[i].addr != msg.sender,
                "Already joined the group."
            );
        }
        
        members[totalMembers] = Member(msg.sender, name, false, totalMembers);

        totalMembers ++;

        return true;
    }

       //// for only admin
    function activateMember(uint[] memory ids) external authorized returns (bool) {
        for (uint i = 0; i < ids.length; i++) {

            /// get index
            uint index = ids[i];

            if (index < totalMembers) {
                members[ids[i]].activated = true;
                activations[members[index].addr] = true;
            }
            
        }

        return true;
    }

    function checkActivation(address addr) public view override returns (bool) {
        if (activations[addr]) {
            return true;
        } else {
            return false;
        }
    }

    function checkJoined(address addr) public view returns (bool) {
        bool res = false;

        for (uint i = 0; i < totalMembers; i++) {
            if (members[i].addr == addr) res = true;
        }

        return res;
    }

    function getTotalMembers() public view returns (uint) {
        return totalMembers;
    }

    function getAllMembers() public view returns (Member[] memory) {
        Member[] memory _members = new Member[](totalMembers);

        for (uint i = 0; i < totalMembers; i++) {
            _members[i] = members[i];
        }

        return _members;
    }

    function getMemberByIndex(uint index) public view override returns (Member memory) {
        require(
            index < totalMembers,
            "There isn't member with the index"
        );

        return members[index];
    }

    function getMemberByAddress(address addr) public view override returns (Member memory) {
        Member memory _member;
        for (uint i = 0; i < totalMembers; i++) {
            if (members[i].addr == addr) {
                _member = members[i];
            }
        }

        return (_member);
    }




}