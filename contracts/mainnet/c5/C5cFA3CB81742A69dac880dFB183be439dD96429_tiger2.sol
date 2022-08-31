/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

/**
 * 老虎第二版
*/

pragma solidity ^0.5.4;

interface INFT721 {
  function transferFrom(address from,address to,uint256 tokenId) external;
  function balanceOf(address owner) external view returns (uint256 balance);
  function awardItem(address player, string calldata tokenURI) external returns (uint256 tokenId);
  function updateIsTransfer(bool _flag) external;
  function transferOwnership(address newOwner) external;
}


interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
}

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
       require(b <= a, errorMessage);
            return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
            return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
            return a % b;
    }
}

contract  tiger2 is Ownable{
  using SafeMath for uint;

  INFT721 public ntfAddress;
  IERC20 public httrAddress;
  IERC20 public httnAddress;
  uint256 public price = 100 * 10**18;

  constructor() public  {
    ntfAddress = INFT721(0x165766E68C4A0EbAB937360568ae5CcbF6789853);
    httrAddress = IERC20(0x71d25b8E00450be7A35ae997EE9E2BEdf4169Fd2);
    httnAddress = IERC20(0x1a3879d0aA7044F6cccd8bd3d4B785605ac699EB);

  }

  event MiningOrderEvent(address sender, uint amount, string uuid, uint256 tokenId);
  
  function buyMiningOrder(string memory uuid) public  {
    httrAddress.transferFrom(msg.sender,address(0x000000000000000000000000000000000000dEaD),price);
    uint256 tokenId = ntfAddress.awardItem(msg.sender,"");
    emit MiningOrderEvent(msg.sender, price, uuid, tokenId);
  }

  function updateIsTransfer(bool _flag) public onlyOwner {
    ntfAddress.updateIsTransfer(_flag);
  }

  function updatePrice(uint256 _price) public onlyOwner {
    price = _price;
  }


  function updateNFTOwner(address newOwner) public onlyOwner {
    ntfAddress.transferOwnership(newOwner);
  }


  function withdrawalHttn(address[] memory toAddress, uint[] memory amount) public onlyOwner {
    require(toAddress.length == amount.length,"Quantity error");
    for (uint i = 0; i < toAddress.length; i++) {
            httnAddress.transfer(toAddress[i], amount[i]);
        }
  }

  function createHu(address to) public onlyOwner returns  (uint tokenId) {
    tokenId = ntfAddress.awardItem(to,"");
  }

  
}