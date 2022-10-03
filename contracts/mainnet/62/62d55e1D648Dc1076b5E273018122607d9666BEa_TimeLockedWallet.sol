/**
 *Submitted for verification at BscScan.com on 2022-10-03
*/

pragma solidity ^0.8.0;
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TimeLockedWallet {
    address public owner;
    uint256 public unlockDate;
    uint256 public createdAt;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(
        uint256 _unlockPeriod
    ) public {
        owner = msg.sender;
        unlockDate = block.timestamp + _unlockPeriod;
        createdAt = block.timestamp;
    }

    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawTokens(address _tokenContract) onlyOwner public {
       require(block.timestamp >= unlockDate, "Not yet!");
     
       //now send all the token balance
       uint256 tokenBalance = IBEP20(_tokenContract).balanceOf(address(this));
       IBEP20(_tokenContract).transfer(owner, tokenBalance);
       emit WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }
    function changeOwner(address _newOwner) onlyOwner public {
      owner = _newOwner;
    }
    function info(address _tokenContract) public view returns( address, uint256, uint256, uint256) {
        return (owner, unlockDate, createdAt, IBEP20(_tokenContract).balanceOf(address(this)));
    }

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);
}