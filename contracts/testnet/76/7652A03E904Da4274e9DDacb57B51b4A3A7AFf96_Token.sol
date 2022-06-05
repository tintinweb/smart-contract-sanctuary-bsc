// Developed by CryptoLeaks
// This contract is a vesting contract developed for Binance Smart Chain

// Sources flattened with hardhat v2.9.3 https://hardhat.org

//SPDX-License-Identifier: Unlicense


//

pragma solidity ^0.8.0;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

pragma solidity ^0.8.0;

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

// File @openzeppelin/contracts/utils/[email protected]

//
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

pragma solidity ^0.8.0;

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
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
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
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
    ) internal virtual {
        require(from != address(0), " transfer from the zero address");
        require(to != address(0), " transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, " transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), " mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, " burn amount exceeds balance");
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
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, " insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

//

pragma solidity ^0.8.0;

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
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
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File contracts/Token.sol

//Developed by CryptoLeaks

pragma solidity ^0.8.0;

contract Token is ERC20, ERC20Burnable, Ownable {
    uint256 private START_TIME = 0;

    // **********************************************************************************
    // **********************    Change vesting Period here    **********************
    // **********************************************************************************
    uint256 vestingPeriod = 5 minutes;

    string NAME = "PsPay";
    string SYMBOL = "PSPY";
    uint256 SUPPLY = 750000000;

    bool vesting_started = false;
    struct Vesting {
        uint256 nextReleaseTime;
        uint256 initialReleaseAmount;
        uint256 monthlyReleaseAmount;
        uint256 cyclesLeft;
    }

    // @dev - holds Launchpad address, vesting percentage
    struct Source {
        uint256 _initialReleasePercentage;
        uint256 _monthlyReleasePercentage;
        bool isSet;
    }

    mapping(address => Source) private _listedSource;
    mapping(address => uint256) private _freeTokens;
    mapping(address => Vesting[]) private _userVestings;
    mapping(address => uint256) private _amountVested;

    event AddSource(
        address _address,
        uint256 _initialReleasePercentage,
        uint256 _monthlyReleasePercentage
    );

    event ManualUnfreeze(address _address, uint256 _amount);

    constructor() ERC20(NAME, SYMBOL) {
        ERC20._mint(msg.sender, SUPPLY * 10**decimals());
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function setStartTime(uint256 date) external onlyOwner {
        require(
            date > block.timestamp,
            "Start time should be greater than current time"
        );

        require(vesting_started == false, "Cannot change Vesting start date");
        START_TIME = date;
        vesting_started = true;
    }

    function startTime() external view returns (uint256) {
        return START_TIME;
    }

    function addSource(
        address _sourceAddress,
        uint256 _initialReleasePercentage,
        uint256 _monthlyReleasePercentage
    ) external onlyOwner {
        require(_sourceAddress != address(0), "Cannot add address 0");
        require(_sourceAddress != owner(), "Cannot add owner as listed source");

        require(
            _listedSource[_sourceAddress].isSet == false,
            "Source Already exists"
        );

        require(
            _initialReleasePercentage < 100,
            "Invalid initial release percentage"
        );
        require(
            _monthlyReleasePercentage < 100,
            "Invalid monthly release percentage"
        );

        require(
            _initialReleasePercentage > 0,
            "Invalid initial release percentage"
        );
        require(
            _monthlyReleasePercentage > 0,
            "Invalid monthly release percentage"
        );

        require(
            (100 - _initialReleasePercentage) % _monthlyReleasePercentage == 0,
            "Invalid Release Percentages"
        );

        _listedSource[_sourceAddress] = Source(
            _initialReleasePercentage,
            _monthlyReleasePercentage,
            true
        );

        emit AddSource(
            _sourceAddress,
            _initialReleasePercentage,
            _monthlyReleasePercentage
        );
    }

    function checkSource(address _sourceAddress) public view returns (bool) {
        return _listedSource[_sourceAddress].isSet;
    }

    function addVesting(
        address to,
        uint256 amount,
        uint256 initialReleaseTime,
        uint256 initialReleasePercentage,
        uint256 monthlyReleasePercentage
    ) private {
        require(vesting_started == true, "Vesting not yet started");

        uint256 initialReleaseAmount = (amount * initialReleasePercentage) /
            100;
        uint256 monthlyReleaseAmount = (amount * monthlyReleasePercentage) /
            100;

        uint256 cycles = 100 - initialReleasePercentage;
        cycles = cycles / monthlyReleasePercentage;
        cycles = cycles + 1;

        _userVestings[to].push(
            Vesting(
                initialReleaseTime,
                initialReleaseAmount,
                monthlyReleaseAmount,
                cycles
            )
        );
    }

    function tokensToBeReleased(address user) private view returns (uint256) {
        uint256 _tokenTobeReleased = 0;
        uint256 _nextRelease;
        uint256 _cycles;
        for (uint256 i = 0; i < _userVestings[user].length; i++) {
            _nextRelease = _userVestings[user][i].nextReleaseTime;
            _cycles = _userVestings[user][i].cyclesLeft;
            if (_cycles > 0 && block.timestamp >= _nextRelease) {
                if (_userVestings[user][i].initialReleaseAmount > 0) {
                    _nextRelease += vestingPeriod;
                    _tokenTobeReleased += _userVestings[user][i]
                        .initialReleaseAmount;
                    _cycles--;
                }

                if (block.timestamp >= _nextRelease) {
                    uint256 cyclesPassed = 1 +
                        ((block.timestamp - _nextRelease) / vestingPeriod);
                    uint256 cyclesToBePaid = min(_cycles, cyclesPassed);

                    _tokenTobeReleased +=
                        cyclesToBePaid *
                        _userVestings[user][i].monthlyReleaseAmount;
                }
            }
        }
        return _tokenTobeReleased;
    }

    function unFreeze(address user) private {
        for (uint256 i = 0; i < _userVestings[user].length; i++) {
            if (
                _userVestings[user][i].cyclesLeft > 0 &&
                block.timestamp >= _userVestings[user][i].nextReleaseTime
            ) {
                if (_userVestings[user][i].initialReleaseAmount > 0) {
                    _freeTokens[user] += _userVestings[user][i]
                        .initialReleaseAmount;
                    _userVestings[user][i].initialReleaseAmount = 0;
                    _userVestings[user][i].nextReleaseTime += vestingPeriod;

                    _amountVested[user] += _userVestings[user][i]
                        .initialReleaseAmount;

                    _userVestings[user][i].cyclesLeft--;
                }
                if (block.timestamp >= _userVestings[user][i].nextReleaseTime) {
                    uint256 cyclesPassed = 1 +
                        ((block.timestamp -
                            _userVestings[user][i].nextReleaseTime) /
                            vestingPeriod);

                    uint256 cyclesToBePaid = min(
                        _userVestings[user][i].cyclesLeft,
                        cyclesPassed
                    );

                    _amountVested[user] +=
                        cyclesToBePaid *
                        _userVestings[user][i].monthlyReleaseAmount;

                    _freeTokens[user] +=
                        cyclesToBePaid *
                        _userVestings[user][i].monthlyReleaseAmount;

                    _userVestings[user][i].cyclesLeft -= cyclesToBePaid;

                    _userVestings[user][i].nextReleaseTime += (cyclesPassed *
                        vestingPeriod);
                }
            }
        }
    }

    function getVestingCycles(address user) public view returns (uint256) {
        uint256 count = 0;
        uint256 _nextRelease;
        for (uint256 i = 0; i < _userVestings[user].length; i++) {
            if (_userVestings[user][i].cyclesLeft > 0) {
                _nextRelease = _userVestings[user][i].nextReleaseTime;
                uint256 localCount = 0;
                if (block.timestamp >= _nextRelease) {
                    if (_userVestings[user][i].initialReleaseAmount > 0) {
                        _nextRelease += vestingPeriod;
                        localCount++;
                    }
                    if (block.timestamp >= _nextRelease) {
                        uint256 cyclesPassed = 1 +
                            ((block.timestamp - _nextRelease) / vestingPeriod);
                        uint256 cyclesToBePaid = min(
                            _userVestings[user][i].cyclesLeft,
                            cyclesPassed
                        );
                        localCount += (cyclesToBePaid);
                    }
                    count += (_userVestings[user][i].cyclesLeft - localCount);
                }
            }
        }
        return count;
    }

    function getFreeTokens(address user) public view returns (uint256) {
        return _freeTokens[user] + tokensToBeReleased(user);
    }

    function getAmonuntVested(address user) public view returns (uint256) {
        return _amountVested[user] + tokensToBeReleased(user);
    }

    function getFrozenTokens(address user) public view returns (uint256) {
        return balanceOf(user) - getFreeTokens(user);
    }

    // For Owner to send Frozen Tokens
    function sendFrozen(
        address to,
        uint256 amount,
        uint256 initialReleasePercentage,
        uint256 monthlyReleasePercentage
    ) public onlyOwner {
        transfer(to, amount);

        //will also call _afterTokenTransfer

        _freeTokens[to] -= amount; //  free tokens will be increased by _afterTokenTransfer > this line reverts this.

        if (block.timestamp < START_TIME) {
            addVesting(
                to,
                amount,
                START_TIME,
                initialReleasePercentage,
                monthlyReleasePercentage
            );
        } else {
            addVesting(
                to,
                amount,
                block.timestamp + vestingPeriod,
                initialReleasePercentage,
                monthlyReleasePercentage
            );
        }
    }

    //  @dev - for owner to unfreeze amount in a wallet;
    function unfreezeAmount(address user, uint256 amount) external onlyOwner {
        require(amount <= getFrozenTokens(user), "Not enough frozen tokens");
        require(amount > 0, "Amount should be greater than 0");

        unFreeze(user);

        uint256 amountReleased = 0;
        for (uint256 i = 0; i < _userVestings[user].length && amount > 0; i++) {
            if (_userVestings[user][i].cyclesLeft > 0) {
                if (_userVestings[user][i].initialReleaseAmount > 0) {
                    _freeTokens[user] += _userVestings[user][i]
                        .initialReleaseAmount;
                    _amountVested[user] += _userVestings[user][i]
                        .initialReleaseAmount;

                    amountReleased += _userVestings[user][i]
                        .initialReleaseAmount;

                    if (amount > _userVestings[user][i].initialReleaseAmount) {
                        amount -= _userVestings[user][i].initialReleaseAmount;
                    } else {
                        amount = 0;
                    }
                    _userVestings[user][i].initialReleaseAmount = 0;
                }
                if (amount > 0) {
                    uint256 cyclesToBeSkipped = amount /
                        _userVestings[user][i].monthlyReleaseAmount;
                    uint256 cyclesSkipped = min(
                        _userVestings[user][i].cyclesLeft,
                        cyclesToBeSkipped
                    );

                    _freeTokens[user] +=
                        cyclesSkipped *
                        _userVestings[user][i].monthlyReleaseAmount;
                    _amountVested[user] +=
                        cyclesSkipped *
                        _userVestings[user][i].monthlyReleaseAmount;

                    amountReleased +=
                        cyclesSkipped *
                        _userVestings[user][i].monthlyReleaseAmount;

                    _userVestings[user][i].cyclesLeft -= cyclesSkipped;

                    amount -=
                        cyclesSkipped *
                        _userVestings[user][i].monthlyReleaseAmount;

                    if (
                        _userVestings[user][i].cyclesLeft > 0 &&
                        amount < _userVestings[user][i].monthlyReleaseAmount &&
                        amount > 0
                    ) {
                        _freeTokens[user] += _userVestings[user][i]
                            .monthlyReleaseAmount;
                        _amountVested[user] += _userVestings[user][i]
                            .monthlyReleaseAmount;
                        amountReleased += _userVestings[user][i]
                            .monthlyReleaseAmount;
                        amount = 0;
                        _userVestings[user][i].cyclesLeft--;
                    }
                }

                _userVestings[user][i].nextReleaseTime =
                    block.timestamp +
                    vestingPeriod;
            }
        }

        emit ManualUnfreeze(user, amountReleased);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        unFreeze(from);

        if (from != address(0)) {
            require(amount <= _freeTokens[from], "Not Enough free tokens");
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        if (_listedSource[from].isSet == true && to != owner()) {
            addVesting(
                to,
                amount,
                block.timestamp + vestingPeriod,
                _listedSource[from]._initialReleasePercentage,
                _listedSource[from]._monthlyReleasePercentage
            );
        } else {
            _freeTokens[to] += amount;
        }

        if (from != address(0)) {
            unchecked {
                _freeTokens[from] -= amount;
            }
        }
        super._afterTokenTransfer(from, to, amount);
    }
}