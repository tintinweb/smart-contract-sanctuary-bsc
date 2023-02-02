/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

 
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

  
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }


    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

pragma solidity 0.8.17;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.17;

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}


pragma solidity 0.8.17;
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract MetaGoldLaunchPad is Ownable {
    using SafeMath for uint256;

    address public directPaymentBNBAddressReceiver;
    uint256 public timeFrom = 0;
    uint256 public timeTo = 0;
    uint256 public BNBLimit = 1200 * 10 ** 18;
    uint256 public collectedBNB = 0;

    
    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


    event TransferReceived (
        address indexed buyer,
        uint256 amount
   );

    event Participate (
        address indexed buyer,
        uint256 amount
    );

    event TransferSentBack (
        address indexed buyer,
        uint256 amount
    );

    struct gParticipants {
        address participant;
        uint256 amountBNB;
        uint256 time;
    }
    struct Participant {
        uint256 amountBNB;
    }


    uint256 public participantCounter = 0;
    mapping(uint256 => gParticipants) public Participants;
    mapping(address => Participant) public participateData;



    constructor() {

    }

    
    receive() external payable {
        if( block.timestamp >= timeFrom && block.timestamp <= timeTo && collectedBNB.add(msg.value) <= BNBLimit) {
            address payable wallet1 = payable(directPaymentBNBAddressReceiver);
            wallet1.transfer(msg.value);
            participateData[msg.sender].amountBNB = participateData[msg.sender].amountBNB.add(msg.value);
            Participants[participantCounter] = gParticipants({
                participant: msg.sender,            
                amountBNB: msg.value,            
                time: block.timestamp            
            });
            participantCounter++;
            collectedBNB = collectedBNB.add(msg.value);
            
            emit TransferReceived(msg.sender, msg.value);
        }
        else{
            address payable wallet1 = payable(msg.sender);
            wallet1.transfer(msg.value);
            emit TransferSentBack(msg.sender, msg.value);
        }
  	}

        function buy() payable public {
            require( block.timestamp >= timeFrom && block.timestamp <= timeTo, "Bad time for buy!");
            require( collectedBNB.add(msg.value) <= BNBLimit, "Price is too much!");
            address payable wallet1 = payable(directPaymentBNBAddressReceiver);
            wallet1.transfer(msg.value);
            
            participateData[msg.sender].amountBNB = participateData[msg.sender].amountBNB.add(msg.value);
            
            Participants[participantCounter] = gParticipants({
                participant: msg.sender,            
                amountBNB: msg.value,            
                time: block.timestamp            
            });
            participantCounter++;
            collectedBNB = collectedBNB.add(msg.value);
            emit Participate(msg.sender, msg.value);
    }

    function getPD(address addr) external view returns (Participant memory) {
        return participateData[addr];
    }

    function getP(uint256 index) external view returns (gParticipants memory) {
        return Participants[index];
    }

    
    function recoverTokens(address tokenAddress, address receiver) external onlyOwner {
        IERC20(tokenAddress).approve(address(this), MAX_INT);
        IERC20(tokenAddress).transferFrom(
                            address(this),
                            receiver,
                            IERC20(tokenAddress).balanceOf(address(this))
        );
    }




    function setTimeFrom(uint256 time) public onlyOwner {
        timeFrom = time;
    }
    function setTimeTo(uint256 time) public onlyOwner {
        timeTo = time;
    }

    function setBNBLimit(uint256 limit) public onlyOwner {
        BNBLimit = limit * 10 ** 18;
    }

    function getRemainingTimeToStart() public view returns (uint256) {
        return block.timestamp.sub(timeFrom); 
    }

    function getRemainingTimeToFinish() public view returns (uint256) {
        return block.timestamp.sub(timeTo); 
    }
    
    function getContractBNBBalance() public view returns (uint256) {
        uint256 contractBNBBalance = address(this).balance;
        return contractBNBBalance; 
    }

    function sendBNBtoWallet(uint256 bnbBalance) public onlyOwner {
        transferOutBNB(payable(directPaymentBNBAddressReceiver), bnbBalance);
    }

    function sendAllBNBToWallet() public onlyOwner {
        transferOutBNB(payable(directPaymentBNBAddressReceiver), getContractBNBBalance());
    }

    function transferOutBNB(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

}