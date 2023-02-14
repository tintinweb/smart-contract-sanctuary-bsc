/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

contract Lesson8 {
    address public owner;
    uint256 public depositAmount;
    function test() public {
        owner = msg.sender;
    }

    function deposit() public payable {
        depositAmount = msg.value;
    }

    function ethBalance() public view returns (uint256) {
        return address(this).balance;
    }
}