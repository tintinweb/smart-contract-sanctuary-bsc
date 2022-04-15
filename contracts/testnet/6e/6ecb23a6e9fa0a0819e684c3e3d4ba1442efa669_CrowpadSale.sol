/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library AddressUpgradeable {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

interface IERC20Upgradeable {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMathUpgradeable {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            
            
            
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    
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

interface ICrowpadSale {

    struct InitParams {
        uint256 saleRate;
        uint256 saleRateDecimals;
        uint256 listingRate;
        uint256 listingRateDecimals;
        uint256 liquidityPercent;
        address payable wallet;
        address router;
        address token;
        address baseToken;
        uint256 softCap;
        uint256 hardCap;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 startTime;
        uint256 endTime;
        uint256 unlockTime;
        bool whitelistEnabled;
    }
    function initialize(
        ICrowpadSale.InitParams calldata params,
        address locker
    ) external;

    function setLogo(string memory logo_) external;
    function addWhitelistAdmin(address account) external;
    function transferOwnership(address account) external;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
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

abstract contract ReentrancyGuardUpgradeable is Initializable {
    
    
    
    
    

    
    
    
    
    
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    
    modifier nonReentrant() {
        
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        
        _status = _ENTERED;

        _;

        
        
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        
        
        
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Crowdsale is Initializable, ContextUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    
    IERC20Upgradeable private _token;
    address private _baseToken;

    
    address payable private _wallet;

    
    
    
    
    uint256 private _rate;
    uint256 private _rateDecimals;

    
    uint256 private _weiRaised;

    
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    
    event ClaimRefunded(address indexed beneficiary, uint256 value);

    
    
    function __Crowdsale_init(uint256 rate_, uint256 rateDecimals_, address payable wallet_, IERC20Upgradeable token_, address baseToken_) internal onlyInitializing {
        __Ownable_init_unchained();
        __Context_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Crowdsale_init_unchained(rate_, rateDecimals_, wallet_, token_, baseToken_);
    }

    function __Crowdsale_init_unchained(uint256 rate_, uint256 rateDecimals_, address payable wallet_, IERC20Upgradeable token_, address baseToken_) internal onlyInitializing {
        require(rate_ > 0, "Crowdsale: rate is 0");
        require(rateDecimals_ <= 24, "Crowdsale: rate decimals must be smaller than 24");
        require(wallet_ != address(0), "Crowdsale: wallet is the zero address");
        require(address(token_) != address(0), "Crowdsale: token is the zero address");

        _rate = rate_;
        _rateDecimals = rateDecimals_;
        _wallet = wallet_;
        _token = token_;
        _baseToken = baseToken_;
    }

    
    receive () external payable {
        buyTokens(_msgSender());
    }

    
    function token() public view returns (IERC20Upgradeable) {
        return _token;
    }

    function isBaseTokenEnabled() public view returns (bool) {
        return _baseToken != address(0);
    }

    
    function baseToken() public view returns (IERC20Upgradeable) {
        return IERC20Upgradeable(_baseToken);
    }

    
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    
    function rate() public view virtual returns (uint256) {
        return _rate;
    }

    
    function rateDecimals() public view virtual returns (uint256) {
        return _rateDecimals;
    }

    
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    
    function buyTokens(address beneficiary) public nonReentrant payable {
        require(_baseToken == address(0), "Purchasing with ETH is disabled");
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        
        uint256 tokens = _getTokenAmount(weiAmount);

        
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds(beneficiary);
        _postValidatePurchase(beneficiary, weiAmount);
    }
    
    
    function buyTokensWithTokens(address beneficiary, uint256 amount) public nonReentrant payable {

        require(_baseToken != address(0), "Purchasing with token is disabled");

        IERC20Upgradeable baseErc20 = IERC20Upgradeable(_baseToken);
        uint256 balanceBefore = baseErc20.balanceOf(address(this));
        IERC20Upgradeable(_baseToken).transferFrom(msg.sender, address(this), amount);
        uint256 balanceEnd = baseErc20.balanceOf(address(this));

        uint256 weiAmount = balanceEnd.sub(balanceBefore);

        require(weiAmount > 0, "fake purchase");

        _preValidatePurchase(beneficiary, weiAmount);
        
        
        uint256 tokens = _getTokenAmount(weiAmount);

        
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds(beneficiary);
        _postValidatePurchase(beneficiary, weiAmount);
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal virtual {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; 
    }

    
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        
    }

    
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal virtual {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal virtual {
        _deliverTokens(beneficiary, tokenAmount);
    }

    
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal virtual {
        
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view virtual returns (uint256) {
        return weiAmount.mul(_rate).div(10**_rateDecimals);
    }

    
    function _forwardFunds(address sender) internal virtual {
        _wallet.transfer(msg.value);
    }
}

abstract contract CappedCrowdsale is Initializable, Crowdsale {
    using SafeMathUpgradeable for uint256;

    uint256 private _cap;

    function __CappedCrowdsale_init(uint256 cap_) internal onlyInitializing {
        __CappedCrowdsale_init_unchained(cap_);
    }

    function __CappedCrowdsale_init_unchained(uint256 cap_) internal onlyInitializing {
        require(cap_ > 0, "CappedCrowdsale: cap is 0");
        _cap = cap_;
    }

    
    function cap() public view returns (uint256) {
        return _cap;
    }

    
    function capReached() public view returns (bool) {
        return weiRaised() >= _cap;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal virtual override {
        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiRaised().add(weiAmount) <= _cap, "CappedCrowdsale: cap exceeded");
    }
}

abstract contract TimedCrowdsale is Initializable, Crowdsale {
    using SafeMathUpgradeable for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    
    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

    
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    function __TimedCrowdsale_init(uint256 openingTime_, uint256 closingTime_) internal onlyInitializing {
        __TimedCrowdsale_init_unchained(openingTime_, closingTime_);
    }

    function __TimedCrowdsale_init_unchained(uint256 openingTime_, uint256 closingTime_) internal onlyInitializing {
        
        require(openingTime_ >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        
        require(closingTime_ > openingTime_, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime_;
        _closingTime = closingTime_;
    }

    
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    
    function isOpen() public view returns (bool) {
        
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    
    function hasClosed() public view returns (bool) {
        
        return block.timestamp > _closingTime;
    }

    
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen virtual override {
        super._preValidatePurchase(beneficiary, weiAmount);
    }

    
    function _extendTime(uint256 newClosingTime) internal {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract WhitelistAdminRole is Initializable, ContextUpgradeable {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    function __WhitelistAdminRole_init() internal onlyInitializing {
        __Context_init_unchained();
        __WhitelistAdminRole_init_unchained();
    }

    function __WhitelistAdminRole_init_unchained() internal onlyInitializing {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

contract WhitelistedRole is Initializable, ContextUpgradeable, WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    function __WhitelistedRole_init() internal onlyInitializing {
        __Context_init_unchained();
        __WhitelistAdminRole_init_unchained();
        __WhitelistedRole_init_unchained();
    }

    function __WhitelistedRole_init_unchained() internal onlyInitializing {
    }


    modifier onlyWhitelisted() {
        require(isWhitelisted(_msgSender()), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function addWhitelistedAddresses(address[] memory accounts) public onlyWhitelistAdmin {
        for (uint256 i = 0; i < accounts.length; ++i) {
            _addWhitelisted(accounts[i]);
        }
    }

    function removeWhitelistedAddresses(address[] memory accounts) public onlyWhitelistAdmin {
        for (uint256 i = 0; i < accounts.length; ++i) {
            _removeWhitelisted(accounts[i]);
        }
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(_msgSender());
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

abstract contract WhitelistCrowdsale is Initializable, WhitelistedRole, Crowdsale {
    bool public whitelistEnabled;


    function __WhitelistCrowdsale_init(bool whitelistEnabled_) internal onlyInitializing {
        __WhitelistCrowdsale_init_unchained(whitelistEnabled_);
        __WhitelistedRole_init_unchained();
    }

    function __WhitelistCrowdsale_init_unchained(bool whitelistEnabled_) internal onlyInitializing {
        whitelistEnabled = whitelistEnabled_;
    }
    
    
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal virtual override {
        require(!whitelistEnabled || isWhitelisted(_beneficiary), "WhitelistCrowdsale: beneficiary doesn't have the Whitelisted role");
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

    function setWhitelistEnabled(bool whitelistEnabled_) public onlyOwner {
        whitelistEnabled = whitelistEnabled_;
    }
}

abstract contract FinalizableCrowdsale is Initializable, TimedCrowdsale {
    using SafeMathUpgradeable for uint256;

    bool private _finalized;
    bool private _canceled;
    uint256 public constant FINALIZE_EXPIRATION = 7 days;

    event CrowdsaleFinalized();
    event CrowdsaleCanceled();

    function _FinalizableCrowdsale_init() internal onlyInitializing {
        __FinalizableCrowdsale_init_unchained();
    }

    function __FinalizableCrowdsale_init_unchained() internal onlyInitializing {
        _finalized = false;
        _canceled = false;
    }

    
    function finalized() public view returns (bool) {
        return _finalized;
    }

    
    function canceled() public view returns (bool) {
        return _canceled;
    }

    function expired() public view returns (bool) {
        return closingTime() <= block.timestamp - FINALIZE_EXPIRATION;
    }

    
    function finalize() public onlyOwner{
        require(!_finalized, "FinalizableCrowdsale: already finalized");
        require(!_canceled, "FinalizableCrowdsale: already canceled");
        require(hasClosed() || _filled(), "FinalizableCrowdsale: not closed");

        _finalized = true;
        _finalization();
        emit CrowdsaleFinalized();
    }

    
    function cancel() public onlyOwner{
        require(!_finalized, "FinalizableCrowdsale: already finalized");
        require(!_canceled, "FinalizableCrowdsale: already canceled");

        _canceled = true;

        _cancelation();
        emit CrowdsaleCanceled();
    }

    function _finalization() internal virtual {
        
    }
    function _cancelation() internal virtual {
        
    }

    function _filled() internal virtual returns (bool) {
        return false;
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
}

interface IUnipswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface ICrowLock {
  function lock(
    address owner,
    address token,
    bool isLpToken,
    uint256 amount,
    uint256 unlockDate
  ) external payable returns (uint256 id);
}

abstract contract LiquidityCrowdsale is Initializable, FinalizableCrowdsale {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 private _listingRate;
    uint256 private _listingRateDecimals;
    uint256 private _liquidityPercent; 
    uint256 private _liquidityUnlockTime;
    uint256 private _lockId;
    IUniswapV2Router02 public uniswapV2Router;
    ICrowLock public locker;

    function _LiquidityCrowdsale_init(uint256 listingRate_, uint256 listingRateDecimals_, uint256 liquidityPercent_, uint256 liquidityUnlockTime_, address locker_, address router_) internal onlyInitializing {
        __LiquidityCrowdsale_init_unchained(listingRate_, listingRateDecimals_, liquidityPercent_, liquidityUnlockTime_, locker_, router_);
    }

    function __LiquidityCrowdsale_init_unchained(uint256 listingRate_, uint256 listingRateDecimals_, uint256 liquidityPercent_, uint256 liquidityUnlockTime_, address locker_, address router_) internal onlyInitializing {
        require(listingRateDecimals_ <= 24, "listing rate decimals must be smaller than 24");
        require(liquidityPercent_ >= 50 && liquidityPercent_ <= 100, "liquidity percent must be in 50-100");
        _listingRate = listingRate_;
        _listingRateDecimals = listingRateDecimals_;
        _liquidityPercent = liquidityPercent_;
        _liquidityUnlockTime = liquidityUnlockTime_;
        locker = ICrowLock(locker_);
        uniswapV2Router = IUniswapV2Router02(router_);
    }

    
    function listingRate() public view returns (uint256) {
        return _listingRate;
    }

    
    function listingRateDecimals() public view returns (uint256) {
        return _listingRateDecimals;
    }

    
    function liquidityPercent() public view returns (uint256) {
        return _liquidityPercent;
    }

    function liquidityUnlockTime() public view returns (uint256) {
        return _liquidityUnlockTime;
    }

    function lockId() public view returns (uint256) {
        return _lockId;
    }

    function _getLiquidityTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_listingRate).div(10**_listingRateDecimals);
    }

    function _addLiquidityETH() private {
        uint256 ethAmount = address(this).balance.mul(_liquidityPercent).div(100);
        uint256 tokenAmount = _getLiquidityTokenAmount(ethAmount);
        
        token().approve(address(uniswapV2Router), tokenAmount);

        
        uint256 liquidity;
        (,,liquidity) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(token()),
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );

        

        address tokenA = uniswapV2Router.WETH();
        address tokenB = address(token());
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        address pairToken = IUnipswapV2Factory(uniswapV2Router.factory()).getPair(token0, token1);

        IERC20Upgradeable(pairToken).approve(address(locker), liquidity);
        _lockId = locker.lock{value: 0}(
            wallet(),
            pairToken,
            true,
            liquidity,
            _liquidityUnlockTime
        );
    }
    function _addLiquidityToken() private {
        IERC20Upgradeable baseErc20 = baseToken();
        uint256 balance = baseErc20.balanceOf(address(this));
        uint256 ethAmount = balance.mul(_liquidityPercent).div(100);
        uint256 tokenAmount = _getLiquidityTokenAmount(ethAmount);
        
        token().approve(address(uniswapV2Router), tokenAmount);
        baseErc20.approve(address(uniswapV2Router), ethAmount);

        
        uint256 liquidity;
        (,,liquidity) = uniswapV2Router.addLiquidity(
            address(baseErc20),
            address(token()),
            ethAmount,
            tokenAmount,
            0, 
            0, 
            address(this),
            block.timestamp
        );

        

        address tokenA = address(baseErc20);
        address tokenB = address(token());
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        address pairToken = IUnipswapV2Factory(uniswapV2Router.factory()).getPair(token0, token1);

        IERC20Upgradeable(pairToken).approve(address(locker), liquidity);
        _lockId = locker.lock{value: 0}(
            wallet(),
            pairToken,
            true,
            liquidity,
            _liquidityUnlockTime
        );
    }

    function _addLiquidity() internal {
        if (isBaseTokenEnabled()) {
            _addLiquidityToken();
        } else {
            _addLiquidityETH();
        }
    }
}

abstract contract RefundableCrowdsale is Initializable, ContextUpgradeable, LiquidityCrowdsale {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address payable;

    enum State {
        Active,
        Refunding,
        Closed
    }

    
    uint256 private _goal;

    mapping(address => uint256) private _deposits;
    State private _state;

    function _RefundableCrowdsale_init(uint256 goal_) internal onlyInitializing {
        __Context_init_unchained();
        __RefundableCrowdsale_init_unchained(goal_);
    }

    function __RefundableCrowdsale_init_unchained(uint256 goal_) internal onlyInitializing {
        require(goal_ > 0, "RefundableCrowdsale: goal is 0");
        _state = State.Active;
        _goal = goal_;
    }

    
    function goal() public view returns (uint256) {
        return _goal;
    }

    
    function claimRefund(address payable refundee) public {
        require(_state == State.Refunding, "RefundEscrow: can claim refund while refunding");
        require(_deposits[refundee] > 0 , "RefundEscrow: deposits is zero");

        uint256 payment = _deposits[refundee];
        _deposits[refundee] = 0;

        if (isBaseTokenEnabled()) {
            baseToken().safeTransfer(refundee, payment);
        } else {
            refundee.sendValue(payment);
        }

        emit ClaimRefunded(refundee, payment);
    }

    function depositOf(address account) public view returns (uint256) {
        return _deposits[account];
    }

    
    function goalReached() public view returns (bool) {
        return weiRaised() >= _goal;
    }

    
    function _finalization() internal virtual override {
        if (goalReached()) {
            _state = State.Closed;
        } else {
            _state = State.Refunding;
        }

        super._finalization();
    }

    
    function _cancelation() internal virtual override {
        _state = State.Refunding;
        super._cancelation();
    }

    
    function _forwardFunds(address sender) internal virtual override {
        require(_state == State.Active, "RefundEscrow: can only deposit while active");
        _deposits[sender] = _deposits[sender].add(msg.value);
    }
}

abstract contract PostDeliveryCrowdsale is TimedCrowdsale {
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _balances;
    uint256 private _holdAmount;

    
    function withdrawTokens(address beneficiary) public virtual{
        require(hasClosed(), "PostDeliveryCrowdsale: not closed");
        uint256 amount = _balances[beneficiary];
        require(amount > 0, "PostDeliveryCrowdsale: beneficiary is not due any tokens");

        _balances[beneficiary] = 0;
        _holdAmount = _holdAmount.sub(amount);

        token().transfer(beneficiary, amount);

        emit TokensClaimed(beneficiary, amount);
    }

    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal virtual override {
        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
        _holdAmount = _holdAmount.add(tokenAmount);
    }
    
    function _clear() internal {
        _holdAmount = 0;
    }

    function reservedTokens() internal view returns (uint256) {
        return _holdAmount;
    }
}

abstract contract RefundablePostDeliveryCrowdsale is Initializable, ContextUpgradeable, RefundableCrowdsale, PostDeliveryCrowdsale {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address payable;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function _RefundablePostDeliveryCrowdsale_init(uint256 goal_) internal onlyInitializing {
        __Context_init_unchained();
        __RefundablePostDeliveryCrowdsale_init_unchained(goal_);
    }

    function __RefundablePostDeliveryCrowdsale_init_unchained(uint256 goal_) internal onlyInitializing {
        __RefundableCrowdsale_init_unchained(goal_);
    }

    function _finalization() internal virtual override {
        if (goalReached()) {
            
            _addLiquidity();

            uint256 tokenAmount = token().balanceOf(address(this));
            tokenAmount = tokenAmount.sub(reservedTokens());

            
            if (tokenAmount > 0) {
                _deliverTokens(wallet(), tokenAmount);
            }
            
            
            if (isBaseTokenEnabled()) {
                IERC20Upgradeable baseErc20 = baseToken();
                uint256 balance = baseErc20.balanceOf(address(this));
                baseErc20.safeTransfer(wallet(), balance);
            } else {
                wallet().sendValue(address(this).balance);
            }
        } else {

            
            _deliverTokens(wallet(), token().balanceOf(address(this)));
        }

        super._finalization();
    }

    function _cancelation() internal virtual override {
        _deliverTokens(wallet(), token().balanceOf(address(this)));
        super._cancelation();
    }

    function withdrawTokens(address beneficiary) public override{
        require(finalized() || expired(), "RefundablePostDeliveryCrowdsale: not finalized");
        require(!canceled(), "RefundablePostDeliveryCrowdsale: caneled");
        require(goalReached(), "RefundablePostDeliveryCrowdsale: goal not reached");

        super.withdrawTokens(beneficiary);
    }

    function _forwardFunds(address sender) internal virtual override(Crowdsale, RefundableCrowdsale) {
        RefundableCrowdsale._forwardFunds(sender);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal virtual override(Crowdsale, PostDeliveryCrowdsale) {
        PostDeliveryCrowdsale._processPurchase(beneficiary, tokenAmount);
    }
}

contract CrowpadSale is Initializable,
    ContextUpgradeable, WhitelistAdminRole,
    Crowdsale, CappedCrowdsale,
    TimedCrowdsale, WhitelistCrowdsale, RefundablePostDeliveryCrowdsale {
    using SafeMathUpgradeable for uint256;

    struct SocialLinks {
        string twitter;
        string facebook;
        string telegram;
        string instagram;
        string github;
        string discord;
        string reddit;
    }

    
    address public factory;
    uint256 public investorMinCap = 2000000000000000; 
    uint256 public investorHardCap = 50000000000000000000; 
    mapping(address => uint256) public contributions;

    string public logo;
    string public website;
    string public projectDescription;
    bool public deposited;
    SocialLinks public links;

    
    uint256 public tokenSalePercentage   = 70;

    
    event TokensDeposited(uint256 amount);

    function initialize(
        ICrowpadSale.InitParams calldata params,
        address locker
    ) public initializer {
        factory = _msgSender();
        __Context_init_unchained();
        __Ownable_init_unchained();
        __WhitelistAdminRole_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Crowdsale_init_unchained(params.saleRate, params.saleRateDecimals, params.wallet, IERC20Upgradeable(params.token), params.baseToken);
        __CappedCrowdsale_init_unchained(params.hardCap);
        __TimedCrowdsale_init_unchained(params.startTime, params.endTime);
        __RefundablePostDeliveryCrowdsale_init_unchained(params.softCap);
        __WhitelistCrowdsale_init_unchained(params.whitelistEnabled);
        
        require(params.softCap <= params.hardCap, "Goal can not be greater than Cap.");
        require(params.maxContribution >= params.minContribution, "Maximum contribution cannot be lower than minimum contribution.");

        __LiquidityCrowdsale_init_unchained(
            params.listingRate,
            params.listingRateDecimals,
            params.liquidityPercent,
            params.unlockTime,
            locker,
            params.router);

        deposited = false;
        investorHardCap = params.maxContribution;
        investorMinCap = params.minContribution;
    }

    
    function getUserContribution(address _beneficiary) public view returns (uint256) {
        return contributions[_beneficiary];
    }

    function _forwardFunds(address sender) internal override(Crowdsale, RefundablePostDeliveryCrowdsale) {
        super._forwardFunds(sender);
    }

    
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    ) internal override(
        CappedCrowdsale,
        Crowdsale,
        TimedCrowdsale,
        WhitelistCrowdsale
    ) {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        uint256 _existingContribution = contributions[_beneficiary];
        uint256 _newContribution = _existingContribution.add(_weiAmount);
        require(_newContribution >= investorMinCap && _newContribution <= investorHardCap, "investorMinCap < contribution < investorHardCap");
        contributions[_beneficiary] = _newContribution;
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal override(Crowdsale, RefundablePostDeliveryCrowdsale) {
        RefundablePostDeliveryCrowdsale._processPurchase(beneficiary, tokenAmount);
    }

    

    function _filled() internal virtual override returns (bool){
        return capReached();
    }

    function setLogo(string memory logo_) external onlyOwner {
        logo = logo_;
    }

    function setWebsite(string memory website_) external onlyOwner {
        website = website_;
    }

    function setTwitter(string memory twitter_) external onlyOwner {
        links.twitter = twitter_;
    }

    function setFacebook(string memory facebook_) external onlyOwner {
        links.facebook = facebook_;
    }

    function setTelegram(string memory telegram_) external onlyOwner {
        links.telegram = telegram_;
    }

    function setInstagram(string memory instagram_) external onlyOwner {
        links.instagram = instagram_;
    }

    function setGithub(string memory github_) external onlyOwner {
        links.github = github_;
    }

    function setDiscord(string memory discord_) external onlyOwner {
        links.discord = discord_;
    }

    function setReddit(string memory reddit_) external onlyOwner {
        links.reddit = reddit_;
    }

    function setProjectDescription(string memory projectDescription_) external onlyOwner {
        projectDescription = projectDescription_;
    }

    function updateMeta(
        string memory logo_,
        string memory website_,
        string memory twitter_,
        string memory facebook_,
        string memory telegram_,
        string memory instagram_,
        string memory github_,
        string memory discord_,
        string memory reddit_,
        string memory projectDescription_
    ) public onlyOwner {
        logo = logo_;
        website = website_;
        links.twitter = twitter_;
        links.facebook = facebook_;
        links.telegram = telegram_;
        links.instagram = instagram_;
        links.github = github_;
        links.discord = discord_;
        links.reddit = reddit_;
        projectDescription = projectDescription_;
    }

    function deposit(
    ) external onlyOwner {
        require(!deposited, "Already deposited");
        
        uint256 amountPresale = _getTokenAmount(cap());
        uint256 amountLiquidity = _getLiquidityTokenAmount(cap().mul(liquidityPercent()).div(100));
        uint256 amountTotal = amountPresale.add(amountLiquidity);

        IERC20Upgradeable tokenErc20 = token();
        uint256 balanceBefore = tokenErc20.balanceOf(address(this));
        tokenErc20.transferFrom(msg.sender, address(this), amountTotal);
        uint256 balanceEnd = tokenErc20.balanceOf(address(this));
        uint256 amountDeposited = balanceEnd.sub(balanceBefore);

        require(amountDeposited >= amountTotal, "Too small amount deposited");
        deposited = true;

        emit TokensDeposited(amountDeposited);
    }

    function getConfiguration() external view returns (ICrowpadSale.InitParams memory params) {
        params.saleRate = rate();
        params.saleRateDecimals = rateDecimals();
        params.listingRate = listingRate();
        params.listingRateDecimals = listingRateDecimals();
        params.liquidityPercent = liquidityPercent();
        params.wallet = wallet();
        params.router = address(0);
        params.token = address(token());
        params.baseToken = address(baseToken());
        params.softCap = goal();
        params.hardCap = cap();
        params.minContribution = investorMinCap;
        params.maxContribution = investorHardCap;
        params.startTime = openingTime();
        params.endTime = closingTime();
        params.unlockTime = liquidityUnlockTime();
        params.whitelistEnabled = whitelistEnabled;
    }
}