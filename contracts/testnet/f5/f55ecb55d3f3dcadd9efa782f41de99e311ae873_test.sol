/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

pragma solidity ^0.5.0;

contract IFreeUpTo {
    function freeUpTo(uint256 value) external returns (uint256 freed);
}

contract ChiGasSaver {

    modifier saveGas() {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;

        IFreeUpTo chi = IFreeUpTo(0x97ce490607c6FD1595c6eFC8c0293af7f10A1dfF);
        chi.freeUpTo((gasSpent + 14154) / 41947);
    }
}

contract test is ChiGasSaver {

    uint nums;

    function doit(uint num) external saveGas(){
        nums = 0;
        for (uint i=0; i<num; i++){
            nums += i;
        }
    }

}