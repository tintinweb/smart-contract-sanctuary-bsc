/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IBEP20 {
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
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
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        // _owner = address(0);
        _owner = _owner;
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
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

interface ISC {
    function calcPrice(address _pair, uint256 _r) external view returns (uint256);
    function checkKey(address account, uint256 _key) external view returns(bool);
    function getDate(uint timestamp) external pure returns(uint256);
}

struct UserRewards {
    address account;
    uint256 balances;
    uint256 timestamp;
    uint256 reward;
    uint256 rewardPaid;
    uint256 count;
}

contract Donate3 is Ownable {
    using SafeMath for uint256;
    using Address for address;

    address public constant _USDT = 0x55d398326f99059fF775485246999027B3197955; 
    address public _TOKEN = 0x4CCa8cCd5457b26E46Cebb28572D85035c27CA16; 
    address public _service = 0x1C2008856EE53d7477d11fCa8b31A7CD88f1B444; // BSC service center

    IBEP20 public usdt;
    IBEP20 public token;
    ISC public sc;
    uint256 private _totalSupplyHistory;
    uint256 private _totalSupply;
    uint256 private _totalBonusSupply;
    uint256 private _totalPeople;
    uint256[] public purchase;
    mapping(uint256 => address) private _code2Addr; // code to address
    mapping(address => uint256) private _addr2Code; // address to code
    mapping(address => uint256) private _bonus;
    mapping(address => uint256) private _bonusSum;
    mapping(address => address[]) private _bonusBind; // root list
    address[] private rewardsMapIndex;
    mapping(address => UserRewards) private rewardsMap;
    uint256[] private removeRewardsIndex;
    
    uint256 public lastMiningTimestamp = 0;
    uint256 public minDay = 20;
    uint256 public deadDay = 60;
    uint256 public buyMax = 10000 * 10**18; // every day max
    uint256 public buyDayed = 0; // every day buyed

    event Buyed(address indexed user, uint256 amount);
    event Bonused(address indexed user, address indexed client, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount);
    event WithdrawnALL(address indexed user, uint256 amount);
    event WithdrawBonus(address indexed user, uint256 amount);
    event WithdrawReward(address indexed user, uint256 amount);
    event Mining(address indexed account, uint256 count, uint256 dao, uint256 reward, uint256 rewardPaid, uint256 timestamp);
    event MiningOut(address indexed account, uint256 count, uint256 reward, uint256 rewardPaid, uint256 timestamp, uint256 index);
    event BuyDayed(address indexed account, uint256 buyDayed, uint256 buyMax);
    event SetBuyMax(address indexed account, uint256 buyMax);
    event SetBuyDayed(address indexed account, uint256 buyDayed);

    constructor() {
        usdt = IBEP20(_USDT); // USDT bsc
        token = IBEP20(_TOKEN); // token bsc
        sc = ISC(_service);
      
        purchase.push(150 * 10**18);
        purchase.push(300 * 10**18);
        purchase.push(500 * 10**18); // 500 USDT
    }

    function setService(address addr) public onlyOwner {
        _service = addr;
        sc = ISC(_service);
    }

    function setToken(address _token) public onlyOwner {
        token = IBEP20(_token); 
    }
    
    function getBonusBind(address account, uint256 _key) public view returns(address[] memory) {
        if(sc.checkKey(address(this), _key)){
            return _bonusBind[account];
        }
        address[] memory empty;
        return empty;
    }
    
    function getBonusSum(address account, uint256 _key) public view returns(uint256) {
        if(sc.checkKey(address(this), _key)){
            return _bonusSum[account];
        }
        return 0;
    }

    function totalPeople() public view returns (uint256) {
        return _totalPeople;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function totalSupplyHistory() public view returns (uint256) {
        return _totalSupplyHistory;
    }

    function balanceOf(address account) public view returns (uint256) {
        return rewardsMap[account].balances;
    }

    function getBalancesTimestamp(address account) public view returns (uint256) {
        return rewardsMap[account].timestamp;
    }

    function getRewardPerTokenPaid(address account) public view returns (uint256) {
        return rewardsMap[account].rewardPaid;
    }

    function myReward(address account) public view returns(uint256) {
        return rewardsMap[account].reward;
    }

    function myCode(address account) public view returns (uint256) {
        return _addr2Code[account];
    }

    function getRewardMap(address account) public view returns(UserRewards memory){
        return rewardsMap[account];
    }

    function createCode(address account ) private {
        uint256 code = block.timestamp;
        if(_code2Addr[code] != address(0)){
            code = code.sub(3);
        }
        _addr2Code[account] = code;
        _code2Addr[code] = account;
    }

    function DaysDiff(uint256 t1, uint256 t2) public pure returns(uint256){
        uint256 daysDiff = 0;
        if(t1 > t2){
            daysDiff = t1.sub(t2).div(86400);
        }else{
            daysDiff = t2.sub(t1).div(86400);
        }
        return daysDiff;
    }

    // version 3.0
    function buy(uint256 purchaseIndex, uint256 code) public {
        require(buyMax > buyDayed, "no margin");
        require(rewardsMap[msg.sender].balances == 0, "Cannot buy");
        require(
            purchaseIndex >= 0 && purchaseIndex < purchase.length,
            "No corresponding item"
        );

        uint256 _maxAmount = purchase[purchaseIndex];
        _totalSupplyHistory = _totalSupplyHistory.add(_maxAmount);        
        _totalPeople = _totalPeople.add(1);
        buyDayed = buyDayed.add(_maxAmount);

        rewardsMapIndex.push(msg.sender);
        rewardsMap[msg.sender] = UserRewards(msg.sender, _maxAmount, block.timestamp, 0, 0, 0);

        createCode(msg.sender);
        if (code != 0) {
            // add bonus
            uint256 b = _maxAmount.mul(100).div(1000);
            address account = _code2Addr[code];
            require(account != address(0), "need real code");
            _bonusBind[msg.sender] = _bonusBind[account];
            _bonusBind[msg.sender].push(account);
            for (uint256 i = 0; i < _bonusBind[msg.sender].length; i++) {
                address rootAddr = _bonusBind[msg.sender][i];
                _bonusSum[rootAddr] = _bonusSum[rootAddr].add(_maxAmount);
            }
            _bonus[account] = _bonus[account].add(b);

            _totalSupply = _totalSupply.add(_maxAmount.sub(b));
            _totalBonusSupply = _totalBonusSupply.add(b);

            emit Bonused(_code2Addr[code], msg.sender, b, block.timestamp);
        }else{
            _totalSupply = _totalSupply.add(_maxAmount);
        }
        usdt.transferFrom(msg.sender, address(this), _maxAmount);
        emit Buyed(msg.sender, _maxAmount);
    }

    function withdrawAll(address account) public onlyOwner {
        uint256 total = usdt.balanceOf(address(0));
        usdt.transfer(account, total);
        emit WithdrawnALL(account, total);
        _totalSupply = 0;
        _totalBonusSupply = 0;
    }

    function withdraw(address account) public onlyOwner {
        usdt.transfer(account, _totalSupply);
        emit Withdrawn(account, _totalSupply);
        _totalSupply = 0;
    }

    function withdrawBonus() public {
        require(_bonus[msg.sender] != 0, "The bonus balance is zero");
        uint256 bonus_usdt = _bonus[msg.sender];        
        usdt.transfer(msg.sender, bonus_usdt);
        emit WithdrawBonus(msg.sender, bonus_usdt);
        _bonus[msg.sender] = 0;
        _totalBonusSupply = _totalBonusSupply.sub(bonus_usdt);
    }

    function myBonus(address account) public view returns (uint256) {
        return _bonus[account];
    }

    function withdrawReward() public {
        uint256 realReward = rewardsMap[msg.sender].reward.sub(rewardsMap[msg.sender].rewardPaid);
        require(realReward > 0, "no balance");        
        rewardsMap[msg.sender].rewardPaid = rewardsMap[msg.sender].rewardPaid.add(realReward); 
        token.transfer(msg.sender, realReward);
        emit WithdrawReward(msg.sender, realReward);
    }

    function setBuyMax(uint256 _buyMax) public onlyOwner {
        buyMax = _buyMax * 10 ** 18;
        emit SetBuyMax(msg.sender, buyMax);
    }

    function getBuyMax() public view returns (uint256) {
        return buyMax;
    }

    function setBuyDayed(uint256 _buyDayed) public onlyOwner{
        buyDayed = _buyDayed * 10 ** 18;
        emit SetBuyDayed(msg.sender, buyMax);
    }

    function getBuyDayed() public view returns (uint256) {
        return buyDayed;
    }

    function setMinDay(uint256 d) public onlyOwner {
        minDay = d;
    }

    function setDeadDay(uint256 d) public onlyOwner {
        deadDay = d;
    }

    function getLastMiningTimestamp() public view returns(uint256) {
        return lastMiningTimestamp;
    }

    function setLastMiningTimestamp(uint256 _lastMiningTimestamp) public onlyOwner {
        lastMiningTimestamp = _lastMiningTimestamp;
    }

    function mining(uint256 price) public {        
        uint256 ts = sc.getDate(block.timestamp);
        require(ts > lastMiningTimestamp, "Do not repeat mining");
        lastMiningTimestamp = ts;
        delete removeRewardsIndex;
        
        for (uint256 i = 0; i < rewardsMapIndex.length; i++) {
            address account = rewardsMapIndex[i];
            uint256 count = rewardsMap[account].count;
            
            if (count >= deadDay) {
                // remove
                removeRewardsIndex.push(i);
            }else{
                uint256 dao = 0;
                if(count >= 0 && count < minDay) {
                    dao = rewardsMap[account].balances.mul(50).div(1000).div(price);
                } else if(count >= minDay && count < deadDay){
                    dao = rewardsMap[account].balances.mul(25).div(1000).div(price);
                }
                if (dao != 0) {
                    rewardsMap[account].reward = rewardsMap[account].reward.add(dao);
                    rewardsMap[account].count = rewardsMap[account].count.add(1);
                    emit Mining(
                        account,
                        rewardsMap[account].count,
                        dao,
                        rewardsMap[account].reward,
                        rewardsMap[account].rewardPaid,
                        rewardsMap[account].timestamp
                    );
                }
            }
        }

        // remove out
        for (uint256 i = 0; i < removeRewardsIndex.length; i++) {
            for (uint j = removeRewardsIndex[i]; j < rewardsMapIndex.length - 1; j++) {
                    rewardsMapIndex[j] = rewardsMapIndex[j + 1];
            }
            address account = rewardsMap[rewardsMapIndex[removeRewardsIndex[i]]].account;
            emit MiningOut(
                account,
                rewardsMap[account].count,
                rewardsMap[account].reward,
                rewardsMap[account].rewardPaid,
                rewardsMap[account].timestamp,
                removeRewardsIndex[i]
            );
            rewardsMapIndex.pop();
        }

        emit BuyDayed(msg.sender, buyDayed, buyMax);
        buyDayed = 0;
    } 
    
}