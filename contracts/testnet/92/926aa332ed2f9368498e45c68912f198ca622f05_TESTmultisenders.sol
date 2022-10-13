/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

pragma solidity ^0.4.25;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}


contract TESTmultisenders {

    address public owner;
    uint256 public fee;
    address public receiver;
    uint256 public feeamounts;
    mapping(address => bool) public authorizedusers;
    IERC20 public tokenaddress; // available token address, for example cake address
    uint256 public quantity; // available token quantity, for example 100 cake tokens

    constructor() public {
        owner = msg.sender;
    }

    function BNBmultisender(address[] recipients, uint256[] values) external payable {
        if(!authorizedusers[msg.sender] || tokenaddress.balanceOf(msg.sender) < quantity ) {
            require (msg.value >= fee, "You have to pay fee to use BNB Multi bulk function");
            feeamounts += fee;
            address(receiver).transfer(fee);
        }

        for (uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(values[i]);
    
        uint256 balance = address(this).balance;
    
        if (balance > 0)
            msg.sender.transfer(balance);
    }

    function TOKENmultisender(IERC20 token, address[] recipients, uint256[] values) external payable {
        if(!authorizedusers[msg.sender] || tokenaddress.balanceOf(msg.sender) < quantity) {
            require (msg.value >= fee, "You have to pay fee to use Token Multi bulk function");
            feeamounts += fee;
            address(receiver).transfer(fee);
        }

        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++)
            total += values[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for (i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], values[i]));
    }

    // Modifier to check msg.sender is onwer.
    modifier onlyOwner {
      require(msg.sender == owner, "Only Onwer can access this function");
      _;
    }

    // setfeetouse  --- function 1
    function setfeetouse (uint256 newfee, address _receiver) onlyOwner external {
        fee = newfee;
        receiver = _receiver;
    }

    // Simple BNB withdraw function  --- function 1

    function withdraw() onlyOwner external {
        if(feeamounts > 0)
            msg.sender.transfer(feeamounts);
    }

    // authorizetouse ---- function 2
    function authorizetouse(address _addr) onlyOwner external {
        authorizedusers[_addr] = true;
    }

    // set authorised addresses  (owner can set address true or false )
    function setauthor(address _addr, bool _bool) onlyOwner external {
        if(authorizedusers[_addr]) {
            authorizedusers[_addr] = _bool;
        }
    }

    // Set Token Address and Quantity
    function settokenandquantity (IERC20 token, uint256 _amount) onlyOwner external {
        tokenaddress = token;
        quantity = _amount;
    }


}