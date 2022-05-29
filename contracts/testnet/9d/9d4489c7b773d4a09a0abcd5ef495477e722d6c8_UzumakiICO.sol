/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

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

    uint256 public icoStartTime;
    uint256 public icoEndTime;

    uint256 priceOfToken;

    mapping(uint => uint) public level;
    uint public presaleExtra = 20;
    
    uint public lastIDCount = 0;
    address payable public ownerWallet;
    
    address public tokenAddress = 0x1f92111fAB32086a3a5C23262F8BBC33FCc8Bbc5;

    struct UserInfo {
        bool joined;
        uint id;
        address selfAddr;
        address parent;
        uint level;
    }

    mapping (address => UserInfo) public userInfos;
    mapping (uint => address ) public userAddressByID;
    mapping (uint => UserInfo) public usersToPay;
    
    mapping (address => uint256) public lockedTokenAmountPerAddress;
    mapping (address => uint256) public lockedTimePerAddress;
    uint256 private secondsOfYear = 3600 * 24 * 365;
    uint256 private wholeLockedTokens = 0;

    constructor () {
        priceOfToken = 1e15;
        lastIDCount = 0;
        icoStartTime = block.timestamp;
        icoEndTime = icoStartTime + 3600 * 24 * 30;

        level[1] = 10;
        level[2] = 4;
        level[3] = 3;
        level[4] = 1;
        level[5] = 1;
        level[6] = 1;
    }

    function buy(address parent) public payable {
        require(msg.value > 0);
        require(address(this).balance > 0);
        require(icoStartTime < block.timestamp && block.timestamp < icoEndTime);
        
        uint tokenAmount = msg.value / priceOfToken * 1e18;
        tokenAmount = tokenAmount * (presaleExtra + 100) / 100;

        require((wholeLockedTokens + tokenAmount) < IERC20(tokenAddress).balanceOf(address(this)));

        bool hasSelf = false;                
        if (lastIDCount > 0) {
            for (uint i = 1; i <= lastIDCount; i++) {
                if (userAddressByID[i] == msg.sender) {
                    hasSelf = true;
                }
            }
        }

        require(hasSelf == false);

        UserInfo memory userInfo;  
        bool hasParent = false;
        

        if (lastIDCount > 0) {
            for (uint i = 1; i <= lastIDCount; i++) {
                if (userAddressByID[i] == parent) {
                    hasParent = true;                 
                }
            }
        }

        lastIDCount++;
        userAddressByID[lastIDCount] = msg.sender;

        if (hasParent == true) {
            userInfo = UserInfo({
                joined: true,
                id: lastIDCount,
                selfAddr: msg.sender,
                parent: parent,
                level: 0
            });

            userInfos[parent].level += 1;

        } else {
            userInfo = UserInfo({
                joined: true,
                id: lastIDCount,
                selfAddr: msg.sender,
                parent: address(0),
                level: 0
            });
        }

        userInfos[msg.sender] = userInfo;

        uint id = 0;
        usersToPay[id] = userInfos[msg.sender];

        for (uint i = 1; i <= 6; i++) {
            if (usersToPay[i-1].parent != address(0)) {
                usersToPay[i] = userInfos[usersToPay[i-1].parent];
            } else {
                break;
            }
        }

        lockedTokenAmountPerAddress[msg.sender] = tokenAmount;
        lockedTimePerAddress[msg.sender] = block.timestamp;
        wholeLockedTokens += tokenAmount;

        for (uint i = 1; i <= 6; i++) {
            if (i <= usersToPay[i].level) {
                payable(usersToPay[i].selfAddr).transfer(msg.value * level[i] / 100);
            }
        }
    }

    function setIcoEndTime(uint256 day) external onlyOwner {
        icoEndTime = icoStartTime + 3600 * 24 * day;
    }

    function setPriceOfToken(uint256 price) external onlyOwner {
        priceOfToken = price;
    }

    function getPriceOfToken() external view returns (uint256){
        return priceOfToken;
    }

    function getParentAddress(uint256 id) external view returns (address) {
        return userInfos[userAddressByID[id]].parent;
    }

    function getLevel(uint256 id) external view returns (uint) {
        return userInfos[userAddressByID[id]].level;
    }

    function balanceOfToken() external view returns (uint256) {        
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function setTokenAddress(address addr) external onlyOwner {
        tokenAddress = addr;
    }

    function withDraw (address addr) external onlyOwner {
        payable(addr).transfer(address(this).balance);
    }

    function setPresaleExtra (uint value) external onlyOwner {
        presaleExtra = value;
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function getUnlockedTokens() external view returns (uint256) {
        uint unlockedTokens = IERC20(tokenAddress).balanceOf(address(this)) - wholeLockedTokens;
        return unlockedTokens;
    }

    function withdrawLockedToken (address addr) external {
        uint256 lockedTime = lockedTimePerAddress[addr] + secondsOfYear;
        require(block.timestamp > lockedTime);
        IERC20(tokenAddress).transfer(addr, lockedTokenAmountPerAddress[addr]);
    }

}