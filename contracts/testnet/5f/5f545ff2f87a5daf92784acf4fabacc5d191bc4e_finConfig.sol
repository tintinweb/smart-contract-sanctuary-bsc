/**
 *Submitted for verification at BscScan.com on 2022-11-07
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

// File: src\finConfig.sol


pragma solidity >=0.8.0 <0.9.0;
//利息参数历史
//冻结时间参数等等
//也许可以把token地址，fin合约地址，nft地址等全部放进来
//需要setdao
contract finConfig is OwnAndAddress {
    address _tokenAddress;
    address _finAddress;
    address _minerAddress;
    address _minerLogicAddress;
    address _finLogicAddress;
    address _encodeAddress;
    address _daoAddress = address(0);

    //在设置了dao合约地址后，可以抛弃所有权
    function setDaoAddress(address addr) public onlyAddrOrOwner(_daoAddress) {
        _daoAddress = addr;
    }

    //获得逻辑合约地址
    function daoAddress() public view returns (address) {
        return _daoAddress;
    }

    function setEncodeAddress(address addr)
        public
        onlyAddrOrOwner(_daoAddress)
    {
        _encodeAddress = addr;
    }

    function encodeAddress() public view returns (address) {
        return _encodeAddress;
    }

    function setMinerLogicAddress(address addr)
        public
        onlyAddrOrOwner(_daoAddress)
    {
        _minerLogicAddress = addr;
    }

    function minerLogicAddress() public view returns (address) {
        return _minerLogicAddress;
    }

    function setFinLogicAddress(address addr)
        public
        onlyAddrOrOwner(_daoAddress)
    {
        _finLogicAddress = addr;
    }

    function finLogicAddress() public view returns (address) {
        return _finLogicAddress;
    }

    function setTokenAddress(address addr) public onlyAddrOrOwner(_daoAddress) {
        _tokenAddress = addr;
    }

    function tokenAddress() public view returns (address) {
        return _tokenAddress;
    }

    function setFinAddress(address addr) public onlyAddrOrOwner(_daoAddress) {
        _finAddress = addr;
    }

    function finAddress() public view returns (address) {
        return _finAddress;
    }

    function setMinerAddress(address addr) public onlyAddrOrOwner(_daoAddress) {
        _minerAddress = addr;
    }

    function minerAddress() public view returns (address) {
        return _minerAddress;
    }

    struct InterestLog {
        uint256 time;
        uint256 base;
        uint256 increasePerDay;
        uint256 increaseDays;
    }
    InterestLog[] private _interestLog;

    uint256 _nftFozenTime;

    function setFozenTime(uint256 time) public onlyAddrOrOwner(_daoAddress) {
        _nftFozenTime = time;
    }

    function nftFozenTime() public view returns (uint256) {
        return _nftFozenTime;
    }

    function addInterestLog(
        uint256 time,
        uint256 base,
        uint256 increasePerDay,
        uint256 increaseDays
    ) public onlyAddrOrOwner(_daoAddress) {
        _interestLog.push(
            InterestLog({
                time: time,
                base: base,
                increasePerDay: increasePerDay,
                increaseDays: increaseDays
            })
        );
    }

    function totalInterestLog() public view returns (uint256) {
        return _interestLog.length;
    }

    function interestLogByIndex(uint256 index)
        public
        view
        returns (InterestLog memory)
    {
        InterestLog memory log = _interestLog[index];
        return log;
    }
}