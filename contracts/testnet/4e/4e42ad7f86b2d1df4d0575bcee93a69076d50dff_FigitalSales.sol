/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.8.9;

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

contract FigitalSales {
    
    // mapping(address => uint) referralList;
     mapping(address => bool) airdropList;
    
    bool public is_active = true;
    address public token_address;
    address public owner;
    address payable private middleman;
    uint public airdrop_reward = 100;
    uint256 public price = 0.000034 ether;
    
    event AirdropClaimed(address _address,uint256 amount);
    event TokensReceived(address _sender, uint256 _amount);
    event OwnershipChanged(address _new_owner);

    modifier onlyOwner() {
        require(msg.sender == owner,"Not Allowed");
        _;
    }

    constructor () {
        owner = msg.sender;
        // Figital Token Address
        token_address = 0x8E079bF887b3fFE8496CA14667B3b2FbE2eA650c;
    }

    function change_owner(address _owner) onlyOwner public {
        owner = _owner;
        emit OwnershipChanged(_owner);
    }
    
    function setTokenaddress(address _address) onlyOwner public {
        token_address = _address;
    }
    function changePrice(uint256 _price) onlyOwner public {
        price = _price;
    }

    function set_middleman(address payable _address) onlyOwner public {
        middleman = _address;
    }

    function set_rewards(uint256 _airdrop_reward) onlyOwner public {
        airdrop_reward = _airdrop_reward;
    }

    function change_state() onlyOwner public {
        is_active = !is_active;
    }


    function get_balance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }


    function claimAirdrop() public payable {
        require(is_active, "Airdrop Distribution is paused");
        require(airdropList[msg.sender], "You have already claimed your airdrop");
        
        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 _airdrop_reward = airdrop_reward * decimal_multiplier;
        
        require(token.balanceOf(address(this)) >= _airdrop_reward, "Insufficient Tokens in stock");
        
        token.transfer( msg.sender, _airdrop_reward);
        airdropList[msg.sender] = true;

    } 
    function buyFigital(uint256 amount) public payable {
        require(is_active, "SALES IS PAUSED");
        uint256 totalBought = (amount * price);
        require(msg.value >= totalBought);

        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 tokensBought = amount * decimal_multiplier;
        require(token.balanceOf(address(this)) >= tokensBought);

        token.transfer(msg.sender, tokensBought); 

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