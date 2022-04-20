/**
 *Submitted for verification at BscScan.com on 2022-04-20
*/

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

// interface IERC20 {
//     function transfer(address recipient, uint256 amount) external returns (bool);
// }

contract MyContract {

    mapping (address => uint256) public balanceOf;
    // this function can accept BNB
    // the accepted amount is in the `msg.value` global variable
    function addStake() external payable {
        //IERC20 tokenContract = IERC20(address(0x456));
        // sending 1 smallest unit of the token to the user executing the `foo()` function
        //tokenContract.transfer(msg.sender, 1);
        balanceOf[msg.sender] = msg.value; // Transfers all tokens to owner
    }

    function viewData() public payable  {
        msg.value;
    }

    // function withdrawStake(uint256 transferAmount) external {
    //     //address recipient = address(0x123);
    //     payable(msg.sender).transfer(transferAmount ether);
    // }

    function rescueBNB(uint256 amount) external {
        payable(msg.sender).transfer(amount);
    }

//find the number of xlt's user staked
    function balanceOfCheck(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return balanceOf[_stakeholder];
    }
}