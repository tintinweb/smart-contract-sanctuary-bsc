/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**The world is yours to change, will you take up the mantle?

Join us in shaping a better tomorrow, endgame.black

The endgame draws near.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

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

        return c;
    }

}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IReferralSystem {
    function setInvestor(address _investor, address _referrer) external;
    function checkInvestor(address _user) external view returns (bool);
    function getReferrer(address _investor) external view returns (address);
}

contract ReferralTerminal is Ownable {
    using SafeMath for uint256;
    string public name = "ReferralTerminal";

    IReferralSystem public referralSystem;

    struct UserInfo {
        uint256 addFollowerNextTime;
        uint256 addFollowerCount;
	}

    mapping(address => UserInfo) public usersInfo;
    uint256 public addFollowerPeriod;
    uint256 public addFollowerMaxNum;
   
    constructor() {
        addFollowerPeriod = 1 days;
        addFollowerMaxNum = 100;
    }

    function setReferrer(address referrer) external {
        address _referrer = referralSystem.getReferrer(msg.sender);
        if ((_referrer == address(0)) && (referrer != msg.sender)) {
            referralSystem.setInvestor(msg.sender, referrer);
        }
    }

    function addFollower(address[] memory follower) external {
        if (usersInfo[msg.sender].addFollowerNextTime < block.timestamp) {
            usersInfo[msg.sender].addFollowerCount = 0;
            uint256 times = (block.timestamp.sub(usersInfo[msg.sender].addFollowerNextTime)).div(
                addFollowerPeriod);
            usersInfo[msg.sender].addFollowerNextTime = usersInfo[msg.sender].addFollowerNextTime.add(
                addFollowerPeriod.mul(times.add(1)));
        }
        require(usersInfo[msg.sender].addFollowerCount.add(follower.length) <= addFollowerMaxNum, 
            "Exceed day's member");
        for (uint i = 0; i < follower.length; i++) {
            address _referrer = referralSystem.getReferrer(follower[i]);
            if ((_referrer == address(0)) && (follower[i] != msg.sender)) {
                referralSystem.setInvestor(follower[i], msg.sender);
                usersInfo[msg.sender].addFollowerCount++;
            }
        }
    }

    function updateReferralSystem(address _referralSystem) external onlyOwner {
        referralSystem = IReferralSystem(_referralSystem);
    }

    function setAddFollowerPeriod(uint256 _addFollowerPeriod) external onlyOwner {
        addFollowerPeriod = _addFollowerPeriod;
    }

    function setAddFollowerMaxNum(uint256 _addFollowerMaxNum) external onlyOwner {
        addFollowerMaxNum = _addFollowerMaxNum;
    }

}