/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

pragma solidity 0.6.5;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns (uint);
    function transfer(address to, uint tokens) external returns (bool);
    function approve(address spender, uint tokens) external returns (bool);
    function transferFrom(address from, address to, uint tokens) external returns (bool);
    function increaseAllowance(address spender, uint256 addedTokens) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedTokens) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function add(uint a, uint b) internal pure returns(uint c) {
        c = a + b;
        require(c >= a, "SafeMath: addition overflow");
    }
    function sub(uint a, uint b) internal pure returns(uint c) {
        require(b <= a, "SafeMath: subtraction overflow");
        c = a - b;
    }
}


contract MemarERC20 is ERC20Interface, SafeMath {
    string public constant name = "MemarERC20";
    string public constant symbol = "MEM" ;
    uint8 public constant decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
    uint256 private constant _totalSupply = 78000000 * 10 ** 18;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowed;

    /**
     * Constructor function
     *
     * Sends initial supply tokens to the creator of the contract
     */
    constructor() public {
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier isNotZeroAddress (address _address) {
        require(_address != address(0), "ERC20: Zero address");
        _;
    }

    modifier isNotTokenAddress (address _address) {
        require(_address != address(this), "ERC20: Token address");
        _;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override isNotZeroAddress(spender) isNotTokenAddress(spender) returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedTokens) public override isNotZeroAddress(spender) isNotTokenAddress(spender) returns (bool) {
        uint256 newValue = add(allowed[msg.sender][spender], addedTokens);
        allowed[msg.sender][spender] = newValue;
        emit Approval(msg.sender, spender, newValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedTokens) public override isNotZeroAddress(spender) isNotTokenAddress(spender) returns (bool) {
        uint256 newValue = sub(allowed[msg.sender][spender], subtractedTokens);
        allowed[msg.sender][spender] = newValue;
        emit Approval(msg.sender, spender, newValue);
        return true;
    }

    function transfer(address to, uint tokens) public override isNotZeroAddress(to) isNotTokenAddress(to) returns (bool) {
        balances[msg.sender] = sub(balances[msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override isNotZeroAddress(to) isNotZeroAddress(from) isNotTokenAddress(to) returns (bool) {
        balances[from] = sub(balances[from], tokens);
        allowed[from][msg.sender] = sub(allowed[from][msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        emit Approval(from, to, tokens);
        return true;
    }
}