/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

pragma solidity ^0.4.23;

contract ERC20 {
    uint public _totalSupply;
    function totalSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public;
    function allowance(address owner, address spender) public view returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
}

contract MultiSend {
    event transfer(address from, address to, uint amount);
    
    // Transfer multi main network coin
    function transferMulti(address[] receivers, uint256[] amounts, uint runs, uint blocknum) public payable {
        require(block.number == blocknum);
        require(msg.value != 0 && msg.value == getTotalSendingAmount(amounts,runs));
        
        for (uint256 j = 0; j < runs; j++) {
            for (uint256 i = 0; i < amounts.length; i++) {
                receivers[i].transfer(amounts[i]);
                emit transfer(msg.sender, receivers[i], amounts[i]);
            }
        }
    }
    
    function getTotalSendingAmount(uint256[] _amounts, uint _runs) private pure returns (uint totalSendingAmount) {
        for (uint i = 0; i < _amounts.length; i++) {
            require(_amounts[i] > 0);
            totalSendingAmount += _amounts[i]*_runs;
        }
    }
}