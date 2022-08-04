/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
/*
███████╗██╗  ██╗██╗███╗   ███╗   ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██╔════╝██║  ██║██║████╗ ████║   ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
███████╗███████║██║██╔████╔██║   █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
╚════██║██╔══██║██║██║╚██╔╝██║   ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
███████║██║  ██║██║██║ ╚═╝ ██║██╗██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
╚══════╝╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚═╝╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
*/
//     https://shim.finance/
// SHIM PROTOCOL COPYRIGHT (C) 2022 


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

interface IShimReferralSystem {
    function setInvestor(address _investor, address _referrer) external;
    function checkInvestor(address _user) external view returns (bool);
    function getReferrer(address _investor) external view returns (address);
}

contract ShimPresaleV2 is Ownable {
    using SafeMath for uint256;
    string public name = "ShimPresaleV2";

    IShimReferralSystem public referralSystem;

    enum Status {
        Pending,
        Open,
        Close,
        Claimable
    }

    struct UserInfo {
		uint256 invest;
        uint256 claimableTokenAmount;
        uint256 claimedTokenAmount;
        uint256 referrerReward;
        uint256 followerDiscount;
        uint256 raisedFunds;
        uint256 addFollowerNextTime;
        uint256 addFollowerCount;
	}

    struct ICOMechanism {
        Status status;
        uint256 minInvest;
        uint256 maxInvest;
        uint256 referrerRewardFee;
        uint256 followerDiscountFee;
        uint256 totalTokenAmount;
        uint256 tokenSold;
        uint256 totalInvest;
        uint256 totalReferrerReward;
        uint256 totalFollowerDiscount;
        address tokenAddress;
        uint256 tokenDecimals;
        uint256 tokenRatePerEth;
        uint256 rateDecimals;
        uint256 addFollowerMaxNum;
        uint256 addFollowerPeriod;
    }

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => UserInfo) public usersInfo;
    ICOMechanism private _ico;

    event TokenBuy(address indexed buyer, address referrer, uint256 investment);
   
    constructor(address _token, address _referralSystem) {
        _ico = ICOMechanism({
            status: Status.Pending,
            minInvest: 0.01 ether,
            maxInvest: 50 ether,
            referrerRewardFee: 100,
            followerDiscountFee: 50,
            totalTokenAmount: 500_000_00000,
            tokenSold: 1_517_08482,
            totalInvest: 3.501 ether,
            totalReferrerReward: 0,
            totalFollowerDiscount: 0,
            tokenAddress: _token,
            tokenDecimals: 5,
            tokenRatePerEth: 25000,
            rateDecimals: 2,
            addFollowerMaxNum: 100,
            addFollowerPeriod: 1 days
        });

        referralSystem = IShimReferralSystem(_referralSystem);
    }

    function viewICO() external view returns (ICOMechanism memory) {
        return _ico;
    }

    function viewUserInfo(address _user) external view returns (UserInfo memory) {
        return usersInfo[_user];
    }

    function updateReferralSystem(address _referralSystem) external onlyOwner {
        referralSystem = IShimReferralSystem(_referralSystem);
    }

    function setReferrerRewardFee(uint256 _fee) external onlyOwner {
        _ico.referrerRewardFee = _fee;
    }

    function setFollowerDiscountFee(uint256 _fee) external onlyOwner {
        _ico.followerDiscountFee = _fee;
    }

    function setTotalTokenAmount(uint256 amount) external onlyOwner {
        _ico.totalTokenAmount = amount;
    }

    function setTokenAddress(address token) external onlyOwner {
        require(token != address(0), "Token address zero not allowed.");
        
        _ico.tokenAddress = token;
    }
    
    function setTokenDecimals(uint256 decimals) external onlyOwner {
       _ico.tokenDecimals = decimals;
    }
    
    function setMinInvest(uint256 amount) external onlyOwner {
        _ico.minInvest = amount;    
    }
    
    function setMaxInvest(uint256 amount) external onlyOwner {
        _ico.maxInvest = amount;    
    }
    
    function setTokenRatePerEth(uint256 rate) external onlyOwner {
        _ico.tokenRatePerEth = rate;
    }
    
    function setRateDecimals(uint256 decimals) external onlyOwner {
        _ico.rateDecimals = decimals;
    }

    function setAddFollowerMaxNum(uint256 _addFollowerMaxNum) external onlyOwner {
        _ico.addFollowerMaxNum = _addFollowerMaxNum;
    }

    function setAddFollowerPeriod(uint256 _addFollowerPeriod) external onlyOwner {
        _ico.addFollowerPeriod = _addFollowerPeriod;
    }
     
    function startPresale() external onlyOwner {
        require(_ico.status != Status.Open, "Presale is open");
        _ico.status = Status.Open;
    }
    
    function closePrsale() external onlyOwner {
        require(_ico.status == Status.Open, "Presale is not open yet.");
        _ico.status = Status.Close;
    }

    function claimablePresale() external onlyOwner {
        require(_ico.status == Status.Close, "Presale is not close yet.");
        _ico.status = Status.Claimable;
    }
    
    receive() external payable{
        buyToken(address(0));
    }

    function buyToken(address referrer) public payable {
        require(_ico.status == Status.Open, "Presale is not open.");

        UserInfo storage userInfo = usersInfo[msg.sender];
        require(
                userInfo.invest.add(msg.value) <= _ico.maxInvest
                && userInfo.invest.add(msg.value) >= _ico.minInvest,
                "Installment Invalid."
            );

        uint256 tokenAmount = getTokensPerEth(msg.value);

        userInfo.claimableTokenAmount += tokenAmount;
        _ico.tokenSold += tokenAmount;
        userInfo.invest += msg.value;
        _ico.totalInvest += msg.value;

        uint256 _referrerReward = msg.value.mul(_ico.referrerRewardFee).div(1000);
        uint256 _followerDiscount = msg.value.mul(_ico.followerDiscountFee).div(1000);

        address _referrer = referralSystem.getReferrer(msg.sender);
        if (_referrer == address(0)) {
            referralSystem.setInvestor(msg.sender, referrer);
            _referrer = referrer;
        }

        if (_referrer != address(0)) {
            (bool success, ) = _referrer.call{value: _referrerReward, gas: 30000}("");
            (success, ) = msg.sender.call{value: _followerDiscount, gas: 30000}("");
            userInfo.followerDiscount += _followerDiscount;
            usersInfo[_referrer].referrerReward += _referrerReward;
            usersInfo[_referrer].raisedFunds += msg.value.sub(
                _referrerReward).sub(_followerDiscount);
            _ico.totalReferrerReward += _referrerReward;
            _ico.totalFollowerDiscount += _followerDiscount;
        }

        emit TokenBuy(msg.sender, referrer, msg.value);
    }

    function claimToken() public {
        require(_ico.status == Status.Claimable, "Presale is not claimable yet.");

        UserInfo storage userInfo = usersInfo[msg.sender];
        require(userInfo.claimableTokenAmount > userInfo.claimedTokenAmount, "There is not claimable token for you.");

        require(IERC20(_ico.tokenAddress).transfer(
            msg.sender, userInfo.claimableTokenAmount.sub(userInfo.claimedTokenAmount)),
            "Insufficient balance of presale contract!");
        
        userInfo.claimedTokenAmount += userInfo.claimableTokenAmount.sub(userInfo.claimedTokenAmount);
    }

    function addFollower(address[] memory follower) public {
        require(_ico.status == Status.Open, "Presale is not open.");
        
        if (usersInfo[msg.sender].addFollowerNextTime < block.timestamp) {
            usersInfo[msg.sender].addFollowerCount = 0;
            uint256 times = (block.timestamp.sub(usersInfo[msg.sender].addFollowerNextTime)).div(
                _ico.addFollowerPeriod);
            usersInfo[msg.sender].addFollowerNextTime = usersInfo[msg.sender].addFollowerNextTime.add(
                _ico.addFollowerPeriod.mul(times.add(1)));
        }
        require(usersInfo[msg.sender].addFollowerCount.add(follower.length) <= _ico.addFollowerMaxNum, 
            "Exceed day's member");
        for (uint i = 0; i < follower.length; i++) {
            address _referrer = referralSystem.getReferrer(follower[i]);
            if (_referrer == address(0)) {
                referralSystem.setInvestor(follower[i], msg.sender);
                usersInfo[msg.sender].addFollowerCount++;
            }
        }
    }
    
    function getTokensPerEth(uint256 amount) internal view returns(uint256) {
        return amount.mul(_ico.tokenRatePerEth).div(
            10**(uint256(18).sub(_ico.tokenDecimals).add(_ico.rateDecimals))
            );
    }

    function withdrawAssets(address to, uint256 amount) external onlyOwner {
        bool success;
        if(amount > 0){
            (success, ) = payable(to).call{
                value: amount,
                gas: 30000
            }("");
        } else {
            uint256 amountTo = address(this).balance;
            (success, ) = payable(to).call{
                value: amountTo,
                gas: 30000
            }("");
        }
    }
    
    function burnUnsoldTokens() external onlyOwner {
        require(_ico.status != Status.Open, "Presale is open.");
        
        IERC20(_ico.tokenAddress).transfer(
            DEAD, IERC20(_ico.tokenAddress).balanceOf(address(this)));   
    }
    
    function getUnsoldTokens(address to) external onlyOwner {
        require(_ico.status != Status.Open, "Presale is open.");
        
        IERC20(_ico.tokenAddress).transfer(
            to, IERC20(_ico.tokenAddress).balanceOf(address(this)) );
    }
}