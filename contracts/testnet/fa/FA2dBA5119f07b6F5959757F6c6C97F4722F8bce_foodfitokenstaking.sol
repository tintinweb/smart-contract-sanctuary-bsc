// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address payable owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract foodfitokenstaking is Ownable {
    address payable public distributor;
    // IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64); // Main
    IERC20 public token = IERC20(0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc); // Test

    uint256 public totalStakedToken;
    uint256 public totalWithdrawanToken;
    uint256 public uniqueStakers;
    uint256 public totalTokenStakers;
    uint256[3] public withdrawDuration = [21 minutes, 30 minutes, 60 minutes];
    uint256[3] public tokenReward = [35,68,171];
    uint256 public percentdivider = 100_000;
    uint256 public minToken = 100e18;
    uint256 public withdrawTaxPercent = 15;
    uint256 public timestep = 1 minutes;

    struct TokenStake {
        uint256 amount;
        uint256 time;
        uint256 startTime;
    }


    struct User {
        bool isExists;
        mapping(uint256 => TokenStake) tokenStakes;
        uint256 stakeCount;
        uint256 totalStakedToken;
        uint256 totalWithdrawanToken;
    }

    mapping(address => User) users;

    event STAKE(address Staker, uint256 amount);
    event CLAIM(address Staker, uint256 amount);
    event WITHDRAW(address Staker, uint256 amount);
    event RESTAKE(address staker, uint256 amount);

    constructor()
        Ownable(payable(msg.sender))
    {
        distributor = payable(msg.sender);
    }

    function stake(uint256 _amount, uint256 _plan) public {
        require(_amount > 0, "Stake amount must be greater than 0");
        require(_plan < 3, "Stake plan must be less than 3");
        if (!users[msg.sender].isExists) {
            users[msg.sender].isExists = true;
            uniqueStakers++;
        }
        {
            require(_amount >= minToken, "stake more than min amount");
            token.transferFrom(msg.sender, address(this), _amount);
            uint256 preReward = calculateTokenReward(msg.sender,_plan);
            if(preReward > 0) {
                token.transferFrom(distributor,address(this), preReward);
            }
            stakeToken(msg.sender, _amount+preReward,_plan);
            users[msg.sender].tokenStakes[_plan].startTime = block.timestamp;
            totalTokenStakers++;
        }

        emit STAKE(msg.sender, _amount);
    }

    function stakeToken(address _user, uint256 _amount,uint256 _plan) private {
        User storage user = users[_user];
        users[msg.sender].tokenStakes[_plan].amount += (_amount);
        users[msg.sender].tokenStakes[_plan].time = block.timestamp;
        user.stakeCount++;
        user.totalStakedToken = user.totalStakedToken+(_amount);
        totalStakedToken = totalStakedToken+(_amount);
    }


    function claim(uint256 _plan) public {
        require(_plan < 3, "Stake plan must be less than 3");
        require(users[msg.sender].tokenStakes[_plan].startTime + withdrawDuration[_plan] < block.timestamp, "Stake duration not completed");
        User storage user = users[msg.sender];
        uint256 preReward = calculateTokenReward(msg.sender,_plan);
            require(preReward > 0, "no reward yet");
            token.transferFrom(distributor, msg.sender, preReward);
            users[msg.sender].tokenStakes[_plan].time = block.timestamp;
            user.totalWithdrawanToken = user.totalWithdrawanToken+(
                preReward
            );
        
        totalWithdrawanToken = totalWithdrawanToken+(preReward);

        emit CLAIM(msg.sender, preReward);
    }

    function withdraw(uint256 _plan) public {
        require(users[msg.sender].tokenStakes[_plan].startTime + withdrawDuration[_plan] < block.timestamp, "Stake duration not completed");
        User storage user = users[msg.sender];
        uint256 amount;
        uint256 preReward;{
            amount = users[msg.sender].tokenStakes[_plan].amount;
            
            token.transfer(msg.sender, amount);
            preReward = calculateTokenReward(msg.sender,_plan);
            if (preReward > 0) {
                token.transferFrom(distributor, msg.sender, preReward);
            }
            users[msg.sender].tokenStakes[_plan].amount = 0;
            users[msg.sender].tokenStakes[_plan].time = block.timestamp;
            user.totalWithdrawanToken = user.totalWithdrawanToken+(amount);
            totalWithdrawanToken = totalWithdrawanToken+(amount);
        } 
        emit WITHDRAW(msg.sender, amount);
        emit CLAIM(msg.sender, preReward);
    }

    function calculateTokenReward(address _user, uint256 _plan)
        public
        view
        returns (uint256 _reward)
    {
        uint256 timeelapsed = block.timestamp-(users[_user].tokenStakes[_plan].time);
        timeelapsed = timeelapsed/timestep;
        

        _reward = users[_user].tokenStakes[_plan].amount*timeelapsed*(tokenReward[_plan]/percentdivider);
    }
    function getUserInfo(address _user)
        public
        view
        returns (
            bool _isExists,
            uint256 _stakeCount,
            uint256 _totalStakedToken,
            uint256 _totalWithdrawanToken
        )
    {
        User storage user = users[_user];
        _isExists = user.isExists;
        _stakeCount = user.stakeCount;
        _totalStakedToken = user.totalStakedToken;

        _totalWithdrawanToken = user.totalWithdrawanToken;
    }

    function userTokenStakeInfo(address _user,uint256 _plan)
        public
        view
        returns (
            uint256 _amount,
            uint256 _time,
            uint256 _startTime
        )
    {
        _amount = users[_user].tokenStakes[_plan].amount;
        _time = users[_user].tokenStakes[_plan].time;
        _startTime = users[_user].tokenStakes[_plan].startTime;
    }


    function SetPoolsReward(
        uint256 [3] calldata tokenreward
    ) external onlyOwner {
        tokenReward = tokenreward;
        
    }

    function SetMinAmount(uint256 _token ) external onlyOwner {
        minToken = _token;
    }

    function SetWithdrawTaxAndDuration(uint256 _tax, uint256 [3] calldata _duration)
        external
        onlyOwner
    {
        withdrawTaxPercent = _tax;
        withdrawDuration = _duration;
    }

    function ChangeDistributor(address payable _distributor)
        external
        onlyOwner
    {
        distributor = _distributor;
    }
}