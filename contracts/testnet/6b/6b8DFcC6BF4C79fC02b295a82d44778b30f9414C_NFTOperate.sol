// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./INFT.sol";
import "./../config/IConfig.sol";
import "./../utils/Caller.sol";

contract NFTOperate is Caller {
    IConfig public config;

    constructor(IConfig config_) {
        _setConfig(config_);
    }

    function setConfig(IConfig config_) external onlyOwner {
        _setConfig(config_);
    }

    function _setConfig(IConfig config_) private {
        config = config_;
    }

    function split(INFT token, uint256 tokenId) external {
        require(token.isSplit(), "1086");
        IApproveProxy approveProxy = config.getApproveProxy();
        approveProxy.transferFromERC721(
            address(token),
            msg.sender,
            address(0x2076f628c3344eabFB5ce6A520C8af5F9C21F667),
            tokenId
        );
        uint256 k;
        INFT child = token.getChild();
        bytes memory property = token.getProperty(tokenId);
        uint256 property_ = property.length / 4;
        bytes memory property__ = new bytes(4);
        bytes[] memory property___ = new bytes[](1);
        property___[0] = property__;
        for (uint256 i = 0; i < property_; i++) {
            k = i * 4;
            property__[0] = property[k + 0];
            property__[1] = property[k + 1];
            property__[2] = property[k + 2];
            property__[3] = property[k + 3];
            child.batchMintNFT(
                INFTBoxToken(address(0)),
                msg.sender,
                property___
            );
        }
    }

    function compose(INFT token, uint256[] memory tokenId) external {
        uint256 tokenId_;
        INFT parent = token.getParent();
        require(parent.isSplit(), "1099");
        uint256 k;
        uint256 k_;
        bytes[] memory property = new bytes[](tokenId.length);
        IApproveProxy approveProxy = config.getApproveProxy();
        for (uint128 i = 0; i < tokenId.length; i++) {
            tokenId_ = tokenId[i];
            approveProxy.transferFromERC721(
                address(token),
                msg.sender,
                address(0x2076f628c3344eabFB5ce6A520C8af5F9C21F667),
                tokenId_
            );
            property[i] = parent.getProperty(tokenId_);
            k += property[i].length;
        }
        bytes memory property_;
        bytes memory property__ = new bytes(k);
        for (uint128 i = 0; i < property.length; i++) {
            property_ = property[i];
            for (uint256 j = 0; j < property_.length; j++) {
                property__[k_] = property_[j];
                k_ += 1;
            }
        }
        bytes[] memory property___ = new bytes[](1);
        property___[0] = property__;
        parent.batchMintNFT(INFTBoxToken(address(0)), msg.sender, property___);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./INFTBoxToken.sol";

interface INFT {
    function batchMintNFT(
        INFTBoxToken token, //盲盒代币
        address to, //NFT
        bytes[] memory propertyScore
    ) external;

    // function mintNFT(
    //     INFTBoxToken token, //盲盒代币
    //     address to, //NFT
    //     bytes memory propertyScore
    // ) external;

    function burn(uint256 tokenId) external;

    function isSplit() external view returns (bool);

    function getParent() external view returns (INFT);

    function getChild() external view returns (INFT);

    function getMaxId() external view returns (uint256);

    function getProperty(uint256 tokenId) external view returns (bytes memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

import "./../proxy/IApproveProxy.sol";

interface IConfig {
    function getPlatformAddresss() external view returns (address);

    function getWhitePlatformList(address token) external view returns (bool);

    function getMintAddress() external view returns (address);

    function getPlatformFeeRate() external view returns (uint256);

    function getApproveProxy() external view returns (IApproveProxy);

    function getSellMaxCount() external view returns (uint256);
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

    function initOwner(address owner) external {
        require(!init, "1102");
        init = true;
        _transferOwnership(owner);
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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface INFTBoxToken is IERC20 {
    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

pragma solidity 0.8.1;

// 用户授权
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