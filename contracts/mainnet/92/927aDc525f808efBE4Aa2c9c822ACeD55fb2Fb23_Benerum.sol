/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: Contracts/BEP20.sol



pragma solidity ^0.8.0;




contract BEP20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor() {
        _name = "Benerum";
        _symbol = "Bener";
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);

        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "Benerum: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "Benerum: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(
            sender != address(0),
            "Benerum: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "Benerum: transfer to the zero address"
        );

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "Benerum: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Benerum: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(
            currentAllowance >= amount,
            "Benerum: burn amount exceeds allowance"
        );
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "Benerum: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(
            accountBalance >= amount,
            "Benerum: burn amount exceeds balance"
        );
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "Benerum: approve from the zero address");
        require(spender != address(0), "Benerum: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File: Contracts/Access.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
abstract contract Access is Context {
    address private _owner;
    uint256 private _passcode;
    mapping(address => bool) private _isAdmin;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event AdminEvent(address indexed account, string message);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
        _isAdmin[_msgSender()] = true;
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
        require(owner() == _msgSender(), "Benerum: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner, uint256 passcode)
        public
        virtual
        onlyAdmin
    {
        require(_passcode == passcode, "Benerum: Invalid transaction");
        require(
            newOwner != address(0),
            "Benerum: new owner is the zero address"
        );

        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        _isAdmin[oldOwner] = false;
        _isAdmin[newOwner] = true;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Throws if called by any account other than an Admin.
     */
    modifier onlyAdmin() {
        require(_isAdmin[_msgSender()], "Benerum: Account is not an Admin");
        _;
    }

    function ownerPasscode(uint256 passcode) public virtual onlyOwner {
        _passcode = passcode;
    }

    /**
     * @dev Give any account Admin priviledge.
     */
    function addAdmin(address account, uint256 passcode)
        public
        virtual
        onlyAdmin
    {
        require(_passcode == passcode, "Benerum: Invalid transaction");
        require(account != address(0), "Benerum: account is the zero address");
        _isAdmin[account] = true;
        emit AdminEvent(account, "Account added to Admins");
    }

    /**
     * @dev Remove any account from the Admins.
     */
    function rmAdmin(address account) public virtual onlyAdmin {
        require(account != address(0), "Benerum: account is the zero address");
        require(account != _owner, "Benerum: It is owner account");
        _isAdmin[account] = false;
        emit AdminEvent(account, "Account removed from Admins");
    }
}

// File: Contracts/Settings.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";



abstract contract Settings is BEP20, Access {
    address private _teamWallet;
    uint256 private _teamFee;
    uint256 private _minAmount;
    mapping(address => uint256) private _balance;
    mapping(address => bool) private _isBenerian;

    constructor() {
        _teamFee = 6;
        _teamWallet = 0x85Db48bC276CF8740883c7e7f59C49f4e95C7211;
    }

    function setBenerianMin(uint256 amount) public onlyAdmin {
        _minAmount = totalSupply() / amount;
    }

    function getBenerianMin() public view virtual returns (uint256) {
        return _minAmount;
    }

    function benerian(uint256 amount) public virtual {
        require(
            amount >= getBenerianMin(),
            "Benerian: amount less than required amount"
        );
        address account = _msgSender();
        _burn(account, amount);
        uint256 oldBalance = _balance[account];
        _balance[account] += amount;
        _isBenerian[account] = true;
        assert(_balance[account] == oldBalance + amount);
    }

    function benerianBalance(address account)
        public
        view
        virtual
        returns (uint256)
    {
        return _balance[account];
    }

    function isBenerian(address account) internal virtual returns (bool) {
        return _isBenerian[account];
    }

    function setTeamWallet(address team) public onlyAdmin {
        _teamWallet = team;
    }

    function _getTeamWallet() internal view virtual returns (address) {
        return _teamWallet;
    }

    function _getTeamFee(address to) internal view virtual returns (uint256) {
        if (_isBenerian[to]) {
            return _teamFee;
        }
        return _teamFee + 2;
    }
}

// File: Contracts/Governance.sol



pragma solidity ^0.8.0;


abstract contract Governance is Settings {
    uint256 private _vDays;
    int256 private _weight;
    uint256 private _voteFee;

    struct Proposal {
        address proposer;
        int256 votes;
        uint256 endDate;
    }
    mapping(bytes32 => Proposal) private _proposals;
    mapping(bytes32 => mapping(address => bool)) private _hasVoted;
    event voteEvent(
        address indexed account,
        bytes32 indexed proposal,
        int256 indexed vote
    );
    event proposalEvent(
        address indexed account,
        bytes32 indexed proposal,
        uint256 indexed endDate
    );

    constructor() {
        _vDays = 14;
        _weight = 1;
        _voteFee = 100 * 10**18;
    }

    function setVoteDuration(uint256 _days) public virtual {
        _vDays = _days;
    }

    function getVoteDuration() public view virtual returns (uint256) {
        return _vDays;
    }

    function setVoteFee(uint256 fee) public virtual {
        _voteFee = fee;
    }

    function getVoteFee() public view virtual returns (uint256) {
        return _voteFee;
    }

    function vote(bytes32 proposal, int256 choice) public virtual {
        require(
            choice == 1 || choice == -1,
            "Benerum: choice can only be 1 or -1"
        );
        address account = _msgSender();
        require(!_hasVoted[proposal][account], "Benerum: Already voted");
        Proposal storage _proposal = _proposals[proposal];
        require(_proposal.votes > 0, "Benerum: proposal not found");
        require(
            block.timestamp < _proposal.endDate,
            "Benerum: proposal expired"
        );
        _burn(account, _voteFee);
        int256 _vote;
        if (choice == 1) {
            if (isBenerian(account)) {
                _proposal.votes += _weight + 1;
                _vote = _weight + 1;
            } else {
                _proposal.votes += _weight;
                _vote = _weight;
            }
        } else {
            if (isBenerian(account)) {
                _proposal.votes -= _weight + 1;
                _vote -= _weight + 1;
            } else {
                _proposal.votes -= _weight;
                _vote -= _weight;
            }
        }
        _hasVoted[proposal][account] = true;
        assert(_hasVoted[proposal][account] == true);
        emit voteEvent(account, proposal, _vote);
    }

    function propose(bytes32 proposal) public virtual {
        require(isBenerian(_msgSender()), "Benerian: account not a benerian");
        Proposal storage _proposal = _proposals[proposal];
        require(_proposal.votes == 0, "Benerum: Proposal already exist");
        _burn(_msgSender(), (_voteFee * 2));
        _proposal.proposer = _msgSender();
        _proposal.endDate = block.timestamp + _vDays * 1 days;
        _proposal.votes = 1;
        assert(_proposal.votes == 1);
        emit proposalEvent(_msgSender(), proposal, _proposal.endDate);
    }

    function totalVote(bytes32 proposal) public view virtual returns (int256) {
        Proposal storage _proposal = _proposals[proposal];
        return _proposal.votes;
    }
}

// File: Contracts/Staking.sol



pragma solidity ^0.8.0;


abstract contract Staking is Governance {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _rewards;
    mapping(address => uint256) private _unlockDate;
    uint256 _amountWeight;

    event stakeEvent(
        address indexed account,
        uint256 indexed action,
        uint256 amount,
        uint256 balance,
        uint256 reward
    );

    function setStakeAmountWeight(uint256 amount) public onlyAdmin {
        _amountWeight = totalSupply() / amount;
    }

    function stakeAmountWeight() public view virtual returns (uint256) {
        return _amountWeight;
    }

    function stake(uint256 amount, uint256 duration) public virtual {
        require(duration >= 90, "Benerum: Duration too low");
        require(_amountWeight > 0, "Benerum: Stake inactive");
        address account = _msgSender();
        uint256 aWeight;
        if (amount > _amountWeight) {
            aWeight = amount / _amountWeight;
        } else {
            aWeight = 1;
        }
        uint256 dWeight = duration / 90;
        uint256 weight = aWeight + dWeight;
        uint256 reward = ((amount * weight) / uint256(100)) *
            (duration / uint256(30));
        _burn(account, amount);
        uint256 oldBalance = _balances[account];
        uint256 oldReward = _rewards[account];
        _balances[account] += amount;
        _rewards[account] += reward;
        uint256 _duration = block.timestamp + duration * 1 days;
        if (_duration > _unlockDate[account]) {
            _unlockDate[account] = _duration;
        }
        assert(
            _balances[account] == oldBalance + amount &&
                _rewards[account] == oldReward + reward
        );
        emit stakeEvent(
            account,
            1,
            amount,
            _balances[account],
            _rewards[account]
        );
    }

    function unStake() public virtual {
        address account = _msgSender();
        require(_balances[account] > 0, "Benerum: No stake found");
        require(
            block.timestamp > _unlockDate[account],
            "Benerum: Sorry, Not yet time"
        );
        uint256 amount = _balances[account] + _rewards[account];
        _balances[account] = 0;
        _rewards[account] = 0;
        require(
            _balances[account] == 0 && _rewards[account] == 0,
            "Benerum: Invalid transaction"
        );
        _mint(account, amount);
        _unlockDate[account] = 0;
        emit stakeEvent(
            account,
            0,
            amount,
            _balances[account],
            _rewards[account]
        );
    }

    function getStakeBalance(address account)
        public
        view
        virtual
        returns (uint256)
    {
        return _balances[account];
    }

    function getStakeReward(address account)
        public
        view
        virtual
        returns (uint256)
    {
        return _rewards[account];
    }

    function getStakeUnlockDate(address account)
        public
        view
        virtual
        returns (uint256)
    {
        return _unlockDate[account];
    }
}

// File: Contracts/Benerum.sol


pragma solidity ^0.8.2;

// import "./BEP20.sol";


contract Benerum is Staking {
    uint256 private _counter;
    struct Withdrawal {
        address to;
        uint256 amount;
        bool created;
        bool rejected;
        int256 validation;
        bool sent;
    }
    uint256 _wValidatorAmount;
    mapping(uint256 => Withdrawal) private _withdrawals;
    mapping(uint256 => mapping(address => bool)) private _hasValidate;
    event adEvent(address indexed account, bytes32 indexed id, uint256 amount);
    event withdrawEvent(
        address indexed account,
        uint256 indexed created,
        int256 value
    );
    event topicEvent(address indexed account, bytes32 indexed newTopic);

    constructor(){
        _mint(msg.sender, 50000000000 * 10**decimals());
        _wValidatorAmount = 500 * 10**18;
    }

    function setWValidatorAmount(uint256 amount) public onlyAdmin {
        _wValidatorAmount = amount;
    }

    function withdrawRequest(address to, uint256 amount) public onlyAdmin {
        _counter += 1;
        Withdrawal storage _withdrawal = _withdrawals[_counter];
        _withdrawal.to = to;
        _withdrawal.amount = amount;
        _withdrawal.created = true;
        assert(_withdrawal.created == true);
        emit withdrawEvent(to, _counter, 1);
    }

    function withdraw(uint256 id, int256 choice) public virtual {
        require(isBenerian(_msgSender()), "Benerian: account not a benerian");
        require(
            choice == 1 || choice == -1,
            "Benerum: choice can only be 1 or -1"
        );
        require(
            !_hasValidate[id][_msgSender()],
            "Benerum: Duplicate validation"
        );
        Withdrawal storage _withdrawal = _withdrawals[id];
        require(!_withdrawal.rejected, "Benerum: Withdrawal rejected");
        require(_withdrawal.created, "Benerum: Withdrawal request not found");
        if (_withdrawal.validation >= 5) {
            require(!_withdrawal.sent, "Benerum: Duplicate transaction");
            uint256 feeAmount = (_withdrawal.amount *
                _getTeamFee(_withdrawal.to)) / uint256(100);
            uint256 minerAmount = _withdrawal.amount - feeAmount;
            _withdrawal.sent = true;
            _mint(_withdrawal.to, minerAmount);
            _mint(_getTeamWallet(), feeAmount);
            _mint(_msgSender(), _wValidatorAmount);
            assert(_withdrawal.amount == minerAmount + feeAmount);
            emit withdrawEvent(
                _withdrawal.to,
                minerAmount,
                _withdrawal.validation
            );
        } else if (_withdrawal.validation <= -3) {
            _withdrawal.rejected = true;
            emit withdrawEvent(_withdrawal.to, 0, _withdrawal.validation);
        } else {
            _withdrawal.validation += choice;
            _hasValidate[id][_msgSender()] = true;
            assert(_hasValidate[id][_msgSender()] == true);
        }
    }

    function advert(uint256 amount, bytes32 _topic) public onlyAdmin {
        address account = _msgSender();
        _burn(account, amount);
        emit adEvent(account, _topic, amount);
    }
}