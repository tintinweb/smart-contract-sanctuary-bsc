// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// 
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}

interface IPair {
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

contract LPMiningRemix is Ownable {
    event AddPool(address indexed LP, address indexed outputToken);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Claim(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    using SafeMath for uint;
    using SafeBEP20 for IBEP20;
    address public USDT;
    bool public initialize;
    uint public startTime;
    uint public constant Acc = 1e18;

    // Info of each user.
    struct UserInviInfo {
        uint power;
        uint bonus;
        address invitePeople;
    }
    mapping (uint => mapping (address => UserInviInfo)) public userInviInfo;

    struct UserInfo_Slot {
        uint power;     // How many LP power in the pool.
        uint amount;    // How many LP tokens the user has provided.
        uint userDebt; // Reward debt. See explanation below.
        uint toClaim;
        uint claimed;
        uint bonus;
        uint depositTime;
        uint lastClaimTime;
        // address invitePeople; // 
    }
    // user lp mapping
    // mapping(uint => mapping(address => mapping(address => uint))) public lpDepositTime;
    // mapping(uint => mapping (address => mapping(address => uint))) public userLpDeposits;
    // Info of each user that stakes LP tokens.   
    // pid => user => lpAddress
    mapping (uint256 => mapping(address => mapping (address => UserInfo_Slot))) public userInfo_slot;

    // Info of each pool.
    struct PoolInfo {
        bool status;
        bool lockToTime;
        address levelLp; // Address of LP token contract.
        address[] lpToken;  // Address of LP token contract.
        address outPutToken; // Address of output token contract.
        uint dailyOut;       // How many CNN daily output from this pool.
        uint lastRewardTime;  // Last time that CNN distribution occurs.
        uint debtInPool; // debt
        uint totalPower; // TVL
        uint startTime;
        uint endTime;
        uint lockTime;
        uint[2] bonusCoe;
        uint[2] levelAmount;
    }

    // lp power mapping
    mapping(uint => mapping (address => uint)) internal lpPower;
    mapping(uint => mapping(address => bool)) public lpInPool;
    // Info of each pool.
    PoolInfo[] public poolInfo;

    constructor(address usdt_)  {
        startTime = block.timestamp;
        USDT = usdt_;
        initialize = true;
        setAdmin(msg.sender);
    }

    mapping(address => bool) public isAdmin;
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Admin: caller is not the Admin");
        _;
    }

    function checkPoolDividend(uint pid_)  public view returns(uint _bonusCoe1, uint _bonusCoe2, uint _levelOne, uint _levelTwo){
        _bonusCoe1 = poolInfo[pid_].bonusCoe[0];
        _bonusCoe2 = poolInfo[pid_].bonusCoe[1];
        _levelOne = poolInfo[pid_].levelAmount[0];
        _levelTwo = poolInfo[pid_].levelAmount[1];
    }
    
    function poolLength() public view returns (uint) {
        return poolInfo.length;
    }

    function checkPoolStatus(uint pid_) public view returns(bool){
        return poolInfo[pid_].status;
    }

    // function checkAllPoolId(address lpAddr_) public view returns(uint[] memory _list){
    //     uint _length = poolInfo.length;
    //     _list = new uint[](_length);
    //     uint i=0;
    //     for (uint pid = 0; pid < _length; pid++) {
    //         if (poolInfo[pid].lpToken == IPair(lpAddr_)){
    //             _list[i] = pid;
    //             i += 1;
    //         }
    //     }
    // }

    // function checkAllOpenPoolId(address lpAddr_) public view returns(uint[] memory _list){
    //     uint _length = poolInfo.length;
    //     _list = new uint[](_length);
    //     uint i=0;
    //     for (uint pid = 0; pid < _length; pid++) {
    //         if (poolInfo[pid].lpToken == IPair(lpAddr_)){
    //             if (poolInfo[pid].status){
    //                 _list[i] = pid;
    //                 i += 1;
    //             }
    //         }
    //     }
    // }

    function getUserInPool(address user_) public view returns(uint[] memory _list){
        uint length = poolInfo.length;
        _list = new uint[](length);
        uint i = 0;
        // address _lp;
        for (uint pid = 0; pid < length; pid++) {
            if (userInviInfo[pid][user_].power > 0){
                _list[i] = pid;
                i += 1;
            }
        }
    }

    function getPool(uint pid_, address user_) external view returns(bool poolStatus, bool poolLock,
                                                    uint poolDailyOut,
                                                    uint pooltotalPower,
                                                    address[2] memory poolAddressList,
                                                    uint[3] memory poolTimeList,
                                                    uint[2] memory poolBonusCoe,
                                                    uint[2] memory poolLevelAmount,
                                                    string[3] memory symbelList,
                                                    uint[1] memory userList,
                                                    address invitor
                                                    ){
        invitor = userInviInfo[pid_][user_].invitePeople;
        userList[0] = updataUserAllReward(pid_, user_);
        // pool
        PoolInfo storage pool = poolInfo[pid_];
        // poolAddressList = new address[](pool.lpToken.length);
        poolStatus = pool.status;
        poolLock = pool.lockToTime;
        poolAddressList[0] = address(pool.levelLp);
        poolAddressList[1] = address(pool.outPutToken);
        poolDailyOut = pool.dailyOut;
        pooltotalPower = pool.totalPower;
        poolTimeList[0] = pool.startTime; 
        poolTimeList[1] = pool.endTime;
        poolTimeList[2] = pool.lockTime;
        poolBonusCoe[0] = pool.bonusCoe[0];
        poolBonusCoe[1] = pool.bonusCoe[1];
        poolLevelAmount[0] = pool.levelAmount[0];
        poolLevelAmount[1] = pool.levelAmount[1];
        address _t0 = IPair(pool.levelLp).token0();
        address _t1 = IPair(pool.levelLp).token1();

        symbelList[0] = IBEP20(_t0).symbol();
        symbelList[1] = IBEP20(_t1).symbol();
        symbelList[2] = IBEP20(pool.outPutToken).symbol();
    }
    
    function getPoolDetail(uint pid_, address user_) public view 
    returns(string[2][] memory symbelList, uint[] memory lpTVL, address[] memory lpAddressList, uint[] memory userLPAmountList, uint[4] memory userList) {
        PoolInfo storage pool = poolInfo[pid_];


        userList[0] = userInviInfo[pid_][user_].power;
        // userList[1] = userInfo[pid_][addr_].toClaim;
        userList[2] = userInviInfo[pid_][user_].bonus;
        // userList[3] = userInfo[pid_][addr_].claimed;
        address _t0; 
        address _t1;
        uint len = pool.lpToken.length;
        lpTVL = new uint[](len);
        lpAddressList = new address[](len);
        userLPAmountList = new uint[](len);
        symbelList = new string[2][](len);
        address _lp;
        for (uint i =0; i<len; i++) {
            _lp = pool.lpToken[i];
            lpTVL[i] = IBEP20(pool.lpToken[i]).balanceOf(address(this));
            lpAddressList[i] = _lp;
            userLPAmountList[i] = userInfo_slot[pid_][user_][_lp].amount;
            _t0 = IPair(_lp).token0();
            _t1 = IPair(_lp).token1();
            symbelList[i] = [IBEP20(_t0).symbol(), IBEP20(_t1).symbol()];

            userList[1] += (userInfo_slot[pid_][user_][_lp].toClaim + updataUserReward_LP(pid_, _lp, user_));
            userList[3] += userInfo_slot[pid_][user_][_lp].claimed;
        }
    }

    function getLpListInPool(uint pid_) public view returns (address[] memory lpList){
        uint len = poolInfo[pid_].lpToken.length;
        lpList = new address[](len);
        for (uint i=0; i<len; i++) {
            lpList[i] = poolInfo[pid_].lpToken[i];
        }
    }
    // calculate debt
    function updataPoolDebt(uint pid_) public view returns (uint _debt){
        PoolInfo storage pool = poolInfo[pid_];
        uint _rate = pool.dailyOut / 1 days;
        if (block.timestamp < pool.endTime){
            // daily
            _debt = pool.totalPower > 0 ? _rate * (block.timestamp - pool.lastRewardTime) * Acc / pool.totalPower + pool.debtInPool : 0 + pool.debtInPool;
        } else if (block.timestamp >= pool.endTime) {
            if (pool.lastRewardTime >= pool.endTime) {
                // end 
                _debt = pool.debtInPool;
            } else if (pool.lastRewardTime < pool.endTime) {
                // first, updata
                _debt = pool.totalPower > 0 ? _rate * (pool.endTime - pool.lastRewardTime) * Acc / pool.totalPower + pool.debtInPool : 0 + pool.debtInPool;
            }
        }
    }
    
    function updataUserAllReward(uint pid_, address user_) view public returns (uint reward) {

        PoolInfo storage pool = poolInfo[pid_];
        uint len = pool.lpToken.length;
        address _lp;
        for(uint i=0; i<len; i++) {
            _lp = pool.lpToken[i];
            reward += updataUserReward_LP(pid_, _lp, user_);
            reward += userInfo_slot[pid_][user_][_lp].toClaim;
        }
    }
    
    // calculate user LP reward
    function updataUserReward_LP(uint pid_, address lp_, address addr_) view public returns (uint reward) {
        UserInfo_Slot storage user_slot = userInfo_slot[pid_][addr_][lp_];
        PoolInfo storage pool = poolInfo[pid_];
        // in deposit cycle
        uint amount = user_slot.amount;

        // is lock
        if (pool.lockToTime && pool.lockTime != 0) {
            uint endTime = user_slot.depositTime + pool.lockTime;
            if (amount != 0){
                if (block.timestamp < endTime) {
                    uint _debt = updataPoolDebt(pid_);
                    reward = (_debt - user_slot.userDebt) * user_slot.power / Acc;
                // out of deposit cycle
                } else if (block.timestamp >= endTime) {
                    uint _rate = pool.dailyOut / 1 days;
                    // _reward = _rate * ((pool.lockTime + user.depositTime) - user.lastClaimTime) * Acc / pool.lpTVL;
                    uint tempDebt = _rate * (endTime - user_slot.lastClaimTime) * Acc / pool.totalPower;
                    reward = tempDebt * user_slot.power / Acc;
                }
            } else {
                reward =0;
            }
        }
        // not lock
        if (!pool.lockToTime || pool.lockTime == 0){
            if(user_slot.power != 0) {
                uint _debt = updataPoolDebt(pid_);
                reward = (_debt - user_slot.userDebt) * user_slot.power / Acc;
            } else {
                reward =0;
            }
        }
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint length = poolInfo.length;
        for (uint pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 pid_) public {
        PoolInfo storage pool = poolInfo[pid_];
        if (block.timestamp <= pool.lastRewardTime || block.timestamp <= pool.startTime) {
            return;
        }
        if (!pool.status){
            return;
        }
        uint _lpSupply = pool.totalPower;
        if (_lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint _debt = updataPoolDebt(pid_);
        pool.debtInPool = _debt;
        pool.lastRewardTime = block.timestamp;
        if (block.timestamp > pool.endTime){
            pool.status = false;
        }
    }

    function getLpValue(address lp_) public view returns (uint _lpValue) { 
        uint _total = IPair(lp_).totalSupply();
        address _t0 = IPair(lp_).token0();
        address _t1 = IPair(lp_).token1();
        require(_t0 == USDT || _t1 == USDT, "not U pair");
        uint _usdt;
        if (_t0 == USDT){
            (_usdt, , ) = IPair(lp_).getReserves();
        } else if (_t1 == USDT){
            (, _usdt, ) = IPair(lp_).getReserves();
        }
        _lpValue = (_usdt * 2) * Acc / _total;
    }

    //-------------------------------------------------  mining  ------------------------------------------------
    event WhoIsyourReferrer(uint indexed pid, address indexed user, address indexed inv);
    function whoIsyourReferrer(uint pid_, address inv_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInviInfo storage user_inv = userInviInfo[pid_][msg.sender];
        require(user_inv.invitePeople == address(0), "Referrer already");
        require(inv_ != msg.sender, "illegal invitation I");
        address invInv = userInviInfo[pid_][inv_].invitePeople;
        require(invInv != msg.sender, "illegal invitation II");
        uint _lpValue = getLpValue(pool.levelLp);
        uint _balance1 = IPair(pool.levelLp).balanceOf(inv_);
        uint _balance2 = userInfo_slot[pid_][inv_][pool.levelLp].amount;

        require(_lpValue * (_balance2 + _balance1) >= pool.levelAmount[0], "inv Lp value too low");
        user_inv.invitePeople = inv_;

        emit WhoIsyourReferrer(pid_, msg.sender, inv_);
    }

    // Deposit LP tokens to Contract for CTN/CNN allocation.
    function deposit(uint256 pid_, address lp_, uint256 amountIn_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo_Slot storage user_slot = userInfo_slot[pid_][msg.sender][lp_];
        UserInviInfo storage user_inv = userInviInfo[pid_][msg.sender];
        require(lpInPool[pid_][lp_], "lp not in pool");
        require(amountIn_ > 0, '0 is not good');
        require (pool.status && block.timestamp >= pool.startTime && block.timestamp < pool.endTime, 'deposit no good, status');
        require(user_inv.invitePeople != address(0), 'no inv');
        if (user_slot.power > 0) {
            uint pending = updataUserReward_LP(pid_, lp_, msg.sender);
            user_slot.toClaim += pending;
        }
        //user slot
        user_slot.amount += amountIn_;
        user_slot.depositTime = block.timestamp;
        user_slot.lastClaimTime = block.timestamp;
        user_slot.userDebt = updataPoolDebt(pid_);
        updatePool(pid_);
        // power
        uint _power = amountIn_ * lpPower[pid_][lp_];
        user_slot.power += _power;
        user_inv.power += _power;
        pool.totalPower += _power;

        IPair(lp_).transferFrom(msg.sender, address(this), amountIn_);

        emit Deposit(msg.sender, pid_, amountIn_);
    }

    // Claim rewards from designated pool
    function claim_All(uint pid_) public {
        PoolInfo storage pool = poolInfo[pid_];
        uint len = pool.lpToken.length;
        address _lp;

        for (uint i=0; i<len; i++){
            _lp = pool.lpToken[i];
            if (userInfo_slot[pid_][msg.sender][_lp].power >0){
                claim_slot(pid_, _lp);
            }
        }

    }

    function teamBonus(uint pid_, address user_, address lp_, uint bonus_) internal {
        userInviInfo[pid_][user_].bonus += bonus_;
        userInfo_slot[pid_][user_][lp_].bonus += bonus_;
    }

    function claim_slot(uint pid_, address lp_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo_Slot storage user_slot = userInfo_slot[pid_][msg.sender][lp_];
        UserInviInfo storage user_inv = userInviInfo[pid_][msg.sender];
        require (user_slot.power > 0, 'no power');
        
        uint _reward = updataUserReward_LP(pid_, lp_, msg.sender);
        uint reward = _reward;
        if (user_slot.toClaim > 0) {
            uint _temp = user_slot.toClaim;
            _reward += _temp;
            reward = _reward;
            user_slot.toClaim = 0;
        }

        // frist
        address inv = user_inv.invitePeople;
        uint commission = _reward * pool.bonusCoe[0] / 100;
        IBEP20(pool.outPutToken).safeTransfer(inv, commission);
        // userInviInfo[pid_][inv].bonus += commission;
        // userInfo_slot[pid_][inv][lp_].bonus += commission;
        teamBonus(pid_, inv, lp_, commission);
        reward -= commission;

        // second
        address invS = userInviInfo[pid_][inv].invitePeople;
        if(pool.bonusCoe[1] > 0){
            if (invS != address(0)){
                uint _lpValue = getLpValue(address(pool.levelLp));
                // uint _ba1 = IPair(pool.levelLp).balanceOf(invS);
                // uint _ba2 = userInfo_slot[pid_][invS][pool.levelLp].amount;
                uint _value = (IPair(pool.levelLp).balanceOf(invS) + userInfo_slot[pid_][invS][pool.levelLp].amount) * _lpValue;
                if (_value > pool.levelAmount[1]){
                    uint commissionS = _reward * pool.bonusCoe[1] / 100;
                    IBEP20(pool.outPutToken).safeTransfer(invS, commissionS);
                    // userInviInfo[pid_][invS].bonus += commissionS;
                    // userInfo_slot[pid_][invS][lp_].bonus += commissionS;
                    teamBonus(pid_, invS, lp_, commissionS);
                    reward -= commissionS;
                }
            }
        }

        // user slot
        uint _debt = updataPoolDebt(pid_);
        user_slot.claimed += _reward;
        user_slot.userDebt =_debt;
        user_slot.lastClaimTime = block.timestamp;

        IBEP20(pool.outPutToken).safeTransfer(address(msg.sender), reward);
        emit Claim(msg.sender, pid_, _reward);
    }

    // Withdraw LP tokens from Contract.
    function withdraw(uint256 pid_, address lp_) public {
        PoolInfo storage pool = poolInfo[pid_];
        UserInfo_Slot storage user_slot = userInfo_slot[pid_][msg.sender][lp_];
        uint endTime = pool.lockTime + user_slot.depositTime;
        uint amountOut = user_slot.amount;
        if (pool.lockToTime) {
            require(block.timestamp > endTime);
        }   
        require(lpInPool[pid_][lp_], "lp not in pool");
        require (amountOut > 0, '0 is not good');
        // require(user_slot >= amountOut_, "withdraw: amount not good");
        bool _withdraw;
        if (!pool.lockToTime) {
            _withdraw = true;
        } else {
            if (block.timestamp > endTime || block.timestamp > pool.endTime){
                _withdraw = true;
            }
        }
        require(_withdraw, "withdraw: not yet time");
        claim_slot(pid_, lp_);
        if (amountOut > 0 ){
            uint _power = user_slot.power;
            user_slot.amount = 0;
            user_slot.power = 0;

            IPair(lp_).transfer(address(msg.sender), amountOut);

            updatePool(pid_);
            pool.totalPower -= _power;
        }
        emit Withdraw(msg.sender, pid_, amountOut);
    }

    //-----------------------------------------------  Developer  ----------------------------------------------


    // Add a new lp to the pool. Can only be called by the owner.
    // DO NOT add the same LP token Pool more than once. Rewards will be messed up if you do.
    function addPool(bool lockToTime_, uint lockTime_,
                        address levelLp_, 
                        address[] memory lpToken_, 
                        address outPutToken_, 
                        uint dailyOut_, 
                        uint endTime_, 
                        uint[2] memory bonusCoe_, 
                        uint[2] memory levelAmount_, 
                        bool withUpdate_) 
                        public onlyAdmin returns(uint _pid){
        require(initialize, "not started");
        require(endTime_ > block.timestamp, "out of time");
        // if (endTime_ == 9999999999) {
        //     require(!lockToTime_, "stake forever!");
        // }
        if (withUpdate_) {
            massUpdatePools();
        }
        _pid = poolInfo.length;
        uint _lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        poolInfo.push(PoolInfo({
            status: true,
            lockToTime: lockToTime_,
            levelLp:levelLp_,
            lpToken: lpToken_,
            outPutToken: outPutToken_,
            dailyOut: dailyOut_,
            lastRewardTime: _lastRewardTime,
            debtInPool: 0,
            totalPower: 0,
            startTime: block.timestamp,
            endTime: endTime_,
            lockTime:lockTime_,
            bonusCoe:bonusCoe_,
            levelAmount:levelAmount_
        }));
        emit AddPool(address(levelLp_), address(outPutToken_));
    }

    function addTimeLimitPool(bool lockToTime_, uint lockTime_,
                                address levelLp_, 
                                address[] memory lpToken_, 
                                address outPutToken_, 
                                uint dailyOut_, 
                                uint startTime_, 
                                uint endTime_, 
                                uint[2] memory bonusCoe_, 
                                uint[2] memory levelAmount_,
                                bool withUpdate_)
                                public onlyAdmin returns(uint _pid){
        require(initialize, "not started");
        require(block.timestamp < startTime_ && startTime_ < endTime_, "out of time");
        // if (endTime_ == 9999999999) {
        //     require(!lockToTime_, "stake forever!");
        // }
        if (withUpdate_) {
            massUpdatePools();
        }
        _pid = poolInfo.length;
        // uint _lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        poolInfo.push(PoolInfo({
            status: true,
            lockToTime: lockToTime_,
            levelLp:levelLp_,
            lpToken: lpToken_,
            outPutToken: outPutToken_,
            dailyOut: dailyOut_,
            lastRewardTime: startTime_,
            debtInPool: 0,
            totalPower: 0,
            startTime: startTime_,
            endTime: endTime_,
            lockTime:lockTime_,
            bonusCoe:bonusCoe_,
            levelAmount:levelAmount_
        }));
        emit AddPool(address(levelLp_), address(outPutToken_));
    }

    function setClosePool(uint pid_) public onlyAdmin {
        require(poolInfo[pid_].status, "allready close");
        poolInfo[pid_].status = false;
        poolInfo[pid_].endTime = block.timestamp;
    }
    
    // Update the pool's daily output. Can only be called by the owner.
    function setAdjustPoolDailyOut(uint256 _pid, uint256 dailyOut_, bool _withUpdate) public onlyAdmin {
        if (_withUpdate) {
            massUpdatePools();
        }
        require(block.timestamp < poolInfo[_pid].startTime, "allready start");
        poolInfo[_pid].dailyOut = dailyOut_;
    }
 
    function setPoolEndTime(uint pid_, uint endTime_) public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require(block.timestamp < endTime_, "not good time");
        pool.endTime = endTime_;
    }

    function setPoolStartTime(uint pid_, uint startTime_)public onlyAdmin {
        PoolInfo storage pool = poolInfo[pid_];
        require( block.timestamp < startTime_ && block.timestamp < pool.startTime, "not good time");
        pool.startTime = startTime_;
    }   
    function setbonusCoe(uint pid_, uint first_, uint second_) public onlyAdmin{
        poolInfo[pid_].bonusCoe[0] = first_;
        poolInfo[pid_].bonusCoe[1] = second_;
    }

    function setlevel(uint pid_, uint inviteRequirement_, uint levelTwoDividend_) public onlyAdmin {
        poolInfo[pid_].levelAmount[0] = inviteRequirement_;
        poolInfo[pid_].levelAmount[1] = levelTwoDividend_;
    }

    function setAdmin(address addr_) public onlyOwner {
        isAdmin[addr_] = true;
    }   

    function remoaveAdmin(address addr_) public onlyOwner {
        isAdmin[addr_] = false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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