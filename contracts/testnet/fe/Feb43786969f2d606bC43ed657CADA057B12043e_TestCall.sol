// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract TestCall is  Ownable {
    event Debug(bytes32 indexed sig);

    uint num = 2.5e18;
    function addAssembly(uint x, uint y) public pure returns (uint) {
        assembly {
            // Add some code here
            let result := add(x, y)
            mstore(0x0, result)
            // 从内存地址0x返回32字节
            return(0x0, 32)
        }
    }

    function count() public {
        num = (2**800 + 1) - 2**800;
        num = .5 * 8;
        emit Debug(msg.sig);
    }
 
    function addSolidity(uint x, uint y) public pure returns (uint) {
        return x + y;
    }


    function sumSolidity(uint[] calldata _data) public pure returns (uint o_sum) {
        for (uint i = 0; i < _data.length; ++i)
            o_sum += _data[i];
    }

    // 我们知道我们只能在数组范围内访问数组元素，所以我们可以在内联汇编中不做边界检查。
    // 由于 ABI 编码中数组数据的第一个字（32 字节）的位置保存的是数组长度，
    // 所以我们在访问数组元素时需要加入 0x20 作为偏移量。
    function sumAsm(uint[] memory _data) public pure returns (uint o_sum) {
        for (uint i = 0; i < _data.length; ++i) {
            assembly {
                o_sum := add(
                        o_sum, 
                        mload(
                            add(
                                add(_data, 0x20), mul(i, 0x20)
                            )
                        )
                    )
            }
        }
    }

    function sumAsm1(uint[] memory _data) public pure returns (uint o_sum) {
        for (uint i = 1; i <= _data.length; ++i) {
            assembly {
                o_sum := add(o_sum, mload(add(_data, mul(i, 0x20))))
            }
        }
    }

    function sumPureAsm(uint[] memory _data) public pure returns (uint o_sum, uint o_len) {
        assembly {
           // 取得数组长度（前 32 字节）
           let len := mload(_data)
           o_len := len

           // 略过长度字段。
           //
           // 保持临时变量以便它可以在原地增加。
           //
           // 注意：对 _data 数值的增加将导致 _data 在这个汇编语句块之后不再可用。
           //      因为无法再基于 _data 来解析后续的数组数据。
           let data := add(_data, 0x20)

           // 迭代到数组数据结束
            for { let end := add(data, mul(len, 0x20)) } lt(data, end) { data := add(data, 0x20) } {
                o_sum := add(o_sum, mload(data))
            }
        }
    }

    function for_loop_solidity(uint n, uint value) public pure returns(uint) {
        for ( uint i = 0; i < n; i++ ) {
            value = 2 * value;
        }
        return value;
    }

    function for_loop_assembly(uint n, uint value) public pure returns (uint) {
        assembly {
            for { let i := 0 } lt(i, n) { i := add(i, 1) } { 
                value := mul(2, value) 
            }
                
            mstore(0x0, value)
            return(0x0, 32)
        }
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