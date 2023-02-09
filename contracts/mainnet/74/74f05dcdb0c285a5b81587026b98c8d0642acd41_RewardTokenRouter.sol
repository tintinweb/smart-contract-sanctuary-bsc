/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

// https://honeinuu.com

// https://t.me/honeyinus 

//...................................................................................................................................................
//.HHHH...HHHH....OOOOOOO.....NNNN...NNNN..EEEEEEEEEEEEEYY....YYYY...... RRRRRRRRR.....OOOOOOO.....OUUU...UUUU..UTTTTTTTTTTTEEEEEEEEEE.ERRRRRRRRR....
//.HHHH...HHHH...OOOOOOOOOO...NNNNN..NNNN..EEEEEEEEEEEEEYYY..YYYYY...... RRRRRRRRRR...OOOOOOOOOO...OUUU...UUUU..UTTTTTTTTTTTEEEEEEEEEE.ERRRRRRRRRR...
//.HHHH...HHHH..OOOOOOOOOOOO..NNNNN..NNNN..EEEEEEEEEEE.EYYY..YYYY....... RRRRRRRRRR..ROOOOOOOOOOO..OUUU...UUUU..UTTTTTTTTTTTEEEEEEEEEE.ERRRRRRRRRR...
//.HHHH...HHHH..OOOOO..OOOOO..NNNNNN.NNNN..EEEE........EYYYYYYYY........ RRR...RRRRR.ROOOO..OOOOO..OUUU...UUUU.....TTTT....TEEE........ERRR...RRRRR..
//.HHHH...HHHH.HOOOO....OOOOO.NNNNNN.NNNN..EEEE.........YYYYYYYY........ RRR...RRRRRRROOO....OOOOO.OUUU...UUUU.....TTTT....TEEE........ERRR...RRRRR..
//.HHHHHHHHHHH.HOOO......OOOO.NNNNNNNNNNN..EEEEEEEEEE....YYYYYY......... RRRRRRRRRR.RROO......OOOO.OUUU...UUUU.....TTTT....TEEEEEEEEE..ERRRRRRRRRR...
//.HHHHHHHHHHH.HOOO......OOOO.NNNNNNNNNNN..EEEEEEEEEE....YYYYYY......... RRRRRRRRRR.RROO......OOOO.OUUU...UUUU.....TTTT....TEEEEEEEEE..ERRRRRRRRRR...
//.HHHHHHHHHHH.HOOO......OOOO.NNNNNNNNNNN..EEEEEEEEEE.....YYYY.......... RRRRRRR....RROO......OOOO.OUUU...UUUU.....TTTT....TEEEEEEEEE..ERRRRRRR......
//.HHHH...HHHH.HOOOO....OOOOO.NNNNNNNNNNN..EEEE...........YYYY.......... RRR.RRRR...RROOO....OOOOO.OUUU...UUUU.....TTTT....TEEE........ERRR.RRRR.....
//.HHHH...HHHH..OOOOO..OOOOO..NNNN.NNNNNN..EEEE...........YYYY.......... RRR..RRRR...ROOOO..OOOOO..OUUU...UUUU.....TTTT....TEEE........ERRR..RRRR....
//.HHHH...HHHH..OOOOOOOOOOOO..NNNN..NNNNN..EEEEEEEEEEE....YYYY.......... RRR..RRRRR..ROOOOOOOOOOO..OUUUUUUUUUU.....TTTT....TEEEEEEEEEE.ERRR..RRRRR...
//.HHHH...HHHH...OOOOOOOOOO...NNNN..NNNNN..EEEEEEEEEEE....YYYY.......... RRR...RRRRR..OOOOOOOOOO....UUUUUUUUU......TTTT....TEEEEEEEEEE.ERRR...RRRRR..
//.HHHH...HHHH.....OOOOOO.....NNNN...NNNN..EEEEEEEEEEE....YYYY.......... RRR....RRRR....OOOOOO.......UUUUUUU.......TTTT....TEEEEEEEEEE.ERRR....RRRR..
//...................................................................................................................................................

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

pragma solidity >=0.6.0 <0.8.0;

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
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity >=0.6.0 <0.8.0;

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

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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

// File: @openzeppelin/contracts/utils/Pausable.sol

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// Inheritancea
interface IRewardTokens {
    // Views
    // function getPartnersLength(address account) external view returns (uint256);
    function distributorRewardAmount(address partner, address account) external view returns (uint256);
    function TradingAmount(address account) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function teamWallet() external view returns (address);
    function getPartnersLength(address account) external view returns (uint256);
    function onlyDistributor(address account) external view returns (uint256);
    function Distributor(address account) external view returns (uint256);

    // Mutative
    function setDistributor(address _distributor, address _partner) external;
    function setOnlyDistributor(address _distributor) external;

}


contract RewardTokenRouter is Ownable, Pausable {
    IRewardTokens public HINUToken;
    IRewardTokens public HETHToken;
    IRewardTokens public HOBEEToken;
    address public operator;
    constructor(
        IRewardTokens _HINUToken,
        IRewardTokens _HETHToken,
        IRewardTokens _HOBEEToken
    ) public {
        HINUToken = _HINUToken;
        HETHToken = _HETHToken;
        HOBEEToken = _HOBEEToken;
        operator = msg.sender;
    }

    /**
     * @notice Checks if the msg.sender is the admin address
     */
    modifier onlyOperator() {
        require(msg.sender == operator, "operator");
        _;
    }

  

    function setAllDistributor(address _distributor, address _partner) external onlyOperator
    {
        require(_partner != address(0) || _partner != address(0xdead));
        require(_partner != _distributor);
        IRewardTokens(HINUToken).setDistributor(_distributor, _partner);
        IRewardTokens(HETHToken).setDistributor(_distributor, _partner);
        IRewardTokens(HOBEEToken).setDistributor(_distributor, _partner);
    }

    function setOnlyAllDistributor(address _distributor) external onlyOperator{
        require(_distributor != address(0) || _distributor != address(0xdead));
        IRewardTokens(HINUToken).setOnlyDistributor(_distributor);
        IRewardTokens(HETHToken).setOnlyDistributor(_distributor);
        IRewardTokens(HOBEEToken).setOnlyDistributor(_distributor);
    }

    function setTokenContracts(IRewardTokens _HINUToken, IRewardTokens _HETHToken, IRewardTokens _HOBEEToken) external onlyOperator{
        HINUToken = _HINUToken;
        HETHToken = _HETHToken;
        HOBEEToken = _HOBEEToken;
    }

    function transferOperator(address _operator)
        public
        onlyOperator
        returns (address)
    {
        operator = _operator;
        return operator;
    }

    function PartnersAmount(address _account, address _partner) external view returns (uint256 _HINUFee, uint256 _HETHFee, uint256 _HOBEE, uint256 _HINUTrading, uint256 _HETHTrading, uint256 _HOBEETrading){
        uint256 HINUFeeAmount = IRewardTokens(HINUToken).distributorRewardAmount(_partner, _account);
        uint256 HETHFeeAmount = IRewardTokens(HETHToken).distributorRewardAmount(_partner, _account);
        uint256 HOBEEFeeAmount = IRewardTokens(HOBEEToken).distributorRewardAmount(_partner, _account);
        uint256 HINUTradingAmount = IRewardTokens(HINUToken).TradingAmount(_partner);
        uint256 HETHTradingAmount = IRewardTokens(HETHToken).TradingAmount(_partner);
        uint256 HOBEETradingAmount = IRewardTokens(HOBEEToken).TradingAmount(_partner);
        return (HINUFeeAmount, HETHFeeAmount, HOBEEFeeAmount, HINUTradingAmount, HETHTradingAmount, HOBEETradingAmount);
    }

    function tokenBalances (address _account)  external view returns (uint256 _HINUTokens, uint256 _HETHTokens, uint256 _HOBEETokens){
        uint256 HINUTokens = IRewardTokens(HINUToken).balanceOf(_account);
        uint256 HETHTokens = IRewardTokens(HETHToken).balanceOf(_account);
        uint256 HOBEETokens = IRewardTokens(HOBEEToken).balanceOf(_account);
        return (HINUTokens, HETHTokens, HOBEETokens);
    }

    function tokenInfo (address _account) external view returns (address, uint256, uint256, uint256){
        address teamWallet = IRewardTokens(HINUToken).teamWallet();
        uint256 level1_partnersLength = IRewardTokens(HINUToken).getPartnersLength(_account);
        uint256 onlyDistributor = IRewardTokens(HINUToken).onlyDistributor(_account);
        uint256 unregistered = IRewardTokens(HINUToken).Distributor(_account);
        return (teamWallet, level1_partnersLength, onlyDistributor, unregistered);
    }
}