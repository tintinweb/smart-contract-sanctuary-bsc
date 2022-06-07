/**
 *Submitted for verification at BscScan.com on 2022-06-07
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

contract LphSuperNode is Modifier {

    using SafeMath for uint;

    mapping(address => bool) private isJoinMapping;
    mapping(address => uint256) private joinIndex;

    address private receiveAddress;
    address [] private joinAddress;
    uint private nodeAmount;

    ERC20 private token;

    constructor() {
        nodeAmount = 150000000000000000000;
        receiveAddress = 0xFDBf7A90eB655ee15Ab8710d197FdB491AF7be27;
    }

    function setTokenContract(address _token) public onlyOwner {
        token = ERC20(_token);
    }

    function join() public isRunning nonReentrant returns (bool) {
        if(isJoinMapping[msg.sender]) {
            _status = _NOT_ENTERED;
            revert("Mobius: Limit exceeded");
        }
        isJoinMapping[msg.sender] = true;
        joinAddress.push(msg.sender);
        joinIndex[msg.sender] = joinAddress.length - 1;

        token.transferFrom(msg.sender, address(this), nodeAmount);
        token.transfer(receiveAddress, nodeAmount);

        return true;
    }

    function setReceiveAddress(address _address) public onlyOwner {
        receiveAddress = _address;
    }

    function getReceiveAddress() public view returns(address){
        return receiveAddress;
    }

    function setJoinAddress(address _address) public onlyOwner{
        if(isJoinMapping[_address]) {
            _status = _NOT_ENTERED;
            revert("Mobius: Limit exceeded");
        }
        isJoinMapping[_address] = true;
        joinAddress.push(_address);
        joinIndex[_address] = joinAddress.length - 1;
    }

 
    function removeJoinAddress(address _address) public onlyOwner {
        isJoinMapping[_address] = false;
        joinAddress[joinIndex[_address]] = joinAddress[joinAddress.length - 1];
        joinAddress.pop();
    }

   
    function setNodeAmount(uint amountToWei) public onlyOwner {
        nodeAmount = amountToWei;
    }

  

    function getAvailableQuota() public view returns(uint) {
        return joinAddress.length;
    }

    function getNodeAmount() public view returns(uint amountToWei) {
        amountToWei = nodeAmount;
    }

    function getJoinStatus() public view returns(bool) {
        return isJoinMapping[msg.sender];
    }

    function getJoinAddress() public view returns(address [] memory) {
       return joinAddress;
    }

}