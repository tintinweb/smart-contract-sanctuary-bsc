/**
 *Submitted for verification at BscScan.com on 2022-07-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    /**
     * TODO: Add comment
     */
    function burn(uint256 burnQuantity) external returns (bool);

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

contract Gambling is Ownable {
    using SafeMath for uint256;
     
    struct gameInfo {
        uint256 period;
        uint256 count;
        uint256 price;
        uint256 award;
        uint256 saleCount;
        uint256 startTime;
        uint256 lotteryCode;
        address winner;
        uint256 openTime;
    }
    
    struct betInfo {
        uint256 buyTime;
        address user;
    }
    mapping(uint256 => gameInfo) private _gameInfoMap;
    //mapping(string => betInfo) private _betUserMap;
    mapping(uint256 => mapping(address=>uint256)) public _userBetCount;
    mapping(uint256 => betInfo[]) public _betUserList;
    address public _opAddress = 0x472a89b8539362658FB00dF7fD258DcC3c2e4Eb5;
    address private _ownerAddress;
    //IERC20 private _token = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 private _token = IERC20(0x2d609440e9156CB0C579f02dC248e849387fDb4f);
    uint256 public _currentPeriod = 0;
    bool public _isStart = false;
   // event BuyIDO(address user, uint256 numberOfToken, uint256 period);
   // event OpenLottery(address winner, uint256 period);

    constructor() {
        _ownerAddress = msg.sender;
    }
    
    function setOpAddress(address opAddress) public onlyOwner {
        _opAddress = opAddress;
    }
    
    function setNewGamble(uint256 period, uint256 count, uint256 price, uint256 award) public returns(bool) {
        require(_opAddress==msg.sender||_ownerAddress==msg.sender, "donnot have permission.");
        //require(!_isStart, "game is in play.");
        //require(_currentPeriod<1, "game not over.");
        require(price>0, "price need bigger than 0.");
        require(count>0, "count cannot be zero.");
        require(award>0, "award cannot be zero.");

        _currentPeriod = period;
        _isStart = true;
        _gameInfoMap[period] = gameInfo({
            period: period,
            count: count,
            price: price,
            saleCount: 0,
            award: award,
            startTime: block.timestamp,
            lotteryCode: 0,
            winner: address(0),
            openTime: 0
        });

        return true;
    }

    function getGambleInfo(uint256 period) public view returns(gameInfo memory) {
        return _gameInfoMap[period];
    }

    function withdraw(address to, uint256 amount) public onlyOwner returns(bool) {
        _token.transfer(to, amount);
        return true;
    }

    function openLottery() public returns(bool) {
        require(_isStart, "current game is over.");
        require(_currentPeriod>0, "currnet game is over.");
        require(_opAddress==msg.sender||_ownerAddress==msg.sender, "donnot have permission.");

        gameInfo memory info = _gameInfoMap[_currentPeriod];
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        info.lotteryCode = random.mod(info.count);
        betInfo memory winBetInfo = _betUserList[_currentPeriod][info.lotteryCode];
        info.winner = winBetInfo.user;
        info.openTime = block.timestamp;
        _token.transfer(winBetInfo.user, info.award);

        return true;
    }


    function buyIdoTest(uint256 numberOfToken) public view returns(uint256) {
        require(_currentPeriod>0, "game not open");

        gameInfo memory info = _gameInfoMap[_currentPeriod];
        uint256 price = info.price;
        require(info.count.sub(info.saleCount)>0, "already sold out.");
        require(info.saleCount.add(numberOfToken) <= info.count, "count left not empty.");
    
        //uint256 amount = price.mul(numberOfToken).mul(10**18);
        //_token.transfer(address(this), amount);

        // uint256 buyed = _userBetCount[_currentPeriod][msg.sender];
        return _token.balanceOf(msg.sender);
    }

    function buyIdoTest2(uint256 numberOfToken) public returns(uint256) {
        require(_currentPeriod>0, "game not open");

        gameInfo memory info = _gameInfoMap[_currentPeriod];
        uint256 price = info.price;
        require(info.count.sub(info.saleCount)>0, "already sold out.");
        require(info.saleCount.add(numberOfToken) <= info.count, "count left not empty.");
    
        uint256 amount = price.mul(numberOfToken).mul(10**18);
        _token.transfer(address(this), amount);

        return amount;
    }

    function buyIdo(uint256 numberOfToken) public returns(bool) {
        require(_currentPeriod>0, "game not open");

        gameInfo memory info = _gameInfoMap[_currentPeriod];
        uint256 price = info.price;
        require(info.count.sub(info.saleCount)>0, "already sold out.");
        require(info.saleCount.add(numberOfToken) <= info.count, "count left not empty.");
       // require(numberOfToken.mul(price)>=msg.value, "price not enough.");

        uint256 amount = price.mul(numberOfToken).mul(10**18);
        _token.transfer(address(this), amount);

        uint256 buyed = _userBetCount[_currentPeriod][msg.sender];
        _userBetCount[_currentPeriod][msg.sender] = numberOfToken.add(buyed);
        for (uint256 i = 0; i < numberOfToken; ++i) {
            _betUserList[_currentPeriod].push(betInfo({
                buyTime: block.timestamp,
                user: msg.sender
            }));
        }

        info.saleCount = info.saleCount.add(numberOfToken);
        if (info.count == info.saleCount) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
            info.lotteryCode = random.mod(info.count);
            betInfo memory winBetInfo = _betUserList[_currentPeriod][info.lotteryCode];
            info.winner = winBetInfo.user;
            info.openTime = block.timestamp;
            _token.transfer(winBetInfo.user, info.award);

            _isStart = false;
            _currentPeriod = 0;
        }

        return true;
    }
}