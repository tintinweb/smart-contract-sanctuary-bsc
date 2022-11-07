// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Ownable.sol";
import "./IERC20.sol";
import "./ICorisPool.sol";
import "./IMasterChefV2.sol";
import "./IterateMapping.sol";

contract FarmBooster is Ownable {
    using IterableMapping for ItMap;

    /// @notice coris token.
    address public immutable CORIS;
    /// @notice coris pool.
    address public immutable CORIS_POOL;
    /// @notice MCV2 contract.
    address public immutable MASTER_CHEF;
    /// @notice boost proxy factory.
    address public BOOSTER_FACTORY;

    /// @notice Maximum allowed boosted pool numbers
    uint256 public MAX_BOOST_POOL;
    /// @notice limit max boost
    uint256 public cA;
    /// @notice include 1e4
    uint256 public constant MIN_CA = 1e4;
    /// @notice include 1e5
    uint256 public constant MAX_CA = 1e5;
    /// @notice cA precision
    uint256 public constant CA_PRECISION = 1e5;
    /// @notice controls difficulties
    uint256 public cB;
    /// @notice not include 0
    uint256 public constant MIN_CB = 0;
    /// @notice include 50
    uint256 public constant MAX_CB = 50;
    /// @notice MCV2 basic boost factor, none boosted user's boost factor
    uint256 public constant BOOST_PRECISION = 100 * 1e10;
    /// @notice MCV2 Hard limit for maxmium boost factor
    uint256 public constant MAX_BOOST_PRECISION = 200 * 1e10;
    /// @notice Average boost ratio precion
    uint256 public constant BOOST_RATIO_PRECISION = 1e5;
    /// @notice coris pool BOOST_WEIGHT precision
    uint256 public constant BOOST_WEIGHT_PRECISION = 100 * 1e10; // 100%

    /// @notice The whitelist of pools allowed for farm boosting.
    mapping(uint256 => bool) public whiteList;
    /// @notice The boost proxy contract mapping(user => proxy).
    mapping(address => address) public proxyContract;
    /// @notice Info of each pool user.
    mapping(address => ItMap) public userInfo;

    event UpdateMaxBoostPool(uint256 factory);
    event UpdateBoostFactory(address factory);
    event UpdateCA(uint256 oldCA, uint256 newCA);
    event UpdateCB(uint256 oldCB, uint256 newCB);
    event Refresh(address indexed user, address proxy, uint256 pid);
    event UpdateBoostFarms(uint256 pid, bool status);
    event ActiveFarmPool(address indexed user, address proxy, uint256 pid);
    event DeactiveFarmPool(address indexed user, address proxy, uint256 pid);
    event UpdateBoostProxy(address indexed user, address proxy);
    event UpdatePoolBoostMultiplier(address indexed user, uint256 pid, uint256 oldMultiplier, uint256 newMultiplier);
    event UpdateCorisPool(
        address indexed user,
        uint256 lockedAmount,
        uint256 lockedDuration,
        uint256 totalLockedAmount,
        uint256 maxLockDuration
    );

    /// @param _coris coris token contract address.
    /// @param _corisPool coris Pool contract address.
    /// @param _v2 MasterChefV2 contract address.
    /// @param _max Maximum allowed boosted farm  quantity
    /// @param _cA Limit max boost
    /// @param _cB Controls difficulties
    constructor(
        address _coris,
        address _corisPool,
        address _v2,
        uint256 _max,
        uint256 _cA,
        uint256 _cB
    ) {
        require(
            _max > 0 && _cA >= MIN_CA && _cA <= MAX_CA && _cB > MIN_CB && _cB <= MAX_CB,
            "constructor: Invalid parameter"
        );
        CORIS = _coris;
        CORIS_POOL = _corisPool;
        MASTER_CHEF = _v2;
        MAX_BOOST_POOL = _max;
        cA = _cA;
        cB = _cB;
    }

    /// @notice Checks if the msg.sender is a contract or a proxy
    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    /// @notice Checks if the msg.sender is the FarmBooster Factory.
    modifier onlyFactory() {
        require(msg.sender == BOOSTER_FACTORY, "onlyFactory: Not factory");
        _;
    }

    /// @notice Checks if the msg.sender is the FarmBooster Proxy.
    modifier onlyProxy(address _user) {
        require(msg.sender == proxyContract[_user], "onlyProxy: Not proxy");
        _;
    }

    /// @notice Checks if the msg.sender is the coris pool.
    modifier onlyCorisPool() {
        require(msg.sender == CORIS_POOL, "onlyCorisPool: Not coris pool");
        _;
    }

    /// @notice set maximum allowed boosted pool numbers.
    function setMaxBoostPool(uint256 _max) external onlyOwner {
        require(_max > 0, "setMaxBoostPool: Maximum boost pool should greater than 0");
        MAX_BOOST_POOL = _max;
        emit UpdateMaxBoostPool(_max);
    }

    /// @notice set boost factory contract.
    function setBoostFactory(address _factory) external onlyOwner {
        require(_factory != address(0), "setBoostFactory: Invalid factory");
        BOOSTER_FACTORY = _factory;

        emit UpdateBoostFactory(_factory);
    }

    /// @notice Set user boost proxy contract, can only invoked by boost contract.
    /// @param _user boost user address.
    /// @param _proxy boost proxy contract.
    function setProxy(address _user, address _proxy) external onlyFactory {
        require(_proxy != address(0), "setProxy: Invalid proxy address");
        require(proxyContract[_user] == address(0), "setProxy: User has already set proxy");

        proxyContract[_user] = _proxy;

        emit UpdateBoostProxy(_user, _proxy);
    }

    /// @notice Only allow whitelisted pids for farm boosting
    /// @param _pid pool id(MasterchefV2 pool).
    /// @param _status farm pool allowed boosted or not
    function setBoosterFarms(uint256 _pid, bool _status) external onlyOwner {
        whiteList[_pid] = _status;
        emit UpdateBoostFarms(_pid, _status);
    }

    /// @notice limit max boost
    /// @param _cA max boost
    function setCA(uint256 _cA) external onlyOwner {
        require(_cA >= MIN_CA && _cA <= MAX_CA, "setCA: Invalid cA");
        uint256 temp = cA;
        cA = _cA;
        emit UpdateCA(temp, cA);
    }

    /// @notice controls difficulties
    /// @param _cB difficulties
    function setCB(uint256 _cB) external onlyOwner {
        require(_cB > MIN_CB && _cB <= MAX_CB, "setCB: Invalid cB");
        uint256 temp = cB;
        cB = _cB;
        emit UpdateCB(temp, cB);
    }

    /// @notice Corispool operation(deposit/withdraw) automatically call this function.
    /// @param _user user address.
    /// @param _lockedAmount user locked amount in coris pool.
    /// @param _lockedDuration user locked duration in coris pool.
    /// @param _totalLockedAmount Total locked coris amount in coris pool.
    /// @param _maxLockDuration maximum locked duration in coris pool.
    function onCorisPoolUpdate(
        address _user,
        uint256 _lockedAmount,
        uint256 _lockedDuration,
        uint256 _totalLockedAmount,
        uint256 _maxLockDuration
    ) external onlyCorisPool {
        address proxy = proxyContract[_user];
        ItMap storage itmap = userInfo[proxy];
        uint256 avgDuration;
        bool flag;
        for (uint256 i = 0; i < itmap.keys.length; i++) {
            uint256 pid = itmap.keys[i];
            if (!flag) {
                avgDuration = avgLockDuration();
                flag = true;
            }
            _updateBoostMultiplier(_user, proxy, pid, avgDuration);
        }

        emit UpdateCorisPool(_user, _lockedAmount, _lockedDuration, _totalLockedAmount, _maxLockDuration);
    }

    /// @notice Update user boost multiplier in V2 pool,only for proxy.
    /// @param _user user address.
    /// @param _pid pool id in MasterchefV2 pool.
    function updatePoolBoostMultiplier(address _user, uint256 _pid) public onlyProxy(_user) {
        // if user not actived this farm, just return.
        if (!userInfo[msg.sender].contains(_pid)) return;
        _updateBoostMultiplier(_user, msg.sender, _pid, avgLockDuration());
    }

    /// @notice Active user farm pool.
    /// @param _pid pool id(MasterchefV2 pool).
    function activate(uint256 _pid) external {
        address proxy = proxyContract[msg.sender];
        require(whiteList[_pid] && proxy != address(0), "activate: Not boosted farm pool");

        ItMap storage itmap = userInfo[proxy];
        require(itmap.keys.length < MAX_BOOST_POOL, "activate: Boosted farms reach to MAX");

        _updateBoostMultiplier(msg.sender, proxy, _pid, avgLockDuration());

        emit ActiveFarmPool(msg.sender, proxy, _pid);
    }

    /// @notice Deactive user farm pool.
    /// @param _pid pool id(MasterchefV2 pool).
    function deactive(uint256 _pid) external {
        address proxy = proxyContract[msg.sender];
        ItMap storage itmap = userInfo[proxy];
        require(itmap.contains(_pid), "deactive: None boost user");

        if (itmap.data[_pid] > BOOST_PRECISION) {
            IMasterChefV2(MASTER_CHEF).updateBoostMultiplier(proxy, _pid, BOOST_PRECISION);
        }
        itmap.remove(_pid);

        emit DeactiveFarmPool(msg.sender, proxy, _pid);
    }

    /// @notice Anyone can refesh sepecific user boost multiplier
    /// @param _user user address.
    /// @param _pid pool id(MasterchefV2 pool).
    function refresh(address _user, uint256 _pid) external notContract {
        address proxy = proxyContract[_user];
        ItMap storage itmap = userInfo[proxy];
        require(itmap.contains(_pid), "refresh: None boost user");

        _updateBoostMultiplier(_user, proxy, _pid, avgLockDuration());

        emit Refresh(_user, proxy, _pid);
    }

    /// @notice Whether user boosted specific farm pool.
    /// @param _user user address.
    /// @param _pid pool id(MasterchefV2 pool).
    function isBoostedPool(address _user, uint256 _pid) external view returns (bool) {
        return userInfo[proxyContract[_user]].contains(_pid);
    }

    /// @notice Actived farm pool list.
    /// @param _user user address.
    function activedPools(address _user) external view returns (uint256[] memory pools) {
        ItMap storage itmap = userInfo[proxyContract[_user]];
        if (itmap.keys.length == 0) return pools;

        pools = new uint256[](itmap.keys.length);
        // solidity for-loop not support multiple variables initializae by ',' separate.
        uint256 i;
        for (uint256 index = 0; index < itmap.keys.length; index++) {
            uint256 pid = itmap.keys[index];
            pools[i] = pid;
            i++;
        }
    }

    /// @notice Anyone can call this function, if you find some guys effectived multiplier is not fair
    /// for other users, just call 'refresh' function.
    /// @param _user user address.
    /// @param _pid pool id(MasterchefV2 pool).
    /// @dev If return value not in range [BOOST_PRECISION, MAX_BOOST_PRECISION]
    /// the actual effectived multiplier will be the close to side boundry value.
    function getUserMultiplier(address _user, uint256 _pid) external view returns (uint256) {
        return _boostCalculate(_user, proxyContract[_user], _pid, avgLockDuration());
    }

    /// @notice coris pool average locked duration calculator.
    function avgLockDuration() public view returns (uint256) {
        uint256 totalStakedAmount = IERC20(CORIS).balanceOf(CORIS_POOL);

        uint256 totalLockedAmount = ICorisPool(CORIS_POOL).totalLockedAmount();

        uint256 pricePerFullShare = ICorisPool(CORIS_POOL).getPricePerFullShare();

        uint256 flexibleShares = ((totalStakedAmount - totalLockedAmount) * 1e18) / pricePerFullShare;
        if (flexibleShares == 0) return 0;

        uint256 originalShares = (totalLockedAmount * 1e18) / pricePerFullShare;
        if (originalShares == 0) return 0;

        uint256 boostedRatio = ((ICorisPool(CORIS_POOL).totalShares() - flexibleShares) * BOOST_RATIO_PRECISION) /
            originalShares;
        if (boostedRatio <= BOOST_RATIO_PRECISION) return 0;

        uint256 boostWeight = ICorisPool(CORIS_POOL).BOOST_WEIGHT();
        uint256 maxLockDuration = ICorisPool(CORIS_POOL).MAX_LOCK_DURATION() * BOOST_RATIO_PRECISION;

        uint256 duration = ((boostedRatio - BOOST_RATIO_PRECISION) * 365 * BOOST_WEIGHT_PRECISION) / boostWeight;
        return duration <= maxLockDuration ? duration : maxLockDuration;
    }

    /// @param _user user address.
    /// @param _proxy proxy address corresponding to the user.
    /// @param _pid pool id.
    /// @param _duration coris pool average locked duration.
    function _updateBoostMultiplier(
        address _user,
        address _proxy,
        uint256 _pid,
        uint256 _duration
    ) internal {
        ItMap storage itmap = userInfo[_proxy];

        // Used to be boost farm pool and current is not, remove from mapping
        if (!whiteList[_pid]) {
            if (itmap.data[_pid] > BOOST_PRECISION) {
                // reset to BOOST_PRECISION
                IMasterChefV2(MASTER_CHEF).updateBoostMultiplier(_proxy, _pid, BOOST_PRECISION);
            }
            itmap.remove(_pid);
            return;
        }

        uint256 prevMultiplier = IMasterChefV2(MASTER_CHEF).getBoostMultiplier(_proxy, _pid);
        uint256 multiplier = _boostCalculate(_user, _proxy, _pid, _duration);

        if (multiplier < BOOST_PRECISION) {
            multiplier = BOOST_PRECISION;
        } else if (multiplier > MAX_BOOST_PRECISION) {
            multiplier = MAX_BOOST_PRECISION;
        }

        // Update multiplier to MCV2
        if (multiplier != prevMultiplier) {
            IMasterChefV2(MASTER_CHEF).updateBoostMultiplier(_proxy, _pid, multiplier);
        }
        itmap.insert(_pid, multiplier);

        emit UpdatePoolBoostMultiplier(_user, _pid, prevMultiplier, multiplier);
    }

    /// @param _user user address.
    /// @param _proxy proxy address corresponding to the user.
    /// @param _pid pool id(MasterchefV2 pool).
    /// @param _duration coris pool average locked duration.
    function _boostCalculate(
        address _user,
        address _proxy,
        uint256 _pid,
        uint256 _duration
    ) internal view returns (uint256) {
        if (_duration == 0) return BOOST_PRECISION;

        (uint256 lpBalance, , ) = IMasterChefV2(MASTER_CHEF).userInfo(_pid, _proxy);
        uint256 dB = (cA * lpBalance) / CA_PRECISION;
        // dB == 0 means lpBalance close to 0
        if (lpBalance == 0 || dB == 0) return BOOST_PRECISION;

        (, , , , uint256 lockStartTime, uint256 lockEndTime, , , uint256 userLockedAmount) = ICorisPool(CORIS_POOL)
            .userInfo(_user);
        if (userLockedAmount == 0 || block.timestamp >= lockEndTime) return BOOST_PRECISION;

        // userLockedAmount > 0 means totalLockedAmount > 0
        uint256 totalLockedAmount = ICorisPool(CORIS_POOL).totalLockedAmount();

        IERC20 lp = IERC20(IMasterChefV2(MASTER_CHEF).lpToken(_pid));
        uint256 userLockedDuration = (lockEndTime - lockStartTime) / (3600 * 24); // days

        uint256 aB = (((lp.balanceOf(MASTER_CHEF) * userLockedAmount * userLockedDuration) * BOOST_RATIO_PRECISION) /
            cB) / (totalLockedAmount * _duration);

        // should '*' BOOST_PRECISION
        return ((lpBalance < (dB + aB) ? lpBalance : (dB + aB)) * BOOST_PRECISION) / dB;
    }

    /// @notice Checks if address is a contract
    /// @dev It prevents contract from being targetted
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}