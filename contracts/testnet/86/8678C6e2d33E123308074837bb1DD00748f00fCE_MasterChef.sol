/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// File: ../leveraged/contracts/security/ReentrancyGuard.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

// File: ../leveraged/contracts/libraries/Address.sol



pragma solidity ^0.8.10;

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

// File: ../leveraged/contracts/interfaces/IIToken.sol



pragma solidity ^0.8.10;

/**
* @dev Interface for a IToken contract
 **/

interface IIToken {
    function balanceOf(address _user) external view returns(uint256);
    function mint(address _user, uint256 _amount) external;
    function burn(address _user, uint256 _amount) external;
}

// File: ../leveraged/contracts/interfaces/ILeveragedVault.sol



pragma solidity ^0.8.10;

/**
* @dev Interface for a LeveragedVault contract
 **/

interface ILeveragedVault {
    function getAssetDecimals(address _asset) external view returns (uint256);
    function getAssetITokenAddress(address _asset) external view returns (address);
    function getAssetTotalLiquidity(address _asset) external view returns (uint256);
    function getUserAssetBalance(address _asset, address _user) external view returns (uint256);
    function getUserBorrowBalance(address _asset, address _user) external view returns (uint256);
    function getUserAverageInterestRate(address _asset, address _user) external view returns (uint256);
    function getAssetInterestRate(address _asset) external view returns (uint256);
    function getFarmPoolTotalValue(address _asset) external view returns (uint256);
    function getAssets() external view returns (address[] memory);
    function setAverageInterestRate(address _asset, address _user, uint256 _averageInterestRate) external;
    function updateBorrowBalance(address _asset, address _user, uint256 _userBorrowBalance) external;
    function transferToVault(address _asset, address payable _depositor, uint256 _amount) external;
    function transferToUser(address _asset, address payable _user, uint256 _amount) external;
    function updateCumulatedIndexLog2(address _asset) external;
    function cumulatedAmount(address _asset, uint256 _storedAmount) external view returns (uint256);
    function storedAmount(address _asset, uint256 _cumulatedAmount) external view returns (uint256);
    receive() external payable;
}

// File: ../leveraged/contracts/interfaces/IPriceOracle.sol



pragma solidity ^0.8.10;

/**
 * @dev Interface for a price oracle.
 */
interface IPriceOracle {
    function getPrice(address _asset) external view returns (uint256);
}

// File: ../leveraged/contracts/MasterChef.sol



pragma solidity ^0.8.10;






/**
* @title MasterChef contract
* @notice Implements the lending actions
 **/
contract MasterChef is ReentrancyGuard {
    using Address for address;

    ILeveragedVault public vault;
    IPriceOracle public priceOracle;

    /**
    * @dev emitted on deposit of BNB
    * @param _depositor the address of the depositor
    * @param _amount the amount to be deposited
    * @param _timestamp the timestamp of the action
    **/
    event DepositBNB(
        address indexed _depositor,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on deposit of asset
    * @param _asset the address of the asset
    * @param _depositor the address of the depositor
    * @param _amount the amount to be deposited
    * @param _timestamp the timestamp of the action
    **/
    event DepositAsset(
        address indexed _asset,
        address indexed _depositor,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on redeem of asset
    * @param _asset the address of the asset
    * @param _user the address of the user
    * @param _amount the amount to be redeemed
    * @param _timestamp the timestamp of the action
    **/
    event Redeem(
        address indexed _asset,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on borrow of asset
    * @param _asset the address of the asset
    * @param _user the address of the user
    * @param _amount the amount to be deposited
    * @param _timestamp the timestamp of the action
    **/
    event Borrow(
        address indexed _asset,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
    * @dev emitted on repay of BNB
    * @param _user the address of the user
    * @param _amount the amount repaid
    * @param _borrowBalance new value of borrow balance
    * @param _timestamp the timestamp of the action
    **/
    event RepayBNB(
        address indexed _user,
        uint256 _amount,
        uint256 _borrowBalance,
        uint256 _timestamp
    );

    /**
    * @dev emitted on repay of asset
    * @param _asset the address of the asset
    * @param _user the address of the user
    * @param _amount the amount repaid
    * @param _borrowBalance new value of borrow balance
    * @param _timestamp the timestamp of the action
    **/
    event RepayAsset(
        address indexed _asset,
        address indexed _user,
        uint256 _amount,
        uint256 _borrowBalance,
        uint256 _timestamp
    );

    // the address used to identify BNB
    address public constant BNB_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    modifier onlyVault {
        require(msg.sender == address(vault), "The caller of this function must be a Vault contract");
        _;
    }

    address public liquidator;

    /**
    * @dev only liquidator can use functions affected by this modifier
    **/
    modifier onlyLiquidator {
        require(liquidator == msg.sender, "The caller must be a liquidator");
        _;
    }

    /**
    * @dev only IToken contract can use functions affected by this modifier
    **/
    modifier onlyITokenContract(address _asset) {
        require(
            vault.getAssetITokenAddress(_asset) == msg.sender,
            "The caller must be a IToken contract"
        );
        _;
    }

    constructor(
        address payable _vault,
        address _priceOracle,
        address _liquidator
    ) {
        vault = ILeveragedVault(_vault);
        priceOracle = IPriceOracle(_priceOracle);
        liquidator = _liquidator;
    }

    /**
    * @dev deposits BNB into the vault.
    * A corresponding amount of the interest bearing token is minted.
    **/
    function depositBNB()
        external
        payable
        nonReentrant
    {
        require(msg.value > 0, "BNB value must be greater than 0");

        vault.updateCumulatedIndexLog2(BNB_ADDRESS);
        IIToken(vault.getAssetITokenAddress(BNB_ADDRESS)).
            mint(msg.sender, msg.value); // iToken minting to depositor

        // transfer deposit to the LeveragedVault contract
        payable(address(vault)).transfer(msg.value);        

        emit DepositBNB(msg.sender, msg.value, block.timestamp);
    }

    /**
    * @dev deposits the supported asset into the vault. 
    * A corresponding amount of the interest bearing token is minted.
    * @param _asset the address of the asset
    * @param _amount the amount to be deposited
    **/
    function depositAsset(address _asset, uint256 _amount)
        external
        nonReentrant
    {
        require(_amount > 0, "Amount must be greater than 0");
        require(_asset != BNB_ADDRESS, "For deposit BNB use function depositBNB");

        vault.updateCumulatedIndexLog2(_asset);
        IIToken(vault.getAssetITokenAddress(_asset)).
            mint(msg.sender, _amount); // iToken minting to depositor

        // transfer deposit to the LeveragedVault contract
        vault.transferToVault(_asset, payable(msg.sender), _amount);

        emit DepositAsset(_asset, msg.sender, _amount, block.timestamp);
    }

    /**
    * @dev redeems a specific amount of asset
    * @param _asset the address of the asset
    * @param _amount the amount being redeemed
    **/
    function redeem(
        address _asset,
        uint256 _amount
    )
        external
        nonReentrant
    {
        uint256 iTokenBalance = vault.getUserAssetBalance(_asset, msg.sender);

        if (_amount == 0) {
            _amount = iTokenBalance;
        } else {
            require(_amount <= iTokenBalance, "Amount more than the user deposit of asset");
        }

        uint256 currentAssetLiquidity = vault.getAssetTotalLiquidity(_asset);
        require(_amount <= currentAssetLiquidity, "There is not enough asset liquidity to redeem");

        checkAssetDebtRatio(_asset, msg.sender, _amount, false);

        vault.updateCumulatedIndexLog2(_asset);
        IIToken(vault.getAssetITokenAddress(_asset)).
            burn(msg.sender, _amount); // iToken burning at the msg.sender

        vault.transferToUser(_asset, payable(msg.sender), _amount);

        emit Redeem(_asset, msg.sender, _amount, block.timestamp);
    }

    /**
    * @dev allows users to borrow a certain amount of an asset
    * @param _asset the address of the asset
    * @param _amount the amount to be borrowed
    **/
    function borrow(
        address _asset,
        uint256 _amount
    )
        external
        nonReentrant
    {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            vault.getAssetTotalLiquidity(_asset) >= _amount,
            "Insufficient liquidity of the asset"
        );

        checkAssetDebtRatio(_asset, msg.sender, _amount, true);

        uint256 currentBorrowBalance = vault.getUserBorrowBalance(_asset, msg.sender);
        uint256 borrowBalance = currentBorrowBalance + _amount;

        uint256 averageInterestRate = 
            (_amount * vault.getAssetInterestRate(_asset) +
                (currentBorrowBalance * vault.getUserAverageInterestRate(_asset, msg.sender))) /
            borrowBalance;

        vault.updateCumulatedIndexLog2(_asset);
        vault.setAverageInterestRate(_asset, msg.sender, averageInterestRate);
        vault.updateBorrowBalance(_asset, msg.sender, borrowBalance);
        vault.transferToUser(_asset, payable(msg.sender), _amount);

        emit Borrow(
            _asset,
            msg.sender,
            _amount,
            block.timestamp
        );
    }

    /**
    * @dev gets debt ratio threshold of the asset with 6 decimals.
    * @param _asset the asset address
    * @return the asset debt ratio threshold
    **/
    function getAssetDebtRatioThreshold(address _asset) public view returns (uint256) {
        uint256 farmPoolTotalValueInUSD = priceOracle.getPrice(_asset) * vault.getFarmPoolTotalValue(_asset) / 10**vault.getAssetDecimals(_asset);
        uint256 millionUSD = 1000000 * 10**8;

        if (farmPoolTotalValueInUSD < millionUSD) { // 0-1M USD
            return 100000 * farmPoolTotalValueInUSD / millionUSD + 700000; // 0.7 - 0.8
        } else if (farmPoolTotalValueInUSD < 3 * millionUSD) { // 1-3M USD
            return 25000 * farmPoolTotalValueInUSD / millionUSD + 775000; // 0.8 - 0.85
        } else if (farmPoolTotalValueInUSD < 10 * millionUSD) { // 3-10M USD
            return 7140 * farmPoolTotalValueInUSD / millionUSD + 828600; // 0.85 - 0.95
        } else { // 10M+ USD
            return 900000; // 0.9
        }
    }

    /**
    * @dev check utilization limit
    * @param _asset the asset address
    * @param _user the user address
    * @param _amount the amount by which the collateral balance or borrow balance will change
    * @param _isBorrowIncrease true if is borrow increase
    **/
    function checkAssetDebtRatio(
        address _asset,
        address _user,
        uint256 _amount,
        bool _isBorrowIncrease
    )
        internal
        view
    {
        ( , , uint256 borrowingPowerInUSD) = getUserTotalBalances(_user);

        uint256 amountInUSD = priceOracle.getPrice(_asset) * _amount / 10**vault.getAssetDecimals(_asset);

        if (_isBorrowIncrease) {
            require(
                amountInUSD < borrowingPowerInUSD,
                "Debt ratio threshold exceeded"
            );
        } else {
            require(
                amountInUSD * getAssetDebtRatioThreshold(_asset) / 10**6 < borrowingPowerInUSD,
                "Debt ratio threshold exceeded"
            );
        }
    }

    /**
    * @notice repays specified amount of BNB
    **/
    function repayBNB()
        external
        payable
        nonReentrant
    {
        require(msg.value > 0, "Value must be greater than 0");

        uint256 currentBorrowBalance = vault.getUserBorrowBalance(BNB_ADDRESS, msg.sender);

        require(msg.value <= currentBorrowBalance, "Amount exceeds borrow");

        uint256 borrowBalance = currentBorrowBalance - msg.value;

        vault.updateCumulatedIndexLog2(BNB_ADDRESS);
        vault.updateBorrowBalance(BNB_ADDRESS, msg.sender, borrowBalance);

        // transfer BNB to the vault contract
        payable(address(vault)).transfer(msg.value);

        emit RepayBNB(
            msg.sender,
            msg.value,
            borrowBalance,
            block.timestamp
        );
    }

    /**
    * @notice repays specified amount of the asset borrow
    * @param _asset the address of the asset
    * @param _amount the amount to be repaid
    **/
    function repayAsset(address _asset, uint256 _amount)
        external
        nonReentrant
    {
        uint256 currentBorrowBalance = vault.getUserBorrowBalance(_asset, msg.sender);

        if (_amount == 0) {
            _amount = currentBorrowBalance;
        } else {
            require(_amount <= currentBorrowBalance, "Amount exceeds borrow");
        }

        uint256 borrowBalance = currentBorrowBalance - _amount;

        vault.updateCumulatedIndexLog2(_asset);
        vault.updateBorrowBalance(_asset, msg.sender, borrowBalance);

        // transfer asset to the DeepWatersVault contract
        vault.transferToVault(_asset, payable(msg.sender), _amount);

        emit RepayAsset(
            _asset,
            msg.sender,
            _amount,
            borrowBalance,
            block.timestamp
        );
    }

    /**
    * @dev during iToken transfer checks utilization limit and updates binary logarithm of liquidity index of the asset
    * @param _asset the asset address
    * @param _from the transfer sender address
    * @param _amount the transfer amount
    **/
    function duringITokenTransfer(address _asset, address _from, uint256 _amount)
        external
        onlyITokenContract(_asset)
    {
        checkAssetDebtRatio(_asset, _from, _amount, false);
        vault.updateCumulatedIndexLog2(_asset);
    }

    /**
    * @notice get user total USD balances
    * @param _user the user address
    * @return totalBalanceInUSD the total USD collateral balance of the user,
    *         totalBorrowBalanceInUSD the total USD borrow balance of the user,
    *         borrowingPowerInUSD the borrowing power in USD,
    **/
    function getUserTotalBalances(address _user)
        public
        view
        returns (
            uint256 totalBalanceInUSD,
            uint256 totalBorrowBalanceInUSD,
            uint256 borrowingPowerInUSD
        )
    {
        uint256 balance;
        uint256 borrowBalance;
        uint256 assetUnit;
        uint256 assetPriceInUSD;

        address[] memory assets = vault.getAssets();
        for (uint256 i = 0; i < assets.length; i++) {
            balance = vault.getUserAssetBalance(assets[i], _user);
            borrowBalance = vault.getUserBorrowBalance(assets[i], _user);

            if (balance == 0 && borrowBalance == 0) { continue; }

            assetUnit = 10**vault.getAssetDecimals(assets[i]);
            assetPriceInUSD = priceOracle.getPrice(assets[i]);

            totalBalanceInUSD += assetPriceInUSD * balance / assetUnit;
            totalBorrowBalanceInUSD += assetPriceInUSD * borrowBalance / assetUnit;
            borrowingPowerInUSD += assetPriceInUSD * balance * getAssetDebtRatioThreshold(assets[i]) / (10**6 * assetUnit);
        }
        
        borrowingPowerInUSD = (borrowingPowerInUSD > totalBorrowBalanceInUSD) ? borrowingPowerInUSD - totalBorrowBalanceInUSD : 0;
    }

    /**
    * @dev liquidates the user if his health factor is less than 1
    * @param _user the address of the user to be liquidated
    **/
    function liquidation(address _user) external onlyLiquidator {

    }

}