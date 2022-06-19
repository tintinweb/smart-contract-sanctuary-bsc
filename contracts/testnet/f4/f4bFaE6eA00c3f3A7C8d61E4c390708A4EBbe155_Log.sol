/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

contract Log {
    event LogEvent(address indexed sender, uint amount);

    function log(address sender, uint amount) public {
        LogEvent(sender, amount);
    }
}