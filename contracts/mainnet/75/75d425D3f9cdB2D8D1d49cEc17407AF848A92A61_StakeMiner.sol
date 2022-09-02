// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/proxy/utils/Initializable.sol';

import '../libraries/TransferHelper.sol';

import './interfaces/IStakeMiner.sol';
import './interfaces/IMiningERC20.sol';
import './StakeMinerBase.sol';

contract StakeMiner is IStakeMiner, StakeMinerBase, Initializable {

    using ValueList for ValueList.List;
    using ValueList for ValueList.Value;

    mapping (address => LockedValue[]) public lockedValues;

    address public override stakeToken;
    address public override rewardToken;

    uint256 public burnRatio;

    mapping(address => uint) public override nonces;

    function initialize(address _stakeToken, address _rewardToken) external override initializer {
        stakeToken = _stakeToken;
        rewardToken = _rewardToken;
        burnRatio = 5;
        _transferOwnership(msg.sender);
    }

    function setBurnRatio(uint256 _burnRatio) external override onlyOwner {
        require(_burnRatio < 100, "StakeMiner: burnRatio > 100");
        burnRatio = _burnRatio;
    }

    function stakeRatio(address pledger) external view returns(uint, uint) {
        return (pledgesMap[pledger].currentValue(false), wholePledge.currentValue(false));
    }
    function stakeAmount(address pledger) external override view returns(uint) {
        if(pledger == address(0)) {
            return wholePledge.currentValue(true);
        } else {
            return pledgesMap[pledger].currentValue(true);
        }
    }

    function lockedAmount(address pledger) external override view returns(uint) { 
        return _lockedValue(pledger);
    }
    
    function lockedRecords(address pledger) external override view returns(LockedValue[] memory) {
        return lockedValues[pledger];
    }

    function rewardAmount(address pledger) external override view returns(uint) {
        return _caleReward(pledger);
    }

    function stake(address to, uint value, uint releaseTime) external override {
        require(value > 0, "StakeMiner: value is zero value");
        TransferHelper.safeTransferFrom(stakeToken, msg.sender, address(this), value);
        uint balance = IERC20(stakeToken).balanceOf(address(this));
        require(balance == value + wholePledge.currentValue(true), "StakeMiner: balance error");
        
        if(releaseTime > block.timestamp) {
            lockedValues[to].push(LockedValue({
                releaseTime: releaseTime,
                value : value
            }));
        }
        
        update(to, value, OPType.ADD);
    }

    function unstake(address to, uint value) external override returns(uint _pledgeValue){
        return _unstake(msg.sender, to, value);
    }

    function harvest(address to) external override returns(uint value) {
        value = _caleReward(msg.sender);
        pledgesMap[msg.sender].clear();
        IMiningERC20(rewardToken).mint(address(this), value);

        IMiningERC20(rewardToken).burn(value * burnRatio / 100);
        TransferHelper.safeTransfer(rewardToken, to, value - value * burnRatio / 100);
    }

    function _unstake(address owner, address to, uint value) private returns(uint) {
        uint _pledgeValue = pledgesMap[owner].currentValue(true);
        uint lockedValue = _lockedValue(owner);
        if(value == 0) {
            value = _pledgeValue;
        }
        require(value + lockedValue <= _pledgeValue, "StakeMiner: Unlocked stake value is insufficient");

        update(owner, value, OPType.SUB);
        TransferHelper.safeTransfer(stakeToken, to, value);

        return (value);
    }


    function _lockedValue(address pledger) private view returns(uint value) {
        LockedValue[] storage list = lockedValues[pledger];
        for(uint i; i < list.length; i++) {
            if(list[i].releaseTime > block.timestamp) {
                value += list[i].value;
            } else if(block.timestamp < list[i].releaseTime + Times.ONE_YEAR){
                value += list[i].value * (list[i].releaseTime + Times.ONE_YEAR - block.timestamp) / Times.ONE_YEAR;
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

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
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import './IMiningBase.sol';

interface IStakeMiner is IMiningBase {

    struct LockedValue {
        uint value;
        uint releaseTime;
    }

    // function UNSTAKE_PERMIT_TYPEHASH() external view returns(bytes32);
    // function DOMAIN_SEPARATOR() external view returns(bytes32);
    // function factory() external view returns (address);
    function initialize(address, address) external;
    function rewardToken() external view returns(address);
    function stakeToken() external view returns (address);

    function stakeAmount(address) external view returns(uint);
    function lockedAmount(address ) external view returns(uint);
    function rewardAmount(address) external view returns(uint);
    function nonces(address owner) external view returns (uint);

    function lockedRecords(address) external view returns(LockedValue[] memory);

    function setBurnRatio(uint256 _burnRatio) external;
    function harvest(address) external returns(uint);
    function stake(address, uint, uint) external;
    function unstake(address, uint) external returns(uint);
    // function unstakePermit(address, address, uint, bytes calldata) external returns(uint) ;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';

interface IMiningERC20 is IERC20Metadata {
    // function initialize(string memory, string memory, address, uint value) external;
    function mint(address to, uint256 value) external;
    function burn(uint256 value) external;
    function addMiner(address miner) external;
    function removeMiner(address _miner) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import './libraries/ValueList.sol';
import './MiningBase.sol';

contract StakeMinerBase is MiningBase {
    using ValueList for ValueList.List;
    using ValueList for ValueList.Value;

    enum OPType {
        ADD,
        SUB
    }
    event Update(address, uint256, OPType);

    ValueList.List internal wholePledge;
    mapping(address => ValueList.List) internal pledgesMap;

    function update(address target, uint value, OPType opType) internal {
        if(opType == OPType.ADD) {
            wholePledge.add(value);
            pledgesMap[target].add(value);
        } else {
            wholePledge.sub(value);
            pledgesMap[target].sub(value);
        }
        emit Update(target, value, opType);
    }

    function _caleReward(address pledger) internal view returns(uint value) {
        ValueList.List storage selfPledge = pledgesMap[pledger];
        
        uint256 selfIndex = selfPledge.lastIndex;
        uint256 wholeIndex = wholePledge.lastIndex;
        uint256 endIndex = Times.toUTC8Index(block.timestamp);

        if(selfIndex != 0 && selfIndex == endIndex) {
            selfIndex = selfPledge.list[selfIndex].prevIndex;
        }

        if(wholeIndex != 0 && wholeIndex == endIndex) {
            wholeIndex = wholePledge.list[wholeIndex].prevIndex;
        }

        while(true) {
            if(selfIndex == 0) {
                break;
            }

            ValueList.Value storage selfValue = selfPledge.list[selfIndex];
            while(selfIndex < wholeIndex) {
                if(selfValue.nextValue != 0) {
                    value += _calcuRewardByDay(wholeIndex + 1, endIndex) * selfValue.nextValue / wholePledge.list[wholeIndex].nextValue;
                    value += _calcuRewardByDay(wholeIndex, wholeIndex + 1) * selfValue.nextValue / wholePledge.list[wholeIndex].value;
                }

                endIndex = wholeIndex;
                wholeIndex = wholePledge.list[wholeIndex].prevIndex;
            }

            if(selfIndex < endIndex) {
                if(wholePledge.list[wholeIndex].nextValue != 0) {
                    value +=  _calcuRewardByDay(selfIndex + 1, endIndex) * selfValue.nextValue / wholePledge.list[wholeIndex].nextValue;
                }

                if(wholePledge.list[wholeIndex].value != 0) {
                    value +=  _calcuRewardByDay(selfIndex, selfIndex + 1) * selfValue.value / wholePledge.list[wholeIndex].value;
                }
            }

            endIndex = selfIndex;
            selfIndex = selfPledge.list[selfIndex].prevIndex;
            wholeIndex = wholePledge.list[wholeIndex].prevIndex;
        }
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

interface IMiningBase {

    function dayReward(uint) external view returns(uint);

    function setDayReward(uint time, uint value) external;
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '../../libraries/Times.sol';

library ValueList {    
    
    struct Value {
        uint256 value;
        uint256 nextValue;
        uint256 prevIndex;
        bool flag;
    }

    struct List {
        uint256 lastIndex;
        mapping(uint256 => Value) list;
    }

    function add(List storage self, uint256 value) internal {
        uint256 _now = Times.toUTC8(block.timestamp);
        uint256 index = _now / Times.ONE_DAY;

        if (!self.list[index].flag) {
            self.list[index] = Value({
                value: self.list[self.lastIndex].nextValue + value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY,
                nextValue: self.list[self.lastIndex].nextValue + value,
                prevIndex: self.lastIndex,
                flag: true
            });
            self.lastIndex = index;
        } else {
            self.list[index].value = self.list[index].value + value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY;
            self.list[index].nextValue = self.list[index].nextValue + value;
        }
    }

    function sub(List storage self, uint256 value) internal {
        uint256 _now = Times.toUTC8(block.timestamp);
        uint256 index = _now / Times.ONE_DAY;
        if (!self.list[index].flag) {
            self.list[index] = Value({
                value: self.list[self.lastIndex].nextValue - value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY,
                nextValue: self.list[self.lastIndex].nextValue - value,
                prevIndex: self.lastIndex,
                flag: true
            });
            self.lastIndex = index;
        } else {
            self.list[index].value = self.list[index].value - value * (Times.ONE_DAY - _now % Times.ONE_DAY) / Times.ONE_DAY;
            self.list[index].nextValue = self.list[index].nextValue - value;
        }
    }

   function clear(List storage self) internal {
        if(self.lastIndex == 0) {
            return;
        }

        uint256 _now = Times.toUTC8(block.timestamp);
        uint256 index = _now / Times.ONE_DAY;
        
        uint256 _index;
        if(index == self.lastIndex) {
            _index = self.list[self.lastIndex].prevIndex;  
            self.list[self.lastIndex].prevIndex = 0;     
        } else {
            _index = self.lastIndex;
            if(self.list[self.lastIndex].nextValue !=0) {
                self.list[index].value = self.list[self.lastIndex].nextValue;
                self.list[index].nextValue = self.list[self.lastIndex].nextValue;
                self.list[index].flag = true;
                self.lastIndex = index;
            } else{
                delete self.list[self.lastIndex];
                self.lastIndex = 0;
            }
        }
        
        while (_index != 0) {
            uint delIndex = _index;
            _index = self.list[_index].prevIndex;
            delete self.list[delIndex];
        }
    }

    function currentValue(List storage self, bool flag) internal view returns (uint256) {
        if(self.lastIndex == 0) {
            return 0;
        }
        
        if(flag) {
            return self.list[self.lastIndex].nextValue;
        } else {
            uint256 index = Times.toUTC8Index(block.timestamp);
            if(index == self.lastIndex) {
                return self.list[self.lastIndex].value;
            } else {
                return self.list[self.lastIndex].nextValue;
            }
        }
    }

    function indexValue(List storage self, uint index) internal view returns (uint256) {
        if(self.lastIndex == 0) {
            return 0;
        }

        if(self.list[index].flag) {
            return self.list[index].nextValue;
        } else {
            uint256 _index = self.lastIndex;
            while (_index > index) {
                _index = self.list[_index].prevIndex;
            }
            return self.list[_index].nextValue;
        }
    }

    // function all(List storage self) internal view returns (Value[] memory rets) {
    //     uint256 _index = self.lastIndex;
    //     uint256 count;
    //     while (self.list[_index].flag) {
    //         count++;
    //         _index = self.list[_index].prevIndex;
    //     }

    //     rets = new Value[](count);
    //     _index = self.lastIndex;
    //     uint256 len;
    //     while (self.list[_index].flag) {
    //         rets[len] = self.list[_index];
    //         (_index) = (rets[len].prevIndex);
    //         len++;
    //     }
    // }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

import '../libraries/Times.sol';

import './interfaces/IMiningBase.sol';

abstract contract MiningBase is IMiningBase, Ownable {

    struct DayReward {
        uint dayIndex;
        uint value;
    }

    DayReward[] public dayRewards;
    
    event SetBlockReward(uint, uint);

    function setDayReward(uint time, uint value) external override onlyOwner {
        uint dayIndex = Times.toUTC8Index(time);
        require(dayRewards.length == 0 || dayRewards[dayRewards.length - 1].dayIndex < dayIndex, "MiningBase: time error");
        dayRewards.push(DayReward({
            dayIndex: dayIndex,
            value: value
        }));
    }

    function dayReward(uint dayIndex) public view override returns(uint) {
        uint index = dayRewards.length;
        if(dayIndex == 0) {
            dayIndex = Times.toUTC8Index(block.timestamp);
        }

        while(index > 0) {
            if(dayRewards[index - 1].dayIndex <= dayIndex) {
                (uint a, uint b) = _outputRatio(dayIndex);
                return dayRewards[index - 1].value * a / b;
            }
            index -= 1;
        }
        return 0;
    }

    function calcuRewardByDays(uint startDay, uint endDay) public view returns(uint) {
        return _calcuRewardByDay(startDay, endDay);
    }

    function _hasOutputRatio() internal virtual view returns(bool) {
        return false;
    }

    function _outputRatio(uint dayIndex) internal virtual view returns(uint, uint) {
        return (1, 1);
    }

    function _calcuRewardByDay(uint startDay, uint endDay) internal view returns(uint value) {
        if(startDay >= endDay) {
            return value;
        }

        for(uint i = dayRewards.length; i > 0; i--) {
            DayReward storage _dayReward = dayRewards[i -1];
            if(endDay > _dayReward.dayIndex) {
                if(startDay < _dayReward.dayIndex) {
                    if(_hasOutputRatio()) {
                        for(uint j = _dayReward.dayIndex; j < endDay; j++) {
                            (uint a, uint b) = _outputRatio(j);
                            value = value + _dayReward.value * a / b;
                        }
                    } else {
                        value = value + _dayReward.value * (endDay - _dayReward.dayIndex);
                    }
                    
                    endDay = _dayReward.dayIndex;
                } else {
                    if(_hasOutputRatio()) {
                        for(uint j = startDay; j < endDay; j++) {
                            (uint a, uint b) = _outputRatio(j);
                            value = value + _dayReward.value * a / b;
                        }
                    } else {
                        value = value + _dayReward.value * (endDay - startDay);
                    }

                    return value;
                }
            }
        }
        return value;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

// a library for performing various math operations

library Times {
    uint256 constant ONE_DAY = 3600;//86400;
    uint256 constant ONE_YEAR = 365 * 86400;

    function toUTC8(uint256 time) internal pure returns (uint256) {
        // return (time + 8 * 60 * 60);
        return time;
    }

    function toUTC8Index(uint256 time) internal pure returns (uint256) {
        // return (time + 8 * 60 * 60) / ONE_DAY;
        return (time) / ONE_DAY;
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