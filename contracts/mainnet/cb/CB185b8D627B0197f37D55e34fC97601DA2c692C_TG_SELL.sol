// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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

// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interface/ITGG.sol";
import "./router.sol";

interface Decimal {
    function decimals() external view returns (uint);
}

contract TG_SELL is OwnableUpgradeable {
    struct UserInfo {
        uint groupAmount;
        address invitor;
        bool isInvitor;
        uint refer;
        uint group;
        uint levelSet;
        uint referReward;
        uint groupReward;
        uint TGClaimed;
        uint UClaimed;
        uint totalBuy;
        uint referClaimed;
        uint groupClaimed;
        address[] referList;
    }

    mapping(address => UserInfo) public userInfo;
    uint public referLimit;
    uint[] rewardLimit;
    uint[] rewardRate;
    uint public maxReward;
    IERC20 public TG;
    IERC20 public USDT;
    uint public price;
    uint public totalUClaimed;
    uint public totalTGClaimed;
    uint public totalBuy;
    uint public buyLimit;
    address public u;
    address public wbnb;
    IPancakeRouter02 public router;
    Mining public main;

    struct Token {
        bool status;
        bool isBNB;
        bool reward;
    }

    mapping(address => Token)public tokenInfo;
    mapping(address => uint) public level;
    mapping(address => mapping(uint => uint)) public referAmount;
    mapping(address => uint) public directAmount;
    uint public rate1;
    uint public rate2;
    event Buy(address indexed player, uint indexed amount);
    event Claim(address indexed player, uint indexed amount);

    function initialize() external initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        referLimit = 100 ether;
        rewardLimit = [1000 ether, 5000 ether, 30000 ether, 100000 ether, 300000 ether];
        rewardRate = [0, 6, 9, 13, 19, 28, 31, 33];
        maxReward = 33;
        price = 1 ether;
        u = 0x55d398326f99059fF775485246999027B3197955;
        wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function setMain(address addr) external onlyOwner {
        main = Mining(addr);
    }

    function setToken(address TG_, address USDT_) external onlyOwner {
        TG = IERC20(TG_);
        USDT = IERC20(USDT_);
    }

    function checkUserToClaim(address addr) external view returns (uint, uint){
        uint total = userInfo[addr].referReward + userInfo[addr].groupReward;
        uint _tg = total * 3 / 10;
        uint _u = total - _tg;
        return (_tg, _u);
    }

    function checkReferList(address addr) external view returns (address[] memory){
        return userInfo[addr].referList;
    }

    function checkRewardLimit() external view returns (uint[] memory){
        return rewardLimit;
    }

    function setRates(uint rate1_,uint rate2_) external onlyOwner{
        rate1 = rate1_;
        rate2 = rate2_;
    }

    function checkRewardRate() external view returns (uint[] memory){
        return rewardRate;
    }

    function setMaxReward(uint max_) external onlyOwner {
        maxReward = max_;
    }

    function getTGGPrice() public view returns (uint){
        return main.getTGGPrice();
    }

    function getTokenPrice(address addr) public view returns (uint){
        uint deci;
        uint[] memory _price;
        address[] memory list;
        if (tokenInfo[addr].isBNB) {
            list = new address[](3);
            list[0] = addr;
            list[1] = wbnb;
            list[2] = u;
            deci = Decimal(addr).decimals();
            _price = router.getAmountsOut(10 ** deci, list);
            return _price[2];
        }
        list = new address[](2);
        list[0] = addr;
        list[1] = u;
        deci = Decimal(addr).decimals();
        _price = router.getAmountsOut(10 ** deci, list);
        return _price[1];
    }

    function getLevel(address addr) public view returns (uint){
        if (userInfo[addr].levelSet != 0) {
            return userInfo[addr].levelSet;
        }
        //        for (uint i = 0; i < rewardLimit.length; i++) {
        //            if (userInfo[addr].groupAmount < rewardLimit[i]) {
        //                return i;
        //            }
        //        }
        return level[addr];
    }

    function setBuyLimit(uint limit_) external onlyOwner {
        buyLimit = limit_;
    }

    function coutingIn(address token, uint amountOut) public view returns (uint){
        uint _price = getTokenPrice(token);
        uint decimal = Decimal(token).decimals();
        uint out = (amountOut * (10 ** decimal)) / _price;
        return out;
    }

    function init() public onlyOwner {
        u = 0x55d398326f99059fF775485246999027B3197955;
        wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        main = Mining(0x6a9e7156C4F481156bcA270c2c06908d5e2C23E4);
    }

    function setTokenInfo(address addr, bool status, bool reward, bool ISBNB_) external onlyOwner {
        tokenInfo[addr] = Token({
        status : status,
        reward : reward,
        isBNB : ISBNB_
        });
    }

    function _processRefer(address addr) internal {
        address temp = userInfo[addr].invitor;
        uint _level = 1;
        if (directAmount[temp] >= 1000 ether && level[temp] == 0) {
            level[temp] = _level;
            temp = userInfo[temp].invitor;
            while (_level <= 4) {
                referAmount[temp][_level]++;
                if (referAmount[temp][_level] >= 3 && level[temp] <= _level) {
                    level[temp] = _level + 1;
                } else {
                    break;
                }
                temp = userInfo[temp].invitor;
                _level ++;
            }

        }
    }

    function buy(uint amount, address invitor_) external {
        if (buyLimit == 0) {
            buyLimit = 10;
        }
        if(rate1 == 0){
            rate1 = 5;
            rate2 = 3;
        }

        if (userInfo[msg.sender].invitor == address(0)) {
            require(amount % (buyLimit * 1e18) == 0, 'wrong amount');
            require(userInfo[invitor_].isInvitor || invitor_ == address(this), 'wrong invitor');
            userInfo[msg.sender].invitor = invitor_;
            userInfo[invitor_].refer += 1;
            userInfo[invitor_].referList.push(msg.sender);
            address temp = invitor_;
            for (uint i = 0; i < 10; i ++) {
                if (temp == address(0) || temp == address(this)) {
                    break;
                }
                userInfo[temp].group ++;

                temp = userInfo[temp].invitor;
            }
            if (!userInfo[msg.sender].isInvitor) {
                userInfo[msg.sender].isInvitor = true;
            }
        }
        directAmount[userInfo[msg.sender].invitor] += amount;
        _processRefer(msg.sender);

        USDT.transferFrom(msg.sender, address(this), amount * (100 - 18) / 100);
        USDT.transferFrom(msg.sender, 0x371bd01516f4289Fe98c992Dc4FE805Cd5370f1F, amount * rate1 / 100);
        USDT.transferFrom(msg.sender, 0x03A230cBcB61adF12cbE302004C4F171B8B0e564, amount * rate2 / 100);
        USDT.transferFrom(msg.sender, 0x1BCCd639939fE5ed927D5D98EAF20948Bc88b32B, amount * 10 / 100);
        address refer = userInfo[msg.sender].invitor;
        uint left = maxReward;
        uint lastLevel = getLevel(msg.sender);
        for (uint i = 0; i < 10; i ++) {
            if (refer == address(0) || refer == address(this)) {
                break;
            }
            if (i == 0) {
                userInfo[refer].referReward += amount / 10;
            }
            if (i == 1) {
                userInfo[refer].referReward += amount / 5;
            }
            userInfo[refer].groupAmount += amount;

            uint _level = getLevel(refer);
            require(_level <= 7, 'out of level');
            if (_level > lastLevel && left > 0) {
                require(rewardRate[_level] > rewardRate[lastLevel], 'out of rewardRate');
                if (left >= (rewardRate[_level] - rewardRate[lastLevel])) {

                    userInfo[refer].groupReward += amount * (rewardRate[_level] - rewardRate[lastLevel]) / 100;
                    left -= (rewardRate[_level] - rewardRate[lastLevel]);
                    lastLevel = _level;
                } else {
                    userInfo[refer].groupReward += amount * left / 100;
                    left = 0;
                    lastLevel = _level;
                }
            }
            refer = userInfo[refer].invitor;
        }


        TG.transfer(msg.sender, amount);
        userInfo[msg.sender].totalBuy += amount;
        totalBuy += amount;
        emit Buy(msg.sender, amount);
    }

    function buyWithToken(address token, uint amount) external {
        require(tokenInfo[token].status, 'wrong token');
        if (buyLimit == 0) {
            buyLimit = 10;
        }
        uint outAmount = coutingIn(token, amount);
        IERC20(token).transferFrom(msg.sender, address(this), outAmount);
        TG.transfer(msg.sender, amount);
        userInfo[msg.sender].totalBuy += amount;
        totalBuy += amount;
        emit Buy(msg.sender, amount);
    }

    function setLevel(address addr, uint level_) external onlyOwner {
        userInfo[addr].levelSet = level_;
    }

    function claimReward() external {
        require(userInfo[msg.sender].referReward > 0 || userInfo[msg.sender].groupReward > 0, 'no reward');
        uint amount = userInfo[msg.sender].referReward + userInfo[msg.sender].groupReward;
        userInfo[msg.sender].referClaimed += userInfo[msg.sender].referReward;
        userInfo[msg.sender].groupClaimed += userInfo[msg.sender].groupReward;
        USDT.transfer(msg.sender, amount * 9 / 10);
        userInfo[msg.sender].UClaimed += amount * 9 / 10;
        userInfo[msg.sender].TGClaimed += amount * 1 / 10;
        totalTGClaimed += amount * 1 / 10;
        totalUClaimed += amount * 9 / 10;
        TG.transfer(msg.sender, amount * 1 / 10);
        userInfo[msg.sender].referReward = 0;
        userInfo[msg.sender].groupReward = 0;
        emit Claim(msg.sender, amount);
    }

    function safePull(address token_, address wallet, uint amount_) public onlyOwner {
        IERC20(token_).transfer(wallet, amount_);
    }


}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ClaimTGG {
    function addAmount(address addr_, uint amount_) external;
}

interface TGG721 {
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);

    function cardIdMap(uint tokenId) external view returns (uint256 cardId);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function mint(address player_, uint cardId_, bool uriInTokenId_) external returns (uint256);
}
interface Refer {
    function bondUserInvitor(address addr_, address invitor_) external;

    function checkUserInvitor(address addr_) external view returns (address);
    
    function isRefer(address addr_) external view returns (bool);
}

interface Mining {
    function checkUserValue(address addr_) external view returns (uint);

    function stage() external view returns (address);

    function U() external view returns (address);

    function NFT() external view returns (address);

    function TGG() external view returns (address);

    function fund() external view returns (address);

    function userInfo(address addr_) external view returns (uint total, uint claimed, bool frist, uint value);

    function getTGGPrice() external view returns (uint);

    function userAmount() external view returns (uint);

    function refer() external view returns (address);

    function claim() external view returns (address);

    function nftPool() external view returns (address);

    function pair() external view returns (address);

    function burnAddress() external view returns (address);
    
    function getTokenPrice(address addr_) external view returns (uint);
    
    function whitePower(address addr,uint amount) external;

}
interface Box {
    function price() external view returns (uint);

    function getPrice() external view returns (uint);

    function U() external view returns (address);

    function NFT() external view returns (address);

    function TGG() external view returns (address);
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