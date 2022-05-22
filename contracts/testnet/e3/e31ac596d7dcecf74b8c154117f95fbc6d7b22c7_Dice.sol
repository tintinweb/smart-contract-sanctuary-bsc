/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

/**
 *Submitted for verification at BscScan.com on 2021-03-05
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: MIT

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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

pragma solidity ^0.6.0;

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Dice is Ownable {
    uint256 private divFactor = 10000000;
    address private burnAddress =
        address(0x000000000000000000000000000000000000dEaD);

    IERC20 public token;
    IERC20 public flpToken;
    uint256 public minFlp;
    uint256 public minBet;
    uint256 public maxBet;
    uint256 public regularFactor = 10000000;
    uint256 public burnFee = 100;

    mapping(address => uint256) public bonus;

    event BetWinner(
        address indexed user,
        uint8 dice1,
        uint8 dice2,
        uint256 amount
    );
    event BetLoser(address indexed user, uint8 dice1, uint8 dice2);

    constructor(
        IERC20 _token,
        IERC20 _flpToken,
        uint256 _minFlp,
        uint256 _minBet,
        uint256 _maxBet
    ) public {
        token = _token;
        flpToken = _flpToken;
        minFlp = _minFlp;
        minBet = _minBet;
        maxBet = _maxBet;
    }

    modifier canPay(uint256 _amount) {
        require(
            token.balanceOf(address(this)) >=
                _amount * (regularFactor / divFactor),
            "No bank money"
        );
        require(token.balanceOf(msg.sender) >= _amount, "No player money");
        require(flpToken.balanceOf(msg.sender) >= minFlp, "No falopa mucha");

        bonus[msg.sender] += 1;
        _;
    }

    function setToken(IERC20 _token) public onlyOwner {
        token = _token;
    }

    function setMinBet(uint256 _minBet) public onlyOwner {
        require(_minBet > 0 && _minBet < maxBet, "Invalid range");

        minBet = _minBet;
    }

    function setMaxBet(uint256 _maxBet) public onlyOwner {
        require(_maxBet > 0 && _maxBet > minBet, "Invalid range");

        maxBet = _maxBet;
    }

    function setFactor(uint256 _factor) public onlyOwner {
        require(_factor > 0, "Invalid range");

        regularFactor = _factor;
    }

    function setBurnFee(uint256 _fee) public onlyOwner {
        require(_fee >= 10 && _fee <= 100, "Invalid range");

        burnFee = _fee;
    }

    function transferFromPot(uint256 _amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= _amount, "No money");

        token.transfer(msg.sender, _amount);
    }

    function bet(
        uint8 _dice1,
        uint8 _dice2,
        uint256 _amount
    ) public canPay(_amount) {
        require(_dice1 >= 1 && _dice1 <= 6, "Invalid range dice 1");
        require(_dice2 >= 1 && _dice2 <= 6, "Invalid range dice 2");
        
        require(_amount >= minBet && _amount <= maxBet, "Invalid range amoun");
        
        uint8 winner1 = randomDice1();
        uint8 winner2 = randomDice2();
        bool oneMatch = _dice1 == winner1 || _dice1 == winner2;
        bool twoMatch = _dice2 == winner1 || _dice2 == winner2;
        bool isTwelve = winner1 == 6 && winner2 == 6;

        if (oneMatch && twoMatch) {
            uint256 factor = regularFactor;
            if (isTwelve) {
                factor = factor * 2;
            }
            payWinner(_amount, factor, winner1, winner2);
        } else {
            chargeLooser(_amount, winner1, winner2);
        }
    }

    function chargeLooser(
        uint256 _amount,
        uint8 dice1,
        uint8 dice2
    ) private {
        uint256 feeAmount = _amount / burnFee;
        uint256 potAmount = _amount - feeAmount;

        token.transferFrom(msg.sender, address(this), potAmount);
        token.transferFrom(msg.sender, burnAddress, feeAmount);

        emit BetLoser(msg.sender, dice1, dice2);
    }

    function payWinner(
        uint256 _amount,
        uint256 factor,
        uint8 dice1,
        uint8 dice2
    ) private {
        factor += bonus[msg.sender]; // Add bonus
        bonus[msg.sender] = 0; // Reset bonus
        
        uint256 winnerAmount = (_amount * factor) / divFactor;
        uint256 feeAmount = winnerAmount / burnFee;
        winnerAmount -= feeAmount - _amount; // Remove winner payment

        token.transfer(msg.sender, winnerAmount);
        token.transfer(burnAddress, feeAmount);

        emit BetWinner(msg.sender, dice1, dice2, winnerAmount + _amount);
    }

    function randomDice1() private view returns (uint8) {
        uint256 blockValue =
            uint256(blockhash(block.number - 1 + block.timestamp));
        blockValue += uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        );
        return uint8(blockValue % 6) + 1;
    }

    function randomDice2() private view returns (uint8) {
        uint256 blockValue =
            uint256(blockhash(block.number - 1 + block.timestamp));
        blockValue += token.balanceOf(msg.sender) + token.balanceOf(address(this));
        return uint8(blockValue % 6) + 1;
    }
}