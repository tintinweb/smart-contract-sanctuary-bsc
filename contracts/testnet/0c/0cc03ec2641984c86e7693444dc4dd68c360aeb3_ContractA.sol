/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

contract ContractA {
    address public caller;
    uint256 public val;
    function func1(uint256 a) public {
        caller = msg.sender;
        val = a;
    }
}