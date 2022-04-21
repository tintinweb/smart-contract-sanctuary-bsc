// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./IConfig.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Config is IConfig, Ownable {
    //普通场配置
    address[] private normalTicketTokens; //普通场门票费用token
    mapping(address => uint256) private normalTicketTokenFee; //普通场门票费用token

    // TODO
    //优惠后普通场门票费用

    //高级场配置
    address[] private seniorTicketTokens; //高级场门票费用token
    mapping(address => uint256) private seniorTicketTokenFee; //高级场门票费用token

    // TODO
    // 优惠高级场门票费用

    /*
    10000:
    10001:
    10002:
    10003:
    10004:
    10005:
    10006:
    10007:
    */
    mapping(address => address) private address2Address;

    /*
    20000:normalManagerFeeAddress 普通场平台管理费收取地址
    20001:normalSuperPrizeFeeAddress 普通场注入超级奖池费收取地址
    20002:normalPrizePoolAddress 普通场奖池地址
    20003:normalBurnAddress 普通场门票NFT的回收地址
    20004:seniorManagerFeeAddress 高级场平台管理费收取地址
    20005:seniorSuperPrizeFeeAddress 高级场注入超级奖池费收取地址
    20006:seniorPrizePoolAddress 高级场奖池地址
    20007:seniorBurnAddress 高级场门票NFT的回收地址
    */
    mapping(uint256 => address) private uint2562Address;

    /*
    30000:
    30001:
    30002:
    30003:
    30004:
    30005:
    30006:
    30007:
    */
    mapping(address => uint256) private address2Uint256;

    /*
    40000:normalManagerFeeRate 普通场平台管理费率
    40001:normalSuperPrizeFeeRate 普通场注入超级奖池费率
    40002:seniorManagerFeeRate 高级场平台管理费率
    40003:seniorSuperPrizeFeeRate 高级场注入超级奖池费率
    40004:
    40005:
    40006:
    40007:
    */
    mapping(uint256 => uint256) private uint2562Uint256;

    IList private list;
    INormalTicket private normalTicket;
    ISeniorTicket private seniorTicket;

    constructor() {
        uint2562Address[20000] = 0x07346765D6063180dc2a09B1774E3Cd34cA38CC3;
        uint2562Address[20001] = 0x25735337fE8cd56CD91944F2Ef8aC65c5Cf68426;
        uint2562Address[20002] = 0x9C92cC086D594743B0b9f99298Aeae572EE46579;
        uint2562Address[20003] = 0xf4e1D63fCf3064B56734969F22665b862522E3a4;

        uint2562Address[20004] = 0xC230a0138DAaA6767b60e6A49EeC72961723247b;
        uint2562Address[20005] = 0xdEdf84264e49Dc29B48cd2AC98346839c42281bD;
        uint2562Address[20006] = 0x8287a8B464F3DF103160d51E41A65469b076a6E8;
        uint2562Address[20007] = 0xF7f034a96C4D982aeC0a753eC735825d00fd748b;

        uint2562Uint256[40000] = 10;
        uint2562Uint256[40001] = 10;

        uint2562Uint256[40002] = 10;
        uint2562Uint256[40003] = 0;
    }

    function getNormalTicketFee(address token)
        external
        view
        override
        returns (uint256)
    {
        uint256 fee = normalTicketTokenFee[token];
        require(0 < fee, "unsupported token");
        return fee;
    }

    function getNormalTicketFees()
        external
        view
        override
        returns (address[] memory, uint256[] memory)
    {
        uint256 length = normalTicketTokens.length;
        uint256[] memory amount = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amount[i] = normalTicketTokenFee[normalTicketTokens[i]];
        }
        return (normalTicketTokens, amount);
    }

    function getNormalManagerFeeRate()
        external
        view
        override
        returns (uint256)
    {
        return uint2562Uint256[40000];
    }

    function getNormalSuperPrizeFeeRate()
        external
        view
        override
        returns (uint256)
    {
        return uint2562Uint256[40001];
    }

    function getNormalManagerFeeAddress()
        external
        view
        override
        returns (address)
    {
        return uint2562Address[20000];
    }

    function getNormalSuperPrizeFeeAddress()
        external
        view
        override
        returns (address)
    {
        return uint2562Address[20001];
    }

    function getNormalPrizePoolAddress()
        external
        view
        override
        returns (address)
    {
        return uint2562Address[20002];
    }

    function getNormalBurnAddress() external view override returns (address) {
        return uint2562Address[20003];
    }

    function getSeniorTicketFee(address token)
        external
        view
        override
        returns (uint256)
    {
        uint256 fee = seniorTicketTokenFee[token];
        require(0 < fee, "unsupported token");
        return fee;
    }

    function getSeniorTicketFees()
        external
        view
        override
        returns (address[] memory, uint256[] memory)
    {
        uint256 length = seniorTicketTokens.length;
        uint256[] memory amount = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amount[i] = seniorTicketTokenFee[seniorTicketTokens[i]];
        }
        return (seniorTicketTokens, amount);
    }

    function getSeniorManagerFeeRate()
        external
        view
        override
        returns (uint256)
    {
        return uint2562Uint256[40002];
    }

    function getSeniorSuperPrizeFeeRate()
        external
        view
        override
        returns (uint256)
    {
        return uint2562Uint256[40003];
    }

    function getSeniorManagerFeeAddress()
        external
        view
        override
        returns (address)
    {
        return uint2562Address[20004];
    }

    function getSeniorSuperPrizeFeeAddress()
        external
        view
        override
        returns (address)
    {
        return uint2562Address[20005];
    }

    function getSeniorPrizePoolAddress()
        external
        view
        override
        returns (address)
    {
        return uint2562Address[20006];
    }

    function getSeniorBurnAddress() external view override returns (address) {
        return uint2562Address[20007];
    }

    function setNormalTicketTokenFee(address token, uint256 amount)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < normalTicketTokens.length; i++) {
            if (normalTicketTokens[i] == token) {
                normalTicketTokens[i] = normalTicketTokens[
                    normalTicketTokens.length - 1
                ];
                normalTicketTokens.pop();
                break;
            }
        }
        if (0 == amount) {
            delete normalTicketTokenFee[token];
        } else {
            normalTicketTokenFee[token] = amount;
            normalTicketTokens.push(token);
        }
    }

    function setNormalManagerFeeRate(uint256 normalManagerFeeRate)
        external
        onlyOwner
    {
        require(normalManagerFeeRate <= 100, "param is out of range");
        uint2562Uint256[40000] = normalManagerFeeRate;
    }

    function setNormalSuperPrizeFeeRate(uint256 normalSuperPrizeFeeRate)
        external
        onlyOwner
    {
        require(normalSuperPrizeFeeRate <= 100, "param is out of range");
        uint2562Uint256[40001] = normalSuperPrizeFeeRate;
    }

    function setNormalManagerFeeAddress(address normalManagerFeeAddress)
        external
        onlyOwner
    {
        require(address(0) != normalManagerFeeAddress, "address cannot be 0");
        uint2562Address[20000] = normalManagerFeeAddress;
    }

    function setNormalSuperPrizeFeeAddress(address normalSuperPrizeFeeAddress)
        external
        onlyOwner
    {
        require(
            address(0) != normalSuperPrizeFeeAddress,
            "address cannot be 0"
        );
        uint2562Address[20001] = normalSuperPrizeFeeAddress;
    }

    function setNormalPrizePoolAddress(address normalPrizePoolAddress)
        external
        onlyOwner
    {
        require(address(0) != normalPrizePoolAddress, "address cannot be 0");
        uint2562Address[20002] = normalPrizePoolAddress;
    }

    function setNormalBurnAddress(address normalBurnAddress)
        external
        onlyOwner
    {
        require(address(0) != normalBurnAddress, "address cannot be 0");
        uint2562Address[20003] = normalBurnAddress;
    }

    function setSeniorTicketTokenFee(address token, uint256 amount)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < seniorTicketTokens.length; i++) {
            if (seniorTicketTokens[i] == token) {
                seniorTicketTokens[i] = seniorTicketTokens[
                    seniorTicketTokens.length - 1
                ];
                seniorTicketTokens.pop();
                break;
            }
        }
        if (0 == amount) {
            delete seniorTicketTokenFee[token];
        } else {
            seniorTicketTokenFee[token] = amount;
            seniorTicketTokens.push(token);
        }
    }

    function setSeniorManagerFeeRate(uint256 seniorManagerFeeRate)
        external
        onlyOwner
    {
        require(seniorManagerFeeRate <= 100, "param is out of range");
        uint2562Uint256[40002] = seniorManagerFeeRate;
    }

    function setSeniorSuperPrizeFeeRate(uint256 seniorSuperPrizeFeeRate)
        external
        onlyOwner
    {
        require(seniorSuperPrizeFeeRate <= 100, "param is out of range");
        uint2562Uint256[40003] = seniorSuperPrizeFeeRate;
    }

    function setSeniorManagerFeeAddress(address seniorManagerFeeAddress)
        external
        onlyOwner
    {
        require(address(0) != seniorManagerFeeAddress, "address cannot be 0");
        uint2562Address[20004] = seniorManagerFeeAddress;
    }

    function setSeniorSuperPrizeFeeAddress(address seniorSuperPrizeFeeAddress)
        external
        onlyOwner
    {
        require(
            address(0) != seniorSuperPrizeFeeAddress,
            "address cannot be 0"
        );
        uint2562Address[20005] = seniorSuperPrizeFeeAddress;
    }

    function setSeniorPrizePoolAddress(address seniorPrizePoolAddress)
        external
        onlyOwner
    {
        require(address(0) != seniorPrizePoolAddress, "address cannot be 0");
        uint2562Address[20006] = seniorPrizePoolAddress;
    }

    function setSeniorBurnAddress(address seniorBurnAddress)
        external
        onlyOwner
    {
        require(address(0) != seniorBurnAddress, "address cannot be 0");
        uint2562Address[20007] = seniorBurnAddress;
    }

    function getAddressByAddress(address key)
        external
        view
        override
        returns (address)
    {
        return address2Address[key];
    }

    function getUint256ByAddress(address key)
        external
        view
        override
        returns (uint256)
    {
        return address2Uint256[key];
    }

    function getAddressByUint256(uint256 key)
        external
        view
        override
        returns (address)
    {
        return uint2562Address[key];
    }

    function getUint256ByUint256(uint256 key)
        external
        view
        override
        returns (uint256)
    {
        return uint2562Uint256[key];
    }

    function setAddressByAddress(address key, address value)
        external
        onlyOwner
    {
        address2Address[key] = value;
    }

    function setUint256ByAddress(uint256 key, address value)
        external
        onlyOwner
    {
        uint2562Address[key] = value;
    }

    function setAddressByUint256(address key, uint256 value)
        external
        onlyOwner
    {
        address2Uint256[key] = value;
    }

    function setUint256ByUint256(uint256 key, uint256 value)
        external
        onlyOwner
    {
        uint2562Uint256[key] = value;
    }

    function setList(IList list_) external onlyOwner {
        list = list_;
    }

    function getList() external view override returns (IList) {
        return list;
    }

    function setNormalTicket(INormalTicket normalTicket_) external onlyOwner {
        normalTicket = normalTicket_;
    }

    function getNormalTicket() external view override returns (INormalTicket) {
        return normalTicket;
    }

    function setSeniorTicket(ISeniorTicket seniorTicket_) external onlyOwner {
        seniorTicket = seniorTicket_;
    }

    function getSeniorTicket() external view override returns (ISeniorTicket) {
        return seniorTicket;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./../list/IList.sol";
import "./../ticket/INormalTicket.sol";
import "./../ticket/ISeniorTicket.sol";

interface IConfig {
    function getNormalTicketFee(address token) external view returns (uint256);

    function getNormalTicketFees()
        external
        view
        returns (address[] memory, uint256[] memory);

    function getNormalManagerFeeRate() external view returns (uint256);

    function getNormalSuperPrizeFeeRate() external view returns (uint256);

    function getNormalManagerFeeAddress() external view returns (address);

    function getNormalSuperPrizeFeeAddress() external view returns (address);

    function getNormalPrizePoolAddress() external view returns (address);

    function getNormalBurnAddress() external view returns (address);

    function getSeniorTicketFee(address token) external view returns (uint256);

    function getSeniorTicketFees()
        external
        view
        returns (address[] memory, uint256[] memory);

    function getSeniorManagerFeeRate() external view returns (uint256);

    function getSeniorSuperPrizeFeeRate() external view returns (uint256);

    function getSeniorManagerFeeAddress() external view returns (address);

    function getSeniorSuperPrizeFeeAddress() external view returns (address);

    function getSeniorPrizePoolAddress() external view returns (address);

    function getSeniorBurnAddress() external view returns (address);

    function getAddressByAddress(address key) external view returns (address);

    function getUint256ByAddress(address key) external view returns (uint256);

    function getAddressByUint256(uint256 key) external view returns (address);

    function getUint256ByUint256(uint256 key) external view returns (uint256);

    function getList() external view returns (IList);

    function getNormalTicket() external view returns (INormalTicket);

    function getSeniorTicket() external view returns (ISeniorTicket);
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

interface IList {
    function getStateV1(address account) external view returns (bool);

    function getStateV2(uint16 id, address account)
        external
        view
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INormalTicket is IERC721 {
    struct MintInfo {
        uint256 id;
        address token;
        uint256 managerFee; //平台管理费
        uint256 superPrizeFee; //超级奖池费
        uint256 prizePoolFee; //普通奖池费
    }

    //   获取NFT铸造信息
    function tryGetNFTInfo(uint256 id)
        external
        view
        returns (bool, MintInfo memory);

    // 设置已使用
    function setUse(uint256 tokenId) external;

    // 查询是否使用
    function getUse(uint256 tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface ISeniorTicket {
    struct MintInfo {
        uint256 id;
        address token;
        uint256 managerFee; //平台管理费
        uint256 superPrizeFee; //超级奖池费
        uint256 prizePoolFee; //普通奖池费
    }

    /**
      获取NFT铸造信息
      params uint256 id  nftid
    */
    function tryGetNFTInfo(uint256 id)
        external
        view
        returns (bool, MintInfo memory);

    // 设置已使用
    function setUse(uint256 tokenId) external;

    // 查询是否使用
    function getUse(uint256 tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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