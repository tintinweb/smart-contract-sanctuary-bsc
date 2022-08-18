//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import './RedCat.sol';
import "./Arrays.sol";

contract CryptoStal is Ownable, ReentrancyGuard {

    using Arrays for uint[];
    // constants
    RedCat RedCatContract = RedCat(0xB7C9cdeA055474167baBA30098b91969C042cb6c);
    uint NO_RARITY = 99;

    // attributes
    uint public digPrice = 0.01 ether;
    uint public baseDigPool = 10;
    uint public baseRedCatPoolRate = 10;
    uint public armsCount = 2;
    uint public roleCount = 12;
    uint public thingsCount = 10;
    address public redCatPoolAddress;
    mapping(address => string) playerName;
    Probability gameProbability;
    Reward gameReward;

    // structs
    struct Probability {
        uint[] commonProbability;
        uint[] rareProbability;
        uint[] legendProbability;
    }

    struct Reward {
        uint[] commonReward;
        uint[] rareReward;
        uint[] legendReward;
    }

    // modifiers
    modifier canDigCryptoStal {
        require(msg.value == digPrice, "money sent is not correct");
        require(msg.sender == tx.origin, "contract don't play");
        _;
    }

    // events
    event RedCatDigLog(address indexed digAddress, uint indexed rarity, uint armsNumber, uint roleNumber, uint thingsNumber, uint indexed cryptoStal);
    event AddPool(address sponsor, uint money);

    receive() external payable {
        emit AddPool(msg.sender, msg.value);
    }

    constructor(uint[] memory _commonProbability, uint[] memory _commonReward, uint[] memory _rareProbability, uint[] memory _rareReward, uint[] memory _legendProbability, uint[] memory _legendReward) {
        gameProbability = Probability(_commonProbability, _rareProbability, _legendProbability);
        gameReward = Reward(_commonReward, _rareReward, _legendReward);
    }

    // dig
    function redCatDig(uint _tokenId) external payable nonReentrant canDigCryptoStal {
        require(isRedCatOwner(_tokenId), "cat isn't your");

        checkBasePool();

        (, uint rarity) = getRarity(_tokenId);
        if (rarity == 0 || rarity == 1) {
            uint end = gameProbability.rareProbability[gameProbability.rareProbability.length - 1] + 1;
            uint reward = gameReward.rareReward[gameProbability.rareProbability.findUpperBound(random(rarity) % end)] * 1 gwei;
            (bool success1,) = msg.sender.call{value : reward}("");
            require(success1, "msg.sender pay failed");

            (uint armsNumber, uint roleNumber, uint thingsNumber) = calculateNumber(reward, rarity);

            emit RedCatDigLog(msg.sender, rarity, armsNumber, roleNumber, thingsNumber, reward);
        } else {
            uint end = gameProbability.legendProbability[gameProbability.legendProbability.length - 1] + 1;
            uint reward = gameReward.legendReward[gameProbability.legendProbability.findUpperBound(random(rarity) % end)] * 1 gwei;
            (bool success1,) = msg.sender.call{value : reward}("");
            require(success1, "msg.sender pay failed");

            (uint armsNumber, uint roleNumber, uint thingsNumber) = calculateNumber(reward, rarity);

            emit RedCatDigLog(msg.sender, rarity, armsNumber, roleNumber, thingsNumber, reward);
        }
    }

    // no redCat dig
    function dig() external payable nonReentrant canDigCryptoStal {
        checkBasePool();

        uint end = gameProbability.commonProbability[gameProbability.commonProbability.length - 1] + 1;
        uint reward = gameReward.commonReward[gameProbability.commonProbability.findUpperBound(random(NO_RARITY) % end)] * 1 gwei;
        (bool success1,) = msg.sender.call{value : reward}("");
        require(success1, "msg.sender pay failed");

        (uint armsNumber, uint roleNumber, uint thingsNumber) = calculateNumber(reward, NO_RARITY);

        emit RedCatDigLog(msg.sender, NO_RARITY, armsNumber, roleNumber, thingsNumber, reward);
    }

    function setPlayerName(string memory _name) external {
        playerName[msg.sender] = _name;
    }

    // only owner
    function clearCrystalShards() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setDigPrice(uint _digPrice) external onlyOwner {
        digPrice = _digPrice;
    }

    function setBaseDigPool(uint _baseDigPool) external onlyOwner {
        baseDigPool = _baseDigPool;
    }

    function setBaseRedCatPoolRate(uint _baseRedCatPoolRate) external onlyOwner {
        baseRedCatPoolRate = _baseRedCatPoolRate;
    }

    function setArmsCount(uint _armsCount) external onlyOwner {
        armsCount = _armsCount;
    }

    function setRoleCount(uint _roleCount) external onlyOwner {
        roleCount = _roleCount;
    }

    function setThingsCount(uint _thingsCount) external onlyOwner {
        thingsCount = _thingsCount;
    }

    // set probability
    function setCommonProbability(uint[] calldata _commonProbability) external onlyOwner {
        gameProbability.commonProbability = _commonProbability;
    }

    function setRareProbability(uint[] calldata _rareProbability) external onlyOwner {
        gameProbability.rareProbability = _rareProbability;
    }

    function setLegendProbability(uint[] calldata _legendProbability) external onlyOwner {
        gameProbability.legendProbability = _legendProbability;
    }

    // set reward
    function setCommonReward(uint[] calldata _commonReward) external onlyOwner {
        gameReward.commonReward = _commonReward;
    }

    function setRareReward(uint[] calldata _rareReward) external onlyOwner {
        gameReward.rareReward = _rareReward;
    }

    function setLegendReward(uint[] calldata _legendReward) external onlyOwner {
        gameReward.legendReward = _legendReward;
    }

    function setRedCatPoolAddress(address _redCatPoolAddress) external onlyOwner {
        redCatPoolAddress = _redCatPoolAddress;
    }

    // getter
    function getPlayerName(address _player) public view returns (string memory) {
        return playerName[_player];
    }

    function getPool() public view returns (uint) {
        return address(this).balance;
    }

    function getRarity(uint _tokenId) public view returns (uint, uint) {
        return RedCatContract.getRarity(_tokenId);
    }

    function isRedCatOwner(uint _tokenId) public view returns (bool) {
        if (msg.sender == RedCatContract.ownerOf(_tokenId)) {
            return true;
        } else {
            return false;
        }
    }

    function getGameProbability() public view returns (Probability memory probability) {
        probability = gameProbability;
    }

    function getGameReward() public view returns (Reward memory reward) {
        reward = gameReward;
    }

    function calculateNumber(uint reward, uint rarity) private view returns (uint armsNumber, uint roleNumber, uint thingsNumber) {
        armsNumber = (random(rarity)) % armsCount;
        roleNumber = (random(rarity) - reward) % roleCount;
        thingsNumber = (random(rarity) + reward) % thingsCount;
    }

    function checkBasePool() private {
        if (getPool() - digPrice > baseDigPool) {
            uint forRedCat = msg.value * baseRedCatPoolRate / 100;
            (bool success1,) = redCatPoolAddress.call{value : forRedCat}("");
            require(success1, "redCatPoolAddress pay failed");
        }
    }

    function random(uint rarity) public view returns (uint) {
        return uint(keccak256(abi.encodePacked(blockhash(block.number), msg.sender, block.number, block.timestamp, rarity)));
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

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;


interface RedCat {
    function getRarity(uint _tokenId) external view returns (uint, uint);
    function ownerOf(uint _tokenId) external view returns (address);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library Arrays {

    function findUpperBound(uint[] storage array, uint element) internal view returns (uint) {
        uint low = 0;
        uint high = array.length;

        while (low < high) {
            uint256 mid = average(low, high);
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
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