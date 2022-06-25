/**
 *Submitted for verification at BscScan.com on 2022-06-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-23
 */

/**
 *Submitted for verification at BscScan.com on 2022-06-02
 */

/**
 *Submitted for verification at BscScan.com on 2022-05-26
 */

/**
 *Submitted for verification at BscScan.com on 2022-05-21
 */

/**
 *Submitted for verification at BscScan.com on 2022-05-19
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256 r) {
        return ((a + m - 1) / m) * m;
    }
}

contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

interface IToken {
    function decimals() external view returns (uint256);

    function transfer(address to, uint256 tokens)
        external
        returns (bool success);

    function burnTokens(uint256 _amount) external;

    function balanceOf(address tokenOwner)
        external
        view
        returns (uint256 balance);

    function approve(address _spender, uint256 _amount)
        external
        returns (bool success);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IProxy {
    function getTierUserCount(uint256 _tier) external view returns (uint256);

    function getAllocationToken() external returns (uint256);

    function tierAllocationPerUser(uint256 supply, uint256 _tier)
        external
        view
        returns (uint256);

    function getUsertier(address _address) external view returns (uint256);
}

contract BitdriveLaunchpad is Owned {
    using SafeMath for uint256;
    address public tokenAddress; // buy
    uint256 public tokenDecimals = 18;

    address public _crypto; // cool
    address public PROXY;

    struct UserInfo {
        uint256 investAmount1;
        uint256 investAmount2;
        uint256 remainingallocationAmount1;
        uint256 remainingallocationAmount2;
        bool isExits;
        bool isround2;
        uint256 SwapTokens;
        uint256 round1Tokens;
        uint256 round2Tokens;
        uint256 round3Tokens;
        uint256 lastClaimed;
        uint256 totalVesting;
        uint256 claimableTokens;
    }

    mapping(address => UserInfo) public userInfo;

    uint256 public tokensPerBusd;
    uint256 public rateDecimals = 0;

    uint256 public soldTokens = 0;
    uint256 public round2Amount = 0;

    uint256 public endTime = 2 days;
    uint256 public round1Start;

    uint256 public round2Start;

    uint256 public round3Start;
    uint256 public end;

    uint256 public round2Eligible;

    uint256 public hardCap;

    uint256 public earnedCap = 0;

    uint256 public currentPoolId = 0;
    bool public isVest;
    uint256 public vestDays;
    uint256 public vestPercent;
    uint256 public currentTime;
    uint256 public test;
    uint256 public test1;

    constructor(
        address _tokenAddress,
        uint256 _tokensPerBusd,
        uint256 _hardCap,
        uint256 _poolId,
        address _owner,
        uint256 _round1,
        uint256 _round2,
        uint256 _round3,
        uint256 _end,
        address _busdAddress,
        bool _isVest,
        uint256 _vestPercent,
        uint256 _vestDays
    ) public {
        tokenAddress = _tokenAddress;
        tokensPerBusd = _tokensPerBusd; // 1 means 1000
        hardCap = _hardCap;
        round2Amount = _hardCap;
        currentPoolId = _poolId;
        owner = payable(_owner);
        PROXY = msg.sender;
        round1Start = _round1;
        round2Start = _round2;
        round3Start = _round3;
        end = _end;
        isVest = _isVest;
        vestPercent = _vestPercent;
        vestDays = _vestDays;
        _crypto = _busdAddress;
    }

    function getTokenPerBusd(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 getTier = IProxy(PROXY).getUsertier(_userAddress);
        uint256 perBusdToken = IProxy(PROXY).tierAllocationPerUser(
            hardCap,
            getTier
        );
        return perBusdToken; // original value id should divide by 1e18
    }

    function getTokenPerBusdtest(address _userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 getTier = IProxy(PROXY).getUsertier(_userAddress);
        uint256 perBusdToken = IProxy(PROXY).tierAllocationPerUser(
            hardCap,
            getTier
        );
        return (getTier, hardCap, perBusdToken); // original value id should divide by 1e18
    }

    function checkBronzeUserCount() internal view returns (uint256) {
        return IProxy(PROXY).getTierUserCount(1);
    }

    function getTokenPerUser() public view returns (uint256) {
        //get Bronze Users
        uint256 brozeUser = checkBronzeUserCount();
        uint256 round2Users = brozeUser + round2Eligible;
        uint256 totalSupply = hardCap * 1e18;
        uint256 remainingTokens = (totalSupply >= round2Amount)
            ? totalSupply - round2Amount
            : 0;
        uint256 eachTier = (remainingTokens > 0 && round2Users > 0)
            ? remainingTokens / round2Users
            : 0;
        uint256 perBusdRound2 = eachTier;
        return perBusdRound2;
    }

    function getUserAllocationRound1(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 remainingAllocation = getTokenPerBusd(msg.sender);
        uint256 remainingallocationAmount = remainingAllocation -
            userInfo[_userAddress].investAmount1;
        return remainingallocationAmount;
    }

    function getUserAllocationRound1test(address _userAddress)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 remainingAllocation = getTokenPerBusd(msg.sender);
        uint256 remainingallocationAmount = remainingAllocation -
            userInfo[_userAddress].investAmount1;
        return (
            remainingAllocation,
            userInfo[_userAddress].investAmount1,
            remainingallocationAmount
        );
    }

    function getUserAllocationRound2(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 remainingAllocation = getTokenPerUser();
        uint256 remainingallocationAmount = remainingAllocation -
            userInfo[_userAddress].investAmount2;
        return remainingallocationAmount;
    }

    function buyTokenRound1(uint256 amount) public {
        require(block.timestamp >= round1Start, "Presale is not open.");
        require(block.timestamp < round2Start, "Sale Closed.");
        require(earnedCap <= hardCap * 1e18, "Reached hardCap");
        //check user remaining allocation
        uint256 getTier = IProxy(PROXY).getUsertier(msg.sender);
        require(getTier > 1, "Not a valid User");
        uint256 remainingAllocation = getTokenPerBusd(msg.sender);
        userInfo[msg.sender].investAmount1 += amount;
        userInfo[msg.sender].isExits = true;
        require(
            remainingAllocation >= userInfo[msg.sender].investAmount1,
            "Amount not exceed"
        );
        TransferHelper.safeTransferFrom(
            _crypto,
            msg.sender,
            address(this),
            amount
        );
        userInfo[msg.sender].remainingallocationAmount1 =
            remainingAllocation -
            userInfo[msg.sender].investAmount1;
        uint256 swappedToken = (tokensPerBusd * amount) / 1000;
        userInfo[msg.sender].SwapTokens += swappedToken;
        userInfo[msg.sender].round1Tokens += swappedToken;
        userInfo[msg.sender].claimableTokens += swappedToken;
        if (!userInfo[msg.sender].isround2) {
            uint256 halfAmount = remainingAllocation / 2;
            test = halfAmount;
            test1 = remainingAllocation;
            if (userInfo[msg.sender].investAmount1 >= halfAmount) {
                userInfo[msg.sender].isround2 = true;
                round2Eligible++;
            }
        }
        earnedCap += amount;
        soldTokens += swappedToken;
        round2Amount += amount;
    }

    function buyTokenRound2(uint256 amount) public {
        require(block.timestamp >= round2Start, "Not started.");
        require(block.timestamp < round3Start, "Sale Closed.");
        uint256 eligibleAmt = earnedCap.add(amount);
        require(eligibleAmt <= hardCap * 1e18, "Reached hardCap");
        //check user remaining allocation
        uint256 remainingAllocation = getTokenPerUser();
        userInfo[msg.sender].isExits = true;
        userInfo[msg.sender].investAmount2 += amount;
        uint256 getTier = IProxy(PROXY).getUsertier(msg.sender);
        require(
            userInfo[msg.sender].isround2 || getTier == 1,
            "User Not eligible to participate"
        );
        require(
            remainingAllocation >= userInfo[msg.sender].investAmount2,
            "Amount not exceed"
        );
        TransferHelper.safeTransferFrom(
            _crypto,
            msg.sender,
            address(this),
            amount
        );
        userInfo[msg.sender].remainingallocationAmount2 =
            remainingAllocation -
            userInfo[msg.sender].investAmount2;
        uint256 swappedToken = (tokensPerBusd * amount) / 1000;
        userInfo[msg.sender].SwapTokens += swappedToken;
        userInfo[msg.sender].round2Tokens += swappedToken;
        userInfo[msg.sender].claimableTokens += swappedToken;
        earnedCap += amount;
        soldTokens += swappedToken;
    }

    function buyTokenRound3(uint256 amount) public {
        require(block.timestamp >= round3Start, "Not started.");
        require(block.timestamp < end, "Sale Closed.");
        uint256 eligibleAmt = earnedCap.add(amount);
        require(eligibleAmt <= hardCap * 1e18, "Reached hardCap");
        TransferHelper.safeTransferFrom(
            _crypto,
            msg.sender,
            address(this),
            amount
        );
        //check user remaining allocation
        uint256 swappedToken = (tokensPerBusd * amount) / 1000;
        userInfo[msg.sender].SwapTokens += swappedToken;
        userInfo[msg.sender].round3Tokens += swappedToken;
        userInfo[msg.sender].claimableTokens += swappedToken;
        earnedCap += amount;
        soldTokens += swappedToken;
    }

    function claimToken() public {
        require(block.timestamp > end, "Sale Not Closed.");
        require(userInfo[msg.sender].claimableTokens > 0, "You already taken");
        if (!isVest) {
            uint256 transferAmount = userInfo[msg.sender].SwapTokens;
            IToken(tokenAddress).transfer(msg.sender, transferAmount);
            userInfo[msg.sender].claimableTokens = 0;
        } else {
            uint256 lastClaimed = userInfo[msg.sender].lastClaimed;
            if (lastClaimed == 0) {
                lastClaimed = end;
            }

            // require(
            //     block.timestamp >
            //         lastClaimed * vestDays * 1 days,
            //     "Vesting period error"
            // );
            require(
                block.timestamp > (lastClaimed + 5 minutes),
                "Vesting period error"
            );

            (uint256 available, uint256 Percentage, ) = availableVesting(
                msg.sender
            );
            require(available > 0, "insufficient reward");

            userInfo[msg.sender].totalVesting += Percentage;
            require(
                IToken(tokenAddress).transfer(msg.sender, available),
                "Insufficient balance of presale contract!"
            );
            userInfo[msg.sender].claimableTokens = userInfo[msg.sender]
                .claimableTokens
                .sub(available);
            userInfo[msg.sender].lastClaimed = block.timestamp;
        }
    }

    function availableVesting(address _user)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        //uint256 vestingPeriod = 86400 * vestDays;

        uint256 lastClaimed = userInfo[msg.sender].lastClaimed;
        if (lastClaimed == 0) {
            lastClaimed = end;
        }

        uint256 diff = 0;
        if (lastClaimed < block.timestamp) {
            diff = block.timestamp - lastClaimed;
        }

        uint256 vestingPeriod = 5 minutes;
        diff = (block.timestamp > lastClaimed)
            ? block.timestamp - lastClaimed
            : 0;
        uint256 calcVesting = diff / vestingPeriod;

        //uint calcVesting = (diff>0 && vestingPeriod>0)?diff / vestingPeriod:0;
        uint256 invest = userInfo[_user].SwapTokens;
        uint256 available = 0;
        uint256 Percentage = 0;
        if (userInfo[_user].claimableTokens > 0 && diff > 0) {
            uint256 totalVesting = userInfo[msg.sender].totalVesting +
                vestPercent;
            Percentage = vestPercent;
            if (totalVesting > 10000) {
                available = userInfo[_user].claimableTokens;
                Percentage = 10000 - userInfo[msg.sender].totalVesting;
            } else {
                available =
                    (uint256(calcVesting) * invest.mul(vestPercent)) /
                    10000;
                Percentage = vestPercent * calcVesting;
            }

            if (available > invest) {
                available = invest - userInfo[_user].claimableTokens;
                Percentage = 10000 - userInfo[msg.sender].totalVesting;
            }
        }

        return (available, Percentage, diff);
    }

    function setTokenAddress(address token) external onlyOwner {
        tokenAddress = token;
    }

    function setCurrentPoolId(uint256 _pid) external onlyOwner {
        currentPoolId = _pid;
    }

    function setTokenDecimals(uint256 decimals) external onlyOwner {
        tokenDecimals = decimals;
    }

    function setCryptoAddress(address token) external onlyOwner {
        _crypto = token;
    }

    function setCryptoAddress1(address token) external onlyOwner {
        _crypto = token;
    }

    function setRoundtiming(
        uint256 _round1,
        uint256 _round2,
        uint256 _round3,
        uint256 _end
    ) external onlyOwner {
        require(
            _round1 > block.timestamp &&
                _round2 > _round1 &&
                _round3 > _round2 &&
                _end > _round3,
            "Invalid time"
        );
        round1Start = _round1;
        round2Start = _round2;
        round3Start = _round3;
        end = _end;
    }

    function settokensPerBusd(uint256 tokenPerBusd) external onlyOwner {
        tokensPerBusd = tokenPerBusd;
    }

    function setRateDecimals(uint256 decimals) external onlyOwner {
        rateDecimals = decimals;
    }

    function setHardCap(uint256 _hardCap) public onlyOwner {
        hardCap = _hardCap;
    }

    function getUnsoldTokensBalance() public view returns (uint256) {
        return IToken(tokenAddress).balanceOf(address(this));
    }

    function burnUnsoldTokens() external onlyOwner {
        require(
            block.timestamp > end,
            "You cannot burn tokens untitl the presale is closed."
        );
        IToken(tokenAddress).burnTokens(
            IToken(tokenAddress).balanceOf(address(this))
        );
    }

    function getUnsoldTokens() external onlyOwner {
        require(
            block.timestamp > end,
            "You cannot get tokens until the presale is closed."
        );
        soldTokens = 0;
        IToken(tokenAddress).transfer(
            owner,
            (IToken(tokenAddress).balanceOf(address(this)))
        );
    }

    function getBusdTokens() external onlyOwner {
        require(
            block.timestamp > end,
            "You cannot get tokens until the presale is closed."
        );
        IToken(_crypto).transfer(
            owner,
            (IToken(_crypto).balanceOf(address(this)))
        );
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "BSC_TRANSFER_FAILED");
    }
}

// File: contracts/UniswapV2ERC20.sol

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(
            _initializing || !_initialized,
            "Initializable: contract is already initialized"
        );

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

contract Proxy is ContextUpgradeable, OwnableUpgradeable {
    mapping(address => address) public _presale;
    uint256 public stakeDays;
    IToken public tokenAddress;
    address public safeToken;
    struct UserInfo {
        uint256 depositamount;
        uint256 tier;
        bool isExits;
        uint256 investTime;
    }

    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => uint256) public STAKING_PRICE;
    mapping(uint256 => uint256) public POOL_WEIGHT;
    uint256 public Bronzeusers;
    uint256 public Silverusers;
    uint256 public Goldusers;
    uint256 public Diamondusers;
    uint256 public totalparticipant;
    address public ownerAddress;

    constructor() public {}

    function initialize(IToken _tokenAddress, uint256 _stakeDays)
        public
        initializer
    {
        tokenAddress = IToken(_tokenAddress);
        STAKING_PRICE[1] = 10 * 1e18;
        STAKING_PRICE[2] = 100 * 1e18;
        STAKING_PRICE[3] = 500 * 1e18;
        STAKING_PRICE[4] = 1000 * 1e18;
        POOL_WEIGHT[1] = 10;
        POOL_WEIGHT[2] = 30;
        POOL_WEIGHT[3] = 60;
        stakeDays = _stakeDays;
        ownerAddress = msg.sender;
    }

    function deposit(uint256 _amount) public {
        require(!userInfo[msg.sender].isExits, "User already exist");
        require(
            (IToken(tokenAddress).balanceOf(msg.sender)) >= STAKING_PRICE[1] &&
                _amount >= STAKING_PRICE[1],
            "You dont have minimum balance"
        );
        // require(
        //     IToken(tokenAddress).transferFrom(
        //         msg.sender,
        //         address(this),
        //         _amount
        //     ),
        //     "Insufficient balance from User"
        // );
        TransferHelper.safeTransferFrom(
            safeToken,
            msg.sender,
            address(this),
            _amount
        );
        totalparticipant++;
        uint256 tier;
        if (_amount >= STAKING_PRICE[1] && _amount < STAKING_PRICE[2]) {
            Bronzeusers++;
            tier = 1;
        } else if (_amount >= STAKING_PRICE[2] && _amount < STAKING_PRICE[3]) {
            Silverusers++;
            tier = 2;
        } else if (_amount >= STAKING_PRICE[3] && _amount < STAKING_PRICE[4]) {
            Goldusers++;
            tier = 3;
        } else if (_amount >= STAKING_PRICE[4]) {
            Diamondusers++;
            tier = 4;
        }
        userInfo[msg.sender].isExits = true;
        userInfo[msg.sender].tier = tier;
        userInfo[msg.sender].investTime = block.timestamp;
        userInfo[msg.sender].depositamount = _amount;
    }

    function unstakeTest(address _user, uint256 numberOfdays) public {
        uint256 Days = numberOfdays * (1 days);
        uint256 changeTime = block.timestamp - Days;
        userInfo[_user].investTime = changeTime;
    }

    function withdraw() public {
        require(userInfo[msg.sender].isExits, "User not exist");
        uint256 endTime = userInfo[msg.sender].investTime + stakeDays * 1 days;
        require(endTime < block.timestamp, "Lock period not completed");

        IToken(tokenAddress).transfer(
            msg.sender,
            userInfo[msg.sender].depositamount
        );

        totalparticipant--;
        uint256 tier = userInfo[msg.sender].tier;
        if (tier == 1) {
            Bronzeusers--;
        } else if (tier == 2) {
            Silverusers--;
        } else if (tier == 3) {
            Goldusers--;
        } else if (tier == 4) {
            Diamondusers--;
        }
        userInfo[msg.sender].isExits = false;
        userInfo[msg.sender].tier = 0;
    }

    function getTierUserCount(uint256 _tier) public view returns (uint256) {
        uint256 tierCount;
        if (_tier == 1) {
            tierCount = Bronzeusers;
        } else if (_tier == 2) {
            tierCount = Silverusers;
        } else if (_tier == 3) {
            tierCount = Goldusers;
        } else if (_tier == 4) {
            tierCount = Diamondusers;
        }
        return tierCount;
    }

    function createPresale(
        address _tokenAddress,
        uint256 _tokensPerBusd,
        uint256 _hardCap,
        uint256 _poolId,
        uint256 _round1start,
        uint256 _round2start,
        uint256 _round3start,
        uint256 _end,
        address _busdAddress,
        bool isVest,
        uint256 vestPercent, // 1 means 100
        uint256 vestDays
    ) public {
        require(ownerAddress == msg.sender, "Not an Owner");
        _presale[_tokenAddress] = address(
            new BitdriveLaunchpad(
                _tokenAddress,
                _tokensPerBusd,
                _hardCap,
                _poolId,
                msg.sender,
                _round1start,
                _round2start,
                _round3start,
                _end,
                _busdAddress,
                isVest,
                vestPercent,
                vestDays
            )
        );
    }

    function getAllocationToken() public view returns (uint256) {
        return
            (Silverusers * POOL_WEIGHT[1]) +
            (Goldusers * POOL_WEIGHT[2]) +
            (Diamondusers * POOL_WEIGHT[3]);
    }

    function tierAllocationPerUser(uint256 maxSupply, uint256 _tier)
        public
        view
        returns (uint256)
    {
        uint256 getallocationToken = getAllocationToken();
        uint256 eachTier = (getallocationToken > 0)
            ? (maxSupply * 1e18) / getallocationToken
            : 0;
        uint256 silverAllocation = Silverusers * eachTier * POOL_WEIGHT[1];
        uint256 goldAllocation = Goldusers * eachTier * POOL_WEIGHT[2];
        uint256 diamondAllocation = Diamondusers * eachTier * POOL_WEIGHT[3];
        uint256 allocToken = 0;
        if (_tier == 2 && Silverusers > 0 && silverAllocation > 0)
            allocToken = silverAllocation / Silverusers;
        if (_tier == 3 && Goldusers > 0 && goldAllocation > 0)
            allocToken = goldAllocation / Goldusers;
        if (_tier == 4 && Diamondusers > 0 && diamondAllocation > 0)
            allocToken = diamondAllocation / Diamondusers;

        return allocToken;
    }

    function getUsertier(address _useraddress) public view returns (uint256) {
        return userInfo[_useraddress].tier;
    }

    function getPresale(address _token) public view returns (address) {
        return _presale[_token];
    }

    function setStakeDays(uint256 _days) public {
        require(ownerAddress == msg.sender, "Not an Owner");
        stakeDays = _days;
    }
}