/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = 0;
        if (b > 0 && a > 0) {
            c = a / b;
        }
        return c;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract lifeBonus is Ownable {
    using SafeMath for uint256;
    address private _mall;
    address private _token;
    uint256 public nextyear = 0;
    uint256 public nexttime = 0;
    uint256 public needBonus = 2000;
    uint256 public nextTotalPower = 1500000 * (10**6);

    constructor(address token_, uint256 start_) {
        _token = token_;
        nexttime = start_;
    }

    function setMall(address addr) external onlyOwner {
        _mall = addr;
    }

    function getBonus(uint256 total_power) external returns (bool) {
        require((owner() == msg.sender || _mall == msg.sender), "error sender");
        require(nexttime < block.timestamp, "error time");
        IERC20 lifeContract = IERC20(_token);
        uint8 decimal = lifeContract.decimals();

        if (nextyear != 0) {
            if (nextyear <= block.timestamp) {
                needBonus = (needBonus * 97) / 100;
                nextyear = nextyear + 365 days;
            }
        } else {
            uint256 next = nextTotalPower;
            uint256 need = needBonus;
            while (next <= total_power) {
                next = (next * 15) / 10;
                need = (need * 12) / 10;
            }

            if (need != needBonus) {
                nextTotalPower = next;
                needBonus = need;
            }

            if (needBonus >= 20000) {
                needBonus = 20000;
                nextyear = nexttime + 365 days;
            }
        }

        nexttime = nexttime + 1 days;
        return lifeContract.transfer(msg.sender, needBonus * (10**decimal));
    }

    function getToken() external view returns (address) {
        return _token;
    }
}