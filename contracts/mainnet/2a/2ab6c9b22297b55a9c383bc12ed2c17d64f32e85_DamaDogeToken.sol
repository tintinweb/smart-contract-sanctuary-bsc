/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

//DamaDoge

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
	mapping (address => bool ) public isBot;
	
    uint public totalBurn;
    uint public deployTime;
    
    uint public _totalSupplyA;
	uint public _totalSupplyB;
    uint public _totalSupplyC;
    
    address public T = 0xcA805Ca7688238f75125F3b19c0350FA2f30B213;  // team address
    address public M = 0x15f68108cFd95f5aBd2aeC4dAfFB00232531C485;  // market address

    address public deadAddress = 0x000000000000000000000000000000000000dEaD;
	
	function setBot(address account) public onlyOwner{
		isBot[account] = true;
	}
	
	function removeBot(address account) public onlyOwner{
		isBot[account] = false;
	}
	
    function totalSupply() public view override returns (uint) {
        return _totalSupplyC;
    }

    function tokenX(uint amount) internal view returns(uint){
        return amount.mul(_totalSupplyB).div(_totalSupplyA);
    }

    function tokenD(uint amount) internal view returns(uint){
        return amount.mul(_totalSupplyA).div(_totalSupplyB);
    }

    function get_balances(address account) public view returns (uint){
        return _balances[account].mul(_totalSupplyB).div(_totalSupplyA);
    }
    function balanceOf(address account) public view override returns (uint) {
       
        return get_balances(account);
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
	//	require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(towner != address(0), "BEP20: towner is zero address");
		require(spender != address(0), "BEP20: spender is zero address");
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


    function _transfer(address sender, address recipient, uint _amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer from the zero address");
		require(!isBot[sender],"is bot");
		
		uint amount = tokenD(_amount);
		
        uint256 tax = amount.mul(10).div(100);

        if (
             sender == T || sender == M || recipient == deadAddress
        ) {
            tax = 0;
        }
        uint256 netAmount = amount - tax;
   
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

        if (tax > 0) {
            uint256 taxA = tax.mul(2).div(10);
            uint256 taxM = tax.mul(4).div(10);
			uint256 taxH = tax.sub(taxA).sub(taxM);
			
            _balances[M] = _balances[M].add(taxM);

            totalBurn = totalBurn.add(tokenX(taxA));
            _totalSupplyA = _totalSupplyA.sub(taxA);
            _totalSupplyB = _totalSupplyB.sub(tokenX(taxA));
			
            emit Transfer(sender, deadAddress, tokenX(taxA));
            emit Transfer(sender, M, tokenX(taxM));
			
			_totalSupplyA = _totalSupplyA.sub(taxH);
        }
        _balances[recipient] = _balances[recipient].add(netAmount);
        
        if (recipient == deadAddress) {

            totalBurn = totalBurn.add(_amount);
            _totalSupplyA = _totalSupplyA.sub(amount);
            _totalSupplyB = _totalSupplyB.sub(_amount);

            emit Burn(sender, address(0), _amount);
        }
        _balances[deadAddress] = tokenD(totalBurn);
        emit Transfer(sender, recipient, tokenX(netAmount));
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

contract DamaDogeToken is BEP20Detailed {

    constructor() BEP20Detailed("DamaDoge coin", "DamaDoge", 18) public {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
        deployTime = block.timestamp;
        _totalSupplyA = 100000000 * (10**18);
		_totalSupplyB = 100000000 * (10**18);
        _totalSupplyC = 100000000 * (10**18);

	    _balances[_msgSender()] = _totalSupplyA;
	    emit Transfer(address(0), _msgSender(), _totalSupplyA);

    }
  
    function takeOutTokenInCase(address _token, uint256 _amount, address _to) public onlyOwner {
		require(_msgSender() != address(0), "BEP20: transfer from the zero address");
		require(_token != address(0), "BEP20: _token from the zero address");
        IBEP20(_token).transfer(_to, _amount);
    }
}