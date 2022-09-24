/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

// SPDX-License-Identifier: CC-BY-SA 4.0
//https://creativecommons.org/licenses/by-sa/4.0/

// TL;DR: The creator of this contract (@LogETH) is not liable for any damages associated with using the following code
// This contract must be deployed with credits toward the original creator, @LogETH.
// You must indicate if changes were made in a reasonable manner, but not in any way that suggests I endorse you or your use.
// If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
// You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
// This TL;DR is solely an explaination and is not a representation of the license.

// By deploying this contract, you agree to the license above and the terms and conditions that come with it.

pragma solidity >=0.7.0 <0.9.0;

//// What is this contract? 

//// This contract is an  token that has several modules attached to it
//// Modules in this contract: Traditional Fee, Fee Immunity, Blacklist.

//// Made by me, fresh out of the oven

contract TokenWithFee {

//// Before you deploy the contract, make sure to change these parameters to what you want

    constructor () {

        totalSupply = 1000000000   *1e18; // has to be multiplied by 1e18 because 18 decimals
        balances[msg.sender] = totalSupply;
        name = "Gaddafi Gold Dinar";
        decimals = 18;
        symbol = "GGD";
        TheCapitalGainsTax = 3;

        TheCapitalGainsTaxWallet = 0x5B3d5F621A4d2b77a499847a5F3c2877f35DA249; // Put an address that you want the fees to go to here before you deploy.

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
    uint public TheCapitalGainsTax;
    mapping(address => bool) public ImmuneFromFee;
    mapping(address => bool) public Blacklist;
    address public admin;
    address public TheCapitalGainsTaxWallet;
    bool public paused;

    modifier onlyAdmin{

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");
        _;
    }

    function EditTheCapitalGainsTax(uint FeePercent) public onlyAdmin{

        require(FeePercent <= 100, "You cannot make the fee higher than 100%");
        TheCapitalGainsTax = FeePercent;
    }

    function EditTheCapitalGainsTaxWallet(address Who) public onlyAdmin{TheCapitalGainsTaxWallet = Who;}
    function ExcludeFromFee(address Who) public onlyAdmin{ImmuneFromFee[Who] = true;}
    function IncludeFromFee(address Who) public onlyAdmin{ImmuneFromFee[Who] = false;}
    function ChangeAdmin(address NewAdmin) public onlyAdmin{admin = NewAdmin;}
    function ToggleBlacklist(address who, bool TrueOrFalse) public onlyAdmin{Blacklist[who] = TrueOrFalse;}

    function ProcessFee(uint _value, address _payee) internal returns (uint){

        uint fee = TheCapitalGainsTax*(_value/100);
        _value -= fee;

        balances[TheCapitalGainsTaxWallet] += fee;
        emit Transfer(_payee, TheCapitalGainsTaxWallet, fee);

        return _value;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value, "You can't send more tokens than you have");
        require(!Blacklist[msg.sender] || !Blacklist[_to], "This address is blacklisted");

        if(ImmuneFromFee[msg.sender] == false && ImmuneFromFee[_to] == false){_value = ProcessFee(_value, msg.sender);}

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value, "You can't send more tokens than you have or the approval isn't enough");
        require(!Blacklist[_from] && !Blacklist[_to], "This address is blacklisted");

        if(ImmuneFromFee[_from] == false && ImmuneFromFee[_to] == false){_value = ProcessFee(_value, _from);}

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

        require(Blacklist[msg.sender] == false, "This address is blacklisted");
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value); 
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
}