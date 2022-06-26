/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved); 
    function balanceOf(address owner) external view returns (uint256 balance);   
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC20 {
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract MineBlog {
    IERC20 token;
    IERC721 NFT;
    uint256 day = 24*60*60;
    constructor(address tokenAddress, address NFTAddress) {
        token = IERC20(tokenAddress);
        NFT = IERC721(NFTAddress);
    }

    struct Staker {
        uint256 amountStaked;
        uint256 lastClaim;
        uint256[] tokenIds;
    }

    mapping(address => Staker) public NFTM;
    
    function stake(uint256[] memory tokenId) public {
        for(uint256 i = 0; i < tokenId.length; i++) {
            require(NFT.getApproved(tokenId[i]) == address(this));
            NFT.transferFrom(msg.sender, address(this), tokenId[i]);
            NFTM[msg.sender].tokenIds.push(tokenId[i]);
        }
        
        if(NFTM[msg.sender].amountStaked > 0) {
            claimIn(msg.sender);
        } else {
            NFTM[msg.sender].lastClaim = block.timestamp;
        }
        NFTM[msg.sender].amountStaked += tokenId.length;
    }
    
    function claim() public {
        require(NFTM[msg.sender].amountStaked > 0);
        uint256 amountInSeconds = block.timestamp - NFTM[msg.sender].lastClaim;
        uint256 rewardMult = (100e18 / day) * amountInSeconds;
        uint256 rewards = (10000e18 * rewardMult / 100e18) * NFTM[msg.sender].amountStaked;
        NFTM[msg.sender].lastClaim = block.timestamp;
        token.transfer(msg.sender, rewards);
    }

    function claimIn(address user) internal {
        require(NFTM[user].amountStaked > 0);
        uint256 amountInSeconds = block.timestamp - NFTM[user].lastClaim;
        uint256 rewardMult = (100e18 / day) * amountInSeconds;
        uint256 rewards = (10000e18 * rewardMult / 100e18) * NFTM[user].amountStaked;
        NFTM[user].lastClaim = block.timestamp;
        token.transfer(user, rewards);
    }

    function unstake(uint256[] memory tokenId) public {
        require(NFTM[msg.sender].amountStaked >= tokenId.length);
        claimIn(msg.sender);
        uint256 staked = NFTM[msg.sender].amountStaked;
        for(uint256 i; i < tokenId.length; i++) {
            _unstake(tokenId[i]);
        }
        require(staked - NFTM[msg.sender].amountStaked == tokenId.length);
           
    }

    function _unstake(uint256 id) internal {
        for(uint256 i; i < NFTM[msg.sender].tokenIds.length; i++) {
            if(id == NFTM[msg.sender].tokenIds[i]) {
                if(NFTM[msg.sender].amountStaked == 1) {
                    NFTM[msg.sender].amountStaked = 0;
                    delete NFTM[msg.sender].tokenIds;
                }else
                    NFTM[msg.sender].amountStaked -= 1;
                if (NFTM[msg.sender].tokenIds.length > 0) {
                    NFTM[msg.sender].tokenIds[i] = NFTM[msg.sender].tokenIds[NFTM[msg.sender].tokenIds.length - 1];
                    NFTM[msg.sender].tokenIds.pop(); 
                }
                NFT.transferFrom(address(this), msg.sender, id);
            }
        }
    }

    function unstakeAll() public {
        uint256[] memory ids = NFTM[msg.sender].tokenIds;
        claimIn(msg.sender);
        NFTM[msg.sender].amountStaked = 0;
        delete NFTM[msg.sender].tokenIds;
        for(uint256 i; i < ids.length; i++) {
            NFT.transferFrom(address(this), msg.sender, ids[i]);
        }
    }
}