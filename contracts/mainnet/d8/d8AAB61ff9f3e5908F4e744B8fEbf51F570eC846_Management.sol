// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IManagement.sol";
import "./interfaces/IRandomService.sol";

contract Management is IManagement, Ownable {
    // Address of Treasury that receives fee and payments
    address public treasury;

    // Address of Verifier to verify signatures
    address public verifier;

    // Address that has an authority to mint MicrophoneNFT and ruby
    address public minter;

    // Address of microphoneNFT contract
    address public microphoneNFT;

    // Address of lootBox contract
    address public lootBox;

    // Address of breeding contract
    address public breeding;

    // Address of ruby contract
    address public ruby;

    // BUSD token address
    address public busd;

    // A map list of used signatures - keccak256(signature) => bytes32
    mapping(bytes32 => bool) public prevSigns;

    // Random generator service
    IRegistry public randomService;

    modifier AddressZero(address _addr) {
        require(_addr != address(0), "Set address to zero");
        _;
    }

    constructor(
        address _treasury,
        address _verifier,
        address _minter,
        address _randomService
    ) {
        treasury = _treasury;
        verifier = _verifier;
        minter = _minter;
        randomService = IRegistry(_randomService);
    }

    function admin() external view returns (address) {
        return owner();
    }

    /**
       @notice Change new address of Treasury
       @dev    Caller must be Owner
       @param _newTreasury Address of new Treasury
     */
    function updateTreasury(address _newTreasury)
        external
        AddressZero(_newTreasury)
        onlyOwner
    {
        treasury = _newTreasury;
    }

    /**
       @notice Update new address of Verifier
       @dev    Caller must be Owner
       @param _newVerifier Address of new Verifier
     */
    function updateVerifier(address _newVerifier)
        external
        AddressZero(_newVerifier)
        onlyOwner
    {
        verifier = _newVerifier;
    }

    /**
       @notice Change new address of Minter
       @dev    Caller must be Owner
       @param _newMinter Address of new Minter
     */
    function updateMinter(address _newMinter)
        external
        AddressZero(_newMinter)
        onlyOwner
    {
        minter = _newMinter;
    }

    /**
        @notice Update new random service
        @dev    Caller must be Owner
        @param  _newService    Address of new random service
     */
    function updateRandomService(address _newService)
        external
        AddressZero(_newService)
        onlyOwner
    {
        randomService = IRegistry(_newService);
    }

    /**
       @notice Update new address of NFT
       @dev    Caller must be Owner
       @param _microNFT Address of new NFT
     */
    function updateMicroNFT(address _microNFT)
        external
        AddressZero(_microNFT)
        onlyOwner
    {
        microphoneNFT = _microNFT;
    }

    /**
       @notice Update new address of loot box
       @dev    Caller must be Owner
       @param _lootBox Address of new loot box
     */
    function updateLootBox(address _lootBox)
        external
        AddressZero(_lootBox)
        onlyOwner
    {
        lootBox = _lootBox;
    }

    /**
       @notice Update new address of breeding contract
       @dev    Caller must be Owner
       @param _breeding Address of breeding contract
     */
    function updateBreeding(address _breeding)
        external
        AddressZero(_breeding)
        onlyOwner
    {
        breeding = _breeding;
    }

    /**
       @notice Update new address of ruby contract
       @dev    Caller must be Owner
       @param _ruby Address of ruby contract
     */
    function updateRuby(address _ruby) external onlyOwner {
        ruby = _ruby;
    }

    /**
       @notice Update new address of BUSD contract
       @dev    Caller must be Owner
       @param _busd Address of BUSD contract
     */
    function updateBUSD(address _busd) external AddressZero(_busd) onlyOwner {
        busd = _busd;
    }

    /**
        @notice Generate random number from Verichains random service
        @dev    Caller must be Lootbox/Breeding contract
     */
    function getRandom() external returns (uint256) {
        address msgSender = _msgSender();
        require(
            msgSender == lootBox || msgSender == breeding,
            "Unauthorized: Lootbox or Breeding contract only"
        );
        uint256 key = 0xc9821440a2c2cc97acac89148ac13927dead00238693487a9c84dfe89e28a284;
        return randomService.randomService(key).random();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IManagement {
    function admin() external returns (address);

    function treasury() external returns (address);

    function verifier() external returns (address);

    function minter() external returns (address);

    function microphoneNFT() external returns (address);

    function lootBox() external returns (address);

    function breeding() external returns (address);

    function ruby() external returns (address);

    function busd() external returns (address);

    function prevSigns(bytes32) external returns (bool);

    function updateTreasury(address _newTreasury) external;

    function updateVerifier(address _newVerifier) external;

    function updateMinter(address _newMinter) external;

    function updateRandomService(address _newService) external;

    function updateMicroNFT(address _microNFT) external;

    function updateLootBox(address _lootBox) external;

    function updateBreeding(address _breeding) external;

    function updateRuby(address _ruby) external;

    function updateBUSD(address _busd) external;

    function getRandom() external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRegistry {
    function randomService(uint256 key) external returns (IRandomService);
}

interface IRandomService {
    function random() external returns (uint256);
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