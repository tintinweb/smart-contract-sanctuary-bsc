/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.2;

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

    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            require(denominator > prod1);

            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)

                prod0 := div(prod0, twos)

                twos := add(div(sub(0, twos), twos), 1)
            }

            prod0 |= prod1 * twos;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            result = prod0 * inverse;
            return result;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 result = 1 << (log2(a) >> 1);

        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

contract KryptoRangerLock is Ownable {
    struct Lock {
        uint256 initialAmount;
        uint256 lockedAmount;
        uint256 unlockPeriod;
        uint256[] unlockedAmountPerPeriod;
        uint256 withdrawed;
    }

    uint256 public initialTime;

    address public privateSale;
    address public team;
    address public marketing;

    IERC20 public tokenContract;
    bool public tokenLocked;

    IERC20 public liquidityContract;
    bool public liquidityLocked;

    mapping(address => mapping(IERC20 => Lock)) private lockProfile;

    event Withdraw(address account, uint256 amount);

    function lockToken(
        address _privateEquity,
        address _developer,
        address _marketing
    ) public onlyOwner {
        require(!tokenLocked, "Locked");
        tokenLocked = true;

        initialTime = block.timestamp;

        privateSale = _privateEquity;
        team = _developer;
        marketing = _marketing;

        // privateSale
        lockProfile[privateSale][tokenContract].lockedAmount = 100_000 ether;
        lockProfile[privateSale][tokenContract].initialAmount = 50_000 ether;
        lockProfile[privateSale][tokenContract].unlockPeriod = 30 days;
        lockProfile[privateSale][tokenContract].unlockedAmountPerPeriod = [25_000 ether, 25_000 ether];

        // marketing
        lockProfile[marketing][tokenContract].lockedAmount = 260_000 ether;
        lockProfile[marketing][tokenContract].initialAmount = 65_000 ether;
        lockProfile[marketing][tokenContract].unlockPeriod = 30 days;
        lockProfile[marketing][tokenContract].unlockedAmountPerPeriod = [65_000 ether, 65_000 ether, 65_000 ether];

        // team
        lockProfile[team][tokenContract].lockedAmount = 400_000 ether;
        lockProfile[team][tokenContract].unlockPeriod = 365 days;
        lockProfile[team][tokenContract].unlockedAmountPerPeriod = [400_000 ether];

        // 100_000 + 260_000 + 400_000 = 760_000
        tokenContract.transferFrom(msg.sender, address(this), 760_000 ether);
    }

    function lockLiquidity() public onlyOwner {
        require(!liquidityLocked, "Locked");
        liquidityLocked = true;

        // liquidity token
        uint256 allLiquidityToken = liquidityContract.balanceOf(msg.sender);
        lockProfile[msg.sender][liquidityContract].lockedAmount = allLiquidityToken;
        lockProfile[msg.sender][liquidityContract].unlockPeriod = 240 days;
        lockProfile[msg.sender][liquidityContract].unlockedAmountPerPeriod = [allLiquidityToken];

        // lock all liquidity token
        liquidityContract.transferFrom(msg.sender, address(this), allLiquidityToken);
    }

    function setTokenContract(address _address) public onlyOwner {
        tokenContract = IERC20(_address);
    }

    function setLiquidityTokenContract(address _address) public onlyOwner {
        liquidityContract = IERC20(_address);
    }

    // public

    function withdrawLiquidityToken(address account) public {
        uint256 balance = unlockedAmount(lockProfile[account][liquidityContract]) - lockProfile[account][liquidityContract].withdrawed;
        require(balance > 0, "No amount to withdraw");

        lockProfile[account][liquidityContract].withdrawed += balance;
        liquidityContract.transfer(account, balance);

        emit Withdraw(account, balance);
    }

    function withdrawToken(address account) public {
        uint256 balance = unlockedAmount(lockProfile[account][tokenContract]) - lockProfile[account][tokenContract].withdrawed;
        require(balance > 0, "No amount to withdraw");

        lockProfile[account][tokenContract].withdrawed += balance;
        tokenContract.transfer(account, balance);

        emit Withdraw(account, balance);
    }

    function unlockedAmount(Lock memory lock) public view returns (uint256 amount) {
        if (lock.unlockPeriod == 0) {
            return 0;
        }

        uint256 timePassed = block.timestamp - initialTime;
        uint256 multiplier = (timePassed / lock.unlockPeriod);

        for (uint256 i = 0; i < multiplier; i++) {
            amount += lock.unlockedAmountPerPeriod[Math.min(i, lock.unlockedAmountPerPeriod.length - 1)];
        }

        amount = Math.min(amount + lock.initialAmount, lock.lockedAmount);
    }

    function getLockProfile(address _address, address token) public view returns (Lock memory) {
        return lockProfile[_address][IERC20(token)];
    }
}