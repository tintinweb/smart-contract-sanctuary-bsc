/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin\contracts\utils\Strings.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// File: @openzeppelin\contracts\utils\Context.sol


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

// File: @openzeppelin\contracts\access\Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: src\DAOLogic.sol


pragma solidity >=0.8.0 <0.9.0;
//只有一个逻辑就行publish逻辑，可以设置当前发行数量，进行扣钱和调用nft生成，
interface Token {
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;
}

interface Nft {
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function logicMint(address to) external returns (uint256);
}

contract DaoLogic is Ownable {
    constructor() {}

    struct PublishParams {
        address nftContract; // NFT合约地址
        address tokenContract; // USDT合约地址
        address buyer; // 买家地址,,nft将向这个地址转入或者铸造给他
        address owner; // NFT卖家地址,就是收钱钱包地址
        uint256 price; // 卖价
        string publishId; // 订单id; 如果服务器有对应订单的话，在dao的无数据库情况下，是直接填0即可
        uint256 deadline; // 有效期，此时间戳之前有效
    }

    event publishedAsset(
        address buyer,
        address owner,
        uint256 price,
        uint256 itemId,
        string publishId
    );
    /*
     * 加密钱包地址
     */
    address ENCODE_ADDRESS;
    /*
     *当前公开销售的库存，和DAONFT的maxsupply区别是，maxsupply是NFT的发行总量，当supplycount生成为0就表示停售了，
     */
    uint256 supplyCount;

    /*
     * 增加销售库存
     */
    function addSupplyCount(uint256 count) public onlyOwner returns (uint256) {
        supplyCount = supplyCount + count;
        return supplyCount;
    }

    /*
     *获得库存数量
     */
    function getSupplyCount() public view returns (uint256) {
        return supplyCount;
    }

    /*
     * 设置加密钱包地址
     */
    function setEncodeAddress(address encodeAddress) public onlyOwner {
        ENCODE_ADDRESS = encodeAddress;
    }

    /*
     * 查看地址
     */
    function getEncodeAddress() public view returns (address) {
        return ENCODE_ADDRESS;
    }

    /*
     *  测试地址是不是加密地址
     */
    function isCanEncode(address encodeAddress) public view returns (bool) {
        return encodeAddress == ENCODE_ADDRESS;
    }

    // 验证签名
    function verify(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        address addr = ecrecover(hash, v, r, s);
        return addr;
    }

    // address转字符串
    function toHexString(address addr) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(addr)), 20);
    }

    /*
     * 公售调用函数，用户web3在和服务器获得签名后，调用这个函数完成
     * 服务器如果要监控结果，可以通过监听合约事件publishedAsset完成
     */
    function publishAsset(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        PublishParams memory inputParams
    ) public {
        //检测库存
        require(supplyCount > 0, "Nft Sold Out");
        // 检测参数,用参数名的ascii序列组成字符串
        string memory message = string(
            abi.encodePacked(
                "buyer=",
                toHexString(inputParams.buyer),
                "&contract=",
                toHexString(inputParams.nftContract),
                "&deadline=",
                Strings.toString(inputParams.deadline),
                "&owner=",
                toHexString(inputParams.owner),
                "&price=",
                Strings.toString(inputParams.price),
                "&publishId=",
                inputParams.publishId,
                "&tokenContract=",
                toHexString(inputParams.tokenContract)
            )
        );
        bytes memory messageBytes = abi.encodePacked(
            "\x19Ethereum Signed Message:\n",
            Strings.toString(bytes(message).length),
            message
        );
        require(
            hash == keccak256(messageBytes),
            "inconsistent parameter hash values"
        );

        // 交易发起方必须是买家
        require(
            msg.sender == inputParams.buyer,
            "the transaction originator must be the buyer"
        );

        // 检测时间有效性
        require(block.timestamp < inputParams.deadline, "transaction expired");

        // 检测是否是管理员的签名
        address encodeAddr = verify(hash, v, r, s);
        require(encodeAddr == ENCODE_ADDRESS, "insufficient permissions");

        // 初始化合约
        Token token = Token(inputParams.tokenContract);
        Nft nft = Nft(inputParams.nftContract);

        // 检测买家余额
        uint256 buyerBalance = token.allowance(msg.sender, address(this));
        require(buyerBalance >= inputParams.price, "insufficient balance");

        // // 检测卖家是否持有nft
        // require(
        //     nft.ownerOf(inputParams.itemId) == inputParams.owner,
        //     "nft does not exist"
        // );
        uint256 itemId = nft.logicMint(inputParams.buyer);
        // 将usdt转给卖家
        token.transferFrom(msg.sender, inputParams.owner, inputParams.price);

        // 将NFT转给买家
        //  nft.transferFrom(inputParams.owner, msg.sender, inputParams.itemId);
        supplyCount = supplyCount - 1;
        // 触发事件
        emit publishedAsset(
            msg.sender,
            inputParams.owner,
            inputParams.price,
            itemId,
            inputParams.publishId
        );
    }
}