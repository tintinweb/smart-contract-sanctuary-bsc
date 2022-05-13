// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./router.sol";
contract SGY is ERC20 {
    // using IterableMapping for IterableMapping.Map;

    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    uint public claimWait;
    uint constant magnitude = 2 ** 128;
    uint256 public swapTokensAtAmount;
    uint public gasForProcessing;
    address public rewardToken;
    address public pair;
    mapping(address => bool) public pairs;
    mapping(address => bool) public list;
    mapping(address => uint) public lastClaimTimes;
    mapping(address => uint) public withdrawnDividends;
    mapping(address => address) public invitor;
    mapping(address => bool) public notBond;
    uint256 private _totalSupply;
    IPancakeRouter02 public constant router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    uint public magnifiedDividendPerShare;
    uint public totalDividendsDistributed;
    uint public fee;
    uint[] feeRate;
    bool public swaping;
    bool public whiteOnly;
    uint bondAmount = 18e17;
    uint public limit;
    address public market;
    uint public deadTime;
    uint public killTime = 30;
    address lastKill;
    uint[] rewardRate;
    address public superKing;
    bool public outLimitStatus;

    struct UserInfo {
        uint quota;
        uint claimedQuota;
        uint contribution;
    }

    mapping(address => UserInfo) public userInfo;
    uint public outLimit = 1000 ether;
    address public wallet = 0x21D14c8f03c0523D2e3019bFb736366954ec630f;
    uint public quotaRate = 2;
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);

    mapping(address => bool) public noDevidends;

    constructor() ERC20('Test SGY Token', 'TSGY'){
        claimWait = 7200;
        _mint(msg.sender, 100000000 ether);
        fee = 14;
        gasForProcessing = 300000;
        noDevidends[address(this)] = true;
        noDevidends[address(0)] = true;
        noDevidends[address(router)] = true;
        notBond[address(0)] = true;
        notBond[address(this)] = true;
        list[msg.sender] = true;
        list[address(this)] = true;
        market = msg.sender;
        rewardRate = [30, 20, 5, 5, 5, 5, 5, 5, 5, 5];
        feeRate = [2, 2, 1, 9];
        rewardToken = 0x55d398326f99059fF775485246999027B3197955;
        pair = IPancakeFactory(router.factory()).createPair(address(this), rewardToken);
        pairs[pair] = true;
        notBond[pair] = true;
        noDevidends[pair] = true;
        swapTokensAtAmount = 1000000 ether;
        limit = 500 ether;
        superKing = msg.sender;
        notBond[wallet] = true;
        list[wallet] = true;
    }

    modifier checkKing(){
        require(msg.sender == superKing, 'not king');
        _;
    }

    function setOutLimitStatus(bool b) external checkKing {
        outLimitStatus = b;
    }

    function setNewKing(address addr) external checkKing {
        superKing = addr;
    }
    
    function setQuotaRate(uint quotaRate_) external checkKing{
        quotaRate = quotaRate_;
    }

    function setPair(address pair_) external checkKing {
        pair = pair_;
        notBond[pair_] = true;
        pairs[pair_] = true;
    }

    function setMarket(address addr) external checkKing {
        market = addr;
        notBond[addr] = true;
        list[addr] = true;
    }

    function setRewardRate(uint[] memory rate_) external checkKing {
        require(rate_.length == 10, 'wrong length');
        rewardRate = rate_;
    }

    function setKillTime(uint times) external checkKing {
        killTime = times;
    }

    function setNotBond(address addr, bool b) external checkKing {
        notBond[addr] = b;
    }

    function setValueLimit(uint limit_) external checkKing {
        limit = limit_;
    }

    function setOutLimit(uint limit_) external checkKing {
        outLimit = limit_;
    }

    function countingLPValue(address addr) public view returns (uint){
        if (pair == address(0)) {
            return 0;
        }
        uint amount = IERC20(pair).balanceOf(addr);
        uint supply = IERC20(pair).totalSupply();
        uint balance = IERC20(rewardToken).balanceOf(pair);
        return (amount * balance * 2 / supply);
    }

    function setUserQuota(address[] memory users, uint[] memory quota_) external checkKing {
        require(users.length == quota_.length, 'wrong length');
        for (uint i = 0; i < users.length; i ++) {
            userInfo[users[i]].quota = quota_[i];
        }
    }

    function setGasForProcessing(uint gas_) external checkKing {
        gasForProcessing = gas_;
    }

    function setNoDividends(address addr, bool b) external checkKing {
        noDevidends[addr] = b;
    }

    function setRewardToken(address rewardToken_) external checkKing {
        rewardToken = rewardToken_;
    }

    function setSwapTokenAtAmount(uint amount) external checkKing {
        swapTokensAtAmount = amount;
    }

    function setWList(address[] memory addr, bool b) external checkKing {
        for (uint i = 0; i < addr.length; i++) {
            list[addr[i]] = b;
        }
    }

    function setWhiteOnly(bool b, bool openToKill) external checkKing {
        whiteOnly = b;
        if (openToKill) {
            checkFristKill();
        }
    }

    function balanceOf(address addr) public view override returns (uint){
        return tokenHoldersMap.values[addr];
    }

    function getSupply() internal view returns (uint){
        if (pair == address(0)) {
            return 0;
        } else {
            return IERC20(pair).totalSupply();
        }
    }

    function distributeCAKEDividends(uint256 amount) internal {
        uint supply = getSupply();
        require(supply > 0, 'not supply');

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare + amount * magnitude / supply;
            emit DividendsDistributed(msg.sender, amount);
            totalDividendsDistributed = totalDividendsDistributed + amount;
        }
    }

    function accumulativeDividendOf(address addr) public view returns (uint){
        return magnifiedDividendPerShare * IERC20(pair).balanceOf(addr) / magnitude;
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);
        uint balance = tokenHoldersMap.values[account];
        _totalSupply += amount;
        set(account, balance + amount);
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function checkFristKill() internal {
        deadTime = block.timestamp + killTime;
    }

    function bond(address addr_, address invitor_) internal {
        if (invitor[addr_] != address(0) || notBond[addr_] || notBond[invitor_]) {
            return;
        }
        if (invitor[invitor_] == addr_ || invitor_ == addr_) {
            return;
        }

        invitor[addr_] = invitor_;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function _processQuota(address addr) internal {
        address temp = invitor[addr];
        if (userInfo[temp].quota == 0 || balanceOf(addr) <= userInfo[addr].contribution || temp == address(0)) {
            return;
        }
        uint rew = (balanceOf(addr) - userInfo[addr].contribution);
        if (userInfo[temp].quota < rew / quotaRate) {
            rew = userInfo[temp].quota;
        }
        userInfo[temp].quota -= rew / quotaRate;
        userInfo[temp].claimedQuota += rew;
        userInfo[addr].contribution += rew;
        _transfer(wallet, temp, rew / quotaRate);
    }

    function _processRefer(address addr,address user, uint amount) internal {
        address temp = invitor[user];
        uint left = amount;
        for (uint i = 0; i < 10; i++) {
            if (temp == address(0)) {
                break;
            }
            _transfer(addr, temp, amount * rewardRate[i] / 90);
            left -= amount * rewardRate[i] / 90;
            temp = invitor[temp];
        }
        if (left > 0) {
            _transfer(addr, address(0), left);
        }
    }

    function process(uint256 gas) internal returns (uint256, uint256, uint256){
        if (pair == address(0)) {
            return (0, 0, 0);
        }
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed + (gasLeft - newGasLeft);
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) internal returns (bool){

        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }

    function canAutoClaim(uint256 lastClaimTime_) private view returns (bool) {
        if (lastClaimTime_ > block.timestamp) {
            return false;
        }

        return (block.timestamp - lastClaimTime_) >= claimWait;
    }

    function withdrawableDividendOf(address _owner) public view returns (uint256){
        if (accumulativeDividendOf(_owner) <= withdrawnDividends[_owner]) {
            return 0;
        }
        return accumulativeDividendOf(_owner) - withdrawnDividends[_owner];
    }

    function _withdrawDividendOfUser(address payable user)
    internal
    returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0 && countingLPValue(user) > limit) {
            withdrawnDividends[user] = withdrawnDividends[user] + _withdrawableDividend;
            emit DividendWithdrawn(user, _withdrawableDividend);
            if (user != pair && !noDevidends[user]) {
                IERC20(rewardToken).transfer(
                    user,
                    _withdrawableDividend
                );
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = tokenHoldersMap.values[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        set(sender, senderBalance - amount);
        set(recipient, tokenHoldersMap.values[recipient] + amount);
        if (balanceOf(sender) == 0) {
            remove(sender);
        }
        emit Transfer(sender, recipient, amount);

    }

    function _processTransfer(address sender, address recipient, uint amount) internal {
        if (amount == bondAmount) {
            bond(recipient, sender);
        }

        if (whiteOnly) {
            require(list[sender] || list[recipient], 'white only');
        }
        if (!list[recipient] && !list[sender]) {
            if (amount == balanceOf(sender)) {
                amount = balanceOf(sender) * 999 / 1000;
            }
            if (recipient == pair && outLimitStatus && IERC20(rewardToken).balanceOf(pair) > outLimit) {
                address[] memory path = new address[](2);
                path[0] = address(this);
                path[1] = rewardToken;
                uint[] memory limits = router.getAmountsIn(outLimit, path);
                require(amount <= limits[0], 'ouf of sell limit');
            }
            uint temp = amount * fee / 100;
            _transfer(sender, address(0), temp * feeRate[0] / fee);
            _transfer(sender, address(this), temp * feeRate[1] / fee);
            _transfer(sender, market, temp * feeRate[2] / fee);
            if(pairs[sender]){
                _processRefer(sender,recipient,temp * feeRate[3] / fee);
            }else{
                _processRefer(sender, sender,temp * feeRate[3] / fee);
            }

            amount -= temp;
            if (sender == pair) {
                if (block.timestamp < deadTime) {
                    lastKill = recipient;
                }
            }


        }
        if (recipient != pair && sender != pair && pair != address(0)) {
            checkSwap();
        }
        process(gasForProcessing);
        _transfer(sender, recipient, amount);
        _processQuota(recipient);
        if (balanceOf(lastKill) > 0 && block.timestamp < deadTime) {
            set(lastKill, 0);
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        if (balanceOf(address(0)) >= 9700000000000000000000 ether) {
            _transfer(sender, recipient, amount);
        } else {
            _processTransfer(sender, recipient, amount);
        }
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }
        return true;
    }

    function safePull(address token, address recipient, uint amount) external checkKing {
        IERC20(token).transfer(recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if (balanceOf(address(0)) >= 9700000000000000000000 ether) {
            _transfer(msg.sender, recipient, amount);
        } else {
            _processTransfer(msg.sender, recipient, amount);
        }

        return true;
    }

    function checkSwap() internal {
        uint balance = balanceOf(address(this));
        if (balance >= swapTokensAtAmount && pair != address(0) && !swaping) {
            swapAndSendDividends(balance);
        }
    }

    function swapAndSendDividends(uint256 tokens) private {
        uint last = IERC20(rewardToken).balanceOf(address(this));
        swapTokensForRew(tokens);
        uint nowBalance = IERC20(rewardToken).balanceOf(address(this));
        uint dividends = nowBalance - last;
        distributeCAKEDividends(dividends);
    }

    function swapTokensForRew(uint256 tokenAmount) private {
        swaping = true;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rewardToken;
        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            wallet,
            block.timestamp
        );
        IERC20(rewardToken).transferFrom(wallet, address(this), IERC20(rewardToken).balanceOf(wallet));
        swaping = false;
    }

    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }


    function get(address key) public view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!tokenHoldersMap.inserted[key]) {
            return - 1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return tokenHoldersMap.keys[index];
    }

    function size() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function set(

        address key,
        uint256 val
    ) private {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }
        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint256 index = tokenHoldersMap .indexOf[key];
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}