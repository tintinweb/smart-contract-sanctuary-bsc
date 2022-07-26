/**
 *Submitted for verification at BscScan.com on 2022-07-26
*/

// File: contracts/interfaces/IERC20.sol

pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/libs/Context.sol

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: contracts/libs/SafeMath.sol

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
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
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: contracts/libs/Multisig.sol

pragma solidity ^0.8.0;

abstract contract Multisig {
    using SafeMath for uint256;

    address private _owner;
    address private minter;
    address private burner;
    address private cap;
    mapping(address => bool) public authorizers;
    address[] public authorizerList;

    bool public initialized = false;

    uint public numConfirmationsRequired = 3;

    enum TransactionType {
        UpdateOwner,
        UpdateAuthorizer,
        Transfer,
        Mint,
        Burn,
        Cap
    }

    mapping(uint256 => mapping(address => bool)) public isConfirmed; 

    struct Transaction {
        TransactionType transactionType;
        address to;                         // new owner, mint, authorizer, transfer
        address from;                       // burn, transfer
        uint256 amount;                     // amount for each transaction
        bool isAuth;                        // for update authorizer
        bool executed;                      // is executed
        uint numConfirmations;              // num of confirmation
        bool isOwnerConfirmationRequired;   // is owner confirmation required. transfer ownership is not required owner confirmation.
    }

    Transaction[] public transactions;    

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    modifier isOwnerOrAuthorizer() {
        require(msg.sender == owner() || authorizers[msg.sender], "you are not owner or authorizer");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "you are not owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function initialize(
        address[] calldata _authorizers,
        address _minter,
        address _burner,
        address _cap,
        uint _numConfirmationsRequired
    ) external onlyOwner {
        require(!initialized, "already initialized");
        require(_authorizers.length > 0, "authorizer is empty");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _authorizers.length,
            "invalid number of required confirmations"
        );
        require(_minter != address(0), "minter address is invalid");
        require(_burner != address(0), "burner address is invalid");
        require(_cap != address(0), "cap address is invalid");
        

        for (uint i = 0; i < _authorizers.length; i++) {
            address _authorizer = _authorizers[i];

            require(_authorizer != address(0), "invalid address");

            if (!authorizers[_authorizer]) {
                authorizers[_authorizer] = true;
                authorizerList.push(_authorizer);
            }
        }
        minter = _minter;
        burner = _burner;
        cap = _cap;
        numConfirmationsRequired = _numConfirmationsRequired;

        initialized = true;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getMinter() public view returns (address) {
        return minter;
    }

    function getBurner() public view returns (address) {
        return burner;
    }

    function getCap() public view returns (address) {
        return cap;
    }

    function getAuthorizers() public view returns (address[] memory) {
        address[] memory _authorizers = new address[](authorizerList.length);
        uint n = 0;
        for (uint i=0; i<authorizerList.length; i++) {
            if (authorizers[authorizerList[i]]) {
                _authorizers[n] = authorizerList[i];
                n++;
            }
        }
        return _authorizers;
    }

    function getTransactionPaging(uint256 _offset, uint256 _limit)
        public
        view
        returns (
            Transaction[] memory trans,
            uint256 nextOffset,
            uint256 total
        )
    {
        total = transactions.length;
        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > total.sub(_offset)) {
            _limit = total.sub(_offset);
        }
        nextOffset = _offset.add(_limit);

        trans = new Transaction[](_limit);
        for (uint256 i = 0; i < _limit; i++) {
            trans[i] = transactions[_offset.add(i)];
        }
    }



    function submitTransferOwnership(address _newOwner)
        external
        isOwnerOrAuthorizer
    {
        require(_newOwner != address(0), "invalid address");
        require(_newOwner != owner(), "new owner must be different address");

        uint256 txIndex = transactions.length;
        transactions.push(
            Transaction({
                transactionType: TransactionType.UpdateOwner,
                to: _newOwner,
                from: address(0),
                amount: 0,
                isAuth: false,
                executed: false,
                numConfirmations: 0,
                isOwnerConfirmationRequired: false
            })
        );
        emit SubmitTransferOwnership(msg.sender, txIndex, _newOwner);
    }
    event SubmitTransferOwnership(address indexed account, uint256 indexed txIndex, address newOwner);

    function submitUpdateAuthorizer(address _authorizer, bool _isAuth)
        external
        isOwnerOrAuthorizer
    {
        require(_authorizer != address(0), "invalid address");
        require(_authorizer != owner(), "owner cannot be an authorizer");

        // check num of authorizer and numConfirmationsRequired
        if (!_isAuth && authorizers[_authorizer]) {
            uint numAuthorizer = 0;
            for (uint i=0; i<authorizerList.length; i++) {
                if (authorizers[authorizerList[i]]) {
                    numAuthorizer += 1;
                }
            }
            require(numAuthorizer > numConfirmationsRequired, "authorizer is not enough, please add authorizer first");
        }

        uint256 txIndex = transactions.length;
        transactions.push(
            Transaction({
                transactionType: TransactionType.UpdateAuthorizer,
                to: _authorizer,
                from: address(0),
                amount: 0,
                isAuth: _isAuth,
                executed: false,
                numConfirmations: 0,
                isOwnerConfirmationRequired: true
            })
        );
        emit SubmitUpdateAuthorizer(msg.sender, txIndex, _authorizer, _isAuth);
    }
    event SubmitUpdateAuthorizer(address indexed account, uint256 indexed txIndex, address authorizer, bool isAuth);

    function submitTransfer(address _to, uint256 _amount)
        external
        isOwnerOrAuthorizer
    {
        require(_to != address(0), "invalid address");

        uint256 txIndex = transactions.length;
        transactions.push(
            Transaction({
                transactionType: TransactionType.Transfer,
                to: _to,
                from: address(this),
                amount: _amount,
                isAuth: false,
                executed: false,
                numConfirmations: 0,
                isOwnerConfirmationRequired: true
            })
        );
        emit SubmitTransfer(msg.sender, txIndex, _to, _amount);
    }
    event SubmitTransfer(address indexed account, uint256 indexed txIndex, address to, uint256 amount);



    function submitMint(address _to, uint256 _amount)
        external
    {
        require(msg.sender == minter, "you don't have a permission");
        require(_to != address(0), "invalid address");

        uint256 txIndex = transactions.length;
        transactions.push(
            Transaction({
                transactionType: TransactionType.Mint,
                to: _to,
                from: address(0),
                amount: _amount,
                isAuth: false,
                executed: false,
                numConfirmations: 0,
                isOwnerConfirmationRequired: true
            })
        );
        emit SubmitMint(msg.sender, txIndex, _to, _amount);
    }
    event SubmitMint(address indexed account, uint256 indexed txIndex, address to, uint256 amount);


    function submitBurn(uint256 _amount)
        external
    {
        require(msg.sender == burner, "you don't have a permission");

        uint256 txIndex = transactions.length;
        transactions.push(
            Transaction({
                transactionType: TransactionType.Burn,
                to: address(0),
                from: msg.sender,
                amount: _amount,
                isAuth: false,
                executed: false,
                numConfirmations: 0,
                isOwnerConfirmationRequired: true
            })
        );
        emit SubmitBurn(msg.sender, txIndex, _amount);
    }
    event SubmitBurn(address indexed account, uint256 indexed txIndex, uint256 amount);

    function submitUpdateCap(uint256 _amount)
        external
    {
        require(msg.sender == cap, "you don't have a permission");

        uint256 txIndex = transactions.length;
        transactions.push(
            Transaction({
                transactionType: TransactionType.Cap,
                to: address(0),
                from: address(0),
                amount: _amount,
                isAuth: false,
                executed: false,
                numConfirmations: 0,
                isOwnerConfirmationRequired: true
            })
        );
        emit SubmitUpdateCap(msg.sender, txIndex, _amount);
    }
    event SubmitUpdateCap(address indexed account, uint256 indexed txIndex, uint256 amount);


    function confirmTransaction(uint256 _txIndex) 
        external 
        isOwnerOrAuthorizer 
        txExists(_txIndex)
        notConfirmed(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);

        _executeTransaction(_txIndex);
    }
    event ConfirmTransaction(address indexed account, uint256 txIndex);

    function executeTransaction(uint256 _txIndex)
        external
    {
        _executeTransaction(_txIndex);
    }

    function _executeTransaction(uint256 _txIndex)
        internal
        txExists(_txIndex)
        notExecuted(_txIndex)        
    {
        Transaction storage transaction = transactions[_txIndex];
        if (transaction.numConfirmations >= numConfirmationsRequired) {
            if ((transaction.isOwnerConfirmationRequired && isConfirmed[_txIndex][owner()])
                || transaction.isOwnerConfirmationRequired == false) {
                
                if (transaction.transactionType == TransactionType.UpdateOwner) {
                    _transferOwnership(transaction.to);
                    transaction.executed = true;

                } else if (transaction.transactionType == TransactionType.UpdateAuthorizer) {
                    _updateAuthorizer(transaction.to, transaction.isAuth);
                    transaction.executed = true;

                } else if (transaction.transactionType == TransactionType.Transfer) {
                    _transfer(transaction.from, transaction.to, transaction.amount);
                    transaction.executed = true;

                } else if (transaction.transactionType == TransactionType.Mint) {
                    _mint(transaction.to, transaction.amount);
                    transaction.executed = true;

                } else if (transaction.transactionType == TransactionType.Burn) {
                    _burn(transaction.from, transaction.amount);
                    transaction.executed = true;

                } else if (transaction.transactionType == TransactionType.Cap) {
                    _updateMaxSupply(transaction.amount);
                    transaction.executed = true;

                }

            }
        }
    }

    function revokeConfirmation(uint256 _txIndex)
        public
        isOwnerOrAuthorizer
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }
    event RevokeConfirmation(address indexed account, uint256 txIndex);

    function _transferOwnership(address _newOwner) internal {
        emit TransferOwnership(owner(), _newOwner);
        _owner = _newOwner;
    }
    event TransferOwnership(address oldOwner, address newOwner);

    function _updateAuthorizer(address _authorizer, bool _isAuth) internal {
        authorizers[_authorizer] = _isAuth;

        bool isExist = false;
        for (uint i=0; i<authorizerList.length; i++) {
            if (authorizerList[i] == _authorizer) {
                isExist = true;
                break;
            }
        }
        if (!isExist) {
            authorizerList.push(_authorizer);
        }
        emit UpdateAuthorizer(_authorizer, _isAuth);

    }
    event UpdateAuthorizer(address indexed account, bool isAuth);

    function _transfer(address _from, address _to, uint256 _amount) internal virtual {
    }

    function _mint(address _to, uint256 _amount) internal virtual {
    }

    function _burn(address _from, uint256 _amount) internal virtual {
    }

    function _updateMaxSupply(uint256 _amount) internal virtual {
    }
}



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



contract LGLG is IBEP20, Multisig, Context {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _maxSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  constructor() {
    _name = "LGLG";
    _symbol = "LGLG";
    _decimals = 18;
    _totalSupply = 0;
    _maxSupply = 0;
  }

  /**
   * @dev Returns the token owner.
   */
  function getOwner() external override view returns (address) {
    return owner();
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external override view returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external override view returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external override view returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external override view returns (uint256) {
    return _totalSupply;
  }
  /**
   * @dev Max Supply
   */
  function maxSupply() external view returns (uint256) {
    return _maxSupply;
  }
  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external override view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external override view returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
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
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
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
  function _transfer(address sender, address recipient, uint256 amount) internal override {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
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
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Mint the token to the recipient address
   */
  function _mint(address recipient, uint256 amount) internal override {
      require(recipient != address(0), "BEP20: mint to the zero address");
      require(_maxSupply >= _totalSupply.add(amount), "total supply is exceeded");

      _balances[recipient] = _balances[recipient].add(amount);
      _totalSupply = _totalSupply.add(amount);

      emit Mint(recipient, amount);
      emit Transfer(address(this), recipient, amount);
  } 
  event Mint(address indexed recipient, uint256 amount);

  /**
   * @dev Burn the token in the sender address
   */
  function _burn(address source, uint256 amount) internal override {
      require(amount > 0, "BEP20: amount is zero");
      require(_balances[source] >= amount, "BEP20: insufficient balance");
      _balances[source] = _balances[source].sub(amount);
      _totalSupply = _totalSupply.sub(amount);

      emit Burn(source, amount);
  } 
  event Burn(address indexed account, uint256 amount);

  /**
   * @dev Update MaxSupply
   */
  function _updateMaxSupply(uint256 amount) internal override {
      require(amount > 0, "BEP20: amount is zero");
      require(_totalSupply < amount, "it must be greater than total supply");

      emit UpdateMaxSupply(_maxSupply, amount);
      _maxSupply = amount;

  } 
  event UpdateMaxSupply(uint oldMaxSupply, uint256 newMaxSupply);

}