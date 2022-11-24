// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

//SPDX-License-Identifier: GNU GPLv3
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";

//@author Nethny
contract Distribution is Ownable {
    struct TeamMember {
        uint256 awardsAddress;
        address[] addresses;
        uint256 interest;
        uint256 shift; //Shift = 10**x interest = interest/shift
        bool choice; // 1- Receiving an award in tokens 0- Receiving an award in usd
        bool immutability;
    }

    address public Root;

    mapping(string => TeamMember) public teamTable;
    string[] public Team;

    function addNewTeamMember(
        string calldata Name,
        address _address,
        uint256 _interest,
        uint256 _shift,
        bool _immutability
    ) public onlyOwner {
        require(teamTable[Name].addresses.length == 0);

        teamTable[Name].addresses.push(_address);
        teamTable[Name].interest = _interest;
        teamTable[Name].shift = _shift;
        teamTable[Name].immutability = _immutability;

        Team.push(Name);
    }

    function changeTeamMember(
        string calldata Name,
        uint256 _interest,
        uint256 _shift,
        bool _immutability
    ) public onlyOwner {
        require(teamTable[Name].immutability == false);

        teamTable[Name].interest = _interest;
        teamTable[Name].shift = _shift;
        teamTable[Name].immutability = _immutability;
    }

    modifier onlyTeamMember(string calldata Name) {
        bool flag = false;
        for (uint256 i = 0; i < teamTable[Name].addresses.length; i++) {
            if (teamTable[Name].addresses[i] == msg.sender) {
                flag = true;
            }
        }

        require(flag);
        _;
    }

    function choose(string calldata Name, bool _choice)
        public
        onlyTeamMember(Name)
    {
        teamTable[Name].choice = _choice;
    }

    function addNewAddressTeam(string calldata Name, address _newAddress)
        public
        onlyTeamMember(Name)
    {
        teamTable[Name].addresses.push(_newAddress);
    }

    function chooseAddressTeam(string calldata Name, uint256 _choice)
        public
        onlyTeamMember(Name)
    {
        require(_choice < teamTable[Name].addresses.length);
        teamTable[Name].awardsAddress = _choice;
    }

    function getTeam() public view returns (string[] memory) {
        return Team;
    }

    function getTeamMember(string calldata name)
        public
        view
        returns (TeamMember memory)
    {
        return teamTable[name];
    }

    /// ====================================================== -Referal- ======================================================

    struct Member {
        address owner;
        uint256 interest;
        uint256 shift;
    }

    mapping(address => Member) public memberTable;

    function getMember(address member) public view returns (Member memory) {
        return memberTable[member];
    }

    function approveNewWallet(address _owner) public {
        require(memberTable[msg.sender].owner == address(0));
        require(msg.sender != _owner);
        memberTable[msg.sender].owner = _owner;

        refferalOwnerTable[_owner].members.push(msg.sender);
    }

    function setOwners(address[] calldata members, address _owner)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < members.length; i++) {
            if (memberTable[members[i]].owner != address(0)) {
                address owner = memberTable[members[i]].owner;
                uint256 length = refferalOwnerTable[owner].members.length;
                for (uint256 j = 0; j < length; j++) {
                    if (refferalOwnerTable[owner].members[j] == members[i]) {
                        refferalOwnerTable[owner].members[
                            j
                        ] = refferalOwnerTable[owner].members[length - 1];

                        refferalOwnerTable[owner].members.pop();
                    }
                }
            }

            memberTable[members[i]].owner = _owner;

            refferalOwnerTable[_owner].members.push(members[i]);
        }
    }

    function changeMember(
        address member,
        address _owner,
        uint256 _interest,
        uint256 _shift
    ) public onlyOwner {
        memberTable[member].owner = _owner;
        memberTable[member].interest = _interest;
        memberTable[member].shift = _shift;
    }

    //Refferal owners part

    struct ReferralOwner {
        uint256 awardsAddress;
        address[] addresses;
        address[] members;
    }

    mapping(address => ReferralOwner) public refferalOwnerTable;

    function getOwnerMember(address member)
        public
        view
        returns (ReferralOwner memory)
    {
        return refferalOwnerTable[member];
    }

    function addNewAddressReferral(address _newAddress) public {
        refferalOwnerTable[msg.sender].addresses.push(_newAddress);
    }

    function chooseAddressReferral(uint256 _choice) public {
        require(_choice < refferalOwnerTable[msg.sender].addresses.length);
        refferalOwnerTable[msg.sender].awardsAddress = _choice;
    }

    function changeMembers(
        address _owner,
        uint256 _interest,
        uint256 _shift
    ) public onlyOwner {
        address[] memory members = refferalOwnerTable[_owner].members;
        for (uint256 i = 0; i < members.length; i++) {
            memberTable[members[i]].interest = _interest;
            memberTable[members[i]].shift = _shift;
        }
    }
}