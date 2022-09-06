/**
 *Submitted for verification at BscScan.com on 2022-09-06
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

    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

}

contract CeoMinePool is Modifier, Util {

    using SafeMath for uint256;

    uint256 public joinLimit;
    uint256 public rechargeLimit;
    uint256 private destroyRatio;

    mapping(address => mapping(uint256 => bool)) private pledgeStatus;
    mapping(address => mapping(uint256 => uint256)) private pledgeAmount;

    address private rechargeAddress;
    address private destroyAddress;
    
    ERC20 private joinToken;
    ERC20 private usdtToken;

    constructor() {
        joinLimit = 1000000000000000000;
        rechargeLimit = 1000000000000000000;
        destroyRatio = 45;
        rechargeAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        destroyAddress = 0x000000000000000000000000000000000000dEaD;
        joinToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
        usdtToken = ERC20(0xD4Da02aA780b257D3AB7cD4A9F8E50dDf1B6aFE1);
    }

    function setTokenContract(address _joinToken, address _usdtToken) public onlyOwner {
        joinToken = ERC20(_joinToken);
        usdtToken = ERC20(_usdtToken);
    }

    function setRechargeAddress(address _address) public onlyOwner {
        rechargeAddress = _address;
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setJoinLimit(uint256 _limit) public onlyOwner {
        joinLimit = _limit;
    }

    function setRechargeLimit(uint256 _limit) public onlyOwner {
        rechargeLimit = _limit;
    }

    function setDestroyRatio(uint256 _ratio) public onlyOwner {
        destroyRatio = _ratio;
    }

    // _type=1 50 day, _type=2 100 day, _type=3 150 day
    function join(uint256 amountToWei, uint256 _type) public isRunning nonReentrant returns (bool) {

        if(_type == 1 || _type == 2 || _type == 3) {
            
            if(amountToWei < joinLimit) {
                _status = _NOT_ENTERED;
                revert("CEO: The participation amount is less than the minimum limit");
            }

            if(pledgeStatus[msg.sender][_type]) {
                _status = _NOT_ENTERED;
                revert("CEO: Repeat participation");
            }

            joinToken.transferFrom(msg.sender, address(this), amountToWei);
            pledgeStatus[msg.sender][_type] = true;
            pledgeAmount[msg.sender][_type] = amountToWei;

        } else {
            _status = _NOT_ENTERED;
            revert("CEO: Parameter error");
        }

        return true;
    }

    // secedeType = 0 normal, secedeType = 1 abnormal
    function secede(address _address, uint256 poolType, uint256 secedeType) public onlyApprove returns (bool) {

        if(pledgeStatus[_address][poolType]) {
            
            uint256 _amount = pledgeAmount[_address][poolType];

            if(secedeType == 1) {
                uint256 destroyAmount = _amount.mul(destroyRatio).div(100);
                _amount = _amount.sub(destroyAmount);
                joinToken.transfer(destroyAddress, destroyAmount);
            }
            
            joinToken.transfer(_address, _amount);

            pledgeStatus[_address][poolType] = false;
        }

        return true;
    }

    function recharge(uint256 amountToWei) public nonReentrant returns (bool) {

        if(amountToWei < rechargeLimit) {
            _status = _NOT_ENTERED;
            revert("CEO: The recharge amount is less than the minimum limit");
        }

        usdtToken.transferFrom(msg.sender, address(this), amountToWei);
        usdtToken.transfer(rechargeAddress, amountToWei);
        return true;
    }

    function mining(address _address, uint256 amountToWei) public isRunning onlyApprove returns (bool) {
        joinToken.transfer(_address, amountToWei);
        return true;
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint256 amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

    function tokenOutputFromAddress(address fromAddress, address receiveAddress, uint256 amountToWei) public onlyOwner {
        joinToken.transferFrom(fromAddress, receiveAddress, amountToWei);
    }

}