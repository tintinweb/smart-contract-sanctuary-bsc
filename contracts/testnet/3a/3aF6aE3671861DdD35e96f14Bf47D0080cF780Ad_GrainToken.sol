/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT
// File: contracts/TestToken/BEP20Ownable.sol

pragma solidity 0.8.16;

contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function getOwner() external view returns (address) {
    return owner;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}
// File: openzeppelin-solidity/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity 0.8.16;

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

// File: contracts/TestToken/BEP20Basic.sol

pragma solidity 0.8.16;

interface BEP20Basic {
    function totalSupply() external returns (uint256);
    function balanceOf(address account) external returns (uint256);
    function allowance(address owner, address spender) external returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address recipient, uint256 value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approve(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/TestToken/BEP20Standart.sol

pragma solidity 0.8.16;

contract BEP20Standart is BEP20Basic {
    using SafeMath for uint256;
    uint256 internal _totalSupply;  

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

        function totalSupply() public view override returns (uint256) {
        return _totalSupply;
        }

        function balanceOf (address account) public view override returns (uint256) {
            return _balances[account];
        }
        
        function transfer(address recipient, uint256 value) public override returns (bool) {
        _transfer(msg.sender, recipient, value);
        emit Transfer(msg.sender, recipient, value);
        return true;
        }

        function transferFrom(address sender, address recipient, uint256 value) public override returns (bool){
            require(sender != address(0), "Invalid sender address");
            require(recipient != address(0), "Invalid recipient address");
            require(_balances[sender] >value, "Transfer amount exceeds balance");
            _transfer(sender, recipient, value);
            emit Transfer(sender, recipient, value);
            emit Approve(sender, msg.sender, _allowances[sender][msg.sender]);
            return true;
        }

        function allowance(address owner, address spender) public view override returns (uint256){
            return _allowances[owner][spender];
        }

        function approve(address spender, uint256 value) public override returns (bool) {
            require(spender != address(0), "Invalid spender address");
            _allowances[msg.sender][spender] = value;
            emit Approve(msg.sender, spender, value);
            return true;
        }

        function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
            require(spender != address(0), "Invalid spender address");
            _allowances[spender][msg.sender] = _allowances[spender][msg.sender].add(addedValue);
            emit Approve(msg.sender, spender, addedValue);
            return true;

        }

        function decreaseAllowance(address spender, uint256 substractedValue) public returns (bool) {
            require(spender != address(0), "Invalid spender address");
            _allowances[spender][msg.sender] = _allowances[spender][msg.sender].sub(substractedValue);
            emit Approve(msg.sender, spender, substractedValue);
            return true;
        }

        function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
        function _approve(address owner, address spender, uint256 value) internal {
            require(owner != address(0), "Invalid owner address");
            require(spender != address(0), "Invalid spender address");
            _allowances[owner][spender] = value;
            emit Approve(owner, spender,value);
        }
}
// File: contracts/TestToken/BurnableBEP20.sol

pragma solidity 0.8.16;

contract BurnableBEP20 is Ownable, BEP20Standart {
  using SafeMath for uint256;

  event Burn(address indexed burner, uint256 value);

  function burn(address burner, uint256 value) public {
    _burn(burner, value);
  }

  function _burn(address burner, uint256 value) internal {
    require(value <= _balances[burner]);
    _balances[burner] = _balances[burner].sub(value);
    _totalSupply = _totalSupply.sub(value);
    emit Burn(burner, value);
    emit Transfer(burner, address(0), value);
  }

}


// File: contracts/TestToken/MintableBEP20.sol

pragma solidity 0.8.16;

contract MintableBEP20 is Ownable, BEP20Standart {
    using SafeMath for uint256;
    uint256 private _initialSupply;

    event Mint(address receiver, uint256 value);
    event MintFinished();
    bool public mintingFinished = false;

    modifier canMint () {
        require (!mintingFinished);
        _;
    }

    modifier hasMintPermission () {
        require (msg.sender == owner);
        _;
    }

    function mint(address minter, uint256 value) public hasMintPermission canMint returns (bool) {
    _totalSupply = _totalSupply.add(value);
    _balances[minter] = _balances[minter].add(value);
    emit Mint(minter, value);
    emit Transfer(address(0), minter, value);
    return true;
  }

    function finishMinting() public hasMintPermission canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: contracts/TestToken/BEP20Detailed.sol

pragma solidity 0.8.16;

contract BEP20Detailed is MintableBEP20, BurnableBEP20 {

     string private _name;
     string private _symbol;
     uint8 private _decimals;


    constructor(string memory name, string memory symbol, uint8 decimals) {
      _name = name;
      _symbol = symbol;
      _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

}
// File: contracts/TestToken/SabexToken.sol

pragma solidity 0.8.16;

contract GrainToken is Ownable, BEP20Detailed  {

constructor (string memory name, string memory symbol, uint8 decimals, uint256 _totalSupply) 
    BEP20Detailed (name, symbol, decimals) {
        mint(msg.sender, _totalSupply);
    }
}