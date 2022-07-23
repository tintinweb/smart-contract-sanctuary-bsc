/**
 *Submitted for verification at BscScan.com on 2022-07-23
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

//// This contract is an BEP20 token that has a fee module attached to it
//// The admin can change the fee or set it to zero and assign the "immume" role to addresses that makes them immune to the fee.
//// The admin is the person that deploys the contract, it cannot be changed once deployed.

//// Unlike traditional fee contracts, this contract broadcasts the fee and the sent amount in the transaction data.
//// The broadcast is supported by ethereum explorers like etherscan and makes accounting much easier.

//// Commissioned by XV#1000 on 7/9/2022

contract TokenWithFee {

//// Before you deploy the contract, make sure to change these parameters to what you want

    constructor () {

        balances[msg.sender] = 1000000000  *10e18;
        totalSupply = 1000000000   *10e18;
        name = "Shadow Dio Coin";
        decimals = 18;
        symbol = "SDC";
        FeePercent = 7;
        MarketingPercent = 12;

        MaxWalletPercent = 5; // The maximum amount of the % total supply a wallet can have, does not effect the admin

        FeeAddress = 0x5B3d5F621A4d2b77a499847a5F3c2877f35DA249; // Put an address that you want the fees to go to here before you deploy.
        MarketingAddress = 0x5B3d5F621A4d2b77a499847a5F3c2877f35DA249; // Put an address that you want the marketing fees to go to here before you deploy.


        admin = msg.sender;
        ImmuneFromFee[address(this)] = true;
        ImmuneFromFee[msg.sender] = true;
    }

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    ERC20 LPtoken;

    string public name;
    uint8 public decimals;
    string public symbol;
    uint public totalSupply;
    uint public FeePercent;
    uint public MarketingPercent;
    uint public MaxWalletPercent;
    mapping(address => bool) public ImmuneFromFee;
    address public admin;
    address public FeeAddress;
    address public MarketingAddress;
    uint public Timer;
    uint public HowLong;
    bool NoRe;

    function LockLP(ERC20 LPtokenAddress, uint LockForHowLongInSeconds) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");
        require(NoRe = false, "You can't start a lock if you have already locked");

        LPtokenAddress.transferFrom(msg.sender, address(this), balanceOf(msg.sender));
        HowLong = LockForHowLongInSeconds;
        Timer = block.timestamp;
        LPtoken = LPtokenAddress;
        NoRe = true;
    }

    function UnlockLP() public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");
        require(block.timestamp - Timer > HowLong, "You cannot unlock as your timer isn't up yet");
        require(NoRe = true, "You cannot unlock your LP if you have no lock in the first place...");

        LPtoken.transferFrom(address(this), msg.sender, balanceOf(address(this)));

        NoRe = false;
    }

    function EditFee(uint Fee) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");
        require(Fee <= 100, "You cannot make the fee higher than 100%");
        FeePercent = Fee;
    }

    function EditFeeAddress(address Who) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button!");
        FeeAddress = Who;
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
        balances[FeeAddress] += fee;
        emit Transfer(_payee, FeeAddress, fee);

        _value = ProcessMarketing(_value, _payee);
        return _value;
    }

    function ProcessMarketing(uint _value, address _payee) internal returns (uint){

        uint fee = MarketingPercent*(_value/100);
        _value -= fee;

        balances[_payee] -= fee;
        balances[MarketingAddress] += fee;
        emit Transfer(_payee, MarketingAddress, fee);

        return _value;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value, "You can't send more tokens than you have");

        if(ImmuneFromFee[msg.sender] = false){_value = ProcessFee(_value, msg.sender);}

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        require(msg.sender == admin || balances[_to] <= (MaxWalletPercent*totalSupply)/100, "This transaction would result in you breaking the max wallet limit");

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value, "You can't send more tokens than you have or the approval isn't enough");

        if(ImmuneFromFee[_from] = false){_value = ProcessFee(_value, _from);}

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        require(msg.sender == admin || balances[_to] <= (MaxWalletPercent*totalSupply)/100, "This transaction would result in you breaking the max wallet limit");

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

interface ERC20{
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns(uint);
    function decimals() external view returns (uint8);
}