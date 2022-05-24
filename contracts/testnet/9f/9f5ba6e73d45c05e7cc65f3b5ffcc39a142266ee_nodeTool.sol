/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

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


contract nodeTool is Ownable {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    uint8 constant type_1 = 1;
    uint8 constant type_2 = 2;
    mapping(uint8 => uint256) public amountMap;

    address public tokenAddress;
    address public receivedAddress;
    uint256 public startTime;
    uint256 public endTime;
    mapping(address => bool) public usedMap;

    address constant firstAddress = 0x0000000000000000000000000000000000000001;
    mapping(address => address) public refMap;
    mapping(address => address[]) public teamMap;
    mapping(address => uint256) public teamAmountMap;
    mapping(address => uint256) public refAmountMap;
    mapping(address => uint8) public nodeTypes;

    event Bind(address indexed fa, address indexed ca);
    event UpdateTime(uint256 indexed start, uint256 indexed end);
    event UpdateAmount(uint8 indexed nodeType, uint256 indexed amount);
    event Buy(
        address indexed from,
        address indexed up,
        uint8 indexed otype,
        uint256 amount
    );

    constructor(
        address _token,
        address _rec,
        uint256 startTime_,
        uint256 endTime_
    ) {
        startTime = startTime_;
        endTime = endTime_;
        receivedAddress = _rec;
        tokenAddress = _token;

        amountMap[type_1] = 6000e18;
        amountMap[type_2] = 2000e18;
    }

    function setTime(uint256 _start, uint256 _end) external onlyOwner {
        startTime = _start;
        endTime = _end;
        emit UpdateTime(_start, _end);
    }

    function _setTokenAmount(uint8 _type, uint256 _amount)
        internal
        checkType(_type)
    {
        amountMap[_type] = _amount;
        emit UpdateAmount(_type,_amount);
    }

    function setTokenAmount(uint8 _type, uint256 _amount) external onlyOwner {
        _setTokenAmount(_type, _amount);
    }

    function setTokenAmountArr(uint8[] memory ts, uint256[] memory amounts)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < ts.length; i++) {
            _setTokenAmount(ts[i], amounts[i]);
        }
    }

    modifier checkType(uint8 _type) {
        require(_type == 1 || _type == 2, "invalid type");
        _;
    }
    modifier checkTime() {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "time:not start or end"
        );
        _;
    }

    function _bind(address f, address c) internal {
        require(
            refMap[f] != address(0) || f == firstAddress,
            "invalid referrer"
        );
        require(refMap[c] == address(0), "already binded");
        refMap[c] = f;
        teamMap[f].push(c);
        emit Bind(f, c);
    }

    function getAmount(uint8 _type)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 amount = amountMap[_type];
        uint256 fee;
        if (_type == type_1) {
            fee = (amount * 30) / 100;
        } else {
            fee = (amount * 10) / 100;
        }
        return (amount, fee, amount - fee);
    }

    function buy(uint8 nodeType, address _referrer)
        external
        checkType(nodeType)
        checkTime
    {
        require(!usedMap[msg.sender], "once");
        if (refMap[msg.sender] == address(0)) {
            _bind(_referrer, msg.sender);
        }
        address up = refMap[msg.sender];

        (uint256 total, uint256 fee, uint256 recAmount) = getAmount(nodeType);
        teamAmountMap[up] += total;
        usedMap[msg.sender] = true;
        safeTransferFrom(tokenAddress, msg.sender, receivedAddress, recAmount);
        safeTransferFrom(tokenAddress, msg.sender, up, fee);
        nodeTypes[msg.sender] = nodeType;
        emit Buy(msg.sender, up, nodeType, total);
    }

    function getTeamLength(address _addr) public view returns (uint256) {
        return teamMap[_addr].length;
    }

    function getReferrer(address _addr) public view returns (address) {
        return refMap[_addr];
    }
}