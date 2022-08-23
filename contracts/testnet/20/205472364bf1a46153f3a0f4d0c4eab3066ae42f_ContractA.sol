/**
 *Submitted for verification at BscScan.com on 2022-08-22
*/

contract ContractA {
    function func1(uint256 a) public view returns(address, uint256) {
        return (msg.sender, a);
    }
}