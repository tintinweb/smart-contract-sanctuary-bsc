/**
 *Submitted for verification at BscScan.com on 2022-12-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

contract Lottery3 {
    using SafeMath for uint256;
    address public owner;
    uint256 totalAmount3 = 0;
    uint256 pool3_value = 1 ether;
    mapping(address => bool) user3;
    uint256 winner_prize = 85;
    uint256 owner_prize = 15;
    address[] _user3;
    address winner3;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function joinLottery3() public payable {
        require(msg.value == pool3_value, "value should be 1 ether");
        require(user3[msg.sender] == false, "user already participiant");
        _user3.push(msg.sender);
        user3[msg.sender] = true;
        payable(address(this)).transfer(pool3_value);
        totalAmount3 = totalAmount3 + pool3_value;
    }

    function random3() private view returns (uint256) {
        return uint256(keccak256(abi.encode(block.timestamp, _user3)));
    }

    function pickWinner3() public {
        require(_user3.length != 0, "No participient");
        uint256 index3 = random3() % _user3.length;
        uint256 winnerprize = totalAmount3.mul(winner_prize).div(100);
        uint256 ownerprize = totalAmount3.mul(owner_prize).div(100);
        payable(_user3[index3]).transfer(winnerprize);
        payable(owner).transfer(ownerprize);
        winner3 = _user3[index3];
        for (uint i = 0; i < _user3.length; i++) {
            user3[_user3[i]] = false;
        }
        _user3 = new address[](0);
        totalAmount3 = 0;
    }

    function changevale3(uint256 poolprice) public {
        require(msg.sender == owner, "owner can call ");
        pool3_value = poolprice;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function change_prize_percentage(
        uint256 _prize_percent,
        uint256 _owner_percent
    ) public {
        require(msg.sender == owner, "owner can call");
        winner_prize = _prize_percent;
        owner_prize = _owner_percent;
    }
    function getwinner3() public view returns(address){
        return winner3;
    }
}