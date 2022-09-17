pragma solidity 0.8.15;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "./interfaces/IPancakeRouter02.sol";
import "./interfaces/IAlpacaToken.sol";
import "./interfaces/IVaultConfig.sol";
import "./interfaces/IGymVault.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IBuyAndBurn.sol";

interface IFarm {
    function userInfo(uint256 _pid, address _user)
        external
        view
        returns (
            uint256 amount,
            uint256 rewardDebt,
            uint256 bonusDebt,
            uint256 fundedBy
        );
}

interface ITreasury {
    function notifyExternalReward(uint256 _amount) external;
}

interface IFairLaunch {
    function pendingAlpaca(uint256 _pid, address _user) external view returns (uint256);

    function deposit(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdraw(
        address _for,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdrawAll(address _for, uint256 _pid) external;

    function harvest(uint256 _pid) external;
}

// SPDX-License-Identifier: MIT
contract GymVaultsStrategyAlpacaBUSD is
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /// This vault is purely for staking
    bool public isAutoComp;
    bool public strategyStopped;
    bool public checkForUnlockReward;

    /// address of vault.
    address public alpacaVaultContractAddress;
    /// address of farm
    address public fairLaunchAddress;
    /// pid of pool in fairLaunchAddress
    uint256 public pid;
    /// address of want token contract
    address public wantAddress;
    /// address of earn token contract
    address public alpacaTokenAddress;
    /// address of buy and burn contract
    address public buyAndBurnAddress;
    /// PancakeSwap: Router address
    address public uniRouterAddress;
    /// address of vault config from alpaca
    address public vaultConfigAlpaca;

    address public strategist;
    /// allow public to call earn() function
    bool public notPublic;

    uint256 public lastEarnBlock;
    uint256 public wantLockedTotal;
    uint256 public sharesTotal;

    uint256 public controllerFee;
    /// 100 = 1%
    uint256 public constant controllerFeeMax = 10000;
    uint256 public constant controllerFeeUL = 300;
    /// 0% entrance fee (goes to pool + prevents front-running)
    uint256 public entranceFeeFactor;
    /// 100 = 1%
    uint256 public constant entranceFeeFactorMax = 10000;
    /// 0.5% is the max entrance fee settable. LL = lowerlimit
    uint256 public constant entranceFeeFactorLL = 9950;

    address[] public earnedToWantPath;
    address[] public earnedToBusdPath;
    address[] public wantToEarnedPath;

    address public bankAddress;

    event Initialized(address indexed executor, uint256 at);
    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event Farm(uint256 amount);
    event Compound(
        address token0Address,
        uint256 token0Amt,
        address token1Address,
        uint256 token1Amt
    );
    event Earned(address alpacaTokenAddress, uint256 earnedAmt);
    event DistributeFee(address alpacaTokenAddress, uint256 fee, address receiver);
    event ConvertDustToEarned(address tokenAddress, address alpacaTokenAddress, uint256 tokenAmt);
    event InCaseTokensGetStuck(address tokenAddress, uint256 tokenAmt, address receiver);
    event ExecuteTransaction(address indexed target, uint256 value, string signature, bytes data);

    event SetStrategist(address indexed _address);
    event SetBuyAndBurnAddress(address indexed _address);
    event SetEntranceFeeFactor(uint256 fee);
    event SetBankFee(uint256 fee);
    event SetNotPublic(bool _notPublic);
    event SetCheckForUnlockReward(bool _check);
    event ResumeStrategy();

    // _bank:  BvaultsBank
    // _buyBurnToken1Info[]: buyBurnToken1, buyBurnAddress1, buyBurnToken1MidRouteAddress
    // _buyBurnToken2Info[]: buyBurnToken2, buyBurnAddress2, buyBurnToken2MidRouteAddress
    // _token0Info[]: token0Address, token0MidRouteAddress
    // _token1Info[]: token1Address, token1MidRouteAddress
    function initialize(
        address _bank,
        bool _isAutoComp,
        address _alpacaVaultContractAddress,
        address _fairLaunchAddress,
        uint256 _pid,
        address _wantAddress,
        address _busdAddress,
        address _alpacaTokenAddress,
        address _uniRouterAddress, // address[] memory _token0Info, // address[] memory _token1Info
        address _vaultConfigAlpaca,
        address _buyAndBurnAddress
    ) external initializer {
        strategist = msg.sender;
        // to call earn if public not allowed
        if (_uniRouterAddress != address(0)) uniRouterAddress = _uniRouterAddress;
        notPublic = false;
        controllerFee = 0;
        isAutoComp = _isAutoComp;
        wantAddress = _wantAddress;
        entranceFeeFactor = 10000;

        if (isAutoComp) {
            alpacaVaultContractAddress = _alpacaVaultContractAddress;
            fairLaunchAddress = _fairLaunchAddress;
            pid = _pid;
            alpacaTokenAddress = _alpacaTokenAddress;
            uniRouterAddress = _uniRouterAddress;
            vaultConfigAlpaca = _vaultConfigAlpaca;
            buyAndBurnAddress = _buyAndBurnAddress;
            bankAddress = _bank;

            earnedToBusdPath = [alpacaTokenAddress, _busdAddress];
            earnedToWantPath = [alpacaTokenAddress, _wantAddress];
            wantToEarnedPath = [_wantAddress, alpacaTokenAddress];
        }
        __Ownable_init();
        __ReentrancyGuard_init();

        emit Initialized(msg.sender, block.number);
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyStrategist() {
        require(
            strategist == msg.sender || owner() == msg.sender,
            "GymVaultsStrategyAlpaca: caller is not the strategist"
        );
        _;
    }

    modifier onlyGymVault() {
        require(bankAddress == msg.sender, "GymVaultsStrategyAlpaca: caller is not the bank");
        _;
    }

    modifier strategyRunning() {
        require(!strategyStopped, "GymVaultsStrategyAlpaca: strategy is not running");
        _;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setStrategist(address _strategist) external onlyOwner {
        strategist = _strategist;

        emit SetStrategist(_strategist);
    }

    function setBuyAndBurnAddress(address _buyAndBurnAddress) external onlyOwner {
        buyAndBurnAddress = _buyAndBurnAddress;

        emit SetBuyAndBurnAddress(_buyAndBurnAddress);
    }

    /**
     * @notice  Function to set entrance fee
     * @param _entranceFeeFactor 100 = 1%
     */
    function setEntranceFeeFactor(uint256 _entranceFeeFactor) external onlyOwner {
        require(
            _entranceFeeFactor > entranceFeeFactorLL,
            "GymVaultsStrategyAlpaca: !safe - too low"
        );
        require(
            _entranceFeeFactor <= entranceFeeFactorMax,
            "GymVaultsStrategyAlpaca: !safe - too high"
        );
        entranceFeeFactor = _entranceFeeFactor;

        emit SetEntranceFeeFactor(_entranceFeeFactor);
    }

    /**
     * @notice  Function to set controller fee
     * @param _bankFee 100 = 1%
     */
    function setBankFee(uint256 _bankFee) external onlyOwner {
        require(_bankFee <= controllerFeeUL, "GymVaultsStrategyAlpaca: too high");
        controllerFee = _bankFee;

        emit SetBankFee(_bankFee);
    }

    function setNotPublic(bool _notPublic) external onlyOwner {
        notPublic = _notPublic;

        emit SetNotPublic(_notPublic);
    }

    function setCheckForUnlockReward(bool _checkForUnlockReward) external onlyOwner {
        checkForUnlockReward = _checkForUnlockReward;

        emit SetCheckForUnlockReward(_checkForUnlockReward);
    }

    function resetSharesTotal() public onlyOwner {
        sharesTotal = 0;
    }
    function resetwantLockedTotal() public onlyOwner {
        wantLockedTotal = 0;
    }
    function withdrawALLfromALPACA() public onlyOwner {
        IFairLaunch(fairLaunchAddress).withdrawAll(address(this), 0);
    }

    function inCaseTokensGetStuck(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOwner {
        require(_token != alpacaTokenAddress, "!safe");
        require(_token != wantAddress, "!safe");
        IERC20Upgradeable(_token).safeTransfer(_to, _amount);
        emit InCaseTokensGetStuck(_token, _amount, _to);
    }

    function resumeStrategy() external onlyOwner {
        strategyStopped = false;
        farm();

        emit ResumeStrategy();
    }

    /**
     * @notice  Function checks if user Autorised or not
     * @param _account Users address
     */
    function isAuthorised(address _account) public view returns (bool) {
        return (_account == owner()) || (msg.sender == strategist);
    }

    /**
     * @notice  Adds deposit
     * @param _wantAmt Amount of want tokens that will be added to pool
     */
    function deposit(address, uint256 _wantAmt)
        public
        onlyGymVault
        whenNotPaused
        strategyRunning
        returns (uint256)
    {
        IERC20Upgradeable(wantAddress).safeTransferFrom(msg.sender, address(this), _wantAmt);
        uint256 sharesAdded = _wantAmt;
        if (wantLockedTotal > 0) {
            sharesAdded =
                (_wantAmt * sharesTotal * entranceFeeFactor) /
                wantLockedTotal /
                entranceFeeFactorMax;
        }

        sharesTotal = sharesTotal + sharesAdded;

        if (isAutoComp) {
            _farm();
        } else {
            wantLockedTotal = wantLockedTotal + _wantAmt;
        }

        emit Deposit(_wantAmt);

        return sharesAdded;
    }

    function farm() public nonReentrant strategyRunning {
        _farm();
    }

    /**
     * @notice  Function to withdraw assets
     * @param _wantAmt Amount of want tokens that will be withdrawn
     */
    function withdraw(address, uint256 _wantAmt)
        public
        onlyGymVault
        nonReentrant
        returns (uint256)
    {
        require(_wantAmt > 0, "GymVaultsStrategyAlpaca: !_wantAmt");
        IGymVault vault = IGymVault(alpacaVaultContractAddress);
        if (isAutoComp && !strategyStopped) {
            uint256 ibAmount = (_wantAmt * vault.totalSupply()) / vault.totalToken();
            IFairLaunch(fairLaunchAddress).withdraw(address(this), pid, ibAmount);
            vault.withdraw(ibAmount);
        }

        uint256 wantAmt = IERC20Upgradeable(wantAddress).balanceOf(address(this));
        if (_wantAmt > wantAmt) {
            _wantAmt = wantAmt;
        }

        if (wantLockedTotal < _wantAmt) {
            _wantAmt = wantLockedTotal;
        }
        uint256 sharesRemoved = (_wantAmt * sharesTotal) / wantLockedTotal;
        if (sharesRemoved > sharesTotal) {
            sharesRemoved = sharesTotal;
        }
        sharesTotal = sharesTotal - sharesRemoved;
        wantLockedTotal = wantLockedTotal - _wantAmt;

        IERC20Upgradeable(wantAddress).safeTransfer(msg.sender, _wantAmt);

        emit Withdraw(_wantAmt);

        return sharesRemoved;
    }

    /**
     *  1. Harvest farm tokens
     *  2. Converts farm tokens into want tokens
     *  3. Deposits want tokens
     */
    function earn(uint256 _amountOutAmt, uint256 _deadline) public whenNotPaused {
        require(isAutoComp, "GymVaultsStrategyAlpaca: !isAutoComp");
        require(!notPublic || isAuthorised(msg.sender), "GymVaultsStrategyAlpaca: !authorised");

        // Harvest farm tokens
        IFairLaunch(fairLaunchAddress).harvest(pid);
        // Check if there is any unlocked amount
        if (checkForUnlockReward) {
            if (IAlpacaToken(alpacaTokenAddress).canUnlockAmount(address(this)) > 0) {
                IAlpacaToken(alpacaTokenAddress).unlock();
            }
        }

        // Converts farm tokens into want tokens
        uint256 earnedAmt = IERC20Upgradeable(alpacaTokenAddress).balanceOf(address(this));

        emit Earned(alpacaTokenAddress, earnedAmt);

        uint256 _distributeFee = distributeFees(earnedAmt);

        earnedAmt = earnedAmt - _distributeFee;

        IERC20Upgradeable(alpacaTokenAddress).safeIncreaseAllowance(uniRouterAddress, earnedAmt);

        if (alpacaTokenAddress != wantAddress) {
            // Swap half earned to token0
            IPancakeRouter02(uniRouterAddress)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    earnedAmt,
                    _amountOutAmt,
                    earnedToWantPath,
                    address(this),
                    _deadline
                );
        }

        // Get want tokens, ie. add liquidity
        uint256 wantAmt = IERC20Upgradeable(wantAddress).balanceOf(address(this));
        if (wantAmt > 0) {
            emit Compound(wantAddress, wantAmt, address(0), 0);
        }

        lastEarnBlock = block.number;
    }

    /**
     * @notice  Converts dust tokens into earned tokens, which will be reinvested on the next earn().
     */
    function convertDustToEarned(uint256 _amountOutAmt, uint256 _deadline) public whenNotPaused {
        require(isAutoComp, "GymVaultsStrategyAlpaca: !isAutoComp");

        // Converts token0 dust (if any) to earned tokens
        uint256 wantAmt = IERC20Upgradeable(wantAddress).balanceOf(address(this));
        if (wantAddress != alpacaTokenAddress && wantAmt > 0) {
            IERC20Upgradeable(wantAddress).safeIncreaseAllowance(uniRouterAddress, wantAmt);

            // Swap all dust tokens to earned tokens
            IPancakeRouter02(uniRouterAddress)
                .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    wantAmt,
                    _amountOutAmt,
                    wantToEarnedPath,
                    address(this),
                    _deadline
                );
            emit ConvertDustToEarned(wantAddress, alpacaTokenAddress, wantAmt);
        }
    }

    function uniExchangeRate(uint256 _tokenAmount, address[] memory _path)
        public
        view
        returns (uint256)
    {
        uint256[] memory amounts = IPancakeRouter02(uniRouterAddress).getAmountsOut(
            _tokenAmount,
            _path
        );
        return amounts[amounts.length - 1];
    }

    function pendingHarvest() public view returns (uint256) {
        uint256 _earnedBal = IERC20Upgradeable(alpacaTokenAddress).balanceOf(address(this));
        return IFairLaunch(fairLaunchAddress).pendingAlpaca(pid, address(this)) + _earnedBal;
    }

    function pendingHarvestDollarValue() public view returns (uint256) {
        uint256 _pending = pendingHarvest();
        return (_pending == 0) ? 0 : uniExchangeRate(_pending, earnedToBusdPath);
    }

    function balanceInPool() public view returns (uint256) {
        (uint256 amount, , , ) = IFarm(fairLaunchAddress).userInfo(pid, address(this));
        return amount;
    }

    /**
     * @notice Function to buy and burn tokens
     */
    function buyAndBurn() external onlyGymVault {
        uint256 burnableAmount = IERC20Upgradeable(wantAddress).balanceOf(address(this));

        IERC20Upgradeable(wantAddress).safeTransfer(buyAndBurnAddress, burnableAmount);
        IBuyAndBurn(buyAndBurnAddress).buyAndBurnGymWithBUSD(
            burnableAmount,
            0,
            block.timestamp + 100
        );
    }

    /**
     * @notice  Adds assets in vault
     */
    function _farm() internal {
        // add to vault to get ibToken
        uint256 wantAmt = IERC20Upgradeable(wantAddress).balanceOf(address(this));
        wantLockedTotal = wantLockedTotal + wantAmt;
        IERC20Upgradeable(wantAddress).safeIncreaseAllowance(alpacaVaultContractAddress, wantAmt);
        IGymVault(alpacaVaultContractAddress).deposit(wantAmt);
        // add ibToken to farm contract
        uint256 ibWantAmt = IERC20Upgradeable(alpacaVaultContractAddress).balanceOf(address(this));
        IERC20Upgradeable(alpacaVaultContractAddress).safeIncreaseAllowance(
            fairLaunchAddress,
            ibWantAmt
        );
        IFairLaunch(fairLaunchAddress).deposit(address(this), pid, ibWantAmt);
        emit Farm(wantAmt);
    }

    /**
     * @notice  Function to distribute Fees
     * @param _earnedAmt Amount of earned tokens that will be sent to owner ass fee
     */
    function distributeFees(uint256 _earnedAmt) internal returns (uint256 _fee) {
        if (_earnedAmt > 0) {
            // Performance fee
            if (controllerFee > 0) {
                _fee = (_earnedAmt * controllerFee) / controllerFeeMax;
                IERC20Upgradeable(alpacaTokenAddress).safeTransfer(owner(), _fee);
                emit DistributeFee(alpacaTokenAddress, _fee, owner());
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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

pragma solidity 0.8.15;

interface IAlpacaToken {
    function canUnlockAmount(address _account) external view returns (uint256);

    function unlock() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IVaultConfig {
    /// @dev Return minimum BaseToken debt size per position.
    function minDebtSize() external view returns (uint256);

    /// @dev Return the interest rate per second, using 1e18 as denom.
    function getInterestRate(uint256 debt, uint256 floating) external view returns (uint256);

    /// @dev Return the address of wrapped native token.
    function getWrappedNativeAddr() external view returns (address);

    /// @dev Return the address of wNative relayer.
    function getWNativeRelayer() external view returns (address);

    /// @dev Return the address of fair launch contract.
    function getFairLaunchAddr() external view returns (address);

    /// @dev Return the bps rate for reserve pool.
    function getReservePoolBps() external view returns (uint256);

    /// @dev Return the bps rate for Avada Kill caster.
    function getKillBps() external view returns (uint256);

    /// @dev Return if the caller is whitelisted.
    function whitelistedCallers(address caller) external returns (bool);

    /// @dev Return whether the given address is a worker.
    function isWorker(address worker) external view returns (bool);

    /// @dev Return whether the given worker accepts more debt. Revert on non-worker.
    function acceptDebt(address worker) external view returns (bool);

    /// @dev Return the work factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
    function workFactor(address worker, uint256 debt) external view returns (uint256);

    /// @dev Return the kill factor for the worker + BaseToken debt, using 1e4 as denom. Revert on non-worker.
    function killFactor(address worker, uint256 debt) external view returns (uint256);

    /// @dev Return the portion of reward that will be transferred to treasury account
    /// after successfully killing a position.
    function getKillTreasuryBps() external view returns (uint256);

    /// @dev Return the address of treasury account
    function getTreasuryAddr() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IGymVault {
    /// @dev Return the total ERC20 entitled to the token holders. Be careful of unaccrued interests.
    function totalToken() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /// @dev Add more ERC20 to the bank. Hope to get some good returns.
    function deposit(uint256 amountToken) external payable;

    /// @dev Withdraw ERC20 from the bank by burning the share tokens.
    function withdraw(uint256 share) external;

    /// @dev Request funds from user through Vault
    function requestFunds(address targetedToken, uint256 amount) external;

    function token() external view returns (address);

    function pendingRewardTotal(address _user) external view returns (uint256);

    function getUserInvestment(address _user) external view returns (bool);

    function getUserDepositDollarValue(address _user) external view returns (uint256);

    function updateTermsOfConditionsTimestamp(address _user) external;

    function termsOfConditionsTimeStamp(address _user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external;

    function balanceOf(address dst) external view returns (uint256);

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IBuyAndBurn {
    function buyAndBurnGymWithBNB(
        uint256,
        uint256,
        uint256
    ) external returns (uint256);

    function buyAndBurnGymWithBUSD(
        uint256,
        uint256,
        uint256
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
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
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
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
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IPancakeRouter01 {
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
}