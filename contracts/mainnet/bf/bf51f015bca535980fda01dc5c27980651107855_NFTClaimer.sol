/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

// Sources flattened with hardhat v2.6.8 https://hardhat.org
// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/[email protected]


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


// File @openzeppelin/contracts/security/[email protected]


pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
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
}


// File @openzeppelin/contracts/security/[email protected]


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


// File @openzeppelin/contracts/access/[email protected]


pragma solidity ^0.8.0;

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/interface/ISquidPlayerNFT.sol

pragma solidity 0.8.9;

interface ISquidPlayerNFT {
    struct TokensViewFront {
        uint tokenId;
        uint8 rarity;
        address tokenOwner;
        uint128 squidEnergy;
        uint128 maxSquidEnergy;
        uint32 contractEndTimestamp;
        uint32 contractV2EndTimestamp;
        uint32 busyTo; //Timestamp until which the player is busy
        uint32 createTimestamp;
        bool stakeFreeze;
        string uri;
        bool contractBought;
    }

    function getToken(uint _tokenId) external view returns (TokensViewFront memory);

    function mint(
        address to,
        uint128 squidEnergy,
        uint32 contractEndTimestamp,
        uint8 rarity
    ) external;

    function lockTokens(
        uint[] calldata tokenId,
        uint32 busyTo,
        bool willDecrease, //will decrease SE or not
        address user,
        uint contractVersion
    ) external returns (uint128);

    function setPlayerContract(uint[] calldata tokenId, uint32 contractDuration, address user, uint contractVersion) external;

    function squidEnergyDecrease(uint[] calldata tokenId, uint128[] calldata deduction, address user) external;

    function squidEnergyIncrease(uint[] calldata tokenId, uint128[] calldata addition, address user) external;

    function tokenOfOwnerByIndex(address owner, uint index) external view returns (uint tokenId);

    function arrayUserPlayers(address _user) external view returns (TokensViewFront[] memory);

    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function availableSEAmount(address _user) external view returns (uint128 amount);

    function availableSEAmountV2(address _user) external view returns (uint128 amount);

    function totalSEAmount(address _user) external view returns (uint128 amount);

    function getSEAmountFromTokensId(uint[] calldata _tokenId) external view returns(uint totalSeAmount, uint[] memory tokenSeAmount);


}


// File contracts/interface/IBNFT.sol

pragma solidity 0.8.9;

interface IBNFT {
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function balanceOf(address owner) external view returns (uint256 balance);
    function admin() external view returns (address);
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}


// File contracts/NFTClaimer.sol

pragma solidity 0.8.9;


contract NFTClaimer is Ownable, Pausable, ReentrancyGuard {

    uint public playerChancesBase;

    ISquidPlayerNFT public playerNFT;
    IBNFT public vouchers;
    bytes32 salt;
    uint deployBlockNumber;

    struct ChanceTablePlayer {
        uint8 rarity;
        uint128 maxValue;
        uint128 minValue;
        uint32 chance;
    }

    ChanceTablePlayer[] public playerChance; //Player chance table
    mapping(uint => bool) claimedVouchers; //Claimed tokens

    event VoucherExchanged(address user, uint voucherId, uint squidEnergy, uint rarity);

    //Initialize function --------------------------------------------------------------------------------------------

    constructor(ISquidPlayerNFT _playerNFT, IBNFT _vouchers) {

        playerNFT = _playerNFT;
        vouchers = _vouchers;
        deployBlockNumber = block.number;

        playerChancesBase = 1000;

        playerChance.push(ChanceTablePlayer({rarity: 1, maxValue: 500, minValue: 400, chance: 450}));
        playerChance.push(ChanceTablePlayer({rarity: 2, maxValue: 1200, minValue: 600, chance: 370}));
        playerChance.push(ChanceTablePlayer({rarity: 3, maxValue: 1700, minValue: 1300, chance: 120}));
        playerChance.push(ChanceTablePlayer({rarity: 4, maxValue: 2300, minValue: 1800, chance: 50}));
        playerChance.push(ChanceTablePlayer({rarity: 5, maxValue: 3000, minValue: 2400, chance: 10}));
    }

    //Modifiers -------------------------------------------------------------------------------------------------------
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }
    //External functions --------------------------------------------------------------------------------------------
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function recordSalt() external onlyOwner {
        require(block.number > deployBlockNumber, "too early");
        require(salt == 0, "salt recorded");
        salt = blockhash(deployBlockNumber);
    }

    function setPlayerChanceTable(ChanceTablePlayer[] calldata _newPlayerChanceTable)
    external
    onlyOwner
    {
        uint _playerChancesBase = 0;
        delete playerChance;
        for (uint i = 0; i < _newPlayerChanceTable.length; i++) {
            _playerChancesBase += _newPlayerChanceTable[i].chance;
            playerChance.push(_newPlayerChanceTable[i]);
        }
        playerChancesBase = _playerChancesBase;
    }

    //Public functions ----------------------------------------------------------------------------------------------

    function userInfo(address _user) public view returns (uint, uint[] memory) {
        uint balance = vouchers.balanceOf(_user);
        uint dis;
        if (balance > 0) {
            for (uint i = 0; i < balance; i++)
                if(claimedVouchers[vouchers.tokenOfOwnerByIndex(_user, i)]) dis++;
        }
        uint[] memory allTokensId = new uint[](dis);
        uint index = dis;
        for(uint i = 0; i < balance; i++){
            if(claimedVouchers[vouchers.tokenOfOwnerByIndex(_user, i)]){
                allTokensId[--index] = vouchers.tokenOfOwnerByIndex(_user, i);
            }

        }
        return (dis, allTokensId);
    }

    function exchangeAllVouchers() public whenNotPaused {
        for (uint i = vouchers.balanceOf(msg.sender); i > 0; i--) {
            if(claimedVouchers[vouchers.tokenOfOwnerByIndex(msg.sender, i-1)]){
                exchangeVoucher(vouchers.tokenOfOwnerByIndex(msg.sender, i-1));
            }
        }
    }

    function exchangeVoucher(uint voucherId) public whenNotPaused notContract {
        require(msg.sender != vouchers.admin(), "Admin cant exchange voucher");
        require(vouchers.ownerOf(voucherId) == msg.sender, "Not owner of token");
        require(claimedVouchers[voucherId], "Token was claimed or not squidNFT");
        vouchers.safeTransferFrom(msg.sender, address(this), voucherId);
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) public nonReentrant whenNotPaused returns (bytes4) {
        require(_operator == address(this), "Only this contract can send token");
        require(address(msg.sender) == address(vouchers), "Token not allowed");
        require(claimedVouchers[_tokenId], "Token was claimed or not squidNFT");
        require(salt != 0, "salt not record");
        bytes32 hash = keccak256(abi.encodePacked(_tokenId, salt));
        claimedVouchers[_tokenId] = false;
        (uint8 rarity, uint128 squidEnergy) = _getRandomPlayer(hash);
        playerNFT.mint(_from, squidEnergy * 1e18, 0, rarity - 1);

        emit VoucherExchanged(_from, _tokenId, squidEnergy * 1e18, rarity - 1);

        return IBNFT.onERC721Received.selector;
    }

    function setVouchersId(uint[] calldata vouchersId) external onlyOwner {
        for(uint i = 0; i < vouchersId.length; i++){
            claimedVouchers[vouchersId[i]] = true;
        }
    }

    //Internal functions --------------------------------------------------------------------------------------------
    function _isContract(address _addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
    //Private functions --------------------------------------------------------------------------------------------

    function _getRandomPlayer(bytes32 _hash) private view returns (uint8, uint128) {
        ChanceTablePlayer[] memory _playerChance = playerChance;
        uint _randomForRarity = _getRandomMinMax(1, playerChancesBase, _hash);
        uint count = 0;
        for (uint i = 0; i < _playerChance.length; i++) {
            count += _playerChance[i].chance;
            if (_randomForRarity <= count) {
                uint8 rarity = _playerChance[i].rarity;
                uint128 squidEnergy = uint128(_getRandomMinMax(_playerChance[i].minValue, _playerChance[i].maxValue, _hash));
                return (rarity, squidEnergy);
            }
        }
        revert("Cant find random level");
    }

    function _getRandomMinMax(uint _min, uint _max, bytes32 _hash) private pure returns (uint random) {
        uint diff = (_max - _min) + 1;
        random = (uint(_hash) % diff) + _min;
    }
}