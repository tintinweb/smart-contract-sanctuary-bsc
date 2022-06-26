/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

pragma solidity ^0.8.15;

// SPDX-License-Identifier: MIT

contract OGStake {
    //constant
    uint256 public constant percentDivider = 100_000;
    uint256 public maxStake = 2_500_000;
    uint256 public minStake = 10_000;
    uint256 public totalStaked;
    uint256 public TimeStep = 1 seconds;
    uint256 tax = 10_000;
    //address
    IBEP20 public TOKEN;
    IBEP721 public NFT = IBEP721(0xa258ffA86B24B08A7F39D7E31fb6A3B57c18a673);
    IBEP721 public NFT2= IBEP721(0xa258ffA86B24B08A7F39D7E31fb6A3B57c18a673);
    IBEP721 public NFT3= IBEP721(0xa258ffA86B24B08A7F39D7E31fb6A3B57c18a673);
    address payable public Admin;
    address payable public RewardAddress;

    // structures
    struct Stake {
        uint256 StakePercent;
        uint256 StakePercentPremium;
        uint256 StakePeriod;
    }
    struct Staker {
        uint256 Amount;
        uint256 Claimed;
        uint256 Claimable;
        uint256 MaxClaimable;
        uint256 TokenPerTimeStep;
        uint256 LastClaimTime;
        uint256 UnStakeTime;
        uint256 StakeTime;
    }
    struct Stakedata {
        Stake[] stakeplan;
        uint256 Nonce;
        mapping(uint256 => mapping(address => Staker)) Plan;
    }

    Stakedata stakedata;
    mapping(address => bool) public blacklisted;

    modifier onlyAdmin() {
        require(msg.sender == Admin, "Stake: Not an Admin");
        _;
    }
    modifier validDepositId(uint256 _depositId) {
        require(_depositId >= 0 &&_depositId < stakedata.stakeplan.length, "Invalid depositId");
        _;
    }
    modifier validUser(address _user) {
        require(!blacklisted[_user], "User is blacklisted");
        _;
    }

    constructor() {
        Admin = payable(msg.sender);
        RewardAddress = payable(msg.sender);
        TOKEN = IBEP20(0xb91b5792F6cf925226C3DB3a35E1dCA9fCCad542);


        stakedata.stakeplan.push(Stake(2_500,3_500, 30 minutes));
        stakedata.Nonce++;
        stakedata.stakeplan.push(Stake(17_500,20_500, 180 minutes));
        stakedata.Nonce++;
        stakedata.stakeplan.push(Stake(39_000,45_000, 360 minutes));
        stakedata.Nonce++;

        maxStake = maxStake * (10**TOKEN.decimals());
        minStake = minStake * (10**TOKEN.decimals());
    }


    // to buy  token during Stake time => for web3 use
    function deposit(uint256 _depositId, uint256 _amount)
        public
        validDepositId(_depositId)
        validUser(msg.sender)
    {
        require(stakedata.Plan[_depositId][msg.sender].Amount+_amount <= maxStake, "MaxStake limit reached");
        require(_amount >= minStake, "Deposit more than 10_000");
        TOKEN.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + (_amount);

        stakedata.Plan[_depositId][msg.sender].Claimable = calcRewards(
            msg.sender,
            _depositId
        );
        stakedata.Plan[_depositId][msg.sender].Amount =
            stakedata.Plan[_depositId][msg.sender].Amount +
            (_amount);
            uint256 _StakePercent = getPercent(_depositId,msg.sender);
        stakedata.Plan[_depositId][msg.sender].MaxClaimable =
            ((stakedata.Plan[_depositId][msg.sender].Amount *
                (_StakePercent)) /
                (percentDivider)) +
            stakedata.Plan[_depositId][msg.sender].Claimable;

        stakedata.Plan[_depositId][msg.sender].TokenPerTimeStep = (
            CalculatePerTimeStep(
                stakedata.Plan[_depositId][msg.sender].MaxClaimable -
                    stakedata.Plan[_depositId][msg.sender].Claimable,
                stakedata.stakeplan[_depositId].StakePeriod
            )
        );

        stakedata.Plan[_depositId][msg.sender].LastClaimTime = block.timestamp;

        stakedata.Plan[_depositId][msg.sender].StakeTime = block.timestamp;
        stakedata.Plan[_depositId][msg.sender].UnStakeTime =
            block.timestamp +
            (stakedata.stakeplan[_depositId].StakePeriod);
        stakedata.Plan[_depositId][msg.sender].Claimed = 0;
    }

    function extendLockup(uint256 _depositId)
        public
        validDepositId(_depositId)
        validUser(msg.sender)
    {
        if (calcRewards(msg.sender, _depositId) > 0) {
            require(
                stakedata.Plan[_depositId][msg.sender].Amount + (calcRewards(msg.sender, _depositId)) <=
                    maxStake,
                "MaxStake limit reached"
            );
        }
        totalStaked = totalStaked + (calcRewards(msg.sender, _depositId));

        if (calcRewards(msg.sender, _depositId) > 0) {
            TOKEN.transferFrom(
                RewardAddress,
                address(this),
                calcRewards(msg.sender, _depositId)
            );
        }
        require(
            stakedata.Plan[_depositId][msg.sender].Amount > 0,
            "not staked"
        );

        stakedata.Plan[_depositId][msg.sender].Amount =
            stakedata.Plan[_depositId][msg.sender].Amount +
            (calcRewards(msg.sender, _depositId));
            uint256 _StakePercent = getPercent(_depositId,msg.sender);
        stakedata.Plan[_depositId][msg.sender].TokenPerTimeStep = (
            CalculatePerTimeStep(
                ((stakedata.Plan[_depositId][msg.sender].Amount *
                    (_StakePercent)) /
                    (percentDivider)),
                stakedata.stakeplan[_depositId].StakePeriod
            )
        );
        stakedata.Plan[_depositId][msg.sender].MaxClaimable = ((stakedata
        .Plan[_depositId][msg.sender].Amount *
            (_StakePercent)) / (percentDivider));

        stakedata.Plan[_depositId][msg.sender].LastClaimTime = block.timestamp;

        stakedata.Plan[_depositId][msg.sender].StakeTime = block.timestamp;
        stakedata.Plan[_depositId][msg.sender].UnStakeTime =
            block.timestamp +
            (stakedata.stakeplan[_depositId].StakePeriod);
        stakedata.Plan[_depositId][msg.sender].Claimable = 0;
        stakedata.Plan[_depositId][msg.sender].Claimed = 0;
    }

    function withdrawAll(uint256 _depositId, address reward)
        external
        validDepositId(_depositId)
        validUser(msg.sender)
    {
        require(
            calcRewards(msg.sender, _depositId) > 0,
            "no claimable amount available yet"
        );
        _withdraw(msg.sender, _depositId, reward);
    }

    function _withdraw(
        address _user,
        uint256 _depositId,
        address reward
    ) internal validDepositId(_depositId) {
        require(
            stakedata.Plan[_depositId][_user].Claimed <=
                stakedata.Plan[_depositId][_user].MaxClaimable,
            "no claimable amount available"
        );
        require(
            block.timestamp > stakedata.Plan[_depositId][_user].LastClaimTime,
            "time not reached"
        );

        if (calcRewards(_user, _depositId) > 0) {
            TOKEN.transferFrom(
                RewardAddress,
                reward,
                calcRewards(_user, _depositId)
            );
        }
        stakedata.Plan[_depositId][_user].Claimed =
            stakedata.Plan[_depositId][_user].Claimed +
            (calcRewards(_user, _depositId));
        stakedata.Plan[_depositId][_user].LastClaimTime = block.timestamp;
        stakedata.Plan[_depositId][_user].Claimable = 0;
    }

    function CompleteWithDraw(uint256 _depositId, address reward)
        external
        validDepositId(_depositId)
        validUser(msg.sender)
    {
        require(
            stakedata.Plan[_depositId][msg.sender].UnStakeTime <
                block.timestamp,
            "Time not reached"
        );
        TOKEN.transfer(
            msg.sender,
            stakedata.Plan[_depositId][msg.sender].Amount
        );
        
        _withdraw(msg.sender, _depositId, reward);
        delete stakedata.Plan[_depositId][msg.sender];
    }
    function forceUnstake(uint256 _depositId)
        external
        validDepositId(_depositId)
        validUser(msg.sender)
    {
        require(
            block.timestamp < stakedata.Plan[_depositId][msg.sender].UnStakeTime ,
            "Time Passed"
        );
        TOKEN.transfer(
            msg.sender,
            stakedata.Plan[_depositId][msg.sender].Amount - ((stakedata.Plan[_depositId][msg.sender].Amount *tax)/percentDivider)
        );
        TOKEN.transfer(
            RewardAddress,
            ((stakedata.Plan[_depositId][msg.sender].Amount *tax)/percentDivider));

        delete stakedata.Plan[_depositId][msg.sender];
    }

    function calcRewards(address _sender, uint256 _depositId)
        public
        view
        validDepositId(_depositId)
        returns (uint256 amount)
    {
        uint256 claimable = stakedata.Plan[_depositId][_sender].TokenPerTimeStep *
            ((block.timestamp -
                (stakedata.Plan[_depositId][_sender].LastClaimTime)) /
                (TimeStep));
        claimable = claimable + stakedata.Plan[_depositId][_sender].Claimable;
        if (
            claimable >
            stakedata.Plan[_depositId][_sender].MaxClaimable -
                (stakedata.Plan[_depositId][_sender].Claimed)
        ) {
            claimable =
                stakedata.Plan[_depositId][_sender].MaxClaimable -
                (stakedata.Plan[_depositId][_sender].Claimed);
        }
        return (claimable);
    }

    function getCurrentBalance(uint256 _depositId, address _sender)
        public
        view
        returns (uint256 addressBalance)
    {
        return (stakedata.Plan[_depositId][_sender].Amount);
    }

    function depositDates(address _sender, uint256 _depositId)
        public
        view
        validDepositId(_depositId)
        returns (uint256 date)
    {
        return (stakedata.Plan[_depositId][_sender].StakeTime);
    }

    function isLockupPeriodExpired(address _user, uint256 _depositId)
        public
        view
        validDepositId(_depositId)
        returns (bool val)
    {
        if (block.timestamp > stakedata.Plan[_depositId][_user].UnStakeTime) {
            return true;
        } else {
            return false;
        }
    }

    // transfer Adminship
    function transferOwnership(address payable _newAdmin) external onlyAdmin {
        Admin = _newAdmin;
    }

    function ChangeTax(uint256 _tax) external onlyAdmin {
        require(_tax < percentDivider/4, "Tax must be less than 25%");
        tax = _tax;
    }

    function blacklist(address _address,bool choice) external onlyAdmin {
        blacklisted[_address] = choice;
    }

    function withdrawStuckToken(address _token, uint256 _amount)
        external
        onlyAdmin
    {
        IBEP20(_token).transfer(msg.sender, _amount);
    }

    function ChangeRewardAddress(address payable _newAddress)
        external
        onlyAdmin
    {
        RewardAddress = _newAddress;
    }

    function ChangeTokenAddress(address _newAddress)
        external
        onlyAdmin
    {
        TOKEN = IBEP20(_newAddress);
    }

    function ChangeNFT(address _newAddress,
        address _newAddress2,
        address _newAddress3)
        external
        onlyAdmin
    {
        NFT = IBEP721(_newAddress);
        NFT2 = IBEP721(_newAddress2);
        NFT3 = IBEP721(_newAddress3);
    }

    function ChangeMinStake(uint256 val) external onlyAdmin {
        require(minStake < maxStake, "Min stake must be less than max stake");
        minStake = val;
    }

    function ChangeMaxStake(uint256 val) external onlyAdmin {
        require(maxStake > minStake, "Max stake must be greater than min stake");
        maxStake = val;
    }


    function getContractTokenBalance() public view returns (uint256) {
        return TOKEN.balanceOf(address(this));
    }

    function CalculatePerTimeStep(uint256 amount, uint256 _VestingPeriod)
        internal
        view
        returns (uint256)
    {
        return (amount * (TimeStep)) / (_VestingPeriod);
    }
    function getPercent(uint256 _depositId, address _user)
        internal
        view
        validDepositId(_depositId)
        returns (uint256)
    {
        if(NFT.balanceOf(_user) > 0 || NFT2.balanceOf(_user) > 0 || NFT3.balanceOf(_user)>0){
            return (stakedata.stakeplan[_depositId].StakePercentPremium);
        }else{
            return (stakedata.stakeplan[_depositId].StakePercent);
        }
    }

    function getuserdata(uint256 _depositId, address _user)
        public
        view
        returns (
            uint256 Amount,
            uint256 Claimed,
            uint256 Claimable,
            uint256 MaxClaimable,
            uint256 UnStakeTime,
            uint256 StakeTime
        )
    {
        return (
            stakedata.Plan[_depositId][_user].Amount,
            stakedata.Plan[_depositId][_user].Claimed,
            stakedata.Plan[_depositId][_user].Claimable,
            stakedata.Plan[_depositId][_user].MaxClaimable,
            stakedata.Plan[_depositId][_user].UnStakeTime,
            stakedata.Plan[_depositId][_user].StakeTime
        );
    }
}

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
interface IBEP721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approret(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApproretForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApproretForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}