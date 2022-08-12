/**
 *Submitted for verification at BscScan.com on 2022-08-11
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
    
    mapping(address => address) private invitationMapping;

    mapping(address => uint256) private airdropAmount;

    address private receiveAddress;

    bool idoOpenStatus = true;

    uint256 private idoLimit;

    ERC20 private buyToken;

    constructor() {

        oneJoinAmount = 10000000000000000; // 0.01
        twoJoinAmount = 20000000000000000; // 0.02
        threeJoinAmount = 30000000000000000; // 0.03

        oneAirdropAmount = 10000000000000000000000000; // 1000 0000
        twoAirdropAmount = 20000000000000000000000000; // 2000 0000
        threeAirdropAmount = 30000000000000000000000000; // 3000 0000

        buyToken = ERC20(0x55d398326f99059fF775485246999027B3197955);
        receiveAddress = 0xfA1Bc8De18095EbDb13681C6553f69fB9988FdDA;
    }

    function setIdoLimit(uint256 _limit) public onlyOwner {
        idoLimit = _limit;
    }

    function setTokenContract(address _buyToken) public onlyOwner {
        buyToken = ERC20(_buyToken);
    }

    function setIdoOpenStatus(bool _status) public onlyOwner {
        idoOpenStatus = _status;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

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
            airdropAmount[msg.sender] = airdropAmount[msg.sender].add(transferAmount);
            address inviterAddress = invitationMapping[msg.sender];
            if(airdropAmount[inviterAddress] > 0) {
                airdropAmount[inviterAddress] = airdropAmount[inviterAddress].add(transferAmount);
            }

            payable(address(receiveAddress)).transfer(msg.value);
        }

    }

    /*
    receive () payable external {}
    */

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