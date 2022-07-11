/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol
library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract EnglishCourseRegisterJul {
    using SafeMath for uint256;

    address _owner;
    uint256 maxStudent;
    uint256 price;
    uint256 totalReceive = 0;
    uint256 totalWithdraw = 0;
    uint256 public decimal = 18;
    uint256 public deadline; // https://www.unixtimestamp.com
    address payable public withdrawAddress;
    mapping(address => bool) public whitelist;
    uint256 totalWhitelist = 0;
    mapping(address => bool) public paidlist;
    uint256 totalPaidlist = 0;

    modifier onlyOwner() {
        require(msg.sender == owner(), "Ownable: caller is not the owner");
        _; // _ phai co khi viet modifier, sau khi thoa man yeu cau modifier se thuc hien code tiep theo cua function
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender] == true);
        _;
    }

    constructor(uint256 _maxStudent, uint256 _price, uint256 _deadline) {
        _owner = msg.sender;
        withdrawAddress = payable(msg.sender);
        maxStudent = _maxStudent;
        price = _price;
        deadline = _deadline;
    }

    function owner() public view virtual returns(address) {
        return _owner;
    }

    // Them danh sach ghi danh
    function addWhitelist(address[] memory _whitelist) external onlyOwner {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            address wl = _whitelist[i];
            if (whitelist[wl] == false) {
                totalWhitelist += 1;
            }
            whitelist[wl] = true;
        }
    }

    // Xoa danh sach ghi danh
    function removeWhitelist(address[] memory _whitelist) external onlyOwner {
        for (uint256 i = 0; i < _whitelist.length; i++) {
            address wl = _whitelist[i];
            if (whitelist[wl] == true) {
                totalWhitelist -= 1;
            }
            whitelist[wl] = false;
        }
    }

    // Thong ke
    function statistic() external view returns(uint256 _maxStudent,
                                               uint256 _totalWhitelist,
                                               uint256 _totalPaidlist,
                                               uint256 _price,
                                               uint256 _total) {
        return (maxStudent,
                totalWhitelist,
                totalPaidlist,
                price,
                totalReceive);
    }

    // Dong hoc phi
    receive() external payable onlyWhitelist {
        require(block.timestamp <= deadline && totalPaidlist <= maxStudent && paidlist[msg.sender] == false && msg.value == price);
        paidlist[msg.sender] = true;
        totalReceive += msg.value;
    }

    function withdraw(uint256 _amount) external payable onlyOwner {
        require(_amount <= totalReceive, "The amount must be less than or equal totalReceive");
        payable(msg.sender).transfer(_amount);
        totalWithdraw += _amount;
    }
}