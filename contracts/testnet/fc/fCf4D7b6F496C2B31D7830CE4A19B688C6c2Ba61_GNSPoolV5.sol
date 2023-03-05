/**
 *Submitted for verification at polygonscan.com on 2021-10-27
*/

// File: contracts\interfaces\TokenInterfaceV5.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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

// File: contracts\interfaces\LpInterfaceV5.sol

pragma solidity 0.8.7;

interface LpInterfaceV5{
    function getReserves() external view returns (uint112, uint112, uint32);
    function token0() external view returns (address);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint256) external;
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address, uint256) external returns (bool);
}

// File: contracts\interfaces\NftInterfaceV5.sol

pragma solidity 0.8.7;

interface NftInterfaceV5{
    function balanceOf(address) external view returns (uint);
    function ownerOf(uint) external view returns (address);
    function transferFrom(address, address, uint) external;
    function tokenOfOwnerByIndex(address, uint) external view returns(uint);
}

// File: contracts\GNSPoolV5.sol

pragma solidity 0.8.7;
contract GNSPoolV5{

    // Constants
    bytes32 public constant MINTER_ROLE = 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;

    // Contracts & Addresses
    TokenInterfaceV5 public token; // DEXY
    LpInterfaceV5 public lp; // DEXY/DAI
    address public govFund;

    // Pool variables
    uint public accTokensPerLp;
    uint public lpBalance;

    // Pool parameters
    uint public maxNftsStaked = 3;
    uint public referralP = 6; // % 2 == 0
    uint[5] public boostsP = [2, 3, 5, 8, 13];

    // Pool stats
    uint public rewardsToken; // 1e18

    // Mappings
    mapping(address => User) public users;
    mapping(address => mapping(uint => StakedNft)) public userNfts;
    mapping(address => bool) public allowedContracts;

    NftInterfaceV5[5] public nfts = [
    NftInterfaceV5(0x0000000000000000000000000000000000000001),
    NftInterfaceV5(0x0000000000000000000000000000000000000001),
    NftInterfaceV5(0x0000000000000000000000000000000000000001),
    NftInterfaceV5(0x0000000000000000000000000000000000000001),
    NftInterfaceV5(0x0000000000000000000000000000000000000001)
    ];

    // Structs
    struct StakedNft{
        uint nftId;
        uint nftType;
    }
    struct User{
        uint provided;
        uint debtToken;
        uint stakedNftsCount;
        uint totalBoost;
        address referral;
        uint referralRewardsToken;
    }

    // Events
    event AddressUpdated(string name, address a);
    event ContractAllowed(address a, bool allowed);
    event BoostsUpdated(uint[5]);
    event NumberUpdated(string name, uint value);
    event NftsUpdated(NftInterfaceV5[5] nfts);

    constructor(address _tradingStorage){
        require(_tradingStorage != address(0), "ADDRESS_0");
        allowedContracts[_tradingStorage] = true;
        govFund = msg.sender;
    }

    // GOV => UPDATE VARIABLES & MANAGE PAIRS

    // 0. Modifiers
    modifier onlyGov(){
        require(msg.sender == govFund, "GOV_ONLY");
        _;
    }

    // Set addresses
    function setGovFund(address _gov) external onlyGov{
        require(_gov != address(0), "ADDRESS_0");
        govFund = _gov;
        emit AddressUpdated("govFund", _gov);
    }

    function setToken(TokenInterfaceV5 _token) external onlyGov{
        require(address(_token) != address(0), "ADDRESS_0");
        require(address(token) == address(0), "ALREADY_SET");
        token = _token;
        emit AddressUpdated("token", address(_token));
    }

    function setLp(LpInterfaceV5 _lp) external onlyGov{
        require(address(_lp) != address(0), "ADDRESS_0");
        require(address(lp) == address(0), "ALREADY_SET");
        lp = _lp;
        emit AddressUpdated("lp", address(_lp));
    }

    function addAllowedContract(address c) external onlyGov{
        require(c != address(0), "ADDRESS_0");
        require(token.hasRole(MINTER_ROLE, c), "NOT_MINTER");
        allowedContracts[c] = true;
        emit ContractAllowed(c, true);
    }
    function removeAllowedContract(address c) external onlyGov{
        require(c != address(0), "ADDRESS_0");
        allowedContracts[c] = false;
        emit ContractAllowed(c, false);
    }
    function setBoostsP(uint _bronze, uint _silver, uint _gold, uint _platinum, uint _diamond) external onlyGov{
        require(_bronze < _silver && _silver < _gold && _gold < _platinum && _platinum < _diamond && _bronze > 0, "WRONG_VALUES");
        boostsP = [_bronze, _silver, _gold, _platinum, _diamond];
        emit BoostsUpdated(boostsP);
    }
    function setMaxNftsStaked(uint _maxNftsStaked) external onlyGov{
        require(_maxNftsStaked >= 3, "BELOW_3");
        maxNftsStaked = _maxNftsStaked;
        emit NumberUpdated("maxNftsStaked", _maxNftsStaked);
    }
    function setReferralP(uint _referralP) external onlyGov{
        require(_referralP % 2 == 0, "NOT_EVEN");
        referralP = _referralP;
        emit NumberUpdated("referralP", _referralP);
    }

    function setNfts(NftInterfaceV5[5] memory _nfts) external onlyGov{
        require(address(_nfts[0]) != address(0));
        nfts = _nfts;
        emit NftsUpdated(_nfts);
    }

    // USEFUL FUNCTIONS

    // Remove access to contracts
    modifier notContract(){
        require(tx.origin == msg.sender, "CONTRACT");
        _;
    }

    // Get reserves LP
    function reservesLp() public view returns(uint, uint){
        (uint112 reserves0, uint112 reserves1, ) = lp.getReserves();
        return lp.token0() == address(token) ? (reserves0, reserves1) : (reserves1, reserves0);
    }

    function increaseAccTokensPerLp(uint _amount) external{
        require(allowedContracts[msg.sender] && token.hasRole(MINTER_ROLE, msg.sender), "ONLY_ALLOWED_CONTRACTS");
        if(lpBalance > 0){
            accTokensPerLp += _amount * 1e18 / lpBalance;
            rewardsToken += _amount;
        }
    }

    // Compute NFT boosts
    function setBoosts() private{
        User storage u = users[msg.sender];
        u.totalBoost = 0;
        for(uint i = 0; i < u.stakedNftsCount; i++){
            u.totalBoost += u.provided * boostsP[userNfts[msg.sender][i].nftType-1] / 100;
        }
        u.debtToken = (u.provided + u.totalBoost) * accTokensPerLp / 1e18;
    }

    // Rewards to be harvested
    function pendingRewardToken() view public returns(uint){
        User storage u = users[msg.sender];
        return (u.provided + u.totalBoost) * accTokensPerLp / 1e18 - u.debtToken;
    }

    // EXTERNAL FUNCTIONS

    // Harvest rewards
    function harvest() public{
        if(lpBalance == 0){ return; }

        User storage u = users[msg.sender];

        uint pendingTokens = pendingRewardToken();

        if(pendingTokens > 0){
            if(u.referral == address(0)){
                token.mint(msg.sender, pendingTokens - pendingTokens * referralP / 100); //94
            }else{
                uint referralReward = pendingTokens * referralP / 200;

                token.mint(msg.sender, pendingTokens - referralReward); //97
                token.mint(u.referral, referralReward);//3

                users[u.referral].referralRewardsToken += referralReward;
            }
        }

        u.debtToken = (u.provided + u.totalBoost) * accTokensPerLp / 1e18;
    }

    // Stake LPs
    function stake(uint amount, address referral) external{
        User storage u = users[msg.sender];

        // 1. Transfer the LPs to the contract
        lp.transferFrom(msg.sender, address(this), amount);

        // 2. Harvest pending rewards
        harvest();

        // 3. Reset lp balance
        lpBalance -= (u.provided + u.totalBoost);

        // 4. Set user provided
        u.provided += amount;

        // 5. Set boosts and debt
        setBoosts();

        // 6. Update lp balance
        lpBalance += (u.provided + u.totalBoost);

        // 7. Set referral
        if(u.referral == address(0) && referral != address(0) && referral != msg.sender){
            u.referral = referral;
        }
    }

    // Stake NFT
    // NFT types: 1, 2, 3, 4, 5
    function stakeNft(uint nftType, uint nftId) external notContract{
        User storage u = users[msg.sender];

        // 0. If didn't already stake NFT + nft type is either platinum or diamond
        require(u.stakedNftsCount < maxNftsStaked, "MAX_NFTS_ALREADY_STAKED");
        require(nftType >= 1 && nftType <= 5, "WRONG_NFT_TYPE");

        // 1. Transfer the NFT to the contract
        require(getnfts()[nftType-1].balanceOf(msg.sender) >= 1, "NOT_NFT_OWNER");
        getnfts()[nftType-1].transferFrom(msg.sender, address(this), nftId);

        // 2. Harvest pending rewards
        harvest();

        // 3. Reset lp balance
        lpBalance -= (u.provided + u.totalBoost);

        // 4. Store NFT info
        StakedNft storage stakedNft = userNfts[msg.sender][u.stakedNftsCount];
        stakedNft.nftType = nftType;
        stakedNft.nftId = nftId;
        u.stakedNftsCount ++;

        // 5. Set user boosts & debt
        setBoosts();

        // 6. Update lp balance
        lpBalance += (u.provided + u.totalBoost);
    }

    // Unstake NFT
    function unstakeNft(uint nftIndex) external{
        User storage u = users[msg.sender];
        StakedNft memory stakedNft = userNfts[msg.sender][nftIndex];

        // 1. Harvest pending rewards
        harvest();

        // 2. Reset lp balance
        lpBalance -= (u.provided + u.totalBoost);

        // 3. Remove NFT from storage => replace by last one and remove last one
        userNfts[msg.sender][nftIndex] = userNfts[msg.sender][u.stakedNftsCount-1];
        delete userNfts[msg.sender][u.stakedNftsCount-1];
        u.stakedNftsCount -= 1;

        // 4. Set user boosts & debt
        setBoosts();

        // 5. Update lp balance
        lpBalance += (u.provided + u.totalBoost);

        // 6. Transfer the NFT to the user
        getnfts()[stakedNft.nftType-1].transferFrom(address(this), msg.sender, stakedNft.nftId);
    }

    // Unstake LPs
    function unstake(uint amount) external{
        // 1. Verify he doesn't unstake more than provided
        User storage u = users[msg.sender];
        require(amount <= u.provided, "AMOUNT_TOO_BIG");

        // 2. Harvest pending rewards
        harvest();

        // 3. Reset lp balance
        lpBalance -= (u.provided + u.totalBoost);

        // 4. Set user provided
        u.provided -= amount;

        // 5. Set boosts and debt
        setBoosts();

        // 6. Update lp balance
        lpBalance += (u.provided + u.totalBoost);

        // 7. Transfer the LPs to the address
        lp.transfer(msg.sender, amount);
    }

    // READ-ONLY VIEW FUNCTIONS

    // 1e5 precision
    function tvl() external view returns(uint){
        if(lp.totalSupply() == 0){ return 0; }

        (, uint reserveDai) = reservesLp();
        uint lpPriceDai = reserveDai * 1e5 * 2 / lp.totalSupply();

        return lpBalance * lpPriceDai / 1e18;
    }

    // NFTs list
    function getnfts() public view returns(NftInterfaceV5[5] memory){
        return nfts;
    }
}