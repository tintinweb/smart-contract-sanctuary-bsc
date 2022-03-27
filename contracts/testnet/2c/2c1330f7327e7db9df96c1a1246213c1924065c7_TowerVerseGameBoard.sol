/**
 *Submitted for verification at BscScan.com on 2022-03-26
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC721 {
    function balanceOf(address _owner) external view returns (uint256);
}

contract TowerVerseGameBoard {

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    address public owner;
    address public tokenAddress;
    address public nftAddress;

    uint256 public nftsRequiredToPlay;
    uint8 public numberOfLevels;
    uint256 public rewardPerStar;

    IERC20 private _tokenContract;
    IERC721 private _nftContract;

    mapping(address => uint8[16]) private scores;

    constructor() {
        owner = msg.sender;
        tokenAddress = 0xc880D1FA2AcFD2acAb04B8F34Cf0af5Ca2Fc19B6;
        nftAddress = 0xDdF03dAD5DB4684692778798cA766580E8490630;
        _tokenContract = IERC20(tokenAddress);
        _nftContract = IERC721(nftAddress);

        nftsRequiredToPlay = 0;
        rewardPerStar = 1 * 10 ** 18;
    }

    function claimRewards(uint8[] memory progress) external {  
        require(canPlay(msg.sender), "Play thresholds not reached");
        uint8 update;
        uint8 saved = getTotalStars(msg.sender);
        for (uint256 i = 0; i < progress.length; i++) {
            if (progress[i] <= 3) {
                update += progress[i];
                if (progress[i] > scores[msg.sender][i]) {
                    scores[msg.sender][i] = progress[i];
                }
            }
        }
        require (update <= 16 * 3, "Invalid data");

        if (saved < update) {
            uint8 newStars = update - saved;
            uint256 totalTokens = rewardPerStar * newStars;
            if (totalTokens > 0) {
                _tokenContract.transfer(msg.sender, totalTokens);
            }
        }
    }

    function playerStatus() public view returns (bool enabled, uint8 totalStars) {
        enabled = canPlay(msg.sender);
        totalStars = getTotalStars(msg.sender);
    }

    // Admin Methods
    function changeOwner(address who) external onlyOwner {
        require(who != address(0), "cannot be zero address");
        owner = who;
    }

    function updateNftsToPlay(uint256 nftThreshold) external onlyOwner
    {
        nftsRequiredToPlay = nftThreshold;
    }

    function updateRewardsPerstar(uint256 reward) external onlyOwner
    {
        rewardPerStar = reward;
    }

    function updateNftContract(address contractAddress) external onlyOwner {
        nftAddress = contractAddress;
        _nftContract = IERC721(nftAddress);
    }

    function updateTokenContract(address contractAddress) external onlyOwner {
        tokenAddress = contractAddress;
        _tokenContract = IERC20(tokenAddress);
    }

    function removeNative() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function transferTokens(address token, address to) external onlyOwner returns(bool){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return IERC20(token).transfer(to, balance);
    }


    // Private Methods
    function canPlay(address who) private view returns (bool) {
        uint256 nftCount = _nftContract.balanceOf(who);
        return nftCount >= nftsRequiredToPlay;
    }

    function getTotalStars(address who) private view returns (uint8 totalStars) {
        for (uint256 i = 0; i < scores[who].length; i++) {
            totalStars += scores[who][i];
        }
    }

}