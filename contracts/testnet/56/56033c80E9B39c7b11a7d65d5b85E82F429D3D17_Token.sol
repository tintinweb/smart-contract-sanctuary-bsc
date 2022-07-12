/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

pragma solidity =0.6.6;


// Math operations with safety checks that throw on error
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Math error");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "Math error");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Math error");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
}


// Abstract contract for the full ERC 20 Token standard
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Token
contract Token is IERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) public {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        _totalSupply = totalSupply_ * 10**(uint256(decimals));
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        require(_from != address(0), "StandardToken: from error");
        require(_to != address(0), "StandardToken: to error");
        _balances[_from] = SafeMath.sub(_balances[_from], _value);

        uint256 _fee = _value.mul(20).div(100);
        _value = _value.sub(_fee);
        _balances[_to] = SafeMath.add(_balances[_to], _value);
        _balances[address(0)] = SafeMath.add(_balances[address(0)], _fee);
        emit Transfer(_from, _to, _value);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
    }

    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_balances[msg.sender] >= _value, "StandardToken: balances error");

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _amount) public override returns (bool) {
        _allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        require(_allowed[_from][msg.sender] >= _value, "StandardToken: allowed error");

        _allowed[_from][msg.sender] = SafeMath.sub(_allowed[_from][msg.sender], _value);
        _transfer(_from, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return _allowed[_owner][_spender];
    }

}