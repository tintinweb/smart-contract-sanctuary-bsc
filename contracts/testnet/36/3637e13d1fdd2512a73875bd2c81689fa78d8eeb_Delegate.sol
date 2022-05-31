/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

contract Delegate {

    // Storage is not in the same order as in the Proxy contract
    uint public n = 1;

    function adds() public {
        n = 5;
    }
}