// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IPrivate.sol";

contract Private is Ownable {

    address public immutable usdt;
    address public immutable busd;
    address public constant previousPrivate = 0xE2F950453DE77191857ee115d672d9650896C159;
    address public receiver;
    uint256 public start;
    uint256 public end;
    uint256 public min;
    uint256 public max;
    uint256 public price;
    uint256 public hardcap;
    uint256 public _totalPaid;
    uint256 public wlPeriod;
    uint256 public totalContributors;
    mapping(uint256 => address) public contributor;
    mapping(address => uint256) public paid;
    mapping(address => bool) public whitelist;

    event OnBuy (uint256 _amount, address _usd);

    constructor(address _usdt, address _busd){
        require(_usdt != address(0), "Zero address");
        require(_busd != address(0), "Zero address");
        usdt = _usdt;
        busd = _busd;
        start = 1675083600 + 12 days;
        end = 1677589200;
        receiver = 0x4438DbD66FF19d534AE74Ce93AB1dD74cc1F6A04;
        price = 0.016 * 10 ** 18;
        hardcap = 840000 * 10 ** 18;
        min = 1000 * 10 ** 18;
        max = 5000 * 10 ** 18;
        wlPeriod = 0;
    }

    function setStart(uint256 _start) external onlyOwner {
        require(_start > block.timestamp, "Start time must be in the future");
        start = _start;
    }

    function setEnd(uint256 _end) external onlyOwner {
        require(_end > start, "End time must be after start time");
        end = _end;
    }

    function setReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "Zero address");
        receiver = _receiver;
    }

    function setPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than zero");
        price = _price;
    }

    function setHardcap(uint256 _hardcap) external onlyOwner {
        require(_hardcap > 0, "Hardcap must be greater than zero");
        hardcap = _hardcap;
    }

    function setMin(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Zero amount");
        min = _amount;
    }

    function setMax(uint256 _amount) external onlyOwner {
        require(_amount > min, "Max must be greater than min");
        max = _amount;
    }

    function setWhitelist(address _addr, bool _status) external onlyOwner {
        whitelist[_addr] = _status;
    }

    function setWhitelistBatch(address[] memory _addr, bool _status) external onlyOwner {
        for (uint256 i = 0 ; i < _addr.length; i++) {
            whitelist[_addr[i]] = _status;
        }
    }

    function setWLperiod(uint256 _period) external onlyOwner {
        wlPeriod = _period;
    }

    function buy(uint256 _amount, address _usd) external {
        require(block.timestamp >= start, "Sale has not started");
        require(block.timestamp <= end, "Sale has ended");
        require(_amount >= min, "Amount is less than minimum");
        require(_amount + paid[_msgSender()] <= max, "Amount is more than maximum");
        require(_amount + totalPaid() <= hardcap, "Hardcap reached");
        if (block.timestamp < start + wlPeriod) {
            require(whitelist[_msgSender()], "Not in whitelist");
        }
        if (paid[_msgSender()] == 0) {
            contributor[totalContributors] = _msgSender();
            totalContributors++;
        }
        paid[_msgSender()] += _amount;
        _totalPaid += _amount;
        if (_usd == usdt) {
            IERC20(usdt).transferFrom(_msgSender(), receiver, _amount);
        } else {
            IERC20(busd).transferFrom(_msgSender(), receiver, _amount);
        }
        emit OnBuy (_amount, _usd);
    }

    function quoteAmount(uint256 _amount) external view returns (uint256) {
        return _amount * 10 ** 18 / price;
    }

    function totalPaid () public view returns (uint256) {
        return IPrivate(previousPrivate).totalPaid() + _totalPaid;
    }

    function getBalance(address _wallet) public view returns (uint256) {
        return paid[_wallet] * 10 ** 18/price;
    }

    function withdraw (
        address _token
    ) public onlyOwner {
        require(IERC20(_token).transfer(_msgSender(), IERC20(_token).balanceOf(address(this))), "Fail transfer");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IPrivate {
    function totalPaid() external view returns (uint256);
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
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}