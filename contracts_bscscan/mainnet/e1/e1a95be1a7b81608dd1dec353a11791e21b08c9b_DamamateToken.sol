/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

//babytiger 

pragma solidity ^0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed owner, address indexed to, uint value);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract BEP20 is Context, Ownable, IBEP20 {
    using SafeMath for uint;

    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;

    bool public isLocked = true;
  
    uint public totalBurn;
    uint public deployTime;
    
    uint internal _totalSupply;
    
    address public T = 0xddd69e2a6B048D0E6de8f0f692c46A7d91FBc47f;  // team address
    address public A = 0x35ef274901b343d6781E70Af9B13f4FDc2a36e98;  // transition address
    address public M = 0x7292F2F244956b0fc9468C55c024c697c1DC75ab;  // market address

    address public busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

 
    
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(sender != address(0), "BEP20: sender is zero address");
		
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(spender != address(0), "BEP20: spender is zero address");
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function checklock() internal {

        if(
            isLocked &&
            (
                IBEP20(busd).balanceOf(address(this)) >= 1000000 * (10**18) ||
                totalBurn >= 100000000 * (10**18) ||
                totalSupply() <= 1000000 * (10**18) ||
                block.timestamp.sub(deployTime) >= 62208000   // 86400 * 30 * 12 * 2  Automatically unlock after 2 years
            )
        )
        {
            isLocked = false;
        }
        
    }

    function swap(uint amount) public {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        require(!isLocked, "Token Smart contract is locked");
		
        this.transferFrom(_msgSender(), address(this), amount);
        IBEP20(busd).transfer(_msgSender(), amount);
        
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");


        uint256 tax = amount.mul(10).div(100);

        if (
             sender == T || sender == A || sender == M ||
            recipient == address(0) || recipient == deadAddress || recipient == address(this)
        ) {
            tax = 0;
        }
        uint256 netAmount = amount - tax;
   
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

        if (tax > 0) {
           
            uint256 taxA = tax.mul(7).div(10);
            //uint256 taxM = tax.mul(3).div(15);
            uint256 taxM = tax.sub(taxA);
            _balances[A] = _balances[A].add(taxA);
            _balances[M] = _balances[M].add(taxM);

            emit Transfer(sender, A, taxA);
            emit Transfer(sender, M, taxM);
    
        }

        _balances[recipient] = _balances[recipient].add(netAmount);
        
        if (recipient == address(0) || recipient == deadAddress || recipient == address(this)) {
            totalBurn = totalBurn.add(netAmount);
            _totalSupply = _totalSupply.sub(netAmount);

            emit Burn(sender, address(0), netAmount);
        }
        
        checklock();

        emit Transfer(sender, recipient, netAmount);
  
    }
 
    function _approve(address towner, address spender, uint amount) internal {
        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    function airdrop(address[] memory recipient, uint[] memory amount) public   returns (bool) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        require(recipient.length == amount.length,"errer:length error");
        require(recipient.length <= 40,"errer:length too macth");
        uint allamout;
        for(uint i; i < amount.length ; i++){
            allamout.add(amount[i]);
        }
        require(_balances[_msgSender()] >= allamout,"not enough");
        for(uint i; i < amount.length ; i++){
           _transfer(_msgSender(), recipient[i], amount[i]);
        }
        return true;
    }

}

contract BEP20Detailed is BEP20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) internal {
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

contract DamamateToken is BEP20Detailed {

    constructor() BEP20Detailed("Damamate coin", "Damamate", 18) public {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        deployTime = block.timestamp;
        _totalSupply = 101000000 * (10**18);
    
	    _balances[_msgSender()] = _totalSupply;
	    emit Transfer(address(0), _msgSender(), _totalSupply);
	
    }
  
    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(_token != address(0), "BEP20: _token from the zero address");
        require(!isLocked, "Token contract is locked");
        IBEP20(_token).transfer(_to, _amount);
    }
}