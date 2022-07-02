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

interface IUniswapV2Pair {
  function token0() external view returns (address);
    function token1() external view returns (address);
function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}



contract MetaWorld {
  using SafeMath for uint256;
  uint public landOptionsCount;
  uint public cropOptionsCount;

  uint public landCount;
  uint public cropCount;

  mapping (uint => _Land) public lands;
  mapping (uint => _Crop) public crops;
  
  address public contract_owner;
  IERC20 mwToken = IERC20(0x1e3eB1a4C1830e7f4f231D2c7752dAE004980253);
  IERC20 busdToken = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
  address pairAddress = address(0xa7A7d5eE3Faa9235Dff30370098dF0959f1BdFc0);
   struct _LandOption {
    uint id;
    uint amount;
    uint fee;
    bool busd;
    bool sellable;
  }
  mapping (uint => _LandOption) public landOptions;

     struct _CropOption {
    uint id;
    uint amount;
    uint harvestTime;
    uint profit;
    uint maxHarvestDays;
    uint fee;
    bool busd;
  }
  mapping (uint => _CropOption) public cropOptions;

   struct _Land {
    uint landId;
    uint id;
    uint activeCrop;
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
     contract_owner = msg.sender;
  }

    function getTokenPrice(uint256 amount) public view  returns(uint256)
   {
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    IERC20 token0 = IERC20(pair.token0());
   
   
    (uint256 Res0, uint256 Res1,) = pair.getReserves();

    // decimals
    uint256 res0 = Res1*(10**token0.decimals());
    return((amount*res0)/Res0); // return amount of token0 needed to buy token1
   }

    function addLandOption(uint  _amount, uint fee ,bool busd, bool sellable) public  {
     
      require (msg.sender == contract_owner,'Should be the owner only');
      landOptionsCount++;
      landOptions[landOptionsCount] = _LandOption(landOptionsCount,_amount,fee, busd,sellable);
    
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
    lands[landCount] = _Land(landCount, _id, 0, msg.sender, _landOption.amount, false, false);
    emit Land(landCount, _id, msg.sender, _landOption.amount, false, false);
  }

    function calculateFee(uint256 _num, uint256 fee) public pure returns (uint256){
        uint256 onePercentofTokens = _num.mul(100).div(100 * 10 ** uint256(2));
        uint256 tenPercentOfTokens = onePercentofTokens.mul(fee);
        return tenPercentOfTokens;
    }

      function sellLandBUSD(uint _id) public {
    _Land storage _land = lands[_id];
    _LandOption storage _landOption = landOptions[_land.id];
    
    uint256 balance = busdToken.balanceOf(address(this));

    require(_landOption.id == _land.id, 'The land option must exist');
    require(_landOption.busd == true, 'The land option doesnot have BUSD enabled');
    require(_landOption.sellable == true, 'The land option doesnot have Sellable enabled'); 
    
    
    require(_land.landId == _id, 'The land must exist');
    
    require(_land.planted == false, 'A planted land cannot be sold');
    require(_land.sold == false, 'A sold land cannot be reselled');

    uint256 extractFee = this.calculateFee(_land.price, _landOption.fee);
    uint256 busdbal = this.getTokenPrice(_land.price - extractFee);
    require(busdbal <= balance,'Balance not available');
    busdToken.approve(address(this), busdbal);
    busdToken.transferFrom(address(this), msg.sender, busdbal);
    _land.sold = true;
    emit LandSold( _id, msg.sender, _land.price, true);
  }

    function rewardCropBUSD(uint _id) public {
     _Crop storage  _lbCrop = crops[_id];
     _Land storage  _lblandCrop = lands[_lbCrop.landId];
     require(_lbCrop.cropId == _id, 'Crop must exist.');
     require(_lbCrop.user == msg.sender, 'Must be land owner.');
     require(_lblandCrop.planted == true, 'An unplanted land cannot be claimed');

     _CropOption storage  _lbcropOption = cropOptions[_lbCrop.id];

     require(_lbcropOption.id == _lbCrop.id, 'The land option must exist');
    require(_lbcropOption.busd == true, 'The crop option doesnot have BUSD enabled');

    uint256 balance = busdToken.balanceOf(address(this));

    uint256 profit = this.calculateProfit(_lbCrop.price, _lbCrop.plantTime, _lbcropOption.harvestTime,_lbcropOption.maxHarvestDays,_lbcropOption.profit);
    
    uint256 extractFee = this.calculateFee(profit, _lbcropOption.fee);
    uint256 busdbal = this.getTokenPrice(profit - extractFee);
    require(busdbal  <= balance,'Balance not available');
    
    busdToken.approve(address(this), busdbal);
    busdToken.transferFrom(address(this), msg.sender, busdbal);
    _lblandCrop.planted = false;
    _lblandCrop.activeCrop = 0;
     _lbCrop.cashed = true;
    emit CropCashed( _id, msg.sender, profit, true);
    
    
  }

  function sellLand(uint _id) public {
    _Land storage _land = lands[_id];
     _LandOption storage _lMMandOption = landOptions[_land.id];
    uint256 balance = mwToken.balanceOf(address(this));
    
    require(_land.landId == _id, 'The land must exist');
    require(_lMMandOption.sellable == true, 'The land option doesnot have Sellable enabled'); 
    require(_land.planted == false, 'A planted land cannot be sold');
    require(_land.sold == false, 'A sold land cannot be reselled');

    uint256 extractFee = this.calculateFee(_land.price, _lMMandOption.fee);

    require(_land.price - extractFee <= balance,'Balance not available');
    mwToken.approve(address(this), _land.price - extractFee);
    mwToken.transferFrom(address(this), msg.sender, _land.price - extractFee);
    _land.sold = true;
    emit LandSold( _id, msg.sender, _land.price, true);
  }

  function addCropOption(uint  _amount,uint harvestTime, uint profit, uint maxHarvestDays, uint fee,bool busd) public  {
      require (msg.sender == contract_owner,'Should be the owner only');
      cropOptionsCount++;
      cropOptions[cropOptionsCount] = _CropOption(cropOptionsCount, _amount, harvestTime, profit, maxHarvestDays, fee,busd);
    
  }

  function changeCropOption(uint _crop,  uint  _amount,uint harvestTime, uint profit, uint maxHarvestDays, uint fee,bool busd) public  {
    _CropOption storage _cropOptionU = cropOptions[_crop];
      require(_cropOptionU.id <= _crop,'Crop Option not available');
      require (msg.sender == contract_owner,'Should be the owner only');
      _cropOptionU.amount = _amount;
      _cropOptionU.harvestTime = harvestTime;
       _cropOptionU.profit = profit;
       _cropOptionU.maxHarvestDays = maxHarvestDays;
       _cropOptionU.fee = fee;
       _cropOptionU.busd = busd;
  }

  function changelandOption(uint _id, uint  _amount, uint fee, bool busd, bool sellable) public  {
     _LandOption storage _landOptionU = landOptions[_id];
      require(_landOptionU.id == _id, 'The offer must exist');
      require (msg.sender == contract_owner,'Should be the owner only');
      _landOptionU.amount = _amount;
      _landOptionU.fee = fee;
      _landOptionU.busd = busd;
      _landOptionU.sellable = sellable;
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
    _landCrop.activeCrop = cropCount;
    crops[cropCount] = _Crop(cropCount, _crop, _land, msg.sender, _cropOption.amount, block.timestamp, false);
    emit Crop(cropCount, _crop, _land, msg.sender, _cropOption.amount, block.timestamp, false);
    
  }

        function calculateProfit(uint256 _num,uint256 timePlanted, uint256 timeHarvest,uint256 maxHarvestDays, uint256 profit) public view returns (uint256){
        uint256 timeDiff = block.timestamp - timePlanted;
        uint256 daysC = timeDiff / 60 / 60 / 24;
        uint256 daysH = timeHarvest / 60 / 60 / 24;
    if(daysC >= maxHarvestDays){
        return _num + ((_num  * profit) / 100) * (maxHarvestDays / daysH);
    }else{
         uint256 result = ((_num  * timeDiff) / timeHarvest) ;
        return _num + ((result  * profit) / 100);
  
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

    uint256 profit = this.calculateProfit(_lCrop.price, _lCrop.plantTime, _lcropOption.harvestTime,_lcropOption.maxHarvestDays,_lcropOption.profit);
    
    uint256 extractFee = this.calculateFee(profit, _lcropOption.fee);
    
    require(profit - extractFee  <= balance,'Balance not available');
    
    mwToken.approve(address(this), profit - extractFee);
    mwToken.transferFrom(address(this), msg.sender, profit - extractFee);
    _llandCrop.planted = false;
    _llandCrop.activeCrop = 0;
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

  function tranferOwnerShip(address new_owner) public   {
      require (msg.sender == contract_owner,'Should be the owner only');
      contract_owner = new_owner;
   }

    function migrateCrop(uint _crop, uint _land,address owner, uint plantTime, bool cashed ) public {
      require (msg.sender == contract_owner,'Should be the owner only');
      _CropOption storage _cropOptionM = cropOptions[_crop];
      cropCount ++;
      crops[cropCount] = _Crop(cropCount, _crop, _land, owner, _cropOptionM.amount, plantTime, cashed);
   
  }

      function migrateLand(uint _id, uint activeCrop,address owner, bool planted, bool sold ) public {
        require (msg.sender == contract_owner,'Should be the owner only');
        _LandOption storage _landOptionM = landOptions[_id];
        require(_landOptionM.id == _id, 'The offer must exist');
        landCount ++;
        lands[landCount] = _Land(landCount, _id, activeCrop, owner, _landOptionM.amount, planted, sold);
  }

        function updateLand(uint landId,uint _id, uint activeCrop,address owner, bool planted, bool sold ) public {
        require (msg.sender == contract_owner,'Should be the owner only');
        _Land storage _landM = lands[landId];
        _LandOption storage _landOptionMM = landOptions[_id];
        require(_landM.landId == landId, 'The land must exist');
        _landM.user = owner;
        _landM.id = _id;
        _landM.activeCrop = activeCrop;
        _landM.price = _landOptionMM.amount;
        _landM.planted = planted;
        _landM.sold = sold; 
  }
   function updateCrop(uint cropId,uint _crop, uint _land,address owner, uint plantTime, bool cashed ) public {
      require (msg.sender == contract_owner,'Should be the owner only');
      _Crop storage _cropM = crops[cropId];
      _CropOption storage _cropOptionMM = cropOptions[_crop];
       require(_cropM.cropId == cropId, 'The crop must exist');
       _cropM.id = _crop;
       _cropM.landId = _land;
       _cropM.user = owner;
       _cropM.price = _cropOptionMM.amount;
       _cropM.plantTime = plantTime;
       _cropM.cashed = cashed;
   
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