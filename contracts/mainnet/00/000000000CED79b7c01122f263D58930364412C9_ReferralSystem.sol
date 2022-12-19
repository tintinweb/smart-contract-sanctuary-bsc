/**
 *Submitted for verification at BscScan.com on 2022-12-19
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

contract ReferralSystem is Ownable {
    using SafeMath for uint256;
    string public name = "ReferralSystem";

    struct UserInfo {
		uint256 index;
        address referrer;
        address[] follower;
	}

    mapping(address => bool) internal isOperator;
    address[] internal operators;
    mapping(address => bool) internal isInvestor;
    address[] internal investors;
    mapping(address => UserInfo) internal usersInfo;

    modifier onlyOperator() {
        require(isOperator[msg.sender], "Not operator");
        _;
    }

    event InvestorSet(address indexed _investor, address _referrer);
    event LinkRemove(address indexed _investor);
    event OperatorSet(address indexed _operator, bool _flag);

    constructor() {}

    function setInvestor(address _investor, address _referrer) external onlyOperator {
        if (isInvestor[_investor]) {
            if (usersInfo[_investor].referrer == address(0)) {
                if ((_referrer != address(0)) && (_investor != _referrer)) {
                    usersInfo[_investor].referrer = _referrer;
                    usersInfo[_referrer].follower.push(_investor);
                }
            }
        } else {
            isInvestor[_investor] = true;
            usersInfo[_investor].index = investors.length;
            investors.push(_investor);
            if (usersInfo[_investor].referrer == address(0)) {
                if ((_referrer != address(0)) && (_investor != _referrer)) {
                    usersInfo[_investor].referrer = _referrer;
                    usersInfo[_referrer].follower.push(_investor);
                }
            }
        }

        emit InvestorSet(_investor, _referrer);
    }

    function removeLink(address _investor) external onlyOperator {
        if (isInvestor[_investor]) {
            if (usersInfo[_investor].referrer != address(0)) {
                address _referrer = usersInfo[_investor].referrer;
                uint256 _length = usersInfo[_referrer].follower.length;
                for (uint256 i=0; i<_length; i++) {
                    if (usersInfo[_referrer].follower[i] == _investor) {
                        usersInfo[_referrer].follower[i] = usersInfo[_referrer].follower[_length-1];
                        usersInfo[_referrer].follower.pop();
                        break;
                    }
                }
                usersInfo[_investor].referrer = address(0);

                emit LinkRemove(_investor);
            }
        }
    }

    function setOperator(address _operator, bool _flag) external onlyOwner {
        if (_flag) {
            if (!isOperator[_operator]) {
                isOperator[_operator] = true;
                operators.push(_operator);
            }
        } else {
            if (isOperator[_operator]) {
                isOperator[_operator] = false;
                for (uint256 i=0; i<operators.length; i++) {
                    if (operators[i] == _operator) {
                        operators[i] = operators[operators.length - 1];
                        operators.pop();
                        break;
                    }
                }
            }
        }

        emit OperatorSet(_operator, _flag);
    }

    function checkOperator(address _user) external view returns (bool) {
        return isOperator[_user];
    }

    function totalOperators() external view returns (uint256) {
        return operators.length;
    }

    function viewOperatorByIndex(uint256 _index) external view returns (address) {
        return operators[_index];
    }

    function checkInvestor(address _user) external view returns (bool) {
        return isInvestor[_user];
    }

    function totalInvestors() external view returns (uint256) {
        return investors.length;
    }

    function investorAddressByIndex(uint256 _index) external view returns (address) {
        return investors[_index];
    }

    function getReferrer(address _investor) external view returns (address) {
        return usersInfo[_investor].referrer;
    }

    function getTotalFollowers(address _investor) external view returns (uint256) {
        return usersInfo[_investor].follower.length;
    }

    function getFollowerByIndex(
        address _investor, uint256 _index
    ) external view returns (address) {
        return usersInfo[_investor].follower[_index];
    }

    function viewUserInfoByIndex(
        uint256 _index
    ) external view returns (
        address _userAddress,
        UserInfo memory _userInfo
    ) {
        _userAddress = investors[_index];
        _userInfo = usersInfo[_userAddress];
    }

    function viewUserInfoByAddress(
        address _userAddress
    ) external view returns (
        UserInfo memory _userInfo
    ) {
        _userInfo = usersInfo[_userAddress];
    }

}