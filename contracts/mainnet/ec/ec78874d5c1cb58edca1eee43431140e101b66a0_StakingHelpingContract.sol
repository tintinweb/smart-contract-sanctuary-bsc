/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-02
*/

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol
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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

// File: newStaking.sol


pragma solidity 0.8.17;

interface PreSale {

    function getTotalBuyers() external view returns(uint256);
    function getTokenBuyersInfo(uint256 _tokenBuyer) external view returns(address, uint256);
    function getTotalSoldTokens() external view returns(uint256);
}


interface IBEP20 {
    
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function isWhiteListed(address _address) external view returns(bool);
}

interface StakingContract {

    function players(address _playerAddress) external view returns(uint256 walletLimit,
                                uint256 totalArenaTokens);
    
    function treasuryWallet() external view returns(address);
    function busdWallet() external view returns(address);
    function areenaInCirculation() external view returns(uint256);
    function totalAreena() external view returns(uint256);
    function BusdInTreasury() external view returns (uint256);
    function setTotalAreena(uint256 _totalAreena) external;
    function setAreenaInCirculation(uint256 _areenaInCirculation) external;
    function updatePalyerWalletLimit(address _playerAddress,uint256 _walletLimit) external;
    function updatePalyerGenAmountPlusBonus(address _playerAddress,uint256 _genAmount) external;
    function minusArenaAmount(address _playerAddress,uint256 _arenaTokens) external;    
}


interface PancakeRouter {

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

contract StakingHelpingContract is Ownable {

    using SafeMath for uint256;

    PreSale public preSale;
    IBEP20 public genToken;
    IBEP20 public busdToken;
    PancakeRouter public pancakeRouter;
    StakingContract public stakingContract;

    bool public saleEnabled;
    uint256 public saleEndTime;
    uint256 public saleStartTime;
    uint256 public genBonusPercentage;
    address mainStakingContractAddress;

    mapping(address => uint256) public areenaLastTransactionForGen;

    address public preSaleWallet = 0x6783db6859A1E971d07035fC2dA916b94c314E51;


    event SellThroughDashboard(bool bonusEnabled, uint256 _amount, uint256 _bonusAmount, uint256 _time);
    event SellThroughAreena(uint256 areenaPrice, uint256 _totalAmountOfGen, uint256 _AddedInCastle);
    event SendInPreSale(address sendFrom, uint256 _tokenAmount, address _receiverAddress);
    event SendDirectlyToCastle(address sendFrom, uint256 _tokenAmount, address _receiverAddress);

    constructor(address _genToken, address _busdToken, address _preSale, 
                address _pancakeRouter, address _stakingContract, address _mainStakingContractAddress) {
        
        genToken = IBEP20(_genToken);
        busdToken = IBEP20(_busdToken);
        preSale = PreSale(_preSale);
        stakingContract = StakingContract(_stakingContract);
        pancakeRouter = PancakeRouter(_pancakeRouter);
        mainStakingContractAddress = _mainStakingContractAddress;
        
    }



    //============================ PreSale Info ==========================

    function sendPreSaleTokens() external {

        uint256 length  = preSale.getTotalBuyers();

        for(uint i = 0; i<= length; i++){

            (address _playerAddress, uint256 _noOfTokens) = preSale.getTokenBuyersInfo(i);
            stakingContract.updatePalyerGenAmountPlusBonus(_playerAddress, _noOfTokens);
        }

        uint256 totalAmountToSend = preSale.getTotalSoldTokens();

        require(msg.sender == preSaleWallet, 
                "Only PreSale Wallet can send Presale tokens.");

        require(genToken.balanceOf(preSaleWallet) >= totalAmountToSend, 
                "Owner did not have sufficent amount of Gen tokens in his wallet to send.");
            
        uint256 allowedAmount = genToken.allowance(preSaleWallet, address(this));
            
        require(allowedAmount >= totalAmountToSend, 
                "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

        genToken.transferFrom(preSaleWallet, mainStakingContractAddress, totalAmountToSend); 

        emit SendInPreSale(preSaleWallet, totalAmountToSend, mainStakingContractAddress);
    }

    function setPreSaleWallet(address _preSaleWallet) onlyOwner external {
        preSaleWallet = _preSaleWallet;
    }


//================================Areena Functions ============================================


    function sellAreenaByGen(uint256 _areenaAmount) external {
       
        uint256 _realAreenaAmount = _areenaAmount.mul(1e18);

        (uint256 _oldWalletLimit,uint256 _oldTotalArenaTokens) = stakingContract.players(msg.sender);

        require(_oldTotalArenaTokens >= _realAreenaAmount,
            "You do not have sufficient amount of arena tokens to sell.");

        if (_oldWalletLimit == 0) {
            stakingContract.updatePalyerWalletLimit(msg.sender, 1 * 1e18);
        }

        require(_realAreenaAmount < _oldWalletLimit,"Please Buy Areena Boster To get All of your reward.");
        
        require(block.timestamp > areenaLastTransactionForGen[msg.sender],
            "You canot sell areena token again before 1 hours.");

        uint256 minSlipage = calculateMinSlippage(basePriceForGenSell);
        uint256 maxSlipage = calculateMaxSlippage(basePriceForGenSell);
           
        uint256 _genPrice = getGenPrice();
            
        if(_genPrice > (basePriceForGenSell - maxSlipage) && _genPrice < (basePriceForGenSell - minSlipage)){
            
            (uint256 areenaPriceInBusd, uint256 _totalAmountOfGen) =  calculateTotalgenthroughAreenaWithoutSlippage(_areenaAmount); //_areenaAmount in uint value
            uint256 amountAdd = calculateSellTax(_totalAmountOfGen);

            amountAdd = _totalAmountOfGen - amountAdd;

            require(genToken.balanceOf(stakingContract.treasuryWallet()) >= _totalAmountOfGen, 
                    "Owner did not have sufficent amount of Gen tokens in his wallet to send.");
                
            uint256 allowedAmount = genToken.allowance(stakingContract.treasuryWallet(), address(this));
                
            require(allowedAmount >= _totalAmountOfGen, 
                    "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

            genToken.transferFrom(stakingContract.treasuryWallet(), mainStakingContractAddress, _totalAmountOfGen);
            stakingContract.updatePalyerGenAmountPlusBonus(msg.sender, amountAdd);
        
            uint256 areenaInCirculation = stakingContract.areenaInCirculation();
            areenaInCirculation -= _realAreenaAmount;
            stakingContract.setAreenaInCirculation(areenaInCirculation);
            
            stakingContract.minusArenaAmount(msg.sender,_realAreenaAmount);

            uint256 totalAreena = stakingContract.totalAreena();
            totalAreena += _realAreenaAmount;
            stakingContract.setTotalAreena(totalAreena);

            areenaLastTransactionForGen[msg.sender] = block.timestamp + 1 hours; //////////hours////////////////

            emit SellThroughAreena(areenaPriceInBusd,_totalAmountOfGen, amountAdd);           

        }else{
        
            require(_genPrice > (basePriceForGenSell - maxSlipage) && _genPrice < (basePriceForGenSell + minSlipage), 
                "To get better price Please Buy gen from pancake swap.");

            (uint256 areenaPriceInBusd, uint256 _totalAmountOfGen) =  calculateTotalgenthroughAreena(_areenaAmount);
            
            uint256 amountAdd = calculateSellTax(_totalAmountOfGen);

            amountAdd = _totalAmountOfGen - amountAdd; 

            require(genToken.balanceOf(stakingContract.treasuryWallet()) >= _totalAmountOfGen, 
                    "Owner did not have sufficent amount of Gen tokens in his wallet to send.");
                
            uint256 allowedAmount = genToken.allowance(stakingContract.treasuryWallet(), address(this));
                
            require(allowedAmount >= _totalAmountOfGen, 
                    "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

            genToken.transferFrom(stakingContract.treasuryWallet(), mainStakingContractAddress, _totalAmountOfGen);
            stakingContract.updatePalyerGenAmountPlusBonus(msg.sender, amountAdd);
        
            uint256 areenaInCirculation = stakingContract.areenaInCirculation();
            areenaInCirculation -= _realAreenaAmount;
            stakingContract.setAreenaInCirculation(areenaInCirculation);

            stakingContract.minusArenaAmount(msg.sender,_realAreenaAmount);
            
            uint256 totalAreena = stakingContract.totalAreena();
            totalAreena += _realAreenaAmount;
            stakingContract.setTotalAreena(totalAreena);

            areenaLastTransactionForGen[msg.sender] = block.timestamp + 1 hours; //////////hours////////////////

            emit SellThroughAreena(areenaPriceInBusd,_totalAmountOfGen, amountAdd);
        }
    }

    // _areenaAmount will be in intiger value.
    function calculateTotalgenthroughAreena(uint256 _areenaAmount) public view returns(uint256 _busdAmount, uint256 amountOfGen) {
        
        _busdAmount = calculateAreenaPriceInBusdForGen(_areenaAmount); //_busdAmount will be in wei value.
        amountOfGen = getGenAmount(_busdAmount); //amountOfGen will be in wei value.
        
        return (_busdAmount,amountOfGen);
    }

    //_areenaAmount will be in intiger value.
    function calculateTotalgenthroughAreenaWithoutSlippage(uint256 _areenaAmount) public view returns(uint256 _busdAmount, uint256 amountOfGen) {
        
        _busdAmount = calculateAreenaPriceInBusdForGen(_areenaAmount); //_busdAmount will be in wei value.
        amountOfGen = (_busdAmount.mul(1e18)).div(basePriceForGenSell);   // amountOfGen will be in wei 
                                                                        
        return (_busdAmount,amountOfGen);
    }

     /* uint256 _areenaAmount will be in intiger value */
    function calculateAreenaPriceInBusdForGen(uint256 _areenaAmount) public view returns (uint256){
        
        uint256 _busdWalletBalance = stakingContract.BusdInTreasury();
        uint256 _areenaValue = _busdWalletBalance.div(10000);

        return _areenaAmount.mul(_areenaValue);
    }

//================================Gen Price calculation ============================================


    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public GEN = 0x66807bFF998aAd2bD4cDDFFA36B12dF25CC754B1;

    uint256 public basePriceForGenSell = 10*1e18;
    address[] public pathTogetGen = [BUSD,GEN];
    address[] public pathTogetGenPrice = [GEN,BUSD];

    function getGenAmount(uint256 _busdAmount) public view returns(uint256){
        
        uint256[] memory _genAmount;
        _genAmount = pancakeRouter.getAmountsOut(_busdAmount,pathTogetGen);

        return _genAmount[1];
    } 

    // how much busd aginst one gen.
    function getGenPrice() public view returns(uint256){
        
        uint256 _genAmount = 1*1e18; 
        uint256[] memory _genPrice;
        
        _genPrice = pancakeRouter.getAmountsOut(_genAmount,pathTogetGenPrice);

        return _genPrice[1];
    }

    uint256 public minSlippage = 500;
    uint256 public  maxSlippage = 1500;

    function calculateMinSlippage(uint256 _amount) public view returns (uint256){
        return _amount.mul(minSlippage).div(10000);
    }

    function calculateMaxSlippage(uint256 _amount) public view returns (uint256){
        return _amount.mul(maxSlippage).div(10000);
    }


    function setbasePrice(uint256 _basePrice) external onlyOwner {
        basePriceForGenSell = _basePrice;
    }

    function setMinSlippage(uint256 _minSlippage) external onlyOwner {
        minSlippage = _minSlippage;
    }

    function setMaxSlippage(uint256 _maxSlippage) external onlyOwner {
        maxSlippage = _maxSlippage;
    }


//=====================================Sell Gen Through The Dashboard ====================================



    function sellGenThroughDashboard(uint256 _busdAmount) public {

        uint256 _realBusdAmount = _busdAmount.mul(1e18);

        require(busdToken.balanceOf(msg.sender) >= _realBusdAmount,
            "You do not have sufficent amount of busd to buy gen token.");

        uint256 minSlipage = calculateMinSlippage(basePriceForGenSell);
        uint256 maxSlipage = calculateMaxSlippage(basePriceForGenSell);
           
        uint256 _genPrice = getGenPrice();
            
        if(_genPrice > (basePriceForGenSell - maxSlipage) && _genPrice < (basePriceForGenSell - minSlipage)){

            uint256 totalGenAmount = (_realBusdAmount.mul(1e18)).div(basePriceForGenSell); 

            uint256 amountAdd = calculateSellTax(totalGenAmount);
            amountAdd = totalGenAmount - amountAdd;
  
            require(genToken.balanceOf(stakingContract.treasuryWallet()) >= totalGenAmount,
                "treasury wallet didnt have sufficient amount of gen token to sell right now.");

            if (saleEnabled && (block.timestamp > saleEndTime)) {
                saleEnabled = false;
            }

            bool checkWhiteListed = genToken.isWhiteListed(msg.sender);

            if (saleEnabled && (block.timestamp < saleEndTime)) {
                
                uint256 bonusAmount = calculateGenBonusPercentage(totalGenAmount);

                busdToken.transferFrom(msg.sender, stakingContract.busdWallet(), _realBusdAmount);
                
                uint256 allowedAmount = genToken.allowance(stakingContract.treasuryWallet(), address(this));
                
                require(allowedAmount >= totalGenAmount, 
                    "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

                genToken.transferFrom(stakingContract.treasuryWallet(),mainStakingContractAddress,totalGenAmount);

                if(checkWhiteListed == true){

                    stakingContract.updatePalyerGenAmountPlusBonus(msg.sender, totalGenAmount.add(bonusAmount));
                    emit SellThroughDashboard(true, totalGenAmount, bonusAmount, block.timestamp);
                }else{

                    stakingContract.updatePalyerGenAmountPlusBonus(msg.sender, amountAdd.add(bonusAmount));
                    emit SellThroughDashboard(true, amountAdd, bonusAmount, block.timestamp);
                }

                
            } else {

                busdToken.transferFrom(msg.sender, stakingContract.busdWallet(), _realBusdAmount);

                uint256 allowedAmount = genToken.allowance(stakingContract.treasuryWallet(), address(this));
                
                require(allowedAmount >= totalGenAmount, 
                    "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

                genToken.transferFrom(stakingContract.treasuryWallet(),mainStakingContractAddress,totalGenAmount);

                if(checkWhiteListed == true){

                    stakingContract.updatePalyerGenAmountPlusBonus(msg.sender,totalGenAmount);
                    emit SellThroughDashboard(false, totalGenAmount, 0, block.timestamp);
                }
                else{

                     stakingContract.updatePalyerGenAmountPlusBonus(msg.sender,amountAdd);
                    emit SellThroughDashboard(false, amountAdd, 0, block.timestamp);
                }

            }            

        }else{
            
            require(_genPrice > (basePriceForGenSell - maxSlipage) && _genPrice < (basePriceForGenSell + minSlipage), 
                "To get better price Please Buy gen from pancake swap.");

            uint256 totalGenAmount = getGenAmount(_realBusdAmount); 

            uint256 amountAdd = calculateSellTax(totalGenAmount);
            amountAdd = totalGenAmount - amountAdd;

            require(genToken.balanceOf(stakingContract.treasuryWallet()) >= totalGenAmount,
                "treasury wallet didnt have sufficient amount of gen token to sell right now.");

            if (saleEnabled && (block.timestamp > saleEndTime)) {
                saleEnabled = false;
            }

            bool checkWhiteListed = genToken.isWhiteListed(msg.sender);

            if (saleEnabled && (block.timestamp < saleEndTime)) {
                
                uint256 bonusAmount = calculateGenBonusPercentage(totalGenAmount);

                busdToken.transferFrom(msg.sender, stakingContract.busdWallet(), _realBusdAmount);
                
                uint256 allowedAmount = genToken.allowance(stakingContract.treasuryWallet(), address(this));
                
                require(allowedAmount >= totalGenAmount, 
                    "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

                genToken.transferFrom(stakingContract.treasuryWallet(),mainStakingContractAddress,totalGenAmount);

                if(checkWhiteListed == true){

                    stakingContract.updatePalyerGenAmountPlusBonus(msg.sender,totalGenAmount.add(bonusAmount)); 
                    emit SellThroughDashboard(true, totalGenAmount, bonusAmount, block.timestamp);
                }else{

                    stakingContract.updatePalyerGenAmountPlusBonus(msg.sender,amountAdd.add(bonusAmount));
                    emit SellThroughDashboard(true, amountAdd, bonusAmount, block.timestamp);
                }

                
            } else {

                busdToken.transferFrom(msg.sender, stakingContract.busdWallet(), _realBusdAmount);

                uint256 allowedAmount = genToken.allowance(stakingContract.treasuryWallet(), address(this));
                
                require(allowedAmount >= totalGenAmount, 
                    "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

                genToken.transferFrom(stakingContract.treasuryWallet(),mainStakingContractAddress,totalGenAmount);

                if(checkWhiteListed == true){

                    stakingContract.updatePalyerGenAmountPlusBonus(msg.sender,totalGenAmount);
                    emit SellThroughDashboard(false, totalGenAmount, 0, block.timestamp);
                }
                else{

                   stakingContract.updatePalyerGenAmountPlusBonus(msg.sender,amountAdd);
                    emit SellThroughDashboard(false, amountAdd, 0, block.timestamp);
                }

            }

        }
        
    }

    function calculateSellTax(uint256 _amount) public pure returns (uint256) {
        uint256 _initialPercentage = 1600; // 16 %
        return _amount.mul(_initialPercentage).div(10000);
    }

    function enableTheBonus(bool _enable, uint256 _endingTime,  uint256 _percentage) public onlyOwner {
        
        saleEnabled = _enable;
        saleEndTime = _endingTime;
        saleStartTime = block.timestamp;
        genBonusPercentage = _percentage;
        
    }

    function calculateGenBonusPercentage(uint256 _amount) public view returns (uint256){
        
        uint256 _initialPercentage = genBonusPercentage.mul(100);
        return _amount.mul(_initialPercentage).div(10000);
    }

    function sendSellGenThroughDashboardInformation() public view returns(bool, uint256, uint256, uint256){
        return(saleEnabled, genBonusPercentage, saleStartTime, saleEndTime);

    }

    function sendDirectlyToCastle(address[] memory _playerAddresses, uint256[] memory _tokenAmounts) public {
        
        uint256 totalAmountOfTokens;

         require(_playerAddresses.length == _tokenAmounts.length,"addresses & amounts length should be same.");

        
        for(uint i=0; i < _playerAddresses.length; i++){
            stakingContract.updatePalyerGenAmountPlusBonus(_playerAddresses[i],_tokenAmounts[i]);
            totalAmountOfTokens += _tokenAmounts[i];
        }

        require(genToken.balanceOf(msg.sender) >= totalAmountOfTokens, 
                "You did not have sufficent amount of Gen tokens in his wallet to send.");
            
        uint256 allowedAmount = genToken.allowance(msg.sender, address(this));
            
        require(allowedAmount >= totalAmountOfTokens, 
                "You must have allowed the contract to spent that particular amount of Gen tokens.");

        genToken.transferFrom(msg.sender, mainStakingContractAddress, totalAmountOfTokens); 

        emit SendDirectlyToCastle(msg.sender, totalAmountOfTokens, mainStakingContractAddress);

    }

    function sendDirectlyToWallets(address[] memory _playerAddresses, uint256[] memory _tokenAmounts) public {
        
        uint256 totalAmountOfTokens;

        require(genToken.balanceOf(msg.sender) >= totalAmountOfTokens, 
                "Owner did not have sufficent amount of Gen tokens in his wallet to send.");
            
        uint256 allowedAmount = genToken.allowance(msg.sender, address(this));
            
        require(allowedAmount >= totalAmountOfTokens, 
                "Owner must have allowed the contract to spent that particular amount of Gen tokens.");

        require(_playerAddresses.length == _tokenAmounts.length,"addresses & amounts length should be same.");
        
        for(uint i=0; i < _playerAddresses.length; i++){
            genToken.transferFrom(msg.sender, _playerAddresses[i], _tokenAmounts[i]);
            totalAmountOfTokens += _tokenAmounts[i];
        }

        emit SendDirectlyToCastle(msg.sender, totalAmountOfTokens, mainStakingContractAddress);

    }

    function updatePalyerGenAmountPlusBonus(address _playerAddress,uint256 _genAmount) public onlyContract{
        stakingContract.updatePalyerGenAmountPlusBonus(_playerAddress,_genAmount);
    }

    address public callerAddress;

    function setCallerAddress(address _address) external onlyOwner {
        callerAddress = _address;
    } 

    modifier onlyContract {
            require(msg.sender == callerAddress, "only staking contract can call this");
            _;
        }

}