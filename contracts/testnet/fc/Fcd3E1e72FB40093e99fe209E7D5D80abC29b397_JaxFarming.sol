// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IERC20.sol";
import "./interface/IPancakeRouter.sol";

contract JaxFarming is Ownable{

    IPancakeRouter01 constant router = IPancakeRouter01(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3); // 0x10ED43C718714eb63d5aA57B78B54704E256024E
    IPancakePair lpToken = IPancakePair(0x9983B94bEedDb6132C6A4d671Bf54e73799110Ab); // 0x2C3Dd2178cd8BdaC6bdBBD628B1fCA120F2c6591

    IERC20 constant wjxn = IERC20(0xBC04b1cEEE41760CBd84d3D58Db57a13c95B8107); // 0xcA1262e77Fb25c0a4112CFc9bad3ff54F617f2e6
    IERC20 constant busd = IERC20(0xa51BcDc792285598Ba7443c71D557e0B7Df6f991); // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    IERC20 constant haber = IERC20(0x4411F3bc052ce3eEbFFBd7DE5c140bBd684eE93a); // 0xd6AF849b09879a3648d56B5d43c6e5908a74CA83

    uint minimum_wjxn_price; // 1e18

    uint farm_period1 = 9 minutes;
    uint farm_period2 = 18 minutes;

    uint farm_reward_percentage1 = 15; // 15%
    uint farm_reward_percentage2 = 30; // 30%

    uint total_reward;
    uint released_reward;

    struct Farm {
        uint lp_amount;
        uint busd_amount;
        uint plan;
        uint reward_percentage;
        uint total_reward;
        uint released_reward;
        uint start_timestamp;
        uint harvest_timestamp;
        uint end_timestamp;
        address owner;
        bool is_withdrawn;
    }

    Farm[] farms;

    mapping(address => uint[]) user_farms;

    event Create_Farm(uint farm_id, uint plan, uint amount);
    event Harvest(uint farm_id, uint busd_amount, uint haber_amount);
    event Set_Farm_Reward_Percentage(uint plan, uint period, uint percentage);
    event Set_Minimum_Wjxn_Price(uint price);
    event Withdraw(uint farm_id);
    event Withdraw_By_Admin(address token, uint amount);

    constructor() {
        busd.approve(address(router), type(uint).max);
        wjxn.approve(address(router), type(uint).max);
        wjxn.approve(address(haber), type(uint).max);
    }

    function create_farm(uint plan, uint lp_amount) external {
        lpToken.transferFrom(msg.sender, address(this), lp_amount);
        require(plan == 1 || plan == 2, "Invalid plan");
        (uint reserve0, uint reserve1, ) = lpToken.getReserves();
        uint busd_reserve;
        if(lpToken.token0() == address(busd))
            busd_reserve = reserve0;
        else
            busd_reserve = reserve1;
        uint busd_amount = 2 * busd_reserve * lp_amount / lpToken.totalSupply();
        _create_farm(plan, lp_amount, busd_amount);
    }

    function create_farm_busd(uint plan, uint busd_amount) external {
        require(plan == 1 || plan == 2, "Invalid plan");
        busd.transferFrom(msg.sender, address(this), busd_amount);
        uint busd_for_wjxn = busd_amount / 2;
        address[] memory path = new address[](2);
        path[0] = address(busd);
        path[1] = address(wjxn);
        uint wjxn_amount = _buy_wjxn(busd_for_wjxn);
        if(wjxn_amount > wjxn.balanceOf(address(this))) {
            uint[] memory amounts = router.swapExactTokensForTokens(busd_for_wjxn, wjxn_amount, path, address(this), block.timestamp);
            wjxn_amount = amounts[1];
        }
        (, , uint lp_amount) = 
            router.addLiquidity(path[0], path[1], busd_amount - busd_for_wjxn, wjxn_amount, 0, 0, address(this), block.timestamp);
        _create_farm(plan, lp_amount, busd_amount);
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
        router.addLiquidity(path[0], path[1], busd_balance, wjxn_balance, 0, 0, owner(), block.timestamp);
    }

    function _create_farm(uint plan, uint lp_amount, uint busd_amount) internal {
        Farm memory farm;
        farm.lp_amount = lp_amount;
        farm.busd_amount = busd_amount;
        farm.plan = plan;
        farm.owner = msg.sender;
        farm.start_timestamp = block.timestamp;
        if(plan == 1){
            farm.reward_percentage = farm_reward_percentage1;
            farm.end_timestamp = block.timestamp + farm_period1;
        }
        if(plan == 2){
            farm.reward_percentage = farm_reward_percentage2;
            farm.end_timestamp = block.timestamp + farm_period2;
        }
        farm.total_reward = busd_amount * farm.reward_percentage / 100;
        total_reward += farm.total_reward;
        uint wjxn_in_busd = wjxn.balanceOf(address(this)) * _get_wjxn_price();
        require(total_reward - released_reward <= wjxn_in_busd, "Farming contract is not active");
        farm.harvest_timestamp = farm.start_timestamp;
        uint farm_id = farms.length;
        farms.push(farm);
        user_farms[msg.sender].push(farm_id);
        emit Create_Farm(farm_id, plan, lp_amount);
    }

    function _buy_wjxn(uint busd_amount) internal view returns(uint) {
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
        uint past_period;
        if(block.timestamp >= farm.end_timestamp)
            past_period = farm.end_timestamp - farm.start_timestamp;
        else
            past_period = block.timestamp - farm.start_timestamp;
        uint period = farm.end_timestamp - farm.start_timestamp;
        uint reward = farm.total_reward * past_period / period; // haber stornetta
        return reward - farm.released_reward;
    }

    function harvest(uint farm_id) public {
        Farm storage farm = farms[farm_id];
        require(farm.owner == msg.sender, "Only farm owner");
        uint pending_reward_busd = get_pending_reward(farm_id);
        require(pending_reward_busd > 0, "Nothing to harvest");
        farm.released_reward += pending_reward_busd;
        released_reward += pending_reward_busd;
        uint pending_reward_haber = pending_reward_busd * 1e8 / _get_wjxn_price();
        uint surplus = pending_reward_haber - (pending_reward_haber / 1e8 * 1e8);
        if(surplus > haber.balanceOf(address(this)))
            haber.mint(pending_reward_haber / 1e8 + 1);
        else
            haber.mint(pending_reward_haber / 1e8);
        haber.transfer(msg.sender, pending_reward_haber);
        farm.harvest_timestamp = block.timestamp;
        emit Harvest(farm_id, pending_reward_busd, pending_reward_haber);
    }

    function set_farm_period_percentage(uint plan, uint period,  uint percentage) external onlyOwner {
        require(plan == 1 || plan == 2, "Invalid plan");
        require(percentage <= 60, "Plan percentage should be less than 60%");
        if(plan == 1) {
            farm_period1 = period;
            farm_reward_percentage1 = percentage;
        }
        else if(plan == 2) {
            farm_period2 = period;
            farm_reward_percentage2 = percentage;
        }
        emit Set_Farm_Reward_Percentage(plan, period, percentage);
    }

    function get_farm_ids(address account) external view returns(uint[] memory){
        return user_farms[account];
    }

    function set_minimum_wjxn_price(uint price) external onlyOwner {
        minimum_wjxn_price = price;
        emit Set_Minimum_Wjxn_Price(price);
    }

    function withdraw(uint farm_id) external {
        require(farm_id < farms.length, "Invalid farm id");
        Farm storage farm = farms[farm_id];
        require(farm.owner == msg.sender, "Only farm owner can withdraw");
        require(farm.is_withdrawn == false, "Already withdrawn");
        require(farm.end_timestamp <= block.timestamp, "Locked");
        lpToken.transfer(farm.owner, farm.lp_amount);
        if(farm.total_reward > farm.released_reward)
            harvest(farm_id);
        farm.is_withdrawn = true;
        emit Withdraw(farm_id);
    }

    
    function withdrawByAdmin(address token, uint amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}