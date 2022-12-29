// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PresaleSRX is Ownable {
    //Price feeds
    AggregatorV3Interface public btcPriceFeed;
    AggregatorV3Interface public bnbPriceFeed;

    //Token address
    address public btcAddress;
    address public bnbAddress;
    address public usdcAddress;
    address public busdAddress;

    //Total tokens in contract
    uint256 public btcAmountInContract;
    uint256 public bnbAmountInContract;
    uint256 public usdcAmountInContract;
    uint256 public busdAmountInContract;

    //SRX token address
    address public srxAddress;

    //Presale start and end time
    uint256 public startTime;
    uint256 public endTime;

    //Presale token price 0.25 usd in usdc = 4 times the coins
    uint256 public srxPrice = 4;

    //Presale hard cap per wallet = 5000 usd
    uint256 public hardCapPerWallet = 5000 * 10 ** 18;

    //Presale min entry = 20 usd
    uint256 public minEntry = 20 * 10 ** 18;

    //Presale token amount 6m
    uint256 public srxAmount = 6000000 * 10 ** 18;

    //Presale token amount sold
    uint256 public srxAmountSold = 0;

    //Presale token amount left
    uint256 public srxAmountLeft = srxAmount;

    //Presale token amount claimed
    uint256 public srxAmountClaimed = 0;

    //Total participants
    uint256 public totalParticipants = 0;

    //Presale user to token amounts
    mapping(address => uint256) public userToBtcTokenAmount;
    mapping(address => uint256) public userToBnbTokenAmount;
    mapping(address => uint256) public userToUsdcTokenAmount;
    mapping(address => uint256) public userToBusdTokenAmount;

    //Presale user to total tokens to claim
    mapping(address => uint256) public userToTotalTokenToClaim;

    //User already tracked
    mapping(address => bool) public userAlreadyTracked;

    //User to total srx token value
    mapping(address => uint256) public userToTotalSrxTokenValue;

    //Events
    event PresaleStarted(uint256 startTime, uint256 endTime);
    event PresaleClaimed(address user, uint256 amount);
    event PresaleTokensBought(
        address user,
        uint256 amount,
        uint256 price,
        address token
    );

    event TokensWithdrawn(address reciever);
    event SRXBurned(uint256 amount);
    event PresaleEndedEarly(uint256 time);

    //constructor
    constructor() {
        //Set price feeds
        btcPriceFeed = AggregatorV3Interface(
            0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
        );
        bnbPriceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );

        //Set token addresses
        btcAddress = 0x574E2C2b53f5676a7A2aA69692a9DC609049342E;
        bnbAddress = 0x7e8CEc3b403074eFc9d313ad781ab6C5F87Dc2DF;
        usdcAddress = 0xBF7089A74050e26c70c1396234aE94b6758096d2;
        busdAddress = 0xC4a46290AD3315eBb998A8cc68B14a70cFCde731;

        //Set SRX token address
        srxAddress = 0x988CBC318A4d646777a0366Ab249C61f047B9484;
    }

    //Start presale
    function startPresale(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyOwner {
        // require(
        //     IERC20(srxAddress).balanceOf(address(this)) >= srxAmount,
        //     "Presale: Not enough tokens in contract"
        // );
        // require(
        //     _startTime > block.timestamp,
        //     "Presale: Start time is in the past"
        // );
        // require(
        //     _endTime > _startTime,
        //     "Presale: End time is before start time"
        // );
        startTime = _startTime;
        endTime = _endTime;
        emit PresaleStarted(_startTime, _endTime);
    }

    //Claim presale
    function claimPresale() external {
        // require(block.timestamp > endTime, "Presale: Presale is still ongoing");
        require(
            userToTotalTokenToClaim[msg.sender] > 0,
            "Presale: No tokens to claim"
        );
        require(
            srxAmountClaimed < srxAmount,
            "Presale: All tokens have been claimed"
        );
        require(
            srxAmountClaimed + userToTotalTokenToClaim[msg.sender] <= srxAmount,
            "Presale: Not enough tokens left to claim"
        );
        require(
            IERC20(srxAddress).transfer(
                msg.sender,
                userToTotalTokenToClaim[msg.sender]
            ),
            "Presale: Transfer failed"
        );
        srxAmountClaimed += userToTotalTokenToClaim[msg.sender];
        emit PresaleClaimed(msg.sender, userToTotalTokenToClaim[msg.sender]);
        userToTotalTokenToClaim[msg.sender] = 0;
    }

    //getTokenPrice function
    function getTokenPrice(
        address _tokenAddress
    ) public view returns (uint256) {
        if (_tokenAddress == btcAddress) {
            // (, int256 price, , , ) = btcPriceFeed.latestRoundData();
            // return uint256(price);
            return uint256(16500 * 10 ** 8);
        } else if (_tokenAddress == bnbAddress) {
            // (, int256 price, , , ) = bnbPriceFeed.latestRoundData();
            // return uint256(price);
            return uint256(1200 * 10 ** 8);
        } else if (_tokenAddress == usdcAddress) {
            //Hard coding the USDC price to 1 USD to avoid price feed errors and its a stable coin
            return 10 ** 8;
        } else if (_tokenAddress == busdAddress) {
            //Hard coding the BUSD price to 1 USD to avoid price feed errors and its a stable coin
            return 10 ** 8;
        } else {
            return 0;
        }
    }

    //Buy srx with any token by specifiying address
    function buySRXWithToken(address _tokenAddress, uint256 _amount) external {
        // require(
        //     block.timestamp >= startTime && block.timestamp <= endTime,
        //     "Presale: Presale is not ongoing"
        // );
        require(
            srxAmountSold < srxAmount,
            "Presale: All tokens have been sold"
        );
        require(
            srxAmountSold + srxAmountLeft >= srxAmount,
            "Presale: Not enough tokens left to sell"
        );

        require(
            userToTotalSrxTokenValue[msg.sender] <= hardCapPerWallet,
            "Presale: User has already bought the maximum amount of tokens per wallet"
        );

        require(
            _tokenAddress == btcAddress ||
                _tokenAddress == bnbAddress ||
                _tokenAddress == usdcAddress ||
                _tokenAddress == busdAddress,
            "Presale: Invalid token address"
        );
        require(
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _amount
            ),
            "Presale: Transfer failed"
        );
        uint256 tokenPrice = (getTokenPrice(_tokenAddress) / 10 ** 8);
        uint256 buyingPower = _amount * tokenPrice;
        uint256 tokenAmount = buyingPower * srxPrice;

        require(
            tokenAmount <= srxAmountLeft,
            "Presale: Not enough tokens left to sell"
        );

        require(buyingPower >= minEntry, "Presale: Buying power is too low");

        require(
            userToTotalSrxTokenValue[msg.sender] + buyingPower <=
                hardCapPerWallet,
            "Presale: User cannot exceed hard cap of tokens per wallet"
        );

        userToTotalSrxTokenValue[msg.sender] += buyingPower;

        if (_tokenAddress == btcAddress) {
            userToBtcTokenAmount[msg.sender] += _amount;
            btcAmountInContract += _amount;
        } else if (_tokenAddress == bnbAddress) {
            userToBnbTokenAmount[msg.sender] += _amount;
            bnbAmountInContract += _amount;
        } else if (_tokenAddress == usdcAddress) {
            userToUsdcTokenAmount[msg.sender] += _amount;
            usdcAmountInContract += _amount;
        } else if (_tokenAddress == busdAddress) {
            userToBusdTokenAmount[msg.sender] += _amount;
            busdAmountInContract += _amount;
        }
        userToTotalTokenToClaim[msg.sender] += tokenAmount;

        srxAmountSold += tokenAmount;
        srxAmountLeft -= tokenAmount;

        if (!userAlreadyTracked[msg.sender]) {
            userAlreadyTracked[msg.sender] = true;
            totalParticipants = totalParticipants + 1;
        }

        emit PresaleTokensBought(
            msg.sender,
            tokenAmount,
            tokenPrice,
            _tokenAddress
        );
    }

    //Presale sold early
    function soldEarly() external onlyOwner {
        // require(block.timestamp < endTime, "Presale: Presale is not ongoing");
        require(srxAmount <= srxAmountSold, "Presale: Presale is not sold out");

        endTime = block.timestamp;
        emit PresaleEndedEarly(endTime);
    }

    //withdrawl all tokens to owner
    function withdrawAllTokens() external onlyOwner {
        // require(block.timestamp > endTime, "Presale: Presale is still ongoing");
        require(
            IERC20(btcAddress).transfer(
                owner(),
                IERC20(btcAddress).balanceOf(address(this))
            ),
            "Presale: Transfer failed"
        );
        require(
            IERC20(bnbAddress).transfer(
                owner(),
                IERC20(bnbAddress).balanceOf(address(this))
            ),
            "Presale: Transfer failed"
        );
        require(
            IERC20(usdcAddress).transfer(
                owner(),
                IERC20(usdcAddress).balanceOf(address(this))
            ),
            "Presale: Transfer failed"
        );
        require(
            IERC20(busdAddress).transfer(
                owner(),
                IERC20(busdAddress).balanceOf(address(this))
            ),
            "Presale: Transfer failed"
        );

        emit TokensWithdrawn(owner());
    }

    //Burn all SRX that is left and not sold
    function burnAllSRX() external onlyOwner {
        // require(block.timestamp > endTime, "Presale: Presale is still ongoing");

        emit SRXBurned(srxAmountLeft);
        srxAmountLeft = 0;
    }
}