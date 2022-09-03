// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IClashFantasyVault {
    function withdraw(address _to, uint256 _amount, uint256 _hasNfts) external;
}

interface IClashFantasyCards {
    function getInternalUserTokenById(address from, uint256 tokenId)
        external
        view
        returns (
            uint256 _amount,
            uint256 _aditionalId,
            uint256 _manaPower,
            uint256 _hasMana,
            uint256 _fansyExtra,
            uint256 _cardLevel,
            uint256 _energy,
            uint256 _typeOf
        );

    function updateCardEnergyBatch(uint256[] memory _tokenId, address _from) external;
    function getCountUserToken(address _address) external view returns(uint256);
}

interface IClashFantasyDecks {
    function updateDeckState(
        address _from,
        uint256 _tokenId,
        uint256 _state
    ) external;

    function getDeckById(address _from, uint256 _tokenId)
        external
        view
        returns (
            uint256, // typeOf
            uint256, // deckLevel
            uint256, // activatePoint
            uint256, // manaSum
            uint256, // fansySum
            uint256, // deckState,
            uint256  // amount
            
        );



    function getCardsInDeckArr(uint256 _tokenId) external view returns (uint256[] memory);

    function updateDeckEnergy(uint256 _tokenId, address _from) external;
}

contract ClashFantasyMiniGameV3 is Initializable {
    address private adminContract;
    IClashFantasyDecks private contractDeck;
    IClashFantasyCards private contractCard;
    IClashFantasyVault private contractVault;
    IERC20 private contractErc20;
    address private walletPrimary;
    address private walletSecondary;
    uint256 private random;

    struct RewardTable {
        uint256 manaPowerAllow;
        uint256 percentage;
        uint256 reward;
    }

    struct DeckTime {
        uint256 lastActivated;
        bool result;
        uint256 reward;
    }
    mapping(uint256 => DeckTime[]) private deckTimeArr;
    mapping(address => uint256) private withdrawLastArr;
    mapping(address => uint256) private rewardArr;
    mapping(uint256 => mapping(address => int256)) private arenaRankingArr;

    RewardTable[] private rangeGame;
    uint256 prePercentageTax;
    uint256 percentageTax;
    address private walletTax;

    address private externalUpdater;
    modifier checkTimeDeckCanPlay(uint256 _tokenId) {
        if (deckTimeArr[_tokenId].length == 0) {
            _;
        } else {
            uint256 _last = deckTimeArr[_tokenId][deckTimeArr[_tokenId].length - 1].lastActivated;
            if (_last != 0) {
                require(_last + 1 days <= block.timestamp, "Locked");
            }
            _;
        }
    }

    modifier onlyAdminOwner() {
        require(
            adminContract == msg.sender,
            "Only the contract admin owner can call this function"
        );
        _;
    }

    modifier onlyExternalUpdater() {
        require(externalUpdater == msg.sender, "ClashFantasyMiniGame contract invalid updater");
        _;
    }

    function initialize(IClashFantasyDecks _contractDeck, IClashFantasyCards _contractCard)
        public
        initializer
    {
        adminContract = msg.sender;
        contractDeck = _contractDeck;
        contractCard = _contractCard;
    }

    function withdraw(uint256 _amount) public {
        require(withdrawLastArr[msg.sender] + 1 days <= block.timestamp, "withdraw Locked");
        uint256 amount = _amount * 10**16;
        require(rewardArr[msg.sender] >= amount, "Wallet Balance insuficent");
        rewardArr[msg.sender] -= amount;
        contractVault.withdraw(msg.sender, amount, contractCard.getCountUserToken(msg.sender));
        withdrawLastArr[msg.sender] = block.timestamp;
    }

    function getLastWithdrawAdd(address _from) public view returns (uint256) {
        return withdrawLastArr[_from];
    }

    function playClickToEarn(uint256 _arenaSelected, uint256 _deckTokenId)
        public
        checkTimeDeckCanPlay(_deckTokenId)
    {
        (   ,
            ,
            uint256 _activatePoint,
            uint256 _manaSum,
            uint256 _fansySum,
            uint256 _deckState,
            uint256 cardAmount
        ) = contractDeck.getDeckById(msg.sender, _deckTokenId);

        uint256 reward = rangeGame[_arenaSelected].reward * 10**18;
        uint256 amount = ((((reward * _fansySum) / 100) + reward) * prePercentageTax) / 100;
        preGameTax(amount);

        require(cardAmount == 8, "checkCanPlay: Deck must have eight cards");
        require(_deckState == 1, "checkCanPlay: Deck must be enabled");
        require(_activatePoint >= 1, "Deck need more energy");
        require(
            rangeGame[_arenaSelected].manaPowerAllow <= _manaSum,
            "Deck Need more Mana to Play in this arena"
        );
        (bool canPlay, uint256[] memory _cardsToUpdate) = checkCanPlay(_deckTokenId);
        require(canPlay == true, "Cards in deck need more energy");
        random++;
        bool success = checkFail(rangeGame[_arenaSelected].percentage);
        uint256 _reward = 0;
        if (success) {
            rewardArr[msg.sender] += (((reward * _fansySum) / 100) + reward);
            _reward = (((reward * _fansySum) / 100) + reward);
        }
        
        contractCard.updateCardEnergyBatch(_cardsToUpdate, msg.sender);
        contractDeck.updateDeckEnergy(_deckTokenId, msg.sender);
        deckTimeArr[_deckTokenId].push(DeckTime(block.timestamp, success, _reward));
    }

    function getRewardWallet(address _address) public view returns (uint256) {
        return (rewardArr[_address]);
    }

    function setRangeGame(
        uint256[] memory _manaPowerAllow,
        uint256[] memory _percentage,
        uint256[] memory _reward
    ) public {
        delete rangeGame;
        for (uint256 index = 0; index < _manaPowerAllow.length; index++) {
            RewardTable memory room = RewardTable(
                _manaPowerAllow[index],
                _percentage[index],
                _reward[index]
            );
            rangeGame.push(room);
        }
    }

    function getLastTimeDeckPlayed(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            bool,
            uint256
        )
    {
        uint256 index = deckTimeArr[_tokenId].length;
        if (index == 0) {
            return (0, false, 0);
        }
        index = index - 1;
        if (index >= deckTimeArr[_tokenId].length) {
            return (0, false, 0);
        } else {
            return (
                deckTimeArr[_tokenId][index].lastActivated,
                deckTimeArr[_tokenId][index].result,
                deckTimeArr[_tokenId][index].reward
            );
        }
    }

    function changeFromGame(uint256 _amount) public {
        require(rewardArr[msg.sender] >= _amount, "Wallet Balance insuficent");
        rewardArr[msg.sender] -= _amount;
    }

    function getDeckPlayed(uint256 _tokenId) public view returns (DeckTime[] memory) {
        return deckTimeArr[_tokenId];
    }

    function getRangeGame() public view returns (RewardTable[] memory) {
        return rangeGame;
    }

    function checkCanPlay(uint256 _deckTokenId) public view returns (bool, uint256[] memory) {
        bool can = true;
        uint256[] memory cards = contractDeck.getCardsInDeckArr(_deckTokenId);
        for (uint256 index = 0; index < cards.length; index++) {
            (, , , , , , uint256 _energy, ) = contractCard.getInternalUserTokenById(
                msg.sender,
                cards[index]
            );
            if (_energy == 0) {
                can = false;
            }
        }
        return (can, cards);
    }

    function preGameTax(uint256 _amount) internal {
        uint256 balance = contractErc20.balanceOf(msg.sender);
        require(balance >= _amount, "preGameTax: Check the token balance");

        uint256 allowance = contractErc20.allowance(msg.sender, address(this));
        require(allowance == _amount, "preGameTax: Check the token allowance");

        uint256 toTaxWallet = (_amount / uint256(100)) * percentageTax;
        uint256 normalTransfer = (_amount / uint256(100)) * uint256( 100 - percentageTax );
        uint256 half = normalTransfer / 2;

        contractErc20.transferFrom(msg.sender, walletTax, toTaxWallet);
        contractErc20.transferFrom(msg.sender, walletPrimary, half);
        contractErc20.transferFrom(msg.sender, walletSecondary, half);
    }

    function checkFail(uint256 _percentage) internal view returns (bool) {
        uint256[] memory myArray = new uint256[](100);
        for (uint256 j = 0; j < _percentage; j++) {
            if (j < _percentage) {
                myArray[j] = 1;
            }
        }
        uint256 purchasenumber = uint256(
            keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender, random))
        ) % 100;
        bool success = false;

        if (myArray[purchasenumber] == 1) {
            success = true;
        }
        return (success);
    }

    function getPercentageTax() public view returns(uint256) {
        return prePercentageTax;
    }

    function updatePrePercentage(uint256 _prePercentageTax) public onlyAdminOwner {
        prePercentageTax = _prePercentageTax;
    }

    function setPercentageTax(uint256 _percentageTax) public onlyAdminOwner {
        percentageTax = _percentageTax;
    }

    function setWalletTax(address _walletTax) public onlyAdminOwner {
        walletTax = _walletTax;
    }

    function setContractErc20(IERC20 _contractErc20) public onlyAdminOwner {
        contractErc20 = _contractErc20;
    }

    function setVaultContract(IClashFantasyVault _contractVault) public onlyAdminOwner {
        contractVault = _contractVault;
    }

    function setWalletPrimary(address _address) public onlyAdminOwner {
        walletPrimary = _address;
    }

    function setWalletSecondary(address _address) public onlyAdminOwner {
        walletSecondary = _address;
    }

    function setExternalUpdater(address _contract) external onlyAdminOwner {
        externalUpdater = _contract;
    }

    function claimFromGame(address _address, uint256 _amount) public onlyExternalUpdater {
        rewardArr[_address] += _amount;
    }

    function getWalletVault() public view returns (address, address) {
        return (walletPrimary, walletSecondary);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
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
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

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