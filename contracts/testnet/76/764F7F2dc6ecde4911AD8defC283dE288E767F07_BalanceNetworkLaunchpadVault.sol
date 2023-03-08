/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

pragma solidity ^0.8.0;

contract BalanceNetworkLaunchpadVault {
    
    address payable public owner; //contract owner's address
    address public tokenAddress; //ERC20 token contract address
    
    constructor() {
        owner = payable(msg.sender); //set contract owner as the deployer
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }
    
    function withdrawToken() public onlyOwner {
        require(msg.sender != owner, "Only token sender can withdraw the tokens");
        require(IERC20(tokenAddress).transfer(msg.sender, IERC20(tokenAddress).balanceOf(address(this))), "Token transfer failed");
    }
    
    receive() external payable {
        require(msg.sender != owner, "Owner cannot deposit tokens");
    }
    
    function withdrawEther() public onlyOwner {
        owner.transfer(address(this).balance);
    }
   function deposit(address tokenAddress , uint256 amount) public  {
        require(msg.sender != owner, "Owner cannot deposit tokens");
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
    }
    function depositBNB() public payable {
        require(msg.sender != owner, "Owner cannot deposit tokens");
    }

    
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function getTokenBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }
    
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}