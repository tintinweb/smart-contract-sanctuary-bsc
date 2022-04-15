/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIP

/**
 *                                                                                @
 *                                                                               @@@
 *                          @@@@@@@                     @@@@@@@@                @ @ @
 *                   @@@@@@@@@@@@@@@@@@@@         @@@@@@@@@@@@@@@@@@@@           @@@
 *                @@@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@         @
 *
 *    @@@@@@@@     @@@@@@@@@    @@@@@@@@@@    @@@@@@@       @@@      @@@@@  @@     @@@@@@@@@@
 *    @@@@@@@@@@   @@@@@@@@@@   @@@@@@@@@@   @@@@@@@@@      @@@       @@@   @@@    @@@@@@@@@@
 *    @@@     @@@  @@@     @@@  @@@     @@  @@@     @@@    @@@@@      @@@   @@@@   @@@     @@
 *    @@@     @@@  @@@     @@@  @@@         @@@            @@@@@      @@@   @@@@   @@@
 *    @@@@@@@@@@   @@@@@@@@@@   @@@    @@    @@@@@@@      @@@ @@@     @@@   @@@@   @@@    @@
 *    @@@@@@@@     @@@@@@@@     @@@@@@@@@     @@@@@@@     @@@ @@@     @@@   @@@@   @@@@@@@@@
 *    @@@          @@@   @@@    @@@    @@          @@@   @@@   @@@    @@@   @@@@   @@@    @@
 *    @@@  @@@@    @@@   @@@    @@@                 @@@  @@@   @@@    @@@   @@@@   @@@
 *    @@@   @@@    @@@    @@@   @@@     @@  @@@     @@@  @@@@@@@@@    @@@   @@     @@@     @@
 *    @@@    @@    @@@    @@@   @@@@@@@@@@   @@@@@@@@    @@@   @@@    @@@      @@  @@@@@@@@@@
 *   @@@@@     @  @@@@@   @@@@  @@@@@@@@@@    @@@@@@    @@@@@ @@@@@  @@@@@@@@@@@@  @@@@@@@@@@
 *
 *                @@@@@@@@@@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@@@@@@@@@@@
 *                   @@@@@@@@@@@@@@@@@@@@        @@@@@@@@@@@@@@@@@@@@@
 *                        @@@@@@@@@@                 @@@@@@@@@@@@
 *
 */

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./SafeERC20.sol";
import "./ReentrancyGuard.sol";

/*===================================================
    OpenZeppelin Contracts (last updated v4.5.0)
=====================================================*/

interface OldPresale { 
    function claimableAmounts(address account) external view returns (uint256);
}

contract CNTPresale is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    event TokenPurchase(address indexed beneficiary, uint256 amount);

    // CNT and BUSD token
    IERC20 private cnt;
    IERC20 private busd;

    // Round Information
    struct RoundInfo {
        uint256 cntPrice;
        uint256 hardCap;
        uint256 startTime;
        uint256 endTime;
        uint256 busdAmount;
        uint256 investors;
        bool    active;
    }
    
    mapping(uint8 => RoundInfo) public roundInfos;

    uint8 public constant maxRoundLV = 3;
    uint8 public currentRound;

    // time to start claim.
    uint256 public claimStartTime = 1649894400; // Thu Apr 14 2022 00:00:00 UTC

    // user information
    address firstAddress = 0xBa2277c387969FDD7A506f128557F7d0D07bF1EE;
    address secondAddress = 0x7DE540505fb4d4c61CD85bd6db18F102fD5c8654;
    address thirdAddress = 0x02E4F17F6e98742F7568CFD7c94d317FFcD0DeC2;

    mapping (address => uint256) public claimableAmounts;
    mapping (address => bool) isChecked;

    // Referral Information
    mapping(address => uint16) public referralCount;

    uint256[] public REFERRAL_PERCENTS = [200, 250, 300, 400];

    // price and percent divisor
    uint256 constant public divisor = 10000;

    // wallet to withdraw
    address public wallet;

    /**
     * @dev Initialize with token address and round information.
     */
    constructor (address _cnt, address _busd, address _wallet) Ownable() {
        require(_cnt != address(0), "presale-err: invalid address");
        require(_busd != address(0), "presale-err: invalid address");
        require(_wallet != address(0), "presale-err: invalid address");

        cnt = IERC20(_cnt);
        busd = IERC20(_busd);
        wallet = _wallet;
  
        roundInfos[1].cntPrice = 75;

        roundInfos[1].hardCap = 500_000 * 10**18;
    }

    /**
     * @dev Initialize ICO data. Only for test
     */
    function Initialize() external onlyOwner {
        roundInfos[1].startTime = 0;
        roundInfos[1].endTime = 0;
        roundInfos[1].busdAmount = 0;
        roundInfos[1].investors = 0;
        roundInfos[1].active = false;

        currentRound = 0;
    }

    /**
     * @dev Set token price for a round.
     */
    function setPrice(uint256 _price) external onlyOwner {
        roundInfos[1].cntPrice = _price;
    }

    function checkMyBalance() external {
        require(!isChecked[msg.sender], "already updated!");
        OldPresale first = OldPresale(firstAddress);
        OldPresale second = OldPresale(secondAddress);
        if(claimableAmounts[msg.sender] <= 0) {
            claimableAmounts[msg.sender] = 0;
        }

        claimableAmounts[msg.sender] += first.claimableAmounts(msg.sender);
        claimableAmounts[msg.sender] += second.claimableAmounts(msg.sender);
        isChecked[msg.sender] = true;
    }

    function recoverCntBalance(address[] memory addr, uint256[] memory am) external onlyOwner {
        
        // OldPresale first = OldPresale(firstAddress);
        // OldPresale second = OldPresale(secondAddress);
        // OldPresale last = OldPresale(thirdAddress);

        for(uint256 i = 0 ; i < addr.length; i++) {
            // if(last.claimableAmounts(addr[i]) > 0) {
            //     // claimableAmounts[addr[i]] = last.claimableAmounts(addr[i]);
            //     isChecked[addr[i]] = true;
            //     continue ;
            // }
            if(claimableAmounts[addr[i]] <= 0) {
                claimableAmounts[addr[i]] = 0;
            }
            claimableAmounts[addr[i]] += _getTokenAmount(am[i]);

            if(!isChecked[addr[i]]) {
                // claimableAmounts[addr[i]] += first.claimableAmounts(addr[i]);
                // claimableAmounts[addr[i]] += second.claimableAmounts(addr[i]);
                isChecked[addr[i]] = true;
            }
        }
    }

    /**
     * @dev Set hardcap for a round.
     */
    function setHardCap(uint256 _hardCap) external onlyOwner {
        require(_hardCap >= roundInfos[1].busdAmount , "presale-err: _hardCap should be greater than deposit amount");

        roundInfos[1].hardCap = _hardCap;
        roundInfos[1].active = true;
    }

    /**
     * @dev Start ICO with end time and hard cap.
     */
    function startICO() external onlyOwner {
        require(roundInfos[1].active == false, "presale-err: Round is already running");

        currentRound = 1;
        roundInfos[1].active = true;
        roundInfos[1].startTime = block.timestamp;
    }

    /**
     * @dev Stop current round.
     */
    function stopICO() external onlyOwner {
        require(roundInfos[1].active == true, "presale-err: no active ico-round");

        roundInfos[currentRound].active = false;
        roundInfos[currentRound].endTime = block.timestamp;
        roundInfos[currentRound].hardCap = roundInfos[currentRound].busdAmount;
    }

    /**
     * @dev Calculate token amount for busd amount.
     */
    function _getTokenAmount(uint256 _busdAmount) internal view returns (uint256) {
        return _busdAmount / roundInfos[1].cntPrice * divisor / (10**9);
    }

    /**
     * @dev Calculate referral bonus amount with refCount.
     */
    function _getReferralAmount(uint16 _refCount, uint256 _busdAmount) internal view returns (uint256) {
        uint256 referralAmount = 0;
        if (_refCount < 4) {
            referralAmount = _busdAmount * REFERRAL_PERCENTS[0] / divisor;
        } else if (_refCount < 10) {
            referralAmount = _busdAmount * REFERRAL_PERCENTS[1] / divisor;
        } else if (_refCount < 26) {
            referralAmount = _busdAmount * REFERRAL_PERCENTS[2] / divisor;
        } else {
            referralAmount = _busdAmount * REFERRAL_PERCENTS[3] / divisor;
        }

        return referralAmount;
    }

    /**
     * @dev Buy tokens with busd and referral address.
     */
    function buyTokens(uint256 _amount, address _referrer) external nonReentrant {
        _preValidatePurchase(msg.sender, _amount);

        uint256 referralAmount;
        if (_referrer != address(0)) {
            referralCount[_referrer] += 1;
            uint16 refCount = referralCount[_referrer];
            
            referralAmount = _getReferralAmount(refCount, _amount);

            _amount -= referralAmount;
        }

        if (roundInfos[1].busdAmount + _amount > roundInfos[1].hardCap) {
            _amount = roundInfos[1].hardCap - roundInfos[1].busdAmount;
            roundInfos[1].endTime = block.timestamp;
            roundInfos[1].active = false;

            if (referralAmount > 0) {
                uint16 refCount = referralCount[_referrer];
                referralAmount = _getReferralAmount(refCount, _amount);
                _amount -= referralAmount;
            }
        }

        busd.safeTransferFrom(msg.sender, address(this), _amount + referralAmount);
        
        if (referralAmount > 0) {
            busd.safeTransfer(_referrer, referralAmount);
        }

        roundInfos[1].busdAmount += _amount;
        roundInfos[1].investors += 1;

        uint256 purchaseAmount = _getTokenAmount(_amount);
        claimableAmounts[msg.sender] += purchaseAmount;

        emit TokenPurchase(msg.sender, purchaseAmount);
    }

    /**
     * @dev Check the possibility to buy token.
     */
    function _preValidatePurchase(address _beneficiary, uint256 _amount) internal view {
        require(_beneficiary != address(0), "presale-err: beneficiary is the zero address");
        require(_amount != 0, "presale-err: _amount is 0");
        require(roundInfos[1].active == true, "presale-err: no active round");
        this; 
    }

    /**
     * @dev Claim tokens after ICO.
     */
    function claimTokens() external {
        require(block.timestamp > 1649894400, "presale-err: can claim after Apr 14 2022 UTC");
        require(roundInfos[1].active == false, "presale-err: ICO is not finished yet");
        require(claimableAmounts[msg.sender] > 0, "presale-err: no token to claim");

        cnt.safeTransfer(msg.sender, claimableAmounts[msg.sender]);
        claimableAmounts[msg.sender] = 0;
    }

    /**
     * @dev Withdraw busd or cnt token from this contract.
     */
    function withdrawTokens(address _token) external onlyOwner {
        IERC20(_token).safeTransfer(wallet, IERC20(_token).balanceOf(address(this)));
    }

    /**
     * @dev Set referral percent on referral level.
     */
    function setReferralPercent(uint8 _referralLV, uint256 _refPercent) external onlyOwner {
        require(_referralLV < 4, "presale-err: referralLV should be less than 4");
        require(_refPercent < 1000, "presale-err: refPercent should be less than 10%");
        
        REFERRAL_PERCENTS[_referralLV] = _refPercent;
    }

    /**
     * @dev Set wallet to withdraw.
     */
    function setWalletReceiver(address _newWallet) external onlyOwner {
        wallet = _newWallet;
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

pragma solidity ^0.8.4;

/**
 * @dev Interface of the BEP standard.
 */
interface IERC20 {

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Returns the token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity ^0.8.10;

library Address {    
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success,) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

pragma solidity ^0.8.10;

import "./Address.sol";
import "./IERC20.sol";

library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
       );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

pragma solidity ^0.8.10;

abstract contract ReentrancyGuard {

    bool private _notEntered;

    constructor () {

        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;
        _;
        _notEntered = true;
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