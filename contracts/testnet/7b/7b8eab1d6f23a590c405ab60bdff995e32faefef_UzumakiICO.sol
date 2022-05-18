/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
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
        require(msg.sender == _owner, "Not owner");
        _;
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

contract UzumakiICO is Ownable {    

    using SafeMath for uint256;

    bool public icoCompleted;
    uint256 public icoStartTime;
    uint256 public icoEndTime;
    uint256 public tokenRate;
    uint256 public fundingGoal;
    uint256 public tokensRaised;
    uint256 public etherRaised;

    uint256 priceOfToken;
    
    uint public lastIDCount = 0;
    address payable public ownerWallet;

    
    modifier whenIcoCompleted {
        require(icoCompleted);
        _;
    }

    struct UserInfo {
        bool joined;
        uint id;
        address payable selfAddr;
        address payable parent;
        uint level;
    }

    mapping (address => UserInfo) public userInfos;
    mapping (uint => address payable ) public userAddressByID;

    constructor () {
        priceOfToken = 1e18;
        lastIDCount = 0;
    }

    function buy(address payable parent) public payable {
        
        UserInfo memory userInfo;
        bool hasParent = false;        
        
        //check the parent is already exists as user.

        if (lastIDCount > 0) {
            for (uint i = 0; i < lastIDCount; i++) {
                if (userInfos[userAddressByID[i]].parent == parent) {
                    hasParent = true;
                } else {
                    hasParent = false;
                }
            }
        }

        lastIDCount++;
        userAddressByID[lastIDCount] = payable(msg.sender);

        if (hasParent == true) {
            userInfo = UserInfo({
                joined: true,
                id: lastIDCount,
                selfAddr: payable(msg.sender),
                parent: parent,
                level: 0
            });

            userInfos[parent].level += 1;

        } else {
            userInfo = UserInfo({
                joined: true,
                id: lastIDCount,
                selfAddr: payable(msg.sender),
                parent: address(0),
                level: 0
            });
        }

        userInfos[msg.sender] = userInfo;

    }

    function setPriceOfToken(uint256 price) external onlyOwner {
        priceOfToken = price;
    }

    function getPriceOfToken() external view returns (uint256){
        return priceOfToken;
    }

}