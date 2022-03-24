/**
 *Submitted for verification at BscScan.com on 2022-03-24
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

// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)
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

/**
 * @title Incomeisland interface
 */
interface IIncomeisland {
    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @notice set tansfer contract address
     * @param _address tansfer contract address
     */
    function checkTransferPermission(address _address)
        external
        view
        returns (bool);

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getNftType(uint256 _nftType)
        external
        view
        returns (
            uint256,
            string memory,
            string memory,
            uint256,
            uint256
        );

    /**
     * @notice get NFT totalNumber.
     */
    function getNftTotalNumber() external view returns (uint256);
}

/**
 * @title Utility interface
 */
interface IUtility {
    /**
     * @notice get number of income token vs wbnb
     */
    function getIncomeTokenFromBNB(uint256 bnbNumber)
        external
        view
        returns (uint256);

    /**
     * @notice get number of income token vs wbnb
     */
    function getBnbTokenFromDollar(uint256 dollarAmount)
        external
        view
        returns (uint256);
}

/**
 * @title IslandToken interface
 */
interface IIslandToken {
    /**
     * @notice use this function for minting the nft
     * @param _account address which will be minted
     * @param _amount amount which will be minted
     */
    function mintByMinter(address _account, uint256 _amount) external;

    /**
     * @notice use this function for minting the nft
     * @param _account address which will be burned
     * @param _amount  amount which will be burned
     */
    function burnByMinter(address _account, uint256 _amount) external;

    /**
     * @dev See {IERC20-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account) external view returns (uint256);
}

contract MiningCenter is Ownable {
    using Address for address;

    /// @notice Information about the NFT as the property
    struct NftHistory {
        uint256 priceBNB;
        uint256 nftLevel;
        uint256 nftNum;
    }

    /// @notice Information about the mining booster
    struct BoosterInfo {
        uint256 boosterStyle;
        uint256 endStamp;
        uint256 beginStamp;
    }

    /// @notice Information about the mining booster type
    struct BoosterType {
        uint256 boosterDuration; // booster days number
        uint256 bnbPrice; // purchase price with bnb
        uint256 incomePrice; // purchase price with income token
    }

    /// @notice Information about the mining booster type
    struct UpgradeType {
        uint256 upgradeRate; // upgrade % All 100
        uint256 bnbPrice; // purchase price with bnb
        uint256 incomePrice; // purchase price with income token
    }

    /// @notice Information about the mining status
    struct MintStatus {
        uint256 mintedAmount; // All withdrawn amount
        uint256 availableAmount; // current available amount
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyManager() {
        require(
            msg.sender == owner() || msg.sender == marketplaceAddress,
            "permission err"
        );
        _;
    }

    // @notice ERC20 income token
    IIncomeisland public incomeIsland;

    // @notice utility contract interface
    IUtility public utility;

    // @notice ERC20 ISLAND token
    IIslandToken private islandToken;

    // @notice NftHistory
    // owner address => nft type => No => nft num
    mapping(address => mapping(uint256 => mapping(uint256 => NftHistory)))
        public nftHistory;

    // @notice NftHistoryLength
    mapping(address => mapping(uint256 => uint256)) public nftHistoryLength;

    // @notice miningBoosterStatus
    // address => booster owner address
    // BoosterInfo => booster status about the user
    //                endStamp -> end timestamp
    //                boosterType -> 0 : common 1: staff mode 2 ~ N: miningBoosterType
    //                beginStamp -> begining timestamp
    mapping(address => BoosterInfo) public miningBoosterStatus;

    // @notice mining Booster Type list
    // uint256 => order number
    // BoosterType => Booster Type
    //                boosterDuration // booster days number
    //                bnbPrice        // purchase price with bnb
    //                incomePrice     // purchase price with income token
    mapping(uint256 => BoosterType) public miningBoosterType;

    // @notice Minted Status
    // uint256 => order number
    // MintStatus => Minted Status
    //               mintedAmount // All withdrawn amount
    //               availableAmount // current available amount
    mapping(address => MintStatus) public mintedStatus;

    // @notice miningBoosterTypeLength
    uint256 public miningBoosterTypeLength;

    // @notice NFT upgrade Type list
    // uint256 => order number
    // BoosterType => Upgrade Type
    //                upgradeRate     // Upgrade Rate All pros is 100
    //                bnbPrice        // purchase price with bnb
    //                incomePrice     // purchase price with income token
    mapping(uint256 => UpgradeType) public nftUpgradeType;

    // @notice nftUpgradeTypeLength
    uint256 public nftUpgradeTypeLength;

    // @notice item marketplace address
    address public marketplaceAddress;

    // the lowest mining rate. Decimal 4
    uint256 public baseMiningRate;

    // refresh cooldown mine duration. The unit is  1 days * mineCooldownRate.
    uint256 public mineCooldownRate;

    // set the mineFee
    uint256 public mineFee;

    // game wallet address which will send bnb fee.
    address public gameWalletAddress;

    // @notice
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        public beginStampList; // owner address => Nft type => Nft Num => beginStamp

    /**
     * @notice MiningCenter Constructor
     * @param _incomeIsland incomeIsland interface address
     * @param _utility utility contract interface address
     * @param _marketplaceAddress that is the address which can control this contract.
     * @param _islandToken IslandToken interface address
     * @param _gameWalletAddress game wallet address
     */
    constructor(
        IIncomeisland _incomeIsland,
        IUtility _utility,
        address _marketplaceAddress,
        IIslandToken _islandToken,
        address _gameWalletAddress
    ) {
        incomeIsland = _incomeIsland;
        utility = _utility;
        marketplaceAddress = _marketplaceAddress;
        miningBoosterTypeLength = 0;
        baseMiningRate = 5478;
        nftUpgradeTypeLength = 0;
        islandToken = _islandToken;
        mineCooldownRate = 3;
        mineFee = 100000000000000000;
        gameWalletAddress = _gameWalletAddress;
    }

    /**
     * @notice get number of income token vs wbnb
     */
    function getIncomeTokenFromBNB(uint256 bnbNumber)
        public
        view
        returns (uint256)
    {
        return utility.getIncomeTokenFromBNB(bnbNumber);
    }

    /**
     * @notice get number of income token vs wbnb
     */
    function getBnbTokenFromDollar(uint256 dollarAmount)
        public
        view
        returns (uint256)
    {
        return utility.getBnbTokenFromDollar(dollarAmount);
    }

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function checkNftOwner(
        address owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        for (uint256 i = 0; i < nftHistoryLength[owner][_nftType]; i++) {
            if (nftHistory[owner][_nftType][i].nftNum == _nftNum) {
                return 1;
            }
        }
        return 0;
    }

    /**
     * @notice checking the nft owner about the unity asset.
     * @param _nftType the nft type
     */
    function getHistoryIndex(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        for (uint256 i = 0; i < nftHistoryLength[_owner][_nftType]; i++) {
            if (nftHistory[_owner][_nftType][i].nftNum == _nftNum) {
                return i;
            }
        }
        return 9999;
    }

    /**
     * @notice update nftHistory variable.
     * @param _owner the nft owner address
     * @param _nftType the nft type
     * @param _priceBNB the nft bnb price
     * @param _nftLevel nft level 0: basic 1: 2 Graphics cars 2: Small mining rig with 4 graphics cards 3 : Medium mining rig with 6 graphics cards 4: Large mining rig with 8 graphics cards 5 : ASIC miner
     * @param _nftNum the nft unique number
     * @param _mode 0: update 1: add
     */
    function manageNFTHistory(
        address _owner,
        uint256 _nftType,
        uint256 _priceBNB,
        uint256 _nftLevel,
        uint256 _nftNum,
        uint16 _mode
    ) public onlyManager {
        if (_mode == 0) {
            uint256 i = getHistoryIndex(_owner, _nftType, _nftNum);
            nftHistory[_owner][_nftType][i] = NftHistory(
                _priceBNB,
                _nftLevel,
                _nftNum
            );
        } else if (_mode == 1) {
            nftHistory[_owner][_nftType][
                nftHistoryLength[_owner][_nftType]
            ] = NftHistory(_priceBNB, _nftLevel, _nftNum);
            nftHistoryLength[_owner][_nftType]++;
        }
    }

    /**
     * @notice add nftHistory variable.
     * @param _owner the nft owner address
     * @param _nftType the nft type
     * @param _nftNum the nft unique number
     * @param _mode 0: remove 1: add
     */
    function updateNFTHistory(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum,
        uint16 _mode
    ) public {
        if (_mode == 0) {
            for (
                uint256 i = getHistoryIndex(_owner, _nftType, _nftNum);
                i < nftHistoryLength[_owner][_nftType] - 1;
                i++
            ) {
                nftHistory[_owner][_nftType][i] = nftHistory[_owner][_nftType][
                    i + 1
                ];
            }
            nftHistory[_owner][_nftType][
                nftHistoryLength[_owner][_nftType] - 1
            ] = NftHistory(0, 0, 0);
            nftHistoryLength[_owner][_nftType]--;
        } else if (_mode == 1) {
            (uint256 priceBNB, , , , ) = incomeIsland.getNftType(_nftType);
            nftHistory[_owner][_nftType][
                nftHistoryLength[_owner][_nftType]
            ] = NftHistory(priceBNB, 0, _nftNum);
            nftHistoryLength[_owner][_nftType]++;
        }
    }

    /**
     * @notice manage Booster Type
     * @param _boosterDuration // booster days number
     * @param _bnbPrice // purchase price with bnb
     * @param _incomePrice // purchase price with income token
     * @param _which // the index which will manage the booster type
     * @param _mode // 0 : add 1 : update 2 : remove
     */
    function manageBoosterType(
        uint256 _boosterDuration,
        uint256 _bnbPrice,
        uint256 _incomePrice,
        uint256 _which,
        uint256 _mode
    ) external onlyManager {
        if (_mode == 0) {
            miningBoosterType[miningBoosterTypeLength++] = BoosterType(
                _boosterDuration,
                _bnbPrice,
                _incomePrice
            );
        } else if (_mode == 1) {
            require(
                _mode >= 0 && _mode <= miningBoosterTypeLength,
                "which error"
            );
            miningBoosterType[_which] = BoosterType(
                _boosterDuration,
                _bnbPrice,
                _incomePrice
            );
        } else if (_mode == 2) {
            require(
                _mode >= 0 && _mode <= miningBoosterTypeLength,
                "which error"
            );
            for (uint256 i = _which; i < miningBoosterTypeLength - 1; i++) {
                miningBoosterType[i] = miningBoosterType[i + 1];
            }
            miningBoosterType[--miningBoosterTypeLength] = BoosterType(0, 0, 0);
        }
    }

    /**
     * @notice manage NFT upgrade Type
     * @param _upgradeRate // upgrade % All 100
     * @param _bnbPrice // purchase price with bnb
     * @param _incomePrice // purchase price with income token
     * @param _which // the index which will manage the booster type
     * @param _mode // 0 : add 1 : update 2 : remove
     */
    function manageNFTUpgradeType(
        uint256 _upgradeRate,
        uint256 _bnbPrice,
        uint256 _incomePrice,
        uint256 _which,
        uint256 _mode
    ) external onlyManager {
        if (_mode == 0) {
            nftUpgradeType[nftUpgradeTypeLength++] = UpgradeType(
                _upgradeRate,
                _bnbPrice,
                _incomePrice
            );
        } else if (_mode == 1) {
            require(_mode >= 0 && _mode <= nftUpgradeTypeLength, "which error");
            nftUpgradeType[_which] = UpgradeType(
                _upgradeRate,
                _bnbPrice,
                _incomePrice
            );
        } else if (_mode == 2) {
            require(_mode >= 0 && _mode <= nftUpgradeTypeLength, "which error");
            for (uint256 i = _which; i < nftUpgradeTypeLength - 1; i++) {
                nftUpgradeType[i] = nftUpgradeType[i + 1];
            }
            nftUpgradeType[--nftUpgradeTypeLength] = UpgradeType(0, 0, 0);
        }
    }

    /**
     * @notice Set incomeIsland interface address
     * @param _incomeIsland IIncomeisland address
     */
    function setIIncomeIsland(IIncomeisland _incomeIsland) external onlyOwner {
        incomeIsland = _incomeIsland;
    }

    /**
     * @notice Set island token address
     * @param _islandToken IIncomeisland address
     */
    function setIslandToken(IIslandToken _islandToken) external onlyOwner {
        islandToken = _islandToken;
    }

    /**
     * @notice Set mineCooldownRate
     * @param _mineCooldownRate mineCooldownRate
     */
    function setMineCooldownRate(uint256 _mineCooldownRate) external onlyOwner {
        mineCooldownRate = _mineCooldownRate;
    }

    /**
     * @notice set marketplace address
     * @param _marketplaceAddress marketplace address
     */
    function setMarketplaceAddress(address _marketplaceAddress)
        external
        onlyOwner
    {
        marketplaceAddress = _marketplaceAddress;
    }

    /**
     * @notice set utility address
     * @param _utility utility address
     */
    function setUtilityAddress(IUtility _utility) external onlyOwner {
        utility = _utility;
    }

    /**
     * @notice set base mining rate
     * @param _baseMiningRate mining rate
     */
    function setBaseMiningRate(uint256 _baseMiningRate) external onlyOwner {
        baseMiningRate = _baseMiningRate;
    }

    /**
     * @notice manage NFT upgrade Type
     * @param _owner // nft owner address
     * @param _boosterStyle // booster Style
     */
    function manageBoosterStatus(address _owner, uint256 _boosterStyle)
        external
        onlyManager
    {
        proceedAvailableMining(_owner, 0, 0, 1);
        if (_boosterStyle == 1 || _boosterStyle == 0) {
            miningBoosterStatus[_owner] = BoosterInfo(
                _boosterStyle,
                block.timestamp,
                block.timestamp
            );
        } else if (_boosterStyle > 1) {
            if (miningBoosterStatus[_owner].endStamp > block.timestamp) {
                miningBoosterStatus[_owner] = BoosterInfo(
                    _boosterStyle,
                    miningBoosterStatus[_owner].endStamp +
                        miningBoosterType[_boosterStyle - 2].boosterDuration *
                        1 days *
                        mineCooldownRate,
                    block.timestamp
                );
            } else {
                miningBoosterStatus[_owner] = BoosterInfo(
                    _boosterStyle,
                    block.timestamp +
                        miningBoosterType[_boosterStyle - 2].boosterDuration *
                        1 days *
                        mineCooldownRate,
                    block.timestamp
                );
            }
        }
    }

    /**
     * @notice get number of income token vs wbnb
     */
    function getAvailableMintedAmount(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        BoosterInfo memory boosterStatus = miningBoosterStatus[_owner];
        if (boosterStatus.boosterStyle == 0) {
            if (
                beginStampList[_owner][_nftType][_nftNum] +
                    1 days *
                    mineCooldownRate <=
                block.timestamp
            ) {
                return 1;
            } else {
                return 0;
            }
        } else if (boosterStatus.boosterStyle == 1) {
            uint256 different = block.timestamp - boosterStatus.beginStamp;
            return (different / 1 days) * mineCooldownRate;
        } else {
            if (boosterStatus.endStamp >= block.timestamp) {
                uint256 different = block.timestamp - boosterStatus.beginStamp;
                return (different / 1 days) * mineCooldownRate;
            } else {
                uint256 currentMinted = 0;
                if (
                    boosterStatus.endStamp + 1 days * mineCooldownRate >=
                    block.timestamp
                ) {
                    currentMinted = 1;
                }
                if (boosterStatus.endStamp >= boosterStatus.beginStamp) {
                    uint256 different = boosterStatus.endStamp -
                        boosterStatus.beginStamp;
                    return
                        (different / 1 days) * mineCooldownRate + currentMinted;
                } else {
                    return currentMinted;
                }
            }
        }
    }

    /**
     * @notice get seconds until mining
     */
    function getRemainTimeBySeconds(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum
    ) public view returns (uint256) {
        BoosterInfo memory boosterStatus = miningBoosterStatus[_owner];
        if (boosterStatus.boosterStyle == 0) {
            if (
                beginStampList[_owner][_nftType][_nftNum] +
                    1 days *
                    mineCooldownRate <=
                block.timestamp
            ) {
                return 0;
            } else {
                return
                    (beginStampList[_owner][_nftType][_nftNum] +
                        1 days *
                        mineCooldownRate -
                        block.timestamp) / 1 seconds;
            }
        } else if (boosterStatus.boosterStyle == 1) {
            return 0;
        } else {
            if (boosterStatus.endStamp < block.timestamp) {
                if (
                    boosterStatus.endStamp + 1 days * mineCooldownRate <
                    block.timestamp
                ) {
                    return
                        (boosterStatus.endStamp +
                            1 days *
                            mineCooldownRate -
                            block.timestamp) / 1 seconds;
                }
            }
            return 0;
        }
    }

    /**
     * @notice do the daily mining and save the available amount.
     * @param _nftType // nft type
     * @param _nftNum // nft uniqe number
     */
    function dailyMining(uint256 _nftType, uint256 _nftNum) external payable {
        require(
            msg.value >= utility.getBnbTokenFromDollar(mineFee),
            "no enough bnb"
        );
        require(
            checkNftOwner(msg.sender, _nftType, _nftNum) == 1,
            "permission error"
        );
        proceedAvailableMining(msg.sender, _nftType, _nftNum, 0);
        address payable gameWallet = payable(
            address(uint160(gameWalletAddress))
        );
        gameWallet.transfer(utility.getBnbTokenFromDollar(mineFee));
    }

    /**
     * @notice proceed the available minted status.
     * @param _owner // owner address
     */
    function getTotalAvailableAmountByIsland(address _owner)
        external
        view
        returns (uint256)
    {
        BoosterInfo memory boosterStatus = miningBoosterStatus[_owner];
        if (boosterStatus.boosterStyle == 0) {
            return mintedStatus[_owner].availableAmount;
        } else {
            uint256 availableDays = getAvailableMintedAmount(_owner, 0, 0);
            uint256 totalMintedAmount = 0;
            for (
                uint256 nftType = 0;
                nftType < incomeIsland.getNftTotalNumber();
                nftType++
            ) {
                for (
                    uint256 i = 0;
                    i < nftHistoryLength[_owner][nftType];
                    i++
                ) {
                    NftHistory memory history = nftHistory[_owner][nftType][i];
                    uint256 expectedMiningAmount = (history.priceBNB *
                        baseMiningRate) / 1000000;
                    if (history.nftLevel > 0) {
                        expectedMiningAmount =
                            (((history.priceBNB *
                                (nftUpgradeType[history.nftLevel - 1]
                                    .upgradeRate + 100)) / 100) *
                                baseMiningRate) /
                            1000000;
                    }

                    if (
                        incomeIsland.balanceOf(_owner, nftType) ==
                        nftHistoryLength[_owner][nftType]
                    ) {
                        totalMintedAmount =
                            totalMintedAmount +
                            availableDays *
                            expectedMiningAmount;
                    }
                }
            }
            return mintedStatus[_owner].availableAmount + totalMintedAmount;
        }
    }

    /**
     * @notice proceed the available minted status.
     * @param _owner // owner address
     * @param _nftType // nft type
     * @param _nftNum // nft uniqe number
     * @param _mode // 0: dailyMining 1: manageBooster
     */
    function proceedAvailableMining(
        address _owner,
        uint256 _nftType,
        uint256 _nftNum,
        uint256 _mode
    ) private {
        BoosterInfo memory boosterStatus = miningBoosterStatus[_owner];
        uint256 availableDays = getAvailableMintedAmount(
            _owner,
            _nftType,
            _nftNum
        );
        require(availableDays > 0, "not available");
        uint256 totalMintedAmount = 0;
        for (
            uint256 nftType = 0;
            nftType < incomeIsland.getNftTotalNumber();
            nftType++
        ) {
            for (uint256 i = 0; i < nftHistoryLength[_owner][nftType]; i++) {
                NftHistory memory history = nftHistory[_owner][nftType][i];
                uint256 expectedMiningAmount = (history.priceBNB *
                    baseMiningRate) / 1000000;
                if (history.nftLevel > 0) {
                    expectedMiningAmount =
                        (((history.priceBNB *
                            (nftUpgradeType[history.nftLevel - 1].upgradeRate +
                                100)) / 100) * baseMiningRate) /
                        1000000;
                }

                if (_mode == 1) {
                    availableDays = getAvailableMintedAmount(
                        _owner,
                        nftType,
                        history.nftNum
                    );
                }

                if (
                    boosterStatus.boosterStyle == 0 &&
                    incomeIsland.balanceOf(_owner, nftType) ==
                    nftHistoryLength[_owner][nftType]
                ) {
                    if (
                        _nftType == nftType &&
                        history.nftNum == _nftNum &&
                        _mode == 0
                    ) {
                        totalMintedAmount =
                            availableDays *
                            expectedMiningAmount;

                        beginStampList[_owner][_nftType][_nftNum] = block
                            .timestamp;
                    } else if (_mode == 1) {
                        totalMintedAmount =
                            totalMintedAmount +
                            availableDays *
                            expectedMiningAmount;
                        beginStampList[_owner][nftType][history.nftNum] = block
                            .timestamp;
                    }
                } else if (
                    incomeIsland.balanceOf(_owner, nftType) ==
                    nftHistoryLength[_owner][nftType]
                ) {
                    totalMintedAmount =
                        totalMintedAmount +
                        availableDays *
                        expectedMiningAmount;
                }

                if (
                    miningBoosterStatus[_owner].endStamp < block.timestamp &&
                    miningBoosterStatus[_owner].boosterStyle > 1
                ) {
                    if (
                        miningBoosterStatus[_owner].endStamp +
                            1 days *
                            mineCooldownRate >=
                        block.timestamp
                    ) {
                        beginStampList[_owner][_nftType][_nftNum] = block
                            .timestamp;
                    } else {
                        beginStampList[_owner][_nftType][
                            _nftNum
                        ] = miningBoosterStatus[_owner].endStamp;
                    }
                }
            }
        }

        mintedStatus[_owner] = MintStatus(
            mintedStatus[_owner].mintedAmount,
            mintedStatus[_owner].availableAmount + totalMintedAmount
        );

        if (
            miningBoosterStatus[_owner].endStamp < block.timestamp &&
            miningBoosterStatus[_owner].boosterStyle > 1
        ) {
            miningBoosterStatus[_owner] = BoosterInfo(
                0,
                miningBoosterStatus[_owner].endStamp,
                miningBoosterStatus[_owner].endStamp
            );
        } else if (miningBoosterStatus[_owner].boosterStyle != 0) {
            miningBoosterStatus[_owner] = BoosterInfo(
                miningBoosterStatus[_owner].boosterStyle,
                miningBoosterStatus[_owner].endStamp,
                block.timestamp
            );
        }
    }

    /**
     * @notice withdraw
     */
    function withdraw() external {
        require(mintedStatus[msg.sender].availableAmount > 0, "not available");
        proceedAvailableMining(msg.sender, 0, 0, 0);
        islandToken.mintByMinter(
            msg.sender,
            mintedStatus[msg.sender].availableAmount
        );
        mintedStatus[msg.sender] = MintStatus(
            mintedStatus[msg.sender].mintedAmount +
                mintedStatus[msg.sender].availableAmount,
            0
        );
    }

    /**
     * @notice mine about the all mining property.
     */
    function MiningAllProperty() external payable {
        require(
            msg.value >= utility.getBnbTokenFromDollar(mineFee),
            "no enough bnb"
        );
        proceedAvailableMining(msg.sender, 0, 0, 1);
        address payable gameWallet = payable(
            address(uint160(gameWalletAddress))
        );
        gameWallet.transfer(utility.getBnbTokenFromDollar(mineFee));
    }

    /**
     * @notice withdraw
     * @param _owner // owner address
     * @param _mintedAmount // minted Amount
     * @param _availableAmount // available Amount
     * @param _mode // 0: mintedAmount and availableAmount will be added 1: mintedAmount and availableAmount will be replaced
     */
    function manageMintedStatus(
        address _owner,
        uint256 _mintedAmount,
        uint256 _availableAmount,
        uint256 _mode
    ) external {
        require(_owner != address(0), "address error");
        if (_mode == 0) {
            mintedStatus[_owner] = MintStatus(
                mintedStatus[_owner].mintedAmount + _mintedAmount,
                mintedStatus[_owner].availableAmount + _availableAmount
            );
        } else {
            mintedStatus[_owner] = MintStatus(_mintedAmount, _availableAmount);
        }
    }

    /**
     * @notice burn island Token
     * @param _owner // owner address
     * @param _amount // burn amount
     */
    function burnIsland(address _owner, uint256 _amount) external onlyManager {
        require(islandToken.balanceOf(_owner) >= _amount, "amount error");
        islandToken.burnByMinter(_owner, _amount);
    }

    /**
     * @notice set game wallet address
     * @param _gameWalletAddress // game wallet address
     */
    function setGameWalletAddress(address _gameWalletAddress)
        external
        onlyManager
    {
        require(_gameWalletAddress != address(0), "Dead address error");
        gameWalletAddress = _gameWalletAddress;
    }

    /**
     * @notice set mine fee
     * @param _mineFee // mine Fee with USD. The decimal is 18.
     */
    function setMineFee(uint256 _mineFee) external onlyManager {
        mineFee = _mineFee;
    }
}