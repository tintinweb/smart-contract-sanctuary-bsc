/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function totalSupply() external virtual view returns (uint256);
}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier isRunning {
        require(running, "Modifier: No Running");
        _;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

contract NWNMinePool is Modifier, Util {

    using SafeMath for uint256;

    mapping(address => address) private invitationMapping;

    uint256 public networkPledge;
    uint256 public secondsOfDay;
    uint256 private inviteRatio;
    uint256 private teamRatio;

    address private receiveAddress;

    mapping(address => uint256) pledgeAmount;
    mapping(address => uint256) pledgeValue;
    mapping(address => uint256) pledgeTime;
    mapping(address => uint256) receiveTime;

    ERC20 private nwnToken;
    ERC20 private usdtToken;
    ERC20 private lpToken;

    constructor() {

        secondsOfDay = 24 * 60 * 60;
        inviteRatio = 50;
        teamRatio = 20;

        nwnToken = ERC20(0xFEc800b20A5380bb674210ef72F7596f62576002);
        usdtToken = ERC20(0x55d398326f99059fF775485246999027B3197955);
        lpToken = ERC20(0x17f44dC71F032BEE95FC52Ff9d7eA92D209F9861);
        receiveAddress = 0x111Df57BDb7E411e0A8047273b99c028A698245d;
    }

    function setTokenContract(address _nwnToken, address _usdtToken, address _lpToken) public onlyOwner {
        nwnToken = ERC20(_nwnToken);
        usdtToken = ERC20(_usdtToken);
        lpToken = ERC20(_lpToken);
    }

    function setSecondsOfDay(uint256 _seconds) public onlyOwner {
        secondsOfDay = _seconds;
    }

    function setInviteRatio(uint256 _ratio) public onlyOwner {
        inviteRatio = _ratio;
    }

    function setTeamRatio(uint256 _ratio) public onlyOwner {
        teamRatio = _ratio;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

    function pledge(uint256 amountToWei) public isRunning nonReentrant returns (bool) {

        lpToken.transferFrom(msg.sender, address(this), amountToWei);

        uint256 usdtBalance = usdtToken.balanceOf(address(lpToken));
        uint256 currentValue = amountToWei.mul(usdtBalance).mul(2).div(lpToken.totalSupply());

        uint256 receiveAmount = computeReceiveReward(msg.sender);
        if(receiveAmount > 0) {
            privateRecevieReward(receiveAmount);
        }

        pledgeAmount[msg.sender] = pledgeAmount[msg.sender].add(amountToWei);
        pledgeValue[msg.sender] = pledgeValue[msg.sender].add(currentValue);
        pledgeTime[msg.sender] = block.timestamp;
        receiveTime[msg.sender] = block.timestamp;

        networkPledge = networkPledge.add(amountToWei);

        return true;
    }

    function redeem() public isRunning nonReentrant returns (bool) {

        if(pledgeAmount[msg.sender] <= 0) {
            _status = _NOT_ENTERED;
            revert("NWN: There is no available amount");
        }

        uint256 receiveAmount = computeReceiveReward(msg.sender);
        if(receiveAmount > 0) {
            privateRecevieReward(receiveAmount);
        }

        lpToken.transfer(msg.sender, pledgeAmount[msg.sender]);

        pledgeAmount[msg.sender] = 0;
        pledgeValue[msg.sender] = 0;
        receiveTime[msg.sender] = block.timestamp;
        networkPledge = networkPledge.sub(pledgeAmount[msg.sender]);

        return true;
    }

    function receiveReward() public isRunning nonReentrant returns (bool) {

        uint256 receiveAmount = computeReceiveReward(msg.sender);

        if(receiveAmount <= 0) {
            _status = _NOT_ENTERED;
            revert("NWN: There is no reward");
        }
        privateRecevieReward(receiveAmount);
        receiveTime[msg.sender] = block.timestamp;
        return true;
    }

    function privateRecevieReward(uint256 receiveAmount) private {

        uint256 _rewardAmount = toWei(receiveAmount, 18).div(queryNwnToUsdtPrice());
        nwnToken.transfer(msg.sender, _rewardAmount);

        if(invitationMapping[msg.sender] != address(0) && pledgeAmount[invitationMapping[msg.sender]] > 0) {
            uint256 inviteReward = _rewardAmount.mul(inviteRatio).div(100);
            nwnToken.transfer(invitationMapping[msg.sender], inviteReward);
        }

        if(receiveAddress != address(0)) {
            uint256 teamReward = _rewardAmount.mul(teamRatio).div(100);
            nwnToken.transfer(receiveAddress, teamReward);
        }

    }

    function computeReceiveReward(address _address) private view returns (uint256 number) {

        uint256 waitReceive = 0;

        if(pledgeAmount[_address] <= 0 || block.timestamp.sub(receiveTime[_address]) < secondsOfDay) {
            return waitReceive;
        }

        uint256 fifteenTime = pledgeTime[_address].add(secondsOfDay.mul(15));
        uint256 thirtyTime = pledgeTime[_address].add(secondsOfDay.mul(30));
        uint256 fortyFiveTime = pledgeTime[_address].add(secondsOfDay.mul(45));
        uint256 sixtyTime = pledgeTime[_address].add(secondsOfDay.mul(60));

        uint256 lastReceiveTime = receiveTime[_address];

        if(lastReceiveTime <= fifteenTime) {
            if(block.timestamp <= fifteenTime) {
                return computeWaitReceive(_address, block.timestamp, lastReceiveTime, 4).add(waitReceive);
            } else {
                waitReceive = computeWaitReceive(_address, fifteenTime, lastReceiveTime, 4).add(waitReceive);
                lastReceiveTime = fifteenTime;
            }
        }

        if(lastReceiveTime <= thirtyTime) {
            if(block.timestamp <= thirtyTime) {
                return computeWaitReceive(_address, block.timestamp, lastReceiveTime, 5).add(waitReceive);
            } else {
                waitReceive = computeWaitReceive(_address, thirtyTime, lastReceiveTime, 5).add(waitReceive);
                lastReceiveTime = thirtyTime;
            }
        }

        if(lastReceiveTime <= fortyFiveTime) {
            if(block.timestamp <= fortyFiveTime) {
                return computeWaitReceive(_address, block.timestamp, lastReceiveTime, 6).add(waitReceive);
            } else {
                waitReceive = computeWaitReceive(_address, fortyFiveTime, lastReceiveTime, 6).add(waitReceive);
                lastReceiveTime = fortyFiveTime;
            }
        }

        if(lastReceiveTime <= sixtyTime) {
            if(block.timestamp <= sixtyTime) {
                return computeWaitReceive(_address, block.timestamp, lastReceiveTime, 7).add(waitReceive);
            } else {
                waitReceive = computeWaitReceive(_address, sixtyTime, lastReceiveTime, 7).add(waitReceive);
                lastReceiveTime = sixtyTime;
            }
        }

        if(block.timestamp > sixtyTime) {
            waitReceive = computeWaitReceive(_address, block.timestamp, lastReceiveTime, 9).add(waitReceive);
        }

        return waitReceive;
    }

    function computeWaitReceive(address _address, uint256 startTime, uint256 endTime, uint256 _ratio) private view returns (uint256) {
        uint256 tempDay = startTime.sub(endTime).div(secondsOfDay);
        return pledgeValue[_address].mul(_ratio).div(1000).mul(tempDay);
    }

    function getAvailableReward(address _address) public view returns(uint256) {
        return computeReceiveReward(_address);
    }

    function getPledgeAmount(address _address) public view returns(uint256) {
        return pledgeAmount[_address];
    }

    function getPledgeValue(address _address) public view returns(uint256) {
        return pledgeValue[_address];
    }

    function getPledgeTime(address _address) public view returns(uint256) {
        return pledgeTime[_address];
    }

    function getReceiveTime(address _address) public view returns(uint256) {
        return receiveTime[_address];
    }

    function bindInviter(address inviterAddress) public isRunning nonReentrant {

        if(invitationMapping[inviterAddress] == address(0) && inviterAddress != address(this)) {
            _status = _NOT_ENTERED;
            revert("NWN: Inviter is invalid");
        }

        if(invitationMapping[msg.sender] == address(0)) {
            invitationMapping[msg.sender] = inviterAddress;
        }
    }
    
    function updateInviter(address _address, address inviterAddress) public onlyApprove {
        invitationMapping[_address] = inviterAddress;
    }

    function getBindStatus() public view returns(bool status) {
        if(invitationMapping[msg.sender] == address(0)) {
            return false;
        }
        return true;
    }

    function getInviter(address _address) public view returns(address) {
        return invitationMapping[_address];
    }

    function updateInviterByList(address [] memory addressList, address [] memory inviterAddressList) public onlyApprove {
        for(uint8 i=0; i<addressList.length; i++) {
            invitationMapping[addressList[i]] = inviterAddressList[i];
        }
    }

    // 1 NWN = ? U
    function queryNwnToUsdtPrice() public view returns (uint256) {
        uint256 reserveA = nwnToken.balanceOf(address(lpToken));
        uint256 reserveB = usdtToken.balanceOf(address(lpToken));
        return Util.mathDivisionToFloat(reserveB, reserveA, 18);
    }


}