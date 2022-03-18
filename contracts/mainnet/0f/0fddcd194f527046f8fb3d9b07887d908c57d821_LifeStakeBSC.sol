/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

/*                           'coddl,.            .';;:clc;.                                           
*                          .lKWMMMWNd.        .:x0XNNWWWWk.                                           
*   ';;;;::'               ,0WMMMMMMXc       ;ONMMMMMMMMWO'                                           
*  'OWMMMMMO'              .dNMMMMMWk'      :KWMMMMMMWNKOl.                                           
*  'OWMMMMMO'               .:dO00kl.      .xWMMMMMNXx,.                                              
*  'OWMMMMMO'                  ...         ;KWMMMMWOc'                                                
*  'OWMMMMMO'                ','''''.   .',oXMMMMMWOl:,',.           ..,;:ccc:;,..                    
*  'OWMMMMMO'               ,0NNNNNKc  .xNNWMMMMMMMWWNNNN0,       .cdOKNWMMMMMWWX0xl,.                
*  'OWMMMMMO'               ;XMMMMMNl  .kMMMMMMMMMMMMMMMMK;    .;xXWMMMMMMMMMMMMMMMWXOc.              
*  'OWMMMMMO'               ;XMMMMMNl  .xNNWMMMMMMMWWWNNN0,   'xXMMMMMMWNKOO0KXWMMMMMMWO;             
*  'OWMMMMMO'               ;XMMMMMNl   .''oXMMMMMWOl:'''.   ,OWMMMMMXkc'.....':kXMMMMMMK:.           
*  'OWMMMMMO'               ;XMMMMMNl      ;KMMMMMWx,.      'kWMMMMWKc.         .:0WMMMMM0;           
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.      lNMMMMMNo.           .cKMMMMMNx.          
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.     .xWMMMMMW0xxxxxxxxxxxxk0NMMMMMM0'          
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.     'OMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK,          
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.     .kWMMMMMWK000000000000000000000d.          
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.     .dWMMMMMXc.                                
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.      ;KMMMMMWk'           ':cccccc;.           
*  'OWMMMMMO'               ;XMMMMMNl      ;KWMMMMWx,.      .lXMMMMMW0c.       .lKWMMMMMNd.    'lxOOxl
*  'OWMMMMMXxooooooooool:.  ;XMMMMMNl      ;KWMMMMWx,.       .cKWMMMMMWKkolcldkKWMMMMMMXo.    cKWMMMMMc
*  'OWMMMMMMMMMWWMMMMMWW0,  ;XMMMMMNl      ;KWMMMMWx,.         'dXWMMMMMMMWWWMMMMMMMWNk;     .xWMMMMMMx.
*  'OWMMMMMMMMMMMMMMMMMW0,  ;KMMMMWXl      ;KWMMMMWd,.           'lOXWWMMMMMMMMMWWN0d,.       cKWMMMMWc.
*  .xKXXXXXXXXXXXXXXXXXKk'  ,OXXXXX0:      ,kXXXXXKo'.             .;okXWMMMMMWN0x:.          .:ONMMXk.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
 
contract LifeStakeBSC {
    //constant
    uint256 public constant percentDivider = 1_000;
    uint256 public maxStake = 2_500_000_000;
    uint256 public minStake = 10_000;
    uint256 public totalStaked;
    uint256 public currentStaked;
    uint256 public tier1Staked;
    uint256 public tier2Staked;
    uint256 public tier3Staked;
    uint256 public TimeStep = 1 hours;
    //address
    IERC20 public TOKEN;
    address payable public Admin;
    address payable public RewardAddress;
 
    // structures
    struct Stake {
        uint256 StakePercent;
        uint256 StakePeriod;
    }
    struct Staker {
        uint256 Amount;
        uint256 Claimed;
        uint256 Claimable;
        uint256 MaxClaimable;
        uint256 TokenPerHour;
        uint256 LastClaimTime;
        uint256 UnStakeTime;
        uint256 StakeTime;
    }
 
    Stake public StakeI;
    Stake public StakeII;
    Stake public StakeIII;
    // mapping & array
    mapping(address => Staker) public PlanI;
    mapping(address => Staker) public PlanII;
    mapping(address => Staker) public PlanIII;
 
    modifier onlyAdmin() {
        require(msg.sender == Admin, "Stake: Not an Admin");
        _;
    }
    modifier validDepositId(uint256 _depositId) {
        require(_depositId >= 1 && _depositId <= 3, "Invalid depositId");
        _;
    }
 
    constructor(address _TOKEN) {
        Admin = payable(msg.sender);
        RewardAddress = payable(msg.sender);
        TOKEN = IERC20(_TOKEN);
        StakeI.StakePercent = 25;
        StakeI.StakePeriod = 30 days;
 
        StakeII.StakePercent = 175;
        StakeII.StakePeriod = 180 days;
 
        StakeIII.StakePercent = 390;
        StakeIII.StakePeriod = 360 days;
 
        maxStake = maxStake * (10**TOKEN.decimals());
        minStake = minStake * (10**TOKEN.decimals());
    }
 
    receive() external payable {}
 
    // to buy  token during Stake time => for web3 use
    function deposit(uint256 _depositId, uint256 _amount)
        public
        validDepositId(_depositId)
    {
        require(currentStaked + _amount <= maxStake, "MaxStake limit reached");
        require(_amount >= minStake, "Deposit more than 10_000");
        TOKEN.transferFrom(msg.sender, address(this), _amount);
        totalStaked = totalStaked + (_amount);
        currentStaked = currentStaked + (_amount);
 
        if (_depositId == 1) {
            tier1Staked = tier1Staked + (_amount);
            PlanI[msg.sender].Claimable = calcRewardsHour(msg.sender, _depositId);
            PlanI[msg.sender].Amount = PlanI[msg.sender].Amount + (_amount);
            
            PlanI[msg.sender].MaxClaimable =
                ((PlanI[msg.sender].Amount * (StakeI.StakePercent)) /
                    (percentDivider)) +
                PlanI[msg.sender].Claimable;
                
            PlanI[msg.sender].TokenPerHour = (
                CalculatePerHour(PlanI[msg.sender].MaxClaimable - PlanI[msg.sender].Claimable,
                    StakeI.StakePeriod
                )
            );
 
            PlanI[msg.sender].LastClaimTime = block.timestamp;
 
            PlanI[msg.sender].StakeTime = block.timestamp;
            PlanI[msg.sender].UnStakeTime =
                block.timestamp +
                (StakeI.StakePeriod);
            PlanI[msg.sender].Claimed = 0; 
        } else if (_depositId == 2) {
            tier2Staked = tier2Staked + (_amount);
            PlanII[msg.sender].Claimable = calcRewardsHour(msg.sender, _depositId);
 
            PlanII[msg.sender].Amount = PlanII[msg.sender].Amount + (_amount);
            
            PlanII[msg.sender].MaxClaimable =
                ((PlanII[msg.sender].Amount * (StakeII.StakePercent)) /
                    (percentDivider)) +
                PlanII[msg.sender].Claimable;
            PlanII[msg.sender].TokenPerHour = (
                CalculatePerHour(PlanII[msg.sender].MaxClaimable - PlanII[msg.sender].Claimable,
                    StakeII.StakePeriod
                )
            );
 
            PlanII[msg.sender].LastClaimTime = block.timestamp;
 
            PlanII[msg.sender].StakeTime = block.timestamp;
            PlanII[msg.sender].UnStakeTime =
                block.timestamp +
                (StakeII.StakePeriod);
            PlanII[msg.sender].Claimed = 0;
        } else if (_depositId == 3) {
            tier3Staked = tier3Staked + (_amount);
            PlanIII[msg.sender].Claimable = calcRewardsHour(msg.sender, _depositId);
            PlanIII[msg.sender].Amount = PlanIII[msg.sender].Amount + (_amount);
            
            PlanIII[msg.sender].MaxClaimable =
                ((PlanIII[msg.sender].Amount * (StakeIII.StakePercent)) /
                    (percentDivider)) +
                PlanIII[msg.sender].Claimable;
            PlanIII[msg.sender].TokenPerHour = (
                CalculatePerHour(PlanIII[msg.sender].MaxClaimable - PlanIII[msg.sender].Claimable,
                    StakeIII.StakePeriod
                )
            );
 
            PlanIII[msg.sender].LastClaimTime = block.timestamp;
 
            PlanIII[msg.sender].StakeTime = block.timestamp;
            PlanIII[msg.sender].UnStakeTime =
                block.timestamp +
                (StakeIII.StakePeriod);
            PlanIII[msg.sender].Claimed = 0;
        }
    }
    function extendLockup(uint256 _depositId)
        public
        validDepositId(_depositId)
    {
        if(calcRewardsHour(msg.sender, _depositId) > 0)
        {
            require(currentStaked + (calcRewardsHour(msg.sender, _depositId)) <= maxStake, "Max stake limit reached. Please harvest before reinvesting");
            }
        totalStaked = totalStaked + (calcRewardsHour(msg.sender, _depositId));
 
        currentStaked = currentStaked + (calcRewardsHour(msg.sender, _depositId));
        if(calcRewardsHour(msg.sender, _depositId) > 0)
        {
            TOKEN.transferFrom(RewardAddress, address(this),calcRewardsHour(msg.sender, _depositId) );
        }
        if (_depositId == 1) {
            require(PlanI[msg.sender].Amount > 0, "Nothing staked");
            tier1Staked = tier1Staked + (calcRewardsHour(msg.sender, _depositId));
 
            PlanI[msg.sender].Amount = PlanI[msg.sender].Amount + (calcRewardsHour(msg.sender, _depositId));
            PlanI[msg.sender].TokenPerHour = (
                CalculatePerHour(
                    ((PlanI[msg.sender].Amount * (StakeI.StakePercent)) /
                        (percentDivider)),
                    StakeI.StakePeriod
                )
            );
            PlanI[msg.sender].MaxClaimable =
                ((PlanI[msg.sender].Amount * (StakeI.StakePercent)) /
                    (percentDivider)) ;
 
            PlanI[msg.sender].LastClaimTime = block.timestamp;
 
            PlanI[msg.sender].StakeTime = block.timestamp;
            PlanI[msg.sender].UnStakeTime =
                block.timestamp +
                (StakeI.StakePeriod);
            PlanI[msg.sender].Claimable = 0;
            PlanI[msg.sender].Claimed = 0;
        } else if (_depositId == 2) {
            require(PlanII[msg.sender].Amount > 0, "Nothing staked");
            tier2Staked = tier2Staked + (calcRewardsHour(msg.sender, _depositId));
 
            PlanII[msg.sender].Amount = PlanII[msg.sender].Amount + (calcRewardsHour(msg.sender, _depositId));
            PlanII[msg.sender].TokenPerHour = (
                CalculatePerHour(
                    ((PlanII[msg.sender].Amount * (StakeII.StakePercent)) /
                        (percentDivider)),
                    StakeII.StakePeriod
                )
            );
            PlanII[msg.sender].MaxClaimable =
                ((PlanII[msg.sender].Amount * (StakeII.StakePercent)) /
                    (percentDivider)) ;
 
            PlanII[msg.sender].LastClaimTime = block.timestamp;
 
            PlanII[msg.sender].StakeTime = block.timestamp;
            PlanII[msg.sender].UnStakeTime =
                block.timestamp +
                (StakeII.StakePeriod);
            PlanII[msg.sender].Claimable = 0;
            PlanII[msg.sender].Claimed = 0;
        } else if (_depositId == 3) {
            require(PlanIII[msg.sender].Amount > 0, "Nothing staked");
            tier3Staked = tier3Staked + (calcRewardsHour(msg.sender, _depositId));
            PlanIII[msg.sender].Claimable = 0;
            PlanIII[msg.sender].Amount = PlanIII[msg.sender].Amount + (calcRewardsHour(msg.sender, _depositId));
            PlanIII[msg.sender].TokenPerHour = (
                CalculatePerHour(
                    ((PlanIII[msg.sender].Amount * (StakeIII.StakePercent)) /
                        (percentDivider)),
                    StakeIII.StakePeriod
                )
            );
            PlanIII[msg.sender].MaxClaimable =
                ((PlanIII[msg.sender].Amount * (StakeIII.StakePercent)) /
                    (percentDivider)) ;
 
            PlanIII[msg.sender].LastClaimTime = block.timestamp;
 
            PlanIII[msg.sender].StakeTime = block.timestamp;
            PlanIII[msg.sender].UnStakeTime =
                block.timestamp +
                (StakeIII.StakePeriod);
            PlanIII[msg.sender].Claimable = 0;
            PlanIII[msg.sender].Claimed = 0;
        }
    }
    function withdrawAll(uint256 _depositId,address reward)
        external
        validDepositId(_depositId)
    {
        require(calcRewardsHour(msg.sender,_depositId) > 0,"No claimable amount available yet");
        _withdraw(msg.sender, _depositId,reward);
    }
 
    function _withdraw(address _user, uint256 _depositId , address reward)
        internal
        validDepositId(_depositId)
    {
        if (_depositId == 1) {
            require(PlanI[_user].Claimed <= PlanI[_user].MaxClaimable,"No claimable amount available");
            require(block.timestamp > PlanI[_user].LastClaimTime,"Lockout time has not expired");
 
 
            if (calcRewardsHour(_user, _depositId) > 0) {
                TOKEN.transferFrom(RewardAddress, reward, calcRewardsHour(_user, _depositId));
            }
            PlanI[_user].Claimed = PlanI[_user].Claimed + (calcRewardsHour(_user, _depositId));
            PlanI[_user].LastClaimTime = block.timestamp;
            PlanI[_user].Claimable = 0;
        }
        if (_depositId == 2) {
            require(PlanII[_user].Claimed <= PlanII[_user].MaxClaimable,"No claimable amount available");
            require(block.timestamp > PlanII[_user].LastClaimTime,"Lockout time has not expired");
 
 
            if (calcRewardsHour(_user, _depositId) > 0) {
                TOKEN.transferFrom(RewardAddress, reward, calcRewardsHour(_user, _depositId));
            }
            PlanII[_user].Claimed = PlanII[_user].Claimed + (calcRewardsHour(_user, _depositId));
            PlanII[_user].LastClaimTime = block.timestamp;
            PlanII[_user].Claimable = 0;
        }
 
        if (_depositId == 3) {
            require(PlanIII[_user].Claimed <= PlanIII[_user].MaxClaimable,"No claimable amount available");
            require(block.timestamp > PlanIII[_user].LastClaimTime,"Lockout time has not expired");
 
 
            if (calcRewardsHour(_user, _depositId) > 0) {
                TOKEN.transferFrom(RewardAddress, reward, calcRewardsHour(_user, _depositId));
            }
            PlanIII[_user].Claimed = PlanIII[_user].Claimed + (calcRewardsHour(_user, _depositId));
            PlanIII[_user].LastClaimTime = block.timestamp;
            PlanIII[_user].Claimable = 0;
        }
        }
 
    function CompleteWithDraw(uint256 _depositId, address reward)
        external
        validDepositId(_depositId)
    {
        if (_depositId == 1) {
            require(
                PlanI[msg.sender].UnStakeTime < block.timestamp,
                "Time1 not reached"
            );
            TOKEN.transfer(msg.sender, PlanI[msg.sender].Amount);
            currentStaked = currentStaked - (PlanI[msg.sender].Amount);
            tier1Staked = tier1Staked - (PlanI[msg.sender].Amount);
            _withdraw(msg.sender, _depositId , reward);
            delete PlanI[msg.sender];
        } else if (_depositId == 2) {
            require(
                PlanII[msg.sender].UnStakeTime < block.timestamp,
                "Time2 not reached"
            );
            TOKEN.transfer(msg.sender, PlanII[msg.sender].Amount);
            currentStaked = currentStaked - (PlanII[msg.sender].Amount);
            tier2Staked = tier2Staked - (PlanII[msg.sender].Amount);
            _withdraw(msg.sender, _depositId,reward);
            delete PlanII[msg.sender];
        } else if (_depositId == 3) {
            require(
                PlanIII[msg.sender].UnStakeTime < block.timestamp,
                "Time3 not reached"
            );
            TOKEN.transfer(msg.sender, PlanIII[msg.sender].Amount);
            currentStaked = currentStaked - (PlanIII[msg.sender].Amount);
            tier3Staked = tier3Staked - (PlanIII[msg.sender].Amount);
            _withdraw(msg.sender, _depositId,reward);
            delete PlanIII[msg.sender];
        }
    }

    function calcRewardsHour(address _sender, uint256 _depositId)
        public
        view
        validDepositId(_depositId)
        returns (uint256 amount)
    {
        if (_depositId == 1) {
            uint256 claimable = PlanI[_sender].TokenPerHour *
                ((block.timestamp - (PlanI[_sender].LastClaimTime)) /
                    (TimeStep));
            claimable = claimable + PlanI[_sender].Claimable;
            if (
                claimable >
                PlanI[_sender].MaxClaimable - (PlanI[_sender].Claimed)
            ) {
                claimable =
                    PlanI[_sender].MaxClaimable -
                    (PlanI[_sender].Claimed);
            }
            return (claimable);
        } else if (_depositId == 2) {
            uint256 claimable = PlanII[_sender].TokenPerHour *
                ((block.timestamp - (PlanII[_sender].LastClaimTime)) /
                    (TimeStep));
            claimable = claimable + PlanII[_sender].Claimable;
            if (
                claimable >
                PlanII[_sender].MaxClaimable - (PlanII[_sender].Claimed)
            ) {
                claimable =
                    PlanII[_sender].MaxClaimable -
                    (PlanII[_sender].Claimed);
            }
            return (claimable);
        } else if (_depositId == 3) {
            uint256 claimable = PlanIII[_sender].TokenPerHour *
                ((block.timestamp - (PlanIII[_sender].LastClaimTime)) /
                    (TimeStep));
            claimable = claimable + PlanIII[_sender].Claimable;
            if (
                claimable >
                PlanIII[_sender].MaxClaimable - (PlanIII[_sender].Claimed)
            ) {
                claimable =
                    PlanIII[_sender].MaxClaimable -
                    (PlanIII[_sender].Claimed);
            }
            return (claimable);
        }
    }
 
    function getCurrentBalance(uint256 _depositId, address _sender)
        public
        view
        returns (uint256 addressBalance)
    {
        if (_depositId == 1) {
            return (PlanI[_sender].Amount);
        } else if (_depositId == 2) {
            return (PlanII[_sender].Amount);
        } else if (_depositId == 3) {
            return (PlanIII[_sender].Amount);
        }
    }
 
    function depositDates(address _sender, uint256 _depositId)
        public
        view
        validDepositId(_depositId)
        returns (uint256 date)
    {
        if (_depositId == 1) {
            return (PlanI[_sender].StakeTime);
        } else if (_depositId == 2) {
            return (PlanII[_sender].StakeTime);
        } else if (_depositId == 3) {
            return (PlanIII[_sender].StakeTime);
        }
    }
 
    function isLockupPeriodExpired(address _user,uint256 _depositId)
        public
        view
        validDepositId(_depositId)
        returns (bool val)
    {
        if (_depositId == 1) {
            if (block.timestamp > PlanI[_user].UnStakeTime) {
                return true;
            } else {
                return false;
            }
        } else if (_depositId == 2) {
            if (block.timestamp > PlanII[_user].UnStakeTime) {
                return true;
            } else {
                return false;
            }
        } else if (_depositId == 3) {
            if (block.timestamp > PlanIII[_user].UnStakeTime) {
                return true;
            } else {
                return false;
            }
        }
    }
 
    // transfer Adminship
    function transferOwnership(address payable _newAdmin) external onlyAdmin {
        Admin = _newAdmin;
    }
    
    function withdrawStuckToken(address _token,uint256 _amount) external onlyAdmin {
        IERC20(_token).transfer(msg.sender,_amount);
    }
 
    function ChangeRewardAddress(address payable _newAddress) external onlyAdmin {
        RewardAddress = _newAddress;
    }
 
    function ChangePlan(
        uint256 _depositId,
        uint256 StakePercent,
        uint256 StakePeriod
    ) external onlyAdmin {
        if (_depositId == 1) {
            StakeI.StakePercent = StakePercent;
            StakeI.StakePeriod = StakePeriod;
        } else if (_depositId == 2) {
            StakeII.StakePercent = StakePercent;
            StakeII.StakePeriod = StakePeriod;
        } else if (_depositId == 3) {
            StakeIII.StakePercent = StakePercent;
            StakeIII.StakePeriod = StakePeriod;
        }
    }
 
    function ChangeMinStake(uint256 val) external onlyAdmin {
        minStake = val;
    }
 
    function ChangeMaxStake(uint256 val) external onlyAdmin {
        maxStake = val;
    }
 
    function userData(
        uint256[] memory _depositId,
        uint256[] memory _amount,
        address[] memory _user
    ) external onlyAdmin {
        require(
            _amount.length == _depositId.length &&
                _depositId.length == _user.length,
            "invalid number of arguments"
        );
        for (uint256 i; i < _depositId.length; i++) {
            totalStaked = totalStaked + (_amount[i]);
            currentStaked = currentStaked + (_amount[i]);
 
            if (_depositId[i] == 1) {
                tier1Staked = tier1Staked + (_amount[i]);
                PlanI[_user[i]].Claimable = calcRewardsHour(
                    _user[i],
                    _depositId[i]
                );
                
                PlanI[_user[i]].MaxClaimable =
                    PlanI[_user[i]].MaxClaimable +
                    ((_amount[i] * (StakeI.StakePercent)) / (percentDivider));
                    PlanI[_user[i]].TokenPerHour =
                    (
                        CalculatePerHour(PlanI[_user[i]].MaxClaimable - PlanIII[_user[i]].Claimed ,
                            StakeI.StakePeriod
                        )
                    ); 

                PlanI[_user[i]].LastClaimTime = block.timestamp;
                PlanI[_user[i]].StakeTime = block.timestamp;
                PlanI[_user[i]].UnStakeTime =
                    block.timestamp +
                    (StakeI.StakePeriod);
                PlanI[_user[i]].Amount = PlanI[_user[i]].Amount + (_amount[i]);

            } else if (_depositId[i] == 2) {
                tier2Staked = tier2Staked + (_amount[i]);
                PlanII[_user[i]].Claimable = calcRewardsHour(
                    _user[i],
                    _depositId[i]
                );
                
                PlanII[_user[i]].MaxClaimable =
                    PlanII[_user[i]].MaxClaimable +
                    ((_amount[i] * (StakeII.StakePercent)) / (percentDivider));

                    PlanII[_user[i]].TokenPerHour =
                    (
                        CalculatePerHour(PlanII[_user[i]].MaxClaimable - PlanIII[_user[i]].Claimed ,
                            StakeII.StakePeriod
                        )
                    );
                PlanII[_user[i]].LastClaimTime = block.timestamp;
                PlanII[_user[i]].StakeTime = block.timestamp;
                PlanII[_user[i]].UnStakeTime =
                    block.timestamp +
                    (StakeII.StakePeriod);
                PlanII[_user[i]].Amount =
                    PlanII[_user[i]].Amount +
                    (_amount[i]);
            } else if (_depositId[i] == 3) {
                tier3Staked = tier3Staked + (_amount[i]);
                PlanIII[_user[i]].Claimable = calcRewardsHour(
                    _user[i],
                    _depositId[i]
                );
                
                PlanIII[_user[i]].MaxClaimable =
                    PlanIII[_user[i]].MaxClaimable +
                    ((_amount[i] * (StakeIII.StakePercent)) / (percentDivider));
                    PlanIII[_user[i]].TokenPerHour =
                    (
                        CalculatePerHour(PlanIII[_user[i]].MaxClaimable - PlanIII[_user[i]].Claimed ,
                            StakeIII.StakePeriod
                        )
                    );
                PlanIII[_user[i]].LastClaimTime = block.timestamp;
                PlanIII[_user[i]].StakeTime = block.timestamp;
                PlanIII[_user[i]].UnStakeTime =
                    block.timestamp +
                    (StakeIII.StakePeriod);
                PlanIII[_user[i]].Amount =
                    PlanIII[_user[i]].Amount +
                    (_amount[i]);
            }
        }
    }
    function ResetSpecificUserData(uint256 _depositId,uint256 _amount,address _user) external onlyAdmin {
        currentStaked = currentStaked + _amount;
        if (_depositId == 1) {
            currentStaked = currentStaked - PlanI[_user].Amount;
            tier1Staked = tier1Staked - PlanI[_user].Amount;
            tier1Staked = tier1Staked + _amount;
            delete PlanI[_user];
            PlanI[_user].TokenPerHour =
                (
                    CalculatePerHour(
                        (_amount * (StakeI.StakePercent)) / (percentDivider),
                        StakeI.StakePeriod
                    )
                );
            PlanI[_user].MaxClaimable =
                ((_amount * (StakeI.StakePercent)) / (percentDivider));
            PlanI[_user].LastClaimTime = block.timestamp;
            PlanI[_user].StakeTime = block.timestamp;
            PlanI[_user].UnStakeTime =
                block.timestamp +
                (StakeI.StakePeriod);
            PlanI[_user].Amount = (_amount);
        }else if (_depositId == 2) {
            currentStaked = currentStaked - PlanII[_user].Amount;
            tier2Staked = tier2Staked - PlanII[_user].Amount;
            tier2Staked = tier2Staked + _amount;
            delete PlanII[_user];
            PlanII[_user].TokenPerHour =
                (
                    CalculatePerHour(
                        (_amount * (StakeII.StakePercent)) / (percentDivider),
                        StakeII.StakePeriod
                    )
                );
            PlanII[_user].MaxClaimable =
                ((_amount * (StakeII.StakePercent)) / (percentDivider));
            PlanII[_user].LastClaimTime = block.timestamp;
            PlanII[_user].StakeTime = block.timestamp;
            PlanII[_user].UnStakeTime =
                block.timestamp +
                (StakeII.StakePeriod);
            PlanII[_user].Amount = (_amount);
        }else if (_depositId == 3) {
            currentStaked = currentStaked - PlanIII[_user].Amount;
            tier3Staked = tier3Staked - PlanIII[_user].Amount;
            tier3Staked = tier3Staked + _amount;
            delete PlanIII[_user];
            PlanIII[_user].TokenPerHour =
                (
                    CalculatePerHour(
                        (_amount * (StakeIII.StakePercent)) / (percentDivider),
                        StakeIII.StakePeriod
                    )
                );
            PlanIII[_user].MaxClaimable =
                ((_amount * (StakeIII.StakePercent)) / (percentDivider));
            PlanIII[_user].LastClaimTime = block.timestamp;
            PlanIII[_user].StakeTime = block.timestamp;
            PlanIII[_user].UnStakeTime =
                block.timestamp +
                (StakeIII.StakePeriod);
            PlanIII[_user].Amount = (_amount);
        }
        
    }
 
    function getContractTokenBalance() public view returns (uint256) {
        return TOKEN.balanceOf(address(this));
    }
    function CalculatePerHour(uint256 amount, uint256 _VestingPeriod)
        internal
        view
        returns (uint256)
    {
        return (amount * (TimeStep)) / (_VestingPeriod);
    }
}
 
interface IERC20 {
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