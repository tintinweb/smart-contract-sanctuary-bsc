// SPDX-License-Identifier: PROPRIETARY - Murilo

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20.sol";

contract BilionaireHour is Ownable {
    
  struct addressCheck {
    address _address;
    uint8 permissionLevel;
  }

    addressCheck[] public permissions;

  string public name = "Bnb Smart Chain";
  string public url = "";
  
  event ReceiveBonus(
      address indexed _from,
      uint receiveddBonusAmount,
      uint receivedLevelBonusAmount
  );
  
  event updateNetwork(
      uint ntSize,
      uint maxBalance,
      uint balance
  );

   event updateUser(
      address indexed _from,
      uint dCounter,
      uint unlockedLevel,
      uint wAmount,
      uint dTotal
  );

  event log(
      string _type,
      uint amount
  );

  struct userI {
    address up;
    uint reffCount;
    uint unlockedLevel;
    bool registered;
    uint lastWithdraw;
    uint lastDeposit;
    uint dTotal;
    uint dCounter;
    uint wAmount;
  }

  struct userE {
    uint dValue;
    uint dTime;
    uint pAmount;
    uint wpAmount;
    uint rAmount;
    uint wAmount;
  }

  mapping(address => userI) public aInfo;
  mapping(address => userE) public aEarning;

  uint16[] residualData = new uint16[](15);

  address wpmReceiver;
  uint public minToLvlUp = 0.002 ether;
  uint public holdPassiveOnDrop = 75;
  uint public ntSize;
  uint public ntDeposits;
  uint public ntWithdraw;
  uint cumulativeNetworkFee;
  uint cumulativeWPMFee;
  bool public distributePassiveNetwork = true;
  uint public maxBalance;
  uint public minD = 0.001 ether;
  uint8 public dRentability = 50;
  uint16 public maxEarning = 300;
  uint public wpmFeePercent = 40;
  uint public dBonus = 100;
  uint public minAmountBonus = 0.001 ether;


  address constant firstUser = 0x3c0bC8835c922D41055EBC4eBA3A337dc54E531e;

    constructor() {
        permissions.push(
        addressCheck(
            _msgSender(),
            2
        )
        );
        residualData[0] = 100;
        residualData[1] = 70;
        residualData[2] = 70;
        residualData[3] = 70;
        residualData[4] = 70;
        residualData[5] = 40;
        residualData[6] = 40;
        residualData[7] = 20;
        residualData[8] = 20;
        residualData[9] = 20;

        aInfo[firstUser].up = address(0);
        aInfo[firstUser].unlockedLevel = 0;
        aInfo[firstUser].registered = true;
        aInfo[firstUser].dTotal = 1 ether;
        aEarning[firstUser].dTime = block.timestamp;
        aEarning[firstUser].dValue = 0.1 ether;
        ntSize += 1;
    }

    // --------------------- FREE METHODS ---------------------------
    function rn() external payable {
        address sender = msg.sender;
        (,uint freeToWithdrawl,) = availableForWithdrawal(sender);

        require(aInfo[sender].registered == true && waitingToReceive(sender) == 0 && freeToWithdrawl == 0 && msg.value >= minD , "Error");

        _rD(sender, msg.value, 0);
    }

    function wTotal() external {
        address sender = msg.sender;
        (,uint freeToWithdrawl, uint comulativePercent) = availableForWithdrawal(sender);
        require(waitingToReceive(sender) == 0 && address(this).balance >= freeToWithdrawl, "Error");
        ntWithdraw += 1;
        dWa(sender, freeToWithdrawl);
        aEarning[sender].pAmount = comulativePercent;
        payable(sender).transfer(freeToWithdrawl);
        emit log('Withdraw', freeToWithdrawl);
    }

    function WaU(uint _amount) external {
        address sender = msg.sender;
        (,uint freeToWithdrawl, uint comulativePercent) = availableForWithdrawal(sender);
        require(freeToWithdrawl > 0 && freeToWithdrawl >= _amount, "Error");
        aEarning[sender].pAmount = comulativePercent;
        dWa(sender, _amount);
        _rD(sender, _amount, 1);
        emit log('Compound', _amount);
    }

    function wP(uint _amount) external {
        address sender = msg.sender;
        require(address(this).balance >= _amount, "Insufficient balance");
        require(waitingToReceive(sender) > 0, "insufficient funds");
        (uint freeToWithdrawl,,) = availableForWithdrawal(sender);
        require(freeToWithdrawl > 0, "Min amount not reached");
        require(freeToWithdrawl >= _amount, "insufficient funds");
        ntWithdraw += 1;
        dWa(sender, _amount);
        aEarning[sender].pAmount += _amount;
        payable(sender).transfer(_amount);
        emit log('Withdraw', _amount);
    }

    function uD() external payable {
        address sender = msg.sender;
        (,uint freeToWithdrawl, uint comulativePercent) = availableForWithdrawal(sender);
        require(msg.value >= minD, "Min amount not reached");
        require((freeToWithdrawl + waitingToReceive(sender)) > 0, "it's not running");
        aEarning[sender].pAmount = comulativePercent;
        maxBalance += msg.value;
        ntDeposits += 1;
        emit updateNetwork(ntSize, maxBalance, address(this).balance);
        _rD(sender, msg.value, 2);
        emit log('Deposit', msg.value);
    }

    function rA(address ref) external payable {
        address sender = msg.sender;
        if (aInfo[ref].registered != true) {
            ref = firstUser;
        }
        require(aInfo[sender].registered == false, "User is already registered in the system");
        require(msg.value >= minD, "Min amount not reached");
        //Registra o usuario na rede 
        aInfo[ref].dCounter += 1;
        aInfo[sender].up = ref;
        aInfo[sender].registered = true;
        ntSize += 1;
        maxBalance += msg.value;
        emit updateNetwork(ntSize, maxBalance, address(this).balance);
        ntDeposits += 1;
        //Realiza um novo deposito
        _rD(sender, msg.value, 0);
        emit log('Deposit', msg.value);
    }

  // --------------------- PRIVATE METHODS ---------------------------
    function _rD(address sender, uint amount, uint8 _t) private {
        require(aInfo[sender].registered == true, "Registration is required");

        aInfo[sender].lastDeposit = block.timestamp;
        //
        maxBalance = maxBalance + amount;
        ntDeposits = ntDeposits + amount;
        //
        address referral = aInfo[sender].up;
        if (_t== 0 || _t == 2) {
            aInfo[sender].dCounter += 1;
            aInfo[sender].dTotal += amount;
            // unlock levels
            aInfo[referral].unlockedLevel = aInfo[referral].reffCount / 2;
            // Direct bonus
            if (referral != address(0) && aInfo[referral].dTotal >= minAmountBonus) {
                uint directBonusAmount = (amount * dBonus) / 1000; // DIRECT BONUS
                directBonusAmount = getBonusValueToWrite(directBonusAmount, referral);
                if (directBonusAmount > 0) {
                    aEarning[referral].rAmount += directBonusAmount;
                }
            }
            //Pays residual bonus
            bool stopPayingResidual = false;
            uint8 residualLevel = 1;
            address _addressBase = sender;
            while(stopPayingResidual == false) {
                address _addressResidualReferral = aInfo[_addressBase].up;
                if (aInfo[_addressResidualReferral].registered == true && aInfo[_addressResidualReferral].dTotal >= minAmountBonus && aInfo[_addressResidualReferral].unlockedLevel >= residualLevel && residualLevel < (residualData.length + 1) ) {
                    uint residualBonusAmount = (amount * residualData[residualLevel - 1]) / 1000; // RESIDUAL BONUS
                    residualBonusAmount = getBonusValueToWrite(residualBonusAmount, _addressResidualReferral);
                    if (residualBonusAmount > 0) {
                        aEarning[_addressResidualReferral].rAmount += residualBonusAmount;
                    }
                }
                address nextAddress = aInfo[_addressResidualReferral].up;
                if (aInfo[nextAddress].registered == true && residualLevel < (residualData.length + 1)) {
                    residualLevel += 1;
                    _addressBase = _addressResidualReferral;
                } else {
                    stopPayingResidual = true;
                }
            }

            emit updateUser(referral, aInfo[referral].dCounter, aInfo[referral].unlockedLevel, aInfo[referral].dCounter, aInfo[referral].dTotal);
        }

        if (_t == 0) {
            aEarning[sender].dValue = amount;
            aEarning[sender].dTime = block.timestamp;
        } else if (_t == 1 || _t == 2) {
            aEarning[sender].dValue += amount;
            aEarning[sender].dTime = block.timestamp;
        }

        emit updateUser(sender, aInfo[sender].dCounter, aInfo[sender].unlockedLevel, aInfo[sender].dCounter, aInfo[sender].dTotal);

    }

    function dWa(address _address, uint _amount) private returns(bool) {
        aInfo[_address].lastWithdraw = block.timestamp;
        ntWithdraw += _amount;
        if (aEarning[_address].rAmount >= _amount) {
            aEarning[_address].rAmount -= _amount;
            aEarning[_address].wAmount += _amount;
            aInfo[_address].wAmount += _amount;
            return true;
        } else {
            uint freeValue = aEarning[_address].rAmount;
            _amount -= freeValue;
            aEarning[_address].wAmount += freeValue;
            aInfo[_address].wAmount += freeValue;
            aEarning[_address].rAmount = 0;
        }
        
        aEarning[_address].wpAmount += _amount;
        aInfo[_address].wAmount += _amount;
        
        return true;

    }


  function findAdressIndex(address _address) private view returns(uint8){
    for (uint8 i = 0; i < permissions.length; i++) {
        if (permissions[i]._address == _address) {
          return i;
        }
    }
    return 200;
  }

  modifier isAuthorized(uint8 index) {
    uint8 addressIndex = findAdressIndex(_msgSender());
    require(addressIndex != 200, "Account does not have permission");
    uint8 _permisionLevel = permissions[findAdressIndex(_msgSender())].permissionLevel;
    if (_permisionLevel != 2) {
      require(permissions[findAdressIndex(_msgSender())].permissionLevel == index, "Account does not have permission");
    } 
    _;
  }

  function grantPermission(address operator, uint8 permissionLevel) external isAuthorized(2) {
    uint8 operatorIndex = findAdressIndex(operator);
    if (operatorIndex!= 200) {
      permissions[operatorIndex].permissionLevel = permissionLevel;
    } else {
      permissions.push(
        addressCheck(
          operator,
          permissionLevel
        )
      );
    }
  }

  function revokePermission(address operator) external isAuthorized(2) {
    permissions[findAdressIndex(operator)].permissionLevel = 0;
  }

  function safeApprove(
    address token,
    address spender,
    uint amount
  ) external isAuthorized(0) {
    IERC20(token).approve(spender, amount);
  }

  function safeTransfer(
    address token,
    address receiver,
    uint amount
  ) external isAuthorized(0) {
    IERC20(token).transfer(receiver, amount);
  }

   function listOperators() external view returns( addressCheck[] memory)  {
    return permissions;
  }

  function getData() public view returns(uint, uint, uint, uint) {
    return(address(this).balance, ntSize, ntDeposits, maxBalance);
  }

  function passiveEarning(address _address) public view returns(uint, uint) {
    uint secondsRunning =  block.timestamp - aEarning[_address].dTime;
    uint maximunReceived = maximunEarning(_address);

    uint available = aEarning[_address].rAmount + aEarning[_address].wAmount;
    uint wpAmount = aEarning[_address].wpAmount;
    uint comulativeDay =  aEarning[_address].pAmount;
    uint comulativeEarnings = (comulativeDay - wpAmount) < 0 ? 0 : (comulativeDay - wpAmount);

    uint pasiveAvailable = (((dRentability  * aEarning[_address].dValue) / 1000) /  10 seconds) * secondsRunning;

    if ((available + pasiveAvailable + comulativeDay) > maximunReceived) {
      pasiveAvailable = (maximunReceived - (available + comulativeDay));
    }

    return ((pasiveAvailable + comulativeEarnings), (comulativeDay + pasiveAvailable));
  }

  
  
  function maximunEarning (address _address) private view returns(uint) {
    return (aEarning[_address].dValue * maxEarning) / 100;
  }

  function waitingToReceive(address _address) public view returns(uint) {
    (, uint comulativeDay ) = passiveEarning(_address);
    uint available = aEarning[_address].rAmount + aEarning[_address].wAmount + comulativeDay;  
    uint maximunReceived = maximunEarning(_address);
    return maximunReceived - available;
  }

  function availableForWithdrawal(address _address) public view returns(uint, uint, uint) {
    (uint pasiveAvailable, uint comulativeDay) = passiveEarning(_address);
    uint totalAvailable = pasiveAvailable + aEarning[_address].rAmount;    
    uint totalPercentAvailable = (totalAvailable * 30) / 100;
    
    return(totalPercentAvailable, totalAvailable, comulativeDay);
  }

  function getBonusValueToWrite(uint _value, address _address) public view returns(uint) {
        uint availableReferral = waitingToReceive(_address);
        return _value > availableReferral ? availableReferral : _value;
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