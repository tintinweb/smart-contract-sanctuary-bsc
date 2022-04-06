// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16;

import "./utils/SafeMath.sol";
import "./utils/Ownable.sol";
import "./interfaces/IERC20.sol";

contract BSCSwapIn is Ownable {
    // Using SafeMath for calculation utility
    using SafeMath for uint256;

    // Public parameter for BEP20 Token address
    IERC20 public BEP20Token;

    // Public parameter for transfer limit on each time
    uint256 public amountLimitPerTrans;

    // Public parameter for transfer minimum on each time
    uint256 public amountRequirePerTrans;

    // Group of Mapping parameter use to support and interactive with BEP20 Bridge workflow process by use sourceTx(Bridge Ticket ID) to be the key index
    mapping(string => address) public destAddr; // To keep destination address on each transaction
    mapping(string => string) public destMemoText; // To keep destination memo text on each transaction
    mapping(string => uint256) public swapAmount; // To keep transfer amount on each transaction
    mapping(string => string) public sourceTx; // To keep source Bridge Ticket ID on each transaction
    mapping(string => uint256) public sourceChain; // To keep our source chain ID on each transaction and possible value are 1 = Stellar, 2 = Klaytn

    // Swap event thrown to contract event
    event Swap(
        address _from,
        address _to,
        string _memoText,
        uint256 _amount,
        string _sourceTx,
        uint256 _sourceChain
    );
    // Transfer event thrown to contract event
    event Transfer(
        address _from,
        address _to,
        string _memoText,
        uint256 _amount
    );

    // BSCSwapIn Constructor
    // There are 3 arguments that constructor need when deploy
    // 1.) BEP20 Token's address on Binance Smart Chain
    // 2.) Amount limit that allow user transfer BEP20 Token on each time
    // 3.) Amount require that allow user transfer BEP20 Token on each time
    constructor(IERC20 _BEP20Token, uint256 _amountLimitPerTrans, uint256 _amountRequirePerTrans) public {
        BEP20Token = _BEP20Token;
        amountLimitPerTrans = _amountLimitPerTrans;
        amountRequirePerTrans =  _amountRequirePerTrans;
    }

    // public function allow only owner use to set limitation bridge amount on each time
    function setAmountLimitPerTrans(uint256 _amountLimitPerTrans)
        public
        onlyOwner
    {
        amountLimitPerTrans = _amountLimitPerTrans;
    }

    // public function allow only owner use to set limitation bridge amount on each time
    function setAmountRequirePerTrans(uint256 _amountRequirePerTrans)
        public
        onlyOwner
    {
        amountRequirePerTrans = _amountRequirePerTrans;
    }

    // public function that return BEP20 Token balance in this contract
    function bep20ContractBalance() public view returns (uint256) {
        return BEP20Token.balanceOf(address(this));
    }

    // The key function is swap use to transfer BEP20 Token from our contract to destination address of user in this network.
    // There are 5 arguments that need to use in swap function
    // 1.) _toAddr : Destination address in this network
    // 2.) _toMemo : Memo Text
    // 3.) _amount : Number of amount
    // 4.) _sourceTx : Bridge Ticket ID to use for reference with over all process
    // 5.) _sourceChain : Source chain of this transaction (possible value are 1 = Stellar, 2 = Klaytn)
    function swap(
        address _toAddr,
        string memory _toMemo,
        uint256 _amount,
        string memory _sourceTx,
        uint256 _sourceChain
    ) public payable onlyOwner returns (bool) {
        // To check duplicate of Bridge Ticket ID
        require(
            bytes(sourceTx[_sourceTx]).length <= 0,
            "Source transaction is already exists"
        );

        // To check destination address is require
        require(_toAddr != address(0), "Destination address is require");

        // To check bridge amount is require and must more than or equal to amountRequirePerTrans
        require(_amount >= amountRequirePerTrans, "Swap amount is lower than minimum requirement");

        // To check Bridge Ticket ID is require
        require(
            bytes(_sourceTx).length > 0,
            "Source Transaction ID is require"
        );

        // To check source chain of this transaction is require and possible value only be 1 or 2 (1 = Stellar, 2 = Klaytn)
        require(
            _sourceChain == 2,
            "Source Chain is require"
        );

        // To check bridge amount must less than or equal limitation amount of each time
        require(
            _amount <= amountLimitPerTrans,
            "Amount has exceed maximum limit allow"
        );

        // To check balance of BEP20 Token in contract is sufficient for this transaction
        require(bep20ContractBalance() >= _amount, "Balance is not enough");

        // Store transaction data into mapping with key sourceTx(Bridge Ticket ID)
        destAddr[_sourceTx] = _toAddr;
        destMemoText[_sourceTx] = _toMemo;
        swapAmount[_sourceTx] = _amount;
        sourceTx[_sourceTx] = _sourceTx;
        sourceChain[_sourceTx] = _sourceChain;

        // Transfer BEP20 Token from contract to user's destination address
        BEP20Token.transfer(_toAddr, _amount);

        // Emit Swap event
        emit Swap(
            address(this),
            _toAddr,
            _toMemo,
            _amount,
            _sourceTx,
            _sourceChain
        );

        return true;
    }

    // Transfer function use only for Owner to transfer BEP20 Token from this contract to any address in this network
    // There are 3 arguments that need to use in this function
    // 1.) _toAddr : Destination address in this network
    // 3.) _amount : Number of amount
    function transfer(
        address _toAddr,
        string memory _toMemo,
        uint256 _amount
    ) public payable onlyOwner returns (bool) {
        // To check destination address is require
        require(_toAddr != address(0), "Destination address is require");

        // To check bridge amount is require and must more than 0
        require(_amount > 0, "Swap amount is require");

        // To check balance of BEP20 Token in contract is sufficient for this transaction
        require(bep20ContractBalance() >= _amount, "Balance is not enough");

        // To check bridge amount must less than or equal limitation amount of each time
        require(
            _amount <= amountLimitPerTrans,
            "Amount has exceed maximum limit allow"
        );

        // Transfer BEP20 Token from contract to user's destination address
        BEP20Token.transfer(_toAddr, _amount);

        // Emit Transfer event
        emit Transfer(address(this), _toAddr, _toMemo, _amount);

        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

import "./Context.sol";

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}