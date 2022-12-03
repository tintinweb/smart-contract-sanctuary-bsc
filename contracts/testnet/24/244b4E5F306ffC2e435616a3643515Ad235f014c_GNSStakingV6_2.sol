/**
 *Submitted for verification at polygonscan.com on 2022-08-16
*/

// File: contracts\interfaces\TokenInterfaceV5.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface TokenInterfaceV5{
    function burn(address, uint256) external;
    function mint(address, uint256) external;
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns(bool);
    function balanceOf(address) external view returns(uint256);
    function hasRole(bytes32, address) external view returns (bool);
    function approve(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
}

// File: contracts\interfaces\NftInterfaceV5.sol

pragma solidity 0.8.15;

interface NftInterfaceV5{
    function balanceOf(address) external view returns (uint);
    function ownerOf(uint) external view returns (address);
    function transferFrom(address, address, uint) external;
    function tokenOfOwnerByIndex(address, uint) external view returns(uint);
}

// File: contracts\GNSStakingV6_2.sol

pragma solidity 0.8.15;

contract GNSStakingV6_2 {

    // Contracts & Addresses
    address public govFund;

    TokenInterfaceV5 public immutable token; // GNS
    TokenInterfaceV5 public immutable dai;

    NftInterfaceV5[5] public nfts;

    // Pool state
    uint public accDaiPerToken;
    uint public tokenBalance;

    // Pool parameters
    uint[5] public boostsP;
    uint public maxNftsStaked;

    // Pool stats
    uint public totalRewardsDistributedDai; // 1e18

    // Mappings
    mapping(address => User) public users;
    mapping(address => mapping(uint => StakedNft)) public userNfts;

    // Structs
    struct StakedNft{
        uint nftId;
        uint nftType;
    }
    struct User{
        uint stakedTokens;        // 1e18
        uint debtDai;             // 1e18
        uint stakedNftsCount;
        uint totalBoostTokens;    // 1e18
        uint harvestedRewardsDai; // 1e18
    }

    // Events
    event GovFundUpdated(address value);
    event BoostsUpdated(uint[5] boosts);
    event MaxNftsStakedUpdated(uint value);

    event DaiDistributed(uint amount);

    event DaiHarvested(
        address indexed user,
        uint amount
    );

    event TokensStaked(
        address indexed user,
        uint amount
    );
    event TokensUnstaked(
        address indexed user,
        uint amount
    );

    event NftStaked(
        address indexed user,
        uint indexed nftType,
        uint nftId
    );
    event NftUnstaked(
        address indexed user,
        uint indexed nftType,
        uint nftId
    );

    constructor(
        address _govFund,
        TokenInterfaceV5 _token,
        TokenInterfaceV5 _dai,
        NftInterfaceV5[5] memory _nfts,
        uint[5] memory _boostsP,
        uint _maxNftsStaked
    ){
        require(_govFund != address(0)
        && address(_token) != address(0)
        && address(_dai) != address(0)
            && address(_nfts[4]) != address(0), "WRONG_PARAMS");

        checkBoostsP(_boostsP);

        govFund = _govFund;
        token = _token;
        dai = _dai;
        nfts = _nfts;

        boostsP = _boostsP;
        maxNftsStaked = _maxNftsStaked;

    }

    // Modifiers
    modifier onlyGov(){
        require(msg.sender == govFund, "GOV_ONLY");
        _;
    }
    modifier notContract(){
        require(tx.origin == msg.sender, "CONTRACT");
        _;
    }

    // Manage addresses
    function setGovFund(address value) external onlyGov{
        require(value != address(0), "ADDRESS_0");

        govFund = value;

        emit GovFundUpdated(value);
    }

    // Manage parameters
    function checkBoostsP(uint[5] memory value) public pure{
        require(value[0] < value[1] && value[1] < value[2]
        && value[2] < value[3] && value[3] < value[4],
            "WRONG_VALUES");
    }
    function setBoostsP(uint[5] memory value) external onlyGov{
        checkBoostsP(value);

        boostsP = value;

        emit BoostsUpdated(value);
    }
    function setMaxNftsStaked(uint value) external onlyGov{
        maxNftsStaked = value;

        emit MaxNftsStakedUpdated(value);
    }

    // Distribute rewards
    function distributeRewardDai(uint amount) external{
        dai.transferFrom(msg.sender, address(this), amount);

        if(tokenBalance > 0){
            accDaiPerToken += amount * 1e18 / tokenBalance;
            totalRewardsDistributedDai += amount;
        }

        emit DaiDistributed(amount);
    }

    // Compute user boosts
    function setBoosts() private{
        User storage u = users[msg.sender];

        u.totalBoostTokens = 0;

        for(uint i = 0; i < u.stakedNftsCount; i++){
            u.totalBoostTokens += u.stakedTokens
            * boostsP[userNfts[msg.sender][i].nftType - 1] / 100;
        }

        u.debtDai = (u.stakedTokens + u.totalBoostTokens) * accDaiPerToken / 1e18;
    }

    // Rewards to be harvested
    function pendingRewardDai() view public returns(uint){
        User storage u = users[msg.sender];

        return (u.stakedTokens + u.totalBoostTokens)
        * accDaiPerToken / 1e18 - u.debtDai;
    }

    // Harvest rewards
    function harvest() public{
        uint pendingDai = pendingRewardDai();

        User storage u = users[msg.sender];
        u.debtDai = (u.stakedTokens + u.totalBoostTokens) * accDaiPerToken / 1e18;
        u.harvestedRewardsDai += pendingDai;

        dai.transfer(msg.sender, pendingDai);

        emit DaiHarvested(msg.sender, pendingDai);
    }

    // Stake tokens
    function stakeTokens(uint amount) external{
        User storage u = users[msg.sender];

        token.transferFrom(msg.sender, address(this), amount);

        harvest();

        tokenBalance -= (u.stakedTokens + u.totalBoostTokens);

        u.stakedTokens += amount;
        setBoosts();

        tokenBalance += (u.stakedTokens + u.totalBoostTokens);

        emit TokensStaked(msg.sender, amount);
    }

    // Unstake tokens
    function unstakeTokens(uint amount) external{
        User storage u = users[msg.sender];

        harvest();

        tokenBalance -= (u.stakedTokens + u.totalBoostTokens);

        u.stakedTokens -= amount;
        setBoosts();

        tokenBalance += (u.stakedTokens + u.totalBoostTokens);

        token.transfer(msg.sender, amount);

        emit TokensUnstaked(msg.sender, amount);
    }

    // Stake NFT
    // NFT types: 1, 2, 3, 4, 5
    function stakeNft(uint nftType, uint nftId) external notContract{
        User storage u = users[msg.sender];

        require(u.stakedNftsCount < maxNftsStaked, "MAX_NFTS_ALREADY_STAKED");

        nfts[nftType - 1].transferFrom(msg.sender, address(this), nftId);

        harvest();

        tokenBalance -= (u.stakedTokens + u.totalBoostTokens);

        StakedNft storage stakedNft = userNfts[msg.sender][u.stakedNftsCount++];
        stakedNft.nftType = nftType;
        stakedNft.nftId = nftId;

        setBoosts();

        tokenBalance += (u.stakedTokens + u.totalBoostTokens);

        emit NftStaked(msg.sender, nftType, nftId);
    }

    // Unstake NFT
    function unstakeNft(uint nftIndex) external{
        User storage u = users[msg.sender];
        StakedNft memory stakedNft = userNfts[msg.sender][nftIndex];

        harvest();

        tokenBalance -= (u.stakedTokens + u.totalBoostTokens);

        userNfts[msg.sender][nftIndex] = userNfts[msg.sender][u.stakedNftsCount - 1];
        delete userNfts[msg.sender][(u.stakedNftsCount--) - 1];

        setBoosts();

        tokenBalance += (u.stakedTokens + u.totalBoostTokens);

        nfts[stakedNft.nftType - 1].transferFrom(address(this), msg.sender, stakedNft.nftId);

        emit NftUnstaked(msg.sender, stakedNft.nftType, stakedNft.nftId);
    }
}