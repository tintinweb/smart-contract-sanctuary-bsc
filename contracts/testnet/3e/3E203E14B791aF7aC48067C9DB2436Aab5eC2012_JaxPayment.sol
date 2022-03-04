//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

contract JaxPayment is Ownable {

    uint public max_junior_count = 5;

    enum MemberStatus {Init, Registered, Rejected, Enabled, Disabled}
    enum MemberType {Member, Manager}

    struct Member {
        uint member_id;
        uint manager_id;
        uint policy_hash;
        uint responsibility_hash;
        uint new_responsibility_hash;
        address public_key;
        MemberStatus status;
        MemberType member_type;
        string policy_link;
        string responsibility_link;
        string new_responsibility_link;
        string trello_board_link;
        uint[] junior_member_ids;
    }

    enum MovementRequestStatus {Init, Accepted, Declined, CurrentManagerApproved, NewManagerApproved, CurrentManagerRejected, NewManagerRejected}

    struct MovementRequest {
        uint member_id;
        uint current_manager_id;
        uint new_manager_id;
        MovementRequestStatus status;
    }

    enum AgreementPartyStatus { Init, Approved, Rejected }

    struct AgreementParty {
        address public_key;
        AgreementPartyStatus status;
    }

    struct Agreement {
        uint agreement_hash;
        AgreementParty[] parties;
    }

    mapping(address => uint) public member_ids;
    Member[] public member_list;

    MovementRequest[] public requests_movement;

    mapping(uint => Agreement) agreement_info;

    event Register_Agreement(uint agreement_hash, address[] parties);
    event Approve_Agreement(uint agreement_hash, address party);
    event Reject_Agreement(uint agreement_hash, address party);

    event Set_Responsibility(uint member_id, uint responsibility_hash, string responsibility_link);
    event Accept_Responsibility(uint member_id, uint responsibility_hash, string responsibility_link);
    event Reject_Responsibility(uint member_id, uint responsibility_hash, string responsibility_link);

    constructor() {
        Member memory admin;
        admin.public_key = msg.sender;
        admin.member_type = MemberType.Manager;
        member_list.push(admin);
    }

    modifier onlyMember() {
        require(member_ids[msg.sender] > 0, "Only Member");
        _;
    }

    modifier onlyManager() {
        uint member_id = member_ids[msg.sender];
        Member memory member = member_list[member_id];
        require(msg.sender == owner() || (member_id > 0 && member.member_type == MemberType.Manager), "Only manager");
        require(member_list[member_id].status == MemberStatus.Enabled, "Only active");
        _;
    }

    modifier onlyActiveMember() {
        uint member_id = member_ids[msg.sender];
        require(member_id > 0, "Only Member");
        require(member_list[member_id].status == MemberStatus.Enabled, "Only active member");
        _;
    }

    function checkSpaceForNewMember(uint manager_id) internal view {
        require(count_junior_members(manager_id) < max_junior_count, "No space for new member");
    }

    function count_junior_members(uint manager_id) internal view returns(uint) {
        Member memory manager = member_list[manager_id];
        return manager.junior_member_ids.length;
    }

    function find_junior_member_index(Member storage manager, uint member_id) internal view returns(uint) {
        uint junior_member_length = manager.junior_member_ids.length;
        for(uint i; i < junior_member_length; i += 1) {
            if(manager.junior_member_ids[i] == member_id)
                return i;
        }
        return max_junior_count;
    }


    function pop_junior_member(Member storage manager, uint member_id) internal {
        uint i = find_junior_member_index(manager, member_id);
        require(i < manager.junior_member_ids.length, "Not a junior member");
        if(i < manager.junior_member_ids.length - 1) {
            manager.junior_member_ids[i] = manager.junior_member_ids[manager.junior_member_ids.length-1];
        }
        manager.junior_member_ids.pop();
    }

    function count_members() public view returns(uint){
        return member_list.length;
    }

    function register_member(address public_key, MemberType member_type, uint responsibility_hash, string calldata responsibility_link, string calldata trello_board_link) external onlyManager {
        uint manager_id = member_ids[msg.sender];
        checkSpaceForNewMember(manager_id);
        require(member_ids[public_key] == 0, "Already registered");
        uint new_member_id = member_list.length;
        Member memory new_member;
        new_member.member_id = new_member_id;
        new_member.member_type = member_type;
        new_member.manager_id = manager_id;
        new_member.public_key = public_key;
        new_member.responsibility_hash = responsibility_hash;
        new_member.responsibility_link = responsibility_link;
        new_member.trello_board_link = trello_board_link;
        new_member.status = MemberStatus.Registered;
        member_list.push(new_member);
        member_ids[public_key] = new_member_id;
    }

    function approve_member_registration() external onlyMember{
        uint member_id = member_ids[msg.sender];
        Member storage member = member_list[member_id];
        require(member.status == MemberStatus.Registered, "Invalid status");
        checkSpaceForNewMember(member.manager_id);
        Member storage manager = member_list[member.manager_id];
        member.status = MemberStatus.Enabled;
        manager.junior_member_ids.push(member_id);
    }

    function delete_member(uint member_id) external onlyManager {
        uint manager_id = member_ids[msg.sender];
        Member storage manager = member_list[manager_id];
        Member storage member = member_list[member_id];
        require(member.junior_member_ids.length == 0, "Member has juniors");
        require(member.manager_id == manager_id, "Can delete junior member only");
        pop_junior_member(manager, member_id);
        member_ids[msg.sender] = 0;
        delete member_list[member_id];
    }

    function set_policy(uint policy_hash, string calldata policy_link) external onlyActiveMember {
        uint member_id = member_ids[msg.sender];
        Member storage member = member_list[member_id];
        member.policy_hash = policy_hash;
        member.policy_link = policy_link;
    }

    function set_responsibility(uint member_id, uint responsibility_hash, string calldata responsibility_link) external onlyManager{
        Member storage member = member_list[member_id];
        require(member.manager_id == member_ids[msg.sender]);
        member.new_responsibility_hash = responsibility_hash;
        member.new_responsibility_link = responsibility_link;
        emit Set_Responsibility(member_id, responsibility_hash, responsibility_link);
    }

    function accept_responsibility() external onlyActiveMember {
        uint member_id = member_ids[msg.sender];
        Member storage member = member_list[member_id];
        require(member.new_responsibility_hash != 0, "Not valid responsibility");
        member.responsibility_hash = member.new_responsibility_hash;
        member.responsibility_link = member.new_responsibility_link;
        emit Accept_Responsibility(member_id, member.new_responsibility_hash, member.new_responsibility_link);
    }

    function reject_responsibility() external onlyActiveMember {
        uint member_id = member_ids[msg.sender];
        Member storage member = member_list[member_id];
        require(member.new_responsibility_hash != 0, "Not valid responsibility");
        emit Reject_Responsibility(member_id, member.new_responsibility_hash, member.new_responsibility_link);
        member.new_responsibility_hash = 0;
        member.new_responsibility_link = "";
    }

    function set_trello_board_link(uint member_id, string calldata trello_board_link) external onlyManager {
        Member storage member = member_list[member_id];
        require(member.status == MemberStatus.Enabled, "Not a valid member");
        require(member.manager_id == member_ids[msg.sender], "Not a subordinate");
        member.trello_board_link = trello_board_link;
    }

    function request_member_movement(uint member_id, uint new_manager_id) external onlyMember {
        MovementRequest memory request;
        uint current_manager_id = member_list[member_id].manager_id;
        require(count_junior_members(new_manager_id) < 5, "New member already have 5");
        request.member_id = member_id;
        request.current_manager_id = current_manager_id;
        request.new_manager_id = new_manager_id;
        requests_movement.push(request);
    }

    function approve_member_movement(uint request_id) external {
        MovementRequest storage request = requests_movement[request_id];
        if(request.status == MovementRequestStatus.Init) {
            require(request.member_id == member_ids[msg.sender], "Only member requested movement");
            request.status = MovementRequestStatus.Accepted;
        }
        else if(request.status == MovementRequestStatus.Accepted) {
            require(request.current_manager_id == member_ids[msg.sender], "Only current member");
            request.status = MovementRequestStatus.CurrentManagerApproved;
        }
        else if(request.status == MovementRequestStatus.CurrentManagerApproved) {
            require(request.new_manager_id == member_ids[msg.sender], "Only new member");
            request.status = MovementRequestStatus.NewManagerApproved;
            checkSpaceForNewMember(request.new_manager_id);
            Member storage member = member_list[request.member_id];
            Member storage current_manager = member_list[request.current_manager_id];
            pop_junior_member(current_manager, request.member_id);
            member.manager_id = request.new_manager_id;
            member_list[request.new_manager_id].junior_member_ids.push(request.member_id);
        }
        else 
            revert("Already proccessed");
    }


    function reject_member_movement(uint request_id) external {
        MovementRequest storage request = requests_movement[request_id];
        if(request.status == MovementRequestStatus.Init) {
            require(request.member_id == member_ids[msg.sender], "Only member requested movement");
            request.status = MovementRequestStatus.Declined;
        }
        else if(request.status == MovementRequestStatus.Accepted) {
            require(request.current_manager_id == member_ids[msg.sender], "Only current member");
            request.status = MovementRequestStatus.CurrentManagerRejected;
        }
        else if(request.status == MovementRequestStatus.CurrentManagerApproved) {
            require(request.new_manager_id == member_ids[msg.sender], "Only new member");
            request.status = MovementRequestStatus.NewManagerRejected;
        }
        else 
            revert("Already proccessed");
    }

    function register_agreement(uint agreement_hash, address[] calldata parties) external {
        Agreement storage agreement = agreement_info[agreement_hash];
        require(agreement.parties.length == 0, "Agreement already exists");
        for(uint i; i < parties.length; i += 1) {
            AgreementParty memory party;
            party.public_key = parties[i];
            agreement.parties.push(party);
        }
        emit Register_Agreement(agreement_hash, parties);
    }

    function approve_agreement(uint agreement_hash) external {
        Agreement storage agreement = agreement_info[agreement_hash];
        uint i;
        for(; i < agreement.parties.length; i += 1) {
            if(agreement.parties[i].public_key == msg.sender)
                break;
        }
        require(i < agreement.parties.length, "Not an agreement party");
        require(agreement.parties[i].status == AgreementPartyStatus.Init, "Already approved/rejected");
        agreement.parties[i].status = AgreementPartyStatus.Approved;
        emit Approve_Agreement(agreement_hash, msg.sender);
    }
    
    function reject_agreement(uint agreement_hash) external {
        Agreement storage agreement = agreement_info[agreement_hash];
        uint i;
        for(; i < agreement.parties.length; i += 1) {
            if(agreement.parties[i].public_key == msg.sender)
                break;
        }
        require(i < agreement.parties.length, "Not an agreement party");
        require(agreement.parties[i].status == AgreementPartyStatus.Init, "Already approved/rejected");
        agreement.parties[i].status = AgreementPartyStatus.Rejected;
        emit Reject_Agreement(agreement_hash, msg.sender);
    }

    function get_agreement_info(uint agreement_hash) external view returns(AgreementParty[] memory){
        return agreement_info[agreement_hash].parties;
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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