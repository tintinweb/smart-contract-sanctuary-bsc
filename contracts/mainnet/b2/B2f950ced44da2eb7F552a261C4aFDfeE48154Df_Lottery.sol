/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

contract Lottery is Auth {

    using SafeMath for uint256;
    address public manager;
    address payable[] public players;
    address public charity;
    uint256 minPay;
    uint256 ticketsSold;
   // uint256 share;

    mapping (address => uint256) private tickets;

    constructor () Auth(0xD3b35843153748eDCcd112A1B2ae26c56D8e6200) {       
        charity = 0x74380FEEcD92b6936d82E2A42B277B71a9B1D284;
        minPay = 25*10**15 wei; //0.025 ether
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > minPay); //1 ether = 1,000,000,000,000,000,000 -> 1*10**18 wei = 1 ether
        players.push(payable(msg.sender));
        ticketsSold++;
    }

    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function changeMin(uint256 newMin) external onlyOwner {
        minPay = newMin;
    }

    //manual
    function pickWinner() external authorized {
        uint index = random() % players.length;
        (bool w, ) = payable(charity).call{value: address(this).balance * 20 / 100}(""); //20% charity
        require(w);
        (bool c, ) = payable(players[index]).call{value: address(this).balance}(""); //80% winner
        require(c);
        players = new address payable[](0);

    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function balanceBNB() public view returns (uint256) {
        return address(this).balance;
    }
}