/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

//import "hardhat/console.sol";

contract TCHO1 {

    address private _owner;

    bool private _isEnabled = true;

    string public name = "TCHO1 COIN";
    string private _symbol = 'TCHO1';
    uint8 private _decimals = 18;
    string private _decimalsString = "18";

    uint private _addrCount = 0;
    mapping(uint => address) private _balanceOfByCount;
    mapping(address => uint) private _balanceOf;
    mapping(address => int8) private _addrExists;

    event Approval(address indexed src, address indexed other, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad);

    constructor(){
        _owner = msg.sender;
        _addrCount = 1;
        _addrExists[_owner] = 1;
        _balanceOfByCount[_addrCount - 1] = _owner;
        _balanceOf[_owner] = convertToWei(100, 0);
    }

    function requireIsEnabled() private view{
        require(_isEnabled == true, "The Contract is currently DISABLED");
    }
    function requireOwner() private view{
        require(msg.sender == _owner, "Only the Owner can execute this logic");
    }

    modifier ifOwner{
        requireOwner();
        _;
    }

    modifier ifEnabled{
        requireIsEnabled();
        _;
    }

    modifier ifEnabledAndOwner{
        requireIsEnabled();
        requireOwner();
        _;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function getOwner() public view returns (address){
        return _owner;
    }

    function setOwner(address newOwner) public ifOwner view{
        newOwner = address(0);
        //owner = newOwner;        
        // revert("Owner Address cannot be modified.");
    }

    function totalSupply() external view returns (uint256){
        uint256 t = 0;
        for(uint i = 0; i < _addrCount; i++){
            t += _balanceOf[_balanceOfByCount[i]];
        }
        return t;
    }

    function totalRegisteredAddresses() external view returns (uint){
        return _addrCount;
    }

    function balanceOf(address account) external view returns (uint256){
        return _balanceOf[account];
    }

    function transfer(address to, uint256 amount) external returns (bool){
        return _innerTransfer(to, amount);
    }

    function _innerTransfer(address to, uint256 amount) private ifEnabled returns (bool){
        address sender = msg.sender;
        lg("TRANSFER is owner of contract?", sender == _owner);
        require(_addrExists[sender] == 1, "SENDER NEVER REGISTERED");
        require(_balanceOf[sender] >= amount, "NOT ENOUGH FUNDS TO TRANSFER");
        require(amount > 0, "Amount must be greater than 0");
        require(sender != to, "SENDER AND DESTINATION ADDRESSES ARE THE SAME");
        _balanceOf[sender] -= amount;
        _balanceOf[to] += amount;
        addAddressIfNotExists(to);
        return true;
    }

    function addAddressIfNotExists(address addr_) private {
        if(_addrExists[addr_] == 0){
            _addrExists[addr_] = 1;
            _addrCount++;
            _balanceOfByCount[_addrCount - 1] = addr_;
            lg("NEW ADDRESS ADDED");
        }
    }

    // function setIsEnabled() public ifOwner{
    //     setIsEnabled(_isEnabled);
    // }
    function setIsEnabled(uint8 enabled_) public ifOwner{
        _isEnabled = enabled_ > 0;
        //require(msg.sender == owner, "Only the Owner can modified this switch.");
        // _isEnabled = enabled_;
        lg("setIsEnabled _isEnabled", _isEnabled);
    }

    function setTransfAmount(uint coinsToSend_) public ifEnabled view{
        setTransfAmount(coinsToSend_, 0);
    }
    function setTransfAmount(uint coinsToSend_, uint8 decimalPlaces_) public ifEnabled view{
        require(coinsToSend_ > 0, "Coins to Send must be greater than 0");
        require(decimalPlaces_ >= 0 && decimalPlaces_ <= _decimals, string.concat("Decimal Places must be between 0 and ", _decimalsString));
        lg("A");
        lg("B", convertToWei(coinsToSend_, decimalPlaces_));
    }

    function convertToWei(uint val_, uint8 decimalPlaces_) private view returns (uint){
        uint8 exp = _decimals - decimalPlaces_;
        val_ = val_ * 10**exp;
        return val_;
    }

    function isContractEnabled() public view returns (bool){
        return _isEnabled;
    }

    //*/
    function lg(string memory txt_) private pure{}
    function lg(string memory txt_, bool val_) private pure{}
    function lg(string memory txt_, int val_) private pure{}
    function lg(string memory txt_, uint val_) private pure{}
    //*/
    /*/
    function lg(string memory txt_) private view{
        console.log("----- -----");
        console.log(txt_);
        console.log("----- -----");
    }
    function lg(string memory txt_, bool val_) private view{
        console.log("----- -----");
        if(bytes(txt_).length > 0) console.log(txt_);
        console.log(val_);
        console.log("----- -----");
    }
    function lg(string memory txt_, int val_) private view{
        console.log("----- -----");
        if(bytes(txt_).length > 0) console.log(txt_);
        if(val_ < 0){
            console.log("-", abs(val_));
        }else{
            console.log(uint(val_));
        }
        console.log("----- -----");
    }
    function lg(string memory txt_, uint val_) private view{
        console.log("----- -----");
        if(bytes(txt_).length > 0) console.log(txt_);
        console.log(val_);
        console.log("----- -----");
    }
    //*/

    function abs(int x) private pure returns (uint){
        return x >= 0 ? uint(x) : uint(-x);
    }

}