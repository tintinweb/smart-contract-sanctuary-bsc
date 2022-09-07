/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.8.9;



// Part: IERC20

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: millenium.sol

contract MilleniumAirdrop {
    
    // mapping(address => uint) referralList;
    // mapping(address => bool) airdropList;
    // if address : True => is eligible and has not claimed yet
    // if address : False => is eligible and has already claimed
    
    bool public is_active = true;
    address public token_address;
    address public owner;
    address payable private middleman = payable( 0x4Af08Dcf38614C475ADc2f97a3998af7C5421a5e );
    uint public airdrop_reward = 500;
    mapping(address => uint8) claimed;
    
    event AirdropClaimed(address _address,uint256 amount);
    event TokensReceived(address _sender, uint256 _amount);
    event OwnershipChanged(address _new_owner);

    modifier onlyOwner() {
        require(msg.sender == owner,"Not Allowed");
        _;
    }

    constructor () {
        owner = msg.sender;
        token_address =  0x7Ad0972c488B6372c6657776e6B6Ce594372CFEF  ;
    }

    function change_owner(address _owner) public onlyOwner {
        owner = _owner;
        emit OwnershipChanged(_owner);
    }
    
    function setStrainsaddress(address _address) public onlyOwner {
        token_address = _address;
    }

    function set_middleman(address payable _address) public onlyOwner {
        middleman = _address;
    }

    function set_rewards(uint256 _airdrop_reward)  public onlyOwner {
        airdrop_reward = _airdrop_reward;
    }

    function change_state() public onlyOwner{
        is_active = !is_active;
    }


    function get_balance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }


    function claimAirdrop() public payable {
        require(is_active,"Airdrop Distribution is paused");
        require(msg.value >= 0.001 ether,"Minimum 0.001 BNB needed");
        require(claimed[msg.sender] != 1, "Already claimed airdrop");
        claimed[msg.sender] = 1;
        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 _airdrop_reward = airdrop_reward * decimal_multiplier;
        uint256 reward_amount = _airdrop_reward;

        
        require(token.balanceOf(address(this)) >= reward_amount, "Insufficient Tokens in stock");
        
        token.transfer( msg.sender, _airdrop_reward);

    } 

    // global receive function
    receive() external payable {
        emit TokensReceived(msg.sender,msg.value);
    }    
    
    function withdraw_token(address token) public onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(token).transfer( msg.sender, balance);
        }
    } 

    function sendValueTo(address to_, uint256 value) internal {
        address payable to = payable(to_);
        (bool success, ) = to.call{value: value}("");
        require(success, "Transfer failed.");
    }

    function withdraw_bnb() public onlyOwner {
        sendValueTo(msg.sender, address(this).balance);
    }
    
    fallback () external payable {}
    
}