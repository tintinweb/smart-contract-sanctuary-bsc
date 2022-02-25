/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-22
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

    // metasino token
    IERC20 public metasinoToken;

    // players
    mapping (address => bool) private players;

    uint256 chipsPerMeta; // 1 metasino = 10 chips tokens

    // betting info
    uint256[] private winInfoList;
    uint256 private randomNum;

    // chips info
    mapping (address => uint256) private chipsInfo;

    // reward wallet address
    address private nftWallet;
    address private gameWallet;
    address private marketingWallet;

    // evnet ------------
    event SetNftWallet(address _wallet);
    event SetGameWallet(address _wWallet);
    event SetMarketingWallet(address _wallet);
    event SetChipsPerMetasino(uint256 _chipsPerMeta);
    event SetTokenAddress(address _metasinoToken);
    event SetBetting(uint256[] _infoList);
    event SetRandomNumber(uint256);

    event WinProc(address toAddr, uint256 amount);
    event LoseProc(address loserAddr, uint256 amount);

    event AddPlayer(address playerAddr);

    event Deposit(address userAddr, uint256 amount);
    event WithdrawForOwner(address userAddr);
    event WithdrawForUser(address userAddr);

    // constructor 
    constructor(address _metasinoToken, uint256 _chipsPerMeta) {
        metasinoToken  = IERC20(_metasinoToken);
        chipsPerMeta = _chipsPerMeta;
    }

    function setNftWallet(address _wallet) external onlyOwner {
        nftWallet = _wallet;
        emit SetNftWallet(_wallet);
    }

    function setGameWallet(address _wallet) external onlyOwner {
        gameWallet = _wallet;
        emit SetGameWallet(_wallet);
    }

    function setMarketingWallet(address _wallet) external onlyOwner {
        marketingWallet = _wallet;
        emit SetMarketingWallet(_wallet);
    }

    function setChipsPerMetasino(uint256 _chipsPerMeta) external onlyOwner {
        chipsPerMeta = _chipsPerMeta;
        emit SetChipsPerMetasino(_chipsPerMeta);
    }

    function setTokenAddress(address _metasinoToken) external onlyOwner {
        metasinoToken  = IERC20(_metasinoToken);
        emit SetTokenAddress(_metasinoToken);
    }

    function addPlayer(address playerAddr) external onlyOwner {
        players[playerAddr] = true;
        emit AddPlayer(playerAddr);
    }

    // win
    function winProc(address winnerAddr, uint256 amount) internal {

        chipsInfo[winnerAddr] = chipsInfo[winnerAddr].add(amount);

        // require(chipsToken.balanceOf(address(this)) >= amount, "the smart contract dont hold the enough tokens");
        // chipsToken.transfer(winnerAddr, amount);

        emit WinProc(winnerAddr, amount);
    }

    // lose
    function loseProc(address loserAddr, uint256 amount) internal {
        // loserAddr must be player.

        uint256 loseAmount = amount.mul(8).div(10);
        require(chipsInfo[loserAddr] >= loseAmount, "loserAddr dont hold the enough chips tokens");

        // The loser's chip amount is reduced by lossAmount.
        chipsInfo[loserAddr] = chipsInfo[loserAddr].sub(loseAmount);

        // rewards metasino token
        uint256 metasinoAmount = amount.div(chipsPerMeta);

        // rewards to nft wallet
        uint256 rewardsAmount = metasinoAmount.div(10);
        require(metasinoToken.transfer(nftWallet, rewardsAmount), "nft reward error");

        // rewards to game wallet
        rewardsAmount = metasinoAmount.div(2);
        require(metasinoToken.transfer(gameWallet, rewardsAmount), "game reward error");

        // rewards to marketing wallet
        rewardsAmount = metasinoAmount.div(5);
        require(metasinoToken.transfer(marketingWallet, rewardsAmount), "marketing reward error");

        emit LoseProc(loserAddr, amount);
    }

    // withdraw for owner
    function withdrawForOwner(uint256 amount) external onlyOwner {
        // transfer all the remaining chips tokens to toAddr
        if (amount > 0) {
            uint256 metasinoAmount = amount.mul(chipsPerMeta);
            if (chipsInfo[msg.sender] > metasinoAmount) {
                chipsInfo[msg.sender] = chipsInfo[msg.sender].sub(metasinoAmount);
            }

            require(metasinoToken.transfer(msg.sender, amount), "Error to withdraw metasino");

            emit WithdrawForOwner(msg.sender);
        }
    }

    // withdraw for user
    function withdrawForUser(uint256 amount) external {
        // transfer all the remaining chips tokens to toAddr
        if (amount > 0) {
            chipsInfo[msg.sender] = chipsInfo[msg.sender].sub(amount);

            uint256 metasinoAmount = amount.div(chipsPerMeta);
            require(metasinoToken.transfer(msg.sender, metasinoAmount), "Error to withdraw metasino");

            emit WithdrawForUser(msg.sender);
        }
    }

    // deposit
    function deposit(uint256 amount) external {
        if (amount > 0) {
            uint256 maxDepositAmount = metasinoToken.balanceOf(msg.sender);
            maxDepositAmount = maxDepositAmount.mul(8).div(10);
            require(maxDepositAmount >= amount, "max deposit amount is 80%");

            metasinoToken.transferFrom(address(msg.sender), address(this), amount);

            // set chips to msg.sender
            chipsInfo[msg.sender] = chipsInfo[msg.sender].add(amount.mul(chipsPerMeta));
        }

        emit Deposit(msg.sender, amount);
    }

    // get random number;
    function getRandomNumber() external view returns (uint256) {
        return randomNum;
    }

    // set random number;
    function setRandomNumber(uint256 _randomNum) external {
        randomNum = _randomNum;
        emit SetRandomNumber(_randomNum);
    }

    function random(uint256 _maxVal) private view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _maxVal);
    }

    // set betting infos
    function setBetting(uint256[] memory _infoList, uint256 bettingAmount) external returns (uint256) {
        winInfoList = _infoList;

        randomNum = random(_infoList.length);

        if (_infoList[randomNum] == 0 || (
            _infoList[randomNum] != 0 && _infoList[randomNum] < bettingAmount)) {
            // lose
            loseProc(msg.sender, bettingAmount);
        } else if (_infoList[randomNum] != 0 && _infoList[randomNum] >= bettingAmount) {
            // win
            uint256 amount = _infoList[randomNum].sub(bettingAmount);
            winProc(msg.sender, amount);
        }

        emit SetBetting(_infoList);

        return randomNum;
    }

    // get win infos
    function getWinInfoList() external view returns (uint256[] memory) {
        return winInfoList;
    }

    // get win infos
    function getWinInfo(uint256 _index) external view returns (uint256) {
        if (_index < winInfoList.length) {
            return winInfoList[_index];
        }

        return 0;
    }

    // get chips
    function getChips(address acc) external view returns (uint256) {
        return chipsInfo[acc];
    }

}