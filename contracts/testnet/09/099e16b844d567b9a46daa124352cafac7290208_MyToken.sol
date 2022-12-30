/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient,uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MyToken is IERC20{

    address public admin;
    string public name;
    string public symbol;
    uint public decimal;
    uint _totalSupply;

    // event Approval(address indexed owner, address indexed spender, uint tokens);

    mapping(address => uint)  balances;
    mapping(address => mapping(address => uint)) allowed;

    modifier onlyOwner{
        require(msg.sender == admin);
        _;
    }
    

    constructor() public {
        name = "Fareed Token";
        symbol = "FT";
        decimal = 18;
        _totalSupply = 100000 * 10 ** decimal;
	    balances[msg.sender] = _totalSupply;
	    emit Transfer(address(0), msg.sender, _totalSupply);
    }

    address public  tokenAdd = address(this);

    function decimals() public  view returns (uint){
        return decimal;
    }

    function totalSupply() public view override returns(uint){
        return _totalSupply - balances[address(0)];
    }

    function  balanceOf(address tokenOwner) public view  returns(uint){
        return balances[tokenOwner];
    }

    function transfer(address _to, uint  _tokens)public returns(bool){
        require(_tokens <= balances[msg.sender]);
        balances[msg.sender] -= _tokens;
        balances[_to] += _tokens;
        emit Transfer(msg.sender,_to, _tokens);
        return true;
    }

    function mint(uint _qty) public onlyOwner returns(uint){
        _totalSupply += _qty;
        balances[msg.sender] += _qty;

        return _totalSupply;
    }

    function burn(uint _qty) public  onlyOwner returns(uint){
        _totalSupply -= _qty;
        balances[msg.sender] -= _qty;

        return _totalSupply;
    }

    function allowance(address _owner, address _spender) public view returns(uint remaining){
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint _value) public returns(bool seccess){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _owner, address _to, uint _tokens) public  returns(bool seccess){
        //uint allowance1 = allowed[_from][msg.sender];
	    require(_tokens <= balances[_owner] , "Not enough Tokens");
	    require(_tokens <= allowed[_owner][msg.sender] , "Your allowence limit is exhusted");
       // require(balances[_owner] >= _value && allowance1 >= _value, " you have not enough tokens.");
        balances[_to] += _tokens;
        balances[_owner] -= _tokens;
        allowed[_owner][msg.sender] -=_tokens;
        emit Transfer(_owner, _to, _tokens);
        return true;
    }

}