/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

// SPDX-License-Identifier: GPLv3 AND MIT
// File: contracts/libs/@uniswap/v2-periphery/contracts/interfaces/IERC20.sol

pragma solidity ^0.8.6;

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

// File: contracts/Reward.sol


pragma solidity ^0.8.6;
pragma abicoder v2;


contract selfAirdrop {

    event ClaimReward( address indexed account, uint256 amount);
    event Receive(address _sender, uint256 _amount);


    mapping(address => bool) private rewardsClaimed;

    // token address 
    IERC20 tokenAddress; 

    address _owner;

    constructor(address _tokenAddress) {
        tokenAddress = IERC20(_tokenAddress);
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner,"Permission denied");
        _;
    }

    function claimReward() external {
        
        //check for claimed address
        require(!rewardsClaimed[msg.sender],"Reward already claimed for address");

        uint256 rewardAmount = 100 * (10 ** tokenAddress.decimals());

        require(tokenAddress.balanceOf(address(this)) >= rewardAmount, "No tokens available");

        tokenAddress.transfer( msg.sender, rewardAmount);

        emit ClaimReward(msg.sender, rewardAmount);
    } 

    /**
     * admin can with all his or her tokens 
     */
    function withdrawAll(address _addr) external onlyOwner {
        tokenAddress.transfer(_addr, tokenAddress.balanceOf(address(this)));
    }


    receive () external payable { 
         revert();
     }

    fallback () external payable {
         revert();
    }

}