/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

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

// File: contracts/sample.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract multisigTest {
    using SafeMath for uint256;

    address private owner;
    address private minter;
    address private burner;
    address private cap;
    mapping(address => bool) private authorizers;
    address[] private authorizerList;

    bool public initialized = false;

    uint public numConfirmationsRequired = 3;

    enum TransactionType {
        UpdateOwner,
        Mint,
        Burn,
        Cap,
        UpdateAuthorizer
    }

    mapping(uint256 => mapping(address => bool)) public isConfirmed; 

    struct Transaction {
        TransactionType transactionType;
        address to;                         // new owner, mint, authorizer
        address from;                       // burn
        uint256 amount;                     // amount for each transaction
        bool isAuth;                        // for update authorizer
        bool executed;                      // is executed
        uint numConfirmations;              // num of confirmation
        bool isOwnerConfirmationRequired;   // is owner confirmation required. transfer ownership is not required owner confirmation.
    }

    Transaction[] public transactions;

    uint256 public _totalSupply;
    uint256 public _maxSupply;
    

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
        require(msg.sender == owner || authorizers[msg.sender], "you are not owner or authorizer");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "you are not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
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

    function getOwner() public view returns (address) {
        return owner;
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

    function submitTransferOwnership(address _newOwner)
        external
        isOwnerOrAuthorizer
    {
        require(_newOwner != address(0), "invalid address");

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
        require(msg.sender == burner, "you don't have a permission");

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
            if ((transaction.isOwnerConfirmationRequired && isConfirmed[_txIndex][owner])
                || transaction.isOwnerConfirmationRequired == false) {
                
                if (transaction.transactionType == TransactionType.UpdateOwner) {
                    _transferOwnership(transaction.to);
                } else if (transaction.transactionType == TransactionType.Mint) {
                    _mint(transaction.to, transaction.amount);
                } else if (transaction.transactionType == TransactionType.Burn) {
                    _burn(transaction.from, transaction.amount);
                } else if (transaction.transactionType == TransactionType.Cap) {
                    _updateCap(transaction.amount);
                } else if (transaction.transactionType == TransactionType.UpdateAuthorizer) {
                    _updateAuthorizer(transaction.to, transaction.isAuth);
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
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
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

    function _mint(address _to, uint256 _amount) internal {
        require(_maxSupply >= _totalSupply.add(_amount), "total supply is exceeded");
        require(_to != address(0), "invalid address");
        _totalSupply = _totalSupply.add(_amount);
    }

    function _burn(address _from, uint256 _amount) internal {
        require(_totalSupply.sub(_amount) >= 0, "invalid amount");
        require(_from != address(0), "invalid address");
        _totalSupply = _totalSupply.sub(_amount);
    }

    function _updateCap(uint256 amount) internal {
        _maxSupply = _maxSupply.add(amount);
    }

}