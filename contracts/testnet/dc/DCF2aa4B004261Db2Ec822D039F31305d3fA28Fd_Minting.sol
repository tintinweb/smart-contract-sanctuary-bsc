/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

pragma solidity >=0.7.0 <0.9.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

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
    string referral;
    string parent_referral;
    uint level;
    uint claimableAmount;
}

contract Minting is Auth {
    constructor (string memory admin_referral) Auth (msg.sender) {
        members[0] = Member(msg.sender, admin_referral, '', 0, 0);
        totalMembers ++;
    }

    mapping(uint => Member) members;
    uint public totalMembers = 0;
    address public mintingToken = address(0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD);
    address public payToken = address(0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD);
    

    function register(string memory parent_referral, string memory referral) public returns (bool) {

        for (uint i = 0; i < totalMembers; i++) {
            require(
                members[i].addr != msg.sender,
                "Already registered."
            );
        }

        bool isParentExist = false;
        for (uint i = 0; i < totalMembers; i++) {
            if (keccak256(abi.encodePacked(members[i].referral)) == keccak256(abi.encodePacked(parent_referral))) {
                isParentExist = true;
            }
        }
        require(isParentExist != false, "Can't not find parent with the referral");

        members[totalMembers] = Member(msg.sender, referral, parent_referral, 0, 0);
        
        totalMembers ++;

        return true;
    }

    function getMemberByIndex(uint index) public view returns (Member memory) {
        require(
            index < totalMembers,
            "There isn't member with the index"
        );

        return members[index];
    }

    function getMemberByAddress(address addr) public view returns (Member memory) {
        Member memory _member;
        for (uint i = 0; i < totalMembers; i++) {
            if (members[i].addr == addr) {
                _member = members[i];
            }
        }

        return (_member);
    }

    function getMemberByReferral(string memory referral) public view returns (Member memory) {
        Member memory _member;
        for (uint i = 0; i < totalMembers; i++) {
            if (keccak256(abi.encodePacked(members[i].referral)) == keccak256(abi.encodePacked(referral))) {
                _member = members[i];
            }
        }

        return (_member);
    }

    function getParents(string memory parent_referral) public view returns (Member[] memory, uint) {
        Member[] memory _parents;

        uint i = 0;
        while (keccak256(abi.encodePacked(parent_referral)) != keccak256(abi.encodePacked(''))) {
            Member memory _parent = getMemberByReferral(parent_referral);
            _parents[i] = _parent;
            parent_referral = _parent.parent_referral;
            i ++;
        }

        return (_parents, _parents.length);
    }

    function levelUp() public returns (bool) {

    }
}