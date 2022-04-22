// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./JaxOwnable.sol";
import "./JaxProtection.sol";
import "./JaxLibrary.sol";
import "./interface/IERC20.sol";
import "./interface/IPancakeRouter.sol";

contract JaxFarming is Initializable, JaxOwnable, JaxProtection {

    using JaxLibrary for JaxFarming;

    IPancakeRouter01 public router;
    IPancakePair public lpToken;

    IERC20 public wjxn;
    IERC20 public busd;
    IERC20 public hst;

    uint public minimum_wjxn_price; // 1e18
    uint public farm_period;
    uint public total_reward;
    uint public released_reward;

    uint public farm_start_timestamp;

    bool public is_deposit_freezed;

    uint32[] public reward_pecentages; // decimals 10

    struct Farm {
        uint lp_amount;
        uint busd_amount;
        uint reward_percentage; // 10 decimals
        uint total_reward;
        uint released_reward;
        uint start_timestamp;
        uint harvest_timestamp;
        uint end_timestamp;
        address owner;
        bool is_withdrawn;
    }

    Farm[] public farms;

    mapping(address => uint[]) public user_farms;

    event Create_Farm(uint farm_id, uint amount);
    event Harvest(uint farm_id, uint busd_amount, uint hst_amount);
    event Set_Farm_Reward_Percentage(uint period, uint percentage);
    event Set_Minimum_Wjxn_Price(uint price);
    event Freeze_Deposit(bool flag);
    event Withdraw(uint farm_id);
    event Withdraw_By_Admin(address token, uint amount);

    modifier checkZeroAddress(address account) {
        require(account != address(0x0), "Only non-zero address");
        _;
    }

    function initialize(IPancakeRouter01 _router, IERC20 _wjxn, IERC20 _busd, IERC20 _hst) external initializer 
        checkZeroAddress(address(_router)) checkZeroAddress(address(_wjxn)) checkZeroAddress(address(_busd)) checkZeroAddress(address(_hst))
    {
        router = _router;
        lpToken = IPancakePair(IPancakeFactory(router.factory()).getPair(address(_wjxn), address(_busd)));
        wjxn = _wjxn;
        busd = _busd;
        hst = _hst;

        busd.approve(address(router), type(uint).max);
        wjxn.approve(address(router), type(uint).max);
        wjxn.approve(address(hst), type(uint).max);

        minimum_wjxn_price = 1.5 * 1e18; // 1.5 USD

        farm_period = 12 minutes;
        total_reward = 0;
        released_reward = 0;

        reward_pecentages = [2511836715, 2496667161, 2481534217, 2466443474, 2451400580, 2436411222, 2421481115, 2406615983, 2391821545, 2377103499, 2362467505, 2347919166, 2333464017, 2319107503, 2304854963, 2290711621, 2276682560, 2262772719, 2248986870, 2235329610, 2221805348, 2208418296, 2195172456, 2182071615, 2169119336, 2156318952, 2143673563, 2131186031, 2118858977, 2106694784, 2094695590, 2082863297, 2071199569, 2059705834, 2048383291, 2037232914, 2026255456, 2015451458, 2004821253, 1994364975, 1984082566, 1973973785, 1964038216, 1954275276, 1944684223, 1935264168, 1926014080, 1916932798, 1908019035, 1899271393, 1890688368, 1882268355, 1874009664, 1865910519, 1857969074, 1850183412, 1842551559, 1835071486, 1827741118, 1820558338, 1813520997, 1806626912, 1799873880, 1793270705, 1786814909, 1780504005, 1774335508, 1768306932, 1762415799, 1756659636, 1751035986, 1745542402, 1740176457, 1734935740, 1729817862, 1724820457, 1719941181, 1715177718, 1710527779, 1705989101, 1701559452, 1697236630, 1693018463, 1688902812, 1684887569, 1680970659, 1677150039, 1673423701, 1669789670, 1666246003, 1662790793, 1659422166, 1656138280, 1652937329, 1649817539, 1646777170, 1643814514, 1640927897, 1638115677, 1635376243, 1632708019, 1630109457, 1627579043, 1625115290, 1622716746, 1620381986, 1618109615, 1615898267, 1613746604, 1611653317, 1609617125, 1607636773, 1605711033, 1603838704, 1602018610, 1600249601, 1598530551, 1596860359, 1595237947, 1593662262, 1592132272, 1590646969, 1589205368, 1587806502, 1586449429, 1585133225, 1583856990, 1582619839, 1581420910, 1580259358, 1579134360, 1578045107, 1576990811, 1575970700, 1574984019, 1574030031, 1573108015, 1572217265, 1571357091, 1570526821, 1569725793, 1568953364, 1568208903, 1567491795, 1566801436, 1566137238, 1565498625, 1564885034, 1564295914, 1563730726, 1563188946, 1562670057, 1562173557, 1561698954, 1561245767, 1560813525, 1560401770, 1560010050, 1559637927, 1559284970, 1558950760, 1558634886, 1558336945, 1558056544, 1557793300, 1557546837, 1557316787, 1557102792, 1556904499, 1556721566, 1556553657, 1556400442, 1556261602, 1556136822, 1556025795, 1555928220, 1555843804, 1555772260, 1555713307, 1555666670, 1555632080];

        farm_start_timestamp = block.timestamp;

        is_deposit_freezed = false;

        _transferOwnership(msg.sender);
    }

    function get_apy_today() public view returns(uint) {
        uint elapsed_days = (block.timestamp - farm_start_timestamp) / 1 days;
        if(elapsed_days > 180) return reward_pecentages[180];
        return reward_pecentages[elapsed_days];
    }

    function create_farm(uint lp_amount) external {
        lpToken.transferFrom(msg.sender, address(this), lp_amount);
        (uint reserve0, uint reserve1, ) = lpToken.getReserves();
        uint busd_reserve = 0;
        if(lpToken.token0() == address(busd))
            busd_reserve = reserve0;
        else
            busd_reserve = reserve1;
        uint busd_amount = 2 * busd_reserve * lp_amount / lpToken.totalSupply();
        _create_farm(lp_amount, busd_amount);
    }

    function restake(uint farm_id) external {
        _withdraw(farm_id, true);
        Farm memory old_farm = farms[farm_id];
        (uint reserve0, uint reserve1, ) = lpToken.getReserves();
        uint busd_reserve = 0;
        if(lpToken.token0() == address(busd))
            busd_reserve = reserve0;
        else
            busd_reserve = reserve1;
        uint busd_amount = 2 * busd_reserve * old_farm.lp_amount / lpToken.totalSupply();
        _create_farm(old_farm.lp_amount, busd_amount);
    }

    function create_farm_busd(uint busd_amount) external {
        busd.transferFrom(msg.sender, address(this), busd_amount);
        uint busd_for_wjxn = busd_amount / 2;
        address[] memory path = new address[](2);
        path[0] = address(busd);
        path[1] = address(wjxn);
        uint wjxn_amount = _busd_buy_wjxn_amount(busd_for_wjxn);
        if(wjxn_amount > wjxn.balanceOf(address(this))) {
            uint[] memory amounts = JaxLibrary.swapWithPriceImpactLimit(address(router), busd_for_wjxn, 3e6, path, address(this)); // price impact 3%
            wjxn_amount = amounts[1];
        }
        (uint busd_added, uint wjxn_added, uint lp_amount) = 
            router.addLiquidity(path[0], path[1], busd_amount - busd_for_wjxn, wjxn_amount, 0, 0, address(this), block.timestamp);
        if(wjxn_amount > wjxn_added) {
            path[0] = address(wjxn);
            path[1] = address(busd);
            uint[] memory amounts = router.swapExactTokensForTokens(wjxn_amount - wjxn_added, 0, path, msg.sender, block.timestamp);
            busd_for_wjxn -= amounts[1];
        }
        if(busd_amount - busd_for_wjxn > busd_added) {
            busd.transfer(msg.sender, busd_amount - busd_for_wjxn - busd_added);
        }
        _create_farm(lp_amount, busd_added + busd_for_wjxn);
        _add_liquidity();
    }

    function _add_liquidity() internal {
        uint busd_balance = busd.balanceOf(address(this));
        uint wjxn_balance = wjxn.balanceOf(address(this));
        if(busd_balance < 10000 * 1e18 || wjxn_balance == 0)
            return;
        address[] memory path = new address[](2);
        path[0] = address(busd);
        path[1] = address(wjxn);
        router.addLiquidity(path[0], path[1], busd_balance, wjxn_balance, 0, 0, owner, block.timestamp);
    }

    function _create_farm(uint lp_amount, uint busd_amount) internal {
        require(is_deposit_freezed == false, "Creating farm is frozen");
        Farm memory farm;
        farm.lp_amount = lp_amount;
        farm.busd_amount = busd_amount;
        farm.owner = msg.sender;
        farm.start_timestamp = block.timestamp;
        farm.reward_percentage = get_apy_today();
        farm.end_timestamp = block.timestamp + farm_period;
        farm.total_reward = busd_amount * farm.reward_percentage / 1e10;
        total_reward += farm.total_reward;
        uint hst_in_busd = hst.balanceOf(address(this)) * _get_wjxn_price() / 1e8;
        require(total_reward - released_reward <= hst_in_busd, "Reward Pool Exhausted");
        farm.harvest_timestamp = farm.start_timestamp;
        uint farm_id = farms.length;
        farms.push(farm);
        user_farms[msg.sender].push(farm_id);
        emit Create_Farm(farm_id, lp_amount);
    }

    function _busd_buy_wjxn_amount(uint busd_amount) internal view returns(uint) {
        return busd_amount / _get_wjxn_price();
    }

    function _get_wjxn_price() internal view returns(uint) {
        uint dex_price = _get_wjxn_dex_price();
        if(dex_price < minimum_wjxn_price)
            return minimum_wjxn_price;
        return dex_price;
    }

    function _get_wjxn_dex_price() internal view returns(uint) {
        address pairAddress = IPancakeFactory(router.factory()).getPair(address(wjxn), address(busd));
        (uint res0, uint res1,) = IPancakePair(pairAddress).getReserves();
        res0 *= 10 ** (18 - IERC20(IPancakePair(pairAddress).token0()).decimals());
        res1 *= 10 ** (18 - IERC20(IPancakePair(pairAddress).token1()).decimals());
        if(IPancakePair(pairAddress).token0() == address(busd)) {
            if(res1 > 0)
                return 1e18 * res0 / res1;
        } 
        else {
            if(res0 > 0)
                return 1e18 * res1 / res0;
        }
        return 0;
    }

    function get_pending_reward(uint farm_id) public view returns(uint) {
        Farm memory farm = farms[farm_id];
        if(farm.harvest_timestamp >= farm.end_timestamp) return 0;
        uint past_period = 0;
        if(block.timestamp >= farm.end_timestamp)
            past_period = farm.end_timestamp - farm.start_timestamp;
        else
            past_period = block.timestamp - farm.start_timestamp;
        uint period = farm.end_timestamp - farm.start_timestamp;
        uint reward = farm.total_reward * past_period / period; // hst stornetta
        return reward - farm.released_reward;
    }

    function harvest(uint farm_id) public {
        Farm storage farm = farms[farm_id];
        require(farm.owner == msg.sender, "Only farm owner");
        require(farm.is_withdrawn == false, "Farm is withdrawn");
        uint pending_reward_busd = get_pending_reward(farm_id);
        require(pending_reward_busd > 0, "Nothing to harvest");
        farm.released_reward += pending_reward_busd;
        released_reward += pending_reward_busd;
        uint pending_reward_hst = pending_reward_busd * 1e8 / _get_wjxn_price();
        require(hst.balanceOf(address(this)) >= pending_reward_hst, "Insufficient reward tokens");
        hst.transfer(msg.sender, pending_reward_hst);
        farm.harvest_timestamp = block.timestamp;
        emit Harvest(farm_id, pending_reward_busd, pending_reward_hst);
    }

    function get_farm_ids(address account) external view returns(uint[] memory){
        return user_farms[account];
    }

    function set_minimum_wjxn_price(uint price) external onlyOwner runProtection {
        require(price >= 1.5 * 1e18, "Minimum wjxn price should be above 1.5 USD");
        minimum_wjxn_price = price;
        emit Set_Minimum_Wjxn_Price(price);
    }

    function capacity_status() external view returns (uint) {
        if(is_deposit_freezed == true) return 0;
        uint hst_in_busd = hst.balanceOf(address(this)) * _get_wjxn_price() / 1e8;
        return 1e8 * (total_reward - released_reward) / hst_in_busd;
    }

    function withdraw(uint farm_id) external {
        _withdraw(farm_id, false);
    }

    function _withdraw(uint farm_id, bool is_restake) internal {
        require(farm_id < farms.length, "Invalid farm id");
        Farm storage farm = farms[farm_id];
        require(farm.owner == msg.sender, "Only farm owner can withdraw");
        require(farm.is_withdrawn == false, "Already withdrawn");
        require(farm.end_timestamp <= block.timestamp, "Locked");
        if(!is_restake)
            lpToken.transfer(farm.owner, farm.lp_amount);
        if(farm.total_reward > farm.released_reward)
            harvest(farm_id);
        farm.is_withdrawn = true;
        emit Withdraw(farm_id);
    }

    
    function withdrawByAdmin(address token, uint amount) external onlyOwner runProtection {
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
    }

    function freeze_deposit(bool flag) external onlyOwner runProtection {
        is_deposit_freezed = flag;
        emit Freeze_Deposit(flag);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

contract JaxOwnable {

  address public owner;
  address public new_owner;
  uint public new_owner_locktime;
  
  event Set_New_Owner(address newOwner, uint newOwnerLocktime);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
      require(owner == msg.sender, "JaxOwnable: caller is not the owner");
      _;
  }

  function setNewOwner(address newOwner) external onlyOwner {
    require(newOwner != address(0x0), "New owner cannot be zero address");
    new_owner = newOwner;
    new_owner_locktime = block.timestamp + 10 minutes;
    emit Set_New_Owner(newOwner, new_owner_locktime);
  }

  function updateOwner() external {
    require(msg.sender == new_owner, "Only new owner");
    require(block.timestamp >= new_owner_locktime, "New admin is not unlocked yet");
    _transferOwnership(new_owner);
    new_owner = address(0x0);
  }

  function renounceOwnership() external onlyOwner {
    _transferOwnership(address(0));
  }

  /**
  * @dev Transfers ownership of the contract to a new account (`newOwner`).
  * Internal function without access restriction.
  */
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = owner;
    owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract JaxProtection {

    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    function _runProtection() internal returns(bool) {
        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
            protection.sender = msg.sender;
            protection.data_hash = data_hash;
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return false;
        }
        require(protection.executed == false, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 10 minutes, "Running is Locked");
        protection.executed = true;
        return true;
    }

    modifier runProtection() {
        if(_runProtection()) {
            _;
        }
    }
}

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.11;

import "./interface/IPancakeRouter.sol";

library JaxLibrary {

  function swapWithPriceImpactLimit(address router, uint amountIn, uint limit, address[] memory path, address to) internal returns(uint[] memory) {
    IPancakeRouter01 pancakeRouter = IPancakeRouter01(router);
    
    IPancakePair pair = IPancakePair(IPancakeFactory(pancakeRouter.factory()).getPair(path[0], path[1]));
    (uint res0, uint res1, ) = pair.getReserves();
    uint reserveIn;
    uint reserveOut;
    if(pair.token0() == path[0]) {
      reserveIn = res0;
      reserveOut = res1;
    } else {
      reserveIn = res1;
      reserveOut = res0;
    }
    uint amountOut = pancakeRouter.getAmountOut(amountIn, reserveIn, reserveOut);
    require(reserveOut * 1e36 * (1e8 - limit) / 1e8 / reserveIn <= amountOut * 1e36 / amountIn, "Price Impact too high");
    return pancakeRouter.swapExactTokensForTokens(amountIn, 0, path, to, block.timestamp);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev Interface of the BEP standard.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function mint(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;


interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}


interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeRouter01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}