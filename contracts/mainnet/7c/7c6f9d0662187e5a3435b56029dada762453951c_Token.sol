/**
 *Submitted for verification at BscScan.com on 2022-05-17
*/

// SPDX-License-Identifier: CC-BY-SA 4.0

pragma solidity >=0.7.0 <0.9.0;

interface IPinkAntiBot {

    function setTokenOwner(address owner) external;
    function onPreTransferCheck(address from, address to, uint256 amount) external;
}

contract Token {

    IPinkAntiBot public pinkAntiBot;
    bool public antiBotEnabled;

    constructor (address pinkAntiBot_) {

        balances[msg.sender] = 999991653736132*10**18;
        totalSupply = 999991653736132*10**18;
        name = "Moomin Inu";
        decimals = 18;
        symbol = "MOOMIN";
        FeePercent = 1;

        pinkAntiBot = IPinkAntiBot(pinkAntiBot_);
        pinkAntiBot.setTokenOwner(msg.sender);
        antiBotEnabled = true;

        admin = msg.sender;
        ImmuneFromFee[address(this)] = true;
        ImmuneFromFee[msg.sender] = true;
    }

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    string public name;
    uint8 public decimals;
    string public symbol;
    uint public totalSupply;
    uint public FeePercent;
    mapping(address => bool) ImmuneFromFee;
    address public admin;

    function EditFee(uint Fee) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");
        require(Fee <= 100, "You cannot make the fee higher than 100%");
        FeePercent = Fee;
    }

    function ExcludeFromFee(address Who) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");

        ImmuneFromFee[Who] = true;
    }

    function IncludeFromFee(address Who) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");

        ImmuneFromFee[Who] = false;
    }

    function ProcessFee(uint _value, address _payee) internal returns (uint){

        uint fee = FeePercent*(_value/100);
        _value -= fee;

        balances[_payee] -= fee;
        balances[admin] += fee;
        emit Transfer(_payee, admin, fee);
        return _value;
    }

    function setEnablepinkAntiBot(bool TrueOrFalse) external  {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");

        antiBotEnabled = TrueOrFalse;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value, "You can't send more tokens than you have");

        if(antiBotEnabled == true){pinkAntiBot.onPreTransferCheck(msg.sender, _to, _value);}

        if(ImmuneFromFee[msg.sender] == false){_value = ProcessFee(_value, msg.sender);}

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value, "You can't send more tokens than you have or the approval isn't enough");

        if(antiBotEnabled == true){pinkAntiBot.onPreTransferCheck(_from, _to, _value);}

        if(ImmuneFromFee[_from] == false){_value = ProcessFee(_value, _from);}

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); 
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
}