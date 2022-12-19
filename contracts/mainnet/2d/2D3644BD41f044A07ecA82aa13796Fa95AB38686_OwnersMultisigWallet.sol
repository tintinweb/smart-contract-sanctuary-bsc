/**
 *Submitted for verification at BscScan.com on 2022-12-19
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

// File: OwnersMultisigVault.sol


pragma solidity ^0.8.4;


/* MINTZ Owners Wallet */
contract OwnersMultisigWallet {

    // Contract Owners.
    mapping (address => bool) public owners;
    uint public ownersCount = 0;
    address[] public ownersList;

    constructor() {
        owners[0xC37Aa088df4E94F5377577a5e9d38052663f3aEc] = true; 
        owners[0x0a47C83a97Ca48DF1d63600f2499B7999D5363eE] = true;
        owners[0x13a6c02BD128087Eb9252f14908735b185B79F61] = true;
        owners[0xEDEa6E95c90acfBb7f4D1d8CDc4e79d7a937E4BC] = true;
        owners[0x08b6f8bDF66E3bd6ACdF1faE927DE782DB2b7C49] = true;

        ownersList.push(0xC37Aa088df4E94F5377577a5e9d38052663f3aEc);
        ownersList.push(0x0a47C83a97Ca48DF1d63600f2499B7999D5363eE);
        ownersList.push(0x13a6c02BD128087Eb9252f14908735b185B79F61);
        ownersList.push(0xEDEa6E95c90acfBb7f4D1d8CDc4e79d7a937E4BC);
        ownersList.push(0x08b6f8bDF66E3bd6ACdF1faE927DE782DB2b7C49);

        ownersCount = 5;
    }
    
    // Number of owners required to approve a transaction.
    uint public quorum = 3;

    // Ticket Duration.
    uint public ticketDuration = 1 days;
    uint public ticketExpirity = 7 days;

    struct ERC20WithdrawalTicket {
        uint creationTimestamp;
        uint value;
        address[] voters;
        address to;
        address token;
        bool used;
    }

    struct WithdrawalTicket {
        uint creationTimestamp;
        uint value;
        address[] voters;
        address to;
        bool used;
    }

    struct DistributionWithdrawalTicket {
        uint creationTimestamp;
        uint value;
        address[] voters;
        address token;
        bool used;
    }

    // Arrays of tickets.
    ERC20WithdrawalTicket[] public ERC20WithdrawalTickets;
    WithdrawalTicket[] public WithdrawalTickets;
    DistributionWithdrawalTicket[] public DistributionWithdrawalTickets;

    /*
     * @dev Function to check if an address is an owner of the contract.
     * @param _owner Address to check.
     * @return True if the address is an owner, false otherwise.
     */
    function isOwner(address _owner) public view returns (bool) {
        return owners[_owner];
    }

    /*
     * @dev Function to check if an address is a voter of a ticket.
     * @param _ticketId Id of the ticket.
     * @param _voter Address to check.
     * @return True if the address is a voter, false otherwise.
     */
    function isERC20WithdrawalVoter(uint _ticketId, address _voter) public view returns (bool) {
        address[] memory voters = ERC20WithdrawalTickets[_ticketId].voters;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    /*
     * @dev Function to check if an address is a voter of a ticket.
     * @param _ticketId Id of the ticket.
     * @param _voter Address to check.
     * @return True if the address is a voter, false otherwise.
     */
    function isWithdrawalVoter(uint _ticketId, address _voter) public view returns (bool) {
        address[] memory voters = WithdrawalTickets[_ticketId].voters;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    /*
     * @dev Function to check if an address is a voter of a ticket.
     * @param _ticketId Id of the ticket.
     * @param _voter Address to check.
     * @return True if the address is a voter, false otherwise.
     */
    function isDistributionWithdrawalVoter(uint _ticketId, address _voter) public view returns (bool) {
        address[] memory voters = DistributionWithdrawalTickets[_ticketId].voters;
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    /*
     * @dev Function to vote for a ticket.
     * @param _ticketId Id of the ticket.
     * @return True if the vote was successful, false otherwise.
     */
    function voteWithdrawal(uint256 _ticketId) public onlyOwners onlyOnceWithdrawal(_ticketId) returns (bool) {
        require(WithdrawalTickets[_ticketId].creationTimestamp + ticketDuration > block.timestamp);
        WithdrawalTickets[_ticketId].voters.push(msg.sender);
        return true;
    }

    /*
     * @dev Function to vote for a ticket.
     * @param _ticketId Id of the ticket.
     * @return True if the vote was successful, false otherwise.
     */
    function voteERC20Withdrawal(uint256 _ticketId) public onlyOwners onlyOnceERC20Withdrawal(_ticketId) returns (bool) {
        require(ERC20WithdrawalTickets[_ticketId].creationTimestamp + ticketDuration > block.timestamp);
        ERC20WithdrawalTickets[_ticketId].voters.push(msg.sender);
        return true;
    }

    /*
     * @dev Function to vote for a ticket.
     * @param _ticketId Id of the ticket.
     * @return True if the vote was successful, false otherwise.
     */
    function voteDistributionWithdrawal(uint256 _ticketId) public onlyOwners onlyOnceDistributionWithdrawal(_ticketId) returns (bool) {
        require(DistributionWithdrawalTickets[_ticketId].creationTimestamp + ticketDuration > block.timestamp);
        DistributionWithdrawalTickets[_ticketId].voters.push(msg.sender);
        return true;
    }

    // function to create a withdrawal ticket.
    function createWithdrawalTicket(address _to, uint256 _amount) public onlyOwners returns (bool) {
        WithdrawalTicket memory ticket = WithdrawalTicket({
            creationTimestamp: block.timestamp,
            value: _amount,
            voters: new address[](0),
            to: _to,
            used: false
        });

        WithdrawalTickets.push(ticket);
        return true;
    }

    // function to create a ERC20 withdrawal ticket.
    function createERC20WithdrawalTicket(address _to, uint256 _amount, address _token) public onlyOwners returns (bool) {
        ERC20WithdrawalTicket memory ticket = ERC20WithdrawalTicket({
            creationTimestamp: block.timestamp,
            value: _amount,
            voters: new address[](0),
            to: _to,
            token: _token,
            used: false
        });

        ERC20WithdrawalTickets.push(ticket);
        return true;
    }

    // function to create a distribution ticket.
    function createDistributionWithdrawalTicket(uint256 _amount, address _token) public onlyOwners returns (bool) {
        DistributionWithdrawalTicket memory ticket = DistributionWithdrawalTicket({
            creationTimestamp: block.timestamp,
            value: _amount,
            voters: new address[](0),
            token: _token,
            used: false
        });

        DistributionWithdrawalTickets.push(ticket);
        return true;
    }

    // function to withdraw a ticket.
    function withdrawTicket(uint256 _ticketId) public onlyOwners onlyOnceTickets(_ticketId) {
        WithdrawalTicket memory ticket = WithdrawalTickets[_ticketId];

        require(ticket.voters.length >= quorum && block.timestamp < ticket.creationTimestamp + ticketExpirity, "Expired or not enough quorum.");
            
        WithdrawalTickets[_ticketId].used = true;

        (bool sentToTarget,) = ticket.to.call{value: ticket.value}("");
        require(sentToTarget, "Failed to send ether.");
    
    
    }

    // function to withdraw a ERC20 ticket.
    function withdrawERC20Ticket(uint256 _ticketId) public onlyOwners onlyOnceERC20Tickets(_ticketId) {
        ERC20WithdrawalTicket memory ticket = ERC20WithdrawalTickets[_ticketId];

        require(ticket.voters.length >= quorum && block.timestamp < ticket.creationTimestamp + ticketExpirity, "Expired or not enough quorum.");
            
        ERC20WithdrawalTickets[_ticketId].used = true;
        
        ERC20 token = ERC20(ticket.token);
        token.transfer(ticket.to, ticket.value);

    }

    // function to distribute a token to all owners equally.
    function withdrawDistributeTokensTicket(uint256 _ticketId) public onlyOwners onlyOnceDistributionTickets(_ticketId) {

        DistributionWithdrawalTicket memory ticket = DistributionWithdrawalTickets[_ticketId];

        require(ticket.voters.length >= quorum && block.timestamp < ticket.creationTimestamp + ticketExpirity, "Expired or not enough quorum.");
            
        DistributionWithdrawalTickets[_ticketId].used = true;
        
        ERC20 token = ERC20(ticket.token);
        uint256 amount = ticket.value / ownersCount;
        for (uint i = 0; i < ownersCount; i++) {
            token.transfer(ownersList[i], amount);
        }
        
    }

    function changeOwner(address _newOwner, address _oldOwner) public onlyOwners {
        require(msg.sender == _oldOwner, "You can only change your own address.");
        for (uint i = 0; i < ownersCount; i++) {
            if (ownersList[i] == msg.sender) {
                ownersList[i] = _newOwner;
                owners[_newOwner] = true;
                owners[_oldOwner] = false;
                break;
            }
        }
    }


    // modifier to allow only once.
    modifier onlyOnceWithdrawal(uint256 _ticketId) {
        require(!isWithdrawalVoter(_ticketId, msg.sender), "You can only vote once.");

        _;
    }

    // modifier to allow only once.
    modifier onlyOnceERC20Withdrawal(uint256 _ticketId) {
        require(!isERC20WithdrawalVoter(_ticketId, msg.sender), "You can only vote once.");

        _;
    }

    modifier onlyOnceDistributionWithdrawal(uint256 _ticketId) {
        require(!isDistributionWithdrawalVoter(_ticketId, msg.sender), "You can only vote once.");

        _;
    }

    // modifier to allow only owners.
    modifier onlyOwners {
        require(owners[msg.sender], "You must be an owner to perform this action.");

        _;
    }

    modifier onlyOnceTickets(uint256 _ticketId) {
        require(!WithdrawalTickets[_ticketId].used, "You can only withdraw once.");
        _;
    }

    modifier onlyOnceERC20Tickets(uint256 _ticketId) {
        require(!ERC20WithdrawalTickets[_ticketId].used, "You can only withdraw once.");
        _;
    }

    modifier onlyOnceDistributionTickets(uint256 _ticketId) {
        require(!DistributionWithdrawalTickets[_ticketId].used, "You can only withdraw once.");
        _;
    }
    


}