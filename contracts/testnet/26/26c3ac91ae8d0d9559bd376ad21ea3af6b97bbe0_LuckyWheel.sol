/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
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

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
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
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
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

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
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
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

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
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
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
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
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

// File: contracts/LuckyWheel.sol


pragma solidity ^0.8.0;





contract LuckyWheel is Ownable {
    mapping (address => uint) private adminList;
    mapping (address => uint) private blackList;

    // a list keeps track balances of each token in contract
    mapping (address => uint) private tokenAmount;
    // a list of contract's default token
    address[] private tokenList;
    // a list of exchange rates used when user turn wheel
    uint[] public exchangeRates;

    uint minimumTokenTurningWheel;
    uint maximumTokenTurningWheel;
    // where unfund token is sent
    address addressFund;

    constructor(address[] memory _tokenAddresses, uint[] memory amounts, 
                uint[] memory _exchangeRates,
                uint _minimumTokenTurningWheel, uint _maximumTokenTurningWheel, address _addressFund) {
        adminList[msg.sender] = 1;

        require(_tokenAddresses.length == amounts.length, "Number of tokens and number of amounts must be the same");
        require(_addressFund != address(0), "Address fund must not be address zero");

        for (uint i = 0; i < _tokenAddresses.length; ++i) {
            require(amounts[i] > 0, "Amount must be greater than 0");
            if (tokenAmount[_tokenAddresses[i]] == 0) {
                tokenList.push(_tokenAddresses[i]);
            }
            tokenAmount[_tokenAddresses[i]] = amounts[i];
        }

        for (uint i = 0; i < exchangeRates.length; ++i) {
            exchangeRates.push(_exchangeRates[i]);
        }

        minimumTokenTurningWheel = _minimumTokenTurningWheel;
        maximumTokenTurningWheel = _maximumTokenTurningWheel;
        addressFund = _addressFund;
    }

    /*
===================================================
                    MODIFIERS
===================================================
 */

    modifier onlyAdmin() {
        require(adminList[_msgSender()] == 1, "OnlyAdmin");
        _;
    }

    modifier isNotInBlackList(address account) {
        require(!checkBlackList(account), "Revert blacklist");
        _;
    }

    modifier isNotAddressZero(address account) {
        require(account != address(0), "ERC20: transfer from the zero address");
        _;
    }
    /*
===================================================
                    CHECK FUNCTION
===================================================
 */
    function checkAdmin(address account) public view returns (bool) {
        return adminList[account] > 0;
    }

    function checkBlackList(address account) public view returns (bool) {
        return blackList[account] > 0;
    }

    /*
===================================================
                    ADD/REMOVE TOKEN
===================================================
 */

    /**
     * Add new token to contract's default token list
     */
    function addToken(address tokenAddress) public onlyAdmin {
        // if the token is already in the list
        if (checkTokenSupported(tokenAddress)) {
            return;
        }

        tokenList.push(tokenAddress);
        tokenAmount[tokenAddress] = 0;

        emit AddedToken(tokenAddress, msg.sender);
    }

    /**
     * Fund a token with amount.
     * Admin must approve for contract before calling this function.
     * The funded token is not need to be in default token list.
     */
    function fundToken(address tokenAddress, uint amount) public onlyAdmin {
        IERC20 token = IERC20(tokenAddress);
        // send token from admin to contract
        token.transferFrom(msg.sender, address(this), amount);
        tokenAmount[tokenAddress] += amount;

        emit FundToken(tokenAddress, amount, msg.sender);
    }

    /**
     * Combine addToken(address) and fundToken(address, uint).
     */
    function addTokenWithFund(address tokenAddress, uint amount) public onlyAdmin {
        addToken(tokenAddress);
        fundToken(tokenAddress, amount);
    }

    /**
     * Remove a token from default token list.
     */
    function removeToken(address tokenAddress) public onlyAdmin {
        // find position of the token in default token list
        uint index = indexOfToken(tokenAddress);

        // if the token doesn't exist in the list
        if (index == tokenList.length) {
            return;
        }

        // Shift all tokens in the right of removed token to left 1 move
        for (uint i = index; i < tokenList.length - 1; ++i) {
            tokenList[i] = tokenList[i+1];
        }
        tokenList.pop();

        // Sent all removed token's amount to addressFund
        if (tokenAmount[tokenAddress] != 0) {
            IERC20 token = IERC20(tokenAddress);
            token.transfer(addressFund, tokenAmount[tokenAddress]);
            tokenAmount[tokenAddress] = 0;
        }
        
        emit RemovedToken(tokenAddress, msg.sender);
    }

    /**
     * Unfund a token.
     * The undfunded token is not need to be in default token list.
     * The token's amount will be transfered to a default address
     */
    function unfundToken(address tokenAddress) public onlyAdmin {
        // if there is nothing to unfund
        if (tokenAmount[tokenAddress] == 0) {
            return;
        }

        // send token's amount to addressFund
        IERC20 token = IERC20(tokenAddress);
        token.transfer(msg.sender, tokenAmount[tokenAddress]);
        tokenAmount[tokenAddress] = 0;

        emit UnfundToken(tokenAddress, msg.sender);
    }

    /**
     * Return amount of a token in contract
     */
    function checkTokenAmount(address tokenAddress) public view returns (uint) {
        return tokenAmount[tokenAddress];
    }

    /**
     * Check if a token is in contract's default token list
     */
    function checkTokenSupported(address tokenAddress) public view returns (bool) {
        return indexOfToken(tokenAddress) != tokenList.length;
    }

    /**
     * Return position of a token in contract's default token list.
     * If the token is not presented in the list, return length of the list.
     */
    function indexOfToken(address tokenAddress) internal view returns (uint) {
        for (uint i = 0; i < tokenList.length; ++i) {
            if (tokenList[i] == tokenAddress) {
                return i;
            }
        }

        return tokenList.length;
    }


    /*
===================================================
                    ADD/REMOVE EXCHANGE RATE
===================================================
 */

    function addExchangeRate(uint exchangeRate) public onlyAdmin {
        if (!checkExchangeRateExist(exchangeRate)) {
            exchangeRates.push(exchangeRate);
            emit AddedExchangeRate(exchangeRate, msg.sender);
        }
    }

    function removeExchangeRate(uint exchangeRate) public onlyAdmin {
        uint index = indexOfExchangeRate(exchangeRate);
        if (index == exchangeRates.length) {
            return;
        }

        for (uint i = index; i < exchangeRates.length - 1; ++i) {
            exchangeRates[i] = exchangeRates[i+1];
        }
        exchangeRates.pop();
        emit RemovedExchangeRate(exchangeRate, msg.sender);
    }

    function checkExchangeRateExist(uint exchangeRate) public view returns (bool) {
        return indexOfExchangeRate(exchangeRate) != exchangeRates.length;
    }

    function indexOfExchangeRate(uint exchangeRate) internal view returns (uint) {
        for (uint i = 0; i < exchangeRates.length; ++i) {
            if (exchangeRates[i] == exchangeRate) {
                return i;
            }
        }

        return exchangeRates.length;
    }

    /*
===================================================
                    TURN WHEEL
===================================================
 */

    function turnWheel(address tokenAddress, uint amount) public isNotInBlackList(msg.sender) {
        require(minimumTokenTurningWheel <= amount, "Amount is too small");
        require(amount <= maximumTokenTurningWheel, "Amount is too big");

        // send user's token to contract
        // this step will ensure that user approved contract before turning wheel
        IERC20 inToken = IERC20(tokenAddress);
        inToken.transferFrom(msg.sender, address(this), amount);
        tokenAmount[tokenAddress] += amount;

        // random an exchange rate from exchange rate list
        uint exchangeRate = randomExchangeRate();
        // calculate number of tokens user will receive
        uint award = (amount * exchangeRate) / 100;

        // if contract has enough tokens to pay user
        if (tokenAmount[tokenAddress] >= award) {
            inToken.transfer(msg.sender, award);
        } else { //  find another token in the default token list to pay user
            address outTokenAddress = findFirstSufficientToken(award);

            // if contract cannot find another token to pay user, revert the transaction
            if (outTokenAddress == address(0)) {
                revert("Sorry! Contract cannot fund you!");
            }

            // pay user
            IERC20 outToken = IERC20(outTokenAddress);
            outToken.transfer(msg.sender, award);
        }

        emit TurnedWheel(tokenAddress, amount, exchangeRate, msg.sender);
    }

    /**
     * Return address of the first token in the default token list of which amount is greater or equal to `award`
     * If there is no such token, return address(0)
     */
    function findFirstSufficientToken(uint amount) internal view returns (address) {
        for (uint i = 0; i < tokenList.length; ++i) {
            if (tokenAmount[tokenList[i]] >= amount) {
                return tokenList[i];
            }
        }

        return address(0);
    }

    /*
===================================================
                    ADMINLIST
===================================================
 */

    function addToAdminlist(address account) external onlyOwner {
        adminList[account] = 1;
        emit AddedAdmin(account);
    }

    function addBatchToAdminlist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            adminList[accounts[i]] = 1;
        }
        emit AddedBatchAdmin(accounts);
    }

    function removeFromAdminlist(address account) external onlyOwner {
        adminList[account] = 0;
        emit RemovedAdmin(account);
    }

        /*
===================================================
                    BLACKLIST
===================================================
 */

    function addToBlacklist(address account) external onlyOwner {
        blackList[account] = 1;
        emit AddedBlackAccount(account);
    }

    function addBatchToBlacklist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            blackList[accounts[i]] = 1;
        }
        emit AddedBatchBlackAccount(accounts);
    }

    function removeFromBlacklist(address account) external onlyOwner {
        blackList[account] = 0;
        emit RemovedBlackAccount(account);
    }

    /*
===================================================
                    RANDOM
===================================================
 */

    /**
     * Generate a "random" number in [0; max)
     */
    function rand(uint max) internal view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));

        return seed % max;
    }

    /**
     * Generate a random exchange rate from contract's exchange rate list
     */
    function randomExchangeRate() internal view returns (uint) {
        return exchangeRates[rand(exchangeRates.length)];
    }

        /*
===================================================
                    EVENT
===================================================
 */
    event AddedToken(address tokenAddress, address admin);
    event FundToken(address tokenAddress, uint amount, address admin);
    event RemovedToken(address tokenAddress, address admin);
    event UnfundToken(address tokenAddress, address admin);

    event AddedExchangeRate(uint exchangeRate, address admin);
    event RemovedExchangeRate(uint exchangeRate, address admin);

    event TurnedWheel(address tokenAddress, uint amount, uint exchangeRate, address user);

    event AddedAdmin(address account);
    event AddedBatchAdmin(address[] accounts);
    event RemovedAdmin(address account);

    event AddedBlackAccount(address account);
    event AddedBatchBlackAccount(address[] accounts);
    event RemovedBlackAccount(address account);

}