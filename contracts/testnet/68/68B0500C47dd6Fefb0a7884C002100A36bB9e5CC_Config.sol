// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./../utils/Caller.sol";
import "./IConfig.sol";

contract Config is IConfig, Ownable {
    /*
    10001:getMintBoxNFT 铸造的BoxToken NFT托管地址，必须是普通地址，必须非0地址，非法要报错
    10002:getBurn 燃烧地址，必须是普通地址，防止ERC721等某些币的特殊支持燃烧机制，必须非0地址，非法要报错
    10003:getApproveProxy 资产授权合约，必须非0地址，非法要报错
    10004:getList 白名单合约，必须非0地址，非法要报错
    10005:getAsset 用户资产托管合约，必须非0地址，非法要报错
    10006:getNFTCreator NFT默认平台创作者，必须是普通地址，必须非0地址，非法要报错
    10007:getBoxSaleFee 盲盒售卖费地址，必须是普通地址，必须非0地址，非法要报错
    10008:getNFTComposeFee NFT合成费地址，必须是普通地址，必须非0地址，非法要报错
    10009:platformFee NFT交易市场-平台费地址(必须是普通地址，必须非0地址)
    */
    mapping(uint256 => address) private uint2562Address;

    /*
    20000:platformFeeRate NFT交易市场-平台费率(0<= x < 100)
    20001:creatorFeeRate NFT交易市场-创作者费率(0<= x < 100)
    */
    mapping(uint256 => uint256) private uint2562Uint256;

    mapping(address => address) private address2Address;

    mapping(address => uint256) private address2Uint256;

    // 资产授权合约，必须非0地址，非法要报错
    function getApproveProxy() external view override returns (IApproveProxy) {
        address address_ = uint2562Address[10003];
        require(address(0) != address_, "1134");
        return IApproveProxy(address_);
    }

    function setApproveProxy(address approveProxy) external onlyOwner {
        require(address(0) != approveProxy, "1135");
        uint2562Address[10003] = approveProxy;
    }

    // 铸造的BoxToken NFT托管地址，必须是普通地址，必须非0地址，非法要报错
    function getMintBoxNFT() external view override returns (address) {
        address address_ = uint2562Address[10001];
        require(address(0) != address_, "1136");
        return address_;
    }

    function setMintBoxNFT(address mintBoxNFT) external onlyOwner {
        require(address(0) != mintBoxNFT, "1137");
        uint2562Address[10001] = mintBoxNFT;
    }

    // 燃烧地址，必须是普通地址，防止ERC721等某些币的特殊支持燃烧机制，必须非0地址，非法要报错
    function getBurn() external view override returns (address) {
        address address_ = uint2562Address[10002];
        require(address(0) != address_, "1138");
        return address_;
    }

    function setBurn(address burnAddress) external onlyOwner {
        require(address(0) != burnAddress, "1139");
        uint2562Address[10002] = burnAddress;
    }

    // 白名单合约，必须非0地址，非法要报错
    function getList() external view override returns (IList) {
        address address_ = uint2562Address[10004];
        require(address(0) != address_, "1140");
        return IList(address_);
    }

    function setList(address list) external onlyOwner {
        require(address(0) != list, "1141");
        uint2562Address[10004] = list;
    }

    // 用户资产托管合约，必须非0地址，非法要报错
    function getAsset() external view override returns (IAsset) {
        address address_ = uint2562Address[10005];
        require(address(0) != address_, "1142");
        return IAsset(address_);
    }

    function setAsset(address asset) external onlyOwner {
        require(address(0) != asset, "1143");
        uint2562Address[10005] = asset;
    }

    // NFT默认平台创作者，必须是普通地址，必须非0地址，非法要报错
    function getNFTCreator() external view override returns (address) {
        address address_ = uint2562Address[10006];
        require(address(0) != address_, "1144");
        return address_;
    }

    function setNFTCreator(address creator) external onlyOwner {
        require(address(0) != creator, "1145");
        uint2562Address[10006] = creator;
    }

    // 盲盒售卖费地址，必须是普通地址，必须非0地址，非法要报错
    function getBoxSaleFee() external view override returns (address) {
        address address_ = uint2562Address[10007];
        require(address(0) != address_, "1146");
        return address_;
    }

    function setBoxSaleFee(address boxSaleFee) external onlyOwner {
        require(address(0) != boxSaleFee, "1147");
        uint2562Address[10007] = boxSaleFee;
    }

    // NFT合成费地址，必须是普通地址，必须非0地址，非法要报错
    function getNFTComposeFee() external view override returns (address) {
        address address_ = uint2562Address[10008];
        require(address(0) != address_, "1148");
        return address_;
    }

    function setNFTComposeFee(address composeFee) external onlyOwner {
        require(address(0) != composeFee, "1149");
        uint2562Address[10008] = composeFee;
    }

    // NFT交易市场-平台费地址(必须是普通地址，必须非0地址)、平台费率(0<= x < 100)、创作者费率(0<= x < 100)，非法要报错
    function getNFTTradePlatformFeeAndPlatformFeeRateAndCreatorFeeRate()
        external
        view
        override
        returns (
            uint256,
            address,
            uint256
        )
    {
        uint256 platformFeeRate = uint2562Uint256[20000];
        address platformAddress = uint2562Address[10009];
        uint256 creatorFeeRate = uint2562Uint256[20001];
        require(address(0) != platformAddress, "1150");
        require(100 > platformFeeRate && 0 <= platformFeeRate, "1151");
        require(100 > creatorFeeRate && 0 <= creatorFeeRate, "1152");
        return (platformFeeRate, platformAddress, creatorFeeRate);
    }

    function setNFTTradePlatformFeeAndPlatformFeeRateAndCreatorFeeRate(
        uint256 platformFeeRate,
        address platformAddress,
        uint256 creatorFeeRate
    ) external onlyOwner {
        require(address(0) != platformAddress, "1153");
        require(100 > platformFeeRate && 0 <= platformFeeRate, "1154");
        require(100 > creatorFeeRate && 0 <= creatorFeeRate, "1155");
        uint2562Uint256[20000] = platformFeeRate;
        uint2562Address[10009] = platformAddress;
        uint2562Uint256[20001] = creatorFeeRate;
    }

    function getAddressByUint256(uint256 key)
        external
        view
        override
        returns (address)
    {
        return uint2562Address[key];
    }

    function setAddressByUint256(uint256 key, address value)
        external
        onlyOwner
    {
        uint2562Address[key] = value;
    }

    function getUint256ByUint256(uint256 key)
        external
        view
        override
        returns (uint256)
    {
        return uint2562Uint256[key];
    }

    function setUint256ByUint256(uint256 key, uint256 value)
        external
        onlyOwner
    {
        uint2562Uint256[key] = value;
    }

    function getAddressByAddress(address key)
        external
        view
        override
        returns (address)
    {
        return address2Address[key];
    }

    function setAddressByAddress(address key, address value)
        external
        onlyOwner
    {
        address2Address[key] = value;
    }

    function getUint256ByAddress(address key)
        external
        view
        override
        returns (uint256)
    {
        return address2Uint256[key];
    }

    function setUint256ByAddress(address key, uint256 value)
        external
        onlyOwner
    {
        address2Uint256[key] = value;
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

pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";

// 调用者
contract Caller is Ownable {
    bool private init;
    mapping(address => bool) public caller;

    modifier onlyCaller() {
        require(caller[msg.sender], "1049");
        _;
    }

    function initOwner(address owner, address caller_) external {
        require(address(0) == Ownable.owner() && !init, "1102");
        init = true;
        _transferOwnership(owner);
        caller[caller_] = true;
    }

    function setCaller(address account, bool state) external onlyOwner {
        if (state) {
            caller[account] = state;
        } else {
            delete caller[account];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./../proxy/IApproveProxy.sol";
import "./../list/IList.sol";
import "./../asset/IAsset.sol";

// TODO 子恒
// 实现Config.sol
interface IConfig {
    // 资产授权合约，必须非0地址，非法要报错
    function getApproveProxy() external view returns (IApproveProxy);

    // 铸造的BoxToken NFT托管地址，必须是普通地址，必须非0地址，非法要报错
    function getMintBoxNFT() external view returns (address);

    // 燃烧地址，必须是普通地址，防止ERC721等某些币的特殊支持燃烧机制，必须非0地址，非法要报错
    function getBurn() external view returns (address);

    // 白名单合约，必须非0地址，非法要报错
    function getList() external view returns (IList);

    // 用户资产托管合约，必须非0地址，非法要报错
    function getAsset() external view returns (IAsset);

    // NFT默认平台创作者，必须是普通地址，必须非0地址，非法要报错
    function getNFTCreator() external view returns (address);

    // 盲盒售卖费地址，必须是普通地址，必须非0地址，非法要报错
    function getBoxSaleFee() external view returns (address);

    // NFT合成费地址，必须是普通地址，必须非0地址，非法要报错
    function getNFTComposeFee() external view returns (address);

    // NFT交易市场-平台费地址(必须是普通地址，必须非0地址)、平台费率(0<= x < 100)、创作者费率(0<= x < 100)，非法要报错
    function getNFTTradePlatformFeeAndPlatformFeeRateAndCreatorFeeRate()
        external
        view
        returns (
            uint256,
            address,
            uint256
        );

    function getAddressByAddress(address key) external view returns (address);

    function getUint256ByAddress(address key) external view returns (uint256);

    function getAddressByUint256(uint256 key) external view returns (address);

    function getUint256ByUint256(uint256 key) external view returns (uint256);
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

pragma solidity 0.8.1;

// 用户授权
// 因为有的合约未实现销毁接口，故不在这里实现代理销毁
interface IApproveProxy {
    function transferFromERC20(
        address token,
        address from,
        address to,
        uint256 amount
    ) external;

    function transferFromERC721(
        address token,
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IList {
    function getStateV1(address account) external view returns (bool);

    function getStateV2(uint16 id, address account)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IAsset {
    function claimMainOrERC20(
        address token,
        address to,
        uint256 amount
    ) external;

    function claimERC721(
        address token,
        address to,
        uint256 tokenId
    ) external;
}