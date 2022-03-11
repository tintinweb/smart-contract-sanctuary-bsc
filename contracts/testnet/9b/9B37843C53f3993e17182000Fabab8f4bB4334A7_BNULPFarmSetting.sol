/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BNULPFarmSetting is  Ownable {
    using SafeMath for uint256;

    uint256 public withdrawFee = 1 * (10**18);
    uint256 public rewardAmountEveryDay = 900 * (10**18);
    bool public start = true;

    mapping (uint256 => uint256) public cakeRewardOfSecondEveryDay;
    uint256 public withdrawCakeFee = 5 * (10**16);

    mapping(address => address) public communityRelation;
    address[] public communityList;
    mapping(address => bool) public isCommunity;
    mapping(address => uint256) public communityIndex;
    uint256 public communityLength;

    constructor(){}

    function addCommunity(address user_, address top_) public onlyOwner {
        require(!isCommunity[user_], "already community");
        isCommunity[user_] = true;
        communityRelation[user_] = top_;
        communityIndex[user_] = communityList.length;
        communityList.push(user_);
        communityLength = communityList.length;
    }

    function deleteCommunity(address user_) public onlyOwner {
        require(isCommunity[user_], "already community");
        isCommunity[user_] = false;
        communityRelation[user_] = address(0);

        communityList[communityIndex[user_]] = communityList[communityList.length-1];
        communityIndex[communityList[communityList.length-1]] = communityIndex[user_];
        communityList.pop();
        communityLength = communityList.length;
    }

    function updateCommunityRelation(address user_, address top_) public onlyOwner {
        require(isCommunity[user_], "already community");
        communityRelation[user_] = top_;
    }

    function getCommunityList() public view returns(address[] memory)  {
        return communityList;
    }

    function setStart(bool val_) public onlyOwner {
        start = val_;
    }

    function setWithdrawFee(uint256 fee_) public onlyOwner {
        withdrawFee = fee_;
    }

    function setWithdrawCakeFee(uint256 fee_) public onlyOwner {
        withdrawCakeFee = fee_;
    }

    function setRewardAmountEveryDay(uint256 amount_) public onlyOwner {
        rewardAmountEveryDay = amount_;
    }

    function setCakeRewardOfSecondEveryDay(uint256 amount_) public onlyOwner {
        uint256 today = block.timestamp.div(86400);
        cakeRewardOfSecondEveryDay[today] = amount_;
    }

    receive() external payable {}

    function withdrawETH(address account, uint256 amount) public onlyOwner {
        require(address(this).balance > amount , "BAD");
        payable(account).transfer(amount);
    }

    function withdrawAnyToken(address token, address account, uint256 amount) public onlyOwner {
        require(IBEP20(token).balanceOf(address(this)) > amount , "BAD");
        IBEP20(token).transfer(account, amount);
    }

}