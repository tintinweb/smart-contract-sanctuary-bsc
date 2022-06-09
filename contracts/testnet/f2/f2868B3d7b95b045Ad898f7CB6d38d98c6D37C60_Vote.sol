/**
 *Submitted for verification at BscScan.com on 2022-06-08
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

contract Vote is Auth {

    constructor () Auth (msg.sender) {}

    struct Member {
        address addr;
        string name;
        bool activated;  // if true, that person already voted
        uint[] votedMaterials;
    }

    struct VotingOption {
        string option;
        uint votedCount;
    }

    struct VotingMaterial {
        address creator;
        string name;
        uint optionCount;
        uint[] options;
    }

    mapping(address => bool) joins;
    mapping(address => bool) activations;
    mapping(uint => Member) members;
    uint totalMembers = 0;

    VotingMaterial[] voting_materials;
    VotingOption[] voting_options;

    function joinToGroup(string memory name) public returns (bool) {
        
        require(
            joins[msg.sender] == false,
            "Already joined the group."
        );

        uint[] memory materials; 
        members[totalMembers] = Member(msg.sender, name, false, materials);
        joins[msg.sender] = true;

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

    function createVotingMaterial(string memory name, string[] memory options) public returns (bool) {
        require(
            checkActivation(msg.sender) == true,
            "You need to join and to be activated by admin"
        );

        VotingMaterial memory vMaterial = VotingMaterial(msg.sender, name, options.length, new uint[](0));
        voting_materials.push(vMaterial);

        uint optionsCount = voting_options.length;
        for (uint i = 0; i < options.length; i++) {
            voting_options.push(VotingOption(options[i], 0));
            voting_materials[voting_materials.length - 1].options.push(optionsCount + i);
        }


        return true;
    }

    function voteMaterial(uint materialId, uint optionId) public returns (bool) {
        require(
            materialId < voting_materials.length,
            "There isn't the index's voting material"
        );

        require(
            optionId < voting_materials[materialId].optionCount,
            "There isn't the index's voting material"
        );

        require(
            checkActivation(msg.sender) == true,
            "You need to join and to be activated by admin"
        );

        uint index;
        for (uint i=0; i < totalMembers; i++) {
            if (members[i].addr == msg.sender) {
                index = i;
            }
        }

        bool alreadyVoted = false;
        for (uint i=0; i < members[index].votedMaterials.length; i++) {
            if (members[index].votedMaterials[i] == materialId) {
                alreadyVoted = true;
            }
        }

        require(
            alreadyVoted == false,
            "You already voted to this voting material"
        );

        members[index].votedMaterials.push(materialId);

        uint oId = voting_materials[materialId].options[optionId];
        voting_options[oId].votedCount ++;

        return true;
    }

    function checkActivation(address addr) public view returns (bool) {
        if (joins[addr] && activations[addr]) {
            return true;
        } else {
            return false;
        }
    }

    function getTotalMembers() public view returns (uint) {
        return totalMembers;
    }

    function getTotalVotingMaterials() public view returns (uint) {
        return voting_materials.length;
    }

    function getTotalVotingOptions() public view returns (uint) {
        return voting_options.length;
    }

    function getAllVotingMaterials() public view returns (VotingMaterial[] memory) {
        return voting_materials;
    }

    function getAllVotingOptions() public view returns (VotingOption[] memory) {
        return voting_options;
    }

    function getMemberByIndex(uint index) public view returns (Member memory) {
        require(
            index < totalMembers,
            "There isn't member with the index"
        );

        return members[index];
    }

    function getVotingMaterialByIndex(uint index) public view returns (VotingMaterial memory) {
        require(
            index < voting_materials.length,
            "There isn't voting material with the index"
        );

        return voting_materials[index];
    }

    function getVotingOptionByIndex(uint index) public view returns (VotingOption memory) {
        require(
            index < voting_options.length,
            "There isn't voting option with the index"
        );

        return voting_options[index];
    }
}