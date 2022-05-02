/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

pragma solidity 0.5.16;

contract ReceiveBNB {
    function addLiquidityEth(address router) external payable returns (bool) {
        //  IPancakeRouter(_router).addLiquidityETH(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);
    }
    function getContractBalance()external view returns(uint){
        return address(this).balance;
    }
}