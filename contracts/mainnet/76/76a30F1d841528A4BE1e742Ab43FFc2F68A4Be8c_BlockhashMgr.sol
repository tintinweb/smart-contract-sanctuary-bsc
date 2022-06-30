// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >= 0.7.6;

import '@openzeppelin/contracts/utils/Context.sol';

/**
 * This is a contract copied from 'Ownable.sol'
 * It has the same fundation of Ownable, besides it accept pendingOwner for mor Safe Use
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _pendingOwner;

    event ChangePendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "Ownable: caller is not the pendingOwner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        if (_pendingOwner != address(0)) {
            emit ChangePendingOwner(_pendingOwner, address(0));
            _pendingOwner = address(0);
        }
    }

    function setPendingOwner(address pendingOwner_) public virtual onlyOwner {
        require(pendingOwner_ != address(0), "Ownable: pendingOwner is the zero address");
        emit ChangePendingOwner(_pendingOwner, pendingOwner_);
        _pendingOwner = pendingOwner_;
    }

    function acceptOwner() public virtual onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        emit ChangePendingOwner(_pendingOwner, address(0));
        _pendingOwner = address(0);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

interface IBlockhashMgr {
    function request(uint256 blockNumber) external;

    function getBlockhash(uint256 blockNumber) external returns(bytes32);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "../core/SafeOwnable.sol";
import "../interfaces/IBlockhashMgr.sol";

contract BlockhashMgr is IBlockhashMgr, SafeOwnable {
    mapping(uint256 => bytes32) public blockInfo;

    uint256 public preBlockNum = block.number;

    function request() external {
        if (blockInfo[preBlockNum] == 0) {
            blockInfo[preBlockNum] = blockhash(preBlockNum);
        }
    }

    function isRequest() public view returns (bool) {
        return
            (blockInfo[preBlockNum] == 0) && (preBlockNum + 200 < block.number);
    }

    function request(uint256 blockNumber) external override {
        require(blockNumber == block.number + 1, "block number error");
        if (blockNumber != preBlockNum && blockInfo[preBlockNum] == 0) {
            if (block.number - preBlockNum <= 256) {
                blockInfo[preBlockNum] = blockhash(preBlockNum);
            }
        }
        preBlockNum = blockNumber;
    }

    function getBlockhash(uint256 blockNumber)
        external
        override
        returns (bytes32)
    {
        require(block.number >= blockNumber, "");

        if (blockInfo[blockNumber] == 0) {
            if (block.number - blockNumber > 256) {
                return 0;
            } else {
                blockInfo[blockNumber] = blockhash(blockNumber);
            }
            preBlockNum = blockNumber;
        }

        return blockInfo[blockNumber];
    }

    function setBlockHash(uint256 _blockNumber, bytes32 _hash)
        external
        onlyOwner
    {
        if (block.number - _blockNumber > 256 && blockInfo[_blockNumber] == 0) {
            blockInfo[_blockNumber] = _hash;
        }
    }
}