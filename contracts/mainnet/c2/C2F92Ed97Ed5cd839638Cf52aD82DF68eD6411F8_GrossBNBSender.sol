/**
 *Submitted for verification at BscScan.com on 2022-10-31
*/

//This software is property of GrossMining... DO NOT COPY!
//Website: https://grossmining.com

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GrossBNBSender {
    using SafeMath for uint256;

    address Dev;
    address feeReceiver = 0xE03e6F942B541C59f98e052Bf9c8422c3E2876ee;

    uint256[2] Sf = [990, 10];
    uint256 percentDivider = 1000;
    uint256 minimumSend = 0.001 ether;
    uint256 public totalSent;
    uint256 public totalTx;

    event TRANSFER(address sender, uint256 amount);

    modifier onlyDev() {
        require(Dev == msg.sender, "only Dev");
        _;
    }

    bool private reentrancySafe = false;

    modifier nonReentrant() {
        require(!reentrancySafe);
        reentrancySafe = true;
        _;
        reentrancySafe = false;
    }

    constructor(address _Dev) {
        Dev = payable(_Dev);
    }

    function sendBNB(address to) public payable nonReentrant {
        require(to != address(0), "Invalid address");
        uint256 send_amount = msg.value;
        require(send_amount >= minimumSend, "Amount too small");

        (bool s1, ) = to.call{value: send_amount.mul(Sf[0]).div(percentDivider)}("");
        require(s1, "Transfer failed.");

        (bool s2, ) = feeReceiver.call{value: send_amount.mul(Sf[1]).div(percentDivider)}("");
        require(s2, "Transfer failed.");

        totalSent += send_amount;
        totalTx++;

        emit TRANSFER(msg.sender, send_amount);
    }

    function setSf(
        uint256 first,
        uint256 second
    ) external onlyDev {
        Sf[0] = first;
        Sf[1] = second;
    }

    function changeDev(address _dev) external onlyDev {
        Dev = _dev;
    }

    function setPercentDivider(uint256 _div) external onlyDev {
        percentDivider = _div;
    }

    function setFeeReceiver(address payable _fr) external onlyDev {
        feeReceiver = _fr;
    }

    function setMinimumSend(uint256 _msa) external onlyDev {
        minimumSend = _msa;
    }

    function rescueBNB() external onlyDev {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-Tiers/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}