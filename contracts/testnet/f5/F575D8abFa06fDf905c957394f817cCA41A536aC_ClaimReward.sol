pragma solidity ^0.8.0;
// SPDX-License-Identifier: MIT
import "./Ownable.sol";

interface INFT {
    function balanceOf(address owner) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function getTokenType(uint256 tokenId) external view returns (uint8);
}

contract ClaimReward is Ownable {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    mapping(uint256 => uint256) amountMap;

    struct Info {
        uint firstTime;
        uint lastTime;
        uint count;
        uint amount;
    }

    mapping(uint256 => Info)public infos;
    INFT nftContract;
    address public tokenAddress;
    uint256 public startTime;
    uint256 public endTime;
    uint256 oneDay;
    uint256 public oneMonth;

    event Claim(address indexed from, uint256 indexed nftId, uint256 amount);
    constructor(address nft, address _token, uint256 startTime_, uint256 endTime_, uint256 oneDay_) {
        nftContract = INFT(nft);
        startTime = startTime_;
        endTime = endTime_;
        oneDay = oneDay_;
        oneMonth = oneDay * 30;
        tokenAddress = _token;
    }

    function setStartTime(uint256 _start) external onlyOwner {
        startTime = _start;
    }

    function _setTokenAmount(uint8 _type, uint256 _amount) internal checkType(_type) {
        amountMap[_type] = _amount;
    }

    function setTokenAmount(uint8 _type, uint256 _amount) external onlyOwner {
        _setTokenAmount(_type, _amount);
    }

    function setTokenAmountArr(uint8[] memory ts, uint256[] memory amounts) external onlyOwner {
        for (uint i = 0; i < ts.length; i++) {
            _setTokenAmount(ts[i], amounts[i]);
        }
    }

    modifier checkType(uint8 _type) {
        require(_type >= 1 && _type <= 4, "invalid type");
        _;
    }
    modifier checkTime() {
        require(block.timestamp >= startTime, "time:not start");
        _;
    }

    function claim(uint256[] memory ids) external checkTime {
        uint total;
        for (uint256 i = 0; i < ids.length; i++) {
            total += _claimId(ids[i]);
        }
        if (total > 0) {
            safeTransfer(tokenAddress, msg.sender, total);
        }

    }

    function getNFTAmount(uint256 nftId) public view returns (uint256){
        uint _type = nftContract.getTokenType(nftId);
        return amountMap[_type];
    }

    function _claimId(uint256 nftId) internal returns (uint256){
        require(nftContract.ownerOf(nftId) == msg.sender, "ownerOf");
        uint tokenAmount = getNFTAmount(nftId);
        uint curAmount;
        Info storage info = infos[nftId];
        require(info.count < 7, "claimAll");
        if (info.firstTime == 0) {
            curAmount = tokenAmount * 40 / 100;
            info.firstTime = block.timestamp;
            info.lastTime = block.timestamp;
            info.count = 1;
            info.amount = curAmount;
            emit Claim(msg.sender, nftId, curAmount);
        } else {
            uint perAmount = tokenAmount / 10;
            (uint newAmount,uint count, uint newTime) = getAmount(perAmount, info.lastTime);
            if (newAmount > 0) {
                curAmount = newAmount;
                info.lastTime = newTime;
                info.count += count;
                info.amount += newAmount;
                emit Claim(msg.sender, nftId, curAmount);
            }

        }
        return curAmount;
    }


    function getAmount(uint256 tokenAmount, uint last) public view returns (uint256, uint256, uint256){

        if (block.timestamp - last < oneMonth) {
            return (0, 0, last);
        }
        uint day = (block.timestamp - last) / oneMonth;
        uint amount = tokenAmount * day;
        uint newTime = day * oneMonth + last;
        return (amount, day, newTime);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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