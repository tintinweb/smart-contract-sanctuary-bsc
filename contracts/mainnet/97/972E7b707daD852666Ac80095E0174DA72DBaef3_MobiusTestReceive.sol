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
    function getInviter(address _address) external virtual view returns (address);
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

    /*
     * @dev wei convert
     * @param price
     * @param decimals
     */
    function toWei(uint price, uint decimals) public pure returns (uint){
        uint amount = price * (10 ** uint(decimals));
        return amount;
    }

}

contract MobiusTestReceive is Modifier, Util {

    using SafeMath for uint256;

    uint256 public usdtAmount;

    mapping(address => bool) private receiveStatus;
    mapping(address => uint256) private mobAmount;

    ERC20 private usdtToken;
    ERC20 private mobToken;

    constructor() {
        usdtAmount = toWei(5000, 18);
        usdtToken = ERC20(0x7F47B73afEe8ca4D3D89242EC64d8b24E4AB8815);
        mobToken = ERC20(0x9775C1CF4c0ACe8D52d533cD4badcdEab9E4340C);
    }

    function setTokenContract(address _usdtToken, address _mobToken) public onlyOwner {
        usdtToken = ERC20(_usdtToken);
        mobToken = ERC20(_mobToken);
    }

    function getReceiveStatus(address _address) public view returns(bool) {
        return receiveStatus[_address];
    }

    function receiveToken() public isRunning nonReentrant returns (bool) {
         if(receiveStatus[msg.sender]) {
            _status = _NOT_ENTERED;
            revert("Mobius: Received test coins");
        }
        
        receiveStatus[msg.sender] = true;

        bool flag = false;
        if(mobAmount[msg.sender] > 0) {
            mobToken.transfer(msg.sender, mobAmount[msg.sender].mul(25).div(100));
            mobAmount[msg.sender] = 0;
            flag = true;
        }


        if(flag || mobToken.getInviter(msg.sender) != address(0)) {
            usdtToken.transfer(msg.sender, usdtAmount);
        }

        return true;
    }

    function setTestAmount(address [] memory addressList, uint256 [] memory amountList) public onlyOwner {
        for(uint8 i=0; i<addressList.length; i++) {
            mobAmount[addressList[i]] = amountList[i];
        }
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}