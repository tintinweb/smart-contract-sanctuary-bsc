/**
 *Submitted for verification at BscScan.com on 2022-08-23
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

contract MobiusDaoProposal is Modifier, Util {

    using SafeMath for uint256;

    uint256 [] proposalIds;
    mapping(uint256 => uint256) private supportVote;
    mapping(uint256 => uint256) private opposeVote;
    mapping(address => bool) private followStatus;
    mapping(uint256 => bool) private feedbackStatus;

    uint256 public proposalAmount;
    address private poolAddress;

    ERC20 private mobToken;

    constructor() {
        proposalAmount = 50000000000000000000;
        poolAddress = 0xAE6c148Ce7D5a059c67C468F96F4F03E8Ae4f3DD;
        mobToken = ERC20(0x1365a1069C4cd570093396Dc92502315747d95bF);
    }

    function setProposalAmount(uint256 _amount) public onlyOwner {
        proposalAmount = _amount;
    }

    function setPoolAddress(address _address) public onlyOwner {
        poolAddress = _address;
    }

    function proposal(uint256 proposalId) public isRunning returns (bool) {
        mobToken.transferFrom(msg.sender, address(this), proposalAmount);
        mobToken.transfer(poolAddress, proposalAmount);
        proposalIds.push(proposalId);
        return true;
    }

    function support(uint256 proposalId, uint256 voteCount) public isRunning returns (bool) {
        supportVote[proposalId] = supportVote[proposalId].add(voteCount);
        return true;
    }

    function oppose(uint256 proposalId, uint256 voteCount) public isRunning returns (bool) {
        opposeVote[proposalId] = opposeVote[proposalId].add(voteCount);
        return true;
    }

    function updateFollowStatus(bool _status) public isRunning returns (bool) {
        followStatus[msg.sender] = _status;
        return true;
    }

    function feedback(uint256 proposalId) public isRunning returns (bool) {
        feedbackStatus[proposalId] = true;
        return true;
    }

    function getAllProposal() public view returns(uint256 [] memory) {
       return proposalIds;
    }

    function getSupportVote(uint256 proposalId) public view returns(uint256) {
       return supportVote[proposalId];
    }

    function getOpposeVote(uint256 proposalId) public view returns(uint256) {
       return opposeVote[proposalId];
    }

    function getFollowStatus(address _address) public view returns(bool) {
       return followStatus[_address];
    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint256 amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}