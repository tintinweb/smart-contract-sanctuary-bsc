// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";
import "./ProjectPresaleConfig.sol";
import "./Shifts.sol";
import "./ProjectManager.sol";
import "./ProjectVotation.sol";
import "./ProjectLaunch.sol";
import "./ProjectVesting.sol";
import "./SecurityFund.sol";
import "./Master.sol";

contract ProjectPresale is Ownable, Operable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount; 
        uint256 claimed; 
        bool refunded;
    }

    struct Presale {
        address owner;
        uint256 shiftID;
        IERC20 stakeToken;
        IERC20 offeringToken;
        uint256 raisingAmount;
        uint256 offeringAmount;
        uint256 totalAmount;
        address[] addressList;
        uint256 contributors;
        bool launched;
    }

    struct PresaleFront {
        address owner;
        uint256 shiftID;
        IERC20 stakeToken;
        IERC20 offeringToken;
        uint256 raisingAmount;
        uint256 offeringAmount;
        uint256 totalAmount;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 softcap;
        uint256 contributors;
        bool launched;
    }
    
    Shifts public shifts;
    ProjectPresaleConfig public config;

    mapping(address => Presale) public presales;
    address[] public presaleAddresses;

    mapping(address => address[]) public userPresales;

    mapping(address => mapping(address => UserInfo)) public userInfo;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public autoBuy;

    constructor(address _operator, ProjectPresaleConfig _config) {
        transferOperable(_operator);
        setConfig(_config);
    }

    modifier onlyActivePresale(address _tokenAddress) {
        require(
            isActivePresale(_tokenAddress),
            "not ifo time"
        );
        _;
    }

    modifier onlyFinishedPresale(address _tokenAddress) {
        require(
            isFinishedPresale(_tokenAddress),
            "ifo not finished"
        );
        _;
    }

    modifier onlyProjectOwner(address _tokenAddress) {
        require(
            msg.sender == presales[_tokenAddress].owner,
            "not project owner"
        );
        _;
    }

    modifier onlySoftcapReached(address _tokenAddress) {
        require(
            isSoftcapReached(_tokenAddress), 
            "softcap not reached"
        );
        _;
    }

    modifier onlyAutoBuy() {
        require(
            address(autoBuy) == address(msg.sender), 
            "not autobuy"
        );
        _;
    }



    /** VIEWS */

    function getUserPresaleAllocation(address _tokenAddress, address _user) internal view returns (uint256) {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][_user];
        return user.amount.mul(1e12).div(presale.totalAmount).div(1e6);
    }

    function getAddressListLength(address _tokenAddress) external view returns (uint256) {
        Presale storage presale = presales[_tokenAddress];
        return presale.addressList.length;
    }

    function getUserInfo(address _tokenAddress, address _user) public view returns (UserInfo memory) {
        return userInfo[_tokenAddress][_user];
    }

    function getPresale(address _tokenAddress) public view returns (Presale memory) {
        return presales[_tokenAddress];
    }

    function getPresaleFront(address _tokenAddress) external view returns (PresaleFront memory) {
        return _formatPresaleFront(_tokenAddress);
    }

    function isFinishedPresale(address _tokenAddress) public view returns (bool) {
        return 
            block.timestamp > shifts.shifts(presales[_tokenAddress].shiftID) + config.presaleDuration();
    }

    function isActivePresale(address _tokenAddress) public view returns (bool) {
        return 
            block.timestamp >= shifts.shifts(presales[_tokenAddress].shiftID) && 
            block.timestamp <= shifts.shifts(presales[_tokenAddress].shiftID) + config.presaleDuration();
    }

    function isUpcomingPresale(address _tokenAddress) public view returns (bool) {
        return 
            block.timestamp < shifts.shifts(presales[_tokenAddress].shiftID);
    }

    function isSoftcapReached(address _tokenAddress) public view returns (bool) {
        return 
            presales[_tokenAddress].raisingAmount * config.presaleSoftCapBPS() <= 
            presales[_tokenAddress].totalAmount * 1e4;
    }

    function isPresale(address _tokenAddress) public view returns (bool) {
        if (presales[_tokenAddress].shiftID == 0) return false;
        return true;
    }

    function getUserPresales(address _user) external view returns (PresaleFront[] memory) {
        PresaleFront[] memory _userPresales = new PresaleFront[](userPresales[_user].length);
        for (uint256 i = 0; i < userPresales[_user].length; i++) {
            _userPresales[i] = _formatPresaleFront(userPresales[_user][i]);
        }
        return _userPresales;
    }

    function getActivePresale() external view returns (PresaleFront memory) {
        for (uint256 i = presaleAddresses.length-1; i >= 0; i--) {
            if (isActivePresale(presaleAddresses[i])) {
                return _formatPresaleFront(presaleAddresses[i]);
            }
        }
        revert("not found");
    }

    function getPastPresales() external view returns (PresaleFront[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < presaleAddresses.length; i++) {
            if (isFinishedPresale(presaleAddresses[i])) {
                count++;
            }
        }
        PresaleFront[] memory pastPresales = new PresaleFront[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < presaleAddresses.length; i++) {
            if (isFinishedPresale(presaleAddresses[i])) {
                pastPresales[counter] = _formatPresaleFront(presaleAddresses[i]);
                counter++;
            }
        }
        return pastPresales;
    }

    function getUpcomingPresales() external view returns (PresaleFront[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < presaleAddresses.length; i++) {
            if (isUpcomingPresale(presaleAddresses[i])) {
                count++;
            }
        }
        PresaleFront[] memory pastPresales = new PresaleFront[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < presaleAddresses.length; i++) {
            if (isUpcomingPresale(presaleAddresses[i])) {
                pastPresales[counter] = _formatPresaleFront(presaleAddresses[i]);
                counter++;
            }
        }
        return pastPresales;
    }
    
    function getUserTotalOfferingAmount(address _tokenAddress, address _user) public view returns (uint256) {
        if (!isSoftcapReached(_tokenAddress)) return 0;
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][_user];
        if (presale.totalAmount > presale.raisingAmount) {
            uint256 allocation = getUserPresaleAllocation(_tokenAddress, _user);
            return presale.offeringAmount.mul(allocation).div(1e6);
        } else {
            return user.amount.mul(presale.offeringAmount).div(presale.raisingAmount);
        }
    }

    function getUserTotalOfferingAvailableAmount(address _tokenAddress, address _user) public view returns (uint256) {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][_user];
        uint256 total = getUserTotalOfferingAmount(_tokenAddress, _user);
        uint256 claimed = user.claimed;
        uint256 availableGross = 
            config.calculateVestingAvaiableByAmountNow(
                shifts.shifts(presale.shiftID) + config.presaleDuration(), 
                total
            );
        if (availableGross > claimed) { 
            return availableGross - claimed;
        }
        return 0;
    }

    function getRefundingAmount(address _tokenAddress, address _user) public view returns (uint256) {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][_user];

        if (presale.launched == true) return 0;
        if (!isFinishedPresale(_tokenAddress)) return 0;
        if (!isSoftcapReached(_tokenAddress)) return user.amount;

        if (presale.totalAmount <= presale.raisingAmount) return 0;
        uint256 allocation = getUserPresaleAllocation(_tokenAddress, _user);
        uint256 payAmount = presale.raisingAmount.mul(allocation).div(1e6);
        
        return user.amount.sub(payAmount);
    }

 
    /** GENERAL FUNCTIONS **/

    function autoParticipate(
        address _tokenAddress, 
        address _user, 
        uint256 _amount
    ) external onlyAutoBuy onlyActivePresale(_tokenAddress) returns(uint256) {
        return _deposit(_tokenAddress, _user, _amount);
    }

    function deposit(address _tokenAddress, uint256 _amount) external onlyActivePresale(_tokenAddress) returns(uint256) {
        require(config.whitelist() == false || Master(operator).projectVotation().presaleUserWhitelist(_tokenAddress, msg.sender) == true, "not whitelisted");
        return _deposit(_tokenAddress, msg.sender, _amount);
    }

    function harvest(
        address _tokenAddress
    ) external nonReentrant onlyFinishedPresale(_tokenAddress) onlySoftcapReached(_tokenAddress) {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][msg.sender];

        require(user.amount > 0, "user not contributed");
        require(user.claimed < getUserTotalOfferingAmount(_tokenAddress, msg.sender), "nothing else to harvest");

        uint256 userOfferingTokenPendingAmount = getUserTotalOfferingAvailableAmount(_tokenAddress, msg.sender);

        require(userOfferingTokenPendingAmount > 0, "harvest amount is 0");

        presale.offeringToken.safeTransfer(msg.sender, userOfferingTokenPendingAmount);
        user.claimed += userOfferingTokenPendingAmount;
    }

    function refund(address _tokenAddress) external nonReentrant onlyFinishedPresale(_tokenAddress) {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][msg.sender];

        require(user.amount > 0, "user not contributed");
        require(user.refunded == false, "already refunded");
        
        uint256 refundingTokenAmount = getRefundingAmount(_tokenAddress, msg.sender);

        require(refundingTokenAmount > 0, "nothing to refund");
        
        presale.stakeToken.safeTransfer(msg.sender, refundingTokenAmount);
        
        user.refunded = true;
    }


    /** PRESALE CREATION **/

    function addPresale(
        address _tokenAddress, 
        uint256 _timestamp,
        address _owner,
        uint256 _raisingAmount,
        uint256 _offeringAmount
    ) external onlyOperator {

        uint256 _shiftID = shifts.getShiftId(_timestamp);
        Presale storage presale = presales[_tokenAddress];

        require(_shiftID > 0, "not valid shift");
        require(shifts.isAvailableShift(_shiftID) == true, "not available shift");
        require(presale.shiftID == 0, "available shift already setted");

        presale.owner = _owner;
        presale.stakeToken = config.stakeToken();
        presale.offeringToken = IERC20(_tokenAddress);
        presale.raisingAmount = _raisingAmount;
        presale.offeringAmount = _offeringAmount;
        presale.shiftID = _shiftID;

        presale.offeringToken.transferFrom(msg.sender, address(this), presale.offeringAmount);

        shifts.setShiftTaken(_shiftID, true);

        presaleAddresses.push(_tokenAddress);
    }

    function getPresaleFunds(
        address _tokenAddress
    ) public onlyOperator onlyFinishedPresale(_tokenAddress) onlySoftcapReached(_tokenAddress) returns(uint256) {

        Presale storage presale = presales[_tokenAddress];

        uint256 unsoldAmount = presale.offeringAmount - (presale.totalAmount * presale.offeringAmount / presale.raisingAmount);
        presale.offeringToken.transfer(BURN_ADDRESS, unsoldAmount);

        presale.stakeToken.transfer(operator, presale.totalAmount);

        presale.launched = true;

        return presale.totalAmount;
    }

    function getOfferingTokensIfUnlanched(
        address _tokenAddress
    ) public onlyOperator returns(uint256) {
        
        if (address(presales[_tokenAddress].offeringToken) == address(0) || isSoftcapReached(_tokenAddress)) {
            return 0;
        }

        Presale storage presale = presales[_tokenAddress];

        uint256 offeringTokenAmount = presale.offeringToken.balanceOf(address(this));
        presale.offeringToken.transfer(operator, presale.offeringToken.balanceOf(address(this)));

        return offeringTokenAmount;
    }

    function getOfferingTokensIfDeleted(address _tokenAddress) public onlyOperator returns(uint256) {
        require(isUpcomingPresale(_tokenAddress), "can't delete");

        if (address(presales[_tokenAddress].offeringToken) == address(0) || isSoftcapReached(_tokenAddress)) {
            return 0;
        }

        Presale storage presale = presales[_tokenAddress];

        uint256 offeringTokenAmount = presale.offeringToken.balanceOf(address(this));
        presale.offeringToken.transfer(operator, presale.offeringToken.balanceOf(address(this)));

        shifts.setShiftTaken(presale.shiftID, false);
        presale.owner = address(0);
        presale.shiftID = 0;

        _removeFromArray(_tokenAddress);

        return offeringTokenAmount;
    }



    /** INTERNAL **/

    function _deposit(address _tokenAddress, address _user, uint256 _amount) internal returns(uint256) {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][_user];

        require(presale.launched == false, "presale already launched");

        if (config.whitelist() == true && Master(operator).projectVotation().presaleUserWhitelist(_tokenAddress, _user) == false) {
            _amount = 0;
        }

        if (user.amount + _amount > Master(operator).masterPool().getUserPresaleAllocation(_user)) {
            _amount = Master(operator).masterPool().getUserPresaleAllocation(_user) - user.amount;
        }

        if (config.presaleOverflow() == false && _amount > presale.raisingAmount - presale.totalAmount) {
            _amount = presale.raisingAmount - presale.totalAmount;
        }
        
        presale.stakeToken.safeTransferFrom(msg.sender, address(this), _amount);
        _depositInternal(_tokenAddress, _user, _amount);

        return _amount;
    }

    function _depositInternal(address _tokenAddress, address _user, uint256 _amount) internal {
        Presale storage presale = presales[_tokenAddress];
        UserInfo storage user = userInfo[_tokenAddress][_user];
        if (user.amount == 0) {
            presale.addressList.push(_user);
            userPresales[_user].push(_tokenAddress);
            presale.contributors += 1;
        }
        user.amount = user.amount.add(_amount);
        presale.totalAmount = presale.totalAmount.add(_amount);
    }

    function _formatPresaleFront(address _tokenAddress) internal view returns (PresaleFront memory) {
        Presale memory presale = presales[_tokenAddress];
        PresaleFront memory presaleFront = PresaleFront({
            owner: presale.owner,
            shiftID: presale.shiftID,
            stakeToken: presale.stakeToken,
            offeringToken: presale.offeringToken,
            raisingAmount: presale.raisingAmount,
            offeringAmount: presale.offeringAmount,
            totalAmount: presale.totalAmount,
            startTimestamp: shifts.shifts(presale.shiftID),
            endTimestamp: shifts.shifts(presale.shiftID) + config.presaleDuration(),
            softcap: presale.raisingAmount * config.presaleSoftCapBPS() / 1e4,
            contributors: presale.contributors,
            launched: presale.launched
        });  
        return presaleFront;
    }

    function _removeFromArray(address _tokenAddress) internal {
        uint256 indexToRemove;
        for (uint256 i = 0; i < presaleAddresses.length; i++){
            if (presaleAddresses[i] == _tokenAddress) {
                indexToRemove = i;
                break;
            }
        }
        for (uint256 i = indexToRemove; i < presaleAddresses.length-1; i++){
            presaleAddresses[i] = presaleAddresses[i+1];
        }
        presaleAddresses.pop();
    }

    /** OWNER **/

    function setConfig(ProjectPresaleConfig _config) public onlyOwner {
        config = _config;
    }

    function setShifts(Shifts _shifts) public onlyOwner {
        shifts = _shifts;
    }

    function setAutoBuy(address _autoBuy) public onlyOwner {
        autoBuy = _autoBuy;
    }

    function setPresaleShiftID(address _tokenAddress, uint256 _shiftID) public onlyOwner {
        Presale storage presale = presales[_tokenAddress];
        require(presale.shiftID > 0, "can't set shift");
        require(shifts.isAvailableShift(_shiftID) == true, "invalid shiftid");

        shifts.setShiftTaken(presale.shiftID, false);
        presale.shiftID = _shiftID;
        shifts.setShiftTaken(presale.shiftID, true);
    }

    function setPresaleRaisingAmount(address _tokenAddress, uint256 _raisingAmount) public onlyOwner {
        Presale storage presale = presales[_tokenAddress];
        presale.raisingAmount = _raisingAmount;
    }

    function setPresaleOfferingAmount(address _tokenAddress, uint256 _offeringAmount) public onlyOwner {
        Presale storage presale = presales[_tokenAddress];
        presale.offeringAmount = _offeringAmount;
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Operable is Context {
    address public operator;

    constructor() {
        _transferOperable(_msgSender());
    }

    modifier onlyOperator() {
        require(
            operator == _msgSender(),
            "Operable: caller is not the operator"
        );
        _;
    }

    function transferOperable(address _newOperator) public onlyOperator {
        require(
            _newOperator != address(0),
            "Operable: new operator is the zero address"
        );

        _transferOperable(_newOperator);
    }

    function _transferOperable(address _newOperator) internal {
        operator = _newOperator;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Governable.sol";

contract ProjectPresaleConfig is Ownable, Governable {
    using SafeMath for uint256; 

    IERC20 public stakeToken;

    uint256 public minLiquidityBPS = 4000;

    uint256 public minRaisingAmount;
    uint256 public maxRaisingAmount;
    
    uint256 public presaleSoftCapBPS = 5000;

    uint256 public presaleDuration;

    uint256 public vestingDrippingDuration;
    uint256 public vestingDrippingDelay;

    bool public presaleOverflow = false;

    bool public whitelist = false;

    constructor(
        address _governor,
        IERC20 _stakeToken,
        uint256 _presaleDuration,
        uint256 _minRaisingAmount,
        uint256 _maxRaisingAmount,
        uint256 _vestingDrippingDuration,
        uint256 _vestingDrippingDelay
    ) {
        setStakeToken(_stakeToken);
        setPresaleDuration(_presaleDuration);
        setMinRaisingAmount(_minRaisingAmount);
        setMaxRaisingAmount(_maxRaisingAmount);
        setVestingDrippingDuration(_vestingDrippingDuration);
        setVestingDrippingDelay(_vestingDrippingDelay);
        transferGovernorship(_governor);
    }



    /** VIEWS **/

    function getStakeTokenDecimals() public view returns(uint256) {
        return uint256(10 ** IERC20Metadata(address(stakeToken)).decimals());
    }

    function calculateVestingAvaiableByAmountNow(uint256 endPresaleTimestamp, uint256 _total) public view returns(uint256) {
        uint256 totalAvailable = 0;
        uint256 drippingStarts = endPresaleTimestamp + vestingDrippingDelay;

        if (block.timestamp < drippingStarts) return 0;
        
        totalAvailable = _total * (block.timestamp - drippingStarts) / vestingDrippingDuration;
        
        if (totalAvailable > _total) {
            totalAvailable = _total;
        }
        
        return totalAvailable;
    }


    
    /** GOVERNANCE */

    function setPresaleDuration(uint256 _presaleDuration) public onlyGov {
        presaleDuration = _presaleDuration;
    }

    function setPresaleSoftCapBPS(uint256 _presaleSoftCapBPS) public onlyGov {
        require(_presaleSoftCapBPS <= 1e4, "invalid value");
        require(_presaleSoftCapBPS >= 0, "invalid value");
        presaleSoftCapBPS = _presaleSoftCapBPS;
    }

    function setMinRaisingAmount(uint256 _minRaisingAmount) public onlyGov {
        require(_minRaisingAmount <= maxRaisingAmount || maxRaisingAmount == 0, "invalid value");
        minRaisingAmount = _minRaisingAmount;
    }

    function setMaxRaisingAmount(uint256 _maxRaisingAmount) public onlyGov {
        require(_maxRaisingAmount >= minRaisingAmount, "invalid value");
        maxRaisingAmount = _maxRaisingAmount;
    }



    /** OWNER **/

    function setStakeToken(IERC20 _stakeToken) public onlyOwner {
        stakeToken = _stakeToken;
    }

    function setPresaleOverflow(bool _presaleOverflow) public onlyOwner {
        presaleOverflow = _presaleOverflow;
    }

    function setVestingDrippingDuration(uint256 _vestingDrippingDuration) public onlyOwner {
        require(_vestingDrippingDuration <= 30 days, "invalid value");
        require(_vestingDrippingDuration >= 0, "invalid value");
        vestingDrippingDuration = _vestingDrippingDuration;
    }

    function setVestingDrippingDelay(uint256 _vestingDrippingDelay) public onlyOwner {
        require(_vestingDrippingDelay <= 30 days, "invalid value");
        require(_vestingDrippingDelay >= 0, "invalid value");
        vestingDrippingDelay = _vestingDrippingDelay;
    }

    function setWhitelist(bool _value) public onlyOwner {
        whitelist = _value;
    }



    /** INTERNAL **/

    function _getSum(uint256[] memory _arr) internal pure returns(uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < _arr.length; i++) {
            sum = sum + _arr[i];
        }
        return sum;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";

contract Shifts is Ownable, Operable {
    using SafeMath for uint256; 

    uint256 public fromTimestamp;
    uint256 public toTimestamp;
    
    uint256[] public shifts;
    mapping(uint256 => bool) public shiftTaken;

    constructor(
        address _operator,
        uint256 _fromTimestamp,
        uint256 _toTimestamp,
        uint256[] memory _shifts
    ) {
        setFromTimestamp(_fromTimestamp);
        setToTimestamp(_toTimestamp);
        shifts.push(0);
        addShifts(_shifts);

        transferOperable(_operator);
    }


    /** VIEWS */

    function getAvailableShifts() public view returns(uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < shifts.length; i++) {
            if (isAvailableShift(i)) {
                count++;
            }
        }
        uint256[] memory _availableShifts = new uint256[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < shifts.length; i++) {
            if (isAvailableShift(i)) {
                _availableShifts[counter] = shifts[i];
                counter++;
            }
        }
        return _availableShifts;
    }

    function isAvailableShift(uint256 _id) public view returns (bool) {
        return (_isAvailableTimestamp(shifts[_id]) == true && shiftTaken[_id] == false);
    }

    function getShiftId(uint256 _timestamp) public view returns (uint256) {
        for (uint256 i = 0; i < shifts.length; i++) {
            if (shifts[i] == _timestamp) {
                return i;
            }
        }
        return 0;
    }



    /** INTERNAL **/

    function _isAvailableTimestamp(uint256 _timestamp) internal view returns (bool) {
        return (_timestamp >= block.timestamp + fromTimestamp && _timestamp <= block.timestamp + toTimestamp);
    }



    /** OPERATOR **/

    function setShiftTaken(uint256 _id, bool value) public onlyOperator {
        shiftTaken[_id] = value;
    }



    /** OWNER */

    function addShifts(uint256[] memory _shifts) public onlyOwner {
        for (uint256 i = 0; i < _shifts.length; i++) {
            shifts.push(_shifts[i]);
        }
    }

    function setShiftTimestamp(uint256 _id, uint256 _timestamp) public onlyOwner {
        shifts[_id] = _timestamp;
    }

    function setShiftsTimestamp(uint256[] memory _id, uint256[] memory _timestamp) public onlyOwner {
        require(_id.length == _timestamp.length, "bad length");
        for (uint256 i = 0; i < _id.length; i++) {
            shifts[_id[i]] = _timestamp[i];
        }
    }

    function setFromTimestamp(uint256 _fromTimestamp) public onlyOwner {
        fromTimestamp = _fromTimestamp;
    }

    function setToTimestamp(uint256 _toTimestamp) public onlyOwner {
        toTimestamp = _toTimestamp;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./access/Operable.sol";

contract ProjectManager is Ownable, Operable {
    
    struct Project {
        address owner;
        string name;
        string slogan;
        string shortDescription;
        string description;
        string[] images;
        string[] socialLinks;
        string auditLink;
        string docsLink;
        string website;
        string videoLink;
        string roadmap;
        string roadmapLink;
        string tokenomics;
        string tokenomicsLink;
    }

    struct Auditor {
        address auditor;
        string name;
        string image;
    }

    struct Data {
        address auditor;
        string link;
        string comments;
        bool done;
        string name;
        string image;
    }

    struct All {
        Project project;
        Data[] audits;
        Data[] quickReviews;
        Data[] kycs;
        string tokenSymbol;
        string tokenName;
        uint8 decimals;
        uint256 totalSupply;
    }

    mapping(address => Project) public projects;

    mapping(address => address[]) public ownerToTokenAddress;

    mapping(string => address) public slugToTokenAddress;

    Auditor[] public auditors;

    mapping(address => Data[]) public projectAudits;
    mapping(address => Data[]) public projectQuickReviews;
    mapping(address => Data[]) public projectKYC;

    constructor(address _operator) {
        transferOperable(_operator);
    }

    modifier onlyProjectOwner(address _tokenAddress) {
        require(
            msg.sender == projects[_tokenAddress].owner || msg.sender == owner(),
            "not project owner"
        );
        _;
    }

    modifier onlyAuditors() {
        require(_getAuditorIndex(msg.sender) < type(uint256).max);
        _;
    }



    /** VIEWS **/

    function getAuditorByAddress(address _auditor) public view returns (Auditor memory) {
        return auditors[_getAuditorIndex(_auditor)];
    }

    function getProject(address _tokenAddress) public view returns(Project memory) {
        return projects[_tokenAddress];
    }

    function getAll(address _tokenAddress) public view returns(All memory) {
        return All({
            project: projects[_tokenAddress],
            audits: projectAudits[_tokenAddress],
            quickReviews: projectQuickReviews[_tokenAddress],
            kycs: projectKYC[_tokenAddress],
            tokenSymbol: IERC20Metadata(_tokenAddress).symbol(),
            tokenName: IERC20Metadata(_tokenAddress).name(),
            decimals: IERC20Metadata(_tokenAddress).decimals(),
            totalSupply: IERC20Metadata(_tokenAddress).totalSupply()
        });
    }

    function getProjectsByOwner(address _owner) public view returns(address[] memory) {
        return ownerToTokenAddress[_owner];
    }

    function isSlug(string memory _slug) public view returns(bool) {
        return slugToTokenAddress[_slug] != address(0);
    }



    /** OWNER **/

    function addAuditor(Auditor memory _auditor) public onlyOwner {
        require(_getAuditorIndex(_auditor.auditor) == type(uint256).max);
        auditors.push(_auditor);
    }

    function removeAuditor(address _auditor) public onlyOwner {
        auditors[_getAuditorIndex(_auditor)] = auditors[auditors.length - 1];
        auditors.pop();
    }

    function setProject(address _tokenAddress, Project memory _project) public onlyOwner {
        projects[_tokenAddress] = _project;
    }

    function setProjectSlug(address _tokenAddress, string memory _slug) public onlyOwner {
        slugToTokenAddress[_slug] = _tokenAddress;
    }


    /** AUDITORS **/

    function setAuditorAuditLink(
        address _tokenAddress, 
        string memory _auditLink, 
        string memory _comments, 
        bool _done
    ) public onlyAuditors {
        uint256 index = 1e18;
        for (uint256 i = 0; i < projectAudits[_tokenAddress].length; i++) {
            if (projectAudits[_tokenAddress][i].auditor == msg.sender) {
                index = i;
            }
        }
        Data memory audit = Data({
            auditor: msg.sender,
            link: _auditLink,
            comments: _comments,
            done: _done,
            image: auditors[_getAuditorIndex(msg.sender)].image,
            name: auditors[_getAuditorIndex(msg.sender)].name
        });
        if (index == 1e18) {
            projectAudits[_tokenAddress].push(audit);
        } else {
            projectAudits[_tokenAddress][index] = audit;
        }
    }

    function setAuditorQuickReview(
        address _tokenAddress, 
        string memory _auditLink, 
        string memory _comments, 
        bool _done
    ) public onlyAuditors {
        uint256 index = 1e18;
        for (uint256 i = 0; i < projectQuickReviews[_tokenAddress].length; i++) {
            if (projectQuickReviews[_tokenAddress][i].auditor == msg.sender) {
                index = i;
            }
        }
        Data memory quickReview = Data({
            auditor: msg.sender,
            link: _auditLink,
            comments: _comments,
            done: _done,
            image: auditors[_getAuditorIndex(msg.sender)].image,
            name: auditors[_getAuditorIndex(msg.sender)].name
        });
        if (index == 1e18) {
            projectQuickReviews[_tokenAddress].push(quickReview);
        } else {
            projectQuickReviews[_tokenAddress][index] = quickReview;
        }
    }

    function setAuditorKYC(
        address _tokenAddress, 
        string memory _auditLink, 
        string memory _comments, 
        bool _done
    ) public onlyAuditors {
        uint256 index = 1e18;
        for (uint256 i = 0; i < projectKYC[_tokenAddress].length; i++) {
            if (projectKYC[_tokenAddress][i].auditor == msg.sender) {
                index = i;
            }
        }
        Data memory kyc = Data({
            auditor: msg.sender,
            link: _auditLink,
            comments: _comments,
            done: _done,
            image: auditors[_getAuditorIndex(msg.sender)].image,
            name: auditors[_getAuditorIndex(msg.sender)].name
        });
        if (index == 1e18) {
            projectKYC[_tokenAddress].push(kyc);
        } else {
            projectKYC[_tokenAddress][index] = kyc;
        }
    }



    /** OPERATOR **/

    function addProject(address _tokenAddress, Project memory _project, string memory _slug) public onlyOperator {
        _addProject(_tokenAddress, _project, _slug);
    }

    function removeProject(address _tokenAddress) public onlyOperator {
        _removeProject(_tokenAddress);
    }

    function setProjectOwner(address _tokenAddress, address _owner) public onlyOperator {
        projects[_tokenAddress].owner = _owner;
    }
    


    /** ONLY PROJECT OWNER **/

    function setProjectSlogan(address _tokenAddress, string memory _slogan) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_slogan).length >= 20 && bytes(_slogan).length <= 100);
        projects[_tokenAddress].slogan = _slogan;
    }

    function setProjectDescription(address _tokenAddress, string memory _description) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_description).length >= 20 && bytes(_description).length <= 100);
        projects[_tokenAddress].description = _description;
    }

    function setProjectShortDescription(address _tokenAddress, string memory _shortDescription) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_shortDescription).length >= 20 && bytes(_shortDescription).length <= 100);
        projects[_tokenAddress].shortDescription = _shortDescription;
    }

    function setProjectImage(address _tokenAddress, uint256 _index, string memory _image) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].images[_index] = _image;
    }

    function setProjectImages(address _tokenAddress, string[] memory _images) public onlyProjectOwner(_tokenAddress) {
        require(_images.length >= 3, "imgs");
        projects[_tokenAddress].images = _images;
    }

    function setProjectSocialLinks(address _tokenAddress, string[] memory _socialLinks) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].socialLinks = _socialLinks;
    }

    function setProjectAuditLink(address _tokenAddress, string memory _auditLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].auditLink = _auditLink;
    }

    function setProjectDocsLink(address _tokenAddress, string memory _docsLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].docsLink = _docsLink;
    }

    function setProjectWebsite(address _tokenAddress, string memory _website) public onlyProjectOwner(_tokenAddress) {
        require(bytes(_website).length > 15);
        projects[_tokenAddress].website = _website;
    }

    function setProjectVideoLink(address _tokenAddress, string memory _videoLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].videoLink = _videoLink;
    }

    function setProjectRoadmap(address _tokenAddress, string memory _roadmap) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].roadmap = _roadmap;
    }

    function setProjectRoadmapLink(address _tokenAddress, string memory _roadmapLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].roadmapLink = _roadmapLink;
    }

    function setProjectTokenomics(address _tokenAddress, string memory _tokenomics) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].tokenomics = _tokenomics;
    }

    function setProjectTokenomicsLink(address _tokenAddress, string memory _tokenomicsLink) public onlyProjectOwner(_tokenAddress) {
        projects[_tokenAddress].tokenomicsLink = _tokenomicsLink;
    }


    /** INTERNAL **/

    function _addProject(address _tokenAddress, Project memory _project, string memory _slug) internal {
        require(bytes(_project.name).length >= 3 && bytes(_project.name).length <= 50, "name");
        require(bytes(_project.slogan).length >= 20 && bytes(_project.slogan).length <= 100, "slogan");
        require(bytes(_project.shortDescription).length >= 20 && bytes(_project.shortDescription).length <= 100, "short");
        require(bytes(_project.description).length >= 20 && bytes(_project.description).length <= 100, "descript");
        require(bytes(_project.website).length > 15, "website");
        require(_project.socialLinks.length >= 2, "socials");
        require(_project.images.length >= 3, "imgs");
        require(bytes(_slug).length > 0 && slugToTokenAddress[_slug] == address(0), "slug");

        projects[_tokenAddress] = _project;

        if (address(_project.owner) != address(0)) {
            ownerToTokenAddress[_project.owner].push(_tokenAddress);
        }
        slugToTokenAddress[_slug] = _tokenAddress;
    }

    function _removeProject(address _tokenAddress) internal {
        projects[_tokenAddress].owner = address(0);
    }



    /** INTERNAL **/ 

    function _getAuditorIndex(address _auditor) internal view returns(uint256) {
        for(uint256 i = 0; i < auditors.length; i++) {
            if (address(auditors[i].auditor) == address(_auditor)) {
                return i;
            }
        }
        return type(uint256).max;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";
import "./access/Governable.sol";

contract ProjectVotation is Ownable, Operable, Governable {
    using SafeMath for uint256; 
    
    struct Votation {
        address tokenAddress;
        uint256 yes;
        uint256 no;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    struct UserVote {
        bool vote;
        uint256 yes;
        uint256 no;
    }

    enum Status { PENDING, ACTIVE, PASSED, REJECTED, NOQUORUM }

    mapping(address => mapping(address => UserVote)) public userVotes;

    mapping(address => Votation) public votations;
    address[] public votationAddresses;

    mapping(address => mapping(address => bool)) public presaleUserWhitelist;
    mapping(address => uint256) public presaleWhitelistQuantity;

    IERC20 public syrupToken;

    uint256 public minQuorumBPS;
    uint256 public constant MIN_MIN_QUORUM_BPS = 0;
    uint256 public constant MAX_MIN_QUORUM_BPS = 10000;

    uint256 public votingDuration;
    uint256 public constant MIN_VOTING_DURATION = 1 hours;
    uint256 public constant MAX_VOTING_DURATION = 15 days;

    uint256 public launchTimestamp;

    constructor(
        address _operator, 
        address _governor,
        uint256 _votingDuration, 
        uint256 _minQuorumBPS, 
        IERC20 _syrupToken,
        uint256 _launchTimestamp
    ) {
        setVotingDuration(_votingDuration);
        setSyrupToken(_syrupToken);
        setMinQuorumBPS(_minQuorumBPS);
        setLaunchTimestamp(_launchTimestamp);
        transferOperable(_operator);
        transferGovernorship(_governor);
    }

    modifier onlyHolders() {
        require(syrupToken.balanceOf(msg.sender) > 0, "no voting power");
        _;
    }

    modifier onlyActiveVotation(address _tokenAddress) {
        require(
            _isActiveVotation(_tokenAddress), 
            "not active votation"
        );
        _;
    }


    /** VIEWS **/

    function getVotation(address _tokenAddress) public view returns(Votation memory) {
        return votations[_tokenAddress];
    }

    function getStatus(address _tokenAddress) public view returns(Status) {
        if (!_exists(_tokenAddress)) {
            return Status.PASSED;
        }
        if (_isFinishedVotation(_tokenAddress)) {
            if (_hasQuorum(_tokenAddress)) {
                if (votations[_tokenAddress].yes > votations[_tokenAddress].no) {
                    return Status.PASSED;
                } else {
                    return Status.REJECTED;
                }
            } else {
                return Status.NOQUORUM;
            }
        }
        if (_isActiveVotation(_tokenAddress)) {
            return Status.ACTIVE;
        }
        return Status.PENDING;
    }

    function isPassed(address _tokenAddress) public view returns(bool) {
        return getStatus(_tokenAddress) == Status.PASSED;
    }

    function getAllVotations() public view returns(Votation[] memory) {
        Votation[] memory allVotations = new Votation[](votationAddresses.length);
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            allVotations[i] = votations[votationAddresses[i]];
        }
        return allVotations;
    }

    function getActiveVotations() public view returns(Votation[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (_isActiveVotation(votationAddresses[i])) {
                count++;
            }
        }
        Votation[] memory activeVotations = new Votation[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (_isActiveVotation(votationAddresses[i])) {
                activeVotations[counter] = votations[votationAddresses[i]];
                counter++;
            }
        }
        return activeVotations;
    }

    function getOldVotations() public view returns(Votation[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (!_isActiveVotation(votationAddresses[i])) {
                count++;
            }
        }
        Votation[] memory oldVotations = new Votation[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < votationAddresses.length; i++) {
            if (!_isActiveVotation(votationAddresses[i])) {
                oldVotations[counter] = votations[votationAddresses[i]];
                counter++;
            }
        }
        return oldVotations;
    }

    function isUserBlocked(address _user) public view returns(bool) {
        Votation[] memory activeVotations = getActiveVotations();
        for (uint256 i = 0; i < activeVotations.length; i++) {
            if (userVotes[activeVotations[i].tokenAddress][_user].vote == true) {
                return true;
            }
        }
        return false;
    }

    function getMinQuorum() public view returns(uint256) {
        return syrupToken.totalSupply() * minQuorumBPS / 1e4;
    }



    /** HOLDERS **/

    function vote(address _tokenAddress, bool _vote) public onlyHolders onlyActiveVotation(_tokenAddress) {
        unvote(_tokenAddress);
        uint256 votationPower = syrupToken.balanceOf(msg.sender);
        votations[_tokenAddress].yes += _vote == true ? votationPower : 0;
        votations[_tokenAddress].no += _vote == true ? 0 : votationPower;
        userVotes[_tokenAddress][msg.sender] = UserVote({
            vote: true,
            yes: _vote == true ? votationPower : 0,
            no: _vote == true ? 0 : votationPower
        });
        presaleUserWhitelist[_tokenAddress][msg.sender] = true;
        presaleWhitelistQuantity[_tokenAddress]++;
    }

    function unvote(address _tokenAddress) public onlyHolders onlyActiveVotation(_tokenAddress) {
        votations[_tokenAddress].yes -= userVotes[_tokenAddress][msg.sender].yes;
        votations[_tokenAddress].no -= userVotes[_tokenAddress][msg.sender].no;
        userVotes[_tokenAddress][msg.sender] = UserVote({
            vote: false,
            yes: 0,
            no: 0
        });
        if (presaleUserWhitelist[_tokenAddress][msg.sender] == true) presaleWhitelistQuantity[_tokenAddress]--;
        presaleUserWhitelist[_tokenAddress][msg.sender] = false;
    }



    /** GOVERNANCE **/

    function setVotingDuration(uint256 _votingDuration) public onlyGov {
        require(_votingDuration >= MIN_VOTING_DURATION, "invalid value");
        require(_votingDuration <= MAX_VOTING_DURATION, "invalid value");
        votingDuration = _votingDuration;
    }

    function setMinQuorumBPS(uint256 _minQuorumBPS) public onlyGov {
        require(_minQuorumBPS >= MIN_MIN_QUORUM_BPS, "invalid value");
        require(_minQuorumBPS <= MAX_MIN_QUORUM_BPS, "invalid value");
        minQuorumBPS = _minQuorumBPS;
    }



    /** OWNER **/

    function setSyrupToken(IERC20 _syrupToken) public onlyOwner {
        require(_syrupToken.totalSupply() >= 0, "not a token");
        require(_syrupToken.balanceOf(address(this)) >= 0, "not a token");
        syrupToken = _syrupToken;
    }

    function setLaunchTimestamp(uint256 _launchTimestamp) public onlyOwner {
        launchTimestamp = _launchTimestamp;
    }



    /** OPERATOR **/

    function addVotation(address _tokenAddress) public onlyOperator {
        Votation storage votation = votations[_tokenAddress];
        votation.tokenAddress = _tokenAddress;
        votation.startTimestamp = block.timestamp < launchTimestamp ? launchTimestamp : block.timestamp;
        votation.endTimestamp = votation.startTimestamp + votingDuration;
        votationAddresses.push(_tokenAddress);
    }

    function removeVotation(address _tokenAddress) public onlyOperator {
        Votation storage votation = votations[_tokenAddress];
        votation.tokenAddress = address(0);
        votation.startTimestamp = 0;
        votation.endTimestamp = 0;
        votation.yes = 0;
        votation.no = 0;

        _removeFromArray(_tokenAddress);
    }



    /** INTERNAL **/

    function _removeFromArray(address _tokenAddress) internal {
        uint256 indexToRemove;
        for (uint256 i = 0; i < votationAddresses.length; i++){
            if (votationAddresses[i] == _tokenAddress) {
                indexToRemove = i;
                break;
            }
        }
        for (uint256 i = indexToRemove; i < votationAddresses.length-1; i++){
            votationAddresses[i] = votationAddresses[i+1];
        }
        votationAddresses.pop();
    }

    function _isActiveVotation(address _tokenAddress) internal view returns(bool) {
        return 
            block.timestamp >= votations[_tokenAddress].startTimestamp &&
            block.timestamp <= votations[_tokenAddress].endTimestamp;
    }

    function _isFinishedVotation(address _tokenAddress) internal view returns(bool) {
        return block.timestamp > votations[_tokenAddress].endTimestamp;
    }

    function _hasQuorum(address _tokenAddress) internal view returns(bool) {
        return votations[_tokenAddress].yes + votations[_tokenAddress].no >= getMinQuorum();
    }

    function _exists(address _tokenAddress) internal view returns(bool) {
        return votations[_tokenAddress].tokenAddress == _tokenAddress;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IPair.sol";
import "./Master.sol";
import "./ProjectPresale.sol";

contract ProjectLaunch is Ownable, Operable {
    using SafeMath for uint256; 
    
    struct Launch {
        IERC20 tokenAddress;
        IERC20 currencyAddress;
        IRouter routerAddress;
        uint256 launchPrice;
        bool launched;
        IPair lpAddress;
    }

    struct Router {
        IRouter routerAddress;
        string name;
        string image;
        uint256 priority;
    }

    mapping(address => Launch) public launches;
    address[] public launchAddresses;

    Router[] public routers;

    constructor(address _operator) {
        transferOperable(_operator);
    }

    /** VIEWS **/

    function getRouters() public view returns(Router[] memory) {
        return routers;
    }

    function getLaunch(address _tokenAddress) public view returns(Launch memory) {
        return launches[_tokenAddress];
    }



    /** OWNER **/

    function addRouter(Router memory _router) public onlyOwner {
        require(_existsRouterAddress(_router.routerAddress) == false, "router already exists");
        routers.push(_router);
    }

    function removeRouter(uint256 _index) public onlyOwner {
        for (uint256 i = _index; i < routers.length-1; i++){
            routers[i] = routers[i+1];
        }
        routers.pop();
    }

    /** 
    @dev this contract should not contain any tokens. 
    In case of trying to add liquidity to an already 
    liquid project there might be a price difference. 
    That difference left on this contract will be given 
    back to the project owner.
    */
    function emergencyWithdraw(IERC20 _token, uint256 _amount) public onlyOwner {
        _token.transfer(msg.sender, _amount);
    }



    /** OPERATOR **/

    function addLaunch(
        address _tokenAddress, 
        address _routerAddress, 
        uint256 _launchPrice
    ) public onlyOperator {
        require(launches[address(_tokenAddress)].launched == false, "token already launched");
        require(address(launches[address(_tokenAddress)].routerAddress) == address(0), "launch already exists");
        require(_existsRouterAddress(IRouter(_routerAddress)) == true, "wrong router address");
        
        Launch storage launch = launches[address(_tokenAddress)];
        launch.tokenAddress = IERC20(_tokenAddress);
        launch.currencyAddress = IERC20(Master(operator).projectPresale().config().stakeToken());
        launch.routerAddress = IRouter(_routerAddress);
        launch.launchPrice = _launchPrice;
        launch.launched = false;
    }

    function launchProject(address _tokenAddress) public onlyOperator returns(address, uint256, uint256) {
        require(launches[_tokenAddress].launched == false, "token already launched");
        require(address(launches[_tokenAddress].routerAddress) != address(0), "launch doesn't exist");

        ProjectPresale.Presale memory presale = Master(operator).projectPresale().getPresale(_tokenAddress);
        Master.Client memory client = Master(operator).getClient(_tokenAddress);

        uint256 _decimals = IERC20Metadata(_tokenAddress).decimals();
        uint256 currencyAmount = presale.totalAmount * client.liquidityBPS / 1e4;
        uint256 tokenAmount = 
            currencyAmount * Master(operator).projectPresale().config().getStakeTokenDecimals() / launches[_tokenAddress].launchPrice
            * (10 ** _decimals) / Master(operator).projectPresale().config().getStakeTokenDecimals();
        
        launches[_tokenAddress].tokenAddress.transferFrom(address(operator), address(this), tokenAmount);
        launches[_tokenAddress].currencyAddress.transferFrom(address(operator), address(this), currencyAmount);
        

        launches[_tokenAddress].tokenAddress.approve(address(launches[_tokenAddress].routerAddress), tokenAmount);
        launches[_tokenAddress].currencyAddress.approve(address(launches[_tokenAddress].routerAddress), currencyAmount);
        launches[_tokenAddress].routerAddress.addLiquidity(
            address(launches[_tokenAddress].tokenAddress),
            address(launches[_tokenAddress].currencyAddress),
            tokenAmount,
            currencyAmount,
            0,
            0,
            address(this),
            block.timestamp + 300
        );

        address lpAddress = IFactory(launches[_tokenAddress].routerAddress.factory()).getPair(
            address(launches[_tokenAddress].tokenAddress),
            address(launches[_tokenAddress].currencyAddress)
        );
        IPair(lpAddress).transfer(operator, IPair(lpAddress).balanceOf(address(this)));

        launches[_tokenAddress].lpAddress = IPair(lpAddress);
        launches[_tokenAddress].launched = true;

        return (lpAddress, currencyAmount, tokenAmount);
    }



    /** INTERNAL **/

    function _existsRouterAddress(IRouter _routerAddress) internal view returns (bool) {
        for (uint256 i = 0; i < routers.length; i++) {
            if (routers[i].routerAddress == _routerAddress) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./access/Operable.sol";
import "./access/Governable.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IPair.sol";

contract ProjectVesting is Ownable, Operable, Governable {
    using SafeMath for uint256; 
    
    struct Vesting {
        address beneficiary;
        IERC20 tokenAddress;
        uint256 totalAmount;
        uint256 startTimestamp;
        uint256[] tokenReleaseTimestamps;
        uint256[] tokenReleaseAmounts;
        uint256 amountClaimed;
        bool isDeleted;
    }

    uint256[] public stakeTokenReleasePeriods;
    uint256[] public stakeTokenReleaseAmountsBPS;

    mapping(address => Vesting[]) public vestings;

    uint256 public lockLiquidityVestingPeriod;

    address public securityFund;

    uint256 public lockFee;
    address payable public feeAddress;

    constructor(
        address _operator,
        address _governor,
        uint256[] memory _stakeTokenReleasePeriods,
        uint256[] memory _stakeTokenReleaseAmountsBPS,
        uint256 _lockLiquidityVestingPeriod,
        address _securityFund,
        uint256 _lockFee,
        address payable _feeAddress
    ) {
        securityFund = _securityFund;
        setStakeTokenVestingPeriods(_stakeTokenReleasePeriods, _stakeTokenReleaseAmountsBPS);
        setLockLiquidityVestingPeriod(_lockLiquidityVestingPeriod);
        transferOperable(_operator);
        transferGovernorship(_governor);
        setLockFee(_lockFee);
        setFeeAddress(_feeAddress);
    }

    modifier onlyBeneficiary(uint256 _index) {
        Vesting storage vesting = vestings[msg.sender][_index];
        require(vesting.beneficiary == msg.sender, "not beneficiary");
        _;
    }

    modifier onlySecurityFund() {
        require(securityFund == msg.sender, "not security fund");
        _;
    }



    /** GENERAL FUNCTIONS **/

    function addVesting(
        address _beneficiary, 
        address _tokenAddress, 
        uint256 _totalAmount, 
        uint256[] memory _tokenReleasePeriods,
        uint256[] memory _tokenReleaseAmountsBPS
    ) payable public {

        require(_beneficiary != address(0), "beneficiary cannot be 0");
        require(_tokenAddress != address(0), "token address cannot be 0");
        if (_totalAmount == 0) return;

        if (msg.sender != operator) {
            require(msg.value >= lockFee, "not enough value for fee");
            Address.sendValue(feeAddress, msg.value);
        }

        uint256 startTimestamp = block.timestamp;
        uint256[] memory tokenReleaseTimestamps = new uint256[](_tokenReleasePeriods.length);
        uint256[] memory tokenReleaseAmounts = new uint256[](_tokenReleaseAmountsBPS.length);
        
        for (uint256 i = 0; i < _tokenReleaseAmountsBPS.length; i++) {
            tokenReleaseTimestamps[i] = startTimestamp + _tokenReleasePeriods[i];
            tokenReleaseAmounts[i] = _totalAmount * _tokenReleaseAmountsBPS[i] / 1e4;
        }
        
        vestings[_beneficiary].push(Vesting({
            beneficiary: _beneficiary,
            tokenAddress: IERC20(_tokenAddress),
            totalAmount: _totalAmount,
            startTimestamp: startTimestamp,
            tokenReleaseTimestamps: tokenReleaseTimestamps,
            tokenReleaseAmounts: tokenReleaseAmounts,
            amountClaimed: 0,
            isDeleted: false
        }));

        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _totalAmount);
    }


    /** VIEWS **/

    function getStakeTokenReleasePeriods() public view returns(uint256[] memory) {
        return stakeTokenReleasePeriods;
    }

    function getStakeTokenReleaseAmountsBPS() public view returns(uint256[] memory) {
        return stakeTokenReleaseAmountsBPS;
    }

    function getUserVestings(address _beneficiary) public view returns(Vesting[] memory) {
        return vestings[_beneficiary];
    }

    function getNotReleasedAmount(address _beneficiary, uint256 _index) public view returns(uint256) {
        uint256 notReleasedAmount = 0;
        Vesting storage vesting = vestings[_beneficiary][_index];
        if (vesting.isDeleted == true) {
            return 0;
        }
        for (uint256 i = 0; i < vesting.tokenReleaseTimestamps.length; i++) {
            if (vesting.tokenReleaseTimestamps[i] > block.timestamp) {
                notReleasedAmount += vesting.tokenReleaseAmounts[i];
            }
        }
        return notReleasedAmount - vesting.amountClaimed;
    }

    function getAvailableToClaim(address _beneficiary, uint256 _index) public view returns(uint256) {
        uint256 totalAvailable = 0;
        Vesting storage vesting = vestings[_beneficiary][_index];
        if (vesting.isDeleted == true) {
            return 0;
        }
        for (uint256 i = 0; i < vesting.tokenReleaseTimestamps.length; i++) {
            if (vesting.tokenReleaseTimestamps[i] <= block.timestamp) {
                totalAvailable += vesting.tokenReleaseAmounts[i];
            }
        }
        return totalAvailable - vesting.amountClaimed;
    }



    /** GOVERNANCE **/

    function setLockLiquidityVestingPeriod(uint256 _lockLiquidityVestingPeriod) public onlyGov {
        lockLiquidityVestingPeriod = _lockLiquidityVestingPeriod;
    }



    /** OWNER **/

    function setStakeTokenVestingPeriods(uint256[] memory _stakeTokenReleasePeriods, uint256[] memory _stakeTokenReleaseAmountsBPS) public onlyOwner {
        uint256 sumOfBPS = 0;
        for (uint256 i = 0; i < _stakeTokenReleaseAmountsBPS.length; i++) {
            sumOfBPS += _stakeTokenReleaseAmountsBPS[i];
        }
        require(sumOfBPS == 1e4, "wrong vesting amount bps");
        require(_stakeTokenReleasePeriods.length == _stakeTokenReleaseAmountsBPS.length, "wrong arrays length");
        stakeTokenReleasePeriods = _stakeTokenReleasePeriods;
        stakeTokenReleaseAmountsBPS = _stakeTokenReleaseAmountsBPS;
    }

    function release(address _beneficiary, uint256 _index, uint256 _amount) public onlyOwner {
        require(_amount <= getNotReleasedAmount(_beneficiary, _index), "bad _amount");
        Vesting storage vesting = vestings[_beneficiary][_index];
        vesting.tokenReleaseAmounts.push(_amount);
        vesting.tokenReleaseTimestamps.push(block.timestamp);
        for (uint256 i = 0; i < vesting.tokenReleaseAmounts.length; i++) {
            if (vesting.tokenReleaseTimestamps[i] > block.timestamp) {
                uint256 originalAmount = vesting.tokenReleaseAmounts[i];
                vesting.tokenReleaseAmounts[i] -= _min(_amount, originalAmount);
                _amount -= _min(_amount, originalAmount);
            }
        }
    }

    function setLockFee(uint256 _lockFee) public onlyOwner {
        lockFee = _lockFee;
    }

    function setFeeAddress(address payable _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }


    /** SECURITY FUND **/

    function releaseToSecurityFund(address _beneficiary, address _tokenAddress) public onlySecurityFund {
        uint256 _index = type(uint256).max;
        for(uint256 i = 0; i < vestings[_beneficiary].length; i++) {
            if (address(vestings[_beneficiary][i].tokenAddress) == _tokenAddress) {
                _index = i;
            }
        }

        if (_index == type(uint256).max) return;

        Vesting storage vesting = vestings[_beneficiary][_index];
        uint256 totalPendingAmount = vesting.totalAmount - vesting.amountClaimed;
        
        vesting.tokenAddress.transfer(securityFund, totalPendingAmount);

        _deleteVesting(_beneficiary, _index, false);
    }



    /** BENEFICIARY **/

    function claim(uint256 _index) public onlyBeneficiary(_index) {
        Vesting storage vesting = vestings[msg.sender][_index];
        uint256 availableToClaim = getAvailableToClaim(msg.sender, _index);
        vesting.amountClaimed += availableToClaim;
        vesting.tokenAddress.transfer(vesting.beneficiary, availableToClaim);
    }



    /** OPERATOR **/

    function deleteAllUserVestings(address _beneficiary) public onlyOperator {
        for (uint256 i = 0; i < vestings[_beneficiary].length; i++) {
            _deleteVesting(_beneficiary, i, true);
        }
    }

    function deleteVestingByTokenAddress(address _beneficiary, address _tokenAddress) public onlyOperator {
        _deleteVestingByTokenAddress(_beneficiary, _tokenAddress);
    }

    function deleteVesting(address _beneficiary, uint256 _index) public onlyOperator {
        _deleteVesting(_beneficiary, _index, true);
    }



    /** INTERNAL **/

    function _deleteVesting(address _beneficiary, uint256 _index, bool _transfer) internal {
        Vesting storage vesting = vestings[_beneficiary][_index];
        if (vesting.isDeleted) return;
        uint256 totalPendingAmount = vesting.totalAmount - vesting.amountClaimed;
        if (_transfer) {
            vesting.tokenAddress.transfer(_beneficiary, totalPendingAmount);
        }
        vesting.totalAmount = 0;
        vesting.amountClaimed = 0;
        vesting.isDeleted = true;
    }

    function _deleteVestingByTokenAddress(address _beneficiary, address _tokenAddress) internal {
        for (uint256 i = 0; i < vestings[_beneficiary].length; i++) {
            if (address(vestings[_beneficiary][i].tokenAddress) == address(_tokenAddress)) {
                _deleteVesting(_beneficiary, i, true);
            }
        }
    }

    function _min(uint256 a, uint256 b) public pure returns(uint256) {
        if (a < b) return a;
        return b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Governable.sol";
import "./access/Operable.sol";
import "./Master.sol";
import "./ProjectPresale.sol";
import "./ProjectLaunch.sol";
import "./ProjectVesting.sol";

contract SecurityFund is Ownable, Governable, Operable, ReentrancyGuard {
    using SafeMath for uint256; 

    struct Refund {
        address tokenAddress;
        uint256 timestamp;
        address[] addressList;
        uint256 totalRefundAmount;
        bool refunded;
    }

    IERC20 public currencyAddress;

    uint256 public maxRefundPerPresaleBPS;
    uint256 public presaleCaducity;

    mapping(address => Refund) public refunds;

    constructor(
        address _operator, 
        address _governor,
        IERC20 _currencyAddress, 
        uint256 _maxRefundPerPresaleBPS,
        uint256 _presaleCaducity
    ) {
        currencyAddress = _currencyAddress;
        setMaxRefundPerPresaleBPS(_maxRefundPerPresaleBPS);
        setPresaleCaducity(_presaleCaducity);
        transferOperable(_operator);
        transferGovernorship(_governor);
    }



    /** VIEWS **/

    function getTotalAmount() public view returns(uint256) {
        return currencyAddress.balanceOf(address(this));
    }



    /** OWNER **/

    function emergencyWithdraw(IERC20 _token, uint256 _amount) public onlyOwner {
        _token.transfer(msg.sender, _amount);
    }
    
    function setMaxRefundPerPresaleBPS(uint256 _maxRefundPerPresaleBPS) public onlyOwner {
        require(_maxRefundPerPresaleBPS <= 1e4, "invalid value");
        maxRefundPerPresaleBPS = _maxRefundPerPresaleBPS;
    }
    
    function setPresaleCaducity(uint256 _presaleCaducity) public onlyOwner {
        require(_presaleCaducity >= 15 days, "invalid value");
        presaleCaducity = _presaleCaducity;
    }



    /** GOVERNANCE **/

    function refund(address _tokenAddress, address _projectVesting) public nonReentrant onlyGov {
        ProjectPresale.Presale memory presale = Master(operator).projectPresale().getPresale(_tokenAddress);
        ProjectLaunch.Launch memory launchInfo = Master(operator).projectLaunch().getLaunch(_tokenAddress);

        if (address(_projectVesting) != address(0)) {
            ProjectVesting(_projectVesting).releaseToSecurityFund(presale.owner, address(currencyAddress));
        }

        uint256 _totalRefundAmount = presale.totalAmount;
        if (_totalRefundAmount > getTotalAmount() * maxRefundPerPresaleBPS / 1e4) {
            _totalRefundAmount = getTotalAmount() * maxRefundPerPresaleBPS / 1e4;
        }
        
        require(Master(operator).projectPresale().isFinishedPresale(_tokenAddress) == true, "wrong time");
        require(block.timestamp <= Master(operator).projectPresale().shifts().shifts(presale.shiftID) + presaleCaducity,
            "not refundable");
        require(launchInfo.launched == true, "not launched");
        require(refunds[_tokenAddress].refunded == false, "already refunded");

        uint256 totalRaisedAmount = presale.totalAmount;
        address[] memory addressList = presale.addressList;

        refunds[_tokenAddress] = Refund({
            tokenAddress: _tokenAddress,
            timestamp: block.timestamp,
            addressList: presale.addressList,
            totalRefundAmount: _totalRefundAmount,
            refunded: true
        });

        for (uint256 i = 0; i < addressList.length; i++) {
            ProjectPresale.UserInfo memory userInfo = Master(operator).projectPresale().getUserInfo(_tokenAddress, addressList[i]);
            currencyAddress.transfer(addressList[i], userInfo.amount * _totalRefundAmount / totalRaisedAmount);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Shifts.sol";
import "./ProjectManager.sol";
import "./ProjectVotation.sol";
import "./ProjectLaunch.sol";
import "./ProjectVesting.sol";
import "./SecurityFund.sol";
import "./MasterPool.sol";
import "./ProjectPresale.sol";
import "./MasterConfig.sol";
import "./DAO.sol";
import "./VoteIncentive.sol";

contract Master is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Client {
        address owner;
        IERC20 tokenAddress;
        uint256 proposalPrice;
        uint256 tokensForPool;
        uint256 liquidityBPS;
        uint256 raisingAmount;
        uint256 offeringAmount;
        address routerAddress;
        uint256[] vestingPeriods;
        uint256[] vestingPeriodsAmountBPS;
        uint256 vestingTotalAmount;
        uint256 launchPrice;
        uint256 presalePrice;
    }

    enum Status { 
        VOTATION, 
        UPCOMING, 
        ACTIVE, 
        PAST, 
        REJECTED 
    }

    IERC20 public nativeToken;

    MasterConfig public masterConfig;
    ProjectManager public projectManager;
    ProjectVotation public projectVotation;
    ProjectLaunch public projectLaunch;
    ProjectVesting public projectVesting;
    SecurityFund public securityFund;
    MasterPool public masterPool;
    ProjectPresale public projectPresale;
    DAO public dao;
    VoteIncentive public voteIncentive;

    mapping(address => Client) public clients;
    address[] public tokenAddresses;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    constructor(IERC20 _nativeToken, MasterConfig _masterConfig, DAO _dao) {
        setNativeToken(_nativeToken);
        setConfig(_masterConfig);
        setDao(_dao);
    }

    modifier onlyClient(address _tokenAddress) {
        require(
            msg.sender == clients[_tokenAddress].owner || msg.sender == owner(),
            "not client"
        );
        _;
    }



    /** VIEWS */

    function getStatus(address _tokenAddress) public view returns (Status) {
        if (
            projectVotation.getStatus(_tokenAddress) == ProjectVotation.Status.ACTIVE ||
            projectVotation.getStatus(_tokenAddress) == ProjectVotation.Status.PENDING
        ) {
            return Status.VOTATION;
        }
        if (
            projectVotation.getStatus(_tokenAddress) == ProjectVotation.Status.REJECTED || 
            projectVotation.getStatus(_tokenAddress) == ProjectVotation.Status.NOQUORUM
        ) {
            return Status.REJECTED;
        }
        if (projectPresale.isActivePresale(_tokenAddress) == true) {
            return Status.ACTIVE;
        }
        if (projectPresale.isFinishedPresale(_tokenAddress) == true) {
            return Status.PAST;
        }
        if (projectPresale.isUpcomingPresale(_tokenAddress) == true) {
            return Status.UPCOMING;
        }
        return Status.VOTATION;
    }

    function getOfferingAmountForLiquidity(
        uint256 _raisingAmount, 
        uint256 _launchPrice, 
        uint256 _liquidityBPS,
        uint256 _decimals
    ) public view returns(uint256) {
        return 
            _raisingAmount * projectPresale.config().getStakeTokenDecimals() * _liquidityBPS / 1e4 / _launchPrice
            * (10 ** _decimals) / projectPresale.config().getStakeTokenDecimals() 
        ;
    }

    function getOfferingAmount(
        uint256 _raisingAmount, 
        uint256 _presalePrice,
        uint256 _decimals
    ) public view returns(uint256) {
        return _raisingAmount * projectPresale.config().getStakeTokenDecimals() / _presalePrice
            * (10 ** _decimals) / projectPresale.config().getStakeTokenDecimals() 
        ;
    }

    function getClient(address _tokenAddress) public view returns (Client memory) {
        return clients[_tokenAddress];
    }

 
    /** GENERAL FUNCTIONS **/

    function launchProject(address _tokenAddress) external nonReentrant {
        ProjectLaunch.Launch memory launchInfo = projectLaunch.getLaunch(_tokenAddress);
        if (launchInfo.launched == true) { return; }

        uint256 stakeTokenAmount = _getPresaleFunds(_tokenAddress);
        stakeTokenAmount -= _launchProjectAndLockLiquidity(_tokenAddress);
        stakeTokenAmount -= _distributeStakeToken(_tokenAddress);
        _vestStakeTokenForProjectOwner(stakeTokenAmount, _tokenAddress);

        _returnProposalPrice(_tokenAddress);
        _createPool(_tokenAddress);
        _burnLeftTokens(_tokenAddress);
    }

    function unlaunchProject(address _tokenAddress) public {
        ProjectLaunch.Launch memory launchInfo = projectLaunch.getLaunch(_tokenAddress);
        ProjectPresale.Presale memory presale = projectPresale.getPresale(_tokenAddress);
        Client storage client = clients[_tokenAddress];

        require(getStatus(_tokenAddress) == Status.REJECTED || getStatus(_tokenAddress) == Status.PAST, "can't unlaunch");
        require(presale.raisingAmount * projectPresale.config().presaleSoftCapBPS() > presale.totalAmount * 1e4, "can't unlaunch");
        require(launchInfo.launched == false, "project already launched");

        projectPresale.getOfferingTokensIfUnlanched(_tokenAddress);

        _deleteAllTokenVestings(_tokenAddress);
        _returnTokensToOwner(_tokenAddress);
        _takeProposalPrice(_tokenAddress);
    }

    function proposePresale(
        address _tokenAddress,
        uint256 _presalePrice,
        uint256 _launchPrice,
        uint256 _raisingAmount,
        uint256 _liquidityBPS,
        address _routerAddress,
        uint256[] memory _vestingPeriods,
        uint256[] memory _vestingPeriodsAmountBPS,
        uint256 _vestingTotalAmount,
        string memory _slug,
        ProjectManager.Project memory _project
    ) external nonReentrant {

        Client storage client = clients[_tokenAddress];

        require(client.owner == address(0), "project already created");
        require(_presalePrice < _launchPrice, "presale price too high");
        require(_liquidityBPS <= masterConfig.maxLiquidityBPS(), "wrong liquidity bps");
        require(_liquidityBPS >= masterConfig.minLiquidityBPS(), "wrong liquidity bps");
        require(_raisingAmount <= projectPresale.config().maxRaisingAmount(), "wrong raising amount");
        require(_raisingAmount >= projectPresale.config().minRaisingAmount(), "wrong raising amount");
        require(_vestingPeriods.length == _vestingPeriodsAmountBPS.length, "bad vesting array length");
        require(
            (_vestingTotalAmount > 0 && _vestingPeriods.length > 0) ||
            (_vestingTotalAmount == 0 && _vestingPeriods.length == 0),
            "wrong vesting"
        );

        uint256 _decimals = IERC20Metadata(_tokenAddress).decimals();
        
        client.owner = msg.sender;
        client.tokenAddress = IERC20(_tokenAddress);
        client.liquidityBPS = _liquidityBPS;
        client.raisingAmount = _raisingAmount;
        client.offeringAmount = getOfferingAmount(_raisingAmount, _presalePrice, _decimals);
        client.proposalPrice = masterConfig.getProposalPrice(_tokenAddress, _raisingAmount);
        client.tokensForPool = masterPool.getRewardAmountForPool(_launchPrice, _tokenAddress);
        client.presalePrice = _presalePrice;
        client.launchPrice = _launchPrice;
        client.routerAddress = _routerAddress;
        client.vestingPeriods = _vestingPeriods;
        client.vestingPeriodsAmountBPS = _vestingPeriodsAmountBPS;
        client.vestingTotalAmount = _vestingTotalAmount;

        _project.owner = msg.sender;
        projectManager.addProject(_tokenAddress, _project, _slug);
        projectLaunch.addLaunch(address(client.tokenAddress), client.routerAddress, client.launchPrice);
        
        if (address(_tokenAddress) != address(nativeToken)) {
            projectVotation.addVotation(_tokenAddress);
        }

        client.tokenAddress.safeTransferFrom(msg.sender, address(this), client.vestingTotalAmount);
        client.tokenAddress.safeTransferFrom(msg.sender, address(this), client.offeringAmount);
        client.tokenAddress.safeTransferFrom(msg.sender, address(this), getOfferingAmountForLiquidity(_raisingAmount, _launchPrice, _liquidityBPS, _decimals));
        client.tokenAddress.safeTransferFrom(msg.sender, address(this), client.tokensForPool);
        require(
            client.tokenAddress.balanceOf(address(this)) == (
                client.vestingTotalAmount + 
                client.offeringAmount + 
                getOfferingAmountForLiquidity(_raisingAmount, _launchPrice, _liquidityBPS, _decimals) + 
                client.tokensForPool
            ),
            "whitelist first"
        );

        nativeToken.safeTransferFrom(msg.sender, address(this), client.proposalPrice);

        tokenAddresses.push(_tokenAddress);
    }



    /** CLIENT **/

    function deleteProposal(address _tokenAddress) external nonReentrant onlyClient(_tokenAddress) {
        ProjectPresale.Presale memory presale = projectPresale.getPresale(_tokenAddress);
        require(
            address(presale.offeringToken) == address(0) || projectPresale.isUpcomingPresale(_tokenAddress) == true, 
            "can't delete"
        );

        if (projectPresale.isUpcomingPresale(_tokenAddress) == true) {
            projectPresale.getOfferingTokensIfDeleted(_tokenAddress);
        }

        Client storage client = clients[_tokenAddress];

        client.tokenAddress.safeTransfer(client.owner, client.tokenAddress.balanceOf(address(this)));
        _takeProposalPrice(_tokenAddress);

        _deleteAllTokenVestings(_tokenAddress);

        projectVotation.removeVotation(_tokenAddress);
        projectManager.removeProject(_tokenAddress);

        clients[_tokenAddress] = Client({
            owner: address(0),
            tokenAddress: IERC20(address(0)),
            proposalPrice: 0,
            tokensForPool: 0,
            liquidityBPS: 0,
            raisingAmount: 0,
            offeringAmount: 0,
            routerAddress: address(0),
            vestingPeriods: new uint256[](0),
            vestingPeriodsAmountBPS: new uint256[](0),
            vestingTotalAmount: 0,
            launchPrice: 0,
            presalePrice: 0
        });

        _removeFromArray(_tokenAddress);
    }

    function createPresale(address _tokenAddress, uint256 _timestamp) external nonReentrant onlyClient(_tokenAddress) {

        Client storage client = clients[_tokenAddress];

        require(projectPresale.isPresale(_tokenAddress) == false, "presale already created");
        require(
            projectVotation.isPassed(_tokenAddress) == true || 
            address(_tokenAddress) == address(nativeToken), 
            "votation not passed"
        );

        client.tokenAddress.approve(address(projectPresale), client.offeringAmount);
        projectPresale.addPresale(_tokenAddress, _timestamp, client.owner, client.raisingAmount, client.offeringAmount);

        if (client.vestingTotalAmount > 0) {
            IERC20(client.tokenAddress).approve(address(projectVesting), client.vestingTotalAmount);
            projectVesting.addVesting(
                client.owner, 
                address(client.tokenAddress), 
                client.vestingTotalAmount, 
                client.vestingPeriods, 
                client.vestingPeriodsAmountBPS
            );
        }
    }



    /** INTERNAL **/

    function _removeFromArray(address _tokenAddress) internal {
        uint256 indexToRemove;
        for (uint256 i = 0; i < tokenAddresses.length; i++){
            if (tokenAddresses[i] == _tokenAddress) {
                indexToRemove = i;
                break;
            }
        }
        for (uint256 i = indexToRemove; i < tokenAddresses.length-1; i++){
            tokenAddresses[i] = tokenAddresses[i+1];
        }
        tokenAddresses.pop();
    }

    function _getPresaleFunds(address _tokenAddress) internal returns(uint256) {
        return projectPresale.getPresaleFunds(_tokenAddress);
    }

    function _launchProjectAndLockLiquidity(address _tokenAddress) internal returns(uint256) {
        ProjectPresale.Presale memory presale = projectPresale.getPresale(_tokenAddress);

        uint256 pre = presale.stakeToken.balanceOf(address(this));

        presale.stakeToken.approve(address(projectLaunch), 2**256 - 1);
        presale.offeringToken.approve(address(projectLaunch), 2**256 - 1);
        (address lpAddress, , ) = projectLaunch.launchProject(_tokenAddress);

        uint256 lpAddressAmount = IERC20(lpAddress).balanceOf(address(this));
        IERC20(lpAddress).approve(address(projectVesting), lpAddressAmount);
        uint256[] memory liquidityLockPeriod = new uint256[](1);
        liquidityLockPeriod[0] = projectVesting.lockLiquidityVestingPeriod();
        uint256[] memory liquidityLockPeriodAmountBPS = new uint256[](1);
        liquidityLockPeriodAmountBPS[0] = 10000;
        projectVesting.addVesting(
            presale.owner, 
            lpAddress, 
            lpAddressAmount, 
            liquidityLockPeriod,
            liquidityLockPeriodAmountBPS
        );

        return pre - presale.stakeToken.balanceOf(address(this));
    }

    function _distributeStakeToken(address _tokenAddress) internal returns(uint256) {

        ProjectPresale.Presale memory presale = projectPresale.getPresale(_tokenAddress);

        uint256 pre = presale.stakeToken.balanceOf(address(this));

        presale.stakeToken.transfer(masterConfig.treasuryAddress(), presale.totalAmount * masterConfig.treasuryBPS() / 1e4);
        presale.stakeToken.transfer(masterConfig.marketingAddress(), presale.totalAmount * masterConfig.marketingBPS() / 1e4);
        presale.stakeToken.transfer(address(securityFund), presale.totalAmount * masterConfig.securityBPS() / 1e4);
        presale.stakeToken.transfer(masterConfig.buybackAddress(), presale.totalAmount * masterConfig.buybackBPS() / 1e4);
        presale.stakeToken.transfer(masterConfig.voteIncentiveAddress(), presale.totalAmount * masterConfig.voteIncentiveBPS() / 1e4);

        return pre - presale.stakeToken.balanceOf(address(this));
    }

    function _vestStakeTokenForProjectOwner(uint256 _stakeTokenAmount, address _tokenAddress) internal {
        ProjectPresale.Presale memory presale = projectPresale.getPresale(_tokenAddress);
        presale.stakeToken.approve(address(projectVesting), _stakeTokenAmount);
        projectVesting.addVesting(
            presale.owner, 
            address(presale.stakeToken), 
            _stakeTokenAmount, 
            projectVesting.getStakeTokenReleasePeriods(), 
            projectVesting.getStakeTokenReleaseAmountsBPS()
        );
    }

    function _returnProposalPrice(address _tokenAddress) internal {
        Client storage client = clients[_tokenAddress];
        nativeToken.transfer(client.owner, client.proposalPrice);
    }

    function _createPool(address _tokenAddress) internal {
        Client storage client = clients[_tokenAddress];
        if (client.tokensForPool == 0) return;
        client.tokenAddress.approve(address(masterPool), client.tokensForPool);
        masterPool.addPool(client.tokenAddress, client.tokensForPool);
    }

    function _burnLeftTokens(address _tokenAddress) internal {
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        if (tokenBalance > 0) {
            IERC20(_tokenAddress).transfer(BURN_ADDRESS, tokenBalance);
        }
    }

    function _deleteAllTokenVestings(address _tokenAddress) internal {
        Client storage client = clients[_tokenAddress];
        projectVesting.deleteVestingByTokenAddress(client.owner, _tokenAddress);
    }

    function _returnTokensToOwner(address _tokenAddress) internal {
        Client storage client = clients[_tokenAddress];
        client.tokenAddress.transfer(client.owner, client.tokenAddress.balanceOf(address(this)));
    }

    function _takeProposalPrice(address _tokenAddress) internal {
        Client storage client = clients[_tokenAddress];
        if (address(voteIncentive) != address(0)) {
            nativeToken.safeIncreaseAllowance(address(voteIncentive), client.proposalPrice);
            voteIncentive.addRewardOperator(_tokenAddress, client.proposalPrice);
        } else {
            nativeToken.transfer(masterConfig.treasuryAddress(), client.proposalPrice);
        }
    }



    /** OWNER **/

    function setConfig(MasterConfig _masterConfig) public onlyOwner {
        masterConfig = _masterConfig;
    }

    function setDao(DAO _dao) public onlyOwner {
        dao = _dao;
    }
    
    function setProjectManager(ProjectManager _projectManager) public onlyOwner {
        projectManager = _projectManager;
    }
    
    function setProjectVotation(ProjectVotation _projectVotation) public onlyOwner {
        projectVotation = _projectVotation;
    }
    
    function setProjectLaunch(ProjectLaunch _projectLaunch) public onlyOwner {
        projectLaunch = _projectLaunch;
    }
    
    function setProjectVesting(ProjectVesting _projectVesting) public onlyOwner {
        projectVesting = _projectVesting;
    }
    
    function setProjectPresale(ProjectPresale _projectPresale) public onlyOwner {
        projectPresale = _projectPresale;
    }
    
    function setSecurityFund(SecurityFund _securityFund) public onlyOwner {
        securityFund = _securityFund;
    }
    
    function setMasterPool(MasterPool _masterPool) public onlyOwner {
        masterPool = _masterPool;
    }

    function setNativeToken(IERC20 _nativeToken) public onlyOwner {
        nativeToken = _nativeToken;
    }

    function setVoteIncentive(VoteIncentive _voteIncentive) public onlyOwner {
        voteIncentive = _voteIncentive;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

abstract contract Governable is Context {
    address public governor;

    constructor() {
        _transferGovernorship(_msgSender());
    }

    modifier onlyGov() {
        require(
            governor == _msgSender(),
            "Governable: caller is not the governor"
        );
        _;
    }

    function transferGovernorship(address _newGovernor) public onlyGov {
        require(
            _newGovernor != address(0),
            "Governable: new governor is the zero address"
        );

        _transferGovernorship(_newGovernor);
    }

    function _transferGovernorship(address _newGovernor) internal {
        governor = _newGovernor;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
        
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface IPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";
import "./Master.sol";
import "./ProjectPresale.sol";
import "./ProjectPresaleConfig.sol";
import "./AnyCall.sol";
import "hardhat/console.sol";

contract MasterPool is ERC20, Operable, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }
    
    struct UserLock {
        uint256 startLockTimestamp;
        uint256 lockId;
        uint256 extraMintedSyrup;
    }
    
    struct UserLockFront {
        uint256 startLockTimestamp;
        uint256 endLockTimestamp;
        uint256 lockId;
        uint256 extraMintedSyrup;
    }

    struct LockTime {
        uint256 multiplierBPS;
        uint256 lockTimestamp;
    }

    struct PoolInfo {
        uint256 pid;
        IERC20 rewardToken;
        uint256 rewardPerSecond;
        uint256 startTimestamp;
        uint256 endTimestamp;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint256 lpSupply;
        uint256 precisionFactor;
        uint256 priority;
    }

    struct Bridge {
        uint256 amount;
        bool backfalled;
    }

    IERC20 public nativeToken;
    address public feeAddress;
    uint256 public depositFeeBPS;
    uint256 public withdrawalFeeBPS;
    uint256 public poolDuration;
    uint256 public startDelayInSeconds;
    uint256 public rewardAmountInCurrencyToken;

    uint256 public allocationConstantBPS;
    uint256 public publicAllocation;

    uint256 public totalLpSupply;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; 
    mapping(address => UserLock) public userLock;

    LockTime[] public lockTimes;

    AnyCall public anyCall;
    uint256 public bridgeLiquidity;
    mapping(uint256 => address) public chainAddresses;

    mapping(address => Bridge[]) public bridges;

    event BridgeWithdraw(address indexed user, uint256 chainID, uint256 amount);

    constructor(
        address _operator,
        IERC20 _nativeToken,
        address _feeAddress,
        uint256 _withdrawalFeeBPS,
        uint256 _poolDuration,
        uint256 _startDelayInSeconds,
        uint256 _rewardAmountInCurrencyToken,
        uint256 _allocationConstantBPS,
        uint256 _publicAllocation,
        uint256[] memory _lockMultiplierBPS,
        uint256[] memory _lockTimestamp
    ) ERC20 ("DXL Allocation Token", "DXALLOC") {
        setNativeToken(_nativeToken);
        setFeeAddress(_feeAddress);
        setDepositFeeBPS(0);
        setWithdrawalFeeBPS(_withdrawalFeeBPS);
        setPoolDuration(_poolDuration);
        setStartDelayInSeconds(_startDelayInSeconds);
        setRewardAmountInCurrencyToken(_rewardAmountInCurrencyToken);
        setAllocationConstantBPS(_allocationConstantBPS);
        setPublicAllocation(_publicAllocation);
        addLockTime(0, 0);
        for(uint256 i = 0; i < _lockMultiplierBPS.length; i++) {
            addLockTime(_lockMultiplierBPS[i], _lockTimestamp[i]);
        }
        transferOperable(_operator);
    }



    /** MODIFIERS **/

    modifier onlyUnlockedUsers() {
        require(
            getUserLockTimeLeft(msg.sender) == 0,
            "locked time not reached"
        );
        _;
    }

    modifier onlyAnyCall() {
        require(
            address(msg.sender) == address(anyCall),
            "noy anyCall"
        );
        _;
    }

    modifier onlyNotBlockedByVote() {
        require(
            getIsUserBlockedByVote(msg.sender) == false,
            "blocked by vote"
        );
        _;
    }



    /** VIEWS **/

    function getIsUserBlockedByVote(address _user) public view returns(bool) {
        return (
            Master(operator).projectVotation().isUserBlocked(_user) || 
            Master(operator).dao().isUserBlocked(_user)
        );
    }

    function getLockTimes() external view returns (LockTime[] memory) {
        return lockTimes;
    }

    function getUserLockTime(address _user) external view returns (UserLockFront memory) {
        UserLock memory _userLock = userLock[_user];
        LockTime memory _lockTime = lockTimes[_userLock.lockId];
        return UserLockFront({
            startLockTimestamp: _userLock.startLockTimestamp,
            endLockTimestamp: _userLock.startLockTimestamp + _lockTime.lockTimestamp,
            lockId: _userLock.lockId,
            extraMintedSyrup: _userLock.extraMintedSyrup
        });
    }

    function getUserPresaleAllocation(address _user) public view returns (uint256) {
        return 
            publicAllocation 
            + balanceOf(_user) * Master(operator).projectPresale().config().getStakeTokenDecimals() / (10 ** decimals())
            * allocationConstantBPS / 1e4; 
    }

    function getActivePools() public view returns (PoolInfo[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (poolInfo[i].endTimestamp >= block.timestamp) {
                count++;
            }
        }
        PoolInfo[] memory activePools = new PoolInfo[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (poolInfo[i].endTimestamp >= block.timestamp) {
                activePools[counter] = poolInfo[i];
                counter++;
            }
        }
        return activePools;
    }

    function getOldPools() public view returns (PoolInfo[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (poolInfo[i].endTimestamp < block.timestamp) {
                count++;
            }
        }
        PoolInfo[] memory oldPools = new PoolInfo[](count);
        uint256 counter = 0;
        for (uint256 i = 0; i < poolInfo.length; i++) {
            if (poolInfo[i].endTimestamp < block.timestamp) {
                oldPools[counter] = poolInfo[i];
                counter++;
            }
        }
        return oldPools;
    }

    function getRewardAmountForPool(uint256 _launchPrice, address _tokenAddress) public view returns (uint256) {
        if (address(_tokenAddress) == address(nativeToken)) return 0;
        uint256 _decimals = IERC20Metadata(_tokenAddress).decimals();
        return 
            rewardAmountInCurrencyToken * Master(operator).projectPresale().config().getStakeTokenDecimals() / _launchPrice 
            * (10 ** _decimals) / Master(operator).projectPresale().config().getStakeTokenDecimals() 
        ;
    }

    function getMultiplier(uint256 _from, uint256 _to, uint256 _endTimestamp) public pure returns (uint256) {
        if (_to <= _endTimestamp) {
            return _to.sub(_from);
        } else if (_from >= _endTimestamp) {
            return 0;
        } else {
            return _endTimestamp.sub(_from);
        }
    }

    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.timestamp > pool.lastRewardBlock && pool.lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.timestamp, pool.endTimestamp);
            uint256 tokenReward = multiplier.mul(pool.rewardPerSecond);
            accTokenPerShare = accTokenPerShare.add(tokenReward.mul(pool.precisionFactor).div(pool.lpSupply));
        }
        return user.amount.mul(accTokenPerShare).div(pool.precisionFactor).sub(user.rewardDebt);
    }

    function getUserLockTimeLeft(address _user) public view returns (uint256) {
        UserLock memory _userLock = userLock[_user];
        if (block.timestamp >= _userLock.startLockTimestamp + lockTimes[_userLock.lockId].lockTimestamp) return 0;
        return _userLock.startLockTimestamp + lockTimes[_userLock.lockId].lockTimestamp - block.timestamp;
    }

    function getUserAllocationMultiplier(address _user) external view returns (uint256) {
        UserLock memory _userLock = userLock[_user];
        return lockTimes[_userLock.lockId].multiplierBPS;
    }

    function getUserDepositedAmount(uint256 _pid, address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        return user.amount;
    }


    /** OPERATOR **/

    function addPool(IERC20 _rewardToken, uint256 _tokensForPool) public onlyOperator {
        _rewardToken.safeTransferFrom(operator, address(this), _tokensForPool);
        uint256 _rewardPerSecond = _tokensForPool / poolDuration;
        uint256 _startTimestamp = block.timestamp + startDelayInSeconds;
        uint256 _endTimestamp = _startTimestamp + poolDuration;
        _addPool(_rewardToken, _rewardPerSecond, _startTimestamp, _endTimestamp);
    }



    /** OWNER **/

    function addPoolOwner(
        IERC20 _rewardToken, 
        uint256 _rewardPerSecond, 
        uint256 _startTimestamp, 
        uint256 _endTimestamp
    ) public onlyOwner {
        _addPool(_rewardToken, _rewardPerSecond, _startTimestamp, _endTimestamp);
    }

    function addLockTime(uint256 _multiplierBPS, uint256 _lockTimestamp) public onlyOwner {
        lockTimes.push(LockTime({
            multiplierBPS: _multiplierBPS,
            lockTimestamp: _lockTimestamp
        }));
    }

    function setLockTime(uint256 _lockId, uint256 _multiplierBPS, uint256 _lockTimestamp) public onlyOwner {
        lockTimes[_lockId] = LockTime({
            multiplierBPS: _multiplierBPS,
            lockTimestamp: _lockTimestamp
        });
    }

    function stopReward(uint256 _pid) public onlyOwner {
        poolInfo[_pid].endTimestamp = block.timestamp;
    }

    function emergencyNativeRewardWithdraw(uint256 _amount) public onlyOwner {
        require(nativeToken.balanceOf(address(this)) - _amount >= totalLpSupply, "wrong amount");
        nativeToken.safeTransfer(address(msg.sender), _amount);
    }

    function setNativeToken(IERC20 _nativeToken) public onlyOwner {
        require(address(nativeToken) == address(0), "already setted");
        nativeToken = _nativeToken;
    }

    function setFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }
    
    function setWithdrawalFeeBPS(uint256 _withdrawalFeeBPS) public onlyOwner {
        require(_withdrawalFeeBPS <= 2000, "invalid value");
        withdrawalFeeBPS = _withdrawalFeeBPS;
    }    

    function setDepositFeeBPS(uint256 _depositFeeBPS) public onlyOwner {
        require(_depositFeeBPS <= 2000, "invalid value");
        depositFeeBPS = _depositFeeBPS;
    }

    function setPoolDuration(uint256 _poolDuration) public onlyOwner {
        poolDuration = _poolDuration;
    }

    function setStartDelayInSeconds(uint256 _startDelayInSeconds) public onlyOwner {
        startDelayInSeconds = _startDelayInSeconds;
    }

    function setRewardAmountInCurrencyToken(uint256 _rewardAmountInCurrencyToken) public onlyOwner {
        rewardAmountInCurrencyToken = _rewardAmountInCurrencyToken;
    }

    function setPriority(uint256 _pid, uint256 _value) public onlyOwner {
        poolInfo[_pid].priority = _value;
    }

    function setRewardPerSecond(uint256 _pid, uint256 _rewardPerSecond) public onlyOwner {
        poolInfo[_pid].rewardPerSecond = _rewardPerSecond;
        updatePool(_pid);        
    } 

    function setStartTimestamp(uint256 _pid, uint256 _startTimestamp) public onlyOwner {
        poolInfo[_pid].startTimestamp = _startTimestamp;
    }   
    
    function setEndTimestamp(uint256 _pid, uint256 _endTimestamp) public onlyOwner {
        poolInfo[_pid].endTimestamp = _endTimestamp;
    }   

    function setAllocationConstantBPS(uint256 _allocationConstantBPS) public onlyOwner {
        allocationConstantBPS = _allocationConstantBPS;
    }

    function setPublicAllocation(uint256 _publicAllocation) public onlyOwner {
        publicAllocation = _publicAllocation;
    }

    function setAnyCall(AnyCall _anyCall) public onlyOwner {
        require(address(anyCall) == address(0), "already setted");
        anyCall = _anyCall;
    }

    function setChainAddress(uint256 _chainID, address _address) public onlyOwner {
        chainAddresses[_chainID] = _address;
    }

    function depositBridgeLiquidity(uint256 _amount) public onlyOwner {
        nativeToken.safeTransferFrom(msg.sender, address(this), _amount);
        bridgeLiquidity += _amount;
    }

    function removeBridgeLiquidity(uint256 _amount) public onlyOwner {
        require(_amount <= bridgeLiquidity, "wrong amount");
        bridgeLiquidity -= _amount;
        nativeToken.transfer(msg.sender, _amount);
    }


    /** GENERAL FUNCTIONS **/

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardBlock) {
            return;
        }
        if (pool.lpSupply == 0) {
            pool.lastRewardBlock = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.timestamp, pool.endTimestamp);
        uint256 tokenReward = multiplier.mul(pool.rewardPerSecond);
        pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(pool.precisionFactor).div(pool.lpSupply));
        pool.lastRewardBlock = block.timestamp;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        _deposit(msg.sender, _pid, _amount, true, true);
        lock(userLock[msg.sender].lockId);
    }
    
    function withdraw(uint256 _pid, uint256 _amount) public onlyUnlockedUsers onlyNotBlockedByVote {
        _withdraw(msg.sender, _pid, _amount, true, true);
    }

    function lock(uint256 _lockId) public {
        UserLock storage _userLock = userLock[msg.sender];
        require(lockTimes.length > _lockId, "wrong lock id");
        require(
            block.timestamp > _userLock.startLockTimestamp + lockTimes[_lockId].lockTimestamp ||
            _userLock.lockId <= _lockId, 
            "can't change lock"
        );

        _lock(msg.sender, _lockId);
    }

    function switchPool(uint256 _pidFrom, uint256 _pidTo, uint256 _amount) public {
        require(_pidFrom == 0 || _pidTo == 0, "wrong switch");
        require(address(poolInfo[_pidFrom].rewardToken) != address(0), "wrong pool from");
        require(address(poolInfo[_pidTo].rewardToken) != address(0), "wrong pool to");

        _withdraw(msg.sender, _pidFrom, _amount, false, false);
        _deposit(msg.sender, _pidTo, _amount, false, false);
    }

    function emergencyWithdraw(uint256 _pid) public onlyUnlockedUsers onlyNotBlockedByVote {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        pool.lpSupply -= user.amount;
        totalLpSupply -= user.amount;
        _burnSyrup(user.amount);
        if (withdrawalFeeBPS > 0) {
            uint256 withdrawalFee = user.amount.mul(withdrawalFeeBPS).div(10000);
            nativeToken.safeTransfer(feeAddress, withdrawalFee);
            user.amount = user.amount.sub(withdrawalFee);
        }
        nativeToken.safeTransfer(address(msg.sender), user.amount);

        user.amount = 0;
        user.rewardDebt = 0;
    }

    function bridgeWithdraw(uint256 _chainID, uint256 _amount) public onlyNotBlockedByVote {
        require(block.chainid != _chainID, "wrong chain");
        require(address(anyCall) != address(0), "not available");
        require(chainAddresses[_chainID] != address(0), "masterPool chain address not setted");

        _withdraw(msg.sender, 0, _amount, false, false);

        UserLock storage _userLock = userLock[msg.sender];
        bytes memory data = abi.encodeWithSignature(
            "bridgeDeposit(address,uint256,uint256,uint256)", 
            msg.sender, _amount, _userLock.lockId, _userLock.startLockTimestamp
        );

        anyCall.anyCall(chainAddresses[_chainID], data, address(this), _chainID);

        bridgeLiquidity += _amount;

        bridges[msg.sender].push(Bridge({
            amount: _amount,
            backfalled: false
        }));
        emit BridgeWithdraw(msg.sender, _chainID, _amount);
    }



    /** INTERNAL **/
    
    function _lock(address _user, uint256 _lockId) internal {
        UserLock storage _userLock = userLock[_user];

        _burn(_user, _userLock.extraMintedSyrup);

        _userLock.startLockTimestamp = block.timestamp;
        _userLock.lockId = _lockId;
        _userLock.extraMintedSyrup = balanceOf(_user) * lockTimes[_lockId].multiplierBPS / 1e4;

        _mint(_user, _userLock.extraMintedSyrup);
    }

    function _addPool(IERC20 _rewardToken, uint256 _rewardPerSecond, uint256 _startTimestamp, uint256 _endTimestamp) internal {
        require(address(_rewardToken) != address(0), "wrong address");
        uint256 decimalsRewardToken = uint256(IERC20Metadata(address(_rewardToken)).decimals());
        uint256 precisionFactor = uint256(10**(uint256(30).sub(decimalsRewardToken)));
        poolInfo.push(
            PoolInfo({
                pid: poolInfo.length,
                rewardToken: _rewardToken,
                rewardPerSecond: _rewardPerSecond,
                startTimestamp: _startTimestamp,
                endTimestamp: _endTimestamp,
                lastRewardBlock: _startTimestamp,
                accTokenPerShare: 0,
                lpSupply: 0,
                precisionFactor: precisionFactor,
                priority: 99999999
            })
        );
    }

    function _withdraw(address _user, uint256 _pid, uint256 _amount, bool _takeFee, bool _transferToUser) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        require(user.amount >= _amount, "withdraw: not good");
        
        updatePool(_pid);
        _transferPendingRewards(_user, _pid);
        
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            _burnSyrup(_amount);
            pool.lpSupply -= _amount;
            totalLpSupply -= _amount;
            if (withdrawalFeeBPS > 0 && _takeFee == true) {
                uint256 withdrawalFee = _amount.mul(withdrawalFeeBPS).div(10000);
                nativeToken.safeTransfer(feeAddress, withdrawalFee);
                _amount = _amount.sub(withdrawalFee);
            }
            if (_transferToUser == true) {
                nativeToken.safeTransfer(address(_user), _amount);
            }
        }

        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(pool.precisionFactor);
    }

    function _deposit(address _user, uint256 _pid, uint256 _amount, bool _takeFee, bool _transferFromUser) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        updatePool(_pid);
        _transferPendingRewards(_user, _pid);
        
        if (_amount > 0) {
            if (_transferFromUser == true) {
                nativeToken.safeTransferFrom(address(_user), address(this), _amount);
            }
            _mintSyrup(_user, _amount);
            if (depositFeeBPS > 0 && _takeFee == true){
                uint256 depositFee = _amount.mul(depositFeeBPS).div(10000);
                nativeToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
                pool.lpSupply += _amount - depositFee;
                totalLpSupply += _amount - depositFee;
            } else {
                user.amount = user.amount.add(_amount);
                pool.lpSupply += _amount;
                totalLpSupply += _amount;
            }
        }
        
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(pool.precisionFactor);
    }

    function _transferPendingRewards(address _user, uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accTokenPerShare).div(pool.precisionFactor).sub(user.rewardDebt);
            if (pending > 0) {
                pool.rewardToken.safeTransfer(address(_user), pending);
            }
        }
    }

    function _mintSyrup(address _user, uint256 _amount) internal {
        UserLock storage _userLock = userLock[_user];
        uint256 amountToMint = _amount + _amount * lockTimes[_userLock.lockId].multiplierBPS / 1e4;
        _mint(address(_user), amountToMint);
    }

    function _burnSyrup(uint256 _amount) internal {
        UserLock storage _userLock = userLock[msg.sender];
        uint256 amountToBurn = _amount + _amount * lockTimes[_userLock.lockId].multiplierBPS / 1e4;
        if (amountToBurn > balanceOf(msg.sender)) {
            amountToBurn = balanceOf(msg.sender);
        }
        _burn(address(msg.sender), amountToBurn);
    }



    /** ANY CALL **/

    function bridgeDeposit(address _user, uint256 _amount, uint256 _lockId, uint256 _startLockTimestamp) public onlyAnyCall {
        require(_amount <= bridgeLiquidity, "no bridge liquidity");

        _deposit(_user, 0, _amount, false, false);

        UserLock storage _userLock = userLock[msg.sender];
        if (_userLock.lockId < _lockId) {
            _userLock.startLockTimestamp = _startLockTimestamp;
            _userLock.lockId = _lockId;
        }
        _lock(_user, _userLock.lockId);

        bridgeLiquidity -= _amount;
    }

    function anyFallback(address /* _to */, bytes calldata _data) public onlyAnyCall {
        (address _user, uint256 _amount, , ) = abi.decode(_data[4:], (address,uint256,uint256,uint256));
        bool bridgeFound = false;
        for (uint256 i = 0; i < bridges[_user].length; i++) {
            if (bridges[_user][i].amount == _amount && bridges[_user][i].backfalled == false) {
                bridges[_user][i].backfalled = true;
                bridgeFound = true;
                break;
            }
        }
        require(bridgeFound == true, "no bridge found");
        _deposit(_user, 0, _amount, false, false);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Governable.sol";

contract MasterConfig is Ownable, Governable {
    using SafeMath for uint256; 

    uint256 public treasuryBPS;
    uint256 public marketingBPS;
    uint256 public securityBPS;
    uint256 public buybackBPS;
    uint256 public voteIncentiveBPS;

    uint256 public minLiquidityBPS;

    address public treasuryAddress;
    address public marketingAddress;
    address public buybackAddress;
    address public voteIncentiveAddress;
    
    uint256[] public proposalPrices;
    uint256[] public proposalPricesRaising;

    mapping(address => bool) public whitelistedProjects;

    constructor(
        address _governor,
        address[] memory addresses,
        uint256[] memory _proposalPrices,
        uint256[] memory _proposalPricesRaising,
        uint256 _treasuryBPS,
        uint256 _marketingBPS,
        uint256 _securityBPS,
        uint256 _buybackBPS,
        uint256 _voteIncentiveBPS,
        uint256 _minLiquidityBPS
    ) {
        setTreasuryAddress(addresses[0]);
        setMarketingAddress(addresses[1]);
        setBuybackAddress(addresses[2]);
        setVoteIncentiveAddress(addresses[3]);
        setProposalPrices(_proposalPrices, _proposalPricesRaising);
        setTreasuryBPS(_treasuryBPS);
        setMarketingBPS(_marketingBPS);
        setSecurityBPS(_securityBPS);
        setBuybackBPS(_buybackBPS);
        setVoteIncentiveBPS(_voteIncentiveBPS);
        setMinLiquidityBPS(_minLiquidityBPS);
        transferGovernorship(_governor);
    }



    /** VIEWS **/

    function maxLiquidityBPS() public view returns(uint256) {
        return uint256(1e4).sub(treasuryBPS).sub(marketingBPS).sub(securityBPS).sub(buybackBPS);
    }

    function getProposalPrice(address _tokenAddress, uint256 _raisingAmount) public view returns(uint256) {
        if (whitelistedProjects[_tokenAddress] == true) {
            return 0;
        }
        for (uint256 i = 0; i < proposalPrices.length; i++) {
            if (_raisingAmount < proposalPricesRaising[i]) {
                return proposalPrices[i];
            }
        }
        return proposalPrices[proposalPrices.length-1];
    }



    /** GOVERNANCE **/

    function setProposalPrices(uint256[] memory _proposalPrices, uint256[] memory _proposalPricesRaising) public onlyGov {
        require(_proposalPrices.length == _proposalPricesRaising.length, "bad length");
        proposalPrices = _proposalPrices;
        proposalPricesRaising = _proposalPricesRaising;
    }

    function setMinLiquidityBPS(uint256 _minLiquidityBPS) public onlyGov {
        require(_minLiquidityBPS <= maxLiquidityBPS(), "invalid value");
        require(_minLiquidityBPS <= 6000, "invalid value");
        require(_minLiquidityBPS >= 3000, "invalid value");
        minLiquidityBPS = _minLiquidityBPS;
    }



    /** OWNER **/

    function setTreasuryBPS(uint256 _treasuryBPS) public onlyOwner {
        require(_treasuryBPS <= 1000, "invalid value");
        treasuryBPS = _treasuryBPS;
    }

    function setMarketingBPS(uint256 _marketingBPS) public onlyOwner {
        require(_marketingBPS <= 250, "invalid value");
        marketingBPS = _marketingBPS;
    }

    function setSecurityBPS(uint256 _securityBPS) public onlyOwner {
        require(_securityBPS <= 250, "invalid value");
        securityBPS = _securityBPS;
    }

    function setBuybackBPS(uint256 _buybackBPS) public onlyOwner {
        require(_buybackBPS <= 250, "invalid value");
        buybackBPS = _buybackBPS;
    }

    function setVoteIncentiveBPS(uint256 _voteIncentiveBPS) public onlyOwner {
        require(_voteIncentiveBPS <= 250, "invalid value");
        voteIncentiveBPS = _voteIncentiveBPS;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        treasuryAddress = _treasuryAddress;
    }

    function setMarketingAddress(address _marketingAddress) public onlyOwner {
        marketingAddress = _marketingAddress;
    }

    function setBuybackAddress(address _buybackAddress) public onlyOwner {
        buybackAddress = _buybackAddress;
    }

    function setVoteIncentiveAddress(address _voteIncentiveAddress) public onlyOwner {
        voteIncentiveAddress = _voteIncentiveAddress;
    }

    function setWhitelistedProject(address _tokenAddress, bool value) public onlyOwner {
        whitelistedProjects[_tokenAddress] = value;
    }
}

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.11;

contract DAOInterface {
    // Debate period
    uint constant proposalDebatePeriod = 2 days;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant executeProposalPeriod = 15 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant maxDepositDivisor = 100;
    // The period to execute the proposal after the voting ends
    uint constant executeTimelockPeriod = 2 days;

    uint256 public proposalPriceInNativeToken;

    address public feeAddress;

    // Governance pool
    IERC20 public syrupToken;
    IERC20 public nativeToken;

    // Proposal ID last
    uint public proposalID;

    // Proposals to spend the DAO's ether
    // Proposal[] public proposals;
    mapping (uint => Proposal) public proposals;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public minQuorumDivisor;
    // The unix time of the last time quorum was reached on a proposal
    uint public lastTimeMinQuorumMet;

    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public allowedRecipients;

    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public blocked;

    // Proposal struct
    struct Proposal {
        // Title
        string title;
        // A plain text description of the proposal
        string description;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // A unix timestamp, denoting when the owner can execute the proposal
        uint executionDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool proposalPassed;
        // A hash to check validity of a proposal
        bytes32 proposalHash;
        // Number of Tokens in favor of the proposal
        uint yea;
        // Number of Tokens opposed to the proposal
        uint nay;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) votedYes;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) votedNo;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => uint256) voted;
        // Address of the shareholder who created the proposal
        address creator;
        // Address of the shareholder who created the proposal
        address recipient;
        // Native tokens paid by proposer
        uint256 nativeTokens;
    }

    // Proposal struct
    struct ProposalFront {
        // Index
        uint256 index;
        // Title
        string title;
        // A plain text description of the proposal
        string description;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // A unix timestamp, denoting when the owner can execute the proposal
        uint executionDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool proposalPassed;
        // A hash to check validity of a proposal
        bytes32 proposalHash;
        // Number of Tokens in favor of the proposal
        uint yea;
        // Number of Tokens opposed to the proposal
        uint nay;
        // Address of the shareholder who created the proposal
        address creator;
        // Address of the shareholder who created the proposal
        address recipient;
        // Native tokens paid by proposer
        uint256 nativeTokens;
    }

    event ProposalAdded(uint indexed proposalID, string title, string description);
    event Voted(uint indexed proposalID, bool position, address indexed voter);
    event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
    event AllowedRecipientChanged(address indexed _recipient, bool _allowed);
}

// The DAO contract itself
contract DAO is DAOInterface, Ownable, ReentrancyGuard {

    // Modifier that allows only shareholders to vote and create new proposals
    modifier onlyTokenHolders {
        uint256 amount = syrupToken.balanceOf(msg.sender);
        require(amount > 0, "no voting power");
        _;
    }

    constructor(
        address _owner,
        address _feeAddress,
        IERC20 _nativeToken,
        uint256 _proposalPriceInNativeToken
    ) {
        // transfer ownership
        transferOwnership(_owner);

        // init variables
        setMinQuorumDivisor(7);
        setFeeAddress(_feeAddress);
        nativeToken = _nativeToken;
        proposalPriceInNativeToken = _proposalPriceInNativeToken;
        lastTimeMinQuorumMet = block.timestamp;
    }



    /** OWNER **/

    function changeAllowedRecipients(address _recipient, bool _allowed) onlyOwner external returns (bool _success) {
        allowedRecipients[_recipient] = _allowed;
        emit AllowedRecipientChanged(_recipient, _allowed);
        return true;
    }

    function setFeeAddress(address _feeAddress) public onlyOwner {
        feeAddress = _feeAddress;
    }

    function setSyrupToken(IERC20 _syrupToken) public onlyOwner {
        syrupToken = _syrupToken;
    }

    function setMinQuorumDivisor(uint _minQuorumDivisor) public onlyOwner {
        require(_minQuorumDivisor <= 100, "bad value");
        require(_minQuorumDivisor > 0, "bad value");
        minQuorumDivisor = _minQuorumDivisor;
    }



    /** VIEWS **/

    function checkProposalCode(uint _proposalID, bytes calldata _transactionData) public view returns (bool _codeChecksOut) {
        Proposal storage p = proposals[_proposalID];
        return p.proposalHash == keccak256(_transactionData);
    }

    function minQuorum() internal view returns (uint _minQuorum) {
        return syrupToken.totalSupply() / minQuorumDivisor;
    }

    function numberOfProposals() public view returns (uint _numberOfProposals) {
        return proposalID;
    }

    function getActiveProposals() public view returns (ProposalFront[] memory) {
        uint256 count = 0;
        for(uint256 i = 0; i < numberOfProposals(); i++) {
            if (block.timestamp <= proposals[i].votingDeadline) {
                count++;
            }
        }
        ProposalFront[] memory activeProposals = new ProposalFront[](count);
        uint256 counter = 0;
        for(uint256 i = 0; i < numberOfProposals(); i++) {
            if (block.timestamp <= proposals[i].votingDeadline) {
                activeProposals[counter] = ProposalFront({
                    index: i,
                    title: proposals[i].title,
                    description: proposals[i].description,
                    votingDeadline: proposals[i].votingDeadline,
                    executionDeadline: proposals[i].executionDeadline,
                    open: proposals[i].open,
                    proposalPassed: proposals[i].proposalPassed,
                    proposalHash: proposals[i].proposalHash,
                    yea: proposals[i].yea,
                    nay: proposals[i].nay,
                    creator: proposals[i].creator,
                    recipient: proposals[i].recipient,
                    nativeTokens: proposals[i].nativeTokens
                });
                counter++;
            }
        }
        return activeProposals;
    }

    function getOldProposals() public view returns (ProposalFront[] memory) {
        uint256 count = 0;
        for(uint256 i = 0; i < numberOfProposals(); i++) {
            if (block.timestamp > proposals[i].votingDeadline) {
                count++;
            }
        }
        ProposalFront[] memory oldProposals = new ProposalFront[](count);
        uint256 counter = 0;
        for(uint256 i = 0; i < numberOfProposals(); i++) {
            if (block.timestamp > proposals[i].votingDeadline) {
                oldProposals[counter] = ProposalFront({
                    index: i,
                    title: proposals[i].title,
                    description: proposals[i].description,
                    votingDeadline: proposals[i].votingDeadline,
                    executionDeadline: proposals[i].executionDeadline,
                    open: proposals[i].open,
                    proposalPassed: proposals[i].proposalPassed,
                    proposalHash: proposals[i].proposalHash,
                    yea: proposals[i].yea,
                    nay: proposals[i].nay,
                    creator: proposals[i].creator,
                    recipient: proposals[i].recipient,
                    nativeTokens: proposals[i].nativeTokens
                });
                counter++;
            }
        }
        return oldProposals;
    }

    function getUserVote(uint _proposalID, address _account) external view returns (bool) {
        Proposal storage p = proposals[_proposalID];
        require(p.voted[_account] > 0, "no vote");
        if (p.votedYes[_account] == true) {
            return true;
        } 
        return false;
    }



    /** INTERNAL **/

    function _closeProposal(uint _proposalID) internal {
        Proposal storage p = proposals[_proposalID];
        p.open = false;
    }

    function _getOrModifyBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0) {
            return false;
        }
        Proposal storage p = proposals[blocked[_account]];
        if (!p.open) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }



    /** GENERAL **/

    function newProposal(
        address _recipient,
        string memory _title,
        string memory _description,
        bytes calldata _transactionData
    ) nonReentrant public returns (uint _proposalID) {

        // requires
        require(allowedRecipients[_recipient] == true, "recipient not allowed");
        require(address(msg.sender) != address(this), "err");

        // to prevent owner from halving quorum before first proposal
        if (proposalID == 0) { 
            lastTimeMinQuorumMet = block.timestamp;
        }

        // get tokens from proposer
        nativeToken.transferFrom(msg.sender, address(this), proposalPriceInNativeToken);

        // get proposal ID
        _proposalID = proposalID;

        // add proposal
        Proposal storage p = proposals[_proposalID];
        p.title = _title;
        p.description = _description;
        p.proposalHash = keccak256(_transactionData);
        p.votingDeadline = block.timestamp + proposalDebatePeriod;
        p.executionDeadline = block.timestamp + proposalDebatePeriod + executeTimelockPeriod;
        p.open = true;
        p.creator = msg.sender;
        p.recipient = _recipient;
        p.nativeTokens = proposalPriceInNativeToken;

        // increment
        proposalID++;

        // event
        emit ProposalAdded(_proposalID, _title, _description);
    }

    function vote(uint _proposalID, bool _supportsProposal) nonReentrant onlyTokenHolders public {

        // get proposal
        Proposal storage p = proposals[_proposalID];

        // unvote user
        unVote(_proposalID);

        // user amount
        uint256 amount = syrupToken.balanceOf(msg.sender);

        // vote
        if (_supportsProposal) {
            p.yea += amount;
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += amount;
            p.votedNo[msg.sender] = true;
        }

        // Set vote
        p.voted[msg.sender] = amount;

        // block user for
        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalID;
        } else if (p.votingDeadline > proposals[blocked[msg.sender]].votingDeadline) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            blocked[msg.sender] = _proposalID;
        }

        // register user vote
        emit Voted(_proposalID, _supportsProposal, msg.sender);
    }

    function unVote(uint _proposalID) onlyTokenHolders public {

        // get proposal
        Proposal storage p = proposals[_proposalID];

        // require
        require(block.timestamp < p.votingDeadline, "voting deadline reached");

        // unvote from yes
        if (p.voted[msg.sender] > 0) {
            if (p.votedYes[msg.sender]) {
                p.yea -= p.voted[msg.sender];
                p.votedYes[msg.sender] = false;
            }
            // unvote from no
            if (p.votedNo[msg.sender]) {
                p.nay -= p.voted[msg.sender];
                p.votedNo[msg.sender] = false;
            }
        }

        // Set un vote
        p.voted[msg.sender] = 0;
    }

    function executeProposal(uint _proposalID, bytes calldata _transactionData) nonReentrant payable public returns (bool _success) {
        // get proposal
        Proposal storage p = proposals[_proposalID];
        // get quorum
        uint quorum = p.yea + p.nay;

        // require
        require(block.timestamp >= p.votingDeadline, "voting still on");
        require(block.timestamp >= p.executionDeadline, "not execution time");
        require(p.open == true, "proposal is closed");
        require(p.proposalPassed == false, "not recursively");
        require(checkProposalCode(_proposalID, _transactionData) == true, "proposal doesn't match transaction data");

        // if quorum not reached
        if (quorum < minQuorum()) {
            nativeToken.transfer(feeAddress, p.nativeTokens);
            _closeProposal(_proposalID);
            return false;
        }

        // if we are over deadline and waiting period, assert proposal is closed
        if (p.open && block.timestamp > p.votingDeadline + executeProposalPeriod) {
            nativeToken.transfer(feeAddress, p.nativeTokens);
            _closeProposal(_proposalID);
            return false;
        }

        // return tokens to proposer
        nativeToken.transfer(p.creator, p.nativeTokens);

        // quorum reached
        lastTimeMinQuorumMet = block.timestamp;

        // Execute result
        if (p.yea > p.nay) {
            // we are setting this here before the CALL() value transfer to
            // assure that in the case of a malicious recipient contract trying
            // to call executeProposal() recursively money can't be transferred
            // multiple times out of the DAO
            p.proposalPassed = true;

            // this call is as generic as any transaction. It sends all gas and
            // can do everything a transaction can do. It can be used to reenter
            // the DAO. The `p.proposalPassed` variable prevents the call from 
            // reaching this line again
            (_success, ) = p.recipient.call{value: msg.value}(_transactionData);
            require(_success == true, "transaction failed");
        }

        // close the proposual
        _closeProposal(_proposalID);

        // emit event
        emit ProposalTallied(_proposalID, _success, quorum);
    }

    function unblockMe() nonReentrant public returns (bool) {
        return _getOrModifyBlocked(msg.sender);
    }

    function isUserBlocked(address _account) external view returns (bool) {
        if (numberOfProposals() == 0) {
            return false;
        }
        Proposal storage p = proposals[blocked[_account]];
        if (block.timestamp > p.votingDeadline) {
            return false;
        }
        if (p.votedYes[_account] == true || p.votedNo[_account] == true) {
            return true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./access/Operable.sol";
import "./Master.sol";
import "./ProjectPresale.sol";
import "./ProjectVotation.sol";

contract VoteIncentive is Ownable, Operable {

    struct UserInfo {
        uint256 amountClaimed;
    }

    struct Reward {
        address tokenAddress;
        uint256 amount;
    }

    mapping(address => UserInfo) public userInfo;
    Reward[] public rewards;
    IERC20 public nativeToken;

    constructor(IERC20 _nativeToken, address _operator) {
        nativeToken = _nativeToken;
        transferOperable(_operator);
    }

    event Harvest(address indexed user, uint256 amount);
    event AddReward(address indexed tokenAddress, uint256 amount);


    /** VIEWS **/

    function getUserAvailableToClaim(address _user) public view returns(uint256) {
        uint256 userTotalRewards = getUserTotalRewards(_user);
        return userTotalRewards - userInfo[_user].amountClaimed;
    }

    function getUserTotalRewards(address _user) public view returns(uint256) {
        uint256 userTotalRewards = 0;
        for(uint256 i = 0; i < rewards.length; i++) {
            ProjectVotation.Votation memory votation = Master(operator).projectVotation().getVotation(address(rewards[i].tokenAddress));
            (, uint256 yes, uint256 no) = Master(operator).projectVotation().userVotes(address(rewards[i].tokenAddress), _user);
            uint256 userVotes = yes + no;
            uint256 totalVotes = votation.yes + votation.no;
            if (userVotes > 0 && totalVotes > 0) {
                userTotalRewards += rewards[i].amount * userVotes / totalVotes;
            }
        }
        return userTotalRewards;
    }


    /** GENERAL **/

    function harvest() public {
        uint256 amountToClaim = getUserAvailableToClaim(msg.sender);
        require(amountToClaim > 0, "nothing to claim");
        userInfo[msg.sender].amountClaimed += amountToClaim;
        nativeToken.transfer(msg.sender, amountToClaim);
        emit Harvest(msg.sender, amountToClaim);
    }


    /** OPERATOR **/

    function addRewardOperator(address _tokenAddress, uint256 _amount) public onlyOperator {
        _addReward(_tokenAddress, _amount);
    }


    /** OWNER **/

    function addReward(address _tokenAddress, uint256 _amount) public onlyOwner {
        _addReward(_tokenAddress, _amount);
    }


    /** INTERNAL **/

    function _addReward(address _tokenAddress, uint256 _amount) internal {
        nativeToken.transferFrom(msg.sender, address(this), _amount);
        rewards.push(Reward({
            tokenAddress: _tokenAddress,
            amount: _amount
        }));
        emit AddReward(_tokenAddress, _amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: UNLINCESED

pragma solidity ^0.8.6;

contract AnyCall {

    // Context information for destination chain targets
    struct Context {
        address sender;
        uint256 fromChainID;
    }

    // Packed fee information (only 1 storage slot)
    struct FeeData {
        uint128 accruedFees;
        uint128 premium;
    }

    // Packed MPC transfer info (only 1 storage slot)
    struct TransferData {
        uint96 effectiveTime;
        address pendingMPC;
    }

    // Extra cost of execution (SSTOREs.SLOADs,ADDs,etc..)
    // TODO: analysis to verify the correct overhead gas usage
    uint256 constant EXECUTION_OVERHEAD = 100000;

    address public mpc;
    mapping(address => bool) public executors;
    TransferData private _transferData;

    mapping(address => bool) public blacklist;
    mapping(address => mapping(address => mapping(uint256 => bool))) public whitelist;
    
    Context public context;

    mapping(address => uint256) public executionBudget;
    FeeData private _feeData;

    event LogAnyCall(
        address indexed from,
        address indexed to,
        bytes data,
        address _fallback,
        uint256 indexed toChainID
    );

    event LogAnyExec(
        address indexed from,
        address indexed to,
        bytes data,
        bool success,
        bytes result,
        address _fallback,
        uint256 indexed fromChainID
    );

    event Deposit(address indexed account, uint256 amount);
    event Withdrawl(address indexed account, uint256 amount);
    event SetBlacklist(address indexed account, bool flag);
    event SetWhitelist(
        address indexed from,
        address indexed to,
        uint256 indexed toChainID,
        bool flag
    );
    event TransferMPC(address oldMPC, address newMPC, uint256 effectiveTime);
    event UpdatePremium(uint256 oldPremium, uint256 newPremium);

    constructor(address _mpc, uint128 _premium) {
        mpc = _mpc;
        _feeData.premium = _premium;

        emit TransferMPC(address(0), _mpc, block.timestamp);
        emit UpdatePremium(0, _premium);
    }

    /// @dev Access control function
    modifier onlyAdmin() {
        require(msg.sender == mpc); // dev: only MPC
        _;
    }

    /// @dev Access control function
    modifier onlyExecutors() {
        require(executors[msg.sender] == true); // dev: only MPC
        _;
    }

    /// @dev Charge an account for execution costs on this chain
    /// @param _from The account to charge for execution costs
    modifier charge(address _from) {
        uint256 gasUsed = gasleft() + EXECUTION_OVERHEAD;
        _;
        uint256 totalCost = (gasUsed - gasleft()) * (tx.gasprice + _feeData.premium);

        executionBudget[_from] -= totalCost;
        _feeData.accruedFees += uint128(totalCost);
    }

    /**
        @notice Submit a request for a cross chain interaction
        @param _to The target to interact with on `_toChainID`
        @param _data The calldata supplied for the interaction with `_to`
        @param _fallback The address to call back on the originating chain
            if the cross chain interaction fails
        @param _toChainID The target chain id to interact with
    */
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID
    ) external {
        require(!blacklist[msg.sender]); // dev: caller is blacklisted
        require(whitelist[msg.sender][_to][_toChainID]); // dev: request denied

        emit LogAnyCall(msg.sender, _to, _data, _fallback, _toChainID);
    }

    /**
        @notice Execute a cross chain interaction
        @dev Only callable by the MPC
        @param _from The request originator
        @param _to The cross chain interaction target
        @param _data The calldata supplied for interacting with target
        @param _fallback The address to call on `_fromChainID` if the interaction fails
        @param _fromChainID The originating chain id
    */
    function anyExec(
        address _from,
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _fromChainID
    ) external charge(_from) onlyExecutors {
        context = Context({sender: _from, fromChainID: _fromChainID});
        (bool success, bytes memory result) = _to.call(_data);
        context = Context({sender: address(0), fromChainID: 0});

        emit LogAnyExec(_from, _to, _data, success, result, _fallback, _fromChainID);

        // Call the fallback on the originating chain with the call information (to, data)
        // _from, _fromChainID, _toChainID can all be identified via contextual info
        if (!success && _fallback != address(0)) {
            emit LogAnyCall(
                _from,
                _fallback,
                abi.encodeWithSignature("anyFallback(address,bytes)", _to, _data),
                address(0),
                _fromChainID
            );
        }
    }

    /// @notice Deposit native currency crediting `_account` for execution costs on this chain
    /// @param _account The account to deposit and credit for
    function deposit(address _account) external payable {
        executionBudget[_account] += msg.value;
        emit Deposit(_account, msg.value);
    }

    /// @notice Withdraw a previous deposit from your account
    /// @param _amount The amount to withdraw from your account
    function withdraw(uint256 _amount) external {
        executionBudget[msg.sender] -= _amount;
        emit Withdrawl(msg.sender, _amount);
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success);
    }

    /// @notice Withdraw all accrued execution fees
    /// @dev The MPC is credited in the native currency
    function withdrawAccruedFees() external {
        uint256 fees = _feeData.accruedFees;
        _feeData.accruedFees = 0;
        (bool success,) = mpc.call{value: fees}("");
        require(success);
    }

    /// @notice Set the whitelist premitting an account to issue a cross chain request
    /// @param _from The account which will submit cross chain interaction requests
    /// @param _to The target of the cross chain interaction
    /// @param _toChainID The target chain id
    function setWhitelist(
        address _from,
        address _to,
        uint256 _toChainID,
        bool _flag
    ) external onlyAdmin {
        require(_toChainID != block.chainid, "AnyCall: Forbidden");
        whitelist[_from][_to][_toChainID] = _flag;
        emit SetWhitelist(_from, _to, _toChainID, _flag);
    }

    /// @notice Set an account's blacklist status
    /// @dev A simpler way to deactive an account's permission to issue
    ///     cross chain requests without updating the whitelist
    /// @param _account The account to update blacklist status of
    /// @param _flag The blacklist state to put `_account` in
    function setBlacklist(address _account, bool _flag) external onlyAdmin {
        blacklist[_account] = _flag;
        emit SetBlacklist(_account, _flag);
    }

    /// @notice Set the premimum for cross chain executions
    /// @param _premium The premium per gas
    function setPremium(uint128 _premium) external onlyAdmin {
        emit UpdatePremium(_feeData.premium, _premium);
        _feeData.premium = _premium;
    }

    /// @notice Initiate a transfer of MPC status
    /// @param _newMPC The address of the new MPC
    function changeMPC(address _newMPC) external onlyAdmin {
        mpc = _newMPC;
    }

    /// @notice Get the total accrued fees in native currency
    /// @dev Fees increase when executing cross chain requests
    function accruedFees() external view returns(uint128) {
        return _feeData.accruedFees;
    }

    /// @notice Get the gas premium cost
    /// @dev This is similar to priority fee in eip-1559, except instead of going
    ///     to the miner it is given to the MPC executing cross chain requests
    function premium() external view returns(uint128) {
        return _feeData.premium;
    }

    /// @notice Get the effective time at which pendingMPC may become MPC
    function effectiveTime() external view returns(uint256) {
        return _transferData.effectiveTime;
    }
    
    /// @notice Get the address of the pending MPC
    function pendingMPC() external view returns(address) {
        return _transferData.pendingMPC;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";