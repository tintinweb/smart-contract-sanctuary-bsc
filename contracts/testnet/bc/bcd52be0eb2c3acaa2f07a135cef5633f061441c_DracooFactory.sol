// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./Address.sol";


/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Adds 'burn' into this ERC20 interface.
     * in order to use it in other contracts to burn tokens.
     */
    function burn(uint256 amount) external returns (bool);

    /**
     * @dev Adds 'burnFrom' into this ERC20 interface.
     * in order to use it in other contracts to burn tokens.
     */
    function burnFrom(address account, uint256 amount) external returns (bool);

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IDracooMaster {

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function checkParents(uint256 tokenId) external view returns (uint256[2] memory);

    function breedMint(address to, uint256[2] memory parentsId) external returns(uint256);

    function checkBreedTimes(uint256 tokenId) external view returns(uint256);

}

// must be assigned as a MinterRole of "DracooMaster" contract
contract DracooFactory is Context, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IDracooMaster public dracoo;
    IERC20 public draToken;
    IERC20 public basToken;

    address private _vault;
    bool private _isBreedAvailable;
    // breed times => DRA cost per breed
    mapping(uint256 => uint256) private _draCost;
    // breed times => BAS cost per breed
    mapping(uint256 => uint256) private _basCost;
    // breed times => frezze time
    mapping(uint256 => uint256) private _freezeTime;
    // dracoo tokenId => next breed time
    mapping(uint256 => uint256) private _nextBreedTime;

    event BreedDracooEgg(uint256 indexed dracooEgg, uint256 dracoo1, uint256 dracoo2, uint256 dracoo1BreedTimes, uint256 dracoo2BreedTimes, uint256 timestamp, address from, address owner);

    constructor (address dracooAddress, 
                 address draAddress, 
                 address basAddress, 
                 address vaultAddress) public {

        dracoo = IDracooMaster(dracooAddress);
        draToken = IERC20(draAddress);
        basToken = IERC20(basAddress);
        _vault = vaultAddress;

        _setTokenCost();
        _setFreezeTime();
        _isBreedAvailable = false;    // initialize as false state
    }

    function setBreedAvailable(bool _newState) public onlyOwner {
        _isBreedAvailable = _newState;
    }

    function setVault(address newVault) public onlyOwner {
        require(newVault != address(0), "can not be the blackhole address");
        _vault = newVault;
    }

    function setDraCost(uint256 breedTime, uint256 newCost) public onlyOwner {
        require(breedTime < 5, "can not exceed 5 times");
        _draCost[breedTime] = newCost;
    }

    function setBasCost(uint256 breedTime, uint256 newCost) public onlyOwner {
        require(breedTime < 5, "can not exceed 5 times");
        _basCost[breedTime] = newCost;
    }

    function setFreezeTime(uint256 breedTime, uint256 newFreezeTime) public onlyOwner {
        require(breedTime < 5, "can not exceed 5 times");
        _freezeTime[breedTime] = newFreezeTime;
    }

    function isBreedAvailable() public view returns (bool) {
        return _isBreedAvailable;
    }

    function draCost(uint256 breedTime) public view returns(uint256) {
        require(breedTime < 5, "can not exceed 5 times");
        return _draCost[breedTime];
    }

    function basCost(uint256 breedTime) public view returns(uint256) {
        require(breedTime < 5, "can not exceed 5 times");
        return _basCost[breedTime];
    }

    function nextBreedTime(uint256 tokenId) public view returns(uint256) {
        require(dracoo.checkBreedTimes(tokenId) < 5, "can not exceed 5 times");
        return _nextBreedTime[tokenId];
    }

    // must be the Minter of Dracoo contract
    function breedDracooEgg(uint256[2] memory twoDracooIds) public nonReentrant returns(uint256) {
        require(isBreedAvailable(), "Dracoo Factory is closed now, try later");
        uint256 dracoo1 = twoDracooIds[0];
        uint256 dracoo2 = twoDracooIds[1];
        require((nextBreedTime(dracoo1) <= block.timestamp) && (nextBreedTime(dracoo2) <= block.timestamp), "can NOT breed within freeze time, try later");
        // user must be the owner of both Dracoo
        require(dracoo.ownerOf(dracoo1) == _msgSender() && dracoo.ownerOf(dracoo2) == _msgSender(), "you are not the owner of those two Dracoo");
        uint256[2] memory dracoo1Parents = dracoo.checkParents(dracoo1);
        uint256 dracoo1Father = Math.max(dracoo1Parents[0], dracoo1Parents[1]);
        uint256 dracoo1Mother = Math.min(dracoo1Parents[0], dracoo1Parents[1]);
        uint256[2] memory dracoo2Parents = dracoo.checkParents(dracoo2);
        uint256 dracoo2Father = Math.max(dracoo2Parents[0], dracoo2Parents[1]);
        uint256 dracoo2Mother = Math.min(dracoo2Parents[0], dracoo2Parents[1]);
        // can not breed with its parents
        require(dracoo1 != dracoo2Father && 
                dracoo1 != dracoo2Mother && 
                dracoo2 != dracoo1Father && 
                dracoo2 != dracoo1Mother, "can not breed with parents");
        if ((dracoo1Father != 0 || dracoo1Mother != 0) &&
            (dracoo2Father != 0 || dracoo2Mother != 0)) {    // can not breed by brothers or sisters
            require((dracoo1Father != dracoo2Father) || 
                    (dracoo1Mother != dracoo2Mother), "can not breed by brothers or sisters");
        }

        // compute consumed DRA & BAS token cost, and transfer
        _computeAndTransfer(dracoo1, dracoo2);
        // breed
        uint256 dracooTokenId = dracoo.breedMint(_msgSender(), twoDracooIds);
        // add freeze time
        uint256 dracoo1BreedTimes = dracoo.checkBreedTimes(dracoo1);
        uint256 dracoo2BreedTimes = dracoo.checkBreedTimes(dracoo2);
        _nextBreedTime[dracoo1] = _freezeTime[dracoo1BreedTimes].add(block.timestamp);
        _nextBreedTime[dracoo2] = _freezeTime[dracoo2BreedTimes].add(block.timestamp);

        emit BreedDracooEgg(dracooTokenId, dracoo1, dracoo2, dracoo1BreedTimes, dracoo2BreedTimes, block.timestamp, address(0), _msgSender());
        return dracooTokenId;
    }

    function _computeAndTransfer(uint256 dracoo1, uint256 dracoo2) internal {
        uint256 dracoo1BreedTime = dracoo.checkBreedTimes(dracoo1);
        uint256 dracoo2BreedTime = dracoo.checkBreedTimes(dracoo2);

        draToken.safeTransferFrom(_msgSender(), _vault, _draCost[dracoo1BreedTime] + _draCost[dracoo2BreedTime]);
        basToken.safeTransferFrom(_msgSender(), _vault, _basCost[dracoo1BreedTime] + _basCost[dracoo2BreedTime]);
    }

    function _setTokenCost() private {
        _draCost[0] = 5 * 1e18;
        _draCost[1] = 10 * 1e18;
        _draCost[2] = 15 * 1e18;
        _draCost[3] = 20 * 1e18;
        _draCost[4] = 25 * 1e18;

        _basCost[0] = 700 * 1e18;
        _basCost[1] = 1500 * 1e18;
        _basCost[2] = 3000 * 1e18;
        _basCost[3] = 5600 * 1e18;
        _basCost[4] = 7200 * 1e18;
    }

    function _setFreezeTime() private {
        _freezeTime[1] = 24 hours;
        _freezeTime[2] = 48 hours;
        _freezeTime[3] = 72 hours;
        _freezeTime[4] = 96 hours;
    }

}