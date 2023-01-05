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

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// ----------------------------------------------------------------------------
// SYNTA token main contract (2022)
//
// Symbol       : SYNTA
// Name         : SYNTA
// Init supply  : 3.080.981
// Max supply   : 300.000.000 (burnable)
// Decimals     : 18
// ----------------------------------------------------------------------------
// SPDX-License-Identifier: MIT
// ----------------------------------------------------------------------------

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SYNTA is IERC20, Ownable, Pausable {
    mapping (address => mapping (address => uint)) private _allowances;
    
    mapping (address => uint) private _unfrozenBalances;

    mapping (address => uint) private _vestingNonces;
    mapping (address => mapping (uint => uint)) private _vestingAmounts;
    mapping (address => mapping (uint => uint)) private _unvestedAmounts;
    mapping (address => mapping (uint => uint)) private _vestingTypes; //0 - multivest, 1 - single vest, > 2 give by vester id
    mapping (address => mapping (uint => uint)) private _vestingReleaseStartDates;
    mapping (address => mapping (uint => uint)) private _vestingSecondPeriods;

    uint public maxSupply = 300_000_000e18;
    string private constant _name = "SYNTA";
    string private constant _symbol = "SYNTA";
    uint8 private constant _decimals = 18;
    uint private _totalSupply = 3_080_981e18;

    uint public constant vestingSaleFirstPeriod = 180 days;
    uint public constant vestingSaleSecondPeriod = 365 days; // 1/365 each day

    mapping (address => uint8) public vesters;

    bytes32 public immutable DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping (address => uint) public nonces;

    event Unvest(address indexed user, uint amount);

    constructor () {
        _unfrozenBalances[owner()] = _totalSupply;

        emit Transfer(address(0), owner(), _unfrozenBalances[owner()]);

        uint chainId = block.chainid;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                chainId,
                address(this)
            )
        );
    }

    receive() payable external {
        revert();
    }

    function getOwner() public override view returns (address) {
        return owner();
    }

    modifier onlyAllowedVester() {
        require (vesters[msg.sender] == 1, "SYNTA::vest: not vester");
        _;
    }

    /**
     * @dev Sets amount as the allowance of spender over the caller's tokens.
     * Returns a boolean value indicating whether the operation succeeded.
     * @param spender address of token spender
     * @param amount the number of tokens that are allowed to spend
     * Emits an {Approval} event
     */
    function approve(address spender, uint amount) external override whenNotPaused returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Moves amount tokens from the caller's account to recipient.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @param recipient address of user
     * @param amount amount of token that you want to send
     */
    function transfer(address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Moves amount tokens from src to dst using the
     * allowance mechanism
     * amount is then deducted from the caller's allowance.
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits a {Transfer} event.
     * @param sender address from
     * @param recipient address of user
     * @param amount amount of token that you want to send
     */
    function transferFrom(address sender, address recipient, uint amount) external override whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "SYNTA::transferFrom: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }
    /**
     * @dev Issue tokens to receiver address
     * @param receiver address receiver
     * @param amount issue amount
     */
    function issue(address receiver, uint amount) public onlyOwner {
        require(_totalSupply + amount <= maxSupply, "SYNTA::issue: _totalSupply cant be more than maxSupply");
        uint256 curUnfrozenBalance = _unfrozenBalances[receiver];
        require(curUnfrozenBalance + amount > curUnfrozenBalance, "SYNTA::issue: exceeds available amount");

        _unfrozenBalances[receiver] = curUnfrozenBalance + amount;
        _totalSupply = _totalSupply + amount;
        emit Transfer(address(0), receiver, amount);
    }

    /**
     * @notice This method can be used to change an account's ERC20 allowance by
     * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
     * need to send a transaction, and thus is not required to hold Ether at all. 
     * @dev Sets value as the allowance of spender over owner's tokens,
     * given owner's signed approval
     * @param owner address of token owner
     * @param spender address of token spender
     * @param amount the number of tokens that are allowed to spend
     * @param deadline the expiration date of the permit
     * @param v the recovery id
     * @param r outputs of an ECDSA signature
     * @param s outputs of an ECDSA signature
     */
    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external whenNotPaused {
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "SYNTA::permit: invalid signature");
        require(signatory == owner, "SYNTA::permit: unauthorized");
        require(block.timestamp <= deadline, "SYNTA::permit: signature expired");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Atomically increases the allowance granted to spender by the caller.
     * @param spender address of user
     * @param addedValue value of tokens 
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(address spender, uint addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to spender by the caller.
     * @param spender address of user
     * @param subtractedValue value of tokens 
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(address spender, uint subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "SYNTA::decreaseAllowance: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }
    
    /**
     * @dev This method is used to withdraw tokens from vesting
     * Emits a {Unvest} event.
     */
    function unvest() external whenNotPaused returns (uint unvested) {
        require (_vestingNonces[msg.sender] > 0, "SYNTA::unvest:No vested amount");
        for (uint i = 1; i <= _vestingNonces[msg.sender]; i++) {
            if (_vestingAmounts[msg.sender][i] == _unvestedAmounts[msg.sender][i]) continue;
            if (_vestingReleaseStartDates[msg.sender][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[msg.sender][i]) * _vestingAmounts[msg.sender][i] / (_vestingSecondPeriods[msg.sender][i] - _vestingReleaseStartDates[msg.sender][i]);
            if (toUnvest > _vestingAmounts[msg.sender][i]) {
                toUnvest = _vestingAmounts[msg.sender][i];
            } 
            uint totalUnvestedForNonce = toUnvest;
            toUnvest -= _unvestedAmounts[msg.sender][i];
            unvested += toUnvest;
            _unvestedAmounts[msg.sender][i] = totalUnvestedForNonce;
        }
        _unfrozenBalances[msg.sender] += unvested;
        emit Unvest(msg.sender, unvested);
    }

    /**
     * @dev Transfer frozen funds to user
     * @param user address of user
     * @param amount SYNTA amount 
     * Emits a {Transfer} event.
     */
    function vest(address user, uint amount, uint vestingSaleStart, uint vestingSaleEnd) external onlyAllowedVester {
        _vest(user, amount, 1, vestingSaleStart, vestingSaleEnd);
    }

    /**
     * @dev Transfer frozen funds to user on purchase
     * @param user address of user
     * @param amount SYNTA amount 
     * Emits a {Transfer} event.
     */
    function vestPurchase(address user, uint amount) external onlyAllowedVester {
        _transfer(msg.sender, owner(), amount);
        _vest(user, amount, 1, block.timestamp + vestingSaleFirstPeriod, block.timestamp + vestingSaleFirstPeriod + vestingSaleSecondPeriod);
    }

    /**
     * @dev Destroys the number of tokens from the owner account, reducing the total supply.
     * can be called only from the owner account
     * @param amount the number of tokens that will be burned
     * Emits a {Transfer} event.
     */
    function burnTokens(uint amount) external onlyOwner returns (bool success) {
        require(amount <= _unfrozenBalances[owner()], "SYNTA::burnTokens: exceeds available amount");

        uint256 ownerBalance = _unfrozenBalances[owner()];
        require(ownerBalance >= amount, "SYNTA::burnTokens: burn amount exceeds owner balance");

        _unfrozenBalances[owner()] = ownerBalance - amount;
        _totalSupply -= amount;
        emit Transfer(owner(), address(0), amount);
        return true;
    }

    /**
     * @dev Returns the remaining number of tokens that spender will be
     * allowed to spend on behalf of owner through {transferFrom}. 
     * This is zero by default.
     * This value changes when {approve} or {transferFrom} are called
     * @param owner address of token owner
     * @param spender address of token spender
     */
    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowances[owner][spender];
    }

    function decimals() external override pure returns (uint8) {
        return _decimals;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view override returns (uint) {
        return _totalSupply;
    }

    /**
     * @dev View method that returns the number of tokens owned by account
     * and vesting balance
     * @param account address of user
     */
    function balanceOf(address account) external view override returns (uint) {
        uint amount = _unfrozenBalances[account];
        if (_vestingNonces[account] == 0) return amount;
        for (uint i = 1; i <= _vestingNonces[account]; i++) {
            amount = amount + _vestingAmounts[account][i] - _unvestedAmounts[account][i];
        }
        return amount;
    }

    /**
     * @notice View method to get available for unvesting volume
     * @param user address of user
     */
    function availableForUnvesting(address user) external view returns (uint unvestAmount) {
        if (_vestingNonces[user] == 0) return 0;
        for (uint i = 1; i <= _vestingNonces[user]; i++) {
            if (_vestingAmounts[user][i] == _unvestedAmounts[user][i]) continue;
            if (_vestingReleaseStartDates[user][i] > block.timestamp) break;
            uint toUnvest = (block.timestamp - _vestingReleaseStartDates[user][i]) * _vestingAmounts[user][i] / (_vestingSecondPeriods[user][i] - _vestingReleaseStartDates[user][i]);
            if (toUnvest > _vestingAmounts[user][i]) {
                toUnvest = _vestingAmounts[user][i];
            } 
            toUnvest -= _unvestedAmounts[user][i];
            unvestAmount += toUnvest;
        }
    }

    /**
     * @notice View method to get available for transfer amount
     * @param account address of user
     */
    function availableForTransfer(address account) external view returns (uint) {
        return _unfrozenBalances[account];
    }

    /**
     * @notice View method to get vesting Information
     * @param user address of user
     * @param nonce nonce of current lock
     */
    function vestingInfo(address user, uint nonce) external view returns (uint vestingAmount, uint unvestedAmount, uint vestingReleaseStartDate, uint vestingSecondPeriod, uint vestType) {
        vestingAmount = _vestingAmounts[user][nonce];
        unvestedAmount = _unvestedAmounts[user][nonce];
        vestingReleaseStartDate = _vestingReleaseStartDates[user][nonce];
        vestingSecondPeriod = _vestingSecondPeriods[user][nonce];
        vestType = _vestingTypes[user][nonce];
    }

    /**
     * @notice View method to get last vesting nonce for user 
     * @param user address of user
     */
    function vestingNonces(address user) external view returns (uint lastNonce) {
        return _vestingNonces[user];
    }

    function _approve(address owner, address spender, uint amount) private {
        require(owner != address(0), "SYNTA::_approve: approve from the zero address");
        require(spender != address(0), "SYNTA::_approve: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint amount) private {
        require(sender != address(0), "SYNTA::_transfer: transfer from the zero address");
        require(recipient != address(0), "SYNTA::_transfer: transfer to the zero address");

        uint256 senderAvailableBalance = _unfrozenBalances[sender];
        require(senderAvailableBalance >= amount, "SYNTA::_transfer: amount exceeds available for transfer balance");
        _unfrozenBalances[sender] = senderAvailableBalance - amount;
        _unfrozenBalances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _vest(address user, uint amount, uint vestType, uint vestingReleaseStart, uint vestingReleaseSecondPeriod) private {
        require(user != address(0), "SYNTA::_vest: vest to the zero address");
        require(vestingReleaseStart >= 0, "SYNTA::_vest: vesting release start date should be more then 0");
        require(vestingReleaseSecondPeriod >= vestingReleaseStart, "SYNTA::_vest: vesting release end date should be more then start date");
        require(amount > 0, "SYNTA::_vest: vesting amount should be more then 0");
        uint nonce = ++_vestingNonces[user];
        _vestingAmounts[user][nonce] = amount;
        _vestingReleaseStartDates[user][nonce] = vestingReleaseStart;
        _vestingSecondPeriods[user][nonce] = vestingReleaseSecondPeriod;
        _unfrozenBalances[owner()] -= amount;
        _vestingTypes[user][nonce] = vestType;
        emit Transfer(owner(), user, amount);
    }

    /**
     * @dev This method is used to add new vesters
     * can be called only from the owner account
     * @param vester new vester 
     * @param isActive boolean condition
     */
    function updateVesters(address vester, bool isActive) external onlyOwner { 
        vesters[vester] = isActive ? 1 : 0;
    }
    
    /**
     * @dev This method is used to withdraw any ERC20 tokens from the contract
     * can be called only from the owner account
     * @param tokenAddress token address
     * @param tokens token amount
     */
    function transferAnyERC20Token(address tokenAddress, uint tokens) external onlyOwner returns (bool success) {
        return IERC20(tokenAddress).transfer(owner(), tokens);
    }

    /**
     * @notice Sets Contract as paused
     * @param isPaused  Pausable mode
     */
    function setPaused(bool isPaused) external onlyOwner {
        if (isPaused) _pause();
        else _unpause();
    }
}