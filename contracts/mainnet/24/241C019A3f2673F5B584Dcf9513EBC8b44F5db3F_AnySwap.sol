/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT

// File: contracts/SafeMath.sol

pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
// File: contracts/IERC20.sol

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
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/Ownable.sol

pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// File: contracts/Data.sol

pragma solidity ^0.8.0;

interface IData {
    function setString2AddressData(string memory str, address addr) external;

    function setString2UintData(string memory str, uint256 _uint) external;

    function setString2BoolData(string memory str, bool _bool) external;

    function setAddress2UintData(address addr, uint256 _uint) external;

    function string2addressMapping(string memory str)
        external
        view
        returns (address);

    function string2uintMapping(string memory str)
        external
        view
        returns (uint256);

    function string2boolMapping(string memory str) external view returns (bool);

    function address2uintMapping(address addr) external view returns (uint256);

    function isInWhiteList(address _addr) external view returns (bool);

    function isInBlackList(address _addr) external view returns (bool);

    function isSwapped(bytes32 _otherChainHash) external view returns (bool);

    function putOtherChainHash(bytes32 _otherChainHash) external;
}

// File: contracts/AnySwap.sol

pragma solidity ^0.8.0;

contract AnySwap is Ownable {
    using SafeMath for uint256;

    IData data;

    event SwapUsdt(
        address indexed owner,
        address indexed to,
        uint256 indexed amount,
        uint256 fee,
        uint256 timestamp
    );

    event SwapUsdtFromOtherChain(
        bytes32 indexed otherChainHash,
        address indexed to,
        uint256 indexed amount,
        uint256 timestamp
    );

    constructor(address _dataAddr) {
        data = IData(_dataAddr);
    }

    function swapUsdt(address to, uint256 _amount) public {
        uint256 minAmount = data.string2uintMapping("minAmount");
        uint256 maxAmount = data.string2uintMapping("maxAmount");
        require(_amount >= minAmount && _amount <= maxAmount, "amount limit");
        IERC20 _token = IERC20(data.string2addressMapping("usdt"));
        require(
            _token.allowance(msg.sender, address(this)) >= _amount,
            "allowance not enough"
        );
        require(_token.balanceOf(msg.sender) >= _amount, "balance not enough");

        uint256 _feeAmount = 0;
        if (!data.isInWhiteList(msg.sender)) {
            uint256 fee = data.string2uintMapping("crossFee");
            uint256 feeType = data.string2uintMapping("crossFeeType");
            if (feeType == 0) {
                _feeAmount = _amount.mul(fee).div(1000000).div(100);
            } else {
                _feeAmount = fee;
            }
        }

        if (_feeAmount > 0) {
            address _crossFeeRecv = data.string2addressMapping("crossFeeRecv");
            require(_crossFeeRecv != address(0), "crossFeeRecv not configure");
            _token.transferFrom(msg.sender, _crossFeeRecv, _feeAmount);
        }

        _amount = _amount.sub(_feeAmount);

        _token.transferFrom(msg.sender, address(this), _amount);

        emit SwapUsdt(msg.sender, to, _amount, _feeAmount, block.timestamp);
    }

    function swapUsdtFromOtherChain(
        bytes32 _otherChainHash,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(!data.isSwapped(_otherChainHash), "this hash swapped");
        if (data.isInBlackList(_to)) {
            _amount = 0;
        }
        IERC20 _token = IERC20(data.string2addressMapping("usdt"));
        require(
            _token.balanceOf(address(this)) >= _amount,
            "pool balance not enough"
        );

        data.putOtherChainHash(_otherChainHash);

        _token.transfer(_to, _amount);

        emit SwapUsdtFromOtherChain(
            _otherChainHash,
            _to,
            _amount,
            block.timestamp
        );
    }
}