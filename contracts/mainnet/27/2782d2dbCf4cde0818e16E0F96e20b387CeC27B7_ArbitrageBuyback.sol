/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

//SPDX-License-Identifier: UNLICENSED


pragma solidity 0.7.6;
pragma abicoder v2;



library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
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
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IBEP20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
}

struct SaleEvent {
    uint startedAt;
    uint endedAt;
    uint256 bnbSaleAmount;
    uint256 bnbPrice;
    uint256 minSellBnbAmount;
    uint256 maxSellBnbAmount;
    IBEP20 coinContract;
    uint256 sold;
    uint nonce;
}

contract ArbitrageBuyback {
    address public owner;
    SaleEvent _event;
    uint _nonce;
    mapping (uint => mapping(address => uint256)) private _history;

    constructor() {
        owner = msg.sender;
        _nonce = 1;
    }

    //options | 1652972262,1682972262,100,1,1,10,0xE3Ca443c9fd7AF40A2B5a95d43207E763e56005F
    function _createSaleEvent(
        uint startedAt,
        uint endedAt,
        uint256 bnbSaleAmount,
        uint256 bnbPrice,
        uint256 minSellBnbAmount,
        uint256 maxSellBnbAmount,
        address coinContractAddress
    ) private returns (SaleEvent memory) {
        require(msg.sender == owner, "Only owner can create sale event");
        require(startedAt < endedAt, "Event should be end after than start");
        require(minSellBnbAmount < maxSellBnbAmount, "min sell bnb amount should be less than max sell bnb amount");
        require(coinContractAddress != address(0), "Coin contract address should be specified");
        require(bnbPrice > 0, "BNB price cannot be less or equal zero");
        require(bnbSaleAmount > 0, "BNB Sales Amount should be greater than zero");
        require(_contractBalance() >= bnbSaleAmount, "Deposit contract before create event");

        _event = SaleEvent({
            startedAt: startedAt,
            endedAt: endedAt,
            bnbSaleAmount: bnbSaleAmount,
            bnbPrice: bnbPrice,
            minSellBnbAmount: minSellBnbAmount,
            maxSellBnbAmount: maxSellBnbAmount,
            coinContract: IBEP20(coinContractAddress),
            sold: 0,
            nonce: _nonce
        });

        _nonce += 1;

        return _event;
    }

   


    function _buyByAddress(uint nonce, address addr) private view returns (uint256) {
        return _history[nonce][addr];
    }

    function _contractBalance() private view returns (uint256 amount) {
        return address(this).balance;
    }

    function _coinContractBalance() private view returns (uint256) {
        if(address(_event.coinContract) == address(0)) {
            return 0;
        }

        return _event.coinContract.balanceOf(address(this));
    }

    function _eventClosed() private view returns (bool) {
        return block.timestamp > _event.endedAt;
    }

    function createSaleEvent(
        uint startedAt,
        uint endedAt,
        uint256 bnbSalesAmount,
        uint256 bnbPrice,
        uint256 minSellBnbAmount,
        uint256 maxSellBnbAmount,
        address coinContractAddress
    ) public returns (SaleEvent memory) {
        return _createSaleEvent(
            startedAt,
            endedAt,
            bnbSalesAmount,
            bnbPrice,
            minSellBnbAmount,
            maxSellBnbAmount,
            coinContractAddress
        );
    }

    function deposit() public payable returns (uint256 amount) {
        require(msg.sender == owner, "Only owner can deposit smart contract");
        return msg.value;
    }

    function withdraw() public {
        require(_eventClosed(), "Event should be closed by time");
        address payable _to = payable(owner);
        _to.transfer(address(this).balance);
    }

    function withdrawCoin() public {
        if(address(_event.coinContract) == address(0)) {
            return;
        }

        _event.coinContract.transfer(owner, _coinContractBalance());
    }

    function buyByAddress(address addr) public view returns (uint256) {
        return _buyByAddress(_nonce, addr);
    }

    function contractBalance() public view returns (uint256 amount) {
        return _contractBalance();
    }

    function coinContractBalance() public view returns (uint256 amount) {
        return _coinContractBalance();
    }

    function currentSaleEvent() public view returns (SaleEvent memory saleEvent) {
        return _event;
    }

    function changeOwner(address newOwner) public {
        require(msg.sender == owner, "You must be owner");
        owner = newOwner;
    }

   /**
        Required call BEP20 approve(contractAddr) before call this method
    */
    function swap(uint256 sellAmount) public payable returns (uint256 amount) {
        uint256 allowance = _event.coinContract.allowance(msg.sender, address(this));

        require(allowance >= sellAmount, "Approve coins before swap");

        uint256 amountInBnb = SafeMath.mul(sellAmount, _event.bnbPrice);
        uint256 soldBnbAmountToAddress = _buyByAddress(_nonce, msg.sender);

        require(_event.maxSellBnbAmount - soldBnbAmountToAddress >= amountInBnb, "Out of available limits");
        require(amountInBnb >= _event.minSellBnbAmount, "Amount in bnb should be greater than min");
        require(amountInBnb <= _event.maxSellBnbAmount, "Amount in bnb should be less than max");
        require(address(_event.coinContract) != address(0), "Coin contract not specified");
        require(_event.startedAt <= block.timestamp, "Event is not started");
        require(_event.endedAt >= block.timestamp, "Event is closed");
        require(_event.bnbSaleAmount > _event.sold, "Sold out");

        bool success = _event.coinContract.transferFrom(msg.sender, address(this), sellAmount);

        if(!success) {
            revert("Not transfered coins");
        }

        address payable recipient = payable(msg.sender);
        recipient.transfer(amountInBnb);

        _event.sold = SafeMath.add(amountInBnb, _event.sold);
        _history[_nonce][msg.sender] += amountInBnb;

        return amountInBnb;
    }
}