/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

pragma solidity ^0.5.1;

contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
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
    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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
    constructor(string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
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
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of `from`'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of `from`'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:using-hooks.adoc[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
}


interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address owner, uint256 id) public view returns (uint256);

    function balanceOfBatch(address[] memory owners, uint256[] memory ids) public view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata values, bytes calldata data) external;
}



contract IERC1155TokenReceiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    external
    returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
    external
    returns(bytes4);
}


library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See `IERC165.supportsInterface`.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See `IERC165.supportsInterface`.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


contract ERC1155 is ERC165, IERC1155
{
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to owner balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from owner to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    constructor()
    public
    {
        _registerInterface(
            ERC1155(0).safeTransferFrom.selector ^
            ERC1155(0).safeBatchTransferFrom.selector ^
            ERC1155(0).balanceOf.selector ^
            ERC1155(0).balanceOfBatch.selector ^
            ERC1155(0).setApprovalForAll.selector ^
            ERC1155(0).isApprovedForAll.selector
        );
    }

    /**
        @dev Get the specified address' balance for token with specified ID.
        @param owner The address of the token holder
        @param id ID of the token
        @return The owner's balance of the token type requested
     */
    function balanceOf(address owner, uint256 id) public view returns (uint256) {
        require(owner != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][owner];
    }

    /**
        @dev Get the balance of multiple account/token pairs
        @param owners The addresses of the token holders
        @param ids IDs of the tokens
        @return Balances for each owner and token id pair
     */
    function balanceOfBatch(
        address[] memory owners,
        uint256[] memory ids
    )
    public
    view
    returns (uint256[] memory)
    {
        require(owners.length == ids.length, "ERC1155: owners and IDs must have same lengths");

        uint256[] memory batchBalances = new uint256[](owners.length);

        for (uint256 i = 0; i < owners.length; ++i) {
            require(owners[i] != address(0), "ERC1155: some address in batch balance query is zero");
            batchBalances[i] = _balances[ids[i]][owners[i]];
        }

        return batchBalances;
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
        @notice Queries the approval status of an operator for a given owner.
        @param owner     The owner of the Tokens
        @param operator  Address of authorized operator
        @return           True if the operator is approved, false if not
    */
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
        @dev Transfers `value` amount of an `id` from the `from` address to the `to` address specified.
        Caller must be approved to manage the tokens being transferred out of the `from` account.
        If `to` is a smart contract, will call `onERC1155Received` on `to` and act appropriately.
        @param from Source address
        @param to Target address
        @param id ID of the token type
        @param value Transfer amount
        @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
    */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
    external
    {
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || _operatorApprovals[from][msg.sender] == true,
            "ERC1155: need operator approval for 3rd party transfers."
        );

        _balances[id][from] = _balances[id][from].sub(value);
        _balances[id][to] = value.add(_balances[id][to]);

        emit TransferSingle(msg.sender, from, to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, value, data);
    }

    /**
        @dev Transfers `values` amount(s) of `ids` from the `from` address to the
        `to` address specified. Caller must be approved to manage the tokens being
        transferred out of the `from` account. If `to` is a smart contract, will
        call `onERC1155BatchReceived` on `to` and act appropriately.
        @param from Source address
        @param to Target address
        @param ids IDs of each token type
        @param values Transfer amounts per token type
        @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
    */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
    external
    {
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");
        require(to != address(0), "ERC1155: target address must be non-zero");
        require(
            from == msg.sender || _operatorApprovals[from][msg.sender] == true,
            "ERC1155: need operator approval for 3rd party transfers."
        );

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            _balances[id][from] = _balances[id][from].sub(value);
            _balances[id][to] = value.add(_balances[id][to]);
        }

        emit TransferBatch(msg.sender, from, to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, values, data);
    }

    /**
     * @dev Internal function to mint an amount of a token with the given ID
     * @param to The address that will own the minted token
     * @param id ID of the token to be minted
     * @param value Amount of the token to be minted
     * @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
     */
    function _mint(address to, uint256 id, uint256 value, bytes memory data) internal {
        require(to != address(0), "ERC1155: mint to the zero address");

        _balances[id][to] = value.add(_balances[id][to]);
        emit TransferSingle(msg.sender, address(0), to, id, value);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, value, data);
    }

    /**
     * @dev Internal function to batch mint amounts of tokens with the given IDs
     * @param to The address that will own the minted token
     * @param ids IDs of the tokens to be minted
     * @param values Amounts of the tokens to be minted
     * @param data Data forwarded to `onERC1155Received` if `to` is a contract receiver
     */
    function _batchMint(address to, uint256[] memory ids, uint256[] memory values, bytes memory data) internal {
        require(to != address(0), "ERC1155: batch mint to the zero address");
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");

        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = values[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(msg.sender, address(0), to, ids, values);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, address(0), to, ids, values, data);
    }

    /**
     * @dev Internal function to burn an amount of a token with the given ID
     * @param owner Account which owns the token to be burnt
     * @param id ID of the token to be burnt
     * @param value Amount of the token to be burnt
     */
    function _burn(address owner, uint256 id, uint256 value) internal {
        _balances[id][owner] = _balances[id][owner].sub(value);
        emit TransferSingle(msg.sender, owner, address(0), id, value);
    }

    /**
     * @dev Internal function to batch burn an amounts of tokens with the given IDs
     * @param owner Account which owns the token to be burnt
     * @param ids IDs of the tokens to be burnt
     * @param values Amounts of the tokens to be burnt
     */
    function _batchBurn(address owner, uint256[] memory ids, uint256[] memory values) internal {
        require(ids.length == values.length, "ERC1155: IDs and values must have same lengths");

        for(uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][owner] = _balances[ids[i]][owner].sub(values[i]);
        }

        emit TransferBatch(msg.sender, owner, address(0), ids, values);
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    )
    internal
    {
        if(to.isContract()) {
            require(
                IERC1155TokenReceiver(to).onERC1155Received(operator, from, id, value, data) ==
                IERC1155TokenReceiver(to).onERC1155Received.selector,
                "ERC1155: got unknown value from onERC1155Received"
            );
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    )
    internal
    {
        if(to.isContract()) {
            require(
                IERC1155TokenReceiver(to).onERC1155BatchReceived(operator, from, ids, values, data) == IERC1155TokenReceiver(to).onERC1155BatchReceived.selector,
                "ERC1155: got unknown value from onERC1155BatchReceived"
            );
        }
    }
}



library CTHelpers {
    /// @dev Constructs a condition ID from an oracle, a question ID, and the outcome slot count for the question.
    /// @param oracle The account assigned to report the result for the prepared condition.
    /// @param questionId An identifier for the question to be answered by the oracle.
    /// @param outcomeSlotCount The number of outcome slots which should be used for this condition. Must not exceed 256.
    function getConditionId(address oracle, bytes32 questionId, uint outcomeSlotCount) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount));
    }

    uint constant P = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint constant B = 3;

    function sqrt(uint x) private pure returns (uint y) {
        uint p = P;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
        // add chain generated via https://crypto.stackexchange.com/q/27179/71252
        // and transformed to the following program:

        // x=1; y=x+x; z=y+y; z=z+z; y=y+z; x=x+y; y=y+x; z=y+y; t=z+z; t=z+t; t=t+t;
        // t=t+t; z=z+t; x=x+z; z=x+x; z=z+z; y=y+z; z=y+y; z=z+z; z=z+z; z=y+z; x=x+z;
        // z=x+x; z=z+z; z=z+z; z=x+z; y=y+z; x=x+y; z=x+x; z=z+z; y=y+z; z=y+y; t=z+z;
        // t=t+t; t=t+t; z=z+t; x=x+z; y=y+x; z=y+y; z=z+z; z=z+z; x=x+z; z=x+x; z=z+z;
        // z=x+z; z=z+z; z=z+z; z=x+z; y=y+z; z=y+y; t=z+z; t=t+t; t=z+t; t=y+t; t=t+t;
        // t=t+t; t=t+t; t=t+t; z=z+t; x=x+z; z=x+x; z=x+z; y=y+z; z=y+y; z=y+z; z=z+z;
        // t=z+z; t=z+t; w=t+t; w=w+w; w=w+w; w=w+w; w=w+w; t=t+w; z=z+t; x=x+z; y=y+x;
        // z=y+y; x=x+z; y=y+x; x=x+y; y=y+x; x=x+y; z=x+x; z=x+z; z=z+z; y=y+z; z=y+y;
        // z=z+z; x=x+z; y=y+x; z=y+y; z=y+z; x=x+z; y=y+x; x=x+y; y=y+x; z=y+y; z=z+z;
        // z=y+z; x=x+z; z=x+x; z=x+z; y=y+z; x=x+y; y=y+x; x=x+y; y=y+x; z=y+y; z=y+z;
        // z=z+z; x=x+z; y=y+x; z=y+y; z=y+z; z=z+z; x=x+z; z=x+x; t=z+z; t=t+t; t=z+t;
        // t=x+t; t=t+t; t=t+t; t=t+t; t=t+t; z=z+t; y=y+z; x=x+y; y=y+x; x=x+y; z=x+x;
        // z=x+z; z=z+z; z=z+z; z=z+z; z=x+z; y=y+z; z=y+y; z=y+z; z=z+z; x=x+z; z=x+x;
        // z=x+z; y=y+z; x=x+y; z=x+x; z=z+z; y=y+z; x=x+y; z=x+x; y=y+z; x=x+y; y=y+x;
        // z=y+y; z=y+z; x=x+z; y=y+x; z=y+y; z=y+z; z=z+z; z=z+z; x=x+z; z=x+x; z=z+z;
        // z=z+z; z=x+z; y=y+z; x=x+y; z=x+x; t=x+z; t=t+t; t=t+t; z=z+t; y=y+z; z=y+y;
        // x=x+z; y=y+x; x=x+y; y=y+x; x=x+y; y=y+x; z=y+y; t=y+z; z=y+t; z=z+z; z=z+z;
        // z=t+z; x=x+z; y=y+x; x=x+y; y=y+x; x=x+y; z=x+x; z=x+z; y=y+z; x=x+y; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x; x=x+x;
        // x=x+x; x=x+x; x=x+x; x=x+x; res=y+x
        // res == (P + 1) // 4

            y := mulmod(x, x, p)
            {
                let z := mulmod(y, y, p)
                z := mulmod(z, z, p)
                y := mulmod(y, z, p)
                x := mulmod(x, y, p)
                y := mulmod(y, x, p)
                z := mulmod(y, y, p)
                {
                    let t := mulmod(z, z, p)
                    t := mulmod(z, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    z := mulmod(z, t, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(z, z, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(y, z, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    z := mulmod(x, x, p)
                    z := mulmod(z, z, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    t := mulmod(z, z, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    z := mulmod(z, t, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(z, z, p)
                    z := mulmod(x, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    t := mulmod(z, z, p)
                    t := mulmod(t, t, p)
                    t := mulmod(z, t, p)
                    t := mulmod(y, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    z := mulmod(z, t, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    z := mulmod(z, z, p)
                    t := mulmod(z, z, p)
                    t := mulmod(z, t, p)
                    {
                        let w := mulmod(t, t, p)
                        w := mulmod(w, w, p)
                        w := mulmod(w, w, p)
                        w := mulmod(w, w, p)
                        w := mulmod(w, w, p)
                        t := mulmod(t, w, p)
                    }
                    z := mulmod(z, t, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    z := mulmod(x, x, p)
                    z := mulmod(x, z, p)
                    z := mulmod(z, z, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    z := mulmod(z, z, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(z, z, p)
                    z := mulmod(y, z, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    z := mulmod(z, z, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    z := mulmod(z, z, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    t := mulmod(z, z, p)
                    t := mulmod(t, t, p)
                    t := mulmod(z, t, p)
                    t := mulmod(x, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    z := mulmod(z, t, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    z := mulmod(x, x, p)
                    z := mulmod(x, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    z := mulmod(z, z, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    z := mulmod(x, x, p)
                    z := mulmod(z, z, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    z := mulmod(x, x, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    z := mulmod(y, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    x := mulmod(x, z, p)
                    z := mulmod(x, x, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(x, z, p)
                    y := mulmod(y, z, p)
                    x := mulmod(x, y, p)
                    z := mulmod(x, x, p)
                    t := mulmod(x, z, p)
                    t := mulmod(t, t, p)
                    t := mulmod(t, t, p)
                    z := mulmod(z, t, p)
                    y := mulmod(y, z, p)
                    z := mulmod(y, y, p)
                    x := mulmod(x, z, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    x := mulmod(x, y, p)
                    y := mulmod(y, x, p)
                    z := mulmod(y, y, p)
                    t := mulmod(y, z, p)
                    z := mulmod(y, t, p)
                    z := mulmod(z, z, p)
                    z := mulmod(z, z, p)
                    z := mulmod(t, z, p)
                }
                x := mulmod(x, z, p)
                y := mulmod(y, x, p)
                x := mulmod(x, y, p)
                y := mulmod(y, x, p)
                x := mulmod(x, y, p)
                z := mulmod(x, x, p)
                z := mulmod(x, z, p)
                y := mulmod(y, z, p)
            }
            x := mulmod(x, y, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            x := mulmod(x, x, p)
            y := mulmod(y, x, p)
        }
    }

    /// @dev Constructs an outcome collection ID from a parent collection and an outcome collection.
    /// @param parentCollectionId Collection ID of the parent outcome collection, or bytes32(0) if there's no parent.
    /// @param conditionId Condition ID of the outcome collection to combine with the parent outcome collection.
    /// @param indexSet Index set of the outcome collection to combine with the parent outcome collection.
    function getCollectionId(bytes32 parentCollectionId, bytes32 conditionId, uint indexSet) internal view returns (bytes32) {
        uint x1 = uint(keccak256(abi.encodePacked(conditionId, indexSet)));
        bool odd = x1 >> 255 != 0;
        uint y1;
        uint yy;
        do {
            x1 = addmod(x1, 1, P);
            yy = addmod(mulmod(x1, mulmod(x1, x1, P), P), B, P);
            y1 = sqrt(yy);
        } while(mulmod(y1, y1, P) != yy);
        if(odd && y1 % 2 == 0 || !odd && y1 % 2 == 1)
            y1 = P - y1;

        uint x2 = uint(parentCollectionId);
        if(x2 != 0) {
            odd = x2 >> 254 != 0;
            x2 = (x2 << 2) >> 2;
            yy = addmod(mulmod(x2, mulmod(x2, x2, P), P), B, P);
            uint y2 = sqrt(yy);
            if(odd && y2 % 2 == 0 || !odd && y2 % 2 == 1)
                y2 = P - y2;
            require(mulmod(y2, y2, P) == yy, "invalid parent collection ID");

            (bool success, bytes memory ret) = address(6).staticcall(abi.encode(x1, y1, x2, y2));
            require(success, "ecadd failed");
            (x1, y1) = abi.decode(ret, (uint, uint));
        }

        if(y1 % 2 == 1)
            x1 ^= 1 << 254;

        return bytes32(x1);
    }

    /// @dev Constructs a position ID from a collateral token and an outcome collection. These IDs are used as the ERC-1155 ID for this contract.
    /// @param collateralToken Collateral token which backs the position.
    /// @param collectionId ID of the outcome collection associated with this position.
    function getPositionId(IERC20 collateralToken, bytes32 collectionId) internal pure returns (uint) {
        return uint(keccak256(abi.encodePacked(collateralToken, collectionId)));
    }
}



contract ConditionalTokens is ERC1155 {

    /// @dev Emitted upon the successful preparation of a condition.
    /// @param conditionId The condition's ID. This ID may be derived from the other three parameters via ``keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount))``.
    /// @param oracle The account assigned to report the result for the prepared condition.
    /// @param questionId An identifier for the question to be answered by the oracle.
    /// @param outcomeSlotCount The number of outcome slots which should be used for this condition. Must not exceed 256.
    event ConditionPreparation(
        bytes32 indexed conditionId,
        address indexed oracle,
        bytes32 indexed questionId,
        uint outcomeSlotCount
    );

    event ConditionResolution(
        bytes32 indexed conditionId,
        address indexed oracle,
        bytes32 indexed questionId,
        uint outcomeSlotCount,
        uint[] payoutNumerators
    );

    /// @dev Emitted when a position is successfully split.
    event PositionSplit(
        address indexed stakeholder,
        IERC20 collateralToken,
        bytes32 indexed parentCollectionId,
        bytes32 indexed conditionId,
        uint[] partition,
        uint amount
    );
    /// @dev Emitted when positions are successfully merged.
    event PositionsMerge(
        address indexed stakeholder,
        IERC20 collateralToken,
        bytes32 indexed parentCollectionId,
        bytes32 indexed conditionId,
        uint[] partition,
        uint amount
    );
    event PayoutRedemption(
        address indexed redeemer,
        IERC20 indexed collateralToken,
        bytes32 indexed parentCollectionId,
        bytes32 conditionId,
        uint[] indexSets,
        uint payout
    );


    /// Mapping key is an condition ID. Value represents numerators of the payout vector associated with the condition. This array is initialized with a length equal to the outcome slot count. E.g. Condition with 3 outcomes [A, B, C] and two of those correct [0.5, 0.5, 0]. In Ethereum there are no decimal values, so here, 0.5 is represented by fractions like 1/2 == 0.5. That's why we need numerator and denominator values. Payout numerators are also used as a check of initialization. If the numerators array is empty (has length zero), the condition was not created/prepared. See getOutcomeSlotCount.
    mapping(bytes32 => uint[]) public payoutNumerators;
    /// Denominator is also used for checking if the condition has been resolved. If the denominator is non-zero, then the condition has been resolved.
    mapping(bytes32 => uint) public payoutDenominator;

    /// @dev This function prepares a condition by initializing a payout vector associated with the condition.
    /// @param oracle The account assigned to report the result for the prepared condition.
    /// @param questionId An identifier for the question to be answered by the oracle.
    /// @param outcomeSlotCount The number of outcome slots which should be used for this condition. Must not exceed 256.
    function prepareCondition(address oracle, bytes32 questionId, uint outcomeSlotCount) external {
        // Limit of 256 because we use a partition array that is a number of 256 bits.
        require(outcomeSlotCount <= 256, "too many outcome slots");
        require(outcomeSlotCount > 1, "there should be more than one outcome slot");
        bytes32 conditionId = CTHelpers.getConditionId(oracle, questionId, outcomeSlotCount);
        require(payoutNumerators[conditionId].length == 0, "condition already prepared");
        payoutNumerators[conditionId] = new uint[](outcomeSlotCount);
        emit ConditionPreparation(conditionId, oracle, questionId, outcomeSlotCount);
    }

    /// @dev Called by the oracle for reporting results of conditions. Will set the payout vector for the condition with the ID ``keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount))``, where oracle is the message sender, questionId is one of the parameters of this function, and outcomeSlotCount is the length of the payouts parameter, which contains the payoutNumerators for each outcome slot of the condition.
    /// @param questionId The question ID the oracle is answering for
    /// @param payouts The oracle's answer
    function reportPayouts(bytes32 questionId, uint[] calldata payouts) external {
        uint outcomeSlotCount = payouts.length;
        require(outcomeSlotCount > 1, "there should be more than one outcome slot");
        // IMPORTANT, the oracle is enforced to be the sender because it's part of the hash.
        bytes32 conditionId = CTHelpers.getConditionId(msg.sender, questionId, outcomeSlotCount);
        require(payoutNumerators[conditionId].length == outcomeSlotCount, "condition not prepared or found");
        require(payoutDenominator[conditionId] == 0, "payout denominator already set");

        uint den = 0;
        for (uint i = 0; i < outcomeSlotCount; i++) {
            uint num = payouts[i];
            den = den.add(num);

            require(payoutNumerators[conditionId][i] == 0, "payout numerator already set");
            payoutNumerators[conditionId][i] = num;
        }
        require(den > 0, "payout is all zeroes");
        payoutDenominator[conditionId] = den;
        emit ConditionResolution(conditionId, msg.sender, questionId, outcomeSlotCount, payoutNumerators[conditionId]);
    }

    /// @dev This function splits a position. If splitting from the collateral, this contract will attempt to transfer `amount` collateral from the message sender to itself. Otherwise, this contract will burn `amount` stake held by the message sender in the position being split worth of EIP 1155 tokens. Regardless, if successful, `amount` stake will be minted in the split target positions. If any of the transfers, mints, or burns fail, the transaction will revert. The transaction will also revert if the given partition is trivial, invalid, or refers to more slots than the condition is prepared with.
    /// @param collateralToken The address of the positions' backing collateral token.
    /// @param parentCollectionId The ID of the outcome collections common to the position being split and the split target positions. May be null, in which only the collateral is shared.
    /// @param conditionId The ID of the condition to split on.
    /// @param partition An array of disjoint index sets representing a nontrivial partition of the outcome slots of the given condition. E.g. A|B and C but not A|B and B|C (is not disjoint). Each element's a number which, together with the condition, represents the outcome collection. E.g. 0b110 is A|B, 0b010 is B, etc.
    /// @param amount The amount of collateral or stake to split.
    function splitPosition(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint[] calldata partition,
        uint amount
    ) external {
        require(partition.length > 1, "got empty or singleton partition");
        uint outcomeSlotCount = payoutNumerators[conditionId].length;
        require(outcomeSlotCount > 0, "condition not prepared yet");

        // For a condition with 4 outcomes fullIndexSet's 0b1111; for 5 it's 0b11111...
        uint fullIndexSet = (1 << outcomeSlotCount) - 1;
        // freeIndexSet starts as the full collection
        uint freeIndexSet = fullIndexSet;
        // This loop checks that all condition sets are disjoint (the same outcome is not part of more than 1 set)
        uint[] memory positionIds = new uint[](partition.length);
        uint[] memory amounts = new uint[](partition.length);
        for (uint i = 0; i < partition.length; i++) {
            uint indexSet = partition[i];
            require(indexSet > 0 && indexSet < fullIndexSet, "got invalid index set");
            require((indexSet & freeIndexSet) == indexSet, "partition not disjoint");
            freeIndexSet ^= indexSet;
            positionIds[i] = CTHelpers.getPositionId(collateralToken, CTHelpers.getCollectionId(parentCollectionId, conditionId, indexSet));
            amounts[i] = amount;
        }

        if (freeIndexSet == 0) {
            // Partitioning the full set of outcomes for the condition in this branch
            if (parentCollectionId == bytes32(0)) {
                require(collateralToken.transferFrom(msg.sender, address(this), amount), "could not receive collateral tokens");
            } else {
                _burn(
                    msg.sender,
                    CTHelpers.getPositionId(collateralToken, parentCollectionId),
                    amount
                );
            }
        } else {
            // Partitioning a subset of outcomes for the condition in this branch.
            // For example, for a condition with three outcomes A, B, and C, this branch
            // allows the splitting of a position $:(A|C) to positions $:(A) and $:(C).
            _burn(
                msg.sender,
                CTHelpers.getPositionId(collateralToken,
                CTHelpers.getCollectionId(parentCollectionId, conditionId, fullIndexSet ^ freeIndexSet)),
                amount
            );
        }

        _batchMint(
            msg.sender,
        // position ID is the ERC 1155 token ID
            positionIds,
            amounts,
            ""
        );
        emit PositionSplit(msg.sender, collateralToken, parentCollectionId, conditionId, partition, amount);
    }

    function mergePositions(
        IERC20 collateralToken,
        bytes32 parentCollectionId,
        bytes32 conditionId,
        uint[] calldata partition,
        uint amount
    ) external {
        require(partition.length > 1, "got empty or singleton partition");
        uint outcomeSlotCount = payoutNumerators[conditionId].length;
        require(outcomeSlotCount > 0, "condition not prepared yet");

        uint fullIndexSet = (1 << outcomeSlotCount) - 1;
        uint freeIndexSet = fullIndexSet;
        uint[] memory positionIds = new uint[](partition.length);
        uint[] memory amounts = new uint[](partition.length);
        for (uint i = 0; i < partition.length; i++) {
            uint indexSet = partition[i];
            require(indexSet > 0 && indexSet < fullIndexSet, "got invalid index set");
            require((indexSet & freeIndexSet) == indexSet, "partition not disjoint");
            freeIndexSet ^= indexSet;
            positionIds[i] = CTHelpers.getPositionId(collateralToken, CTHelpers.getCollectionId(parentCollectionId, conditionId, indexSet));
            amounts[i] = amount;
        }
        _batchBurn(
            msg.sender,
            positionIds,
            amounts
        );

        if (freeIndexSet == 0) {
            if (parentCollectionId == bytes32(0)) {
                require(collateralToken.transfer(msg.sender, amount), "could not send collateral tokens");
            } else {
                _mint(
                    msg.sender,
                    CTHelpers.getPositionId(collateralToken, parentCollectionId),
                    amount,
                    ""
                );
            }
        } else {
            _mint(
                msg.sender,
                CTHelpers.getPositionId(collateralToken,
                CTHelpers.getCollectionId(parentCollectionId, conditionId, fullIndexSet ^ freeIndexSet)),
                amount,
                ""
            );
        }

        emit PositionsMerge(msg.sender, collateralToken, parentCollectionId, conditionId, partition, amount);
    }

    function redeemPositions(IERC20 collateralToken, bytes32 parentCollectionId, bytes32 conditionId, uint[] calldata indexSets) external {
        uint den = payoutDenominator[conditionId];
        require(den > 0, "result for condition not received yet");
        uint outcomeSlotCount = payoutNumerators[conditionId].length;
        require(outcomeSlotCount > 0, "condition not prepared yet");

        uint totalPayout = 0;

        uint fullIndexSet = (1 << outcomeSlotCount) - 1;
        for (uint i = 0; i < indexSets.length; i++) {
            uint indexSet = indexSets[i];
            require(indexSet > 0 && indexSet < fullIndexSet, "got invalid index set");
            uint positionId = CTHelpers.getPositionId(collateralToken,
                CTHelpers.getCollectionId(parentCollectionId, conditionId, indexSet));

            uint payoutNumerator = 0;
            for (uint j = 0; j < outcomeSlotCount; j++) {
                if (indexSet & (1 << j) != 0) {
                    payoutNumerator = payoutNumerator.add(payoutNumerators[conditionId][j]);
                }
            }

            uint payoutStake = balanceOf(msg.sender, positionId);
            if (payoutStake > 0) {
                totalPayout = totalPayout.add(payoutStake.mul(payoutNumerator).div(den));
                _burn(msg.sender, positionId, payoutStake);
            }
        }

        if (totalPayout > 0) {
            if (parentCollectionId == bytes32(0)) {
                require(collateralToken.transfer(msg.sender, totalPayout), "could not transfer payout to message sender");
            } else {
                _mint(msg.sender, CTHelpers.getPositionId(collateralToken, parentCollectionId), totalPayout, "");
            }
        }
        emit PayoutRedemption(msg.sender, collateralToken, parentCollectionId, conditionId, indexSets, totalPayout);
    }

    /// @dev Gets the outcome slot count of a condition.
    /// @param conditionId ID of the condition.
    /// @return Number of outcome slots associated with a condition, or zero if condition has not been prepared yet.
    function getOutcomeSlotCount(bytes32 conditionId) external view returns (uint) {
        return payoutNumerators[conditionId].length;
    }

    /// @dev Constructs a condition ID from an oracle, a question ID, and the outcome slot count for the question.
    /// @param oracle The account assigned to report the result for the prepared condition.
    /// @param questionId An identifier for the question to be answered by the oracle.
    /// @param outcomeSlotCount The number of outcome slots which should be used for this condition. Must not exceed 256.
    function getConditionId(address oracle, bytes32 questionId, uint outcomeSlotCount) external pure returns (bytes32) {
        return CTHelpers.getConditionId(oracle, questionId, outcomeSlotCount);
    }

    /// @dev Constructs an outcome collection ID from a parent collection and an outcome collection.
    /// @param parentCollectionId Collection ID of the parent outcome collection, or bytes32(0) if there's no parent.
    /// @param conditionId Condition ID of the outcome collection to combine with the parent outcome collection.
    /// @param indexSet Index set of the outcome collection to combine with the parent outcome collection.
    function getCollectionId(bytes32 parentCollectionId, bytes32 conditionId, uint indexSet) external view returns (bytes32) {
        return CTHelpers.getCollectionId(parentCollectionId, conditionId, indexSet);
    }

    /// @dev Constructs a position ID from a collateral token and an outcome collection. These IDs are used as the ERC-1155 ID for this contract.
    /// @param collateralToken Collateral token which backs the position.
    /// @param collectionId ID of the outcome collection associated with this position.
    function getPositionId(IERC20 collateralToken, bytes32 collectionId) external pure returns (uint) {
        return CTHelpers.getPositionId(collateralToken, collectionId);
    }
}



contract ERC1155TokenReceiver is ERC165, IERC1155TokenReceiver {
    constructor() public {
        _registerInterface(
            ERC1155TokenReceiver(0).onERC1155Received.selector ^
            ERC1155TokenReceiver(0).onERC1155BatchReceived.selector
        );
    }
}


library CeilDiv {
    // calculates ceil(x/y)
    function ceildiv(uint x, uint y) internal pure returns (uint) {
        if (x > 0) return ((x - 1) / y) + 1;
        return x / y;
    }
}


contract FIFAMarketMaker is ERC20, ERC1155TokenReceiver, Ownable {
    event FPMMFundingAdded(
        address indexed funder,
        uint[] amountsAdded,
        uint sharesMinted
    );
    event FPMMFundingRemoved(
        address indexed funder,
        uint[] amountsRemoved,
        uint collateralRemovedFromFeePool,
        uint sharesBurnt
    );
    event FPMMBuy(
        address indexed buyer,
        uint investmentAmount,
        uint feeAmount,
        uint indexed outcomeIndex,
        uint outcomeTokensBought
    );
    event FPMMSell(
        address indexed seller,
        uint returnAmount,
        uint feeAmount,
        uint indexed outcomeIndex,
        uint outcomeTokensSold
    );

    enum Stage {
        Running,
        Paused,
        Closed
    }

    using SafeMath for uint;
    using CeilDiv for uint;

    uint constant ONE = 10 ** 18;

    uint[] outcomeSlotCounts;
    bytes32[][] collectionIds;
    uint[] public positionIds;
    mapping(address => uint256) withdrawnFees;
    uint internal totalWithdrawnFees;

    bytes32[] countrys;
    ConditionalTokens public conditionalTokens;
    IERC20 public collateralToken;
    bytes32[] conditionIds;
    uint public fee;
    uint internal feePoolWeight;

    Stage public stage;

    struct BetRecord {
        uint256 timestamp;
        uint256 collateralAmount;
        uint256 outcomeTokensToBuy;
        uint256 positionId;
        uint256 outcomeIndex;
    }

    mapping(address => BetRecord[]) userBetRecords;

    /*
    *  Modifiers
    */
    modifier atStage(Stage _stage) {
        // Contract has to be in given stage
        require(stage == _stage);
        _;
    }

    constructor(
        bytes32[] memory _countrys,
        ConditionalTokens _conditionalTokens,
        IERC20 _collateralToken,
        bytes32[] memory _conditionIds,
        uint _fee,
        string memory _name,
        string memory _symbol)
    public ERC20(_name, _symbol) {

        countrys = _countrys;
        conditionalTokens = _conditionalTokens;
        collateralToken = _collateralToken;
        conditionIds = _conditionIds;
        fee = _fee;

        uint atomicOutcomeSlotCount = 1;
        outcomeSlotCounts = new uint[](conditionIds.length);
        for (uint i = 0; i < conditionIds.length; i++) {
            uint outcomeSlotCount = conditionalTokens.getOutcomeSlotCount(conditionIds[i]);
            atomicOutcomeSlotCount *= outcomeSlotCount;
            outcomeSlotCounts[i] = outcomeSlotCount;
        }
        require(atomicOutcomeSlotCount > 1, "conditions must be valid");

        collectionIds = new bytes32[][](conditionIds.length);
        _recordCollectionIDsForAllConditions(conditionIds.length, bytes32(0));
        require(positionIds.length == atomicOutcomeSlotCount, "position IDs construction failed!?");

        stage = Stage.Paused;
    }

    function _recordCollectionIDsForAllConditions(uint conditionsLeft, bytes32 parentCollectionId) private {
        if (conditionsLeft == 0) {
            positionIds.push(CTHelpers.getPositionId(collateralToken, parentCollectionId));
            return;
        }

        conditionsLeft--;

        uint outcomeSlotCount = outcomeSlotCounts[conditionsLeft];

        collectionIds[conditionsLeft].push(parentCollectionId);
        for (uint i = 0; i < outcomeSlotCount; i++) {
            _recordCollectionIDsForAllConditions(
                conditionsLeft,
                CTHelpers.getCollectionId(
                    parentCollectionId,
                    conditionIds[conditionsLeft],
                    1 << i
                )
            );
        }
    }

    // ================================ VIEW ================================
    function getCountrys() public view returns (bytes32[] memory) {
        return countrys;
    }

    function getPoolBalances() public view returns (uint[] memory) {
        address[] memory thises = new address[](positionIds.length);
        for (uint i = 0; i < positionIds.length; i++) {
            thises[i] = address(this);
        }
        return conditionalTokens.balanceOfBatch(thises, positionIds);
    }

    function generateBasicPartition(uint outcomeSlotCount) private pure returns (uint[] memory partition) {
        partition = new uint[](outcomeSlotCount);
        for (uint i = 0; i < outcomeSlotCount; i++) {
            partition[i] = 1 << i;
        }
    }

    function collectedFees() external view returns (uint) {
        return feePoolWeight.sub(totalWithdrawnFees);
    }

    function feesWithdrawableBy(address account) public view returns (uint) {
        uint rawAmount = feePoolWeight.mul(balanceOf(account)) / totalSupply();
        return rawAmount.sub(withdrawnFees[account]);
    }

    function calcBuyAmount(uint investmentAmount, uint outcomeIndex) public view returns (uint) {
        require(outcomeIndex < positionIds.length, "invalid outcome index");
        
        // 50 100
        uint[] memory poolBalances = getPoolBalances();
        // 费率0，所以investmentAmountMinusFees = 10
        uint investmentAmountMinusFees = investmentAmount.sub(investmentAmount.mul(fee) / ONE);
        // buyTokenPoolBalance = 50
        uint buyTokenPoolBalance = poolBalances[outcomeIndex];
        uint endingOutcomeBalance = buyTokenPoolBalance.mul(ONE);
        for (uint i = 0; i < poolBalances.length; i++) {
            // i == 1时执行
            if (i != outcomeIndex) {
                // poolBalance = 100
                uint poolBalance = poolBalances[i];
                // 50 * 100 / （100 + 10）= 45.45
                endingOutcomeBalance = endingOutcomeBalance.mul(poolBalance).ceildiv(
                    poolBalance.add(investmentAmountMinusFees)
                );
            }
        }
        require(endingOutcomeBalance > 0, "must have non-zero balances");

        // （50 + 10）- 45.45 = 14.55
        return buyTokenPoolBalance.add(investmentAmountMinusFees).sub(endingOutcomeBalance.ceildiv(ONE));
    }

    function calcSellAmount(uint returnAmount, uint outcomeIndex) public view returns (uint outcomeTokenSellAmount) {
        require(outcomeIndex < positionIds.length, "invalid outcome index");

        uint[] memory poolBalances = getPoolBalances();
        uint returnAmountPlusFees = returnAmount.mul(ONE) / ONE.sub(fee);
        uint sellTokenPoolBalance = poolBalances[outcomeIndex];
        uint endingOutcomeBalance = sellTokenPoolBalance.mul(ONE);
        for (uint i = 0; i < poolBalances.length; i++) {
            if (i != outcomeIndex) {
                uint poolBalance = poolBalances[i];
                endingOutcomeBalance = endingOutcomeBalance.mul(poolBalance).ceildiv(
                    poolBalance.sub(returnAmountPlusFees)
                );
            }
        }
        require(endingOutcomeBalance > 0, "must have non-zero balances");

        return returnAmountPlusFees.add(endingOutcomeBalance.ceildiv(ONE)).sub(sellTokenPoolBalance);
    }

    function getUserBetRecordLength(address account) public view returns (uint256 length) {
        return userBetRecords[account].length;
    }

    function getUserBetRecords(address account, uint256 index) public view returns (uint256 time, uint256 inAmount, uint256 outAmount, uint256 positionId, uint256 outcomeIndex) {
        return (
        userBetRecords[account][index].timestamp,
        userBetRecords[account][index].collateralAmount,
        userBetRecords[account][index].outcomeTokensToBuy,
        userBetRecords[account][index].positionId,
        userBetRecords[account][index].outcomeIndex
        );
    }

    // ================================ SETTING ================================
    function pause() public onlyOwner atStage(Stage.Running) {
        stage = Stage.Paused;
    }

    function resume() public onlyOwner atStage(Stage.Paused) {
        stage = Stage.Running;
    }

    // ================================ ACTION ================================
    function addFunding(uint addedFunds, uint[] calldata distributionHint) external onlyOwner {
        require(addedFunds > 0, "funding must be non-zero");

        uint[] memory sendBackAmounts = new uint[](positionIds.length);
        uint poolShareSupply = totalSupply();
        uint mintAmount;
        if (poolShareSupply > 0) {
            require(distributionHint.length == 0, "cannot use distribution hint after initial funding");
            uint[] memory poolBalances = getPoolBalances();
            uint poolWeight = 0;
            for (uint i = 0; i < poolBalances.length; i++) {
                uint balance = poolBalances[i];
                if (poolWeight < balance)
                    poolWeight = balance;
            }

            for (uint i = 0; i < poolBalances.length; i++) {
                uint remaining = addedFunds.mul(poolBalances[i]) / poolWeight;
                sendBackAmounts[i] = addedFunds.sub(remaining);
            }

            mintAmount = addedFunds.mul(poolShareSupply) / poolWeight;
        } else {
            if (distributionHint.length > 0) {
                require(distributionHint.length == positionIds.length, "hint length off");
                uint maxHint = 0;
                for (uint i = 0; i < distributionHint.length; i++) {
                    uint hint = distributionHint[i];
                    if (maxHint < hint)
                        maxHint = hint;
                }

                // [20, 30]
                // maxHint = 30
                for (uint i = 0; i < distributionHint.length; i++) {
                    // 1、 100 * 20 / 30
                    // 2、 100
                    uint remaining = addedFunds.mul(distributionHint[i]) / maxHint;
                    require(remaining > 0, "must hint a valid distribution");
                    // 1、 100 - （100 * 20 / 30) = 33.33
                    // 2、 0
                    sendBackAmounts[i] = addedFunds.sub(remaining);
                }
            }

            mintAmount = addedFunds;
        }

        require(collateralToken.transferFrom(msg.sender, address(this), addedFunds), "funding transfer failed");
        require(collateralToken.approve(address(conditionalTokens), addedFunds), "approval for splits failed");
        splitPositionThroughAllConditions(addedFunds);

        _mint(msg.sender, mintAmount);

        // [33.33, 0]
        conditionalTokens.safeBatchTransferFrom(address(this), msg.sender, positionIds, sendBackAmounts, "");

        // transform sendBackAmounts to array of amounts added
        for (uint i = 0; i < sendBackAmounts.length; i++) {
            sendBackAmounts[i] = addedFunds.sub(sendBackAmounts[i]);
        }

        emit FPMMFundingAdded(msg.sender, sendBackAmounts, mintAmount);
    }

    function removeFunding(uint sharesToBurn) external onlyOwner {
        uint[] memory poolBalances = getPoolBalances();

        uint[] memory sendAmounts = new uint[](poolBalances.length);

        uint poolShareSupply = totalSupply();
        for (uint i = 0; i < poolBalances.length; i++) {
            sendAmounts[i] = poolBalances[i].mul(sharesToBurn) / poolShareSupply;
        }

        uint collateralRemovedFromFeePool = collateralToken.balanceOf(address(this));

        _burn(msg.sender, sharesToBurn);
        collateralRemovedFromFeePool = collateralRemovedFromFeePool.sub(
            collateralToken.balanceOf(address(this))
        );

        conditionalTokens.safeBatchTransferFrom(address(this), msg.sender, positionIds, sendAmounts, "");

        emit FPMMFundingRemoved(msg.sender, sendAmounts, collateralRemovedFromFeePool, sharesToBurn);
    }

    function buy(uint investmentAmount, uint outcomeIndex, uint minOutcomeTokensToBuy) external atStage(Stage.Running) {
        uint outcomeTokensToBuy = calcBuyAmount(investmentAmount, outcomeIndex);
        require(outcomeTokensToBuy >= minOutcomeTokensToBuy, "minimum buy amount not reached");

        require(collateralToken.transferFrom(msg.sender, address(this), investmentAmount), "cost transfer failed");

        uint feeAmount = investmentAmount.mul(fee) / ONE;
        feePoolWeight = feePoolWeight.add(feeAmount);
        uint investmentAmountMinusFees = investmentAmount.sub(feeAmount);
        require(collateralToken.approve(address(conditionalTokens), investmentAmountMinusFees), "approval for splits failed");
        splitPositionThroughAllConditions(investmentAmountMinusFees);

        conditionalTokens.safeTransferFrom(address(this), msg.sender, positionIds[outcomeIndex], outcomeTokensToBuy, "");

        BetRecord memory betRecord = BetRecord({
        timestamp : block.timestamp,
        collateralAmount : investmentAmount,
        outcomeTokensToBuy : outcomeTokensToBuy,
        positionId : positionIds[outcomeIndex],
        outcomeIndex: outcomeIndex
        });

        userBetRecords[msg.sender].push(betRecord);

        emit FPMMBuy(msg.sender, investmentAmount, feeAmount, outcomeIndex, outcomeTokensToBuy);
    }

    //    function sell(uint returnAmount, uint outcomeIndex, uint maxOutcomeTokensToSell) external {
    //        uint outcomeTokensToSell = calcSellAmount(returnAmount, outcomeIndex);
    //        require(outcomeTokensToSell <= maxOutcomeTokensToSell, "maximum sell amount exceeded");
    //
    //        conditionalTokens.safeTransferFrom(msg.sender, address(this), positionIds[outcomeIndex], outcomeTokensToSell, "");
    //
    //        uint feeAmount = returnAmount.mul(fee) / (ONE.sub(fee));
    //        feePoolWeight = feePoolWeight.add(feeAmount);
    //        uint returnAmountPlusFees = returnAmount.add(feeAmount);
    //        mergePositionsThroughAllConditions(returnAmountPlusFees);
    //
    //        require(collateralToken.transfer(msg.sender, returnAmount), "return transfer failed");
    //
    //        emit FPMMSell(msg.sender, returnAmount, feeAmount, outcomeIndex, outcomeTokensToSell);
    //    }

    function splitPositionThroughAllConditions(uint amount) private {
        for (uint i = conditionIds.length - 1; int(i) >= 0; i--) {
            uint[] memory partition = generateBasicPartition(outcomeSlotCounts[i]);
            for (uint j = 0; j < collectionIds[i].length; j++) {
                conditionalTokens.splitPosition(collateralToken, collectionIds[i][j], conditionIds[i], partition, amount);
            }
        }
    }

    function mergePositionsThroughAllConditions(uint amount) private {
        for (uint i = 0; i < conditionIds.length; i++) {
            uint[] memory partition = generateBasicPartition(outcomeSlotCounts[i]);
            for (uint j = 0; j < collectionIds[i].length; j++) {
                conditionalTokens.mergePositions(collateralToken, collectionIds[i][j], conditionIds[i], partition, amount);
            }
        }
    }

    function withdrawFees(address account) public {
        uint rawAmount = feePoolWeight.mul(balanceOf(account)) / totalSupply();
        uint withdrawableAmount = rawAmount.sub(withdrawnFees[account]);
        if (withdrawableAmount > 0) {
            withdrawnFees[account] = rawAmount;
            totalWithdrawnFees = totalWithdrawnFees.add(withdrawableAmount);
            require(collateralToken.transfer(account, withdrawableAmount), "withdrawal transfer failed");
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        if (from != address(0)) {
            withdrawFees(from);
        }

        uint totalSupply = totalSupply();
        uint withdrawnFeesTransfer = totalSupply == 0 ?
        amount :
        feePoolWeight.mul(amount) / totalSupply;

        if (from != address(0)) {
            withdrawnFees[from] = withdrawnFees[from].sub(withdrawnFeesTransfer);
            totalWithdrawnFees = totalWithdrawnFees.sub(withdrawnFeesTransfer);
        } else {
            feePoolWeight = feePoolWeight.add(withdrawnFeesTransfer);
        }
        if (to != address(0)) {
            withdrawnFees[to] = withdrawnFees[to].add(withdrawnFeesTransfer);
            totalWithdrawnFees = totalWithdrawnFees.add(withdrawnFeesTransfer);
        } else {
            feePoolWeight = feePoolWeight.sub(withdrawnFeesTransfer);
        }
    }


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4) {
        if (operator == address(this)) {
            return this.onERC1155Received.selector;
        }
        return 0x0;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4) {
        if (operator == address(this) && from == address(0)) {
            return this.onERC1155BatchReceived.selector;
        }
        return 0x0;
    }
}