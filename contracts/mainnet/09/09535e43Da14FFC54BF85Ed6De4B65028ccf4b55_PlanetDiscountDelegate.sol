/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity ^0.8.10;

contract PlanetStorage {
    
    address public gGammaAddress = 0xF701A48e5C751A213b7c540F84B64b5A6109962E;
    address public gammatroller = 0xF54f9e7070A1584532572A6F640F09c606bb9A83;
    address public oracle = 0xC23b8aF5D68222a2FB835CEB07B009b94e36eFF9;
    
    address public admin;
    address public implementation;
    address public infinityVault;
    
    uint256 public level0Discount = 0;
    uint256 public level1Discount = 500;
    uint256 public level2Discount = 2000;
    uint256 public level3Discount = 5000;
   
    uint256 public level1Min = 100;
    uint256 public level2Min = 500;
    uint256 public level3Min = 1000;
    
    
    /**
     * @notice Total amount of underlying discount given
     */
    mapping(address => uint) public totalDiscountGiven;
    
    mapping(address => bool) public isMarketListed;
    
    /*
     * @notice Official record of each user whether the user is present in discountGetters or not
     */
    mapping(address => mapping(address => BorrowDiscountSnapshot)) public borrowDiscountSnap;
    
    struct ReturnBorrowDiscountLocalVars {
        uint marketTokenSupplied;
    }
    
    mapping(address => address[]) public usersWhoHaveBorrow;

    /**
     * @notice Container for borrow balance information
     * @member principal Total balance (with accrued interest), after applying the most recent balance-changing action
     * @member interestIndex Global borrowIndex as of the most recent balance-changing action
     */
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    
    /**
     * @notice Container for Discount information
     * @member exist (whether user is present in Discount scheme)
     * @member index (user address index in array of usersWhoHaveBorrow)
     * @member lastRepayAmountDiscountGiven(the last repay amount at which discount is given to user)
     * @member accTotalDiscount(total discount accumulated to the user)
     * @member lastUpdated(timestamp at which it is updated last time)
     */
    struct BorrowDiscountSnapshot {
        bool exist;
        uint index;
        uint lastBorrowAmountDiscountGiven;
        uint accTotalDiscount;
        uint lastUpdated;
    }
  
   /**
    * @notice Event emitted when discount is changed for user
    */
    event BorrowDiscountAccrued(address market,address borrower,uint discountGiven,uint lastUpdated);
     
    event gGammaAddressChange(address prevgGammaAddress,address newgGammaAddress);
    
    event gammatrollerChange(address prevGammatroller,address newGammatroller);
    
    event oracleChanged(address prevOracle,address newOracle);

    event InfinityVaultChanged(address oldInfinityVault,address newInfinityVault);
}

contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    /**
     * @dev Truncates the given exp to a whole number value.
     *      For example, truncate(Exp{mantissa: 15 * expScale}) = 15
     */
    function truncate(Exp memory exp) pure internal returns (uint) {
        // Note: We are not using careful math here as we're performing a division that cannot fail
        return exp.mantissa / expScale;
    }

    /**
     * @dev Multiply an Exp by a scalar, then truncate to return an unsigned integer.
     */
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }

    /**
     * @dev Multiply an Exp by a scalar, truncate, then add an to an unsigned integer, returning an unsigned integer.
     */
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }

    /**
     * @dev Checks if first Exp is less than second Exp.
     */
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }

    /**
     * @dev Checks if left Exp <= right Exp.
     */
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }

    /**
     * @dev Checks if left Exp > right Exp.
     */
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }

    /**
     * @dev returns true if Exp is exactly zero
     */
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {
        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {
        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {
        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {
        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}

interface PriceOracle {
    /**
      * @notice Get the underlying price of a gToken asset
      * @param gToken The gToken to get the underlying price of
      * @return The underlying asset price mantissa (scaled by 1e18).
      *  Zero means the price is unavailable.
      */
    function getUnderlyingPrice(GToken gToken) external view returns (uint);
}

interface GammatrollerInterface {
   
    function getAllMarkets() external view returns(GToken[] memory);
}

interface GToken {
    
    function totalReserves() external view returns (uint256);
    
    function totalBorrows() external view returns (uint256);
    
    function borrowIndex() external view returns (uint256);

    /**
     * @notice Get a snapshot of the account's balances, and the cached exchange rate
     * @dev This is used by gammatroller to more efficiently perform liquidity checks.
     * @param account Address of the account to snapshot
     * @return (possible error, token balance, borrow balance, exchange rate mantissa)
     */
    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

    /**
     * @notice Return the borrow balance of account based on stored data
     * @param account The address whose balance should be calculated
     * @return The calculated balance
     */
    function borrowBalanceStored(address account) external view returns (uint);

    
    /**
     * @notice Return the reserve factor of market based on stored data
     * @dev This function does not accrue interest before returning the reserve factor
     * @return reserve fcator scaled by 1e18
     */
    function reserveFactorMantissa() external view returns (uint);

}

interface InfinityVault {

    function getUserGtokenBal(address user) external view returns(uint);

}

contract PlanetDiscountDelegate is PlanetStorage,ExponentialNoError{
    
    function changeAddress(address _newgGammaAddress,address _newGammatroller,address _newOracle,address _newInfinityVault) public returns(bool){
        
        require(msg.sender == admin, "only admin can call");
        address _gGammaAddress = gGammaAddress;
        address _gammatroller = gammatroller;
        address _oracle = oracle;
        address _infinityVault = infinityVault;
        
        gGammaAddress = _newgGammaAddress;
        gammatroller = _newGammatroller;
        oracle = _newOracle;
        infinityVault = _newInfinityVault;
        
        emit gGammaAddressChange(_gGammaAddress,_newgGammaAddress);
        emit gammatrollerChange(_gammatroller,_newGammatroller);
        emit oracleChanged(_oracle,_newOracle);
        emit InfinityVaultChanged(_infinityVault,_newInfinityVault);
        return true;
    }
    
    function listMarket(address market) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       require(!isMarketListed[market],"market already listed");
       isMarketListed[market] = true;
       return true;
    }
    
    function listMarkets(address[] memory markets) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       for(uint i = 0 ; i < markets.length ; ++i){
        address market = markets[i];
         require(!isMarketListed[market],"market already listed");
         isMarketListed[market] = true;
       }
       return true;
    }

    function deListMarket(address market) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       require(isMarketListed[market],"market already delisted");
       isMarketListed[market] = false;
       return true;
    }
    
    function deListMarkets(address[] memory markets) public returns(bool){
       require(msg.sender == admin, "only admin can call");
       for(uint i = 0 ; i < markets.length ; ++i){
        address market = markets[i];
         require(!isMarketListed[market],"market already delisted");
         isMarketListed[market] = false;
       }
       return true;
    }
    
    function returnBorrowerStakedAsset(address borrower,address market) public view returns(uint){
        
        address marketAddress = market;
        ReturnBorrowDiscountLocalVars memory vars;
        
        (,uint gTokenBalance,,uint exchangeRate) = GToken(marketAddress).getAccountSnapshot(borrower);
        
        if(gTokenBalance != 0){
            uint price = PriceOracle(oracle).getUnderlyingPrice(GToken(marketAddress));
        
            vars.marketTokenSupplied = mul_ScalarTruncate(Exp({mantissa: gTokenBalance}), exchangeRate);
            uint256 marketTokenSuppliedInBnb = mul_ScalarTruncate(Exp({mantissa: vars.marketTokenSupplied}), price);
        
            return (marketTokenSuppliedInBnb);
        }
        else{
            return 0;
        }
    }
   
    function returnDiscountPercentage(address borrower) public view returns(uint discount){
        
        //scaled upto 2 decimal like if 50% then output is 5000
       
        GToken[] memory userInMarkets = GammatrollerInterface(gammatroller).getAllMarkets();

        (,uint gTokenBalance,,uint exchangeRate) = GToken(gGammaAddress).getAccountSnapshot(borrower);
        uint price = PriceOracle(oracle).getUnderlyingPrice(GToken(gGammaAddress));
        
        gTokenBalance = gTokenBalance + InfinityVault(infinityVault).getUserGtokenBal(borrower);
        
        uint256 gammaStaked = mul_ScalarTruncate(Exp({mantissa: gTokenBalance}), exchangeRate);
        gammaStaked = mul_ScalarTruncate(Exp({mantissa: gammaStaked}), price);
        
        uint256 otherStaked = 0; 
        
        for(uint i = 0; i < userInMarkets.length ;++i){
            
            GToken _market = userInMarkets[i];
            
            if(isMarketListed[address(_market)] && address(_market) != gGammaAddress){
                
                otherStaked = otherStaked + returnBorrowerStakedAsset(borrower,address(_market));
            
            }
            
        }

        
        Exp memory _discount = Exp({mantissa: div_((gammaStaked*expScale), otherStaked)});

        _discount.mantissa = _discount.mantissa*100;
        uint256 _scaledDiscount = _discount.mantissa/1e16;
        discount = _scaledDiscount;
        
        if(level1Min <= discount && discount < level2Min){
            discount = level1Discount;
        }
        else if(level2Min <= discount && discount < level3Min){
            discount = level2Discount;
        }
        else if(discount >= level3Min){
            discount = level3Discount;
        }
        else{
            discount = level0Discount;
        }
        
    }  
    
    function totalReservesAfterDiscount(address market) external view returns(uint res){
        res = GToken(market).totalReserves() - totalDiscountGiven[market];
    }
    
    /**
     * Borrow side
     */
    
    function changeLastBorrowAmountDiscountGiven(address borrower,uint borrowAmount) external returns(bool) {
        
        address market = msg.sender;
        
        require(isMarketListed[market],"Market not listed");
        
        BorrowDiscountSnapshot storage _borrowDis = borrowDiscountSnap[market][borrower];
        
        (_borrowDis.lastBorrowAmountDiscountGiven) = borrowAmount;
        
        _borrowDis.lastUpdated = block.number;
        
        return true;
    }
    
    struct BorrowLocalVars {
        uint accountBorrowsNew;
        uint interest;
        uint newDiscount;
    }
    
    function changeUserBorrowDiscount(address borrower) external returns(uint,uint,uint,uint){
        
        address _market = msg.sender;
        
        require(isMarketListed[_market],"Market not listed");
        
        GToken market = GToken(_market);
        
        BorrowLocalVars memory vars;
        
        BorrowDiscountSnapshot storage _dis = borrowDiscountSnap[_market][borrower];
        
        uint discount = returnDiscountPercentage(borrower); // 5% => 500,20% => 2000 ,50% => 5000
        
        (uint currentBorrowBal) = market.borrowBalanceStored(borrower);
        
        if( _dis.exist && discount > 0) {
            
            //interest on principal
            vars.interest = currentBorrowBal - _dis.lastBorrowAmountDiscountGiven;
            
            //reserve factor of market
            (uint reserveFactor) = GToken(market).reserveFactorMantissa();
            
            //multiply reserve factor with interest borrower have to pay on principal
            uint valueOfGivenInterestGoToReserves = 
             mul_ScalarTruncate(Exp({mantissa:vars.interest}),reserveFactor);

            //Applying discount percentage
            vars.newDiscount = discount*valueOfGivenInterestGoToReserves;
            
            vars.newDiscount = vars.newDiscount/10000;
            
            //update the borrow amount of borrower
            _dis.lastBorrowAmountDiscountGiven = currentBorrowBal;
            
            vars.accountBorrowsNew = currentBorrowBal - vars.newDiscount;
            
            totalDiscountGiven[_market] = totalDiscountGiven[_market] + vars.newDiscount;
         
            _dis.lastUpdated = block.number; 
            
            emit BorrowDiscountAccrued(_market,borrower,vars.newDiscount,_dis.lastUpdated);
            
            return(vars.accountBorrowsNew,market.borrowIndex(),market.totalBorrows() - vars.newDiscount, market.totalReserves() - vars.newDiscount); 
        }
        else {
            
            if(_dis.exist){
                
                _dis.lastBorrowAmountDiscountGiven = currentBorrowBal;
                _dis.lastUpdated = block.number;
                
            }
            else{
                usersWhoHaveBorrow[_market].push(borrower);
                _dis.exist = true;
                _dis.index = usersWhoHaveBorrow[_market].length - 1;
                _dis.lastBorrowAmountDiscountGiven = currentBorrowBal;
                _dis.lastUpdated = block.number;
            }
            
            return(currentBorrowBal,market.borrowIndex(),market.totalBorrows(), market.totalReserves());
        }
    }
   
    
    function returnBorrowUserArr(address market) external view returns(address [] memory){
        
        return usersWhoHaveBorrow[market];
    
    }

}