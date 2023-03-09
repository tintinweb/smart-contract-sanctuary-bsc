/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    function asset() external view returns (address assetTokenAddress);

    function totalAssets() external view returns (uint256 totalManagedAssets);

    function convertToShares(uint256 assets) external view returns (uint256 shares);

    function convertToAssets(uint256 shares) external view returns (uint256 assets);

    function maxDeposit(address receiver) external view returns (uint256 maxAssets);

    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function maxMint(address receiver) external view returns (uint256 maxShares);

    function previewMint(uint256 shares) external view returns (uint256 assets);

    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    function maxWithdraw(address owner) external view returns (uint256 maxAssets);

    function previewWithdraw(uint256 assets) external view returns (uint256 shares);

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);

    function maxRedeem(address owner) external view returns (uint256 maxShares);

    function previewRedeem(uint256 shares) external view returns (uint256 assets);

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
}

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

library Address {

    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {        
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

    function safeApprove(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {            
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}


interface ITokenMinter {
  function mint(address, uint256) external;

  function burn(address, uint256) external;
}

interface IWhitelist {
    function isWhitelisted(address) external view returns (bool);
}

interface IStaker {
  function approve(address, uint256) external;
}

contract MVLP_Depositor is Pausable, Ownable {
    using SafeERC20 for IERC20;

    uint256 private constant FEE_DIVISOR = 1e4;
    IERC20 public constant MVLP =
        IERC20(0xa5F756Ce4717FC41528851dA2F81E65B806Cfade); // testnet

    struct PartnerInfo {
        bool isActive;
        uint32 exitFeeToPlatform; // goes to Platform
        uint32 exitFeeToVault; // goes back to Vault
        uint32 totalExitFee;
    }

    address public immutable staker;
    address public immutable vault; // xMVLP

    address public immutable assetMVLP;

    address private exitFeeCollector;
    mapping(address => PartnerInfo) private partners;

    uint32 public defaultExitFeeToPlatform;
    uint32 public defaultExitFeeToVault;

    IWhitelist public whitelist;
    bool public isWhitelistStaking;

    constructor(
        address _staker,
        address _assetMVLP,
        address _vault,
        address _exitFeeCollector,
        address _whitelist
    ) {
        staker = _staker;
        assetMVLP = _assetMVLP;
        vault = _vault;
        exitFeeCollector = _exitFeeCollector;
        whitelist = IWhitelist(_whitelist);

        defaultExitFeeToPlatform = 200; // 2%
        defaultExitFeeToVault = 50; // 0.5%
        
        IERC20(assetMVLP).approve(_vault, type(uint256).max);
    }

    function deposit(uint256 _amount) public whenNotPaused {
        _isEligibleSender();
        _deposit(msg.sender, _amount);
    }

    function redeem(uint256 _amount) public whenNotPaused {
        _isEligibleSender();

        PartnerInfo memory partner = partners[msg.sender];

        uint256 exitFeeToPlatform = partner.isActive
            ? partner.exitFeeToPlatform
            : defaultExitFeeToPlatform;
        uint256 exitFeeToVault = partner.isActive
            ? partner.exitFeeToVault
            : defaultExitFeeToVault;

        _redeem(msg.sender, _amount, exitFeeToPlatform, exitFeeToVault);
    }

    function previewRedeem(
        address _addr,
        uint256 _shares
    )
        external
        view
        returns (
            uint256 assetsPlatformFee,
            uint256 assetsVaultFee,
            uint256 assetsLessFee
        )
    {
        PartnerInfo memory partner = partners[_addr];
        uint256 exitFeeToPlatform = partner.isActive
            ? partner.exitFeeToPlatform
            : defaultExitFeeToPlatform;
        uint256 exitFeeToVault = partner.isActive
            ? partner.exitFeeToVault
            : defaultExitFeeToVault;
        uint256 assets = IERC4626(vault).previewRedeem(_shares);
        
        (uint256 _assetsPlatformFee, ) = _calculateFee(
            assets,
            exitFeeToPlatform
        );
        (uint256 _assetsVaultFee, ) = _calculateFee(assets, exitFeeToVault);
        uint256 _assetsLessFee = 0;
        unchecked {
            _assetsLessFee = assets - _assetsPlatformFee - _assetsVaultFee;
        }

        return (_assetsPlatformFee, _assetsVaultFee, _assetsLessFee);
    }

    function getFeeBp(
        address _addr
    )
        external
        view
        returns (uint256 exitFeeToPlatform, uint256 exitFeeToVault)
    {
        PartnerInfo memory partner = partners[_addr];
        exitFeeToPlatform = partner.isActive
            ? partner.exitFeeToPlatform
            : defaultExitFeeToPlatform;
        exitFeeToVault = partner.isActive
            ? partner.exitFeeToVault
            : defaultExitFeeToVault;
    }

    ///@notice Deposit _assets
    function depositAll() external {
        deposit(MVLP.balanceOf(msg.sender));
    }

    ///@notice Withdraw _shares
    function redeemAll() external {
        redeem(IERC20(vault).balanceOf(msg.sender));
    }

    function donate(uint256 _assets) external {
        MVLP.safeTransferFrom(msg.sender, staker, _assets);
        ITokenMinter(assetMVLP).mint(vault, _assets);
    }

    /** PRIVATE FUNCTIONS */
    function _deposit(address _user, uint256 _assets) private {
        if (_assets < 1 ether) revert UNDER_MIN_AMOUNT();

        // unstake for _user, stake in staker
        // requires approval in user for depositor to spend
        MVLP.safeTransferFrom(_user, staker, _assets);

        // mint appropriate aMVLP to depositor
        ITokenMinter(assetMVLP).mint(address(this), _assets);

        // deposit aMVLP into vault for xMVLP
        // already max approved in constructor
        uint256 _shares = IERC4626(vault).deposit(_assets, _user);
        emit Deposited(_user, _assets, _shares);
    }

    function _redeem(
        address _user,
        uint256 _shares,
        uint256 exitFeeToPlatform,
        uint256 exitFeeToVault
    ) private {
        if (_shares < 1 ether) revert UNDER_MIN_AMOUNT();

        // redeem xMVLP for vaMVLP to address(this)
        uint256 _assets = IERC4626(vault).redeem(_shares, address(this), _user);

        (uint256 _assetsPlatformFee, ) = _calculateFee(
            _assets,
            exitFeeToPlatform
        );
        (uint256 _assetsVaultFee, ) = _calculateFee(_assets, exitFeeToVault);

        uint256 _assetsLessFee = 0;
        unchecked {
            _assetsLessFee = _assets - _assetsPlatformFee - _assetsVaultFee;
        }
        ITokenMinter(assetMVLP).burn(address(this), _assetsLessFee);

        // transfer _assetsVaultFee to vault
        SafeERC20.safeTransfer(IERC20(assetMVLP), vault, _assetsVaultFee);

        // requires approval in staker for depositor to spend
        IStaker(staker).approve(_user, _assetsLessFee);
        IStaker(staker).approve(exitFeeCollector, _assetsPlatformFee);
        MVLP.safeTransferFrom(staker, _user, _assetsLessFee);        
        MVLP.safeTransferFrom(staker, exitFeeCollector, _assetsPlatformFee);

        emit Withdrawed(
            _user,
            _shares,
            _assetsLessFee,
            _assetsVaultFee,
            _assetsPlatformFee
        );
    }

    function _calculateFee(
        uint256 _totalAmount,
        uint256 _fee
    ) private pure returns (uint256 feeAmount, uint256 amountLessFee) {
        feeAmount = (_totalAmount * _fee) / FEE_DIVISOR;
        unchecked {
            amountLessFee = _totalAmount - feeAmount;
        }
    }

    function _isEligibleSender() private view {
        if (isWhitelistStaking) revert UNAUTHORIZED();
    }

    /** OWNER FUNCTIONS */
    function setExitFee(
        uint32 _newPlatformFee,
        uint32 _newVaultVee
    ) external onlyOwner {
        uint32 _totalExitFee = _newPlatformFee + _newVaultVee;
        if (_totalExitFee > FEE_DIVISOR) revert BAD_FEE();

        emit FeeUpdated(_newPlatformFee, _newVaultVee);

        defaultExitFeeToPlatform = _newPlatformFee;
        defaultExitFeeToVault = _newVaultVee;
    }

    ///@dev _partnerAddr needs to have an approval for this contract to spend MVLP
    function updatePartner(
        address _partnerAddr,
        uint32 _exitFeeToPlatform,
        uint32 _exitFeeToVault,
        bool _isActive
    ) external onlyOwner {
        uint32 _totalExitFee = _exitFeeToPlatform + _exitFeeToVault;
        if (_totalExitFee > FEE_DIVISOR) revert BAD_FEE();
        partners[_partnerAddr] = PartnerInfo({
            isActive: _isActive,
            exitFeeToPlatform: _exitFeeToPlatform,
            exitFeeToVault: _exitFeeToVault,
            totalExitFee: _totalExitFee
        });
        emit PartnerUpdated(
            _partnerAddr,
            _exitFeeToPlatform,
            _exitFeeToVault,
            _isActive
        );
    }

    function setFeeCollector(address _newFeeCollector) external onlyOwner {
        emit FeeCollectorUpdated(_newFeeCollector, exitFeeCollector);
        exitFeeCollector = _newFeeCollector;
    }

    function setWhitelist(address _whitelist) external onlyOwner {
        emit WhitelistUpdated(_whitelist, address(whitelist));
        whitelist = IWhitelist(_whitelist);
    }

    function setPaused(bool _pauseContract) external onlyOwner {
        if (_pauseContract) {
            _pause();
        } else {
            _unpause();
        }
    }

    function setWhitelistStaking(bool _state) external onlyOwner {
      isWhitelistStaking = _state;
    }

    event WhitelistUpdated(address _new, address _old);
    event FeeCollectorUpdated(address _new, address _old);
    event FeeUpdated(uint256 _newExitPlatformFee, uint256 _newExitVaultVee);
    event PartnerUpdated(
        address _partner,
        uint32 _exitFeeToPlatform,
        uint32 _exitFeeToVault,
        bool _isActive
    );
    event Deposited(address indexed _user, uint256 _assets, uint256 _shares);
    event Withdrawed(
        address indexed _user,
        uint256 _shares,
        uint256 _assetsLessFee,
        uint256 _assetsVaultFee,
        uint256 _assetsPlatformFee
    );

    error UNDER_MIN_AMOUNT();
    error UNAUTHORIZED();
    error INVARIANT_VIOLATION();
    error BAD_FEE();
}