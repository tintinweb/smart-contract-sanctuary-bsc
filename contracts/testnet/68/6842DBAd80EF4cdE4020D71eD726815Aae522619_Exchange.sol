/**
 *Submitted for verification at BscScan.com on 2022-04-16
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
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

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Exchange is Ownable {
    using Address for address;

    struct Pool {
        address RtAddress;
        address RuAddress;
        address poolCreator;
        uint256 RtAmount;
        uint256 RuAmount;
        uint256 maxLeverage;
    }

    struct LeverageTrade {
        uint256 usdcAmount;
        uint256 positionLeverage;
    }

    // @notice poolList map.
    // uint256 => pool id. This field is increment primary number of the poolList map
    // Pool => the structure of the Pool
    mapping(uint256 => Pool) public poolList;

    // @notice total poolList length
    uint256 public poolListLength;

    // @notice leverageTradeList map.
    // address => creator address of leverage trade
    // uint256 => leverage trade id. This field is increment primary number of the poolList map
    // LeverageTrade => the structure of the Leverage Trade
    mapping(address => mapping(uint256 => LeverageTrade))
        public leverageTradeList;

    // @notice total leverageTradeList length
    mapping(address => uint256) public leverageTradeListLength;

    // @notice max leverage value of the contract strategy
    uint256 internal maxLeverage;

    // @notice usdc token address of the contract AMM leverage trade
    IERC20 internal USDCAddress;

    /**
     * @notice Exchange Constructor
     * @param _USDCAddress USDC Address
     */
    constructor(address _USDCAddress) {
        poolListLength = 0;
        maxLeverage = 10;
        USDCAddress = IERC20(_USDCAddress);
    }

    /**
     * @notice create new Pool
     * @param _RtAddress token address which will do the liquidity from.
     * @param _RuAddress token address which will do the liquidity from.
     * @param _RtAmount token amount which will do the liquidity . Decimal has to calculate before inputted.
     * @param _RuAmount token amount which will do the liquidity . Decimal has to calculate before inputted.
     */
    function createPool(
        address _RtAddress,
        address _RuAddress,
        uint256 _RtAmount,
        uint256 _RuAmount
    ) external {
        IERC20 RtAddressAsset = IERC20(_RtAddress);
        IERC20 RuAddressAsset = IERC20(_RuAddress);
        require(_RtAddress != address(0), "_RtAddress param err");
        require(_RuAddress != address(0), "_RuAddress param err");
        require(_RtAddress != _RuAddress, "_RtAddress _RuAddress param err");
        require(_RtAmount > 0, "_RtAmount param err");
        require(_RuAmount > 0, "_RuAmount param err");
        require(
            RtAddressAsset.balanceOf(msg.sender) >= _RtAmount,
            "_RtAmount balance err"
        );
        require(
            RuAddressAsset.balanceOf(msg.sender) >= _RuAmount,
            "_RuAmount balance err"
        );
        RtAddressAsset.transferFrom(msg.sender, address(this), _RtAmount);
        RuAddressAsset.transferFrom(msg.sender, address(this), _RuAmount);
        poolList[poolListLength++] = Pool(
            _RtAddress,
            _RuAddress,
            msg.sender,
            _RtAmount,
            _RuAmount,
            maxLeverage
        );
    }

    /**
     * @notice remove new Pool
     * @param _poolId the primary id that will remove the pool.
     */
    function removePool(uint256 _poolId) external {
        require(poolList[_poolId].poolCreator == msg.sender, "permission err");
        IERC20 RtAddressAsset = IERC20(poolList[_poolId].RtAddress);
        IERC20 RuAddressAsset = IERC20(poolList[_poolId].RuAddress);

        RtAddressAsset.transferFrom(
            address(this),
            msg.sender,
            poolList[_poolId].RtAmount
        );
        RuAddressAsset.transferFrom(
            address(this),
            msg.sender,
            poolList[_poolId].RuAmount
        );

        for (uint256 i = _poolId; i < poolListLength - 1; i++) {
            poolList[i] = poolList[i + 1];
        }
        poolList[poolListLength - 1] = Pool(
            address(0),
            address(0),
            address(0),
            0,
            0,
            0
        );
        poolListLength--;
    }

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _RtAddress token address which will do the liquidity from.
     * @param _RuAddress token address which will do the liquidity from.
     */
    function checkPoolPrimaryId(address _RtAddress, address _RuAddress)
        public
        view
        returns (uint256)
    {
        for (uint256 i = 0; i < poolListLength - 1; i++) {
            if (
                (poolList[i].RtAddress == _RtAddress) &&
                (poolList[i].RuAddress == _RuAddress) &&
                (poolList[i].poolCreator == msg.sender)
            ) {
                return i;
            }
        }
        return 9999;
    }

    /**
     * @notice exchange the ERC token about the exsited pool in the exchange
     * @param _poolId the primary id that will exchange.
     * @param _depositAmount the amount that will exchange.
     * @param _depositAddress the amount that will exchange.
     */
    function exchangeAMM(
        uint256 _poolId,
        uint256 _depositAmount,
        address _depositAddress
    ) external {
        address RtAddress = address(0);
        uint256 RtAmount = 0;
        address RuAddress = address(0);
        uint256 RuAmount = 0;
        if (poolList[_poolId].RtAddress == _depositAddress) {
            RtAddress = poolList[_poolId].RtAddress;
            RtAmount = poolList[_poolId].RtAmount;
            RuAddress = poolList[_poolId].RuAddress;
            RuAmount = poolList[_poolId].RuAmount;
        }
        if (poolList[_poolId].RuAddress == _depositAddress) {
            RtAddress = poolList[_poolId].RuAddress;
            RtAmount = poolList[_poolId].RuAmount;
            RuAddress = poolList[_poolId].RtAddress;
            RuAmount = poolList[_poolId].RtAmount;
        }
        require(
            RtAddress != address(0) && RuAddress != address(0),
            "param err"
        );
        uint256 resultAmount = RuAmount -
            (RtAmount * RuAmount) /
            (RtAmount + _depositAmount);
        IERC20 RtAddressAsset = IERC20(RtAddress);
        IERC20 RuAddressAsset = IERC20(RuAddress);
        require(
            RtAddressAsset.balanceOf(msg.sender) >= _depositAmount,
            "user balancer err"
        );
        require(
            RuAddressAsset.balanceOf(address(this)) >= resultAmount,
            "contract balancer err"
        );
        RtAddressAsset.transferFrom(msg.sender, address(this), _depositAmount);
        RuAddressAsset.transferFrom(address(this), msg.sender, resultAmount);
        poolList[_poolId] = Pool(
            RtAddress,
            RuAddress,
            poolList[_poolId].poolCreator,
            (RtAmount + _depositAmount),
            (RuAmount - resultAmount),
            poolList[_poolId].maxLeverage
        );
    }

    /**
     * @notice Deposit USDC
     * @param _depositAmount the amount of USDC.
     */
    function depositLeverageTrade(uint256 _depositAmount) external {
        require(
            USDCAddress.balanceOf(msg.sender) >= _depositAmount,
            "amount err"
        );
        USDCAddress.transferFrom(msg.sender, address(this), _depositAmount);
        leverageTradeList[msg.sender][
            leverageTradeListLength[msg.sender]++
        ] = LeverageTrade(_depositAmount, 0);
    }

    /**
     * @notice swap USDC Trade
     * @param _tradeId the primary id of the leverageTradeList.
     * @param _positionRelease the position release amount.
     */
    function swapLeverageTrade(uint256 _tradeId, uint256 _positionRelease)
        external
    {
        require(
            _tradeId < leverageTradeListLength[msg.sender],
            "_tradeId param err"
        );
        require(
            _positionRelease <=
                maxLeverage -
                    leverageTradeList[msg.sender][_tradeId].positionLeverage,
            "_positionRelease param err"
        );
        require(
            address(this).balance >
                leverageTradeList[msg.sender][_tradeId].usdcAmount *
                    _positionRelease,
            "eth amount err"
        );

        address payable _payAdr = payable(address(uint160(msg.sender)));
        _payAdr.transfer(
            leverageTradeList[msg.sender][_tradeId].usdcAmount *
                _positionRelease
        );

        if (
            leverageTradeList[msg.sender][_tradeId].positionLeverage -
                _positionRelease ==
            0
        ) {
            for (
                uint256 i = _tradeId;
                i < leverageTradeListLength[msg.sender] - 1;
                i++
            ) {
                leverageTradeList[msg.sender][i] = leverageTradeList[
                    msg.sender
                ][i + 1];
            }
            leverageTradeList[msg.sender][
                leverageTradeListLength[msg.sender] - 1
            ] = LeverageTrade(0, 0);
            leverageTradeListLength[msg.sender]--;
        } else {
            leverageTradeList[msg.sender][_tradeId] = LeverageTrade(
                leverageTradeList[msg.sender][_tradeId].usdcAmount,
                leverageTradeList[msg.sender][_tradeId].positionLeverage -
                    _positionRelease
            );
        }
    }

    /**
     * @notice return the amount after swap
     * @param _depositAmount the amount that will exchange.
     * @param _depositAddress the amount that will exchange.
     */
    function getExpectedAmountSwap(
        uint256 _depositAmount,
        address _depositAddress
    ) external view returns (uint256) {
        require(
            _depositAddress != address(0) && _depositAmount != 0,
            "param err"
        );
        address RtAddress = address(0);
        uint256 RtAmount = 0;
        address RuAddress = address(0);
        uint256 RuAmount = 0;

        uint256 _poolId = 9999;
        for (uint256 i = 0; i < poolListLength; i++) {
            if (poolList[i].RtAddress == _depositAddress) {
                _poolId = i;
            }
        }

        require(_poolId != 9999, "param err");

        RtAddress = poolList[_poolId].RtAddress;
        RtAmount = poolList[_poolId].RtAmount;
        RuAddress = poolList[_poolId].RuAddress;
        RuAmount = poolList[_poolId].RuAmount;

        uint256 resultAmount = RuAmount -
            (RtAmount * RuAmount) /
            (RtAmount + _depositAmount);
        return resultAmount;
    }

    /**
     * @notice return the amount for swap
     * @param _targetAmount the amount that will exchange.
     * @param _targetAddress the amount that will exchange.
     */
    function getAmountForPaySwap(uint256 _targetAmount, address _targetAddress)
        external
        view
        returns (uint256)
    {
        require(
            _targetAddress != address(0) && _targetAmount != 0,
            "param err"
        );
        address RtAddress = address(0);
        uint256 RtAmount = 0;
        address RuAddress = address(0);
        uint256 RuAmount = 0;

        uint256 _poolId = 9999;
        for (uint256 i = 0; i < poolListLength; i++) {
            if (poolList[i].RuAddress == _targetAddress) {
                _poolId = i;
            }
        }

        require(_poolId != 9999, "param err");

        RtAddress = poolList[_poolId].RtAddress;
        RtAmount = poolList[_poolId].RtAmount;
        RuAddress = poolList[_poolId].RuAddress;
        RuAmount = poolList[_poolId].RuAmount;

        uint256 resultAmount = (RtAmount * RuAmount) /
            (RuAmount - _targetAmount) -
            RtAmount;
        return resultAmount;
    }

    /**
     * @notice return the leverage detail info
     * @param _leverageId the amount that will exchange.
     */
    function getLeverageInfo(uint256 _leverageId)
        external
        view
        returns (uint256, uint256)
    {
        require(
            _leverageId < leverageTradeListLength[msg.sender],
            "_tradeId param err"
        );

        return (
            leverageTradeList[msg.sender][_leverageId].usdcAmount *
                (maxLeverage -
                    leverageTradeList[msg.sender][_leverageId]
                        .positionLeverage),
            leverageTradeList[msg.sender][_leverageId].positionLeverage
        );
    }
}