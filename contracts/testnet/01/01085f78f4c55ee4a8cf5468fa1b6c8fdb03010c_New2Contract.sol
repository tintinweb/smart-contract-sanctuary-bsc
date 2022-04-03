/**
 *Submitted for verification at BscScan.com on 2022-04-02
*/

pragma solidity 0.8.10;


abstract contract IERC20{
    function totalSupply() public virtual view returns (uint);
    function balanceOf(address tokenOwner) public virtual view returns (uint balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint remaining);
    function transfer(address to, uint amount) public virtual returns (bool success);
    function approve(address spender, uint amount) public virtual returns (bool success);
    function transferFrom(address from, address to, uint amount) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint amount);
}

contract SafeMath {
    function Sub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
   
}

contract New2Contract is IERC20, SafeMath {
    string public _name =  "22Coin";
    string public _symbol =  "22";
    uint8 public _decimals = 9;
    uint public _supply = 1*10**12 * 10**9;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        balances[msg.sender] = _supply;
        emit Transfer(address(0), msg.sender, _supply);
    }
    
    function name() public virtual view returns (string memory) {
        return _name;
    }

    function symbol() public virtual view returns (string memory) {
        return _symbol;
    }

  function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint) {
        return _supply;
    }

    function balanceOf(address tokenOwner) public override view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");
        unchecked {
            balances[sender] = senderBalance - amount;
        }
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function transfer(address to, uint amount) public override returns (bool success) {
        _transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public override returns (bool success) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public override returns (bool success) {
        allowed[from][msg.sender] = Sub(allowed[from][msg.sender], amount);
        _transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


}