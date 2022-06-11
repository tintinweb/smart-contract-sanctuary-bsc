/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

contract INSURANCE {
    //accept funds from MainContract
    receive() external payable {}

    address payable public MAINCONTRACT;

    constructor() {
        MAINCONTRACT = payable(msg.sender);
    }

    function initiate() public {
        require(msg.sender == MAINCONTRACT, "Forbidden");
        uint256 balance = address(this).balance;
        if (balance == 0) return;
        MAINCONTRACT.transfer(balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMainContract() public view returns (address) {
        return MAINCONTRACT;
    }
}