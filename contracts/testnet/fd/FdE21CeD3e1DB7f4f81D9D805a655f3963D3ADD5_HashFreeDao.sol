/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)
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


contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IHashFreeDao {
    function getRelations(address _address) external view returns(uint8 count, address[] memory);
    function payToken() external view returns(address);
    function setReferral(address origin, address referral) external;
}


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)
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

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


contract HashFreeDao is ERC20Detailed, Pausable, Ownable, IHashFreeDao {
    uint256 private _totalSupply;
    IERC20 private usdt;

    uint256 public ReferralFee = 1;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public operators;
    mapping(address => bool) public minters;
    mapping(address => bool) public blackList;

    // origin => referrals, should be private
    mapping(address => address[]) private referrals;
    mapping(address => address[]) private underlings;
    mapping(address => uint8) private referralCount;
    mapping(address => uint256) private underCount;
    // not allowed join relation
    mapping(address => bool) public singles;

    event SetReferral(address origin, address referral);
    event Betray(address origin);

    modifier onlyOperator() {
        require(operators[_msgSender()], "only operator");
        _;
    }

    modifier onlyMinter() {
        require(minters[_msgSender()], "only minter");
        _;
    }

    constructor(IERC20 _payToken) ERC20Detailed("FreeCoin", "FreeCoin", 0) {
        setOperator(address(this), true);
        setOperator(owner(), true);
        setMinter(owner(), true);
        singles[address(this)] = true;
        usdt = _payToken;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getRelations(address _address)
        external
        view
        override
        returns (uint8 count, address[] memory)
    {
        return (referralCount[_address], referrals[_address]);
    }

    function getUnderlings(address _address)
        public
        view
        returns (uint256 count, address[] memory)
    {
        return (underCount[_address], underlings[_address]);
    }

    function payToken() public view override returns (address) {
        return address(usdt);
    }

    function setOperator(address operator, bool flag) public onlyOwner {
        operators[operator] = flag;
    }

    function setReferralFee(uint256 fee) public onlyOwner {
        ReferralFee = fee;
    }

    function setMinter(address minter, bool flag) public onlyOwner {
        minters[minter] = flag;
        if (flag) {
            singles[minter] = flag; // minter should be single
        }
    }

    function setBlackList(address[] memory blacks, bool flag) public onlyOwner {
        for (uint256 i = 0; i < blacks.length; ++i) {
            blackList[blacks[i]] = flag;
        }
    }

    // @Notice: init set must before user get hashfree
    function setSingles(address[] memory _singles, bool flag) public onlyOperator {
        for (uint256 i = 0; i < _singles.length; ++i) {
            singles[_singles[i]] = flag;
        }
    }

    function setReferral(address _origin, address _referral)
        public
        override
        onlyOperator
    {
        if (canBeReferral(_origin, _referral)) _setReferral(_origin, _referral);
    }

    function _setReferral(address _origin, address _referral) private {
        if (singles[_origin] || singles[_referral]) {
            return;
        }
        // set referral to origin's relation
        require(underCount[_origin] == 0, "origin has underlings");
        require(referralCount[_origin] == 0, "origin has referral");
        referrals[_origin].push(_referral);
        referralCount[_origin] += 1;
        
        // get referral's relation transparent to origin
        uint8 count = referralCount[_referral];
        if (count > 0) {
            count = count >= 9 ? 9 : count;
            referralCount[_origin] += count;
            for (uint256 i = 0; i < count; i++) {
                address uperReferral = referrals[_referral][i];
                if (uperReferral != address(0)) {
                    referrals[_origin].push(uperReferral);
                }
            }
        }
        emit SetReferral(_origin, _referral);
        // record immdeatly uplings
        underlings[_referral].push(_origin);
        underCount[_referral] += 1;
    }

    function betray(address target) public onlyOperator {
        uint8 count = referralCount[target];
        require(count > 0, "no need betray");
        delete referrals[target];
        referralCount[target] = 0;
        emit Betray(target);
    }

    function canBeReferral(address _origin, address _referral)
        public
        view
        returns (bool)
    {
        return (!singles[_origin] &&
            !singles[_referral] &&
            referralCount[_origin] == 0 &&
            underCount[_origin] == 0);
    }

    function withdraw(address _token, address _to) public onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }

    // ==========  detail for erc20 ==========
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function mint(address spender, uint256 amount)
        public
        onlyMinter
        returns (bool)
    {
        _mint(spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount >= 1, "invalid amount");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        uint256 referralFee;
        // if "to" not referral & underlings, "from" become "to"'s referral
        if (canBeReferral(to, from)) {
            _setReferral(to, from);
            referralFee = ReferralFee;
        }
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        amount -= referralFee; // reduce referral fee
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    // without trigger referral
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal whenNotPaused {
        require(!blackList[from] && !blackList[to], "in black list");
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}