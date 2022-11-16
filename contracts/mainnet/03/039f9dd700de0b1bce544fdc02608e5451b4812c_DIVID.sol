/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: Unlicensed
 
pragma solidity ^0.8.4;

contract Stakeable {
    uint256 internal rewardPerDay = 365;
    IERC20 public xDIV_CONTRACT;

    constructor() {
        stakeholders.push();
        stakeholderssuper.push();
        xDIV_CONTRACT = IERC20(0xe500Aa09807C9A0e98F7C9De3a752d560Ef6FFdd);
    }

    struct StakingSummary {
        uint256 total_amount;
        Stake[] stakes;
    }
    struct StakingSummarySuper {
        uint256 total_amount;
        StakeSuper[] stakessuper;
    }

    struct Stake {
        address user;
        uint256 amount;
        string stakename;
        uint256 since;
        uint256 created;
        uint256 claimable;
        uint256 xdivbonus;
    }
    struct StakeSuper {
        address user;
        uint256 amount;
        string stakenamesuper;
        uint256 since;
        uint256 created;
        uint256 claimable;
        uint256 xdivbonus;
    }

    struct Stakeholder {
        address user;
        Stake[] address_stakes;
    }
    struct StakeholderSuper {
        address user;
        StakeSuper[] address_stakessuper;
    }

    Stakeholder[] internal stakeholders;
    StakeholderSuper[] internal stakeholderssuper;

    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal stakesSuper;

    event Staked(
        address indexed user,
        uint256 amount,
        string stakename,
        uint256 index,
        uint256 timestamp,
        uint256 created,
        uint256 xdivbonus
    );
    event StakedSuper(
        address indexed user,
        uint256 amount,
        string stakenamesuper,
        uint256 index,
        uint256 timestamp,
        uint256 created,
        uint256 xdivbonus
    );

    function _addStakeholder(address staker) internal returns (uint256) {
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex;
    }
    function _addStakeholderSuper(address staker) internal returns (uint256) {
        stakeholderssuper.push();
        uint256 userIndex = stakeholderssuper.length - 1;
        stakeholderssuper[userIndex].user = staker;
        stakesSuper[staker] = userIndex;
        return userIndex;
    }

    function _stake(uint256 _amount, string memory _stakename) internal {
        require(_amount > 0, "Cannot stake nothing");
        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        uint256 timestamp2 = block.timestamp;
        uint256 xdivbalance = xDIV_CONTRACT.balanceOf(msg.sender);
        uint256 xdivbonus;
        if (index == 0) {
            index = _addStakeholder(msg.sender);
        }
        if (xdivbalance >= 3) {
            xdivbonus = 3;
        } else {
            xdivbonus = xdivbalance;
        }
        stakeholders[index].address_stakes.push(
            Stake(msg.sender, _amount, _stakename, timestamp, timestamp2, 0, xdivbonus)
        );
        emit Staked(msg.sender, _amount, _stakename, index, timestamp, timestamp2, xdivbonus);
    }
    function _stakeSuper(uint256 _amountsuper, string memory _stakenamesuper) internal {
        require(_amountsuper > 0, "Cannot stake nothing");
        uint256 index = stakesSuper[msg.sender];
        uint256 timestamp = block.timestamp;
        uint256 timestamp2 = block.timestamp;
        uint256 xdivbalance = xDIV_CONTRACT.balanceOf(msg.sender);
        uint256 xdivbonus = xdivbalance;
        if (index == 0) {
            index = _addStakeholderSuper(msg.sender);
        }
        if (xdivbalance >= 13) {
            xdivbonus = 13;
        } else {
            xdivbonus = xdivbalance;
        }
        stakeholderssuper[index].address_stakessuper.push(
            StakeSuper(msg.sender, _amountsuper, _stakenamesuper, timestamp, timestamp2, 0, xdivbonus)
        );
        emit StakedSuper(msg.sender, _amountsuper, _stakenamesuper, index, timestamp, timestamp2, xdivbonus);
    }

    /**
     * @notice
     * calculateStakeReward is used to calculate how much a user should be rewarded for their stakes
     * and the duration the stake has been active
     */
    function calculateStakeReward(Stake memory _current_stake)
        internal
        view
        returns (uint256)
    {
        // First calculate how long the stake has been active
        // Use current seconds since epoch - the seconds since epoch the stake was made
        // The output will be duration in SECONDS ,
        // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
        // the alghoritm is  seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
        // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
        // we then multiply each token by the hours staked , then divide by the rewardPerHour rate

        uint256 aprBonus = _current_stake.xdivbonus;
        if ( aprBonus > 0) {
            return
                (((block.timestamp - _current_stake.since) / 24 hours) *
                    _current_stake.amount *
                    (10 + (_current_stake.xdivbonus * 10 / 5))) / rewardPerDay / 10;
        } else {
            return
                (((block.timestamp - _current_stake.since) / 24 hours) *
                    _current_stake.amount) / rewardPerDay;
        }
    }

    function calculateStakeRewardSuper(StakeSuper memory _current_stakesuper)
        internal
        view
        returns (uint256)
    {
        // First calculate how long the stake has been active
        // Use current seconds since epoch - the seconds since epoch the stake was made
        // The output will be duration in SECONDS ,
        // We will reward the user 0.1% per Hour So thats 0.1% per 3600 seconds
        // the alghoritm is  seconds = block.timestamp - stake seconds (block.timestap - _stake.since)
        // hours = Seconds / 3600 (seconds /3600) 3600 is an variable in Solidity names hours
        // we then multiply each token by the hours staked , then divide by the rewardPerHour rate

        uint256 aprBonus = _current_stakesuper.xdivbonus;

        if (aprBonus > 0) {
            return
                (((block.timestamp - _current_stakesuper.since) / 24 hours) *
                    _current_stakesuper.amount *
                    (10 + (_current_stakesuper.xdivbonus * 10 / 5))) / rewardPerDay / 10;
        } else {
            return
                (((block.timestamp - _current_stakesuper.since) / 24 hours) *
                    _current_stakesuper.amount) / rewardPerDay;
        }
    }
    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also calculateStakeReward and reset timer
     */
    function _withdrawStake(uint256 amount, uint256 index)
        internal
        returns (uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[
            index
        ];
        require(
            current_stake.amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );
        uint256 xdivbonusDecrease = current_stake.xdivbonus;
        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeReward(current_stake);
        // Remove by subtracting the money unstaked
        current_stake.amount = current_stake.amount - amount;
        if (xdivbonusDecrease > 0) {
        current_stake.xdivbonus = xdivbonusDecrease - 1;
        }
        bool xdiv = xDIV_CONTRACT.balanceOf(msg.sender) > 0;
        if ((block.timestamp - current_stake.created) / 30 days >= 1) {
            amount = amount;
            reward = reward;
        } else if (xdiv) {
            amount = (amount * 70) / 100;
            reward = (reward * 90) / 100;
        } else {
            amount = (amount * 50) / 100;
            reward = (reward * 50) / 100;
        }

        // If stake is empty, 0, then remove it from the array of stakes
        if (current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            // If not empty then replace the value of it
            stakeholders[user_index]
                .address_stakes[index]
                .amount = current_stake.amount;
            // Deduct the XDIVBONUS
            stakeholders[user_index]
                .address_stakes[index]
                .xdivbonus = current_stake.xdivbonus;
            // Reset timer of stake
            stakeholders[user_index].address_stakes[index].since = block
                .timestamp;
        }

        return amount + reward;
    }
    function _withdrawStakeSuper(uint256 amount, uint256 index)
        internal
        returns (uint256)
    {
        // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakesSuper[msg.sender];
        StakeSuper memory current_stakesuper = stakeholderssuper[user_index].address_stakessuper[
            index
        ];
        require(
            current_stakesuper.amount >= amount,
            "Staking: Cannot withdraw more than you have staked"
        );

        // Calculate available Reward first before we start modifying data
        uint256 reward = calculateStakeRewardSuper(current_stakesuper);
        uint256 xdivbonusDecrease = current_stakesuper.xdivbonus;
        current_stakesuper.amount = current_stakesuper.amount - amount;
        if (xdivbonusDecrease > 0) {
            current_stakesuper.xdivbonus = xdivbonusDecrease - 1;
        }
        // Remove by subtracting the money unstaked
        bool xdiv = xDIV_CONTRACT.balanceOf(msg.sender) > 0;
        if ((block.timestamp - current_stakesuper.created) / 365 days >= 1) {
            amount = amount;
            reward = reward;
        } else if (xdiv) {
            amount = (amount * 70) / 100;
            reward = (reward * 90) / 100;
        } else {
            amount = (amount * 50) / 100;
            reward = (reward * 50) / 100;
        }
        if (current_stakesuper.amount == 0) {
            delete stakeholderssuper[user_index].address_stakessuper[index];
        } else {
            // If not empty then replace the value of it
            stakeholderssuper[user_index]
                .address_stakessuper[index]
                .amount = current_stakesuper.amount;
            // Deduct the XDIV
            stakeholderssuper[user_index]
                .address_stakessuper[index]
                .xdivbonus = current_stakesuper.xdivbonus;
            // Reset timer of stake
            stakeholderssuper[user_index].address_stakessuper[index].since = block
                .timestamp;
        }
        return amount + reward;
    }

    function hasStake(address _staker)
        public
        view
        returns (StakingSummary memory)
    {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(
            0,
            stakeholders[stakes[_staker]].address_stakes
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
            uint256 availableReward = calculateStakeReward(summary.stakes[s]);
            summary.stakes[s].claimable = availableReward;
            summary.stakes[s].created = summary.stakes[s].created;
            totalStakeAmount = totalStakeAmount + summary.stakes[s].amount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }
    function hasStakeSuper(address _staker)
        public
        view
        returns (StakingSummarySuper memory)
    {
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount;
        // Keep a summary in memory since we need to calculate this
        StakingSummarySuper memory summary = StakingSummarySuper(
            0,
            stakeholderssuper[stakesSuper[_staker]].address_stakessuper
        );
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakessuper.length; s += 1) {
            uint256 availableReward = calculateStakeRewardSuper(summary.stakessuper[s]);
            summary.stakessuper[s].claimable = availableReward;
            summary.stakessuper[s].created = summary.stakessuper[s].created;
            totalStakeAmount = totalStakeAmount + summary.stakessuper[s].amount;
        }
        // Assign calculate amount to summary
        summary.total_amount = totalStakeAmount;
        return summary;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
 
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
abstract contract Ownable is Context {
    address private _owner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
 
    function owner() public view virtual returns (address) {
        return _owner;
    }
 
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
 
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
 
interface IERC20 {
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender, uint256 amount) external returns (bool);
 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
 
    mapping (address => mapping (address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
 
    string private _name;
    string private _symbol;
    uint8 private _decimals;
 
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }
 
    function name() public view virtual returns (string memory) {
        return _name;
    }
 
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
 
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
 
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
 
        _beforeTokenTransfer(sender, recipient, amount);
 
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
 
        _beforeTokenTransfer(address(0), account, amount);
 
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
 
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
 
        _beforeTokenTransfer(account, address(0), amount);
 
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
 
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

interface IXDIVID {
    function distributeDividends(uint256 amount) external;
}
 
////////////////////////////////
///////// Interfaces ///////////
////////////////////////////////
 
interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
 
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
 
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
 
    function createPair(address tokenA, address tokenB) external returns (address pair);
 
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
 
interface IUniswapV2Pair {
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
 
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
 
    function addLiquidity( address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB, uint liquidity); 
function addLiquidityETH( address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external payable returns (uint amountToken, uint amountETH, uint liquidity); 
function removeLiquidity( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline ) external returns (uint amountA, uint amountB); 
function removeLiquidityETH( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountToken, uint amountETH); 
function removeLiquidityWithPermit( address tokenA, address tokenB, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountA, uint amountB); 
function removeLiquidityETHWithPermit( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountToken, uint amountETH); 
function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts); 
function swapTokensForExactTokens( uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts); 
function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts); 
function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts); 
function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts); 
function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts); 
 
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
 
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline ) external returns (uint amountETH); 
function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens( address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s ) external returns (uint amountETH); 
 
 
function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external; 
function swapExactETHForTokensSupportingFeeOnTransferTokens( uint amountOutMin, address[] calldata path, address to, uint deadline ) external payable; 
function swapExactTokensForETHSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external; 
 
}
 
////////////////////////////////
////////// Libraries ///////////
////////////////////////////////
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }
 
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }
 
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }
 
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }
 
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}
 
library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when multiplying INT256_MIN with -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));
 
    int256 c = a * b;
    require((b == 0) || (c / b == a));
    return c;
  }
 
  function div(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when dividing INT256_MIN by -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    require(!(a == - 2**255 && b == -1) && (b > 0));
 
    return a / b;
  }
 
  function sub(int256 a, int256 b) internal pure returns (int256) {
    require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
 
    return a - b;
  }
 
  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }
 
  function toUint256Safe(int256 a) internal pure returns (uint256) {
    require(a >= 0);
    return uint256(a);
  }
}
 
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}
 
////////////////////////////////
/////////// Tokens /////////////
////////////////////////////////
contract DIVID is ERC20, Ownable, Stakeable {
    using SafeMath for uint256;
 
    IXDIVID public xdivid;
    IUniswapV2Router02 public uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public busdToken;
    address public dividToken;
    address public xDividContract;
    uint256 public xDividFee = 10;
    uint256 public minSwapAmount = 500 * 10**18;
 
    mapping (address => bool) private isExcludedFromFees; 
    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
    event UpdatebusdDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SendDividends(
    	uint256 amount
    );
 
    constructor(address xDIVaddress) ERC20("DIVID", "DIV") {
    	busdToken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        dividToken = address(this);
        xDividContract = xDIVaddress;
        IXDIVID _xdivid = IXDIVID(xDIVaddress);
        xdivid = _xdivid;

    	IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), busdToken);
 
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
 
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(address(this), true);
        excludeFromFees(owner(), true);
        _mint(owner(), 10000000 * (10**18));
    }
 
    receive() external payable {
 
  	}

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        require(newAddress != address(uniswapV2Router), "DIVID: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }
 
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(isExcludedFromFees[account] != excluded, "DIVID: Account is already exluded from fees");
        isExcludedFromFees[account] = excluded;
 
        emit ExcludeFromFees(account, excluded);
    }
 
    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "DIVID: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");
 
        _setAutomatedMarketMakerPair(pair, value);
    }
 
    function _setAutomatedMarketMakerPair(address pair, bool value) private onlyOwner {
        require(automatedMarketMakerPairs[pair] != value, "Boda: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function getIsExcludedFromFees(address account) public view returns(bool) {
        return isExcludedFromFees[account];
    }
  	
    function distributeDivs() public {
        uint256 currentBUSDBalance = IERC20(busdToken).balanceOf(address(this));
        IERC20(busdToken).approve(xDividContract, currentBUSDBalance);
        xdivid.distributeDividends(currentBUSDBalance);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        bool excludedAccount = isExcludedFromFees[from] || isExcludedFromFees[to];

        if (!excludedAccount) {
        	uint256 fees;
            uint256 tmpMarketingRewardPercent;

            tmpMarketingRewardPercent = amount.mul(xDividFee).div(100);
            fees = tmpMarketingRewardPercent;

        	amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }
        super._transfer(from, to, amount);
    }

    function swapTokensForBUSD() public {
        //set the path.
        address[] memory path = new address[](3);
        path[0] = dividToken;
        path[1] = uniswapV2Router.WETH();
        path[2] = busdToken;

        uint256 tokensForDividends = balanceOf(address(this));
        IERC20(dividToken).approve(address(uniswapV2Router), tokensForDividends);
        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            tokensForDividends,
            0,
            path,
            dividToken,
            block.timestamp
        );
    }

    function stakeSuper(uint256 _amountsuper, string memory _stakenamesuper) public {
        // Make sure staker actually is good for it
        uint256 userBalance = balanceOf(msg.sender);
        require(
            _amountsuper < userBalance,
            "DevToken: Cannot stake more than you own"
        );

        _stakeSuper(_amountsuper, _stakenamesuper);
        // Burn the amount of tokens on the sender
        _burn(msg.sender, _amountsuper);
    }

    function stake(uint256 _amount, string memory _stakename) public {
        // Make sure staker actually is good for it
        uint256 userBalance = balanceOf(msg.sender);
        require(
            _amount < userBalance,
            "DevToken: Cannot stake more than you own"
        );

        _stake(_amount, _stakename);
        // Burn the amount of tokens on the sender
        _burn(msg.sender, _amount);
    }

    /**
     * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(uint256 amount, uint256 stake_index) public {
        uint256 amount_to_mint = _withdrawStake(amount, stake_index);
        // Return staked tokens to user
        _mint(msg.sender, amount_to_mint);
    }
    function withdrawStakeSuper(uint256 amount, uint256 stake_index) public {
        uint256 amount_to_mint = _withdrawStakeSuper(amount, stake_index);
        // Return staked tokens to user
        _mint(msg.sender, amount_to_mint);
    }
}