/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-12
*/

//  SPDX-License-Identifier: MIT

//  █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████
//
//      ███████ ███    ███  █████  ██████  ████████   ██   ██ ██    ██ ██████    
//      ██      ████  ████ ██   ██ ██   ██    ██      ██   ██ ██    ██ ██   ██   
//      ███████ ██ ████ ██ ███████ ██████     ██      ███████ ██    ██ ██████    
//           ██ ██  ██  ██ ██   ██ ██   ██    ██      ██   ██ ██    ██ ██   ██   
//      ███████ ██      ██ ██   ██ ██   ██    ██      ██   ██  ██████  ██████    
//
//  █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████
//
//              ██ ██  ██     ██████   █████  ██    ██ ██      ██    ██          
//             ███    ██      ██   ██ ██   ██  ██  ██  ██       ██  ██           
//              ██   ██       ██   ██ ███████   ████   ██        ████            
//              ██  ██        ██   ██ ██   ██    ██    ██         ██             
//              ██ ██  ██     ██████  ██   ██    ██    ███████    ██             
//
//  █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████
//
//           ██████   ██████  ███████ ██  ██      █████  ██████  ██████          
//                ██ ██       ██         ██      ██   ██ ██   ██ ██   ██         
//            █████  ███████  ███████   ██       ███████ ██████  ██████          
//                ██ ██    ██      ██  ██        ██   ██ ██      ██   ██         
//           ██████   ██████  ███████ ██  ██     ██   ██ ██      ██   ██         
//
//  █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████
//
//  SmartHub - a modern smart-contract on BSC for fast and safe earning
//
//  Daily rate: 1%
//  APR: 365%
//
//  Minimal deposit: 0.05 BNB
//  Maximal deposit: 50 BNB
//  
//  Deposit fee: 15%
//  Deposit withdrawal fee: 10%
//
//  Profit reinvestment fee: 0%
//  Profit withdrawal fee: 0%
//
//  Referral rewards: 10% - 6% - 5% - 3% - 1%
//
//  Website: https://smarthub.fun
//
//  █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████ █████
//

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)



pragma solidity ^0.8.0;


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




pragma solidity ^0.8.17;

// ------
// --- Structures
// ------

struct State {
    uint256 launch_time;
    uint32 n_users;
    uint256 turnover;
    uint256 payouts;
}

struct User {
    bool registered;
    address referrer;
    uint256 deposit;
    uint256 balance;
    uint256 claim_time;
    uint16[5] referrals;
}

contract SmartHub is Ownable {
    // ------
    // --- Settings
    // ------

    uint256 constant internal LAUNCH_TIME = 1668988800;

    uint8 constant internal PRECENT_DIVEDER = 100;

    uint32 constant internal DEPOSIT_PERIOD = 60*60*24;
    uint8 constant internal DEPOSIT_RATE = 1;

    uint256 constant internal MIN_DEPOSIT = 0.05 ether;
    uint256 constant internal MAX_DEPOSIT = 50 ether;

    address constant internal FEE_ADDRESS = 0x14221853ECFa6D8D3488846776619fe12fdD94cA;
    uint8 constant internal DEPOSIT_FEE = 15;
    uint8 constant internal WITHDRAW_FEE = 10;

    address constant internal DEFAULT_REFERRER = 0x14221853ECFa6D8D3488846776619fe12fdD94cA;
    uint8[5] internal REF_REWARD = [10, 6, 5, 3, 1];

    // ------
    // --- Variables
    // ------

    State internal state;
    mapping(address => User) internal users;

    bool internal reentrancy_lock;

    // ------
    // --- Events
    // ------

    event NewUser(address indexed user, address indexed referrer);
    event Invest(address indexed user, uint256 amount);
    event Reinvest(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    // ------
    // --- Modifiers
    // ------

    modifier nonReentrant() {
        require(!reentrancy_lock, "No re-entrancy");
        reentrancy_lock = true;
        _;
        reentrancy_lock = false;
    }

    modifier onlyLaunched() {
        require(block.timestamp >= state.launch_time, "Contract must be launched");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User must be registered");
        _;
    }

    // ------
    // --- Initialization
    // ------

    constructor() {
        state.launch_time = LAUNCH_TIME;

        if (FEE_ADDRESS == DEFAULT_REFERRER){
            _createUser(FEE_ADDRESS, DEFAULT_REFERRER);
        } else {
            _createUser(DEFAULT_REFERRER, DEFAULT_REFERRER);
            _createUser(FEE_ADDRESS, DEFAULT_REFERRER);
        }
        
    }

    // ------
    // --- External functions
    // ------

        function invest(address referrer) external payable nonReentrant onlyLaunched {
        if (!_userRegistered(msg.sender)){
            _registration(msg.sender, referrer);
        }

        _chargeBalance(msg.sender);

        require(msg.value >= MIN_DEPOSIT, "Deposit amount is less than minimal deposit");

        uint256 fee = (msg.value * DEPOSIT_FEE) / PRECENT_DIVEDER;
        uint256 upd_deposit = users[msg.sender].deposit + (msg.value - fee);
        require(upd_deposit <= MAX_DEPOSIT, "Deposit must be less than maximal deposit");

        users[msg.sender].deposit += msg.value - fee;
        users[FEE_ADDRESS].balance += fee;

        if (msg.sender != FEE_ADDRESS && msg.sender != DEFAULT_REFERRER) {
            _chargeRef(msg.sender, 0);
        }

        state.turnover += msg.value;

        emit Invest(msg.sender, msg.value);
    }

    function reinvest(uint256 amount) external nonReentrant onlyLaunched onlyRegistered {
        _chargeBalance(msg.sender);

        require(amount <= users[msg.sender].balance, "Not enough balance");
        require(amount >= MIN_DEPOSIT, "Deposit amount is less than minimal deposit");

        uint256 upd_deposit = users[msg.sender].deposit + amount;
        require(upd_deposit <= MAX_DEPOSIT, "Deposit must be less than maximal deposit");

        users[msg.sender].balance -= amount;
        users[msg.sender].deposit += amount;

        emit Reinvest(msg.sender, amount);
    }

    function withdraw(uint256 amount) external nonReentrant onlyLaunched onlyRegistered {
        _chargeBalance(msg.sender);

        require(amount <= users[msg.sender].deposit, "Deposit less than withdrawal amount");
        
        uint256 fee = (amount * WITHDRAW_FEE) / PRECENT_DIVEDER;

        users[msg.sender].deposit -= amount;

        state.turnover += amount-fee;
        state.payouts += amount-fee;

        users[FEE_ADDRESS].balance += fee;

        payable(msg.sender).transfer(amount-fee);

        emit Withdraw(msg.sender, amount);
    }

    function claim(uint256 amount) external nonReentrant onlyLaunched onlyRegistered {
        _chargeBalance(msg.sender);

        require(amount <= users[msg.sender].balance, "Not enough balance");

        users[msg.sender].balance -= amount;

        state.turnover += amount;
        state.payouts += amount;

        payable(msg.sender).transfer(amount);

        emit Claim(msg.sender, amount);
    }

    // ------
    // --- Internal functions
    // ------

    function _userRegistered(address _user) internal view returns (bool user_registered) {
        return (
            users[_user].registered
        );
    }

    function _registration(address _user, address _referrer) internal {
        require(!_userRegistered(_user), "User is already registered");

        if (_user == _referrer) {
            _referrer = DEFAULT_REFERRER;
        }

        if (!_userRegistered(_referrer)) {
            _createUser(_referrer, DEFAULT_REFERRER);
        }

        _createUser(_user, _referrer);
    }

    function _createUser(address _user, address _referrer) internal {
        User storage user = users[_user];

        user.registered = true;
        user.referrer = _referrer;

        state.n_users += 1;

        if (_user != DEFAULT_REFERRER) {
            _refUpdate(_referrer, 0);
        }

        emit NewUser(_user, _referrer);
    }

    function _refUpdate(address _referrer, uint8 _ref_level) internal {
        User storage referrer = users[_referrer];

        referrer.referrals[_ref_level] += 1;

        if (_ref_level + 1 < REF_REWARD.length && _referrer != DEFAULT_REFERRER) {
            _refUpdate(referrer.referrer, _ref_level + 1);
        }
    }

    function _calcReward(address _user) internal view returns(uint reward) {
        uint256 deposit = users[_user].deposit;
        uint256 from = users[_user].claim_time;
        uint256 to = block.timestamp;

        return (
            (deposit * (to - from) * DEPOSIT_RATE) / DEPOSIT_PERIOD / PRECENT_DIVEDER
        );
    }

    function _chargeBalance(address _user) internal {
        users[_user].balance += _calcReward(_user);
        users[_user].claim_time = block.timestamp;
    }

    function _chargeRef(address _user, uint8 _level) internal {
        User storage referrer = users[users[_user].referrer];

        uint256 fee = (REF_REWARD[_level] * msg.value) / PRECENT_DIVEDER;

        referrer.balance += fee;

        if (_level + 1 < REF_REWARD.length && users[_user].referrer != DEFAULT_REFERRER) {
            _chargeRef(users[_user].referrer, _level + 1);
        }
    }
    
    // ------
    // --- View functions
    // ------

    function contractState() external view returns(
        uint32 n_users,
        uint256 turnover,
        uint256 payouts
    ) {
        return (
            state.n_users,
            state.turnover,
            state.payouts
        );
    }

    function userState(address _user) external view returns(
        uint256 deposit,
        uint256 balance,
        uint16[5] memory referrals
    ) {
        User storage user = users[_user];

        return (
            user.deposit,
            user.balance + _calcReward(_user),
            user.referrals
        );
    }
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdrawFees() public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
    }
}