//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/INovationRouter02.sol";
import "./interfaces/INovationPair.sol";
import "./interfaces/INovationFactory.sol";

struct PoolParam {
    uint hardCap;
    uint softCap;
    uint minInvest;
    uint maxInvest;
    uint startTime;
    uint endTime;
    uint salePrice;
    uint listPrice;
    uint liquidityAlloc;
    bool isBurnForUnsold;
}

interface IPool {
    function token() external view returns (address);
    function hardcap() external view returns (uint);
    function softcap() external view returns (uint);
    function maxInvestable() external view returns (uint);
    function minInvestable() external view returns(uint);
    function startTime() external view returns (uint);
    function endTime() external view returns (uint);
    function salePrice() external view returns(uint);
    function publicMode() external view returns (bool);
    function tokenOwner() external view returns (address);
}

contract PresalePool is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    bool public publicMode;
    mapping(address => bool) public whitelist;
    mapping(address => uint) public invests;
    address[] public investors;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    INovationRouter02 public immutable router;

    uint public maxInvestable = 100 ether;
    uint public minInvestable;
    uint public hardcap = 10000 ether;
    uint public softcap;
    bool public canceled;
    bool public enabled = true;
    // bool public ended;
    bool public finalized;
    uint public startTime;
    uint public endTime;

    uint public raised;

    uint public salePrice;
    uint public listPrice;
    uint public liquidityAlloc;
    bool public isBurnForUnsold;

    bool public enabledClaim;
    mapping(address => bool) public claimed;
    uint public totalClaimed;
    bool public enabledRefund;
    mapping(address => bool) public refunded;

    address public tokenOwner;

    address public bnbFeeWallet = 0xe327c0F351eC6809c0339EF75e7DF1A225e90Fae;
    address public tokenFeeWallet = 0xe327c0F351eC6809c0339EF75e7DF1A225e90Fae;
    uint public bnbFee = 400; // 4%
    uint public tokenFee;
    uint public constant feeDenominator = 10000;

    uint public minBnbAllocToLiquidity = 5000; // 50%
    uint public minTokenAllocToLiquidity = 1000; // 10%

    modifier onlyTokenOwner {
        require (msg.sender == tokenOwner, "!token owner");
        _;
    }

    modifier beforeStarted {
        require (!(enabled && block.timestamp >= startTime), "sale already started");
        _;
    }

    modifier beforeEnded {
        require (block.timestamp < endTime, "ended");
        _;
    }

    modifier onlyStarted {
        require (enabled && block.timestamp >= startTime, "sale isn't started");
        _;
    }

    constructor(
        address _token, 
        address _router,
        address _owner
    ) {
        token = IERC20(_token);
        tokenOwner = _owner;
        router = INovationRouter02(_router);
    }

    function initialize(
        PoolParam calldata _args, 
        address[] calldata _whitelist
    ) external onlyOwner {
        require (_args.hardCap > 0, "!hardcap");
        require (_args.softCap <= _args.hardCap, "!softcap");
        hardcap = _args.hardCap;
        if (_args.softCap > 0) softcap = _args.softCap;
        
        minInvestable = _args.minInvest == 0 ? 0.01 ether : _args.minInvest;
        maxInvestable = _args.maxInvest == 0 ? hardcap : _args.maxInvest;
        require (minInvestable <= maxInvestable, "!min investable");
        
        startTime = _args.startTime == 0 ? (block.timestamp + 1 hours) : _args.startTime;
        endTime = _args.endTime == 0 ? (block.timestamp + 2 days) : _args.endTime;
        require (startTime > block.timestamp, "!start time");
        require (startTime < endTime, "!end time");

        require (_args.salePrice > 0, "!sale price");
        salePrice = _args.salePrice;
        listPrice = _args.listPrice;
        require (_args.liquidityAlloc < feeDenominator, "!lp alloc");
        liquidityAlloc = _args.liquidityAlloc;
        isBurnForUnsold = _args.isBurnForUnsold;

        if (_whitelist.length > 0) {
            for (uint i = 0; i < _whitelist.length; i++) whitelist[_whitelist[i]] = true;
        } else {
            publicMode = true;
        }
    }

    function setPublicMode(bool _flag) external beforeStarted onlyTokenOwner {
        publicMode = _flag;
    }

    function setWhilteList(address[] memory _accounts, bool _flag) external beforeStarted onlyTokenOwner {
        for (uint i = 0; i < _accounts.length; i++) {
            if (whitelist[_accounts[i]] != _flag) whitelist[_accounts[i]] = _flag;
        }
    }

    function setInvestable(uint _min, uint _max) external beforeStarted onlyTokenOwner {
        require (_min <= _max, "invalid amount");
        minInvestable = _min;
        maxInvestable = _max;
    }

    function setCap(uint _soft, uint _hard) external beforeStarted onlyTokenOwner {
        require (_soft <= _hard, "invalid cap");
        softcap = _soft;
        hardcap = _hard;
    }

    function updateStartTime(uint _start) external beforeStarted onlyTokenOwner {
        require (block.timestamp <= _start, "!start time");
        startTime = _start;
    }

    function updateEndTime(uint _end) external beforeEnded onlyTokenOwner {
        if (_end > 0) { 
            require (_end > block.timestamp && _end > startTime, "!end time");
            endTime = _end;
        } else endTime = type(uint).max;
    }

    function setSalePrice(uint _price) external beforeStarted onlyTokenOwner {
        require (!enabledClaim, "already in claiming");
        salePrice = _price;
    }

    function setListingPrice(uint _price) external onlyTokenOwner {
        require (!finalized, "already listed");
        listPrice = _price;
    }

    function setLiquidityAlloc(uint _alloc) external onlyTokenOwner {
        require (!finalized, "already listed");
        require (_alloc <= feeDenominator - bnbFee, "!percent");
        liquidityAlloc = _alloc;
    }

    function toggleBurnForUnsold() external onlyTokenOwner {
        isBurnForUnsold = !isBurnForUnsold;
    }

    function cancelSale() external onlyTokenOwner {
        require (block.timestamp < startTime, "sale started");

        uint deposit = token.balanceOf(address(this));
        if (deposit > 0) token.safeTransfer(tokenOwner, deposit);

        canceled = true;
        enabled = false;
    }

    function enableSale() external onlyTokenOwner {
        require (!canceled, "canceled pool");
        require (token.balanceOf(address(this)) >= salePrice*hardcap/1e18, "!enough tokens");
        enabled = true;
    }

    function endSale() external onlyStarted onlyTokenOwner {
        // ended = true;
        endTime = block.timestamp;
    }

    // function enableClaim() external onlyTokenOwner {
    //     require (block.timestamp >= endTime, "!available");
    //     require (finalized, "!finalized");
    //     enabledClaim = true;
    // }

    function enableRefund() external onlyTokenOwner {
        require (block.timestamp >= endTime, "still in sale");
        require (!finalized, "already finalized");

        uint deposit = token.balanceOf(address(this));
        if (deposit > 0) token.safeTransfer(tokenOwner, deposit);

        enabledRefund = true;
    }

    function invest() external payable {
        require (msg.value > 0, "!invest");
        _invest();
    }

    function _invest() internal nonReentrant {
        require (enabled, "!enabld sale");
        require (block.timestamp >= startTime, "!started");
        require (block.timestamp < endTime, "ended");
        if (publicMode == false) require (whitelist[msg.sender] == true, "!whitelisted");
        require (raised + msg.value <= hardcap, "filled hardcap");
        require (invests[msg.sender] + msg.value <= maxInvestable, "exceeded invest");
        if (invests[msg.sender] == 0) {
            require (msg.value >= minInvestable, "too small invest");
        }

        if (invests[msg.sender] == 0) investors.push(msg.sender);
        
        invests[msg.sender] += msg.value;
        raised += msg.value;
    }

    function claim() external nonReentrant {
        require (invests[msg.sender] > 0, "!investor");
        require (enabledClaim == true, "!available");
        require (claimed[msg.sender] == false, "already claimed");

        uint claimAmount = salePrice * invests[msg.sender] / 1e18;

        require (claimAmount <= token.balanceOf(address(this)), "no balance");
        
        token.safeTransfer(msg.sender, claimAmount);

        claimed[msg.sender] = true;
        totalClaimed += claimAmount;
    }

    function multiSend() external onlyTokenOwner {
        require (enabledClaim == true, "!available");

        for (uint i = 0; i < investors.length; i++) {
            address investor = investors[i];
            if (claimed[investor] == true) continue;

            uint claimAmount = salePrice * invests[investor] / 1e18;

            require (claimAmount <= token.balanceOf(address(this)), "no balance");
            
            token.safeTransfer(investor, claimAmount);

            claimed[investor] = true;
            totalClaimed += claimAmount;
        }
    }

    function finalize() external onlyTokenOwner {
        require (enabledRefund == false, "enabled refund");
        require (block.timestamp >= endTime, "!end");
        require (raised >= softcap, "failed");
        
        if (liquidityAlloc == 0) {
            withdraw();
            return;
        }

        require (liquidityAlloc >= minBnbAllocToLiquidity, "!bnb percent");
        uint _bnbAmount = liquidityAlloc * raised / feeDenominator;
        uint _tokenAmount = _bnbAmount * listPrice / 1e18;
        require (_tokenAmount >= minTokenAllocToLiquidity * token.totalSupply() / feeDenominator, "!token percent");

        
        INovationFactory factory = INovationFactory(router.factory());
        INovationPair pair = INovationPair(factory.getPair(address(token), router.WETH()));
        if (address(pair) == address(0)) {
            pair = INovationPair(INovationFactory(router.factory()).createPair(
                address(token),
                router.WETH()
            ));
        }

        require (pair.totalSupply() == 0, "liquidity exsits");

        uint _before = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), _tokenAmount);
        uint _after = token.balanceOf(address(this));
        require (_after - _before >= _tokenAmount, "!liquidity tokens");

        token.approve(address(router), _tokenAmount);
        router.addLiquidityETH{value: _bnbAmount}(
            address(token),
            _tokenAmount,
            0,
            0,
            tokenOwner,
            block.timestamp
        );

        uint feeAmount = raised * bnbFee / feeDenominator;
        if (feeAmount > 0) {
            address(bnbFeeWallet).call{value: feeAmount}("");
        }
        address(tokenOwner).call{value: raised - _bnbAmount - feeAmount}("");

        if (tokenFee > 0) {
            feeAmount = (salePrice * hardcap / 1e18) * tokenFee / feeDenominator;
            token.safeTransferFrom(msg.sender, tokenFeeWallet, feeAmount);
        }

        finalized = true;
        enabledClaim = true;
    }

    function withdraw() internal {
        uint feeAmount = raised * bnbFee / feeDenominator;
        if (feeAmount > 0) {
            address(bnbFeeWallet).call{value: feeAmount}("");
        }
        address(tokenOwner).call{value: raised - feeAmount}("");

        if (tokenFee > 0) {
            feeAmount = (salePrice * hardcap / 1e18) * tokenFee / feeDenominator;
            token.safeTransferFrom(msg.sender, tokenFeeWallet, feeAmount);
        }

        finalized = true;
        enabledClaim = true;
    }

    function transferUnsold() external {
        require (msg.sender == owner() || msg.sender == tokenOwner, "!owner");
        require (finalized, "!available");
        require (hardcap > raised, "filled");
        uint unsold = salePrice * (hardcap - raised) / 1e18;
        if (isBurnForUnsold) token.safeTransfer(DEAD, unsold);
        else token.safeTransfer(tokenOwner, unsold);
    }

    function getRefund() external nonReentrant {
        require (enabledRefund == true, "!available");
        require (invests[msg.sender] > 0, "!investor");
        require (refunded[msg.sender] == false, "already returned");
        address(msg.sender).call{value: invests[msg.sender]}("");
        refunded[msg.sender] = true;
    }

    function claimable(address _user) external view returns(uint) {
        return salePrice * invests[_user] / 1e18;
    }

    function getInvestors() external view returns (address[] memory, uint[] memory) {
        uint[] memory amountList = new uint[](investors.length);
        for (uint i = 0; i < investors.length; i++) {
            amountList[i] = invests[investors[i]];
        }

        return (investors, amountList);
    }

    function count() external view returns (uint) {
        return investors.length;
    }

    function saleAmount() external view returns (uint amount) {
        amount = salePrice * raised / 1e18;
    }

    function started() external view returns (bool) {
        return (block.timestamp >= startTime) && enabled;
    }

    function ended() public view returns (bool) {
        return (block.timestamp >= endTime);
    }

    function setFee(uint _bnbFee, uint _tokenFee) external onlyOwner {
        bnbFee = _bnbFee;
        tokenFee = _tokenFee;
    }

    function setFeeWallets(address _bnbWallet, address _tokenWallet) external onlyOwner {
        bnbFeeWallet = _bnbWallet;
        tokenFeeWallet = _tokenWallet;
    }

    function setLimitForLiquidity(uint _bnb, uint _token) external onlyOwner {
        require (_bnb > 0 && _bnb <= feeDenominator, "invalid");
        require (_token > 0 && _token <= feeDenominator, "invalid");
        minBnbAllocToLiquidity = _bnb;
        minTokenAllocToLiquidity = _token;
    }

    // function getTokensInStuck() external onlyTokenOwner {
    //     uint256 _bal = token.balanceOf(address(this));
    //     if (_bal > 0) token.safeTransfer(msg.sender, _bal);
    // }

    receive() external payable {
        // _invest();
        revert ("!available to send BNB directly");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import "./INovationRouter01.sol";

interface INovationRouter02 is INovationRouter01 {
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface INovationPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface INovationFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

    function existToken(address) external view returns (bool);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface INovationRouter01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}