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
interface IPair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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
contract foodfilpstaking is Ownable {
    address payable public distributor;
    // IPair public liquidityPair =
        // IPair(0x639bf1d9F3a683B28369708596aEfe38F2988e9C); // Main
    IPair public liquidityPair = IPair(0x223af7B2D3F2e0be90F0fd09F055d42Fe5b2b990); // Test
    // IERC20 public token = IERC20(0x64619f611248256F7F4b72fE83872F89d5d60d64); // Main
    IERC20 public token = IERC20(0xfCacB1e616F0Aa55378a68fb3A815444CFF9f9fc); // Test

    uint256 public totalStakedlp;
    uint256 public totalWithdrawanToken;
    uint256 public uniqueStakers;
    uint256 public totallpStakers;
    uint256[3] public withdrawDuration = [21 minutes, 30 minutes, 60 minutes];
    uint256[3] public tokenReward = [35,68,171];
    uint256 public percentdivider = 100_000;
    uint256 public minlp = 100e18;
    uint256 public withdrawTaxPercent = 15;
    uint256 public timestep = 1 minutes;

    struct lpStake {
        uint256 amount;
        uint256 time;
        uint256 reward;
        uint256 startTime;
    }


    struct User {
        bool isExists;
        mapping(uint256 => lpStake) lpStakes;
        mapping(uint256 => uint256) stakeCount;
        mapping(uint256 => uint256) totalStakedlp;
        mapping(uint256 => uint256) totalWithdrawanToken;
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
            require(_amount >= minlp, "stake more than min amount");
            liquidityPair.transferFrom(msg.sender, address(this), _amount);
            uint256 preReward = calculateTokenReward(msg.sender,_plan);
            stakeToken(msg.sender, _amount,_plan,preReward);
            users[msg.sender].lpStakes[_plan].startTime = block.timestamp;
            totallpStakers++;
        }

        emit STAKE(msg.sender, _amount);
    }

    function stakeToken(address _user, uint256 _amount,uint256 _plan,uint256 _prereward) private {
        User storage user = users[_user];
        users[msg.sender].lpStakes[_plan].amount += (_amount);
        users[msg.sender].lpStakes[_plan].time = block.timestamp;
        users[msg.sender].lpStakes[_plan].reward += _prereward;
        user.stakeCount[_plan]++;
        user.totalStakedlp[_plan] = user.totalStakedlp[_plan]+(_amount);
        totalStakedlp = totalStakedlp+(_amount);
    }


    function claim(uint256 _plan) public {
        require(_plan < 3, "Stake plan must be less than 3");
        require(users[msg.sender].lpStakes[_plan].time + timestep < block.timestamp, "Stake duration not completed");
        User storage user = users[msg.sender];
        uint256 preReward = calculateTokenReward(msg.sender,_plan);
            require(preReward > 0, "no reward yet");
            token.transferFrom(distributor, msg.sender, preReward);
            users[msg.sender].lpStakes[_plan].time = block.timestamp;
            user.totalWithdrawanToken[_plan] = user.totalWithdrawanToken[_plan]+(
                preReward
            );
        
        totalWithdrawanToken = totalWithdrawanToken+(preReward);
        
        emit CLAIM(msg.sender, preReward);
    }

    function withdraw(uint256 _plan) public {
        require(users[msg.sender].lpStakes[_plan].startTime + withdrawDuration[_plan] < block.timestamp, "Stake duration not completed");
        User storage user = users[msg.sender];
        uint256 amount;
        uint256 preReward;{
            amount = users[msg.sender].lpStakes[_plan].amount;
            
            liquidityPair.transfer(msg.sender, amount);
            preReward = calculateTokenReward(msg.sender,_plan);
            if (preReward > 0) {
                token.transferFrom(distributor, msg.sender, preReward);
            }
            users[msg.sender].lpStakes[_plan].amount = 0;
            users[msg.sender].lpStakes[_plan].reward = 0;
            users[msg.sender].lpStakes[_plan].time = block.timestamp;
            user.totalWithdrawanToken[_plan] = user.totalWithdrawanToken[_plan]+(amount);
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
        uint256 timeelapsed = block.timestamp-(users[_user].lpStakes[_plan].time);
        timeelapsed = timeelapsed/timestep;
        

        _reward = (getTokenForLP(users[_user].lpStakes[_plan].amount)+users[_user].lpStakes[_plan].reward)*timeelapsed*tokenReward[_plan]/percentdivider;
    }
    function getTokenReserve() public view returns (uint256) {
        (uint256 token0Reserve, uint256 token1Reserve, ) = liquidityPair
            .getReserves();
        if (liquidityPair.token0() == address(token)) {
            return token0Reserve;
        }
        return token1Reserve;
    }
    function getTokenForLP(uint256 _lpAmount) public view returns (uint256) {
        uint256 lpSupply = liquidityPair.totalSupply();
        uint256 totalReserveInToken = getTokenReserve() * 2;
        return (totalReserveInToken * _lpAmount) / lpSupply;
    }
    function getUserInfo(address _user,uint256 index)
        public
        view
        returns (
            bool _isExists,
            uint256 _stakeCount,
            uint256 _totalStakedlp,
            uint256 _totalWithdrawanToken
        )
    {
        User storage user = users[_user];
        _isExists = user.isExists;
        _stakeCount = user.stakeCount[index];
        _totalStakedlp = user.totalStakedlp[index];

        _totalWithdrawanToken = user.totalWithdrawanToken[index];
    }

    function userTokenStakeInfo(address _user,uint256 _plan)
        public
        view
        returns (
            uint256 _amount,
            uint256 _time,
            uint256 _reward,
            uint256 _startTime
        )
    {
        _amount = users[_user].lpStakes[_plan].amount;
        _time = users[_user].lpStakes[_plan].time;
        _reward = users[_user].lpStakes[_plan].reward;
        _startTime = users[_user].lpStakes[_plan].startTime;
    }


    function SetPoolsReward(
        uint256 [3] calldata tokenreward
    ) external onlyOwner {
        tokenReward = tokenreward;
        
    }

    function SetMinAmount(uint256 _token ) external onlyOwner {
        minlp = _token;
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