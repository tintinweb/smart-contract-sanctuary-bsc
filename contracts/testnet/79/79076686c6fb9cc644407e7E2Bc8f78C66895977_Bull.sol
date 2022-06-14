// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ERC20 {
    function totalSupply() external returns (uint _totalSupply);
    function balanceOf(address _owner) external returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint tokens);
    event Approval(address indexed _owner, address indexed _spender, uint tokens);
}

contract Bull is ERC20{

    address payable admin;

    string public constant name = "BULL";
    string public constant symbol = "BULL";
    uint8 public constant decimals = 18;
    string public standard = "BULL Token version 1.0";

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;


    uint256 totalSupply_;

    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
        // The msg.sender contains the Ethereum account of the currently
        // executing contract function.
        approve(msg.sender, total);
    }
    // function() external payable {}


    function totalSupply() public view returns (uint256) {
      return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    // transfer to user
    function transfer(address receiver, uint _value) public returns (bool) {
        // require(msg.sender == admin, 'Permision denied!');
        require(_value <= balances[msg.sender], 'Balance is not enough!');
        
        balances[msg.sender] -= _value;
        balances[receiver] += _value;
        emit Transfer(msg.sender, receiver, _value);
        return true;
    }

    // user transfer to contract
    function transferToContract(address _to, uint256 _value) public returns (bool success){
        require(balances[tx.origin] >= _value, "Your Balance is not enough");
        balances[tx.origin] -= _value;
        balances[_to] += _value;

        emit Transfer(tx.origin, _to, _value);

        return true;
    }

    // approve for spender
    function approve(address spender, uint _value) public returns (bool) {
        allowed[msg.sender][spender] = _value;
        emit Approval(msg.sender, spender, _value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return allowed[owner][spender];
    }

    // transfer from user to user
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(_value <= balances[_from], 'Seller balance must be equal or greater than buyer balance!');
        require(_value <= allowed[_from][msg.sender], 'You can not transfer amount larger than allowance!');
        // require(_value <= token.allowance(msg.sender, address(this)), 'You can not transfer amount larger than allowance!');

        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}