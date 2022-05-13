/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
interface IBEP721{
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory  data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed_tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

}

contract StakeContract {

    //Variables
    IBEP20 public StakeToken;
    IBEP20 public RewardToken;
    IBEP721 public NFT;
    IBEP721 public NFT2;
    IBEP721 public NFT3;
    address payable public owner;
    address payable public rewardAddress;
    uint256 public totalNewUser;
    uint256 public totalStaked;
    uint256 public minStake;
    uint256 public constant percentDivider = 100_000;

    //arrays
    uint256[4] public percentagesStandard = [1_500, 2_100, 4_400, 6_900];
    uint256[4] public percentagesPremium = [6_400, 8_900, 11_400, 15_900];
    uint256[4] public durations = [30 days, 90 days, 180 days, 365 days];

    
    //structures
    struct Stake {
        uint256 stakeTime;
        uint256 withdrawTime;
        uint256 amount;
        uint256 bonus;
        uint256 plan;
        bool withdrawan;
        bool unstaked;
        bool premium;
    }

    struct User {
        uint256 totalstakeduser;
        uint256 stakecount;
        uint256 claimedTokens;
        uint256 unStakedTokens;
        mapping(uint256 => Stake) stakerecord;
    }

    //mappings
    mapping(address => User) public users;
    mapping(address => bool) public newuser;

    //modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: Not an owner");
        _;
    }

    //events
    event Staked(
        address indexed _user,
        uint256 indexed _amount,
        uint256 indexed _Time
    );

    event UnStaked(
        address indexed _user,
        uint256 indexed _amount,
        uint256 indexed _Time
    );

    event Withdrawn(
        address indexed _user,
        uint256 indexed _amount,
        uint256 indexed _Time
    );

    event NewUser(address indexed _user);

    // constructor
    constructor() {
        owner = payable(0x942e5DF5b89D9105918F5A8784eb18df1df42327);
        rewardAddress =  payable(0x942e5DF5b89D9105918F5A8784eb18df1df42327);
        StakeToken = IBEP20(0x1e9F149cCADa7020436344ABE354E99842CFE35A);//stake token
        RewardToken = IBEP20(0x6292F56ccE9FB34e21010a1A237a4D908a6474eA);//reward token

        NFT = IBEP721(0x2F890cc86EC820b3D2D5D8797487Fe7D8447b0b7);//nft
        NFT2 = IBEP721(0x92ea2483a03dB93c2fAB9C49B76c73131f8cBcD5);//nft
        NFT3 = IBEP721(0xA65136284b422B585e09bF3A5D1dE732a2bb6ed8);//nft

        minStake = 100;
        minStake = minStake*(10**StakeToken.decimals());

    }

    // functions


    //writeable
    function stake(uint256 amount, uint256 plan) public {
      uint256 percentage ;
        require(plan >= 0 && plan < 4, "put valid plan details");
        require(
            amount >= minStake,
            "cant deposit need to stake more than minimum amount"
        );
        if (!newuser[msg.sender]) {
            newuser[msg.sender] = true;
            totalNewUser++;
            emit NewUser(msg.sender);
        }
        User storage user = users[msg.sender];
        
        
        StakeToken.transferFrom(msg.sender, address(this), amount);
        
        if(NFT.balanceOf(msg.sender)>0 || NFT2.balanceOf(msg.sender)>0 || NFT3.balanceOf(msg.sender)>0){
          percentage = percentagesPremium[plan];
          user.stakerecord[user.stakecount].premium = true;  
        }else{
          percentage = percentagesStandard[plan];
        }

        user.totalstakeduser += amount;
        user.stakerecord[user.stakecount].plan = plan;
        user.stakerecord[user.stakecount].stakeTime = block.timestamp;
        user.stakerecord[user.stakecount].amount = amount;
        user.stakerecord[user.stakecount].withdrawTime = block.timestamp+(durations[plan]);
        user.stakerecord[user.stakecount].bonus = ((amount*(percentage)/(percentDivider))*(10**RewardToken.decimals())/(10**StakeToken.decimals()));
        user.stakecount++;
        totalStaked += amount;
        emit Staked(msg.sender, amount, block.timestamp);
    }


    function withdraw(uint256 count) public {
        User storage user = users[msg.sender];
        require(user.stakecount >= count, "Invalid Stake index");
        require(StakeToken.balanceOf(address(this)) >= user.stakerecord[count].amount , "insufficent Contract Balance");
        require(
            !user.stakerecord[count].withdrawan,
            " withdraw completed "
        );
        require(
            !user.stakerecord[count].unstaked,
            " withdraw completed "
        );
        StakeToken.transfer(
            msg.sender,
            user.stakerecord[count].amount
        );
        RewardToken.transferFrom(
            rewardAddress,
            msg.sender,
            user.stakerecord[count].bonus
        );
        user.claimedTokens += user.stakerecord[count].amount;
        user.claimedTokens += user.stakerecord[count].bonus;
        user.stakerecord[count].withdrawan = true;
        emit Withdrawn(
            msg.sender,
            user.stakerecord[count].amount,
            block.timestamp);
    }

    function unstake(uint256 count) public {
        User storage user = users[msg.sender];
        require(user.stakecount >= count, "Invalid Stake index");
        require(StakeToken.balanceOf(address(this)) >= user.stakerecord[count].amount , "insufficent Contract Balance");
        require(
            !user.stakerecord[count].withdrawan,
            " withdraw completed "
        );
        require(
            !user.stakerecord[count].unstaked,
            " unstake completed "
        );
        StakeToken.transfer(
            msg.sender,
            user.stakerecord[count].amount
        );
        user.unStakedTokens += user.stakerecord[count].amount;
        user.stakerecord[count].unstaked = true;
        emit UnStaked(
            msg.sender,
            user.stakerecord[count].amount,
            block.timestamp
        );
    }

    function changeOwner(address payable _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    function changeRewardAddress(address payable _newRewardAddress) external onlyOwner {
        rewardAddress = _newRewardAddress;
    }

    function migrateStuckFunds() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function migratelostToken(address lostToken) external onlyOwner {
        IBEP20(lostToken).transfer(
            owner,
            IBEP20(lostToken).balanceOf(address(this))
        );
    }
    function setminStake(uint256 _minStake) external onlyOwner {
        minStake = _minStake;
    }

    function setTokenaddress(IBEP20 _stakeToken,IBEP20 _rewardToken,IBEP721 _nft,IBEP721 _nft2,IBEP721 _nft3)external onlyOwner{
        StakeToken = _stakeToken;
        RewardToken = _rewardToken;
        NFT = _nft;
        NFT2 = _nft2;
        NFT3 = _nft3;

    }
    function setPremiumPercentage(uint256 _percentage,uint256 _percentage2,uint256 _percentage3,uint256 _percentage4)external onlyOwner{
        percentagesPremium[0] = _percentage;
        percentagesPremium[1] = _percentage2;
        percentagesPremium[2] = _percentage3;
        percentagesPremium[3] = _percentage4;
    }
    function setStandardPercentage(uint256 _percentage,uint256 _percentage2,uint256 _percentage3,uint256 _percentage4)external onlyOwner{
        percentagesStandard[0] = _percentage;
        percentagesStandard[1] = _percentage2;
        percentagesStandard[2] = _percentage3;
        percentagesStandard[3] = _percentage4;
    }
    function setDuration(uint256 _duration,uint256 _duration2,uint256 _duration3,uint256 _duration4)external onlyOwner{
        durations[0] = _duration;
        durations[1] = _duration2;
        durations[2] = _duration3;
        durations[3] = _duration4;
    }

    //readable
    
    function stakedetails(address add, uint256 count)
        public
        view
        returns (
        uint256 withdrawTime,
        uint256 amount,
        uint256 bonus,
        uint256 plan,
        bool withdrawan,
        bool unstaked

        )
    {
        return (
            users[add].stakerecord[count].withdrawTime,
            users[add].stakerecord[count].amount,
            users[add].stakerecord[count].bonus,
            users[add].stakerecord[count].plan,
            users[add].stakerecord[count].withdrawan,
            users[add].stakerecord[count].unstaked
        );
    }

    function calculateRewards(address user,uint256 amount, uint256 plan)
        external
        view
        returns (uint256)
    {
      uint256 percentage;
      if(NFT.balanceOf(user)>0 || NFT2.balanceOf(user)>0 || NFT3.balanceOf(user)>0){
          percentage = percentagesPremium[plan];
        }else{
          percentage = percentagesStandard[plan];
        }
        return ((amount*(percentage)/(percentDivider))*(10**RewardToken.decimals())/(10**StakeToken.decimals()));
    }

    function currentStaked(address add) external view returns (uint256) {
        uint256 currentstaked;
        for (uint256 i; i < users[add].stakecount; i++) {
            if (!users[add].stakerecord[i].withdrawan) {
                currentstaked += users[add].stakerecord[i].amount;
            }
        }
        return currentstaked;
    }

    function getContractTokenBalanceRewardToken() external view returns (uint256) {
        return RewardToken.allowance(owner, address(this));
    }

    function getContractTokenBalanceStakeToken() external view returns (uint256) {
        return StakeToken.balanceOf(address(this));
    }

    function getCurrentwithdrawTime() external view returns (uint256) {
        return block.timestamp;
    }
}