//SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IPayoutAgent {
    function payout(address, uint, bool) external;
}

contract TefiVault is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct UserInfo {
        uint amount;
        uint share;
        uint expireAt;
        uint depositedAt;
        uint claimedAt;
    }

    address public strategy;
    IERC20 public asset;
    address public payoutAgent;
    address public treasuryWallet = 0x647BB910944165D14b961985c28b06b08cA47f77;

    uint public totalSupply;
    uint public totalShare;
    uint public underlying;
    uint public profits;
    uint public boostFund;
    mapping (uint => uint) public dailyProfit;
    mapping (uint => uint) public dailyLoss;

    mapping(address => UserInfo) public users;
    mapping(address => address) public referrals;
    EnumerableSet.AddressSet userList;
    mapping(address => bool) public invested;
    mapping(address => bool) public investWhitelist;
    mapping(address => bool) public permanentWhitelist;
    mapping(address => bool) public agents;

    uint public rebalanceRate = 20;
    uint public farmPeriod = 60 days;
    uint public expireDelta = 2 days;
    uint public maxSupply = type(uint).max;
    uint public maxUserSupply = 100_000 ether;
    bool public isPublic;

    bool locked;
    uint public constant DUST = 0.1 ether;

    event Deposited(address indexed user, uint amount);
    event BulkDeposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event WithdrawnAll(address indexed user, uint amount);
    event Claimed(address indexed user, uint amount);
    event Compounded(address indexed user, uint amount);

    event Lost(uint amount);
    event Payout(uint amount, uint profit);
    event Refilled(uint amount);

    modifier onlyStrategy {
        require (msg.sender == strategy, "!permission");
        _;
    }

    modifier clearDustShare {
        _;
        UserInfo storage user = users[msg.sender];
        if (balanceOf(msg.sender) < DUST) {
            totalSupply -= user.amount;
            totalShare -= user.share;
            delete users[msg.sender];

            if (!permanentWhitelist[msg.sender]) {
                investWhitelist[msg.sender] = false;
            }
        }
    }

    modifier updateUserList {
        _;
        if (balanceOf(msg.sender) > 0) {
            if (!userList.contains(msg.sender)) userList.add(msg.sender);
        }
        else if (userList.contains(msg.sender)) userList.remove(msg.sender);
    }


    constructor(address _strategy, address _asset, address _payoutAgent) {
        strategy = _strategy;
        asset = IERC20(_asset);
        payoutAgent = _payoutAgent;

        asset.approve(payoutAgent, type(uint).max);
    }

    function getUserList() external view returns (address[] memory) {
        return userList.values();
    }

    function userCount() external view returns (uint) {
        return userList.length();
    }

    function referredWallets(address _wallet) external view returns (address[] memory) {
        uint count;
        for (uint i = 0; i < userList.length(); i++) {
            address user = userList.at(i);
            if (referrals[user] == _wallet) count++;
        }
        if (count == 0) return new address[](0);

        address[] memory _referrals = new address[](count);
        count = 0;
        for (uint i = 0; i < userList.length(); i++) {
            address user = userList.at(i);
            if (referrals[user] == _wallet) _referrals[count] = user;
            ++count;
        }
        return _referrals;
    }

    function balance() public view returns (uint) {
        return asset.balanceOf(address(this)) + underlying - boostFund;
    }

    function available() public view returns (uint) {
        return asset.balanceOf(address(this));
    }

    function balanceOf(address _user) public view returns (uint) {
        return totalShare == 0 ? 0 : users[_user].share * balance() / totalShare;
    }

    function principalOf(address _user) public view returns (uint) {
        if (totalShare == 0) return 0;
        UserInfo storage user = users[_user];
        uint curBal = user.share * balance() / totalShare;
        return curBal > user.amount ? user.amount : curBal;
    }

    function lostOf(address _user) public view returns (uint) {
        if (totalShare == 0) return 0;
        UserInfo storage user = users[_user];
        uint curBal = user.share * balance() / totalShare;
        return curBal < user.amount ? (user.amount - curBal) : 0;
    }

    function earned(address _user) public view returns (uint) {
        UserInfo storage user = users[_user];
        uint bal = balanceOf(_user);
        return user.amount < bal ? (bal - user.amount) : 0;
    }

    function claimable(address _user) public view returns (uint) {
        return _calculateExpiredEarning(_user);
    }

    function totalEarned() external view returns (uint) {
        uint totalBal = balance();
        return totalBal > totalSupply ? (totalBal - totalSupply) : 0;
    }

    function todayProfit() external view returns (uint) {
        return dailyProfit[block.timestamp / 1 days * 1 days];
    }

    function totalLoss() public view returns (uint) {
        uint totalAvailable = underlying + available() - profits;
        uint _totalSupply = totalSupply + boostFund;
        return _totalSupply > totalAvailable ? (_totalSupply - totalAvailable) : 0;
    }

    function todayLoss() external view returns (uint) {
        return dailyLoss[block.timestamp / 1 days * 1 days];
    }

    function checkExpiredUsers() external view returns (uint, address[] memory) {
        uint count;
        for (uint i = 0; i < userList.length(); i++) {
            if (users[userList.at(i)].expireAt + expireDelta <= block.timestamp) count++;
        }
        if (count == 0) return (0, new address[](0));
        address[] memory wallets = new address[](count);
        count = 0;
        for (uint i = 0; i < userList.length(); i++) {
            address wallet = userList.at(i);
            if (users[wallet].expireAt + expireDelta <= block.timestamp) {
                wallets[count] = wallet;
                count++;
            }
        }
        return (wallets.length, wallets);
    }

    function bulkDeposit(address[] calldata _users, uint[] calldata _amounts) external whenNotPaused nonReentrant {
        require (agents[msg.sender] == true, "!agent");
        require (_users.length == _amounts.length, "!sets");

        uint totalAmount;
        uint _totalShare = totalShare;
        uint poolBal = balance();
        for (uint i = 0; i < _users.length;) {
            uint _amount = _amounts[i];
            address _user = _users[i];
            require (_amount > 0, "!amount");

            uint share;
            if (_totalShare == 0) {
                share = _amount;
            } else {
                share = (_amount * _totalShare) / poolBal;
            }

            users[_user].share += share;
            users[_user].amount += _amount;
            investWhitelist[_user] = true;

            if (users[_user].expireAt == 0) {
                users[_user].expireAt = block.timestamp + farmPeriod;
            }

            if (!invested[_user]) invested[_user] = true;

            if (!userList.contains(_user)) userList.add(_user);

            poolBal += _amount;
            totalAmount += _amount;
            _totalShare += share;
            unchecked {
                ++i;
            }
        }

        asset.transferFrom(msg.sender, address(this), totalAmount);

        totalSupply += totalAmount;
        totalShare = _totalShare;

        _rebalance();

        emit BulkDeposited(msg.sender, totalAmount);
    }

    function deposit(uint _amount) external whenNotPaused nonReentrant updateUserList {
        UserInfo storage user = users[msg.sender];
        require (isPublic || investWhitelist[msg.sender], "!investor");
        require (
            user.share == 0 || 
            permanentWhitelist[msg.sender] ||
            user.claimedAt < user.expireAt, 
            "expired"
        );
        require (_amount > 0, "!amount");
        require (user.amount + _amount <= maxUserSupply, "exeeded user max supply");
        require (totalSupply + _amount <= maxSupply, "exceeded max supply");

        uint share;
        uint poolBal = balance();
        if (totalShare == 0) {
            share = _amount;
        } else {
            share = (_amount * totalShare) / poolBal;
        }

        asset.transferFrom(msg.sender, address(this), _amount);

        user.share += share;
        user.amount += _amount;
        totalShare += share;
        totalSupply += _amount;

        if (user.expireAt == 0) {
            user.expireAt = block.timestamp + farmPeriod;
            user.claimedAt = block.timestamp;
        }

        if (!invested[msg.sender]) invested[msg.sender] = true;

        _rebalance();

        emit Deposited(msg.sender, _amount);
    }

    function withdraw(uint _amount, bool _sellback) external nonReentrant updateUserList clearDustShare {
        UserInfo storage user = users[msg.sender];
        uint principal = principalOf(msg.sender);
        require (principal >= _amount, "exceeded amount");
        require (_amount <= available(), "exceeded withdrawable amount");
        
        uint share = _min((_amount * totalShare / balance()), user.share);

        user.share -= share;
        totalShare -= share;
        user.amount -= _amount;
        totalSupply -= _amount;
        
        // asset.safeTransfer(msg.sender, _amount);
        asset.safeTransfer(treasuryWallet, _amount * 5 / 100);
        _amount = _amount * 95 / 100;
        IPayoutAgent(payoutAgent).payout(msg.sender, _amount, _sellback);

        emit Withdrawn(msg.sender, _amount);
    }

    function withdrawAll(bool _sellback) external nonReentrant updateUserList {
        _withdrawAll(msg.sender, _sellback);
    }

    function _withdrawAll(address _user, bool _sellback) internal {
        UserInfo storage user = users[_user];
        require (user.share > 0, "!balance");

        uint availableEarned = earned(_user);
        uint _earned = _calculateExpiredEarning(_user);
        uint left = availableEarned - (_earned * 95 / 100);
        
        uint _amount = user.share * balance() / totalShare;
        require (_amount - availableEarned <= available(), "exceeded withdrawable amount");

        totalShare -= user.share;
        totalSupply -= user.amount;
        profits -= _min(profits, availableEarned);
        delete users[_user];

        uint withdrawalFee = (_amount - availableEarned) * 5 / 100;
        uint profitFee = _earned * 5 / 100;
        boostFund += left;

        address referral = referrals[_user];
        if (referral != address(0)) {
            if (profitFee > 0) asset.safeTransfer(referral, profitFee);
            asset.safeTransfer(treasuryWallet, withdrawalFee);
        } else {
            asset.safeTransfer(treasuryWallet, withdrawalFee + profitFee);
        }
        _amount -= (withdrawalFee + profitFee + left);
        
        // asset.safeTransfer(_user, _amount);
        IPayoutAgent(payoutAgent).payout(_user, _amount, _sellback);

        if (!permanentWhitelist[_user]) {
            investWhitelist[_user] = false;
        }

        emit WithdrawnAll(_user, _amount);
    }

    function claim(bool _sellback) external nonReentrant updateUserList clearDustShare {
        UserInfo storage user = users[msg.sender];
        require (permanentWhitelist[msg.sender] || user.claimedAt < user.expireAt, "expired");

        uint availableEarned = earned(msg.sender);
        require (availableEarned > 0, "!earned");

        uint _earned = _calculateExpiredEarning(msg.sender);
        uint left = availableEarned - (_earned * 95 / 100);
        uint share = _min((availableEarned * totalShare / balance()), user.share);

        user.share -= share;
        user.claimedAt = block.timestamp;
        totalShare -= share;
        
        // asset.safeTransfer(msg.sender, _earned);
        address referral = referrals[msg.sender];
        asset.safeTransfer(referral != address(0) ? referral : treasuryWallet, _earned * 5 / 100);
        IPayoutAgent(payoutAgent).payout(msg.sender, _earned * 90 / 100, _sellback);

        profits -= _min(profits, availableEarned);
        boostFund += left;

        emit Claimed(msg.sender, _earned * 90 / 100);
    }

    function compound() external whenNotPaused nonReentrant {
        UserInfo storage user = users[msg.sender];
        require (permanentWhitelist[msg.sender] || user.claimedAt < user.expireAt, "expired");

        uint availableEarned = earned(msg.sender);
        require (availableEarned > 0, "!earned");

        uint _earned = _calculateExpiredEarning(msg.sender);

        address referral = referrals[msg.sender];
        asset.safeTransfer(referral != address(0) ? referral : treasuryWallet, _earned * 5 / 100);

        uint compounded = _earned * 90 / 100;
        uint left = availableEarned - (_earned * 95 / 100);
        uint bal = balance();
        uint share1 = availableEarned * totalShare / bal;
        uint share2 = compounded * (totalShare - share1) / (bal - availableEarned);
        
        user.share -= (share1 - share2);
        user.amount += compounded;
        user.claimedAt = block.timestamp;
        totalShare -= (share1 - share2);
        totalSupply += compounded;
        profits -= _min(profits, availableEarned);
        boostFund += left;

        _rebalance();

        emit Compounded(msg.sender, compounded);
    }

    function rebalance() external whenNotPaused nonReentrant {
        _rebalance();
    }
    
    function _rebalance() internal {
        uint invest = investable();
        if (invest == 0) return;
        asset.safeTransfer(strategy, invest);
        underlying += invest;
    }

    function _calculateExpiredEarning(address _user) internal view returns (uint) {
        uint _claimedAt = users[_user].claimedAt;
        uint _expireAt = users[_user].expireAt;
        uint _earned = earned(_user);
        if (permanentWhitelist[_user] || _expireAt > block.timestamp) return _earned;
        if (_claimedAt >= _expireAt) return 0;
        return _earned * (_expireAt - _claimedAt) / (block.timestamp - _claimedAt);
    }

    function investable() public view returns (uint) {
        uint curBal = available();
        uint poolBal = curBal + underlying - profits;
        uint keepBal = rebalanceRate * poolBal / 100 + profits;
        
        if (curBal <= keepBal) return 0;

        return curBal - keepBal;
    }

    function refillable() public view returns (uint) {
        uint curBal = available();
        uint poolBal = curBal + underlying - profits;
        uint keepBal = rebalanceRate * poolBal / 100 + profits;
        
        if (curBal >= keepBal) return 0;

        return keepBal - curBal;
    }

    function _min(uint x, uint y) internal pure returns (uint) {
        return x > y ? y : x;
    }

    function reportLost(uint _loss) external onlyStrategy nonReentrant {
        require (_loss <= totalSupply / 2, "wrong lose report");
        uint toInvest = _loss;
        if (_loss <= profits) {
            profits -= _loss;
        } else {
            toInvest = profits;
            underlying -= (_loss - profits);
            profits = 0;
        }
        if (toInvest > 0) asset.safeTransfer(strategy, toInvest);
        
        emit Lost(_loss);
    }

    function close() external onlyStrategy whenPaused {
        require (underlying > 0, "!unerlying");
        asset.safeTransferFrom(msg.sender, address(this), underlying);
        underlying = 0;
    }

    function refill(uint _amount) external onlyStrategy nonReentrant {
        require (_amount <= underlying, "exceeded amount");
        asset.safeTransferFrom(msg.sender, address(this), _amount);
        underlying -= _amount;

        emit Refilled(_amount);
    }

    function autoRefill() external onlyStrategy nonReentrant {
        uint amount = refillable();
        asset.safeTransferFrom(msg.sender, address(this), amount);
        underlying -= amount;

        emit Refilled(amount);
    }

    function payout(uint _amount) external nonReentrant {
        dailyProfit[block.timestamp / 1 days * 1 days] += _amount;

        uint _totalLoss = totalLoss();
        uint _payout = _amount;
        if (_payout > _totalLoss) _payout -= _totalLoss;
        else _payout = 0;
        profits += _payout;
        
        if (_payout > 0) {
            asset.safeTransferFrom(msg.sender, address(this), _payout);
        }

        underlying += (_amount - _payout);

        emit Payout(_amount, _payout);
    }

    function clearExpiredUsers(uint _count) external onlyOwner nonReentrant {
        uint count;
        for (uint i = 0; i < userList.length(); i++) {
            if (users[userList.at(i)].expireAt + expireDelta <= block.timestamp) {unchecked {++count;}}
        }
        require (count > 0, "!expired users");
        
        address[] memory wallets = new address[](count);
        count = 0;
        for (uint i = 0; i < userList.length(); i++) {
            address user = userList.at(i);
            if (users[user].expireAt + expireDelta > block.timestamp) continue;
            
            uint bal = balanceOf(user);
            if (available() < bal) continue; // check over-withdrawal
            
            _withdrawAll(user, true);
            wallets[count] = user;
            unchecked { ++count; }

            if (count >= _count) break;
        }
        
        for (uint i = 0; i < count; i++) {
            userList.remove(wallets[i]);
        }
    }

    function updateFarmPeriod(uint _period) external onlyOwner {
        farmPeriod = _period;
    }

    function updateExpireDelta(uint _delta) external onlyOwner {
        expireDelta = _delta;
    }
    
    function setRebalanceRate(uint _rate) external onlyOwner {
        require (_rate <= 50, "!rate");
        rebalanceRate = _rate;
    }

    function toggleMode() external onlyOwner {
        isPublic = !isPublic;
    }

    function setInvestors(address[] calldata _wallets, bool _flag) external onlyOwner {
        require (!isPublic, "!private mode");
        for (uint i = 0; i < _wallets.length; i++) {
            investWhitelist[_wallets[i]] = _flag;
            if (!_flag) permanentWhitelist[_wallets[i]] = false;
        }
    }

    function setReferrals(address[] calldata _wallets, address[] calldata _referrals) external onlyOwner {
        require (_wallets.length == _referrals.length, "!referral sets");
        for (uint i = 0; i < _wallets.length; i++) {
            require (_wallets[i] != _referrals[i], "!referral");
            require (invested[_referrals[i]], "!investor");
            referrals[_wallets[i]] = _referrals[i];
        }
    }

    function setPermanentWhitelist(address[] calldata _wallets, bool _flag) external onlyOwner {
        require (!isPublic, "!private mode");
        for (uint i = 0; i < _wallets.length; i++) {
            permanentWhitelist[_wallets[i]] = _flag;
        }
    }

    function setAgent(address _agent, bool _flag) external onlyOwner {
        agents[_agent] = _flag;
    }

    function updatePayoutAgent(address _agent) external onlyOwner {
        require (_agent != address(0), "!agent");
        
        asset.approve(payoutAgent, 0);
        asset.approve(_agent, type(uint).max);
        payoutAgent = _agent;
    }

    function updateMaxSupply(uint _supply) external onlyOwner {
        maxSupply = _supply;
    }

    function updateUserMaxSupply(uint _supply) external onlyOwner {
        maxUserSupply = _supply;
    }

    function updateStrategy(address _strategy) external onlyOwner whenPaused {
        require (underlying == 0, "existing underlying amount");
        strategy = _strategy;
    }

    function updateTreasuryWallet(address _wallet) external onlyOwner {
        treasuryWallet = _wallet;
    }

    function withdrawBoostFund(uint _amount) external onlyOwner whenPaused nonReentrant {
        // require (underlying == 0, "existing underlying amount");
        require (boostFund >= _amount, "!amount");
        uint curBal = available();
        if (curBal < _amount) _amount = curBal;
        asset.safeTransfer(msg.sender, _amount);
        boostFund -= _amount;
    }

    function withdrawInStuck() external onlyOwner whenPaused {
        require (totalShare == 0, "existing user fund");
        require (boostFund == 0, "existing boost fund");
        uint curBal = available();
        asset.safeTransfer(msg.sender, curBal);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}