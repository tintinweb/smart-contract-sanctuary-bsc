/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

contract Vault {
    
    receive() external payable {}

    function getBNB() public {
        (payable (msg.sender)).transfer(address(this).balance);
    }

}