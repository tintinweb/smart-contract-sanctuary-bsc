/**
 *Submitted for verification at BscScan.com on 2022-03-24
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
library AddressUpgradeable {   
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
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

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
   
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
abstract contract Initializable {   
    bool private _initialized;    
    bool private _initializing;
    modifier initializer() {        
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
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }
    function __Context_init_unchained() internal onlyInitializing {
    }
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
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

contract Donate5 is Initializable,OwnableUpgradeable {
    using SafeMath for uint256;
    using AddressUpgradeable for address;

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

    function initialize()public initializer{
		__Context_init_unchained();
		__Ownable_init_unchained();        

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

    function getRewardMap(address account) public view returns(UserRewards memory) {
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

    function DaysDiff(uint256 t1, uint256 t2) public pure returns(uint256) {
        uint256 daysDiff = 0;
        if(t1 > t2){
            daysDiff = t1.sub(t2).div(86400);
        }else{
            daysDiff = t2.sub(t1).div(86400);
        }
        return daysDiff;
    }

    // version 5.0
    function buy(uint256 purchaseIndex, address referer) public {
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
        if (referer != address(0) && _addr2Code[referer] != 0) {
            // add bonus
            uint256 b = _maxAmount.mul(100).div(1000);
            address account = referer;
            require(account != address(0), "need real address");
            _bonusBind[msg.sender] = _bonusBind[account];
            _bonusBind[msg.sender].push(account);
            for (uint256 i = 0; i < _bonusBind[msg.sender].length; i++) {
                address rootAddr = _bonusBind[msg.sender][i];
                _bonusSum[rootAddr] = _bonusSum[rootAddr].add(_maxAmount);
            }
            _bonus[account] = _bonus[account].add(b);

            _totalSupply = _totalSupply.add(_maxAmount.sub(b));
            _totalBonusSupply = _totalBonusSupply.add(b);

            emit Bonused(account, msg.sender, b, block.timestamp);
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