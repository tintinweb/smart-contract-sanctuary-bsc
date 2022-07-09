// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// July 9th, 2022
// https://slamtoken.com
// Made for SLAM token to be used with external token contracts" by @Kadabra_SLAM (Telegram)

import "library.sol";

interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract DepositsSLAM is Ownable, ReentrancyGuard {    
    function allowanceToken(address _tokenContract, uint256 _amount, address _spender) external nonReentrant onlyOwner{
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.approve(_spender, _amount);
    }

    function withdraw() external nonReentrant onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // To get any tokens out of the contract if needed
    function withdrawNFT(address _nftTokenContract, address _to) external nonReentrant onlyOwner{
        IERC721 nftTokenContract = IERC721(_nftTokenContract);
        nftTokenContract.setApprovalForAll(_to, true);
    }

    function withdrawToken(address _tokenContract, uint256 _amount, address _to) external nonReentrant onlyOwner{
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(_to, _amount);
    }

    function withdrawToken_All(address _tokenContract, address _to) external nonReentrant onlyOwner{
        IERC20 tokenContract = IERC20(_tokenContract);
        uint256 _amount = tokenContract.balanceOf(address(this));
        tokenContract.transfer(_to, _amount);
    }
}