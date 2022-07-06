/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: contracts/Horse20Bank.sol


pragma solidity ^0.8.0;




interface IToken {
    function transfer(address receiver, uint256 amount) external;
    function transferFrom(address from,  address receiver, uint256 amount)external;
    function balanceOf(address account) external view returns (uint256);
}
library Signature {
    function getEthSignedMessageHash(bytes32 messageHash)
        private
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    function getSigner(bytes32 messageHash, bytes memory sig)
        internal
        pure
        returns (address)
    {
       
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return ecrecover(getEthSignedMessageHash(messageHash), v, r, s);
    }
}
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract Horse20Bank is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    struct DepositRecord { 
        address playerAddress; 
        uint256 amount; 
        uint256 depositTime; 
        address payAddress;
    }
    struct WithdrawRecord {
        uint256  orderNumber;
        uint256  amount; 
        uint256  withdrawTime; 
        address  payAddress; 
        address  playerAddress;
    }
    struct RechargeRecord {
        uint256 amount;
        address payAddress;
        address playerAddress;
        uint256 blockTime;
        bool    state;
        uint256 withdrawIndex;
    }

    uint256 public depositIndex;
    uint256 public withdrawIndex;
    address public signer;

    address[2] public partners;

    mapping(uint256 => bool) public orderList;
    mapping(address => bool) public payAddressList;
    mapping(uint256 => DepositRecord)  public depositRecords;
    mapping(uint256 => WithdrawRecord) public withdrawRecords;
    mapping(uint256 => RechargeRecord) public rechargeRecords;

    event Deposit  (address playerAddress, uint256 amount, address payAddress, uint256 depositTime); 
    event Withdraw (uint256 orderNumber, uint256 amount, uint256 withdrawTime, address payAddress, address playerAddress);
    event Recharge (uint256 orderNumber, uint256 amount, address playerAddress, uint256 blockTime);

    constructor() {
        depositIndex  = 1;
        withdrawIndex = 1;

        partners [0] = 0x3A15cC95eE2f978a4F7ceb46139dFD3a9f235e57;
        partners [1] = 0x960b0Ce82F72404b7f1cf7d9EC8BfcEA6e0710bE;
    }

    modifier onlyPayAddress(address _payAddress) {
        require(payAddressList[_payAddress], "subclass Token is not support");

        _;
    }

    function setPayAddress(address _payAddress, bool _flag) external onlyOwner {
        require(_isContract(_payAddress),"must Contract");

        payAddressList[_payAddress]=_flag;
    }

    function setSinger(address _signer) external onlyOwner{
        require(_signer != address(0), "error operator");
        require(!_isContract(_signer), "contract not allowed");
        
        signer = _signer;
    }
    
    function changePartners(address _partner1, address _partner2) external onlyOwner{
        require(_partner1 != address(0), "error address _partner1");
        require(_partner2 != address(0), "error address _partner1");

        partners [0] = _partner1;
        partners [1] = _partner2;
    }

    function depositToken(address _payAddress, uint256 _amount) external onlyPayAddress(_payAddress) nonReentrant {
        require(_amount > 0, "wrong Amount");

        IToken(_payAddress).transferFrom(_msgSender(), address(this), _amount);
        depositRecords[depositIndex] = DepositRecord(_msgSender(), _amount, block.timestamp, _payAddress);
        depositIndex++;

        emit Deposit(_msgSender(), _amount, _payAddress, block.timestamp); 
    }

    function encode(address _playerAddress, address _payAddress, uint256 _orderNumber, uint256 _amount, uint256 _fee) public onlyPayAddress(_payAddress) view returns (bytes32) {
        require(!orderList[_orderNumber], "error orderNumber");
        require(_orderNumber > 0, "orderNumber too low");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(_amount > 0, "error amount");
        require(_fee > 0 && _fee <= 1000, "error fee");

        uint256 feeAmount = _amount.mul(_fee).div(1000, "over flow").div(2, "over flow");

        require(feeAmount > 0, "error fee");

        return keccak256(abi.encodePacked(_playerAddress, _payAddress, _orderNumber, _amount, _fee));
    }

    function rechargeEncode(uint256 _orderNumber,address _payAddress, address _playerAddress, uint256 _amount) public onlyPayAddress(_payAddress) view returns (bytes32) {
        require(!orderList[_orderNumber], "error orderNumber");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(_amount > 0, "error amount");
        require(IToken(_payAddress).balanceOf(address(this)) >= _amount, "insufficient funds in the bank");

        return keccak256(abi.encodePacked(_orderNumber, _payAddress, _playerAddress, _amount));
    }
    
    function rechargeToken(uint256 _orderNumber,address _payAddress, address _playerAddress, uint256 _amount, bytes memory signature) external onlyPayAddress(_payAddress) {
        require(rechargeClaim(_orderNumber, _payAddress, _playerAddress, _amount, signature), "signature verification failed");
        require(!orderList[_orderNumber], "error orderNumber");
        require(_playerAddress != address(0), "error address");
        require(!_isContract(_playerAddress), "contract not allowed");
        require(_amount > 0, "error amount");
        require(IToken(_payAddress).balanceOf(address(this)) >= _amount, "insufficient funds in the bank");
       
        rechargeRecords[_orderNumber] = RechargeRecord(_amount, _payAddress, _playerAddress, block.timestamp, false, 0);

        emit Recharge(_orderNumber, _amount, _playerAddress, block.timestamp);
    }

    function withdrawToken(address _playerAddress,address _payAddress, uint256 _orderNumber, uint256 _amount, uint256 _fee, bytes memory signature) external nonReentrant {
        require(!orderList[_orderNumber], "error orderNumber");
        require(rechargeRecords[_orderNumber].amount >= _amount, "amount error");
        require(rechargeRecords[_orderNumber].playerAddress == _playerAddress, "playerAddress error");
        require(!rechargeRecords[_orderNumber].state, "has been processed");
        require(rechargeRecords[_orderNumber].withdrawIndex == 0, "has been processed");
        require(_msgSender() == _playerAddress, "insufficient permissions");
        require(claim(_playerAddress, _payAddress, _orderNumber, _amount, _fee, signature), "signature verification failed");
        require(IToken(_payAddress).balanceOf(address(this)) >= _amount, "insufficient funds in the bank");

        uint256 feeAmount = _amount.mul(_fee).div(1000, "over flow");

        IToken(_payAddress).transfer(_msgSender(), _amount.sub(feeAmount, "over flow"));
        IToken(_payAddress).transfer(partners [0], feeAmount.div(2, "over flow"));
        IToken(_payAddress).transfer(partners [1], feeAmount.div(2, "over flow")); 

        RechargeRecord storage rechargeRecord = rechargeRecords[_orderNumber];
        rechargeRecord.state = true;
        rechargeRecord.withdrawIndex = withdrawIndex;

        withdrawRecords[withdrawIndex] = WithdrawRecord(_orderNumber, _amount, block.timestamp, _payAddress, _playerAddress);
        withdrawIndex++;

        orderList[_orderNumber] = true;
        emit Withdraw(_orderNumber, _amount, block.timestamp, _payAddress, _msgSender());
    }

    function claim(address _playerAddress,address _payAddress, uint256 _orderNumber, uint256 _amount, uint256 _fee, bytes memory signature) private view returns(bool) {
        return Signature.getSigner(encode(_playerAddress, _payAddress, _orderNumber, _amount, _fee), signature) == signer;
    }

    function rechargeClaim(uint256 _orderNumber,address _payAddress, address _playerAddress, uint256 _amount, bytes memory signature) private view returns(bool) {
        return Signature.getSigner(rechargeEncode(_orderNumber, _payAddress, _playerAddress, _amount), signature) == signer;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}