//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract JaxPayment is Ownable {

    enum ManagerStatus {Init, Registered, Rejected, Enabled, Disabled}

    struct Manager {
        uint senior_manager;
        ManagerStatus status;
        address public_key;
        uint budget_limit;
        uint policy_hash;
        string policy_link;
        uint responsibility_hash;
        string responsibility_link;
        string trello_board_link;
        uint[] junior_managers;
        address[] staffs;
    }

    enum StaffStatus {Init, Registered, Rejected, Enabled, Disabled}

    struct Staff {
        uint manager_no;
        StaffStatus status;
        uint responsibility_hash;
        string responsibility_link;
        uint my_policy_hash;
        string my_policy_link;
        string trello_board_link;
    }

    enum MovementRequestStatus {Init, Accepted, Declined, OldManagerApproved, NewManagerApproved, OldManagerRejected, NewManagerRejected}

    struct StaffMovementRequest {
        address staff_key;
        uint current_manager;
        uint new_manager;
        MovementRequestStatus status;
    }

    struct ManagerMovementRequest {
        uint manager_no;
        uint current_manager;
        uint new_manager;
        MovementRequestStatus status;
    }

    struct Agreement {
        uint agreement_hash;
        address[] parties;
        address[] approved_parties;
        address[] rejected_parties;
    }

    IERC20 base_currency;

    mapping(address => uint) public manager_numbers;

    Manager[] public manager_info;

    mapping(address => Staff) public staff_info;

    StaffMovementRequest[] public requests_staff_movement;
    ManagerMovementRequest[] public requests_manager_movement;

    mapping(uint => Agreement) public agreement_info;

    event Register_Agreement(uint agreement_hash, address[] parties);
    event Approve_Agreement(uint agreement_hash, address party);
    event Reject_Agreement(uint agreement_hash, address party);

    modifier onlyManager () {
        require(manager_numbers[msg.sender] > 0 || msg.sender == owner(), "Only Manager");
        _;
    }

    function count_subordinates(uint manager_no) internal view returns(uint) {
        Manager storage manager = manager_info[manager_no];
        return manager.junior_managers.length + manager.staffs.length;
    }

    function pop_junior_manager(uint manager_no) internal {
        Manager storage senior_manager = manager_info[manager_info[manager_no].senior_manager];
        uint i;
        for(; i < senior_manager.junior_managers.length; i += 1) {
            if(senior_manager.junior_managers[i] == manager_no)
                break;
        }
        require(i < senior_manager.junior_managers.length, "error");
        if(i < senior_manager.junior_managers.length - 1) {
            senior_manager.junior_managers[i] = senior_manager.junior_managers[senior_manager.junior_managers.length-1];
        }
        senior_manager.junior_managers.pop();
    }

    function pop_staff(address staff_addr) internal {
        Manager storage manager = manager_info[staff_info[staff_addr].manager_no];
        uint i;
        for(; i < manager.staffs.length; i += 1) {
            if(manager.staffs[i] == staff_addr)
                break;
        }
        require(i < manager.staffs.length, "error");
        if(i < manager.staffs.length - 1) {
            manager.staffs[i] = manager.staffs[manager.staffs.length-1];
        }
        manager.staffs.pop();
    }

    function count_managers() public view returns(uint){
        return manager_info.length;
    }

    constructor() {
        manager_numbers[msg.sender] = count_managers();
        Manager memory manager;
        manager.public_key = msg.sender;
        manager_info.push(manager);
    }

    function set_base_currency(IERC20 _base_currency) external onlyOwner {
        base_currency = _base_currency;
    }

    function register_manager(address account) external onlyManager {
        uint senior_manager_number = manager_numbers[msg.sender];
        Manager storage senior_manager = manager_info[senior_manager_number];
        require(count_subordinates(senior_manager_number) < 5, "Maximum 5 subordinates");
        require(manager_numbers[account] == 0, "Already registered");
        uint junior_manager_number = manager_info.length;
        Manager memory junior_manager;
        junior_manager.senior_manager = senior_manager_number;
        junior_manager.public_key = account;
        junior_manager.status = ManagerStatus.Registered;
        manager_info.push(junior_manager);
        manager_numbers[account] = junior_manager_number;
    }

    function approve_manager() external {
        uint manager_number = manager_numbers[msg.sender];
        require(manager_number > 0, "Not registered");
        Manager storage manager = manager_info[manager_number];
        require(manager.status == ManagerStatus.Registered, "Invalid status");
        Manager storage senior_manager = manager_info[manager.senior_manager];
        require(count_subordinates(manager.senior_manager) < 5, "No space");
        manager.status = ManagerStatus.Enabled;
        senior_manager.junior_managers.push(manager_number);
    }

    function register_staff(address account) external onlyManager {
        uint manager_number = manager_numbers[msg.sender];
        Manager storage manager = manager_info[manager_number];
        require(count_subordinates(manager_number) < 5, "Maximum 5 subordinates");
        Staff storage staff = staff_info[account];
        require(staff.manager_no == 0 && staff.status == StaffStatus.Init, "Invalid staff status");
        staff.manager_no = manager_number;
        staff.status = StaffStatus.Registered;
    }


    function approve_staff() external {
        Staff storage staff = staff_info[msg.sender];
        require(staff.status == StaffStatus.Registered, "Invalid status");
        Manager storage manager = manager_info[staff.manager_no];
        require(count_subordinates(staff.manager_no) < 5, "No space");
        staff.status = StaffStatus.Enabled;
        manager.staffs.push(msg.sender);
    }

    function set_policy(uint policy_hash, string calldata policy_link) external onlyManager {
        uint manager_number = manager_numbers[msg.sender];
        Manager storage manager = manager_info[manager_number];
        manager.policy_hash = policy_hash;
        manager.policy_link = policy_link;
    }

    function set_responsibility_for_junior_manager(uint junior_manager_no, uint responsibility_hash, string calldata responsibility_link) external onlyManager{
        Manager storage manager = manager_info[junior_manager_no];
        require(manager.senior_manager == manager_numbers[msg.sender]);
        manager.responsibility_hash = responsibility_hash;
        manager.responsibility_link = responsibility_link;
    }

    function set_responsibility_for_staff(address staff_address, uint responsibility_hash, string calldata responsibility_link) external onlyManager {
        Staff storage staff = staff_info[staff_address];
        require(staff.manager_no == manager_numbers[msg.sender]);
        staff.responsibility_hash = responsibility_hash;
        staff.responsibility_link = responsibility_link;
    }

    function set_my_policy(uint my_policy_hash, string calldata my_policy_link) external {
        Staff storage staff = staff_info[msg.sender];
        require(staff.status == StaffStatus.Enabled, "Invalid staff");
        staff.my_policy_hash = my_policy_hash;
        staff.my_policy_link = my_policy_link;
    }

    function set_budget_limits(uint[] calldata budget_limits) external onlyManager {
        uint manager_number = manager_numbers[msg.sender];
        Manager storage manager = manager_info[manager_number];
        uint total_budget;
        require(budget_limits.length == manager.junior_managers.length, "Array length mismatch");
        for(uint i; i < budget_limits.length; i += 1) {
            Manager storage junior_manager = manager_info[manager.junior_managers[i]];
            junior_manager.budget_limit = budget_limits[i];
            total_budget += budget_limits[i];
        }
        require(total_budget <= manager.budget_limit, "Budget over");
    }

    function request_staff_movement(address staff_key, uint current_manager_no, uint new_manager_no) external onlyManager {
        StaffMovementRequest memory request;
        require(staff_info[staff_key].manager_no == current_manager_no, "Incorrect current manager");
        Manager storage new_manager = manager_info[new_manager_no];
        require(count_subordinates(new_manager_no) < 5, "New manager already have 5");
        request.staff_key = staff_key;
        request.current_manager = current_manager_no;
        request.new_manager = new_manager_no;
        requests_staff_movement.push(request);
    }

    function approve_staff_movement(uint request_id) external {
        StaffMovementRequest storage request = requests_staff_movement[request_id];
        if(request.status == MovementRequestStatus.Init) {
            require(request.staff_key == msg.sender, "Only staff requested movement");
            request.status = MovementRequestStatus.Accepted;
        }
        else if(request.status == MovementRequestStatus.Accepted) {
            require(request.current_manager == manager_numbers[msg.sender], "Only current manager");
            request.status = MovementRequestStatus.OldManagerApproved;
        }
        else if(request.status == MovementRequestStatus.OldManagerApproved) {
            require(request.new_manager == manager_numbers[msg.sender], "Only new manager");
            request.status = MovementRequestStatus.NewManagerApproved;
            require(count_subordinates(request.new_manager) < 5, "New manager already have 5");
            Staff storage staff = staff_info[request.staff_key];
            pop_staff(request.staff_key);
            staff.manager_no = request.new_manager;
            manager_info[request.new_manager].staffs.push(request.staff_key);
        }
        else 
            revert("Already proccessed");
    }

    function reject_staff_movement(uint request_id) external {
        StaffMovementRequest storage request = requests_staff_movement[request_id];
        if(request.status == MovementRequestStatus.Init) {
            require(request.staff_key == msg.sender, "Only staff requested movement");
            request.status = MovementRequestStatus.Declined;
        }
        else if(request.status == MovementRequestStatus.Accepted) {
            require(request.current_manager == manager_numbers[msg.sender], "Only current manager");
            request.status = MovementRequestStatus.OldManagerRejected;
        }
        else if(request.status == MovementRequestStatus.OldManagerApproved) {
            require(request.new_manager == manager_numbers[msg.sender], "Only new manager");
            request.status = MovementRequestStatus.NewManagerRejected;
        }
        else 
            revert("Already proccessed");
    }

    function request_manager_movement(uint manager_no, uint new_manager_no) external onlyManager {
        ManagerMovementRequest memory request;
        uint current_manager_no = manager_info[manager_no].senior_manager;
        Manager storage new_manager = manager_info[new_manager_no];
        require(count_subordinates(new_manager_no) < 5, "New manager already have 5");
        request.manager_no = manager_no;
        request.current_manager = current_manager_no;
        request.new_manager = new_manager_no;
        requests_manager_movement.push(request);
    }

    function approve_manager_movement(uint request_id) external {
        ManagerMovementRequest storage request = requests_manager_movement[request_id];
        if(request.status == MovementRequestStatus.Init) {
            require(request.manager_no == manager_numbers[msg.sender], "Only manager requested movement");
            request.status = MovementRequestStatus.Accepted;
        }
        else if(request.status == MovementRequestStatus.Accepted) {
            require(request.current_manager == manager_numbers[msg.sender], "Only current manager");
            request.status = MovementRequestStatus.OldManagerApproved;
        }
        else if(request.status == MovementRequestStatus.OldManagerApproved) {
            require(request.new_manager == manager_numbers[msg.sender], "Only new manager");
            request.status = MovementRequestStatus.NewManagerApproved;
            require(count_subordinates(request.new_manager) < 5, "New manager already have 5");
            Manager storage manager = manager_info[request.manager_no];
            pop_junior_manager(request.manager_no);
            manager.senior_manager = request.new_manager;
            manager_info[request.new_manager].junior_managers.push(request.manager_no);
        }
        else 
            revert("Already proccessed");
    }


    function reject_manager_movement(uint request_id) external {
        ManagerMovementRequest storage request = requests_manager_movement[request_id];
        if(request.status == MovementRequestStatus.Init) {
            require(request.manager_no == manager_numbers[msg.sender], "Only manager requested movement");
            request.status = MovementRequestStatus.Declined;
        }
        else if(request.status == MovementRequestStatus.Accepted) {
            require(request.current_manager == manager_numbers[msg.sender], "Only current manager");
            request.status = MovementRequestStatus.OldManagerRejected;
        }
        else if(request.status == MovementRequestStatus.OldManagerApproved) {
            require(request.new_manager == manager_numbers[msg.sender], "Only new manager");
            request.status = MovementRequestStatus.NewManagerRejected;
        }
        else 
            revert("Already proccessed");
    }

    function register_agreement(uint agreement_hash, address[] calldata parties) external {
        Agreement storage agreement = agreement_info[agreement_hash];
        require(agreement.parties.length == 0, "Agreement already exists");
        for(uint i; i < parties.length; i += 1) {
            agreement.parties.push(parties[i]);
        }
        emit Register_Agreement(agreement_hash, parties);
    }

    function approve_agreement(uint agreement_hash) external {
        Agreement storage agreement = agreement_info[agreement_hash];
        uint i;
        for(; i < agreement.parties.length; i += 1) {
            if(agreement.parties[i] == msg.sender)
                break;
        }
        require(i < agreement.parties.length, "Not an agreement party");
        for(i = 0; i < agreement.approved_parties.length; i += 1 ) {
            if(agreement.approved_parties[i] == msg.sender) 
                revert("Already approved");
        }
        for(i = 0; i < agreement.rejected_parties.length; i += 1 ) {
            if(agreement.rejected_parties[i] == msg.sender)
                revert("Already rejected");
        }
        agreement.approved_parties.push(msg.sender);
        emit Approve_Agreement(agreement_hash, msg.sender);
    }

    function reject_agreement(uint agreement_hash) external {
        Agreement storage agreement = agreement_info[agreement_hash];
        uint i;
        for(; i < agreement.parties.length; i += 1) {
            if(agreement.parties[i] == msg.sender)
                break;
        }
        require(i < agreement.parties.length, "Not an agreement party");
        for(i = 0; i < agreement.approved_parties.length; i += 1 ) {
            if(agreement.approved_parties[i] == msg.sender) 
                revert("Already approved");
        }
        for(i = 0; i < agreement.rejected_parties.length; i += 1 ) {
            if(agreement.rejected_parties[i] == msg.sender)
                revert("Already rejected");
        }
        agreement.rejected_parties.push(msg.sender);
        emit Reject_Agreement(agreement_hash, msg.sender);
    }

    function set_trello_board_link_for_staff(string calldata trello_board_link) external {
        Staff storage staff = staff_info[msg.sender];
        require(staff.status == StaffStatus.Enabled, "Not a valid staff");
        staff.trello_board_link = trello_board_link;  
    }

    function set_trello_board_link_for_manager(string calldata trello_board_link) external onlyManager {
        Manager storage manager = manager_info[manager_numbers[msg.sender]];
        manager.trello_board_link = trello_board_link;
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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