/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

pragma solidity ^0.8.0;
contract mytoken{
    string public name="Ethereum";
    uint8 public decimals=18;
    string public symbol="ETH";
    uint256 constant public totalsupply=1 ether;


    address owner;
    event Transfer(address indexed _from,address indexed _to,uint _amount);
    event approve(address indexed _owner,address indexed _spender,uint _value);

    mapping (address=>uint) balanceof;
    mapping (address => mapping (address => uint256)) allowance;
    mapping (address=>uint) lockedtokens;
    mapping (address=>uint) timestamps_;
    //timestamps_[] creationtime;

    modifier entertokens(uint _eth){
        require(balanceof[msg.sender]>=10000 && 10000>=_eth,"you cannot lock more than 10000 tokens");
        _;
    }
    modifier onlyafter(uint _time){
        require(block.timestamp>_time,"unlock after 1 hours");
        _;
    }

    constructor() public{
        balanceof[msg.sender]=totalsupply;
        owner=msg.sender;


    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceof[msg.sender]>=_value,"error");
        balanceof[msg.sender] -= _value;
        balanceof[_to] += _value;
        return true;
        emit Transfer(msg.sender, _to, _value);

    }
    function transferfrom(address _from,address _to,uint _value) public returns(bool success){
        require(balanceof[msg.sender]>=_value,"error");
        require(allowance[_from][msg.sender]>=_value," error1");

        balanceof[_to] += _value;
        balanceof[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        return true;

        emit Transfer(_from, _to, _value);
    }
    function getbalance(address _address) public view returns(uint){
        return balanceof[_address];
    }
    function lockcoin(uint _eth) entertokens(_eth) public{
        timestamps_[msg.sender]=block.timestamp;
       transferfrom(msg.sender,address(this),_eth);

    }

    function unlocktoken(uint _eth) public onlyafter(timestamps_[msg.sender] +30 seconds){
        require(lockedtokens[msg.sender]>=_eth);
        
        
    }




}