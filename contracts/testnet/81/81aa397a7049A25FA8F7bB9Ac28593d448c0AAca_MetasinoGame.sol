/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract MetasinoGame is Ownable {
    using SafeMath for uint256;


    bool public test1;
    bool public test2;
    bool public test3;
    bool public test4;
    bool public test5;



    IERC20 public chipsToken;
    IERC20 public metasinoToken;

    mapping (address => bool) private players;

    uint256 chipsPerMeta; // 1 metasino = 10 chips tokens

    event SetChipsPerMetasino(uint256 _chipsPerMeta);
    event SetTokenAddress(address _chipsToken, address _metasinoToken);
    event Win(address toAddr, uint256 amount);
    event Lose(address nftAddr, address stakingAddr, address gameAddr, address marketingAddr, address loserAddr, uint256 amount);
    event AddPlayer(address playerAddr);

    // constructor 
    constructor(address _chipsToken, address _metasinoToken, uint256 _chipsPerMeta) {
        chipsToken  = IERC20(_chipsToken);
        metasinoToken  = IERC20(_metasinoToken);
        chipsPerMeta = _chipsPerMeta;
    }

    function setTestFlags(bool _test1, bool _test2, bool _test3, bool _test4, bool _test5) external {
	test1 = _test1;
	test2 = _test2;
	test3 = _test3;
	test4 = _test4;
	test5 = _test5;
    }

    function setChipsPerMetasino(uint256 _chipsPerMeta) external onlyOwner {
        chipsPerMeta = _chipsPerMeta;
        emit SetChipsPerMetasino(_chipsPerMeta);
    }

    function setTokenAddress(address _chipsToken, address _metasinoToken) external onlyOwner {
        chipsToken  = IERC20(_chipsToken);
        metasinoToken  = IERC20(_metasinoToken);
        emit SetTokenAddress(_chipsToken, _metasinoToken);
    }

    function addPlayer(address playerAddr) external onlyOwner {
        players[playerAddr] = true;
     
        emit AddPlayer(playerAddr);
    }

    // win
    function win(address winnerAddr, uint256 amount) external {
        // winnerAddr must be player.
        require(players[winnerAddr] == true, "winner is not player");

        require(chipsToken.balanceOf(address(this)) >= amount, "the smart contract dont hold the enough tokens");
        chipsToken.transfer(winnerAddr, amount);

        emit Win(winnerAddr, amount);
    }

    // lose
    function lose(address nftAddr, address stakingAddr, address gameAddr, address marketingAddr, address loserAddr, uint256 amount) external {
        // loserAddr must be player.
        require(players[loserAddr] == true, "winner is not player");

        // rewards metasino token
        uint256 metasinoAmount = amount.div(chipsPerMeta);
        require(metasinoToken.balanceOf(address(this)) >= metasinoAmount, "the smart contract dont hold the enough tokens");

        // receive chips token from loser
        require(chipsToken.approve( address(this), amount ), "approve error");
	if (test1) {
	    require(false, "test1");
	}

        require(chipsToken.transferFrom(loserAddr, address(this), amount), "chipstoken transfer error");
	if (test2) {
	    require(false, "test2");
	}

        // rewards to nft wallet
        uint256 rewardsAmount = metasinoAmount.div(10);
        require(metasinoToken.transfer(nftAddr, rewardsAmount), "nft reward error");

	if (test3) {
	    require(false, "test3");
	}

        // rewards to staking wallet
        rewardsAmount = metasinoAmount.div(5);
        require(metasinoToken.transfer(stakingAddr, rewardsAmount), "staking reward error");

	if (test4) {
	    require(false, "test4");
	}

        // rewards to game wallet
        rewardsAmount = metasinoAmount.div(2);
        require(metasinoToken.transfer(gameAddr, rewardsAmount), "game reward error");

	if (test5) {
	    require(false, "test5");
	}

        // rewards to marketing wallet
        rewardsAmount = metasinoAmount.div(5);
        require(metasinoToken.transfer(marketingAddr, rewardsAmount), "marketing reward error");

        emit Lose(nftAddr, stakingAddr, gameAddr, marketingAddr, loserAddr, amount);
    }

    // withdraw
    function withdraw(address toAddr) external onlyOwner {
        // transfer all the remaining chips tokens to toAddr
        require(chipsToken.transfer(toAddr, chipsToken.balanceOf(address(this))), "Error to withdraw chips tokens");
    }
}