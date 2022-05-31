/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

contract Proxy {

    // The delegate address will be overwritten with the
    // value that was supposed to be stored in n
    address public delegate;
    uint public n = 1;

    constructor(address _delegateAdr) public {
        delegate = _delegateAdr;
    }

    function() external payable {

        assembly {
            let _target := sload(0)
            calldatacopy(0x0, 0x0, calldatasize)
            let result := delegatecall(gas, _target, 0x0, calldatasize, 0x0, 0)
            returndatacopy(0x0, 0x0, returndatasize)
            switch result case 0 {revert(0, 0)} default {return (0, returndatasize)}
        }
    }
}