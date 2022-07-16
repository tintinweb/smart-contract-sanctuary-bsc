/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT
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


contract Ownable {
    address _owner;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "OwnerRole: caller does not have the Owner role");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == _owner;
    }
}


/**
* @author Arvind Kalra (github.com/arvindkalra) and Pranav Singhal (github.com/pranav-singhal)
* @title TokenStorage
*/
contract TokenStorage  is Ownable{
    using SafeMath for uint256;

    //    mapping (address => bool) internal _allowedAccess;

    // Access Modifier for Storage contract
    address internal _registryContract;

    constructor() public {
        _owner = msg.sender;
    }

    function setProxyContract(address proxyContract) onlyOwner public{
        require(proxyContract != address(0), "InvalidAddress: invalid address passed for proxy contract");
        _registryContract = proxyContract;
    }

    function getRegistryContract() view public returns(address){
        return _registryContract;
    }

    //    function addDeligateContract(address upgradedDeligatee) public{
    //        require(msg.sender == _registryContract, "AccessDenied: only registry contract allowed access");
    //        _allowedAccess[upgradedDeligatee] = true;
    //    }

    modifier onlyAllowedAccess() {
        require(msg.sender == _registryContract, "AccessDenied: This address is not allowed to access the storage");
        _;
    }

    // Allowances with its Getter and Setter
    mapping (address => mapping (address => uint256)) internal _allowances;

    function setAllowance(address _tokenHolder, address _spender, uint256 _value) public onlyAllowedAccess {
        _allowances[_tokenHolder][_spender] = _value;
    }

    function getAllowance(address _tokenHolder, address _spender) public view onlyAllowedAccess returns(uint256){
        return _allowances[_tokenHolder][_spender];
    }


    // Balances with its Getter and Setter
    mapping (address => uint256) internal _balances;
    function addBalance(address _addr, uint256 _value) public onlyAllowedAccess {
        _balances[_addr] = _balances[_addr].add(_value);
    }

    function subBalance(address _addr, uint256 _value) public onlyAllowedAccess {
        _balances[_addr] = _balances[_addr].sub(_value);
    }

    function setBalance(address _addr, uint256 _value) public onlyAllowedAccess {
        _balances[_addr] = _value;
    }

    function getBalance(address _addr) public view onlyAllowedAccess returns(uint256){
        return _balances[_addr];
    }

    // Total Supply with Getter and Setter
    uint256 internal _totalSupply = 0;

    function addTotalSupply(uint256 _value) public onlyAllowedAccess {
        _totalSupply = _totalSupply.add(_value);
    }

    function subTotalSupply(uint256 _value) public onlyAllowedAccess {
        _totalSupply = _totalSupply.sub(_value);
    }

    function setTotalSupply(uint256 _value) public onlyAllowedAccess {
        _totalSupply = _value;
    }

    function getTotalSupply() public view onlyAllowedAccess returns(uint256) {
        return(_totalSupply);
    }
}