/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 < 0.9.0;
 
//Safe Math Interface
 
contract SafeMath {
 
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
     
 
//ERC Token Standard #20 Interface 1000000000000000000000000
 
interface IERC20 {
    //function totalSupply() external returns (uint);

    function balanceOf(address account) external returns (uint);

    function transfer(address recipient, uint256 amount) external ;

    function allowance(address owner, address spender) external returns (uint);

    function approve(address owner, address spender, uint256 amount) external returns (bool);
    
    function burn(uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

 
//Actual token contract
 
contract CannabisBit is IERC20, SafeMath {
    string public symbol = "CBC";
    string public name = "CannabisBit";
    uint8 public decimals = 18;
    uint public _initialSupply = 1000000*10**18;
    uint public _totalSupply = 0;
    address public _owner = msg.sender; 
    uint256 public founderCoreteamAdvisor = 0;
    uint256 public reserved = 0;
    uint256 public price = 0.07 ether;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint256)) private _allowances;


    modifier onlyOwner(){
        require(_owner == msg.sender, "Sorry you are not the owner");
        _;
        }
    constructor(){
        mint(_initialSupply);
    }

    function mint(uint256 amount) public onlyOwner{
        require(amount != 0, "supply should be greater than 0");
        founderCoreteamAdvisor += (amount * 10)/100;
        reserved += (amount * 10)/100;
        uint256 supply = amount -((amount * 20)/100);    
        _beforeTokenTransfer(address(0), _owner, amount);
        _totalSupply += supply;
        unchecked {
            balances[_owner] += supply;
        }
            
        
        emit Transfer(address(0), _owner, amount);

         _afterTokenTransfer(address(0), _owner, amount);
    }
 
    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }
 
    function transfer(address to, uint tokens) public override onlyOwner {
        require(to != address(0), "cannot transfer to zero address");
        require(tokens <= balances[_owner], "tokens should be less than owner's balance");
        balances[_owner] = safeSub(balances[_owner], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
    }

    function reserevedTransfer(address _to, uint256 amount) public onlyOwner{
        require(amount <= reserved, "amount of token exceeded from the reserved tokens");
        require(_to != address(0), "cannot transfer to zero address");
        balances[_to] += amount;
        reserved -= amount;
        emit Transfer(_owner, _to, amount);
    }

    function founderCoreteamAdvisorTransfer(address _to, uint256 amount) public onlyOwner{
        require(amount <= founderCoreteamAdvisor, "amount of token exceeded from the founderCoreteamAdvisor tokens");
        require(_to != address(0), "cannot transfer to zero address");
        balances[_to] += amount;
        founderCoreteamAdvisor -= amount;
        emit Transfer(_owner, _to, amount);
    }

    function approve(address owner, address spender, uint tokens) public override returns (bool success) {
        require(spender != address(0), "ERC20: approve to the zero address");
        require(owner !=address(0),"owner cannot be zero address");
        _allowances[owner][spender] = tokens;
        emit Approval(owner, spender, tokens);
        return true;
    }
 
    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        address spender = msg.sender;
         _spendAllowance(spender, tokens);
        balances[from] = safeSub(balances[from], tokens);
        _allowances[from][msg.sender] = safeSub(_allowances[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    
    function _spendAllowance(address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(_owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                approve(_owner, spender, currentAllowance - amount);
            }
        }
    }

    function burn(uint256 amount) public override onlyOwner {
        require(_owner != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(_owner, address(0), amount);

        uint256 accountBalance = balances[_owner];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balances[_owner] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(_owner, address(0), amount);

        _afterTokenTransfer(_owner, address(0), amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            balances[newOwner] += _totalSupply;
            _owner = newOwner;
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        transferOwnership(address(0));
    }

    function withdrawBal() public returns (bool success){
        require(_owner == msg.sender,"Sorry! You are not allowed to withdraw balance");
        payable(_owner).transfer(address(this).balance);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
 
}