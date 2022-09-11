/**
 *Submitted for verification at BscScan.com on 2022-09-10
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

// File: src\interface.sol



pragma solidity >=0.8.0 <0.9.0;

//只有一个逻辑就行publish逻辑，可以设置当前发行数量，进行扣钱和调用nft生成，
interface IConfig {
    function tokenAddress() external view returns (address);

    function finAddress() external view returns (address);

    function minerAddress() external view returns (address);

    function nftFozenTime() external view returns (uint256);

    function minerLogicAddress() external view returns (address);

    function finLogicAddress() external view returns (address);

    function encodeAddress() external view returns (address);

    function daoAddress() external view returns (address);
}

interface IToken {
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

    function transfer(address to, uint256 amount) external returns (bool);
}

interface INft {
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IMinerNft is INft {
    function cutPower(uint256 tokenId, uint256 cut) external;

    function increasePower(uint256 tokenId, uint256 power) external;

    function totalPower(uint256 tokenId) external view returns (uint256);

    function tokenPower(uint256 tokenId) external view returns (uint256);

    function tokenInterest(uint256 tokenId) external view returns (uint256);

    function tokenEndtime(uint256 tokenId) external view returns (uint256);

    function extendEndtime(uint256 tokenId, uint256 endtime) external;

    function logicMint(
        address to,
        string memory uri,
        uint256 power,
        uint256 interest,
        uint256 endtime
    ) external returns (uint256);
}

interface IFinNft is INft {
    function logicMint(
        address to,
        uint256 power,
        uint256 minerItemId,
        uint256 price,
        string memory uri
    ) external returns (uint256);

    function logicTrans(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function logicBurn(uint256 tokenId) external;

    function tokenPrice(uint256 tokenId) external view returns (uint256);

    function tokenPower(uint256 tokenId) external view returns (uint256);

    function tokenMintTime(uint256 tokenId) external view returns (uint256);

    function tokenFromMiner(uint256 tokenId) external view returns (uint256);

    function tokenSettledProfit(uint256 tokenId)
        external
        view
        returns (uint256);

    function profitSettled(uint256 tokenId, uint256 profit)
        external
        returns (uint256);
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

// File: src\OwnAndAddress.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;
abstract contract OwnAndAddress is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
    modifier onlyAddr(address addr) {
        require(_msgSender() == addr, "caller is not defined address");
        _;
    }
    modifier onlyAddrOrOwner(address addr) {
        require(
            owner() == _msgSender() ||
                (addr != address(0) && _msgSender() == addr),
            "Ownable: caller is not the owner or defined address"
        );

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner ");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: src\base.sol



pragma solidity >=0.8.0 <0.9.0;
//所有基于base的需要setconfig 还要 setdao
contract base is OwnAndAddress {
    address internal CONFIG_CONTRACT = address(0);

    function setConfigAddress(address addr)
        public
        onlyAddrOrOwner(daoAddress())
    {
        CONFIG_CONTRACT = addr;
    }

    function daoAddress() internal view returns (address) {
        if (CONFIG_CONTRACT == address(0)) return address(0);
        return IConfig(CONFIG_CONTRACT).daoAddress();
    }

    //获得逻辑合约地址
    function configAddress() public view returns (address) {
        return CONFIG_CONTRACT;
    }
}

// File: src\MinerLogic.sol


pragma solidity >=0.8.0 <0.9.0;
//功能:铸造minnerNFT，交易minnerNFT,minner延期
contract MinerLogic is base {
    constructor() {}

    //铸造MINNERNFT
    struct MintParams {
        address to;
        string uri;
        uint256 power;
        uint256 endtime;
        uint256 interest;
        uint256 deadline; // 有效期，此时间戳之前有效
        string clientId;
    }
    event MintEvent(
        address to,
        string uri,
        uint256 power,
        uint256 endtime,
        uint256 interest,
        uint256 itemId,
        string clientId
    );
    //生成FINNFT
    struct PowerSellParams {
        uint256 deadline; // 有效期，此时间戳之前有效
        uint256 power;
        uint256 price;
        address seller;
        address buyer;
        uint256 minerNftId;
        string clientId;
    }

    event PowerSellEvent(
        uint256 power,
        uint256 price,
        address seller,
        address buyer,
        uint256 minerNftId,
        uint256 finNftId,
        string clientId
    );
    //续期
    struct MinerExtendTimeParams {
        uint256 minerNftId;
        uint256 endtime;
        uint256 deadline; // 有效期，此时间戳之前有效
        string clientId;
    }

    event MinerExtendTimeEvent(
        uint256 minerNftId,
        uint256 endtime,
        string clientId
    );

    //续期

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
     * 矿工销售自己的MINERNFT 并且分割给用户
     * 逻辑：1.矿工要先把把自己的MINERNFT appove给这个逻辑合约，中心化数据库也记录这个事情，并且挂单(显示在网站上),等待用户去购买
     *       2.普通用户在网站上appove USDT 之类的钱给这个合约，并且发起splitAndSell
     * 这个函数完成：收买家的钱转给旷矿工，把旷工的nft 裁剪出来，并且对应的发行finnft给买家
     */
    function mintMinerNft(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        MintParams memory inputParams
    ) public {
        // 检测参数,用参数名的ascii序列组成字符串
        string memory message = string(
            abi.encodePacked(
                "clientId=",
                inputParams.clientId,
                "&deadline=",
                Strings.toString(inputParams.deadline),
                "&endtime=",
                Strings.toString(inputParams.endtime),
                "&interest=",
                Strings.toString(inputParams.interest),
                "&power=",
                Strings.toString(inputParams.power),
                "&to=",
                toHexString(inputParams.to),
                "&uri=",
                inputParams.uri
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
            msg.sender == inputParams.to,
            "the transaction originator must be the buyer"
        );

        // 检测时间有效性
        require(block.timestamp < inputParams.deadline, "transaction expired");

        // 初始化合约
        IConfig config = IConfig(CONFIG_CONTRACT);
        // 检测是否是管理员的签名
        require(
            verify(hash, v, r, s) == config.encodeAddress(),
            "insufficient permissions"
        );
        IMinerNft miner = IMinerNft(config.minerAddress());

        uint256 itemId = miner.logicMint(
            inputParams.to,
            inputParams.uri,
            inputParams.power,
            inputParams.interest,
            inputParams.endtime
        );

        // 触发事件
        emit MintEvent(
            msg.sender,
            inputParams.uri,
            inputParams.power,
            inputParams.endtime,
            inputParams.interest,
            itemId,
            inputParams.clientId
        );
    }

    function powerSell(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        PowerSellParams memory inputParams
    ) public {
        // 检测参数has
        string memory message = string(
            abi.encodePacked(
                "buyer=",
                toHexString(inputParams.buyer),
                "&clientId=",
                inputParams.clientId,
                "&deadline=",
                Strings.toString(inputParams.deadline),
                "&minerNftId=",
                Strings.toString(inputParams.minerNftId),
                "&power=",
                Strings.toString(inputParams.power),
                "&price=",
                Strings.toString(inputParams.price),
                "&seller=",
                toHexString(inputParams.seller)
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

        IConfig config = IConfig(CONFIG_CONTRACT);
        // 检测是否是管理员的签名
        require(
            verify(hash, v, r, s) == config.encodeAddress(),
            "insufficient permissions"
        );
        // 初始化合约
        IToken token = IToken(config.tokenAddress());
        IFinNft fin = IFinNft(config.finAddress());
        IMinerNft miner = IMinerNft(config.minerAddress());

        // 检测买家余额

        require(
            token.allowance(msg.sender, address(this)) >= inputParams.price,
            "insufficient balance"
        );

        // 检测卖家是否持有nft
        require(
            miner.ownerOf(inputParams.minerNftId) == inputParams.seller,
            "MinerNFT does not exist"
        );
        require(
            miner.tokenPower(inputParams.minerNftId) >= inputParams.power,
            "Power is not enough"
        );
        require(
            miner.tokenEndtime(inputParams.minerNftId) >
                block.timestamp + config.nftFozenTime(),
            "MinerNFT is near end"
        );
        // 将usdt转给卖家
        token.transferFrom(msg.sender, inputParams.seller, inputParams.price);

        // 将NFT转给买家
        miner.cutPower(inputParams.minerNftId, inputParams.power);

        //铸造fin
        uint256 finId = fin.logicMint(
            msg.sender,
            inputParams.power,
            inputParams.minerNftId,
            inputParams.price,
            miner.tokenURI(inputParams.minerNftId)
        );
        // 触发事件
        emit PowerSellEvent(
            inputParams.power,
            inputParams.price,
            inputParams.seller,
            inputParams.buyer,
            inputParams.minerNftId,
            finId,
            inputParams.clientId
        );
    }

    function extendMinerNft(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        MinerExtendTimeParams memory inputParams
    ) public {
        // 检测参数,用参数名的ascii序列组成字符串
        string memory message = string(
            abi.encodePacked(
                "clientId=",
                inputParams.clientId,
                "&deadline=",
                Strings.toString(inputParams.deadline),
                "&endtime=",
                Strings.toString(inputParams.endtime),
                "&minerNftId=",
                Strings.toString(inputParams.minerNftId)
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

        // 检测时间有效性
        require(block.timestamp < inputParams.deadline, "transaction expired");
        IConfig config = IConfig(CONFIG_CONTRACT);
        // 检测是否是管理员的签名
        require(
            verify(hash, v, r, s) == config.encodeAddress(),
            "insufficient permissions"
        );

        // 初始化合约

        IMinerNft miner = IMinerNft(config.minerAddress());
        require(
            msg.sender == miner.ownerOf(inputParams.minerNftId),
            "the transaction originator must be the owner"
        );
        require(
            miner.tokenEndtime(inputParams.minerNftId) < inputParams.endtime,
            "can not extends less than orgin endtime"
        );
        miner.extendEndtime(inputParams.minerNftId, inputParams.endtime);

        // 触发事件
        emit MinerExtendTimeEvent(
            inputParams.minerNftId,
            inputParams.endtime,
            inputParams.clientId
        );
    }
}