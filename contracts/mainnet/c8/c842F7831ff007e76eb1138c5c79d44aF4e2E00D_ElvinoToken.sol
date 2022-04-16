/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * -------
 * Context
 * -------
 */
abstract contract Context {

    // Get msg.sender
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    // Get msg.data
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * --------
 * Counters
 * --------
 */
library Counters {

    // Define counter struct
    struct Counter {
        uint256 _value;
    }

    // Get current counter value
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    // Increment counter
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    // Decrement counter
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    // Reset counter
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

/**
 * -------
 * Ownable
 * -------
 */
contract Ownable is Context {
    address public _owner;

    // On deploy, transfers ownership to msg.sender
    constructor() {
        _transferOwnership(_msgSender());
    }

    // Get owner
    function owner() public view virtual returns (address) {
        return _owner;
    }

    // Only owner modifier
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // renounce ownership
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    // Transfer ownership to new owner
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    // Transfer ownership to new owner (internal)
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    // Ownership transferred event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

/**
 * ----------------
 * SafeMath library
 * ----------------
 */
library SafeMath {

    // Add
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    // Subtract
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    // Multiply
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    // Divide
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    // Module
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * ---------------
 * Address library
 * ---------------
 */
library Address {

    // Check if address is a contract
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    // Send value to address
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    // Call function on address
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    // call function on address with value
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * ------
 * IBEP20
 * ------
 */
interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * --------------
 * IBEP20Metadata
 * --------------
 */
interface IBEP20Metadata is IBEP20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);
}

/**
 * -----
 * BEP20
 * -----
 */
abstract contract BEP20 is Context, IBEP20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 internal _totalSupply;

    // Return total supply
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // Get address balance
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    // Transfer from msg.sender to address the amount
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    // Check allowance from owner to spender
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Approve from msg.sender to spender the amount
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    // Transfer from address to address the amount
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    // Increase allowance from msg.sender to spender the amount
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    // Decrease allowance from msg.sender to spender the amount
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "BEP20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // Transfer
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    // Mint
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "BEP20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // Burn
    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "BEP20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "BEP20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    // Approve
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Spend allowance
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "BEP20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    // Before  token transfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // After token transfer
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

/**
 * -------------
 * BEP20Burnable
 * -------------
 */
abstract contract BEP20Burnable is Context, BEP20 {

    // Burn
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    // Burn from
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

/**
 * -----------
 * BEP20 Token
 * -----------
 */
contract ElvinoToken is BEP20Burnable, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;

    string private _name;
    string private _symbol;
    uint256 private _DECIMALS;
    uint256 private _MAX = ~uint256(0);
    uint256 private _DECIMALFACTOR;
    uint256 private _tTotal;
    uint256 private _rTotal;

    constructor(
        string memory name_, 
        string memory symbol_,
        uint256 decimals_,
        uint256 initialSupply,
        address Owner_
    ) {
        // Set token data
        _name = name_;
        _symbol = symbol_;
        _DECIMALS = decimals_;
        
        // Setting the initial supply
        _DECIMALFACTOR = 10 ** uint256(_DECIMALS);
        _tTotal = initialSupply * _DECIMALFACTOR;
        _rTotal = (_MAX - (_MAX % _tTotal));

        _owner = Owner_;
        _rOwned[Owner_] = _rTotal;

        // Minting tokens based on supply
        _mint(_msgSender(), _tTotal);
    }

    // Get token name
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    // Get token symbol
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    // Get token decimals
    function decimals() public view virtual override returns (uint256) {
        return _DECIMALS;
    }

    // Burn should be only called by the owner
    function burn(uint256 amount) public virtual override onlyOwner {
        _burn(_msgSender(), amount);
    }
}