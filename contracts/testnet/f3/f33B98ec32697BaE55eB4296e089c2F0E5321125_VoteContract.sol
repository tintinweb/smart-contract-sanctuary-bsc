/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library Counters {
    struct Counter {
        uint256 _value;
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        counter._value = value - 1;
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

abstract contract Pausable is Context {

    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract Whitelist is Ownable {

    modifier onlyWhitelisted() {
        if(active){
            require(whitelist[msg.sender], 'not whitelisted');
        }
        _;
    }

    bool active = true;

    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    function activateDeactivateWhitelist() public onlyOwner() {
        active = !active;
    }

    function addAddressToWhitelist(address addr) public onlyOwner() returns(bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

    function addAddressesToWhitelist(address[] calldata addrs) public onlyOwner() returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    function removeAddressFromWhitelist(address addr) onlyOwner() public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }

    function removeAddressesFromWhitelist(address[] calldata addrs) onlyOwner() public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }
}

// DegenGovernance.sol
// This contract is 'vSH33P', representative of on-chain vote weight.
contract VoteToken is ERC20, ERC20Burnable, Pausable, Whitelist {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //////////////////
    // DATA STRUCTS //
    //////////////////

    struct AddressData {
        uint256 received;
        uint256 transferred;

        uint256 xReceived;
        uint256 xTransferred;
    }

    ///////////////////////////////
    // CONFIGURABLES & VARIABLES //
    ///////////////////////////////
    
    mapping(address => AddressData) private _addressData;
    mapping(address => bool) private _whitelisted;
    mapping(address => bool) private _permittedContract;

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(address minter) ERC20("SH33P Vote Token", "vSH33P") {
        _whitelisted[msg.sender] = true;
        _whitelisted[minter] = true;
    }

    receive() external payable {
        revert();
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Check if a contract is permitted for use with this token
    function isPermittedContract(address _contract) public view returns (bool) {
        return _permittedContract[_contract];
    }

    //////////////////////////
    // RESTRICTED FUNCTIONS //
    //////////////////////////

    // Mint tokens to an address
    function mint(address to, uint256 amount) public onlyWhitelisted {
        _mint(to, amount);
    }

    // Batch-mint tokens to an array of addresses
    function batchMint(address[] memory _recipients, uint256[] memory _amounts) public onlyWhitelisted {
        require(_recipients.length == _amounts.length, "INVALID_LENGTH");

        for (uint256 i = 0; i < _recipients.length; i++) {
            _mint(_recipients[i], _amounts[i]);
        }
    }

    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Pause the contract
    function pause() public onlyOwner {
        _pause();
    }

    // Unpause the contract
    function unpause() public onlyOwner {
        _unpause();
    }

    // Add a contract to the permitted list
    function setPermittedContract(address _contract, bool _allowed) public onlyOwner {
        _permittedContract[_contract] = _allowed;
    }

    ////////////////////////
    // INTERNAL FUNCTIONS //
    ////////////////////////

    // Record transfer stats for sender and recipient, by amount and instance
    function _recordStats(address _from, address _to, uint256 _amount) internal {
        _addressData[_to].received += _amount;
        _addressData[_from].transferred += _amount;

        _addressData[_to].xReceived++;
        _addressData[_from].xTransferred++;
    }

    // Contract overrides before a transfer
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal whenNotPaused override {

        // Count transfer stats for both addresses
        _recordStats(from, to, amount);

        // Check if either address is a contract
        bool fromIsContract = Address.isContract(from);
        bool toIsContract = Address.isContract(to);

        // If from is a contract, require permitted
        if (fromIsContract) {
            require(_permittedContract[from], "CONTRACT_NOT_PERMITTED");
        }

        // If to is a contract, require permitted
        if (toIsContract) {
            require(_permittedContract[to], "CONTRACT_NOT_PERMITTED");
        }
    }
}

// VoteRewards.sol
// Users deposit xToken in this contract (5% fee in and out), from which they can earn vToken.
contract VoteRewards is ReentrancyGuard, Pausable, Whitelist {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== MODIFIERS ========== */

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== STATE VARIABLES ========== */

    IERC20 public voteToken;
    IERC20 public lockToken;

    uint256 public distributionFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    /* ========== EVENTS ========== */

    event RewardAdded(uint256 reward);
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    /* ========== CONSTRUCTOR ========== */

    constructor(address _rewardsToken, address _stakingToken) Ownable() {
        voteToken = IERC20(_rewardsToken);
        lockToken = IERC20(_stakingToken);
    }

    /* ========== VIEWS ========== */

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < distributionFinish ? block.timestamp : distributionFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
            );
    }

    function earned(address account) public view returns (uint256) {
        return _balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate.mul(rewardsDuration);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function deposit(uint256 amount) external nonReentrant whenNotPaused updateReward(msg.sender) {
        require(amount > 0, "Cannot deposit 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lockToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lockToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            voteToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward) external onlyWhitelisted() updateReward(address(0)) {

        // If the distribution has finished,
        if (block.timestamp >= distributionFinish) {

            // Set the reward rate and go again!
            rewardRate = reward.div(rewardsDuration);
        } else { // Otherwise,

            // Find remaining time on distribution
            uint256 remaining = distributionFinish.sub(block.timestamp);

            // Calculate rewards not distributed
            uint256 leftover = remaining.mul(rewardRate);

            // Add reward to remains and start window again
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        // Get the balance of voteTokens
        uint balance = voteToken.balanceOf(address(this));

        // Require rate to be equal or less than balance divided by time
        require(rewardRate <= balance.div(rewardsDuration), "Provided reward too high");

        // Set timestamps
        lastUpdateTime = block.timestamp;
        distributionFinish = block.timestamp.add(rewardsDuration);

        // Tell the network
        emit RewardAdded(reward);
    }

    // Added to support recovering LP Rewards from other systems such as BAL to be distributed to holders
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(lockToken), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        require(block.timestamp > distributionFinish, "STAKING_ALREADY_ACTIVE");
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }
}

// VoteContract.sol
// This contract holds the proposal, and handles tokens used for voting.
contract VoteContract is Whitelist, Pausable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    ///////////////
    // MODIFIERS //
    ///////////////

    modifier lockedIs(bool _set) {
        require(proposalLocked == _set, "VoteContract: NOT_SET");
        _;
    }

    modifier requiresVotes() {
        require(voteToken.balanceOf(msg.sender) > 0, "VoteToken: NO_VOTING_WEIGHT");
        _;
    }

    modifier withNoVoteTokenBalanceOnly() {
        require(voteToken.balanceOf(address(this)) == 0, "VoteToken: TOKENS_IN_CONTRACT");
        _;
    }

    ////////////////
    // INTERFACES //
    ////////////////

    IERC20 public voteToken;
    VoteRewards public voteRewards;

    Counters.Counter private proposalId;

    ///////////////////////////////
    // CONFIGURABLES & VARIABLES //
    ///////////////////////////////

    bool public proposalLocked;

    uint256 public totalVotes;
    uint256 public withdrawableTokens;

    struct ProposalData {
        string title;
        string description;
        
        uint256 totalOptions;

        uint256 startTime;
        uint256 finishTime;
        uint256 duration;

        bool refundable;
        bool passed;

        mapping(uint256 => string) _optionData;
    }

    struct AddressData {
        uint256 votes;
    }

    //////////////////
    // DATA MAPPING //
    //////////////////

    // Votes of each proposal
    mapping(uint8 => uint256) private _votesOf;

    // Mapping of proposal data
    mapping(uint256 => ProposalData) private _proposalData;

    // Per-proposal mapping of participant data
    mapping(uint256 => mapping(address => AddressData)) private _participantData;

    /////////////////////
    // CONTRACT EVENTS //
    /////////////////////

    event onVote(address indexed _voter, uint8 _optionId, uint256 _votes, uint256 _timestamp);

    event onProposalCreated(uint256 _proposalId, uint256 _timestamp);
    event onProposalPassed(uint256 _proposalId, uint256 _timestamp);
    event onProposalCancelled(uint256 _proposalId, uint256 _timestamp);

    event onRecoverTokens(uint256 _amount, uint256 _timestamp);
    event onResetOptions(uint256 _timestamp);

    ////////////////////////////
    // CONSTRUCTOR & FALLBACK //
    ////////////////////////////

    constructor(address _voteToken, address _voteRewards) {
        voteToken = IERC20(_voteToken);
        voteRewards = VoteRewards(_voteRewards);
        _pause();
    }

    ////////////////////
    // VIEW FUNCTIONS //
    ////////////////////

    // Get Start & Finish Time of this Proposal
    function getTimes() public view returns (uint256 startTime, uint256 finishTime) {
        startTime = _proposalData[proposalId.current()].startTime;
        finishTime = _proposalData[proposalId.current()].finishTime;
    }

    // Get Duration of this Proposal
    function getDuration() public view returns (uint256) {
        return _proposalData[proposalId.current()].duration;
    }

    // Get Remaining time to cast Votes
    function getRemainingTime() public view returns (uint256) {
        (, uint256 finishTime) = getTimes();

        if (finishTime > block.timestamp) {
            return (finishTime.sub(block.timestamp));
        }

        return 0;
    }

    // Get Remaining Vote Count
    function getRemainingVotes() public view returns (uint256) {
        return (voteToken.totalSupply().sub(voteToken.balanceOf(address(this))));
    }

    // Get votes of an option
    function getVotesOf(uint8 _optionId) public view returns (uint256) {
        return _votesOf[_optionId];
    }

    // Get details of an option
    function getOptionDetails(uint8 _optionId) public view returns (string memory _description) {
        return (_proposalData[proposalId.current()]._optionData[_optionId]);
    }

    // Get the title of the current proposal
    function getProposalTitle() public view returns (string memory _title) {
        return _proposalData[proposalId.current()].title;
    }

    // Get the description of the current proposal
    function getProposalDescription() public view returns (string memory _desc) {
        return _proposalData[proposalId.current()].description;
    }

    /////////////////////
    // WRITE FUNCTIONS //
    /////////////////////

    // Vote for an option (uses voteToken)
    function vote(uint8 _optionId, uint256 _votes) public whenNotPaused() nonReentrant() requiresVotes() returns (bool _success) {
        (uint256 startTime, uint256 finishTime) = getTimes();
        require(block.timestamp >= startTime, "VoteContract: VOTES_NOT_ENABLED");
        require(block.timestamp < finishTime, "VoteContract: PROPOSAL_EXPIRED");

        // Require voting for a valid option
        uint256 totalOptions = _proposalData[proposalId.current()].totalOptions;
        require(_optionId <= totalOptions, "VoteContract: INVALID_OPTION_ID");

        // Collect the vote tokens submitted by voter
        require(voteToken.transferFrom(msg.sender, address(this), _votes), "VoteContract: TRANSFER_FAILED");

        // Record the votes corresponding to choice
        _votesOf[_optionId] += _votes;
        _participantData[proposalId.current()][msg.sender].votes += _votes;

        // Tell the network!
        emit onVote(msg.sender, _optionId, _votes, block.timestamp);
        return true;
    }

    // Claim refund on a proposal (must be declared 'void / invalid')
    function claimRefund(uint256 _proposalId) public nonReentrant() returns (bool _success) {
        require(_proposalData[_proposalId].refundable, "VoteContract: IS_NOT_REFUNDABLE");

        uint256 _amount = _participantData[_proposalId][msg.sender].votes;
        _participantData[_proposalId][msg.sender].votes = 0;

        voteToken.transfer(msg.sender, _amount);

        return true;
    }

    //////////////////////////
    // RESTRICTED FUNCTIONS //
    //////////////////////////

    // Step 1: Create a Proposal || Proposal must be 'unlocked' || Contract must be 'paused'
    function createProposal(
        string memory _proposal, 
        uint256 _voteStartTime, 
        uint256 _voteDuration, 
        string[] memory options
    ) public onlyWhitelisted() whenPaused() lockedIs(false) returns (bool _success) {
        require(options.length > 0, "VoteContract: NO_OPTIONS_SET");

        // Lock the proposal
        proposalLocked = true;

        // Add options to the proposal
        for (uint256 i = 0; i < options.length; i++) {
            _proposalData[proposalId.current()]._optionData[i] = options[i];
        }

        // Store proposal data on-chain
        ProposalData storage pd = _proposalData[proposalId.current()];

        pd.description = _proposal;

        // Set times for voting
        pd.startTime = _voteStartTime;
        pd.duration = _voteDuration;
        pd.finishTime = (block.timestamp + _voteDuration);

        pd.refundable = false;
        pd.passed = false;

        // Tell the network
        emit onProposalCreated(proposalId.current(), block.timestamp);
        return true;
    }

    // Step 2: Conclude the vote || Proposal must be 'locked' || Contract must be 'unpaused'
    // If 'cancelProposal' is true, a refund for the finished proposal is triggered.
    function finishVote(bool _cancelProposal) public onlyOwner() whenNotPaused() lockedIs(true) {

        // Disable further voting
        proposalLocked = false;

        if (_cancelProposal) {
            _proposalData[proposalId.current()].refundable = true;
            _proposalData[proposalId.current()].passed = false;
            emit onProposalCancelled(proposalId.current(), block.timestamp);
        } else {
            withdrawableTokens += totalVotes;
            _proposalData[proposalId.current()].passed = true;
            emit onProposalPassed(proposalId.current(), block.timestamp);
        }

        totalVotes = 0;
        proposalId.increment();
    }

    // Step 3: Recover used tokens for re-use || Send to Pool for redistribution || Claim to caller for other purposes
    function processTokens(bool _sendToPool) public onlyOwner() whenPaused() returns (bool _success) {
        (, uint256 finishTime) = getTimes();
        require(block.timestamp >= finishTime, "VoteContract: NOT_ALLOWED_YET");

        // If tokens are for the staking pool,
        if (_sendToPool) {
            // Notifty staking pool of tokens for rewards
            voteRewards.notifyRewardAmount(withdrawableTokens);
        } else {
            // Transfer them to the caller
            voteToken.transfer(msg.sender, withdrawableTokens);
        }

        // Loop through all the options and reset them to zero
        for (uint8 i = 1; i <= _proposalData[proposalId.current()].totalOptions; i++) {
            _votesOf[i] = 0;
        }

        // Tell the network
        emit onRecoverTokens(withdrawableTokens, block.timestamp);
        return true;
    }


    //////////////////////////
    // OWNER-ONLY FUNCTIONS //
    //////////////////////////

    // Pause the contract
    function pause() public onlyOwner() {
        _pause();
    }

    // Unpause the contract
    function unpause() public onlyOwner() {
        _unpause();
    }
}