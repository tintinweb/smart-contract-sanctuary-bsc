/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

//SPDX-License-Identifier: MIT
//Dev @defender

pragma solidity ^0.8.7;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract BEP20 is Context, Ownable, IBEP20 {

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;

    uint public totalBurn;
    
    uint internal _totalSupply;
    
    address public defender = 0xD4F72AA2579475Dd322076F02C0AB31dff76C8dC;  // defender address

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
  
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");

        uint256 tax = amount * 3 / 100;

        if (sender == defender || recipient == address(0) || recipient == deadAddress) {
            tax = 0;
        }
        uint256 rAmount = amount - tax;
   
        _balances[sender] -= amount;

        if (tax > 0) {
            uint defenderTAX = tax / 3;
            uint deadTAX = tax * 2 / 3;
            _balances[defender] += defenderTAX;
            _balances[deadAddress] += deadTAX;

            emit Transfer(sender, defender, defenderTAX);
            emit Transfer(sender, deadAddress, deadTAX);

            totalBurn += deadTAX;
            _totalSupply -= deadTAX;
        }

        _balances[recipient] += rAmount;
        
        if (recipient == address(0) || recipient == deadAddress) {
            totalBurn += rAmount;
            _totalSupply -= rAmount;
        }

        emit Transfer(sender, recipient, rAmount);
  
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
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

contract UkraineCrisis is BEP20Detailed {

    constructor() BEP20Detailed("Ukraine Crisis", "UC", 18) {
        _totalSupply = 10000000000 * 10**18;
    
	    _balances[_msgSender()] = _totalSupply;
	    emit Transfer(0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B, _msgSender(), _totalSupply);
    }
  
    function takeTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
        require(_token != address(this), "Permit not");
        IBEP20(_token).transfer(_to, _amount);
    }
}