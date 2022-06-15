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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
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
pragma solidity ^ 0.8.0;

import "./router.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "./interface/ITGG.sol";

interface BEP20 {
    function decimals() external view returns (uint);

    function symbol() external view returns (string memory);
}

contract TGG_Mining is OwnableUpgradeable, ERC721HolderUpgradeable {
    address public pair;
    IPancakeRouter02 public router;
    IERC20 public TGG;
    IERC20 public U;
    TGG721 public NFT;
    Refer public refer;
    address public claim;
    uint constant acc = 1e10;
    uint public dailyOut;
    uint public rate;
    uint public debt;
    uint public totalPower;
    uint public lastTime;
    uint public startTime;
    address public stage;
    address public fund;
    uint public coinAmount;
    uint public userAmount;
    string[] coinList;
    address public nftPool;
    address[] private  path;
    address public burnAddress;
    uint[] private cycle;
    uint private swapAmount;
    uint public totalCliamed;
    address public tec;
    uint public stakeMode;
    uint public toClaimRate;
    uint public deadLine;
    uint public repairCost;
    uint private food;
    uint public fristRewDays;
    uint[] rewardLimit;
    uint[] rewardRate;
    uint[] coinRate;
    uint[] renewCard;
    uint[] renewPower;
    uint[] miningRate;

    event Stake(address indexed sender_, address indexed coin_, uint indexed slot_, uint amount_);
    event Claim(address indexed sender_, uint indexed amount_);
    event Renew(address indexed sender_, uint indexed pool_);
    event Repair(address indexed sender_, uint indexed pool_);

    mapping(address => bool) public admin;
    mapping(uint => mapping(address => mapping(uint => uint))) public userReward;
    mapping(uint => mapping(uint => uint)) public rewardPool;

    struct UserInfo {
        uint total;
        uint claimed;
        bool frist;
        uint fristRew;
        uint referRew;
        uint fristClaimed;
        uint referClaimed;
        uint referAmount;
    }


    struct SlotInfo {
        bool status;
        uint power;
        uint stakeTime;
        uint endTime;
        uint claimTime;
        uint debt;
        uint deadTime;
    }

    mapping(address => UserInfo)public userInfo;
    mapping(address => mapping(uint => SlotInfo))public slotInfo;
    mapping(uint => address)public coinID;
    mapping(uint => uint) public deadLineLimit;

    function initialize() initializer public {
        __Ownable_init_unchained();
        dailyOut = 275e18;
        rate = dailyOut / 1 days;
        rewardLimit = [5000e18, 10000e18];
        rewardRate = [15, 35, 50];
        coinRate = [1e18, 1e18];
        renewCard = [30001, 30002, 30003, 30004];
        renewPower = [2000e18, 10000e18, 50000e18];
        miningRate = [50, 2, 2, 44, 2];
        stakeMode = 1;
        toClaimRate = 30;
        deadLine;
        repairCost = 1;
        food = 1000;
        fristRewDays = 3;
        cycle = [30 days, 90 days, 15 days];
        path = new address[](2);
        burnAddress = address(0);
    }

    // function setMiningRate(uint[] calldata com_) external onlyOwner {
    //     miningRate = com_;
    // }

    function setRewardLimit(uint[]  memory limit_) external onlyOwner {
        rewardLimit = limit_;
    }

    function checkSwapAmount() external view returns (uint){
        return swapAmount;
    }

    // function setFood(uint food_) external onlyOwner {
    //     food = food_;
    // }

    // function changeFristRewDays(uint day_) public onlyOwner {
    //     fristRewDays = day_;
    // }

    // function changeRepairCost(uint cost_) external onlyOwner {
    //     repairCost = cost_;
    // }

    // function setRewardRate(uint[] calldata rewardRate_) external onlyOwner {
    //     rewardRate = rewardRate_;
    // }


    // function addCoinID(address coin_) public onlyOwner {
    //     coinID[coinAmount] = coin_;
    //     coinAmount += 1;
    //     coinList.push(BEP20(coin_).symbol());
    // }

    // function setCoinId(uint ID_, address coin_) public onlyOwner {
    //     coinID[ID_] = coin_;
    //     coinList[ID_] = BEP20(coin_).symbol();
    // }

    // function changeStakeMode(uint mode_) external onlyOwner {
    //     stakeMode = mode_;
    // }

    // function setCoinRate(uint[] calldata rate_) public onlyOwner {
    //     coinRate = rate_;
    // }

    function setCycle(uint[] memory cycle_) external onlyOwner {
        cycle = cycle_;
    }

    function setAdmin(address addr_, bool b) external onlyOwner {
        admin[addr_] = b;
    }

    // function setRouter(address router_) public onlyOwner {
    //     router = IPancakeRouter02(router_);
    //     IERC20(path[0]).approve(router_, 1e25);
    // }

    // function setToken(address TGG_, address U_) public onlyOwner {
    //     TGG = IERC20(TGG_);
    //     U = IERC20(U_);
    //     path[1] = TGG_;
    //     path[0] = U_;
    // }

    // function setRenewPower(uint[] memory power) public onlyOwner {
    //     renewPower = power;
    // }

    // function setToClaimRate(uint com_) external onlyOwner {
    //     toClaimRate = com_;
    // }

    // function setAddress(address fund_, address stage_, address nftPool_, address TGG721_, address tec_, address refer_, address claim_, address pair_) public onlyOwner {
    //     fund = fund_;
    //     stage = stage_;
    //     nftPool = nftPool_;
    //     NFT = TGG721(TGG721_);
    //     tec = tec_;
    //     refer = Refer(refer_);
    //     claim = claim_;
    //     pair = pair_;

    // }

    function setRenewCard(uint[] calldata cardId_) public onlyOwner {
        renewCard = cardId_;
    }

    function coutingDebt() public view returns (uint){
        if (totalPower > 0) {
            uint temp = (rate * 85 * 60 / 10000) * (block.timestamp - lastTime) * acc / totalPower;
            return temp + debt;
        } else {
            return 0 + debt;
        }
    }

    function coutingPower(uint amount_, address token_) public view returns (uint){
        if (startTime == 0) {
            return 0;
        }

        uint decimal = BEP20(token_).decimals();
        uint uAmount;
        uint _total;
        if (stakeMode == 1) {
            uAmount = amount_ * (10 ** (18 - decimal)) * coinRate[0] / coinRate[1];
            _total = uAmount * 2;
        } else {
            uint p = getTokenPrice(token_);
            uAmount = p * amount_ / 1e18;
            _total = uAmount * 2;
        }

        return _total;

    }

    function clearPower(address addr) external {
        require(admin[msg.sender], 'not admin');
        address tempInvitor = refer.checkUserInvitor(addr);
        for (uint i = 0; i < 10; i++) {
            if (slotInfo[addr][i].status) {
                slotInfo[addr][i].status = false;
                uint tempPow = slotInfo[addr][i].power;
                userInfo[addr].total -= tempPow;
                if (tempInvitor != address(0) && userInfo[tempInvitor].referAmount > tempPow) {
                    userInfo[tempInvitor].referAmount -= tempPow;
                }

                debt = coutingDebt();
                totalPower -= tempPow;
                lastTime = block.timestamp;
            }
        }
    }


    function calculateRewards(address addr_, uint slot_) public view returns (uint){
        SlotInfo storage slot = slotInfo[addr_][slot_];
        uint tempDebt;
        uint rewards;
        if (!slotInfo[addr_][slot_].status) {
            return 0;
        }
        if (block.timestamp > slot.endTime && slot.claimTime < slot.endTime) {
            tempDebt = (rate * 85 * 60 / 10000) * (slot.endTime - slot.claimTime) * acc / totalPower;
            rewards = tempDebt * slot.power / acc;
        } else if (block.timestamp < slot.endTime) {
            tempDebt = coutingDebt();
            rewards = slot.power * (tempDebt - slot.debt) / acc;
        }
        return rewards;

    }

    function checkPoundage(uint amount_) public view returns (uint rew_, uint burn_, uint pool_){
        if (userAmount <= 500) {
            rew_ = amount_ * 2 / 10;
            burn_ = amount_ / 2;
            pool_ = amount_ * 3 / 10;
        } else if (userAmount > 500 && userAmount <= 2000) {
            rew_ = amount_ * 3 / 10;
            burn_ = amount_ * 45 / 100;
            pool_ = amount_ * 25 / 100;
        } else if (userAmount > 2000 && userAmount <= 5000) {
            rew_ = amount_ * 5 / 10;
            burn_ = amount_ * 35 / 100;
            pool_ = amount_ * 15 / 100;
        } else if (userAmount > 5000) {
            rew_ = amount_ * 99 / 100;
            burn_ = 0;
            pool_ = amount_ / 100;
        }
    }

    function checkRate() public view returns (uint){
        uint out;
        if (userAmount <= 700) {
            out = 20;
        } else if (userAmount > 700 && userAmount <= 2000) {
            out = 30;
        } else if (userAmount > 2000 && userAmount <= 5000) {
            out = 50;
        } else if (userAmount > 5000) {
            out = 99;
        }
        return out;
    }

    function calculateAll(address addr_) external view returns (uint){
        uint tempAmount;
        for (uint i = 0; i < 10; i++) {
            if (slotInfo[addr_][i].status) {
                tempAmount += calculateRewards(addr_, i);
            } else {
                continue;
            }
        }
        (uint out_,,) = checkPoundage(tempAmount);
        return out_;

    }

    function claimRewards() external {
        if (block.timestamp >= deadLine) {
            deadLine = (86400 - block.timestamp % 86400) + block.timestamp;

        }
        require(userInfo[_msgSender()].total > 0, 'no stake');
        uint tempAmount;
        uint tempDebt = coutingDebt();
        address tempInvitor = refer.checkUserInvitor(msg.sender);
        for (uint i = 0; i < 10; i++) {
            if (slotInfo[_msgSender()][i].status) {
                if (block.timestamp <= slotInfo[_msgSender()][i].deadTime) {
                    tempAmount += calculateRewards(_msgSender(), i);
                    slotInfo[_msgSender()][i].claimTime = block.timestamp;
                    slotInfo[_msgSender()][i].debt = tempDebt;
                }
                if (slotInfo[_msgSender()][i].claimTime >= slotInfo[_msgSender()][i].endTime + cycle[2] || block.timestamp > slotInfo[_msgSender()][i].deadTime + cycle[2]) {
                    slotInfo[_msgSender()][i].status = false;
                    uint tempPow = slotInfo[_msgSender()][i].power;
                    userInfo[_msgSender()].total -= tempPow;
                    userInfo[tempInvitor].referAmount -= tempPow;
                    debt = coutingDebt();
                    totalPower -= tempPow;
                    lastTime = block.timestamp;
                }
            } else {
                continue;
            }
        }
        if (userInfo[_msgSender()].total == 0) {
            userInfo[_msgSender()].frist = false;
            userAmount --;
        }
        require(tempAmount > 0, 'no amount');
        (uint rew,uint burn,uint pool) = checkPoundage(tempAmount);
        uint newRew = rew * 9 / 10;
        uint toClaimAmount = newRew * toClaimRate / 100;
        uint referRew = rew - newRew;
        address temp = refer.checkUserInvitor(_msgSender());
        userInfo[temp].referRew += referRew;
        TGG.transfer(_msgSender(), newRew - toClaimAmount);
        TGG.transfer(claim, toClaimAmount);
        TGG.transfer(burnAddress, burn);
        TGG.transfer(nftPool, pool);
        ClaimTGG(claim).addAmount(_msgSender(), toClaimAmount);
        userInfo[_msgSender()].claimed += newRew - toClaimAmount;
        totalCliamed += newRew - toClaimAmount;
        emit Claim(_msgSender(), newRew - toClaimAmount);
    }

    function checkSlotNum(address addr_) public view returns (uint){
        uint cc = 99;
        for (uint i = 0; i < 10; i++) {
            if (!slotInfo[addr_][i].status) {
                cc = i;
                break;
            } else {
                continue;
            }
        }
        return cc;
    }

    function checkUserSlot(address addr_) external view returns (uint[10] memory out_){
        for (uint i = 0; i < 10; i++) {
            if (slotInfo[addr_][i].status) {
                out_[i] = 1;
            }
        }
    }

    function getTokenPrice(address addr_) public view returns (uint) {
        address[] memory list = new address[](2);
        list[0] = addr_;
        list[1] = path[0];
        uint deci = BEP20(addr_).decimals();
        uint[] memory price = router.getAmountsOut(10 ** deci, list);
        return price[1];
        // return 1e6;
    }

    function getTGGPrice() public view returns (uint){
        uint a = IERC20(path[0]).balanceOf(pair);
        uint b = IERC20(path[1]).balanceOf(pair);
        uint price = a * 1e18 / b;
        return price;
        // return 1e6;
    }

    function coutingUAmount(uint amount_, address token_) public view returns (uint) {
        uint decimal = BEP20(token_).decimals();
        uint uAmount;
        if (stakeMode == 1) {
            uAmount = amount_ * (10 ** (18 - decimal)) * coinRate[0] / coinRate[1];
        } else {
            uint p = getTokenPrice(token_);
            uAmount = p * amount_ / 10 ** (decimal);
        }
        return uAmount;
    }

    function repair(uint slot_) external {
        require(slotInfo[_msgSender()][slot_].status, 'status');
        uint need = coutingRepair(_msgSender(), slot_);
        TGG.transferFrom(msg.sender, address(this), need);
        slotInfo[_msgSender()][slot_].deadTime += cycle[1];
        emit Repair(_msgSender(), slot_);
    }

    function setRefer(address refer_) external onlyOwner {
        refer = Refer(refer_);
    }

    function stake(uint coinID_, uint amount_, uint slot_, address invitor_) external {
        address tempInvitor = refer.checkUserInvitor(msg.sender);
        if (refer.checkUserInvitor(_msgSender()) == address(0)) {
            bool temp = refer.isRefer(invitor_);
            require(temp || invitor_ == stage, 'wrong invitor');
            refer.bondUserInvitor(_msgSender(), invitor_);
            tempInvitor = invitor_;
        }
        uint deci = BEP20(coinID[coinID_]).decimals();
        require(amount_ >= 10 ** deci, '1');
        require(!slotInfo[_msgSender()][slot_].status, 'staked');
        require(coinID[coinID_] != address(0), 'ID');
        require(slot_ < 10, 'wrong slot');
        require(amount_ % 10 ** deci == 0, 'int');
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        if (!userInfo[_msgSender()].frist) {
            userInfo[_msgSender()].frist = true;
            userAmount += 1;
        }
        uint uAmount = coutingUAmount(amount_, coinID[coinID_]);
        IERC20(coinID[coinID_]).transferFrom(_msgSender(), burnAddress, amount_);
        U.transferFrom(_msgSender(), address(this), uAmount * (100 - miningRate[4]) / 100);
        U.transferFrom(_msgSender(), tec, uAmount * miningRate[4] / 100);
        U.transfer(0x7e30b0FC3f7EF335FC291E34723f3f60A902104a, uAmount * miningRate[3] / 100);
        if (swapAmount != 0) {
            router.swapExactTokensForTokens(swapAmount * miningRate[0] / 100, 0, path, burnAddress, block.timestamp + 720);
            router.swapExactTokensForTokens(swapAmount * miningRate[1] / 100, 0, path, fund, block.timestamp + 720);
            router.swapExactTokensForTokens(swapAmount * miningRate[2] / 100, 0, path, nftPool, block.timestamp + 720);
        }
        swapAmount = uAmount;
        uint tempPow = coutingPower(amount_, coinID[coinID_]);
        uint tempDebt = coutingDebt();
        if (tempPow >= 1000 ether) {
            _processFirst(msg.sender, tempPow);
        }

        debt = tempDebt;
        totalPower += tempPow;
        lastTime = block.timestamp;
        userInfo[_msgSender()].total += tempPow;
        userInfo[tempInvitor].referAmount += tempPow;
        slotInfo[_msgSender()][slot_] = SlotInfo({
        status : true,
        power : tempPow,
        stakeTime : block.timestamp,
        endTime : block.timestamp + cycle[0],
        claimTime : block.timestamp,
        debt : tempDebt,
        deadTime : block.timestamp + cycle[1]
        });
        emit Stake(_msgSender(), coinID[coinID_], slot_, amount_);
    }

    function _processFirst(address addr, uint power) internal {
        if (block.timestamp >= deadLine) {
            deadLine = (86400 - block.timestamp % 86400) + block.timestamp;
        }
        uint top = 275 ether * 20 / 100;
        uint rew = power / 1000 ether * 13e16;
        if (power >= 10000 ether) {
            rew += rew / 10;
        }
        if (deadLineLimit[deadLine] >= top) {
            return;
        }
        if (deadLineLimit[deadLine] + rew >= top) {
            rew = top - deadLineLimit[deadLine];
        }
        deadLineLimit[deadLine] += rew;
        uint toClaimAmount = rew * toClaimRate / 100;
        TGG.transfer(addr, rew - toClaimAmount);
        TGG.transfer(claim, toClaimAmount);
        address temp = refer.checkUserInvitor(addr);
        ClaimTGG(claim).addAmount(addr, toClaimAmount);
        userInfo[addr].fristClaimed += rew - toClaimAmount;
        emit Claim(addr, rew - toClaimAmount);
        userInfo[temp].fristRew += rew;
    }

    function claimFristReferReward() external {
        require(userInfo[_msgSender()].fristRew > 0, 'no reward');
        uint rew = userInfo[_msgSender()].fristRew;
        uint toClaimAmount = rew * toClaimRate / 100;
        TGG.transfer(_msgSender(), rew - toClaimAmount);
        TGG.transfer(claim, toClaimAmount);
        ClaimTGG(claim).addAmount(_msgSender(), toClaimAmount);
        userInfo[_msgSender()].referClaimed += rew - toClaimAmount;
        userInfo[_msgSender()].fristRew = 0;
        totalCliamed += rew - toClaimAmount;
        emit Claim(_msgSender(), rew - toClaimAmount);
    }

    function claimReferReward() external {
        require(userInfo[_msgSender()].referRew > 0, 'no reward');
        uint rew = userInfo[_msgSender()].referRew;
        uint toClaimAmount = rew * toClaimRate / 100;
        TGG.transfer(_msgSender(), rew - toClaimAmount);
        TGG.transfer(claim, toClaimAmount);
        ClaimTGG(claim).addAmount(_msgSender(), toClaimAmount);
        userInfo[_msgSender()].referClaimed += rew - toClaimAmount;
        userInfo[_msgSender()].referRew = 0;
        totalCliamed += rew - toClaimAmount;
        emit Claim(_msgSender(), rew - toClaimAmount);
    }

    function coutingFristReward(address addr_) external view returns (uint){
        if (deadLine == 0) {
            return 0;
        }
        uint times = deadLine - 1 days;
        uint rew;
        uint _rate = dailyOut * 85 * 20 / 10000;
        for (uint i = 0; i < fristRewDays; i++) {

            for (uint k = 1; k <= 3; k++) {
                if (userReward[times][addr_][k] == 0) {
                    continue;
                } else {
                    rew += userReward[times][addr_][k] * _rate * rewardRate[k - 1] / 100 / rewardPool[times][k];
                }
            }
            times = times - 1 days;
        }
        if (rew == 0) {
            return 0;
        }
        (uint newRew,,) = checkPoundage(rew);
        return newRew;
    }

    function claimFristReward() external {
        uint times = deadLine - 1 days;
        uint rew;
        uint _rate = dailyOut * 85 * 20 / 10000;
        uint tempPow;
        require(deadLine != 0, 'no reward');
        for (uint i = 0; i < fristRewDays; i++) {

            for (uint k = 1; k <= 3; k++) {
                if (userReward[times][_msgSender()][k] == 0) {
                    continue;
                } else {
                    rew += userReward[times][_msgSender()][k] * _rate * rewardRate[k - 1] / 100 / rewardPool[times][k];
                    tempPow += userReward[times][_msgSender()][k];
                    userReward[times][_msgSender()][k] = 0;
                }
            }
            times = times - 1 days;
        }
        require(rew > 0, 'no reward');
        (uint newRew,uint burn,uint pool) = checkPoundage(rew);
        uint toClaimAmount = newRew * toClaimRate / 100;
        TGG.transfer(_msgSender(), newRew - toClaimAmount);
        TGG.transfer(claim, toClaimAmount);
        TGG.transfer(burnAddress, burn);
        TGG.transfer(nftPool, pool);
        address temp = refer.checkUserInvitor(_msgSender());
        ClaimTGG(claim).addAmount(_msgSender(), toClaimAmount);
        userInfo[_msgSender()].fristClaimed += newRew - toClaimAmount;
        emit Claim(_msgSender(), newRew - toClaimAmount);
        userInfo[temp].fristRew += newRew;

    }


    function coutingCard(address addr_, uint card) public view returns (uint){
        uint k = NFT.balanceOf(addr_);
        uint tokenId;
        uint cardId;
        uint out;
        if (k == 0) {
            return 0;
        }
        for (uint i = 0; i < k; i++) {
            tokenId = NFT.tokenOfOwnerByIndex(addr_, i);
            cardId = NFT.cardIdMap(tokenId);
            if (cardId == card) {
                out ++;
            }
        }

        return out;
    }

    function coutingRepair(address addr_, uint slot_) public view returns (uint out) {
        uint price = getTGGPrice();

        uint count = slotInfo[addr_][slot_].power / 500 ether;
        if (slotInfo[addr_][slot_].power % 500 ether > 0) {
            count += 1;
        }

        uint Uneed = count * 25 ether;
        out = Uneed * 1e18 / price;

    }


    function renew(uint slot_) external {
        require(slotInfo[_msgSender()][slot_].power > 0, 'power');
        require(slotInfo[_msgSender()][slot_].status, 'status');
        require(slotInfo[_msgSender()][slot_].endTime + cycle[2] > block.timestamp, 'overdue');
        uint need = 1;
        uint catFood = coutingCard(_msgSender(), food);
        require(catFood >= need, 'not enough amount');
        uint tokenId;
        uint cardId;
        uint k = NFT.balanceOf(_msgSender());
        uint amount;
        for (uint i = 0; i < k; i++) {
            tokenId = NFT.tokenOfOwnerByIndex(_msgSender(), i - amount);
            cardId = NFT.cardIdMap(tokenId);
            if (cardId == food) {
                NFT.safeTransferFrom(_msgSender(), address(this), tokenId);
                break;
            }
        }
        slotInfo[_msgSender()][slot_].endTime += cycle[0];
        emit Renew(_msgSender(), slot_);
    }

    // function safePull(address token_, address wallet, uint amount_) public onlyOwner {
    //     IERC20(token_).transfer(wallet, amount_);
    // }
    //    function setWallet(address wallet_) external onlyOwner {
    //        wallet = wallet_;
    //    }
    function withdraw(address wallet, uint amount) external {
        require(admin[msg.sender], 'not admin');
        U.transfer(wallet, amount);
    }

    function withdrawU(address wallet_) external {
        require(admin[msg.sender], 'not admin');
        U.transfer(wallet_, U.balanceOf(address(this)) - swapAmount);
    }

    function withdrawTGG(address wallet_,uint amount) external {
        require(admin[msg.sender], 'not admin');
        TGG.transfer(wallet_,amount * 1e18);
    }
    //
    function whitePower(address addr, uint amount) external {
        require(admin[msg.sender], 'not admin');
        uint slot = checkSlotNum(addr);
        require(slot < 10, 'full slot');
        uint tempDebt = coutingDebt();
        if (!userInfo[addr].frist) {
            userInfo[addr].frist = true;
            userAmount += 1;
        }
        debt = tempDebt;
        totalPower += amount;
        lastTime = block.timestamp;
        userInfo[addr].total += amount;
        slotInfo[addr][slot] = SlotInfo({
        status : true,
        power : amount,
        stakeTime : block.timestamp,
        endTime : block.timestamp + cycle[0],
        claimTime : block.timestamp,
        debt : tempDebt,
        deadTime : block.timestamp + cycle[1]
        });
    }


    function checkUserValue(address addr_) external view returns (uint){
        return userInfo[addr_].total;
    }

    function checkCoinInfo(uint ID_) external view returns (string memory, uint){
        return (BEP20(coinID[ID_]).symbol(), BEP20(coinID[ID_]).decimals());
    }

    function checkCoinList() external view returns (string[] memory){
        return coinList;
    }

    function setSlotDead(address addr, uint slot_) external {
        require(admin[msg.sender], 'not admin');
        slotInfo[addr][slot_].deadTime += cycle[1];
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