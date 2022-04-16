// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Presale is Ownable {
    using SafeMath for uint256;

    struct PoolInfo {
        uint id;
        string name;            //Sale name
        uint256 price;      //per 1 ETH value
        uint256 hardCap;    //
        uint256 softCap;    //
        uint256 locked;     // total token locked
        uint256 raised;     // ETH raised
        uint256 minVal;     //Buy min
        uint256 maxVal;     //Buy max
        uint256 openingTime;
        uint256 closingTime;
        uint256 earnWhitelist;  // percent
        uint256 earnReferral;   // percent
        bool hide; //           // show/hide pool
        bool whitelistOnly;     // only whitelist can buy
    }

    struct RefInfo {
        uint pid;
        mapping(address => uint256) raised;
        address[] lookup;
        uint256 total; //total ETH
    }

    struct RefView {
        address addr;
        uint256 raised; //total ETH
    }

    struct VestingInfo {
        uint index;
        uint256 openingTime;
        uint256 percent;
    }

    struct UserBuy {
        uint pid; //lock buy pool
        uint256 locked; //lock buy pool
        uint256 raised; //earn calculate earch buy
        uint256 refRaised; //total ref raised
        uint luckyNumber; //total token wined
        bool isWhitelist; //token withdraw
    }

    struct UserClaim {
        uint256 locked; //lock buy all pool
        uint256 withdrawed; //token withdrawed
        uint lastclaim; //
    }

    //user balance: addr -> [poolid -> uinfo]
    mapping(address => mapping(uint => UserBuy)) private _buyed;
    mapping(address => UserClaim) private _claiming;
    mapping(address => uint256) private _claimRef;
    mapping(address => uint256) private _claimLuck;
    mapping(address => RefInfo) private _refLogs;
    //pool info
    mapping(uint256 => PoolInfo) private _pools;
    uint public poolsLength = 0;

    IERC20 public sellToken;

    mapping(address => bool) private _whitelist; //

    //percent
    uint256 public apr = 15000;
    uint256 private denominator = 10000;

    //Claim:
    address public rewardWallet;
    uint256 public releaseTime = 1701302400;
    uint256 public releaseRefTime = 1701302400;
    uint256 public releaseLuckyTime = 1701302400;

     //150%/year
    mapping(uint => VestingInfo) private _vesting;
    uint public vestingLength = 0;

    //Events:
    event TokensPurchased(
        address indexed beneficiary,
        uint256 value,
        uint256 token,  //buyed
        uint256 poolid,
        uint256 locked, //total locked
        uint256 price,  //
        uint256 hardcap
    );
    event ClaimToken(address indexed beneficiary, uint256 amount);
    event Withdrawtoken(address indexed to, uint256 amount);
    event SetDone(address indexed to, bool result);

    constructor(IERC20 _token){
        sellToken = _token;
    }

    modifier onlySaleOpen(uint256 pid) {
        require(isPoolOpen(pid), "Seed pool not open");
        _;
    }

    function isPoolOpen(uint256 pid) public view returns (bool) {
        return
            block.timestamp >= _pools[pid].openingTime &&
            block.timestamp <= _pools[pid].closingTime &&
            _pools[pid].hardCap > _pools[pid].raised;
    }

    function getPoolOpen() public view returns (uint) {
        for (uint256 index = 0; index < poolsLength; index++) {
            if (block.timestamp >= _pools[index].openingTime && block.timestamp <= _pools[index].closingTime && _pools[index].hardCap > _pools[index].raised) {
                return index;
            }
        }
        return 999;
    }

    function importPresale(address[] calldata addrs, uint256[] calldata amounts) external onlyOwner{
        for(uint i=0; i< addrs.length; i++){
            _claiming[addrs[i]].locked = _claiming[addrs[i]].locked.add(amounts[i]);
            _claiming[addrs[i]].withdrawed = 0;
            _claiming[addrs[i]].lastclaim = 0;
        }
    }

    function importRefReward(address[] calldata addrs, uint256[] calldata amounts) external onlyOwner{
        for(uint i=0; i< addrs.length; i++){
            _claimRef[addrs[i]] = _claimRef[addrs[i]].add(amounts[i]);
        }
    }

    function importLuckReward(address[] calldata addrs, uint256[] calldata amounts) external onlyOwner{
        for(uint i=0; i< addrs.length; i++){
            _claimLuck[addrs[i]] = _claimLuck[addrs[i]].add(amounts[i]);
        }
    }

    function getPoolInfo(uint256 pid) public view returns (PoolInfo memory) {
        return _pools[pid];
    }

    function pool(uint256 pid, string memory name, uint256 price, uint256 hardCap, uint256 softCap, uint256 minUserCap, uint256 maxUserCap, uint256 openingTime, uint256 closingTime) external onlyOwner {
        require(price > 0, "token price is 0");
        require(closingTime > openingTime, "opening is not before closing");

        poolsLength++;
        _pools[pid].id = pid;
        _pools[pid].name = name;
        _pools[pid].hardCap = hardCap;
        _pools[pid].softCap = softCap;
        _pools[pid].price = price;

        _pools[pid].locked = 0;
        _pools[pid].raised = 0;

        _pools[pid].minVal = minUserCap;
        _pools[pid].maxVal = maxUserCap;

        _pools[pid].openingTime = openingTime;
        _pools[pid].closingTime = closingTime;
    }

    function poolSetup(uint256 pid, uint256 whitelistpercent, uint256 referralpercent, bool hide, bool wlonly) external onlyOwner {
        _pools[pid].earnWhitelist = whitelistpercent;
        _pools[pid].earnReferral = referralpercent;
        _pools[pid].hide = hide;
        _pools[pid].whitelistOnly = wlonly;
    }

    function setMaxPools(uint _max) external onlyOwner {
        poolsLength = _max;
    }

    function getMaxPools() public view returns (uint256) {
        return poolsLength;
    }

    function getPools() public view returns (PoolInfo[] memory) {
        PoolInfo[] memory pools = new PoolInfo[](poolsLength);
        for (uint256 i = 0; i < poolsLength; i++) {
            pools[i] = _pools[i];
        }
        return pools;
    }

    function isWhitelist() public view returns (bool) {
        return _whitelist[msg.sender];
    }

    function setWhitelist(address addr, bool val) external onlyOwner {
        require(addr != address(0), "addr is 0");
        _whitelist[addr] = val;
    }

    function addWhitelist() external {
        _whitelist[msg.sender] = true;
        emit SetDone(msg.sender, true);
    }

    function setToken(address addr) external onlyOwner {
        require(addr != address(0), "token is 0");
        sellToken = IERC20(addr);
    }

    function weiRaised() public view returns (uint256) {
        return address(this).balance;
    }

    function getRaised(uint256 pid) public view returns (uint256) {
        return _pools[pid].raised;
    }

    receive() external payable{
        uint poolid = getPoolOpen();
        require(poolid < 999, "all pool has closed");
        if(msg.value > 0){
            buyToken(poolid, address(0), block.timestamp % 1000);
        }
    }   
     
    function withdrawToken(address _to, uint256 _amount) external onlyOwner {
        require(sellToken.balanceOf(address(this)) >= _amount, "Not enough token");
        require(_to != address(0), "Destination is 0");
        sellToken.transfer(_to, _amount);
        emit Withdrawtoken(_to, _amount);
    }

    function withdrawReward(uint256 _amount) external onlyOwner {
        require(sellToken.balanceOf(address(this)) >= _amount, "Not enough token");
        //sellToken.transfer(_to, _amount);
        sellToken.transferFrom(rewardWallet, msg.sender, _amount);
        emit Withdrawtoken(msg.sender, _amount);
    }

    function withdrawRewardTo(address _to, uint256 _amount) external onlyOwner {
        require(sellToken.balanceOf(address(this)) >= _amount, "Not enough token");
        require(_to != address(0), "Destination is 0");
        //sellToken.transfer(_to, _amount);
        sellToken.transferFrom(rewardWallet, msg.sender, _amount);
        emit Withdrawtoken(_to, _amount);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success, "receiver rejected BNB transfer");
    }

    function setVestingTime(uint256 _time) external onlyOwner {
        releaseTime = _time;
    } 
     function setRefClaimTime(uint256 _time) external onlyOwner {
        releaseRefTime = _time;
    } 
     function setLuckyClaimTime(uint256 _time) external onlyOwner {
        releaseLuckyTime = _time;
    } 

    function balanceOf(address account) public view returns (uint256 avail, uint256 locked, uint256 claimed) {
        return (_claiming[account].locked - _claiming[account].withdrawed, _claiming[account].locked, _claiming[account].withdrawed);
    }

    function getBuyInfo(uint pid, address account) public view returns (UserBuy memory) {
        return _buyed[account][pid];
    }

    

    function getClaimInfo(address account) public view returns (UserClaim memory) {
        return _claiming[account];
    }

    function getRefUser(address addr) public view returns (RefView[] memory) {
        uint count = _refLogs[addr].lookup.length;
        RefView[] memory ret = new RefView[](count);
        //mapping(address => uint256) storage raised = _refLogs[addr].raised;
        for (uint256 i = 0; i < count; i++) {
            //ret.push(RefView(_refLogs[addr].lookup[i], _refLogs[addr].raised[_refLogs[addr].lookup[i]]));
            ret[i].addr = _refLogs[addr].lookup[i];
            ret[i].raised = _refLogs[addr].raised[_refLogs[addr].lookup[i]];
        }
        return ret;
    }

    function getRefReward(address account) public view returns (uint256) {
        return _claimRef[account];
    }

    function getLuckReward(address account) public view returns (uint256) {
        return _claimLuck[account];
    }

    function _preValidatePurchase(uint256 pid, address beneficiary, uint256 weiAmount) internal virtual onlySaleOpen(pid) {
        require(beneficiary != address(0), "beneficiary is the zero address");
        require(weiAmount > 0, "weiAmount is 0");
        require(_pools[pid].raised.add(weiAmount) <= _pools[pid].hardCap,"hardcap exceeded");
        require(weiAmount >= _pools[pid].minVal, "cap minimal required");
    }

    function buyToken(uint256 pid, address refaddr, uint ln) public payable {
        address beneficiary = _msgSender();
        uint256 weiAmount = msg.value;
        _preValidatePurchase(pid, beneficiary, weiAmount);
        //POOL
        uint256 tokenAmount = weiAmount.mul(_pools[pid].price).div(10**18);
        _pools[pid].raised = _pools[pid].raised.add(weiAmount);
        _pools[pid].locked = _pools[pid].locked.add(tokenAmount);
        
        //USER
        _buyed[beneficiary][pid].pid = pid;
        _buyed[beneficiary][pid].luckyNumber = ln;
        _buyed[beneficiary][pid].isWhitelist = _whitelist[beneficiary];
        _buyed[beneficiary][pid].raised = _buyed[beneficiary][pid].raised.add(weiAmount);
        _buyed[beneficiary][pid].locked = _buyed[beneficiary][pid].locked.add(tokenAmount);
        //TOTAL:
        _claiming[beneficiary].locked = _claiming[beneficiary].locked.add(tokenAmount);

        //REF USER:
        if (refaddr != address(0)) {
            //total ref:
            _buyed[refaddr][pid].refRaised = _buyed[refaddr][pid].refRaised.add(weiAmount);
            //log ref
            _refLogs[refaddr].pid = pid;
            if (_refLogs[refaddr].raised[beneficiary] == 0) {
                _refLogs[refaddr].lookup.push(beneficiary); 
            }
            _refLogs[refaddr].raised[beneficiary].add(weiAmount); // refLogs.push(RefInfo(pid, msg.sender, weiAmount));
            _refLogs[refaddr].total.add(weiAmount);
            //earn ref
            // uint256 earnAmount = tokenAmount.mul(_pools[pid].earnReferral).div(denominator);
            // _balances[refaddr][pid].earned = _balances[refaddr][pid].earned.add(earnAmount);
            // _claiming[refaddr].locked = _claiming[refaddr].locked.add(earnAmount);
        }
        emit TokensPurchased(beneficiary, weiAmount, tokenAmount, pid, _pools[pid].locked, _pools[pid].price, _pools[pid].hardCap);
    }

    function amountCanClaim(address holder) public view returns(uint256){
        if(_claiming[holder].locked == 0){
            return 0;
        }
        //before release time
        if(block.timestamp < releaseTime){
            return 0;
        }
        //in
        for (uint256 i = 0; i < vestingLength - 1; i++) {
            if(block.timestamp >= releaseTime.add(_vesting[i].openingTime) && block.timestamp < releaseTime.add(_vesting[i + 1].openingTime)){
                return _claiming[holder].locked.mul(_vesting[i].percent).div(denominator).sub(_claiming[holder].withdrawed);
            }
        }
        // release all
        if(block.timestamp >= releaseTime.add(_vesting[vestingLength - 1].openingTime)){
            return _claiming[holder].locked.sub(_claiming[holder].withdrawed);
        }
        return 0;
    }

    //amount per pool can claim locked token 
    function checkClaim(uint pid, address holder) public view returns(string memory, uint, uint256){
        if(_buyed[holder][pid].locked == 0){
            return ("Locked is zero", 0, 0);
        }
        //before release time
        if(block.timestamp < releaseTime){
            return ("not at this time", 0, 0);
        }
        //in
        for (uint256 i = 0; i < vestingLength - 1; i++) {
            if(block.timestamp >= releaseTime.add(_vesting[i].openingTime) && block.timestamp < releaseTime.add(_vesting[i + 1].openingTime)){
                return ("Pool/Locked: ", i, _buyed[holder][pid].locked);
            }
        }
        // release all
        if(block.timestamp >= releaseTime.add(_vesting[vestingLength - 1].openingTime)){
            return ("vesting all", 0, 0);
        }
        return ("NA", 0, 0);
    }

    function rewardAmount(address holder) public view returns(uint){
        uint256 amount = _claiming[holder].locked.sub(_claiming[holder].withdrawed);
        if(amount == 0){
            return 0;
        }
        uint timeElapsed;
        if(_claiming[holder].lastclaim != 0){
            timeElapsed = block.timestamp - _claiming[holder].lastclaim;
        }else{
            timeElapsed = block.timestamp - releaseTime;
        }
        uint256 reward = amount.mul(timeElapsed).div(365 days).mul(apr).div(denominator);
        return reward;
    }

    function claim() external{
        require(block.timestamp >= releaseTime, "Wait for release time");
        require(_claiming[msg.sender].locked > 0, "Your balance is 0");
        uint256 amount = amountCanClaim(msg.sender);
        if(amount > 0){
            require(sellToken.balanceOf(address(this)) >= amount, "Not enough token");
            // reward stake
            uint reward = rewardAmount(msg.sender);
            if(reward > 0){
                sellToken.transferFrom(rewardWallet, msg.sender, reward);
                _claiming[msg.sender].lastclaim = block.timestamp;
            }
            // release
            sellToken.transfer(msg.sender, amount);
            //totalHold = totalHold.sub(amount);
            _claiming[msg.sender].withdrawed = _claiming[msg.sender].withdrawed.add(amount);
            emit ClaimToken(msg.sender, amount);
        }
    }

    function setRewardWallet(address _rewardWallet) external onlyOwner{
        require(_rewardWallet != address(0), "Zero address");
        rewardWallet = _rewardWallet;
    }

    function luckyNumber(uint pid, address _wallet) public view returns(uint) {
        return _buyed[_wallet][pid].luckyNumber;
    }

    function setAPR(uint _apr) external onlyOwner{
        apr = _apr;
    }

    function vesting(uint _index, uint256 _time, uint256 _vestpercent) external onlyOwner{
        vestingLength++;
        _vesting[_index].index = _index;
        _vesting[_index].openingTime = _time;
        _vesting[_index].percent = _vestpercent;
    }

    function getVesting(uint _index) public view returns(VestingInfo memory) {
        return _vesting[_index];
    }

    function setMaxVesting(uint _length) external onlyOwner{
        vestingLength = _length;
    }

    function getMaxVesting() public view returns(uint) {
        return vestingLength;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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