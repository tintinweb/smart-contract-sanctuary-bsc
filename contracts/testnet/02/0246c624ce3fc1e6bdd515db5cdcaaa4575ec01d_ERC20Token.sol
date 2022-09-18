/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract ERC20Token is IERC20 {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    address private _owner;
    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        _name = "Token 2";
        _symbol = "Token2";
        _decimals = 18;
        _totalSupply = 10000000000000000000000;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function _approve(address addressOwner, address spender, uint256 amount) internal {
        require(addressOwner != address(0), "owner is zero address");
        require(spender != address(0), "spender is zero address");

        _allowances[addressOwner][spender] = amount;
        emit Approval(addressOwner, spender, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address addressOwner, address spender) external view returns (uint256) {
        return _allowances[addressOwner][spender];
    }

    mapping(address=>bool) LPArr;

    function addLPArr(address addressLP) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(!LPArr[addressLP], "address already listed");
        LPArr[addressLP] = true;
    }

    function removeLPArr(address addressLP) public {
        require(_owner == msg.sender, "caller is not the owner");
        require(LPArr[addressLP], "address not already listed");
        LPArr[addressLP] = false;
    }

    function checkLPArr(address addressLP) external view returns (bool) {
        return LPArr[addressLP];
    }

    address private _addressTax;

    function setAddressTax(address newAddress) public {
        require(_owner == msg.sender, "caller is not the owner");
        _addressTax = newAddress;
    }

    uint8 private _percentTaxSell = 0;

    function setPercentTaxSell(uint8 TaxSell) public {
        require(_owner == msg.sender, "caller is not the owner");
        _percentTaxSell = TaxSell;
    }

    uint8 private _percentTaxBuy = 0;

    function setPercentTaxBuy(uint8 TaxBuy) public {
        require(_owner == msg.sender, "caller is not the owner");
        _percentTaxBuy = TaxBuy;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "sender is zero address");
        require(recipient != address(0), "recipient is zero address");
        require(amount <= _balances[sender], "transfer amount exceeds balance");

        _balances[sender] = SafeMath.sub(_balances[sender], amount);

        if(LPArr[sender] && _percentTaxBuy>0){
            uint256[] memory amountArr = new uint256[](3);
            amountArr[0] = SafeMath.div(amount, 100); // 1%
            amountArr[1] = SafeMath.mul(amountArr[0], _percentTaxBuy); // amount Tax Buy
            amountArr[2] = SafeMath.sub(amount, amountArr[1]); // amount transfer

            _balances[_addressTax] = SafeMath.add(_balances[_addressTax], amountArr[1]);
            emit Transfer(sender, _addressTax, amountArr[1]);
            _balances[recipient] = SafeMath.add(_balances[recipient], amountArr[2]);
            emit Transfer(sender, recipient, amountArr[2]);
        } else if(LPArr[recipient] && _percentTaxSell>0){
            uint256[] memory amountArr = new uint256[](3);
            amountArr[0] = SafeMath.div(amount, 100); // 1%
            amountArr[1] = SafeMath.mul(amountArr[0], _percentTaxSell); // amount Tax Sell
            amountArr[2] = SafeMath.sub(amount, amountArr[1]); // amount transfer

            _balances[_addressTax] = SafeMath.add(_balances[_addressTax], amountArr[1]);
            emit Transfer(sender, _addressTax, amountArr[1]);
            _balances[recipient] = SafeMath.add(_balances[recipient], amountArr[2]);
            emit Transfer(sender, recipient, amountArr[2]);
        } else {
            _balances[recipient] = SafeMath.add(_balances[recipient], amount);
            emit Transfer(sender, recipient, amount);
        }
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, SafeMath.sub(_allowances[sender][msg.sender], amount, "transfer amount exceeds allowance"));
        return true;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function setOwner(address newOwner) public {
        require(_owner == msg.sender, "caller is not the owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function contractTokensTransfer(address _token, address _to, uint256 _amount) external {
        require(_owner == msg.sender, "caller is not the owner");
        IERC20 contractToken = IERC20(_token);
        contractToken.transfer(_to, _amount);
    }

    function contractEthTransfer(address _to, uint256 _amount) external {
        require(_owner == msg.sender, "caller is not the owner");
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}