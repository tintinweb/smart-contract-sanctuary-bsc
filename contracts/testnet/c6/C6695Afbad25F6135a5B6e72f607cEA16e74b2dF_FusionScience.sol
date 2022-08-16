// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract FusionScience is Ownable {
    uint256[] public classRandRates = [3300, 6600, 9900, 9900, 10000];
    uint256[] public dinoClasses = [1, 2, 3, 4, 5];
    mapping(uint256 => uint256) public dinoRarityToSuccessRate;
    address public fusionLabContract;

    constructor() {
        dinoRarityToSuccessRate[1] = 5000;
        dinoRarityToSuccessRate[2] = 3400;
        dinoRarityToSuccessRate[3] = 2000;
        dinoRarityToSuccessRate[4] = 1250;
    }

    modifier onlyFusionLabContract() {
        require(
            msg.sender == fusionLabContract,
            "Only fusion lab contract can call this function"
        );
        _;
    }

    function setFusionLabContract(address _fusionLabContract)
        external
        onlyOwner
    {
        fusionLabContract = _fusionLabContract;
    }

    function setClassRandRates(uint256[] memory _classRandRates)
        external
        onlyOwner
    {
        require(_classRandRates.length == 5, "Class rand rates must be 5");
        classRandRates = _classRandRates;
    }

    function setDinoRarityToSuccessRate(
        uint256 _dinoRarity,
        uint256 _successRate
    ) external onlyOwner {
        dinoRarityToSuccessRate[_dinoRarity] = _successRate;
    }

    function calculateFusionGenes(
        uint256 _dinoRarity,
        uint256 _dino1Id,
        uint256 _dino1BornAt,
        uint256 _dino2Id,
        uint256 _dino2BornAt
    )
        external
        view
        onlyFusionLabContract
        returns (bool _isSuccess, uint256 _dinoGenes)
    {
        uint256 rand = ((uint256(
            keccak256(abi.encodePacked(_dino1BornAt, _dino2Id))
        ) + _dino1Id) % 10000) + 1;
        uint256 rand2 = (uint256(blockhash(block.number - 1)) % 10000) + 1;
        uint256 newDinoClass;
        for (uint256 i = 0; i < classRandRates.length; i++) {
            if (rand <= classRandRates[i]) {
                newDinoClass = dinoClasses[i];
                break;
            }
        }
        uint256 successRate = dinoRarityToSuccessRate[_dinoRarity];
        bool isSuccess = rand2 < successRate;
        uint256 dinoGenes = (newDinoClass + 10) *
            100 +
            (10 + (_dinoRarity + 1));
        if (isSuccess) {
            return (true, dinoGenes);
        }
        return (false, 0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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