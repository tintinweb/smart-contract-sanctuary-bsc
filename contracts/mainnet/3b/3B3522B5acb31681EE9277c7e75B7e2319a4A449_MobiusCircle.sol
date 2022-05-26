/**
 *Submitted for verification at BscScan.com on 2022-05-26
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

abstract contract MobToken {
    function queryThisToUsdtPrice() external virtual view returns (uint256);
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

    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

}

contract MobiusCircle is Modifier, Util {

    using SafeMath for uint256;

    uint256 private historyTotalPower;
    uint256 private networkPower;

    uint256 private joinLimit;
    uint256 private minePoolRatio;

    uint256 private lastOutputTime;
    uint256 private maxOutput;
    uint256 private limitOutputTime = 24 * 60 * 60;

    address private deflationPoolAddress;
    address private mineWithdrawAddress;

    mapping(uint256 => mapping(address => uint256)) private blockPowerMapping;
    mapping(address => bool) minerMapping;
    mapping(address => uint256) addressPower;
    mapping(address => bool) approveMapping;

    ERC20 private mobToken;

    constructor() {

        joinLimit = 100000000000000000000;
        minePoolRatio = 98;

        lastOutputTime = block.timestamp;
        maxOutput = 10000000000000000000000;
        mobToken = ERC20(0x9775C1CF4c0ACe8D52d533cD4badcdEab9E4340C);
    }

    function setMobToken(address _token) public onlyOwner {
        mobToken = ERC20(_token);
    }

    function setDeflationPoolAddress(address _address) public onlyOwner {
        deflationPoolAddress = _address;
    }

    function setMineWithdrawAddress(address _address) public onlyOwner {
        mineWithdrawAddress = _address;
    }

    function setJoinLimit(uint256 _joinLimit) public onlyOwner {
        joinLimit = _joinLimit;
    }

    function setMinePoolRatio(uint256 ratio) public onlyOwner {
        minePoolRatio = ratio;
    }

    function setAllowMining(address _address, bool canMining) public onlyOwner {
        minerMapping[_address] = canMining;
    }

    function isAllowMining(address _address) public view returns (bool) {
        return minerMapping[_address];
    }

    function join(uint256 amountToWei) public isRunning nonReentrant returns (bool) {
        uint256 price = MobToken(address(mobToken)).queryThisToUsdtPrice();
        uint256 joinAmount = backWei(amountToWei, 18).mul(price);
        if(joinAmount < joinLimit) {
            _status = _NOT_ENTERED;
            revert("Mobius: The join number is less than the limit");
        }

        mobToken.transferFrom(msg.sender, address(this), amountToWei);

        uint256 power = joinAmount.mul(3);

        historyTotalPower = historyTotalPower.add(power);
        networkPower = networkPower.add(power);

        blockPowerMapping[block.number][msg.sender] = power;
        addressPower[msg.sender] = addressPower[msg.sender].add(power);

        uint256 minePoolAmount = amountToWei.mul(minePoolRatio).div(100);
        uint256 deflationPoolAmount = amountToWei.sub(minePoolAmount);
        
        mobToken.transfer(deflationPoolAddress, deflationPoolAmount);

        return true;
    }

    function transferJoin(address joinAddress, uint256 amountToWei) public returns (bool) {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");
        uint256 price = MobToken(address(mobToken)).queryThisToUsdtPrice();
        uint256 power = backWei(amountToWei, 18).mul(price).mul(3);
        historyTotalPower = historyTotalPower.add(power);
        networkPower = networkPower.add(power);
        blockPowerMapping[block.number][joinAddress] = power;
        addressPower[joinAddress] = addressPower[joinAddress].add(power);
        return true;
    }

    function getBlockPower(uint _number, address _address) public view returns(uint256 power) {
        return blockPowerMapping[_number][_address];
    }

    function getAddressPower(address _address) public view returns(uint256 power) {
        return addressPower[_address];
    }

    function setApproveStatus(address _address, bool _status) public onlyOwner {
        approveMapping[_address] = _status;
    }

    function isApproveAddress(address _address) public view returns (bool) {
        return approveMapping[_address];
    }

    function dailyOutput() public isRunning returns(bool) {
        require(approveMapping[msg.sender], "Mobius: The caller is not the approveAddress");
        uint256 intervalTime = block.timestamp.sub(lastOutputTime);
        if(intervalTime >= limitOutputTime) {
            lastOutputTime = block.timestamp;
            mobToken.transfer(mineWithdrawAddress, maxOutput);
        }

        return true;
    }

    function setAddressPower(address [] memory addressList, uint256 [] memory powerList) public onlyOwner {
        for(uint8 i=0; i<addressList.length; i++) {
            addressPower[addressList[i]] = powerList[i];
        }
    }

    

}