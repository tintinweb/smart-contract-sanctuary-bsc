//SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../libraries/Random.sol";

contract LuckyMoney is Ownable {
    struct UserInfo {
        string name;
        address addr;
    }

    uint256 public specialPrize;
    uint256 public firstPrize;
    uint256 public secondPrize;
    uint256 public thirdPrize;

    uint256 public nTicket;

    uint256 public MIN_TICKET_NUMBER = 4;
    address public operator;

    mapping (string => bool) private _isUsedName;
    mapping (address => uint256) public tickets;
    mapping (uint256 => UserInfo) public users;


    modifier onlyOperator() {
        require(operator == msg.sender || owner() == msg.sender, "operator: caller is not the operator");
        _;
    }
    function prizes() external view returns(uint256 third, uint256 second, uint256 first, uint256 special) {
        return (thirdPrize, secondPrize, firstPrize, specialPrize);
    }

    // test
    // function setNTicket(uint256 n) external onlyOwner {
    //     nTicket = n;
    //     specialPrize = 0;
    //     firstPrize = 0;
    //     secondPrize = 0;
    //     thirdPrize = 0;
    // }

    function register(string memory name) external {
        require(tickets[_msgSender()] == 0, "LuckyMoney: registered user");
        require(!_isUsedName[name], "LuckyMoney: nickname is used");
        nTicket = nTicket + 1;
        uint256 tid = nTicket;
        tickets[_msgSender()] = tid;
        users[tid] = UserInfo({
            name: name, 
            addr: _msgSender()
        });
        _isUsedName[name] = true;

        emit Registered(name, _msgSender(), tid);
    }

    function thirdPrizeDraw() external onlyOperator {
        uint256 seed;
        uint256 special = specialPrize;
        uint256 first = firstPrize;
        uint256 second = secondPrize;
        uint256 third = thirdPrize;
        uint256 _nTicket = nTicket;
        uint256 _n = (_nTicket % 10 == 0) ? _nTicket + 1 : _nTicket;

        require(_nTicket >= MIN_TICKET_NUMBER, "LuckyMoney: not enough ticket");

        for (uint256 i = 1; i < 100; i++) {
            seed = Random.computerSeed(i) / (i + 1) % _n + 1;
            if (!(seed == special || seed == first || seed == second)) {
                break;
            }
        }
        for (uint256 i = 0; i < 3; i++) {
            if (seed == special || seed == first || seed == second) seed = seed + 1;
        }

        thirdPrize = (seed > _nTicket) ? seed % _nTicket : seed;

        emit ThirdPrizeDrawed(third, thirdPrize);
    }

    function secondPrizeDraw() external onlyOperator {
        uint256 seed;
        uint256 special = specialPrize;
        uint256 first = firstPrize;
        uint256 second = secondPrize;
        uint256 third = thirdPrize;
        uint256 _nTicket = nTicket;
        uint256 _n = (_nTicket % 10 == 0) ? _nTicket + 1 : _nTicket;

        require(_nTicket >= MIN_TICKET_NUMBER, "LuckyMoney: not enough ticket");

        for (uint256 i = 1; i < 100; i++) {
            seed = Random.computerSeed(i) / (i + 1) % _n + 1;
            if (!(seed == special || seed == first || seed == third)) {
                break;
            }
        }
        for (uint256 i = 0; i < 3; i++) {
            if (seed == special || seed == first || seed == third) seed = seed + 1;
        }

        secondPrize = (seed > _nTicket) ? seed % _nTicket : seed;

        emit SecondPrizeDrawed(second, secondPrize);
    }

    function firstPrizeDraw() external onlyOperator {
        uint256 seed;
        uint256 special = specialPrize;
        uint256 first = firstPrize;
        uint256 second = secondPrize;
        uint256 third = thirdPrize;
        uint256 _nTicket = nTicket;
        uint256 _n = (_nTicket % 10 == 0) ? _nTicket + 1 : _nTicket;

        require(_nTicket >= MIN_TICKET_NUMBER, "LuckyMoney: not enough ticket");

        for (uint256 i = 1; i < 100; i++) {
            seed = Random.computerSeed(i) / (i + 1) % _n + 1;
            if (!(seed == special || seed == second || seed == third)) {
                break;
            }
        }
        for (uint256 i = 0; i < 3; i++) {
            if (seed == special || seed == second || seed == third) seed = seed + 1;
        }

        firstPrize = (seed > _nTicket) ? seed % _nTicket : seed;

        emit FirstPrizeDrawed(first, firstPrize);
    }

    function specialPrizeDraw() external onlyOperator {
        uint256 seed;
        uint256 special = specialPrize;
        uint256 first = firstPrize;
        uint256 second = secondPrize;
        uint256 third = thirdPrize;
        uint256 _nTicket = nTicket;
        uint256 _n = (_nTicket % 10 == 0) ? _nTicket + 1 : _nTicket;

        require(_nTicket >= MIN_TICKET_NUMBER, "LuckyMoney: not enough ticket");

        for (uint256 i = 1; i < 100; i++) {
            seed = Random.computerSeed(i) / (i + 1) % _n + 1;
            if (!(seed == first || seed == second || seed == third)) {
                break;
            }
        }
        for (uint256 i = 0; i < 3; i++) {
            if (seed == first || seed == second || seed == third) seed = seed + 1;
        }

        specialPrize = (seed > _nTicket) ? seed % _nTicket : seed;

        emit SpecialPrizeDrawed(special, specialPrize);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setMinTicketNumber(uint256 _num) external onlyOwner {
        MIN_TICKET_NUMBER = _num;
    }

    /*----------------------------EVENTS----------------------------*/

    event Registered(string indexed name, address indexed addr, uint256 ticket);
    event ThirdPrizeDrawed(uint256 oldPrize, uint256 newPrize);
    event SecondPrizeDrawed(uint256 oldPrize, uint256 newPrize);
    event FirstPrizeDrawed(uint256 oldPrize, uint256 newPrize);
    event SpecialPrizeDrawed(uint256 oldPrize, uint256 newPrize);

}

// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library Random {
    address constant BNB = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526; // mainnet 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
    address constant BTC = 0x5741306c21795FdCBb9b265Ea0255F499DFe515C; // mainnet 0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf
    address constant ETH = 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7; // mainnet 0x9ef1B8c0E4F7dc8bF5719Ea496883DC6401d5b2e

    uint256 constant PRECISION = 1e20;

    function getLatestPrice(address _addr) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(_addr);
        (, int256 _price, , , ) = priceFeed.latestRoundData();
        return uint256(_price);
    }

    function computerSeed(uint256 salt) internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp)
                    + block.gaslimit
                    + uint256(keccak256(abi.encodePacked(blockhash(block.number)))) / (block.timestamp)
                    + uint256(keccak256(abi.encodePacked(block.coinbase))) / (block.timestamp)
                    + (uint256(keccak256(abi.encodePacked(tx.origin)))) / (block.timestamp)
                    + block.number * block.timestamp
                )
            )
        );
        seed = (seed % PRECISION) * getLatestPrice(BNB);
        seed = (seed % PRECISION) * getLatestPrice(ETH);
        seed = (seed % PRECISION) * getLatestPrice(BTC);
        if (salt > 0) {
            seed = seed % PRECISION * salt;
        }
        return seed;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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