/**
 *Submitted for verification at BscScan.com on 2022-05-23
*/

/**
 *Submitted for verification at hecoinfo.com on 2021-09-14
*/

/**

*/

pragma solidity ^0.4.26;
    contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
    owner = msg.sender;
    }
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
    }
    }
    contract Pausable is Ownable {
    event Pause();
    event Unpause();
    bool public paused = false;
    modifier whenNotPaused() {
    require(!paused);
    _;
    }
    modifier whenPaused() {
    require(paused);
    _;
    }
    function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
    }
    function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
    }
    }
    contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    }
    contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    contract Airdropper is Ownable {
    function multisend(address _tokenAddr, address[] dests, uint256[] values) public onlyOwner returns (uint256) {
    uint256 i = 0;
    while (i < dests.length) {
    ERC20(_tokenAddr).transferFrom(msg.sender, dests[i], values[i]);
    i += 1;
    }
    return(i);
    }
    }