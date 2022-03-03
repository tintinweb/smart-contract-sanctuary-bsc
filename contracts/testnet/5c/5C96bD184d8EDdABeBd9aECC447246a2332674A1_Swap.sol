/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity >=0.4.19;


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Swap {

    event Swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);
    
    address owner;
    
    struct Pool { mapping(address => uint256) rate ;}

    mapping(address => Pool) tokenRate;
    
    using SafeMath for uint256;


   constructor() public {  
     owner = msg.sender;
   }  

    
    function settingRate(address _tokenA, address _tokenB, uint256 _rate) external returns (bool){
        require(msg.sender == owner, "Not permission");
        if(tokenRate[_tokenB].rate[_tokenA] > 0){
            delete tokenRate[_tokenB].rate[_tokenA];
        }       
        tokenRate[_tokenA].rate[_tokenB] = _rate ;
      
        return true;
    }

    function getRate(address _tokenA, address _tokenB) public view returns (uint256,bool){
        uint256 rate = tokenRate[_tokenA].rate[_tokenB];
        if(rate == 0){
            return (tokenRate[_tokenB].rate[_tokenA], false);
        }
        return (tokenRate[_tokenA].rate[_tokenB], true);
       
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn) external payable returns (bool){
        (uint256 rate, bool rateAB)  = getRate(_tokenIn, _tokenOut);
        require(rate > 0 , "Not setting rate");
       
        if(_tokenIn == address(0)){
            // swap native token vs token X
            IERC20 tokenOut = IERC20(_tokenOut);
            uint256 nativeAmountIn = msg.value;
            uint256 amountOut = _calAmountTokenOut(nativeAmountIn, rate, rateAB);

            require(tokenOut.transfer(msg.sender, amountOut));
            emit Swap(_tokenIn, _tokenOut, nativeAmountIn, amountOut);
        } else if(_tokenOut == address(0)) { 
            // swap X vs native token
            IERC20 tokenIn = IERC20(_tokenIn);           
            require(tokenIn.allowance(msg.sender, address(this)) >= _amountIn, "TokenIn not yet approve");
            uint256 nativeOut = _calAmountTokenOut(_amountIn,rate,rateAB);
            require(tokenIn.transferFrom(msg.sender, address(this), _amountIn));
            payable(msg.sender).transfer(nativeOut);
            emit Swap(_tokenIn, _tokenOut, _amountIn, nativeOut);
    
        }else{
            IERC20 token0 = IERC20(_tokenIn);
            IERC20 token1 = IERC20(_tokenOut);
            require(token0.allowance(msg.sender, address(this)) >= _amountIn, "TokenIn not yet approve");
            
            uint256 amountOut = _calAmountTokenOut(_amountIn,rate,rateAB);
            require(token1.balanceOf(address(this)) >= amountOut, "Contract not enough tokenOut");
            
            require(token0.transferFrom(msg.sender,address(this), _amountIn ));
            require(token1.approve(msg.sender, amountOut));
            require(token1.transfer(msg.sender, amountOut));
            emit Swap(_tokenIn, _tokenOut, _amountIn, amountOut);
        }
        
        return true;
    }

    function _calAmountTokenOut(uint256 _amountIn, uint256 _rate, bool _rateAB) private pure returns(uint256){
        if(_rateAB){
            return _amountIn.mul( _rate).div(10**18);
        }
        return _amountIn.mul(10**18).div(_rate);
    }

}

library SafeMath { 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      assert(b <= a);
      return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      assert(c >= a);
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
        // Solidity only automatically asserts when dividing by 0
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