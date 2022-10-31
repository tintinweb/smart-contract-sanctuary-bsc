// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SynthesisTokenStorage.sol";


interface IRhinoToken {
    // 1 2
    function burn(address owner, uint256 tokenId) external returns(address, uint256);
    // 3 4 5
    function synthesisMint(address recipient) external returns(address, uint256);
    function synthesis(address _owner, uint256[] memory _tokenId) external returns(bool);

}

interface ILimitedRhinoToken {
    function burn(address owner, uint256[] memory tokenId) external returns(bool);

    function synthesisMint(address recipient, uint256 limitedTime) external returns(address, uint256, uint256);
}

interface IEternalRhinoToken {
    function synthesisMint(address recipient) external returns(address, uint256);
}

interface IRandomNumberGenerator {
    function getRandomNumber(uint256 _seed) external view returns(uint256);
    function importSeedFromThird(address _seed, uint256 modulo) external view returns (uint8);
}

interface ITrading {
    function activity(address nft, uint256 tokenId) external view returns(uint256);
}

contract SynthesisToken is Ownable, SynthesisTokenStorage{

    event Level1And2Merge(address owner, uint256 level1ById0, uint256 level1ById1, uint256 level2ById, uint256 level3ById);
    event Level3MergeRealTime(address owner, uint256 tokenId, uint256 limitedTime);
    event Level4MergeMiddleLevel(address owner, uint256 tokenId, uint256 limitedTime);
    event Level5MergeHighLevel(address owner, uint256 tokenId, uint256 limitedTime);
    event SetRandomGenerator(address oldRandomGenerator, address newRandomGenerator);
    event SetTrading(address oldTrading, address newTrading);

    constructor(address _randomGeneratorAddress){
        randomGenerator = _randomGeneratorAddress;
    }

    function activity_(uint256[] calldata level1Id, uint256 level2Id) internal view{
        for(uint i; i < level1Id.length; i++){
            uint isTrading = ITrading(trading).activity(LEVEL1, level1Id[i]);
            require(isTrading != 1, "NFTs cannot be synthesized in transactions");
        }
        require(ITrading(trading).activity(LEVEL2, level2Id) != 1, "NFTs cannot be synthesized in transactions");
    }

    function nftActivity(address nft, uint256[] calldata tokenId) internal view{
        for(uint i; i < tokenId.length; i++){
            uint isTrading = ITrading(trading).activity(nft, tokenId[i]);
            require(isTrading != 1, "NFTs cannot be synthesized in transactions");
        }
    }

    function setTrading(address newTrading) external onlyOwner {
        require(newTrading != address(0), "Trading cannot be set to zero address");
        address old = trading;
        trading = newTrading;
        emit SetTrading(old, newTrading);
    }

    function setRandomGenerator(address newRandomGenerator) external onlyOwner {
        require(newRandomGenerator != address(0), "Random generator cannot be set to zero address");
        address oldRandomGenerator = randomGenerator;
        randomGenerator = newRandomGenerator;
        emit SetRandomGenerator(oldRandomGenerator, newRandomGenerator);
    }

    function level1And2Merge(uint256[] calldata level1Id, uint256 level2Id) external returns(address, uint256){
        uint256 length = level1Id.length;
        require(length > 0 && length <= 2, "Level 1 Array id is empty");
        require(level2Id > 0, "Level 2 id is empty");
        activity_(level1Id, level2Id);

        for(uint i; i < level1Id.length; i++){
            IRhinoToken(LEVEL1).burn(msg.sender, level1Id[i]);
        }
        IRhinoToken(LEVEL2).burn(msg.sender, level2Id);
        uint8 currentRandomNumber = IRandomNumberGenerator(randomGenerator).importSeedFromThird(msg.sender, 100);
        uint256 newTokenId;
        address recipient;
        if(length == 1){
            if(currentRandomNumber <= 40){
                (recipient, newTokenId) = IRhinoToken(LEVEL3).synthesisMint(msg.sender);
            }
        }
        if(length == 2){
            if(currentRandomNumber <= 80){
                (recipient, newTokenId) = IRhinoToken(LEVEL3).synthesisMint(msg.sender);
            }
        }
        emit Level1And2Merge (recipient, level1Id[0], level1Id[1], currentRandomNumber, newTokenId);
        return (recipient, newTokenId);
    }

    function level1And2TimeLimitMerge(uint256[] calldata level1Id, uint256 level2Id) external returns(address, uint256){
        require(block.timestamp <= timeLimitMerge, "Limited time event not open");
        require(level1Id.length == 2, "Level 1 Not enough cards");
        require(level2Id > 0, "Level 2 id is empty");
        activity_(level1Id, level2Id);
        for(uint i; i < level1Id.length; i++){
            IRhinoToken(LEVEL1).burn(msg.sender, level1Id[i]);
        }
        IRhinoToken(LEVEL2).burn(msg.sender, level2Id);
        (address recipient, uint256 newTokenId) = IRhinoToken(LEVEL3).synthesisMint(msg.sender);
        emit Level1And2Merge (msg.sender, level1Id[0], level1Id[1], level2Id, newTokenId);
        return(recipient, newTokenId);
    }

    function timeLimitMergeOpen(uint256 timeLimit) external onlyOwner returns(uint256){
        timeLimitMerge = block.timestamp + timeLimit;
        return timeLimitMerge;
    }

    function level3Merge(uint256[] calldata level3Id) external returns(address, uint256, uint256){
        require(level3Id.length == 5, "Level 3 Not enough cards");
        require(randomNumberLevel3 < 6600, "Level 3 the maximum number of synthesis has been reached");
        nftActivity(LEVEL3, level3Id);
        uint256 currentRandomNumber = IRandomNumberGenerator(randomGenerator).getRandomNumber(randomNumberLevel3);
        IRhinoToken(LEVEL3).synthesis(msg.sender, level3Id);
        // 3960,3960-6270,6270-6600
        uint256 newTokenId;
        uint256 limitedTime;
        if(currentRandomNumber <= 3960){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(realTime).synthesisMint(msg.sender, 100);
        } else if(currentRandomNumber > 3960 && currentRandomNumber <= 6270){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(realTime).synthesisMint(msg.sender, 200);
        } else if(currentRandomNumber > 6270 && currentRandomNumber <= 6600){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(realTime).synthesisMint(msg.sender, 300);
        }
        randomNumberLevel3 += 1;
        emit Level3MergeRealTime (msg.sender, newTokenId, limitedTime);
        return (msg.sender, newTokenId, limitedTime);
    }

    function level4Merge(uint256[] calldata level4Id) external returns(address, uint256, uint256){
        require(level4Id.length == 5, "Level 4 Not enough cards");
        require(randomNumberLevel4 < 1000, "Level 4 the maximum number of synthesis has been reached");
        nftActivity(LEVEL4, level4Id);

        uint256 currentRandomNumber = IRandomNumberGenerator(randomGenerator).getRandomNumber(randomNumberLevel4);
        IRhinoToken(LEVEL4).synthesis(msg.sender, level4Id);

        uint256 newTokenId;
        uint256 limitedTime;
        if(currentRandomNumber <= 600){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(middleLevel).synthesisMint(msg.sender, 100);
        } else if(currentRandomNumber > 600 && currentRandomNumber <= 950){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(middleLevel).synthesisMint(msg.sender, 200);
        } else if(currentRandomNumber > 950 && currentRandomNumber <= 1000){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(middleLevel).synthesisMint(msg.sender, 300);
        }
        randomNumberLevel4 += 1;
        emit Level4MergeMiddleLevel(msg.sender, newTokenId, limitedTime);
        return (msg.sender, newTokenId, limitedTime);
    }

    function level5Merge(uint256[] calldata level5Id) external returns(address, uint256, uint256){
        require(level5Id.length == 5, "Level 5 Not enough cards");
        require(randomNumberLevel5 < 400, "Level 5 the maximum number of synthesis has been reached");
        nftActivity(LEVEL5, level5Id);

        uint256 currentRandomNumber = IRandomNumberGenerator(randomGenerator).getRandomNumber(randomNumberLevel5);
        IRhinoToken(LEVEL5).synthesis(msg.sender, level5Id);
        // 240,240-380,380-20
        uint256 newTokenId;
        uint256 limitedTime;
        if(currentRandomNumber <= 240){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(highLevel).synthesisMint(msg.sender, 100);
        } else if(currentRandomNumber > 240 && currentRandomNumber <= 380){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(highLevel).synthesisMint(msg.sender, 200);
        } else if(currentRandomNumber > 380 && currentRandomNumber <= 20){
            (,newTokenId, limitedTime) = ILimitedRhinoToken(highLevel).synthesisMint(msg.sender, 300);
        }
        randomNumberLevel5 += 1;
        emit Level5MergeHighLevel(msg.sender, newTokenId, limitedTime);
        return (msg.sender, newTokenId, limitedTime);
    }

    function realTimeMerge(uint256[] calldata tokenIds) external returns(address, uint256){
        require(tokenIds.length == 6, "real Time Not enough cards");
        nftActivity(realTime, tokenIds);

        bool success = ILimitedRhinoToken(realTime).burn(msg.sender, tokenIds);
        address recipient;
        uint256 newTokenId;
        if (success) (recipient, newTokenId) = IEternalRhinoToken(eternalRealTime).synthesisMint(msg.sender);
        return (recipient, newTokenId);
    }

    function middleLevelMerge(uint256[] calldata tokenIds) external returns(address, uint256){
        require(tokenIds.length == 6, "middle Level Not enough cards");
        nftActivity(middleLevel, tokenIds);

        bool success = ILimitedRhinoToken(middleLevel).burn(msg.sender, tokenIds);
        address recipient;
        uint256 newTokenId;
        if (success) (recipient, newTokenId) = IEternalRhinoToken(eternalMiddleLevel).synthesisMint(msg.sender);
        return (recipient, newTokenId);
    }

    function highLevelMerge(uint256[] calldata tokenIds) external returns(address, uint256){
        require(tokenIds.length == 6, "high Level Not enough cards");
        nftActivity(highLevel, tokenIds);

        bool success = ILimitedRhinoToken(highLevel).burn(msg.sender, tokenIds);
        address recipient;
        uint256 newTokenId;
        if (success) (recipient, newTokenId) = IEternalRhinoToken(eternalHighLevel).synthesisMint(msg.sender);
        return (recipient, newTokenId);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.16;

contract SynthesisTokenStorage {

    address public constant LEVEL1 = 0x1f63F101d93174D3A471687176eDb4fa269946E0;
    address public constant LEVEL2 = 0x03660E43393a4540FE7405EcCBdf492592a4Dbcd;
    address public constant LEVEL3 = 0xADE404B61BD4d7df5fe2561cbCf01BF2F988dC57;
    address public constant LEVEL4 = 0x10Af994327d84d2c40242C14B690fbDB9bD1640B;
    address public constant LEVEL5 = 0x10Fc5871FA832f4E17B28aA956347a181D31e2A6;

    address public constant realTime = 0x9267e2Cc841334bc9d5eAeF09958c67E24abB0B8;
    address public constant eternalRealTime = 0x7DEA2099C0507213A8e8b9C6144974C11A283616;

    address public constant middleLevel = 0x8Da6ecD7AF37313beA5a20dD8Ac0f5e4b4e9F987;
    address public constant eternalMiddleLevel = 0xE3F02cfeb182E6d94E9fE7871941508ACF588ba2;

    address public constant highLevel = 0x2EE0bb3b40137ddEB9b2a25343De4df207010ecd;
    address public constant eternalHighLevel = 0x64a306f46ACF194cCD6EcBfc20b1bbb31c405d60;

    address public randomGenerator;
    address public trading;

    uint256 internal randomNumberLevel3;
    uint256 internal randomNumberLevel4;
    uint256 internal randomNumberLevel5;

    uint256 public timeLimitMerge;
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