// contracts/MetarsFundFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "Ownable.sol";
import "IMetarsFund.sol";
import "MetarsFund.sol";

contract MetarsFundFactory is Ownable {
    mapping(uint256 => address) public getPair;
    address[] public allPairs;

    event FundCreated(uint256 _artId, address pair, uint256);

    function createFundPair(
        uint256 _artId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _minFundAmount,
        uint256 _maxFundAmount
    ) external onlyOwner returns (address pair) {
        require(getPair[_artId] == address(0), "PAIR_EXISTS");
        bytes memory bytecode = type(MetarsFund).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_artId, address(this)));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IMetarsFund(pair).initialize(_artId, _startTime, _endTime, _minAmount, _maxAmount, _minFundAmount, _maxFundAmount, owner());
        getPair[_artId] = pair;
        allPairs.push(pair);
        emit FundCreated(_artId, pair, allPairs.length);
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// contracts/IMetarsFund.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMetarsFund {
    
    function initialize(
        uint256 _artId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _minFundAmount,
        uint256 _maxFundAmount,
        address _owner
    ) external;
}

// contracts/MetarsFund.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "TransferHelper.sol";

contract MetarsFund {
    address public owner;
    address public factory;
    bool public pause = true;
    uint256 public artId;
    // min eth amount
    uint256 public minAmount;
    uint256 public maxAmount;
    // max fund
    uint256 public maxFundAmount;
    uint256 public minFundAmount;

    uint256 public startTime;
    uint256 public endTime;

    uint256 public totalReceiveFund;

    address[] public fundUsers;

    mapping(address => uint256) public userFundMap;

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(
        uint256 _artId,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minAmount,
        uint256 _maxAmount,
        uint256 _minFundAmount,
        uint256 _maxFundAmount,
        address _owner
    ) external {
        require(msg.sender == factory, "Fund: FORBIDDEN"); // sufficient check
        artId = _artId;
        owner = _owner;
        // minAmount = 0.1 ether;
        // maxAmount = 1 ether;
        // minFundAmount = 100 ether;
        // maxFundAmount = 1000 ether;
        minAmount = _minAmount;
        maxAmount = _maxAmount;
        minFundAmount = _minFundAmount;
        maxFundAmount = _maxFundAmount;
        startTime = _startTime;
        endTime = _endTime;
    }

    receive() external payable {
        require(!pause, "already pause");
        require(msg.value >= minAmount, "< minAmount");
        require(msg.value <= maxAmount, "> maxAmount");
        require(block.timestamp >= startTime, "Err: not start");
        require(block.timestamp <= endTime, "Err: already end");
        // require(currentBalance < maxFundAmount, "exceed maxFundAmount");
        uint256 lastAmount = userFundMap[msg.sender];
       
        userFundMap[msg.sender] = lastAmount + msg.value;
        totalReceiveFund = totalReceiveFund + msg.value;
        fundUsers.push(msg.sender);
    }

    function setParams(uint256 _minAmount, uint256 _maxAmount) public {
        require(msg.sender == owner, "not owner");
        minAmount = _minAmount;
        maxAmount = _maxAmount;
    }

    function refund(uint256 count) public {
        require(pause, "not pause");
        require(msg.sender == owner, "not owner");
        require(address(this).balance < minFundAmount, "can not refund");

        for (uint256 i = 0; i < count; i++) {
            if (fundUsers.length > 0) {
                address _user = fundUsers[fundUsers.length - 1];
                uint256 amount = userFundMap[_user];
                if (amount > 0) {
                    TransferHelper.safeTransferETH(_user, amount);
                    userFundMap[_user] = 0;
                    // totalReceiveFund = totalReceiveFund - amount;
                }
                fundUsers.pop();
            }
        }
        // for (uint256 i = 0; i < _users.length; i++) {
        //     address _user = _users[i];
        //     uint256 amount = userFundMap[_user];
        //     if (amount > 0) {
        //         TransferHelper.safeTransferETH(_user, amount);
        //         userFundMap[_user] = 0;
        //         totalReceiveFund = totalReceiveFund - amount;
        //     }
        // }
    }

    function changePause() public {
        require(msg.sender == owner, "not owner");
        pause = !pause;
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "not owner");
        TransferHelper.safeTransferETH(owner, amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}