/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.4.0;

contract OneCoin {

    struct Awards {
        uint64 uid;
        uint64 period;
        string winCode;
        bool isUsed;
    }

    struct Record {
        string hash;
        bool isUsed;
    }

    address private _owner;

    mapping(uint64 => Record) public orders;
    mapping(uint64 => Awards) public awards;

    constructor() public{
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function archive(uint64 period, string hash) public onlyOwner returns (bool){
        if (orders[period].isUsed) {
            return false;
        }
        orders[period] = Record({hash:hash, isUsed : true}) ;
        return true;
    }

    function claim(uint64 period, uint64 uid, string winCode) public onlyOwner returns (bool){
        if (awards[period].isUsed) {
            return false;
        }
        awards[period] = Awards({uid : uid, period : period, winCode : winCode, isUsed : true});
        return true;
    }
}