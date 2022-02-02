/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.0;

contract ascendDAOholders{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address _owner;
    address[] public members;

    string _name;
    string _symbol;

    uint _totalsupply;

    constructor() {
        _owner = msg.sender;
        _name = "AscendDAOholder";
        _symbol = "aDAO";
        _totalsupply = 0;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalsupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    modifier owner {
        require(msg.sender == _owner); _;
    }

    function takeArray(address[] calldata addys) public owner{
        clearArray();
        members = addys;
        giveBalance();
        _totalsupply = members.length;
    }

    function clearArray() public owner{
        uint len = members.length;
        if(len > 1){
            for(uint i=0; i <= len; i++){
                _balances[members[i]] = 0;
                members[i] = _owner;
            }
        }
    }

    function giveBalance() public owner{
        uint len = members.length;
        if(len > 1){
            for(uint i=0; i <= len; i++){
                _balances[members[i]] = 1;
            }
        }
    }



}