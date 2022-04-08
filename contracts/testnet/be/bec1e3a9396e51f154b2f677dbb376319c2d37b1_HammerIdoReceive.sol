/**
 *Submitted for verification at BscScan.com on 2022-04-08
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

    function toWei(uint number, uint decimals) public pure returns (uint){
        return number * (10 ** uint(decimals));
    }

}

contract HammerIdoReceive is Modifier, Util {

    using SafeMath for uint;

    mapping(address => uint) private buyIdoNumber;
    mapping(address => uint) private inviteReward;
    mapping(address => uint) private receiveIdoNumber;

    uint private idoReceivePeriod; // Private placement receive period

    uint private swapOnlineTime; // swap online time

    ERC20 private buyToken;
    ERC20 private sellToken;

    constructor() {
        swapOnlineTime = 0;
        idoReceivePeriod = 30;
    }

    /*
     * @dev Set up | Creator call | Set the token contract address
     * @param _buyToken  Configure the purchase token contract address
     * @param _sellToken Configure the address of the sell token contract
     */
    function setTokenContract(address _buyToken, address _sellToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
        sellToken = ERC20(_sellToken);
    }

    function setSwapOnlineTime() public onlyOwner {
        swapOnlineTime = block.timestamp;
    }

    function getNumberByAddress(address _address) public view returns(uint numberToWei) {
        return buyIdoNumber[_address];
    }

    function getInviteReward(address _address) public view returns(uint numberToWei) {
        return inviteReward[_address];
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

    function getNumberForIdo() public view returns(uint number) {
        if(swapOnlineTime == 0) {
            return 0;
        }
        return computeReceiveIdoNumber();
    }

    function receiveForIdo() public isRunning nonReentrant returns (bool) {
        if(swapOnlineTime == 0) {
            _status = _NOT_ENTERED;
            revert("Hammer: No amount available at the moment");
        }
        uint receiveNumber = computeReceiveIdoNumber();
        if(receiveNumber <= 0) {
            _status = _NOT_ENTERED;
            revert("Hammer: No amount available at the moment");
        }
        receiveIdoNumber[msg.sender] = receiveIdoNumber[msg.sender].add(receiveNumber);
        sellToken.transfer(msg.sender, receiveNumber);
        return true;
    }

    function computeReceiveIdoNumber() private view returns (uint number) {
        uint availableNumber = 0;
        uint secondsOfDay = 24 * 60 * 60;
        uint onlineDay = block.timestamp.sub(swapOnlineTime).div(secondsOfDay);
        uint totalNumber = buyIdoNumber[msg.sender].add(inviteReward[msg.sender]);
        if(receiveIdoNumber[msg.sender] >= totalNumber) {
            return availableNumber;
        }
        uint availableReceivePeriod = onlineDay.div(idoReceivePeriod).add(1);
        if(availableReceivePeriod >= 10) {
            availableNumber = totalNumber;
        } else {
            availableNumber = totalNumber.mul(10).div(100).mul(availableReceivePeriod);
        }
        if(receiveIdoNumber[msg.sender] < availableNumber) {
            return availableNumber.sub(receiveIdoNumber[msg.sender]);
        } else {
            return 0;
        }
    }

    function updateBuyNumberByArray(address [] memory addresses, uint [] memory buyNumbers) public onlyOwner {

        for(uint8 i=0; i<addresses.length; i++) {
            buyIdoNumber[addresses[i]] = buyNumbers[i];
        }

    }

    function updateRewardByArray(address [] memory addresses, uint [] memory rewards) public onlyOwner {

        for(uint8 i=0; i<addresses.length; i++) {
            inviteReward[addresses[i]] = rewards[i];
        }

    }

}