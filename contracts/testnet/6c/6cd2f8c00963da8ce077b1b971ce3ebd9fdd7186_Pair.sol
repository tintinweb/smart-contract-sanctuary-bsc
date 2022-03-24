/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity >= 0.8.0;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}



library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {

	mapping(address => bool) public manager;

    event OwnershipTransferred(address indexed newOwner, bool isManager);


    constructor() {
        _setOwner(_msgSender(), true);
    }

    modifier onlyOwner() {
        require(manager[_msgSender()], "Ownable: caller is not the owner");
        _;
    }

    function setOwner(address newOwner,bool isManager) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner,isManager);
    }

    function _setOwner(address newOwner, bool isManager) private {
        manager[newOwner] = isManager;
        emit OwnershipTransferred(newOwner, isManager);
    }
}


contract Pair is Ownable{
    using SafeMath  for uint;
    using UQ112x112 for uint224;

   
    address public token0;
    address public token1;
    uint public token0Amount;
    uint public token1Amount;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
	uint256 public maxSwapAmount;
	uint256 public secondsOfdDay;
	uint256 public addTimestamp;
	uint256 public subTimestamp;
	uint256 public maxFallRate;
    uint256 public fee;
    uint256 public token0Fee;
	uint256 public token1Fee;

	mapping(uint256 => uint256) public openingPrice;
    modifier lock() {
        require(unlocked == 1, 'Pair: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }


    event Sync(uint256 currentTimestamp, uint112 reserve0, uint112 reserve1);
    event Swap(
        address sender,
		uint256 currentTimestamp,
        uint amountIn,
        uint amountOut,
        address[]  path,
        address to
    );
	event RecordOpeningPrice(uint256 currentTimestamp, uint256 currentDay, uint256 currentPrice);

    constructor() {   
        token0 = 0x0b234acf8734B609585Ef60A30178E143B58B6A1;
        token1 = 0x8E532c66e550c06b58367cAB0e76a807b8D088b9;
        mint(10000 * 10 ** 18,10000 * 10 ** 18);
		secondsOfdDay = 86400;
		maxFallRate = 4000;
        maxSwapAmount = 1000 * 10 ** 18;
        fee = 25;
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) public onlyOwner{       
        token0 = _token0;
        token1 = _token1;
    }


	function mint(uint256 amount0 , uint256 amount1) public lock onlyOwner{
	
        (uint112 _reserve0, uint112 _reserve1,) = getReserves();
 
        token0Amount = token0Amount.add(amount0);
        token1Amount = token1Amount.add(amount1);

        _update(token0Amount, token1Amount, _reserve0, _reserve1);
      
       
    }


    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }    
	
	// update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
	
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
		
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; 
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {

            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(block.timestamp,reserve0, reserve1);
    }
	

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amountIn, address[] memory path, address to) external lock {
	
		require(to != token0 && to != token1, 'Pair: INVALID_TO');
        require(amountIn > 0 , 'Pair: INSUFFICIENT_OUTPUT_AMOUNT');
		
		IERC20(path[0]).transferFrom(msg.sender, address(this),amountIn);	
        recordOpeningPrice();	
		uint amountOut = getAmountsOut(amountIn,path);		
		IERC20(path[1]).transfer(to, amountOut);		
        (uint112 _reserve0, uint112 _reserve1 ,) = getReserves();
		
		

		if(path[0] == token0){
            require(path[1] == token1,'Pair: INVALID_PATH_1');
			token0Amount = token0Amount.add(amountIn);
			token1Amount = token1Amount.sub(amountOut);
            token0Fee = token0Fee.add(amountIn.mul(fee).div(10000));
            require( amountOut <= maxSwapAmount,"Pairs: AMOUNT_MAX");

		 }else if(path[0] == token1){

            require(path[1] == token0,'Pair: INVALID_PATH_0');
			token1Amount = token1Amount.add(amountIn);
			token0Amount = token0Amount.sub(amountOut);
            token1Fee = token1Fee.add(amountIn.mul(fee).div(10000));
            require( amountIn <= maxSwapAmount,"Pairs: AMOUNT_MAX");
		}
	    
		_update(token0Amount, token1Amount, _reserve0, _reserve1);			
        emit Swap(msg.sender, block.timestamp, amountIn, amountOut, path, to);
		
		comparedPrice();
    }
	
	// this low-level function should be called from a contract which performs important safety checks
    function quantify(uint amountIn, address[] memory path) external lock onlyOwner{
	
	    require(amountIn > 0 , 'Pair: INSUFFICIENT_OUTPUT_AMOUNT');	
        recordOpeningPrice();	
		uint amountOut = getAmountsOut(amountIn,path);		
        (uint112 _reserve0, uint112 _reserve1 ,) = getReserves();
		
		
		
		if(path[0] == token0){
            require(path[1] == token1,'Pair: INVALID_PATH_1');
			token0Amount = token0Amount.add(amountIn);
			token1Amount = token1Amount.sub(amountOut);
         

		 }else if(path[0] == token1){

            require(path[1] == token0,'Pair: INVALID_PATH_0');
			token1Amount = token1Amount.add(amountIn);
			token0Amount = token0Amount.sub(amountOut);
            
		}
	    
		_update(token0Amount, token1Amount, _reserve0, _reserve1);		
        emit Swap(msg.sender, block.timestamp, amountIn, amountOut, path, msg.sender);
		
		comparedPrice();
    }
	
	

	// given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view returns (uint amountOut) {
        require(amountIn > 0, 'Pair: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'Pair: INSUFFICIENT_LIQUIDITY');

        uint amountInWithFee = amountIn.mul(10000 - fee);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);

        amountOut = numerator / denominator;
    }
	

    function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint256) {
        require(path.length == 2, 'Pair: INVALID_PATH');
        if( amountIn == 0) return 0;
	    (uint112 _reserve0, uint112 _reserve1 ,) = getReserves();
        uint256 amountOut;
        uint reserveIn;
        if(path[0] == token0){
            
            require(path[1] == token1,'Pair: INVALID_PATH1');
            reserveIn = token0Amount.add(amountIn);
            amountOut = getAmountOut(amountIn, reserveIn , _reserve1);

        }else if(path[0] == token1){
            
            require(path[1] == token0,'Pair: INVALID_PATH0');
            reserveIn = token1Amount.add(amountIn);
            amountOut = getAmountOut(amountIn, reserveIn, _reserve0);
        }
        return amountOut;
    }
	
	function recordOpeningPrice() public{
		uint256 currentTimestamp = block.timestamp.add(addTimestamp).sub(subTimestamp);
		uint256 currentDay = currentTimestamp.div(secondsOfdDay);		
		
		if(openingPrice[currentDay] == 0){
			uint256 currentPrice  = unitPrice();
			openingPrice[currentDay] = currentPrice;
			emit RecordOpeningPrice(currentTimestamp,currentDay,currentPrice);
		}
		
	}
	
	function comparedPrice() view public returns(bool){
		uint256 currentTimestamp = block.timestamp.add(addTimestamp).sub(subTimestamp);
		uint256 currentDay = currentTimestamp.div(secondsOfdDay);		
		uint256 currentPrice = unitPrice();
		uint256 lowestPrice = openingPrice[currentDay].mul(10000 - maxFallRate).div(10000);
		require(currentPrice >= lowestPrice ,"Pair: INSUFFICIENT_LIQUIDITY_BURNED");
        return true;
	}
	
	function unitPrice() public view returns(uint256){
		address[] memory path = new address[](2);
		path[0] = token1;
		path[1] = token0;
		uint256 decimal = IERC20(token1).decimals();
		uint256 currentPrice  = getAmountsOut(1 * 10 ** decimal, path);
		return currentPrice;
		
	}

    function trend() public view returns(bool,uint256){
        uint256 currentUnitPrice = unitPrice();
        uint256 currentTimestamp = block.timestamp.add(addTimestamp).sub(subTimestamp);
        uint256 currentDay = currentTimestamp.div(secondsOfdDay);
        uint256 currentOpeningPrice = openingPrice[currentDay];
        uint256 subPrice;
        if(currentUnitPrice > currentOpeningPrice){
            subPrice = currentUnitPrice.sub(currentOpeningPrice);
            return(true, subPrice * 10000 / currentOpeningPrice);

        }else if(currentUnitPrice < currentOpeningPrice){
            subPrice = currentOpeningPrice.sub(currentUnitPrice);
            return(false, subPrice * 10000 / currentOpeningPrice);
        }else{
            return(true, 0);
        }
  


    }

    function withdrawFee(address to)public onlyOwner{
        IERC20(token0).transfer(to, token0Fee);	
        IERC20(token1).transfer(to, token1Fee);
        token0Fee = 0;
        token1Fee = 0;
    }

	function setTimestamp(uint256 _addTimestamp, uint256 _subTimestamp)public onlyOwner{
		addTimestamp = _addTimestamp;
		subTimestamp = _subTimestamp;
	}
	
	function setSecondsOfdDay(uint256 _secondsOfdDay)public onlyOwner{
		secondsOfdDay = _secondsOfdDay;
	}
	
	function setMaxFallRate(uint256 _maxFallRate)public onlyOwner{
		maxFallRate = _maxFallRate;
	}
    function setMaxSwapAmount(uint256 _maxSwapAmount)public onlyOwner{
        maxSwapAmount = _maxSwapAmount;
    }
    
    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }
	function withdrawStuckTokens(address token) public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
		IERC20(token).transfer(msg.sender, amount);
	}
	
	function withdrawStuckEth() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}
	
	receive() external payable {}
	

}