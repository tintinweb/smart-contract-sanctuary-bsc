// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/math/SafeMath.sol";



   interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
}



contract MetaWorld {
  using SafeMath for uint256;
  uint public landOptionsCount;
  uint public cropOptionsCount;

  uint public landCount;
  uint public cropCount;

  mapping (uint => _Land) public lands;
  mapping (uint => _Crop) public crops;
  
  address public contract_owner = 0x7bb35F76048127d52211feE800127036af6a2fBb;
  IERC20 mwToken = IERC20(0x1e3eB1a4C1830e7f4f231D2c7752dAE004980253);

   struct _LandOption {
    uint id;
    uint amount;
  }
  mapping (uint => _LandOption) public landOptions;

     struct _CropOption {
    uint id;
    string name;
    uint amount;
    uint harvestTime;
  }
  mapping (uint => _CropOption) public cropOptions;

   struct _Land {
    uint landId;
    uint id;
    address user;
    uint price;
    bool planted;
    bool sold;
  }

   struct _Crop {
    uint cropId;
    uint id;
    uint landId;
    address user;
    uint price;
    uint plantTime;
    bool cashed;
  }

    event Land(
    uint landId,
    uint id,
    address user,
    uint price,
    bool planted,
    bool sold
  );

  event LandSold(
  uint id,
      address user,
      uint price,
      bool sold
  );

    event Crop(
    uint cropId,
    uint id,
    uint landId,
    address user,
    uint price,
    uint plantTime,
    bool cashed
  );

    event CropCashed(
      uint id,
      address user,
      uint price,
      bool cashed
  );

  constructor() {
    
  }

    function addLandOption(uint  _amount) public  {
      require (msg.sender == contract_owner,'Should be the owner only');
      landOptionsCount++;
      landOptions[landOptionsCount] = _LandOption(landOptionsCount,_amount);
    
  }

    function buyLand(uint _id) public {
    _LandOption storage _landOption = landOptions[_id];
    uint256 balance = mwToken.balanceOf(msg.sender);
    uint256 allowanceAmount = mwToken.allowance(msg.sender,address(this));
    require(_landOption.id == _id, 'The offer must exist');
    require(_landOption.amount <= balance,'Balance not available');
    require(_landOption.amount <= allowanceAmount,'Allowed Amount not available');

    mwToken.transferFrom(msg.sender, address(this), _landOption.amount);
    landCount ++;
    lands[landCount] = _Land(landCount, _id, msg.sender, _landOption.amount, false, false);
    emit Land(landCount, _id, msg.sender, _landOption.amount, false, false);
  }

    function calculateFee(uint256 _num) public pure returns (uint256){
        uint256 onePercentofTokens = _num.mul(100).div(100 * 10 ** uint256(2));
        uint256 tenPercentOfTokens = onePercentofTokens.mul(10);
        return tenPercentOfTokens;
    }

  function sellLand(uint _id) public {
    _Land storage _land = lands[_id];
    uint256 balance = mwToken.balanceOf(address(this));
    
    require(_land.landId == _id, 'The land must exist');
    
    require(_land.planted == false, 'A planted land cannot be sold');
    require(_land.sold == false, 'A sold land cannot be reselled');

    uint256 extractFee = this.calculateFee(_land.price);

    require(_land.price - extractFee <= balance,'Balance not available');
    mwToken.approve(address(this), _land.price - extractFee);
    mwToken.transferFrom(address(this), msg.sender, _land.price - extractFee);
    _land.sold = true;
    emit LandSold( _id, msg.sender, _land.price, true);
  }

  function addCropOption(string memory _name, uint  _amount,uint harvestTime) public  {
      require (msg.sender == contract_owner,'Should be the owner only');
      cropOptionsCount++;
      cropOptions[cropOptionsCount] = _CropOption(cropOptionsCount, _name, _amount, harvestTime);
    
  }

  function plantCrop(uint _land, uint _crop) public {
     _CropOption storage _cropOption = cropOptions[_crop];
     _Land storage  _landCrop = lands[_land];
    uint256 balance = mwToken.balanceOf(msg.sender);
    uint256 allowanceAmount = mwToken.allowance(msg.sender,address(this));
    require(_landCrop.user == msg.sender, 'Must be land owner.');
    require(_cropOption.amount <= balance,'Balance not available');
    require(_landCrop.planted == false, 'A planted land cannot be replanted');
    require(_cropOption.amount <= allowanceAmount,'Allowed Amount not available');

    
    mwToken.transferFrom(msg.sender, address(this), _cropOption.amount);
    cropCount ++;
    _landCrop.planted = true;
    crops[cropCount] = _Crop(cropCount, _crop, _land, msg.sender, _cropOption.amount, block.timestamp, false);
    emit Crop(cropCount, _crop, _land, msg.sender, _cropOption.amount, block.timestamp, false);
    
  }

        function calculateProfit(uint256 _num,uint256 timePlanted, uint256 timeHarvest) public view returns (uint256){
        uint256 timeDiff = block.timestamp - timePlanted;
    if(timeDiff >= timeHarvest){
        return _num.mul(2);
    }else{

        uint256 result = ((_num  * timeDiff) / timeHarvest) / 1e4;
        return _num.add(result);

    }
        
    }

  function rewardCrop(uint _id) public {
     _Crop storage  _lCrop = crops[_id];
     _Land storage  _llandCrop = lands[_lCrop.landId];
     require(_lCrop.cropId == _id, 'Crop must exist.');
     require(_lCrop.user == msg.sender, 'Must be land owner.');
     require(_llandCrop.planted == true, 'An unplanted land cannot be claimed');

     _CropOption storage  _lcropOption = cropOptions[_lCrop.id];
    uint256 balance = mwToken.balanceOf(address(this));

    uint256 profit = this.calculateProfit(_lCrop.price, _lCrop.plantTime, _lcropOption.harvestTime);
    
    uint256 extractFee = this.calculateFee(profit);
    
    require(profit - extractFee  <= balance,'Balance not available');
    
    mwToken.approve(address(this), profit - extractFee);
    mwToken.transferFrom(address(this), msg.sender, profit - extractFee);
    _llandCrop.planted = false;
     _lCrop.cashed = true;
    emit CropCashed( _id, msg.sender, profit, true);
    
    
  }




     function withdrawWFunds() external   {
      require (msg.sender == contract_owner,'Should be the owner only');
      require (this.totalWBalance() > 0,'Balance not available');
     payable(msg.sender).transfer(this.totalWBalance());
   }

    function totalWBalance() external view returns(uint) {
     return address(this).balance;
   }



   function withdraw(uint amount,address token) public   returns(bool) {
        require (msg.sender == contract_owner,'Should be the owner only');
        IERC20 mwToken2 = IERC20(token);
        uint balance = mwToken2.balanceOf(address(this));
        require(amount <= balance,'Balance not available');
        mwToken2.approve(address(this), type(uint256).max);
        mwToken2.transferFrom(address(this), msg.sender, amount);
        return true;
    }


  function getBalanceContract(address token) public  view returns(uint){
        IERC20 mwToken2 = IERC20(token);
        return mwToken2.balanceOf(address(this));
    }


    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

  // Fallback: reverts if Ether is sent to this smart-contract by mistake
  fallback () external {
    revert();
  }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}