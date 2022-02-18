/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;


interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function decimals() external view returns (uint8);
}

interface IERC721 {
    function balanceOf(address _owner) external view returns (uint256);
}


library LightweightsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
}


contract ScoreBoard {
    using LightweightsDateTimeLibrary for uint256;

    struct Day {
        Score[] allScores;
        mapping(address => uint256[]) playerScores;
    }

    struct Score {
        uint256 timestamp;
        address who;
        string initials;
        uint256 score;
    }

    struct DisplayScore {
        string initials;
        uint256 score;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "can only be called by the contract owner");
        _;
    }

    address public owner;
    address public tokenAddress;
    address public nftAddress;
    uint8 public tokenDecimals;

    uint256 public nftTier0Threshold;
    uint256 public nftTier1Threshold;
    uint256 public nftTier2Threshold;
    uint256 public nftTier3Threshold;
    uint256 public tokenTier0Threshold;
    uint256 public tokenTier1Threshold;
    uint256 public tokenTier2Threshold;
    uint256 public tokenTier3Threshold;

    uint256 public tier0Plays = 2**256 - 1;
    uint256 public tier1Plays = 30;
    uint256 public tier2Plays = 20;
    uint256 public tier3Plays = 10;
    uint256 public freePlays = 0;

    IERC20 private _tokenContract;
    IERC721 private _nftContract;

    mapping(uint256 => mapping(uint256 => mapping(uint256 => Day))) private scores;

    constructor() {
        owner = msg.sender;
        tokenAddress = 0x05019E26ad3ef8A964d34caBcF92fC935452D154;
        nftAddress = 0xDdF03dAD5DB4684692778798cA766580E8490630;
        _tokenContract = IERC20(tokenAddress);
        _nftContract = IERC721(nftAddress);
        tokenDecimals = _tokenContract.decimals();

        nftTier0Threshold = 4;
        nftTier1Threshold = 3;
        nftTier2Threshold = 2;
        nftTier3Threshold = 1;
        tokenTier0Threshold = 1_000_000 * 10 ** tokenDecimals;
        tokenTier1Threshold = 300_000 * 10 ** tokenDecimals;
        tokenTier2Threshold = 200_000 * 10 ** tokenDecimals;
        tokenTier3Threshold = 100_000 * 10 ** tokenDecimals;
    }

    function submitScores(string memory initials, uint256[] memory score) external {
        (uint256 year, uint256 month, uint256 day, uint256 gamesAllowed,) = playerStatus();
        for (uint256 i = 0; i < score.length; i++) {
            if (scores[year][month][day].playerScores[msg.sender].length >= gamesAllowed) {
                return;
            }
            scores[year][month][day].allScores.push(Score(block.timestamp, msg.sender, initials, score[i]));
            scores[year][month][day].playerScores[msg.sender].push(score[i]);
        }
    }

    function playerStatus() public view returns (uint256 year, uint256 month, uint256 day, uint256 gamesAllowed, uint256 gamesPlayed) {
        (year, month, day) = block.timestamp.timestampToDate();
        gamesAllowed = getAllowedGames();
        gamesPlayed = scores[year][month][day].playerScores[msg.sender].length;
    }

    function getTodaysScores() external view returns (uint256 year, uint256 month, uint256 day, DisplayScore[] memory scoreboard) {
        (year, month, day) = block.timestamp.timestampToDate();
        DisplayScore[] memory s = new DisplayScore[](scores[year][month][day].allScores.length);

        for (uint256 i = 0; i < scores[year][month][day].allScores.length; i ++) {
            s[i] = DisplayScore(scores[year][month][day].allScores[i].initials, scores[year][month][day].allScores[i].score);
        }

        return (year, month, day, s);
    }


    // Admin Methods

    function updateThresholdAndPlays(uint8 tier, uint256 nftThreshold, uint256 tokenThreshold, uint256 numberOfPlays) external onlyOwner
    {
        if (tier == 0) {
            nftTier0Threshold = nftThreshold;
            tokenTier0Threshold = tokenThreshold;
            tier0Plays = numberOfPlays;
        } else if (tier == 1) {
            nftTier1Threshold = nftThreshold;
            tokenTier1Threshold = tokenThreshold;
            tier1Plays = numberOfPlays;
        } else if (tier == 2) {
            nftTier2Threshold = nftThreshold;
            tokenTier2Threshold = tokenThreshold;
            tier2Plays = numberOfPlays;
        } else if (tier == 3) {
            nftTier3Threshold = nftThreshold;
            tokenTier3Threshold = tokenThreshold;
            tier3Plays = numberOfPlays;
        } else {
            revert("Invalid tier");
        }
    }

    function updateFreePlays(uint256 numberOfPlays) external onlyOwner
    {
        freePlays = numberOfPlays;
    }

    function updateNftContract(address contractAddress) external onlyOwner {
        nftAddress = contractAddress;
        _nftContract = IERC721(nftAddress);
    }

    function updateTokenContract(address contractAddress) external onlyOwner {
        tokenAddress = contractAddress;
        _tokenContract = IERC20(tokenAddress);
        tokenDecimals = _tokenContract.decimals();
    }


    // Private Methods

    function getAllowedGames() private view returns (uint256) {
        uint256 nftCount = _nftContract.balanceOf(msg.sender);
        uint256 tokenCount = _tokenContract.balanceOf(msg.sender);

        if (nftCount >= nftTier0Threshold || tokenCount >= tokenTier0Threshold) {
            return tier0Plays;
        }

        if (nftCount >= nftTier1Threshold || tokenCount >= tokenTier1Threshold) {
            return tier1Plays;
        }

        if (nftCount >= nftTier2Threshold || tokenCount >= tokenTier2Threshold) {
            return tier2Plays;
        }

        if (nftCount >= nftTier3Threshold || tokenCount >= tokenTier3Threshold) {
            return tier3Plays;
        }

        return freePlays;
    }
}