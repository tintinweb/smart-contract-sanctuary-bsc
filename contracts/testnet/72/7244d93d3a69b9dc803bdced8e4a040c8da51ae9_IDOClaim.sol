/**
 *Submitted for verification at BscScan.com on 2022-07-15
*/

pragma solidity ^0.5.16;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

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
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
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
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
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
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
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
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
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

contract IDOClaim {
    using SafeMath for uint;

    bool public isStopped;

    address public token;
    address[] public recipient;
    address public owner;

    mapping(address => uint256) public vestingAmount;

    uint256 public claimTimestamp;
    uint256 public TGE = 40;

    mapping(address => bool) public isRecipientClaimed;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(
        address token_,
        uint256 claimTimestamp_
    ) public {
        require(claimTimestamp_ >= block.timestamp, 'IDOClaim::constructor: vesting begin too early');
        require(token_ != address(0) && token_ != address(this), "Token must not be 0x00 or this");

        owner = msg.sender;
        token = token_;

        claimTimestamp = claimTimestamp_;

        isStopped = false;
    }

    function setClaimTimestamp(uint256 claimTimestamp_) public onlyOwner {
        require(claimTimestamp_ >= block.timestamp, 'IDOClaim::constructor: vesting begin too early');

        claimTimestamp = claimTimestamp_;
    }

    function setTGE(uint256 TGE_) public onlyOwner {
        require(TGE_ <= 100, 'IDOClaim::setTGE: TGE must under 100');

        TGE = TGE_;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setRecipient(address _newRecipient) public {
        require(isRecipientClaimed[msg.sender] == false, 'IDOClaim::claim: you are claimed'); 
        require(isRecipientClaimed[_newRecipient] == false, 'IDOClaim::claim: new recipient is claimed'); 
        bool isRecipient = false;
        uint256 index;
        for(uint256 i; i<recipient.length; i++){
            if(address(msg.sender) == recipient[i]){
                isRecipient = true;
                index = i;
                break;
            }
        }
        require(isRecipient, 'IDOClaim::setRecipient: unauthorized');

        vestingAmount[_newRecipient] = vestingAmount[msg.sender];
        vestingAmount[msg.sender] = 0;
        recipient[index] = _newRecipient;
    }

    function addRecipients(address[] memory recipient_, uint256[] memory vestingAmount_) public onlyOwner {
        for(uint256 i; i<recipient_.length; i++){
            recipient.push(recipient_[i]);
            vestingAmount[recipient_[i]] = vestingAmount_[i];
        }
    }

    function updateRecipients(address _oldRecipient, address _newRecipient, uint _newVestingAmt) public onlyOwner{
        bool recipientExisted = false;
        uint256 index;
        for(uint256 i; i<recipient.length; i++){
            if(_oldRecipient == recipient[i]){
                recipientExisted = true;
                index = i;
                break;
            }
        }
        if(recipientExisted){
            if(_oldRecipient == _newRecipient){
                vestingAmount[_newRecipient] = _newVestingAmt;
                return;
            }

            vestingAmount[_newRecipient] = vestingAmount[_oldRecipient];
            vestingAmount[_oldRecipient] = 0;
            recipient[index] = _newRecipient;
        }
        else{
            vestingAmount[_newRecipient] = _newVestingAmt;
            recipient.push(_newRecipient);
        }

        isRecipientClaimed[_newRecipient] = false;

        return;
    }

    function deleteRecipient(address _recipient) public onlyOwner{
        bool recipientExisted = false;
        uint256 index;
        for(uint256 i; i<recipient.length; i++){
            if(_recipient == recipient[i]){
                recipientExisted = true;
                index = i;
                break;
            }
        }
        if(recipientExisted){
            vestingAmount[_recipient] = 0;
            recipient[index] = address(0);
        }
    }

    function claim() public {
        require(!isStopped, "IDO claim has stopped");
        require(isRecipientClaimed[msg.sender] == false, 'IDOClaim::claim: you claimed'); 
        require(block.timestamp >= claimTimestamp, 'IDOClaim::claim: not time yet');

        uint256 amount = vestingAmount[msg.sender].mul(40).div(100);
        isRecipientClaimed[msg.sender] = true;
        IToken(token).transfer(msg.sender, amount);
    }
    
    function stop() external onlyOwner {
        isStopped = true;
        claimTimestamp = block.timestamp;
        uint256 amount = IToken(token).balanceOf(address(this));
        IToken(token).transfer(msg.sender, amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
}
    
interface IToken {
    function balanceOf(address account) external view returns (uint);
    function transfer(address dst, uint rawAmount) external returns (bool);
}