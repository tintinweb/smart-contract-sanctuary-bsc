/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//For whitelist, 
interface IWhiteList {
    function Check(address _Subject, uint256 _Id) external view returns(uint);
    function Register(address _Subject,uint256 _Id,uint256 _Amount) external;
    function LastRoundRegister(address _Subject,uint256 _Id) external;
    function CreateManualWhiteList(uint256 _ChangeUntil, address _Contract) external payable returns(uint256 Id);
    function ChangeCreator(uint256 _Id, address _NewCreator) external;
}

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


contract ERC20Helper {
    event TransferOut(uint256 Amount, address To, address Token);
    event TransferIn(uint256 Amount, address From, address Token);
    modifier TestAllownce(
        address _token,
        address _owner,
        uint256 _amount
    ) {
        require(
            ERC20(_token).allowance(_owner, address(this)) >= _amount,
            "no allowance"
        );
        _;
    }

    function TransferToken(
        address _Token,
        address _Reciver,
        uint256 _Amount
    ) internal {
        uint256 OldBalance = CheckBalance(_Token, address(this));
        emit TransferOut(_Amount, _Reciver, _Token);
        ERC20(_Token).transfer(_Reciver, _Amount);
        require(
            (CheckBalance(_Token, address(this)) + _Amount) == OldBalance,
            "recive wrong amount of tokens"
        );
    }

    function CheckBalance(address _Token, address _Subject)
        internal
        view
        returns (uint256)
    {
        return ERC20(_Token).balanceOf(_Subject);
    }

    function TransferInToken(
        address _Token,
        address _Subject,
        uint256 _Amount
    ) internal TestAllownce(_Token, _Subject, _Amount) {
        require(_Amount > 0);
        uint256 OldBalance = CheckBalance(_Token, address(this));
        ERC20(_Token).transferFrom(_Subject, address(this), _Amount);
        emit TransferIn(_Amount, _Subject, _Token);
        require(
            (OldBalance + _Amount) == CheckBalance(_Token, address(this)),
            "recive wrong amount of tokens"
        );
    }

    function ApproveAllowanceERC20(
        address _Token,
        address _Subject,
        uint256 _Amount
    ) internal {
        require(_Amount > 0);
        ERC20(_Token).approve(_Subject, _Amount);
    }
}

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

contract GovManager is Ownable {
    address public GovernerContract;

    modifier onlyOwnerOrGov() {
        require(
            msg.sender == owner() || msg.sender == GovernerContract,
            "Authorization Error"
        );
        _;
    }

    function setGovernerContract(address _address) external onlyOwnerOrGov {
        GovernerContract = _address;
    }

    constructor() {
        GovernerContract = address(0);
    }
}

contract FeeBaseHelper is ERC20Helper, GovManager {
    event TransferInETH(uint256 Amount, address From);
    event NewFeeAmount(uint256 NewFeeAmount, uint256 OldFeeAmount);
    event NewFeeToken(address NewFeeToken, address OldFeeToken);

    uint256 public Fee;
    address public FeeToken;
    mapping(address => uint256) public Reserve;

    function PayFee(uint256 _fee) public payable {
        if (_fee == 0) return;
        if (FeeToken == address(0)) {
            require(msg.value >= _fee, "Not Enough Fee Provided");
            emit TransferInETH(msg.value, msg.sender);
        } else {
            TransferInToken(FeeToken, msg.sender, _fee);
        }
        Reserve[FeeToken] += _fee;
    }

    function SetFeeAmount(uint256 _amount) public onlyOwnerOrGov {
        require(Fee != _amount, "Can't swap to same fee value");
        emit NewFeeAmount(_amount, Fee);
        Fee = _amount;
    }

    function SetFeeToken(address _token) public onlyOwnerOrGov {
        require(FeeToken != _token, "Can't swap to same token");
        emit NewFeeToken(_token, FeeToken);
        FeeToken = _token; // set address(0) to use ETH/BNB as main coin
    }

    function WithdrawFee(address _token, address _to) public onlyOwnerOrGov {
        require(Reserve[_token] > 0, "Fee amount is zero");
        if (_token == address(0)) {
            payable(_to).transfer(Reserve[_token]);
        } else {
            TransferToken(_token, _to, Reserve[_token]);
        }
        Reserve[_token] = 0;
    }
}

contract LockedDealEvents {
    event TokenWithdrawn(uint256 PoolId, address Recipient, uint256 Amount);
    event MassPoolsCreated(uint256 FirstPoolId, uint256 LastPoolId);
    event NewPoolCreated(
        uint256 PoolId,
        address Token,
        uint256 StartTime,
        uint256 FinishTime,
        uint256 StartAmount,
        address Owner
    );
    event PoolTransferred(
        uint256 PoolId,
        uint256 oldPoolId,
        address NewOwner,
        address OldOwner
    );
    event PoolApproval(uint256 PoolId, address Spender, uint256 Amount);
    event PoolSplit(
        uint256 OldPoolId,
        uint256 NewPoolId,
        uint256 NewAmount,
        address NewOwner
    );
}

/// @title contains modifiers and stores variables.
contract LockedDealModifiers {
    mapping(uint256 => mapping(address => uint256)) public Allowance;
    mapping(uint256 => Pool) public AllPoolz;
    mapping(address => uint256[]) public MyPoolz;
    uint256 public Index;

    address public WhiteList_Address;
    bool public isTokenFilterOn; // use to enable/disable token filter
    uint256 public TokenFeeWhiteListId;
    uint256 public TokenFilterWhiteListId;
    uint256 public UserWhiteListId;
    uint256 public maxTransactionLimit;

    struct Pool {
        uint256 StartTime;
        uint256 FinishTime;
        uint256 StartAmount;
        uint256 DebitedAmount;
        address Owner;
        address Token;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0x0), "Zero Address is not allowed");
        _;
    }
    modifier isPoolValid(uint256 _PoolId) {
        require(_PoolId < Index, "Pool does not exist");
        _;
    }

    modifier isPoolOwner(uint256 _PoolId) {
        require(
            AllPoolz[_PoolId].Owner == msg.sender,
            "You are not Pool Owner"
        );
        _;
    }

    modifier isAllowed(uint256 _PoolId, uint256 _amount) {
        require(
            _amount <= Allowance[_PoolId][msg.sender],
            "Not enough Allowance"
        );
        _;
    }

    modifier isLocked(uint256 _PoolId) {
        require(AllPoolz[_PoolId].DebitedAmount == 0, "Pool is Unlocked");
        _;
    }

    modifier isGreaterThanZero(uint256 _num) {
        require(_num > 0, "Array length should be greater than zero");
        _;
    }

    modifier isBelowLimit(uint256 _num) {
        require(_num <= maxTransactionLimit, "Max array length limit exceeded");
        _;
    }
}

contract LockedManageable is
    FeeBaseHelper,
    LockedDealEvents,
    LockedDealModifiers
{
    constructor() {
        maxTransactionLimit = 400;
        isTokenFilterOn = false; // disable token filter whitelist
    }

    function setWhiteListAddress(address _address) external onlyOwner {
        WhiteList_Address = _address;
    }

    function setTokenFeeWhiteListId(uint256 _id) external onlyOwner {
        TokenFeeWhiteListId = _id;
    }

    function setTokenFilterWhiteListId(uint256 _id) external onlyOwner {
        TokenFilterWhiteListId = _id;
    }

    function setUserWhiteListId(uint256 _id) external onlyOwner {
        UserWhiteListId = _id;
    }

    function swapTokenFilter() external onlyOwner {
        isTokenFilterOn = !isTokenFilterOn;
    }

    function isTokenWithoutFee(address _tokenAddress)
        public
        view
        notZeroAddress(WhiteList_Address)
        returns (bool)
    {
        return
            IWhiteList(WhiteList_Address).Check(
                _tokenAddress,
                TokenFeeWhiteListId
            ) > 0;
    }

    function isTokenWhiteListed(address _tokenAddress)
        public
        view
        returns (bool)
    {
        return
            !isTokenFilterOn ||
            IWhiteList(WhiteList_Address).Check(
                _tokenAddress,
                TokenFilterWhiteListId
            ) >
            0;
    }

    function isUserWithoutFee(address _UserAddress)
        public
        view
        notZeroAddress(WhiteList_Address)
        returns (bool)
    {
        return
            IWhiteList(WhiteList_Address).Check(_UserAddress, UserWhiteListId) >
            0;
    }

    function setMaxTransactionLimit(uint256 _newLimit) external onlyOwner {
        maxTransactionLimit = _newLimit;
    }
}

contract LockedPoolz is LockedManageable {
    constructor() {
        Index = 0;
    }

    modifier isTokenValid(address _Token) {
        require(isTokenWhiteListed(_Token), "Need Valid ERC20 Token"); //check if _Token is ERC20
        _;
    }

    function SplitPool(
        uint256 _PoolId,
        uint256 _NewAmount,
        address _NewOwner
    ) internal returns (uint256) {
        Pool storage pool = AllPoolz[_PoolId];
        require(pool.StartAmount >= _NewAmount, "Not Enough Amount Balance");
        uint256 poolAmount = pool.StartAmount - _NewAmount;
        pool.StartAmount = poolAmount;
        uint256 poolId = CreatePool(
            pool.Token,
            pool.StartTime,
            pool.FinishTime,
            _NewAmount,
            _NewOwner
        );
        emit PoolSplit(_PoolId, poolId, _NewAmount, _NewOwner);
        return poolId;
    }

    //create a new pool
    function CreatePool(
        address _Token, // token to lock address
        uint256 _StartTime, // Until what time the pool will Start
        uint256 _FinishTime, // Until what time the pool will end
        uint256 _StartAmount, //Total amount of the tokens to sell in the pool
        address _Owner // Who the tokens belong to
    ) internal isTokenValid(_Token) returns (uint256) {
        require(
            _StartTime <= _FinishTime,
            "StartTime is greater than FinishTime"
        );
        //register the pool
        AllPoolz[Index] = Pool(
            _StartTime,
            _FinishTime,
            _StartAmount,
            0,
            _Owner,
            _Token
        );
        MyPoolz[_Owner].push(Index);
        emit NewPoolCreated(
            Index,
            _Token,
            _StartTime,
            _FinishTime,
            _StartAmount,
            _Owner
        );
        uint256 poolId = Index;
        Index++;
        return poolId;
    }
}

/// @title contains array utility functions
library Array {
    /// @dev returns a new slice of the array
    function KeepNElementsInArray(uint256[] memory _arr, uint256 _n)
        internal
        pure
        returns (uint256[] memory newArray)
    {
        if (_arr.length == _n) return _arr;
        require(_arr.length > _n, "can't cut more then got");
        newArray = new uint256[](_n);
        for (uint256 i = 0; i < _n; i++) {
            newArray[i] = _arr[i];
        }
        return newArray;
    }

    function KeepNElementsInArray(address[] memory _arr, uint256 _n)
        internal
        pure
        returns (address[] memory newArray)
    {
        if (_arr.length == _n) return _arr;
        require(_arr.length > _n, "can't cut more then got");
        newArray = new address[](_n);
        for (uint256 i = 0; i < _n; i++) {
            newArray[i] = _arr[i];
        }
        return newArray;
    }

    /// @return true if the array is ordered
    function isArrayOrdered(uint256[] memory _arr)
        internal
        pure
        returns (bool)
    {
        require(_arr.length > 0, "array should be greater than zero");
        uint256 temp = _arr[0];
        for (uint256 i = 1; i < _arr.length; i++) {
            if (temp > _arr[i]) {
                return false;
            }
            temp = _arr[i];
        }
        return true;
    }

    /// @return sum of the array elements
    function getArraySum(uint256[] calldata _array)
        internal
        pure
        returns (uint256)
    {
        uint256 sum = 0;
        for (uint256 i = 0; i < _array.length; i++) {
            sum = sum + _array[i];
        }
        return sum;
    }

    /// @return true if the element exists in the array
    function isInArray(address[] memory _arr, address _elem)
        internal
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < _arr.length; i++) {
            if (_arr[i] == _elem) return true;
        }
        return false;
    }
}

contract LockedCreation is LockedPoolz {
    function CreateNewPool(
        address _Token, //token to lock address
        uint256 _StartTime, //Until what time the pool will start
        uint256 _FinishTime, //Until what time the pool will end
        uint256 _StartAmount, //Total amount of the tokens to sell in the pool
        address _Owner // Who the tokens belong to
    ) external payable notZeroAddress(_Owner) returns (uint256) {
        TransferInToken(_Token, msg.sender, _StartAmount);
        if (
            WhiteList_Address != address(0) &&
            !(isUserWithoutFee(msg.sender) || isTokenWithoutFee(_Token))
        ) {
            PayFee(Fee);
        }
        CreatePool(_Token, _StartTime, _FinishTime, _StartAmount, _Owner);
    }

    function CreateMassPools(
        address _Token,
        uint256[] calldata _StartTime,
        uint256[] calldata _FinishTime,
        uint256[] calldata _StartAmount,
        address[] calldata _Owner
    )
        external
        payable
        isGreaterThanZero(_Owner.length)
        isBelowLimit(_Owner.length)
    {
        require(_Owner.length == _FinishTime.length, "Date Array Invalid");
        require(_StartTime.length == _FinishTime.length, "Date Array Invalid");
        require(_Owner.length == _StartAmount.length, "Amount Array Invalid");
        TransferInToken(_Token, msg.sender, Array.getArraySum(_StartAmount));
        if (
            WhiteList_Address != address(0) &&
            !(isUserWithoutFee(msg.sender) || isTokenWithoutFee(_Token))
        ) {
            PayFee(Fee * _Owner.length);
        }
        uint256 firstPoolId = Index;
        for (uint256 i = 0; i < _Owner.length; i++) {
            CreatePool(
                _Token,
                _StartTime[i],
                _FinishTime[i],
                _StartAmount[i],
                _Owner[i]
            );
        }
        uint256 lastPoolId = Index - 1;
        emit MassPoolsCreated(firstPoolId, lastPoolId);
    }

    // create pools with respect to finish time
    function CreatePoolsWrtTime(
        address _Token,
        uint256[] calldata _StartTime,
        uint256[] calldata _FinishTime,
        uint256[] calldata _StartAmount,
        address[] calldata _Owner
    )
        external
        payable
        isGreaterThanZero(_StartTime.length)
        isBelowLimit(_Owner.length * _FinishTime.length)
    {
        require(_Owner.length == _StartAmount.length, "Amount Array Invalid");
        require(_FinishTime.length == _StartTime.length, "Date Array Invalid");
        TransferInToken(
            _Token,
            msg.sender,
            Array.getArraySum(_StartAmount) * _FinishTime.length
        );
        uint256 firstPoolId = Index;
        if (
            WhiteList_Address != address(0) &&
            !(isUserWithoutFee(msg.sender) || isTokenWithoutFee(_Token))
        ) {
            PayFee(Fee * _Owner.length * _FinishTime.length);
        }
        for (uint256 i = 0; i < _FinishTime.length; i++) {
            for (uint256 j = 0; j < _Owner.length; j++) {
                CreatePool(
                    _Token,
                    _StartTime[i],
                    _FinishTime[i],
                    _StartAmount[j],
                    _Owner[j]
                );
            }
        }
        uint256 lastPoolId = Index - 1;
        emit MassPoolsCreated(firstPoolId, lastPoolId);
    }
}

contract LockedControl is LockedCreation {
    function PoolTransfer(uint256 _PoolId, address _NewOwner)
        external
        isPoolValid(_PoolId)
        isPoolOwner(_PoolId)
        isLocked(_PoolId)
        notZeroAddress(_NewOwner)
    {
        Pool storage pool = AllPoolz[_PoolId];
        require(_NewOwner != pool.Owner, "Can't be the same owner");
        uint256 newPoolId = SplitPool(_PoolId, pool.StartAmount, _NewOwner);
        emit PoolTransferred(newPoolId, _PoolId, _NewOwner, msg.sender);
    }

    function SplitPoolAmount(
        uint256 _PoolId,
        uint256 _NewAmount,
        address _NewOwner
    )
        external
        isPoolValid(_PoolId)
        isPoolOwner(_PoolId)
        isLocked(_PoolId)
        notZeroAddress(_NewOwner)
        returns (uint256)
    {
        uint256 poolId = SplitPool(_PoolId, _NewAmount, _NewOwner);
        return poolId;
    }

    function ApproveAllowance(
        uint256 _PoolId,
        uint256 _Amount,
        address _Spender
    )
        external
        isPoolValid(_PoolId)
        isPoolOwner(_PoolId)
        isLocked(_PoolId)
        notZeroAddress(_Spender)
    {
        Allowance[_PoolId][_Spender] = _Amount;
        emit PoolApproval(_PoolId, _Spender, _Amount);
    }

    function SplitPoolAmountFrom(
        uint256 _PoolId,
        uint256 _Amount,
        address _Address
    )
        external
        isPoolValid(_PoolId)
        isAllowed(_PoolId, _Amount)
        isLocked(_PoolId)
        notZeroAddress(_Address)
        returns (uint256)
    {
        uint256 poolId = SplitPool(_PoolId, _Amount, _Address);
        uint256 _NewAmount = Allowance[_PoolId][msg.sender] - _Amount;
        Allowance[_PoolId][msg.sender] = _NewAmount;
        return poolId;
    }
}

contract LockedPoolzData is LockedControl {
    function GetAllMyPoolsId(address _UserAddress)
        public
        view
        returns (uint256[] memory)
    {
        return MyPoolz[_UserAddress];
    }

    // function GetMyPoolzwithBalance
    // reconsider msg.sender
    function GetMyPoolsId(address _UserAddress)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] storage allIds = MyPoolz[_UserAddress];
        uint256[] memory ids = new uint256[](allIds.length);
        uint256 index;
        for (uint256 i = 0; i < allIds.length; i++) {
            if (
                AllPoolz[allIds[i]].StartAmount >
                AllPoolz[allIds[i]].DebitedAmount
            ) {
                ids[index++] = allIds[i];
            }
        }
        return Array.KeepNElementsInArray(ids, index);
    }

    function GetPoolsData(uint256[] memory _ids)
        public
        view
        returns (Pool[] memory)
    {
        Pool[] memory data = new Pool[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            require(_ids[i] < Index, "Pool does not exist");
            data[i] = Pool(
                AllPoolz[_ids[i]].StartTime,
                AllPoolz[_ids[i]].FinishTime,
                AllPoolz[_ids[i]].StartAmount,
                AllPoolz[_ids[i]].DebitedAmount,
                AllPoolz[_ids[i]].Owner,
                AllPoolz[_ids[i]].Token
            );
        }
        return data;
    }

    function GetMyPoolsIdByToken(address _UserAddress, address[] memory _Tokens)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] storage allIds = MyPoolz[_UserAddress];
        uint256[] memory ids = new uint256[](allIds.length);
        uint256 index;
        for (uint256 i = 0; i < allIds.length; i++) {
            if (Array.isInArray(_Tokens, AllPoolz[allIds[i]].Token)) {
                ids[index++] = allIds[i];
            }
        }
        return Array.KeepNElementsInArray(ids, index);
    }

    function GetMyPoolDataByToken(
        address _UserAddress,
        address[] memory _Tokens
    ) public view returns (Pool[] memory) {
        return GetPoolsData(GetMyPoolsIdByToken(_UserAddress, _Tokens));
    }

    function isTransferPoolActive(uint256 _PoolId) public view returns (bool) {
        return AllPoolz[_PoolId].DebitedAmount == 0;
    }
}

contract LockedDealV2 is LockedPoolzData {
    function getWithdrawableAmount(uint256 _PoolId)
        public
        view
        isPoolValid(_PoolId)
        returns (uint256)
    {
        Pool storage pool = AllPoolz[_PoolId];
        if (block.timestamp < pool.StartTime) return 0;
        if (pool.FinishTime < block.timestamp)
            return pool.StartAmount - pool.DebitedAmount;
        uint256 totalPoolDuration = pool.FinishTime - pool.StartTime;
        uint256 timePassed = block.timestamp - pool.StartTime;
        uint256 timePassedPermille = timePassed * 1000;
        uint256 ratioPermille = timePassedPermille / totalPoolDuration;
        uint256 debitableAmount = (pool.StartAmount * ratioPermille) / 1000;
        return debitableAmount - pool.DebitedAmount;
    }

    //@dev no use of revert to make sure the loop will work
    function WithdrawToken(uint256 _PoolId) external returns (bool) {
        //pool is finished + got left overs + did not took them
        Pool storage pool = AllPoolz[_PoolId];
        if (
            _PoolId < Index &&
            pool.StartTime <= block.timestamp &&
            pool.StartAmount - pool.DebitedAmount > 0
        ) {
            uint256 tokenAmount = getWithdrawableAmount(_PoolId);
            uint256 tempDebitAmount = tokenAmount + pool.DebitedAmount;
            pool.DebitedAmount = tempDebitAmount;
            TransferToken(pool.Token, pool.Owner, tokenAmount);
            emit TokenWithdrawn(_PoolId, pool.Owner, tokenAmount);
            return true;
        }
        return false;
    }
}