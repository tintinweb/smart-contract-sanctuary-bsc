/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-09
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
}

contract Modifier {
    address internal owner; // Constract creater
    bool public running = true;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
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

    function startStop() public onlyOwner returns (bool success) {
        if (running) { running = false; } else { running = true; }
        return true;
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

contract MobiusChainGas is Modifier {

    using SafeMath for uint256;
    uint256 private totalRecevied;

    mapping(address => uint256) private addressReceived;
    mapping(address => bool) private isGasLeaguer;

    ERC20 private mobToken;

    constructor() {
        mobToken = ERC20(0x9775C1CF4c0ACe8D52d533cD4badcdEab9E4340C);
    }

    function setTokenContract(address _mobToken) public onlyOwner {
        mobToken = ERC20(_mobToken);
    }

    function receiveAward() public isRunning nonReentrant returns (bool) {

        if(!isGasLeaguer[msg.sender]) {
            _status = _NOT_ENTERED;
            revert("Mobius: Not a member of the GAS");
        }

        uint256 totalAmount = mobToken.balanceOf(address(this)).add(totalRecevied);
        uint256 availableAward = totalAmount.div(24).sub(addressReceived[msg.sender]);
        if(availableAward <= 0) {
            _status = _NOT_ENTERED;
            revert("Mobius: No rewards currently available");
        }

        totalRecevied = totalRecevied.add(availableAward);
        addressReceived[msg.sender] = addressReceived[msg.sender].add(availableAward);

        mobToken.transfer(msg.sender, availableAward);

        return true;
    }

    function getAvailableAward(address _address) public view returns(uint256 availableAward) {
        uint256 totalAmount = mobToken.balanceOf(address(this)).add(totalRecevied);
        availableAward = totalAmount.div(24).sub(addressReceived[_address]);
    }

    function getAddressRecevied(address _address) public view returns(uint256) {
        return addressReceived[_address];
    }

    function getTotalRecevied() public view returns(uint256) {
        return totalRecevied;
    }

    function addGasLeaguer(address [] memory addressList) public onlyOwner {
        for(uint8 i=0; i<addressList.length; i++) {
            isGasLeaguer[addressList[i]] = true;
        }
    }

}