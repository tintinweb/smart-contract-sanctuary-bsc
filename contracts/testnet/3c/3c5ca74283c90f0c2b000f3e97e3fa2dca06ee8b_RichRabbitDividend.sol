/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT

// Dependency file: @openzeppelin/contracts/utils/math/SafeMath.sol

// pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.10;

interface RichRabbit_Interface {
    function viewAccount(uint _token) external view returns(uint256);
    function redeem() external returns(bool);
    function viewAccountTotal(address account_) external view returns(uint256);
    function viewDividendTotal() external view returns(uint256);
    function reDistribution() external returns(bool);
}

interface RichRabbitNFT{
    function totalSupply() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address account) external view returns (uint256);
}

interface RichRabbitCheck{
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract RichRabbitDividend is RichRabbit_Interface {
    using SafeMath for uint256;
    uint256 public totalSupply;
    uint public maxSupply;
    mapping (uint => Tokens) public accounts;
    struct Tokens{
        uint256 amount;
    }

    address private tokenAddress_ = address(0x02B3F45dBafC972dD4a3194a690c7d78ab65c712);
    address private nftAddress_ = address(0x3E211c97398E9ECA97e3A5EA671A7174EEEf7c78);
    address private _paymentAddress = address(0x6CB0ED7C8d911564e543EAcA9208D81642ec65f9);

    RichRabbitCheck public tokenAddress = RichRabbitCheck(tokenAddress_);
    RichRabbitNFT public firstCollection = RichRabbitNFT(nftAddress_);

    constructor(){
        getTotalSupply();
        maxSupply = 999;
    }
    //Only Token Holders can use contract
    modifier TokenHolder{
        require(checkTokens()== true, "only token holders can access");
        _;
    }

    /// @return status of wheather the holder possess the token
    function checkTokens() internal view returns(bool){
        uint token;
        for(token=0;token <= totalSupply-1;token++){
            if(firstCollection.ownerOf(token) == msg.sender){
                return true;
            }
        }
        return false;
    }

    function callFromFallback(uint256 _singleshare) internal{
        uint CurrentCount=0;
        for(CurrentCount;CurrentCount<=totalSupply-1;CurrentCount++){
            accounts[CurrentCount].amount += _singleshare;
        }
    }
    //Account of your funds in contract
    function viewAccount(uint _token) public view returns(uint256){
        require(_token<=totalSupply-1,"incorrect token number");
        return accounts[_token].amount;
    }

    function viewAccountTotal(address account_) public view returns(uint256){
        uint256 total=0;
        for(uint tokens=0;tokens<=totalSupply-1;tokens++){
            if(firstCollection.ownerOf(tokens) == account_){
                total += viewAccount(tokens);
            }
        }
        return total;
    }

    function viewDividendTotal() public view returns(uint256){
        uint256 total=0;
        for(uint tokens=0;tokens<=totalSupply-1;tokens++){
            total += viewAccount(tokens);
        }
        return total;
    }
    
    //redeem Dividends from treasury
    function redeem() public TokenHolder returns(bool){
        uint256 total=0;
        for(uint tokens=0;tokens<=totalSupply-1;tokens++){
            if(firstCollection.ownerOf(tokens) == msg.sender){
                total += accounts[tokens].amount;
                accounts[tokens].amount = 0;
            }
        }
        if(total > 0){
            tokenAddress.transfer(msg.sender, total);
        }
        return true;
    }

    function setpaymentAddress(address paymentAddress) external {
         _paymentAddress = paymentAddress;
    }

    function withdraw() external {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficient balance");
        (bool success, ) = payable(_paymentAddress).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function getTotalSupply() internal returns(uint) {
        totalSupply = firstCollection.totalSupply();
        return totalSupply;
    }

    function reDistribution() public returns(bool) {
        uint256 tokenAmount_ = tokenAddress.balanceOf(address(this)) - viewDividendTotal();
        uint256 single_share = tokenAmount_.div(getTotalSupply());
        callFromFallback(single_share);
        return true;
    }
    //Payments made to the contract
    receive() external payable {
        reDistribution();
    }
}