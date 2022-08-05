/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;




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
     *
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
     *
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
     *
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
     *
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract VestingCore is Ownable {

    event VestingToken(address owner, uint256 amount);
    event AddVesting(address owner, uint256 amount);

    address public adminAddress;
    address public token;
    uint256 claimTime;
    uint256 countClaim;
    uint256 duration;

    /*** DATA TYPES ***/
    struct VestingType {
        address owner;
        uint256 amount;
        uint256 amountClaimed;
    }

    mapping(uint256 => VestingType[]) public arrVesting;
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "NOT_THE_ADMIN");
        _;
    }

    function addVesting(address[] memory _owner,  uint256[] memory _amount) external onlyAdmin {
        for(uint i=0; i<_owner.length; i++){
            VestingType memory vestingType = VestingType({
            owner: _owner[i],
            amount: _amount[i],
            amountClaimed: 0
            });
        arrVesting[0].push(vestingType);
        emit AddVesting(_owner[i], _amount[i]);
        }
    }

    function claim() external onlyAdmin {
        require(countClaim < 5, "claim surpass count");
        if (countClaim != 0) {
            require( block.timestamp >= claimTime + duration, "Invalid Time Unlock");
        }

        for(uint i=0; i<arrVesting[0].length; i++) {
            if(countClaim == 4) {
                uint256 amountClaim = arrVesting[0][i].amount - arrVesting[0][i].amountClaimed;
                require(IERC20(token).transfer(arrVesting[0][i].owner, amountClaim), "Transfer fail");
                arrVesting[0][i].amountClaimed += amountClaim;
                emit VestingToken(arrVesting[0][i].owner, amountClaim);
            } else {
                require(IERC20(token).transfer(arrVesting[0][i].owner, arrVesting[0][i].amount/5), "Transfer fail");
                arrVesting[0][i].amountClaimed += arrVesting[0][i].amount/5;
                emit VestingToken(arrVesting[0][i].owner, arrVesting[0][i].amount/5);
            }
        }
        countClaim++;
        claimTime = block.timestamp;
    }

    function deleteVesting() external onlyAdmin {
        delete arrVesting[0];
    }

    function getInfo(address _addr) external view returns(address , uint256 , uint256){
        address owner;
        uint256 amount;
        uint256 amountClaimed;
        for(uint i=0; i<arrVesting[0].length; i++){
            if(arrVesting[0][i].owner == _addr){
                owner = _addr;
                amount = arrVesting[0][i].amount / 10 **18;
                amountClaimed = arrVesting[0][i].amountClaimed;
            }
        }

        return(owner, amount, amountClaimed);
    }

    // @dev Sets the reference to the admin.
    /// @param _address - Address of admin.
    function setAdminAddress(address _address) external onlyOwner {
        adminAddress = _address;
    }

    function setDuration(uint256 _duration) external onlyOwner {
        duration = _duration;
    }

    function setCountClaim(uint256 _countClaim) external onlyOwner {
        countClaim = _countClaim;
    }

    function setClaimTime(uint256 _claimTime) external onlyOwner {
        claimTime = _claimTime;
    }

    // @dev Sets the reference to the admin.
    /// @param _address - Address of admin.
    function setTokenAddress(address _address) external onlyAdmin {
        token = _address;
    }

    function withdrawBalance(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(owner(), _amount);
    }

}