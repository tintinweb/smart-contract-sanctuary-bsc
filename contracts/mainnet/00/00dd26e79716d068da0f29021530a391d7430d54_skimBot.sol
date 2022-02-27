/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


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


// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

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
}



library FarmageddonLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'FarmageddonLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'FarmageddonLibrary: ZERO_ADDRESS');
    }


}
// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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



pragma solidity ^0.8.0;

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

interface IToken {
    function balanceOf(address owner) external view returns (uint);
}

interface IFactory {

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
}

interface IFarmageddonPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function skim(address to) external;
    
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract skimBot is  Ownable {
    using SafeMath  for uint;

    uint _MAX112 = 2**112 -1;
    address bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public treasury = 0x32fb83c864b731305795F2d1Cf2B31b03188420A;
    uint256 public minBNB = 2500000000000000;
    uint256 public minBUSD = 1500000000000000000;
   

    function _changeTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function _changeMinBNB(uint256 newMinBNB) external onlyOwner {
        minBNB = newMinBNB;
    }

    function _changeMinBUSD(uint256 newMinBUSD) external onlyOwner {
        minBUSD = newMinBUSD;
    }

    function getLength(address factory) public view returns (uint256 AllPairsLength) {
        IFactory FA = IFactory(factory);
        return FA.allPairsLength();
    } 

   
    
    function _checkOne(uint _j, address factory) external view returns (uint256 BNBraw, uint256 BUSDraw, address){
        IFactory FA = IFactory(factory);
           uint amount0 = 0;
           uint amount1 = 0;
           uint256 bnb = 0;
           uint256 busd = 0;

        // check each pair for extra BNB
                address pair = FA.allPairs(_j);
                IFarmageddonPair LP = IFarmageddonPair(pair);
                address token0 = LP.token0();
                address token1 = LP.token1();
                // find pair
                
                
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
                
                // Set tokens for checks
                IToken Token0 = IToken(token0);
                IToken Token1 = IToken(token1);
                
                // check for differences
                amount0 = Token0.balanceOf(pair) - _reserve0;
                amount1 = Token1.balanceOf(pair) - _reserve1;
          if (amount0 <= _MAX112 && amount1 <= _MAX112) {     
                // check for BNB differences
                if (amount0 > 0 && token1 == bnbAddress) {
                    bnb = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == bnbAddress) {
                    bnb = getAmountOut(amount1, _reserve1, _reserve0);
                }
                
                 // check for BUSD differences
                if (amount0 > 0 && token1 == busdAddress) {
                    busd = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == busdAddress) {
                    busd = getAmountOut(amount1, _reserve1, _reserve0);
                }
           } 
           
           return (bnb, busd, pair);
    }

    function _SkimIt(uint j, address factory) external {
        IFactory FA = IFactory(factory);
            IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));
            LP.skim(treasury);
    }

    function _take(uint j, address factory) external {
        address pair = IFactory(factory).allPairs(j);
        address token0 = IFarmageddonPair(pair).token0();
        address token1 = IFarmageddonPair(pair).token1();
            
            // take that money!                       
            if (token0 == bnbAddress || token0 == busdAddress) {
                    address[] memory path = new address[](2);
                        path[0] = token1;
                        path[1] = token0;
                    _swap(path, treasury, pair);
            } else if (token1 == bnbAddress || token1 == busdAddress) {
                    address[] memory path = new address[](2);
                        path[0] = token0;
                        path[1] = token1;
                    _swap(path, treasury, pair);
            }
        
    }


    function _checkOneLP(address _j) external view returns (uint256 BNBraw, uint256 BUSDraw, address[] memory _path){
            uint amount0 = 0;
           uint amount1 = 0;
           uint256 bnb = 0;
           uint256 busd = 0;
           address[] memory path = new address[](2);

        // check each pair for extra BNB
                address pair = _j;
                IFarmageddonPair LP = IFarmageddonPair(pair);
                address token0 = IFarmageddonPair(pair).token0();
                address token1 = IFarmageddonPair(pair).token1();
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
                
                // Set tokens for checks
                IToken Token0 = IToken(token0);
                IToken Token1 = IToken(token1);
                
                // check for differences
                amount0 = Token0.balanceOf(pair) - _reserve0;
                amount1 = Token1.balanceOf(pair) - _reserve1;
          if (amount0 <= _MAX112 && amount1 <= _MAX112) {     
                // check for BNB differences
                if (amount0 > 0 && token1 == bnbAddress) {
                    bnb = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == bnbAddress) {
                    bnb = getAmountOut(amount1, _reserve1, _reserve0);
                }
                
                 // check for BUSD differences
                if (amount0 > 0 && token1 == busdAddress) {
                    busd = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == busdAddress) {
                    busd = getAmountOut(amount1, _reserve1, _reserve0);
                }
           } 
          
           if (token0 == bnbAddress || token0 == busdAddress) {
                        path[0] = token1;
                        path[1] = token0;
            } else if (token1 == bnbAddress || token1 == busdAddress) {
                        path[0] = token0;
                        path[1] = token1;
            }
           
           return (bnb, busd, path);
    }

    function _takefromLP(address LPAddress) external {
            address pair = LPAddress;
            address token0 = IFarmageddonPair(pair).token0();
            address token1 = IFarmageddonPair(pair).token1();
            
            // take that money!                       
            if (token0 == bnbAddress || token0 == busdAddress) {
                    address[] memory path = new address[](2);
                        path[0] = token1;
                        path[1] = token0;
                    _swap(path, treasury, pair);
            } else if (token1 == bnbAddress || token1 == busdAddress) {
                    address[] memory path = new address[](2);
                        path[0] = token0;
                        path[1] = token1;
                    _swap(path, treasury, pair);
            }
        
    }


  function CheckList(address[] calldata LPList) external view returns (uint256 BNBraw, uint256 BUSDraw, address LPAddress, address[] memory _path){
 address[] memory path = new address[](2);     
   for (uint i = 0; i < LPList.length; i++) {
        uint amount0 = 0;
        uint amount1 = 0;
        uint256 bnb = 0;
        uint256 busd = 0;
        
        // check each pair for extra BNB
                address pair = LPList[i];
                // IFarmageddonPair LP = IFarmageddonPair(pair);
                address token0 = IFarmageddonPair(pair).token0();
                address token1 = IFarmageddonPair(pair).token1();
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = IFarmageddonPair(pair).getReserves();
                
                // Set tokens for checks
                // IToken Token0 = IToken(token0);
                // IToken Token1 = IToken(token1);
                
                // check for differences
                amount0 = IToken(token0).balanceOf(pair) - _reserve0;
                amount1 = IToken(token1).balanceOf(pair) - _reserve1;
          if (amount0 <= _MAX112 && amount1 <= _MAX112) {     
                // check for BNB differences
                if (amount0 > 0 && token1 == bnbAddress) {
                    bnb = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == bnbAddress) {
                    bnb = getAmountOut(amount1, _reserve1, _reserve0);
                }
                
                 // check for BUSD differences
                if (amount0 > 0 && token1 == busdAddress) {
                    busd = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == busdAddress) {
                    busd = getAmountOut(amount1, _reserve1, _reserve0);
                }
           } 
           
           if (token0 == bnbAddress || token0 == busdAddress) {
                        path[0] = token1;
                        path[1] = token0;
            } else if (token1 == bnbAddress || token1 == busdAddress) {
                        path[0] = token0;
                        path[1] = token1;
            }
           
           if (bnb > minBNB ) return (bnb, busd, pair, path);
           if (busd > minBUSD) return (bnb, busd, pair, path);
           
           
    }
    return ( 0,0,address(0), path);
    }

    
    function CheckABunch(uint start, uint end, address factory) external view returns (uint256 BNBraw, uint256 BUSDraw, address LPAddress){
      
        IFactory FA = IFactory(factory);
        for (uint i = start; i < end; i++) {
           uint amount0 = 0;
           uint amount1 = 0;
           uint256 bnb = 0;
           uint256 busd = 0;
   
    
                address pair = FA.allPairs(i);
                // IFarmageddonPair LP = IFarmageddonPair(pair);
                address token0 = IFarmageddonPair(pair).token0();
                address token1 = IFarmageddonPair(pair).token1();
                // find pair
                
                
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = IFarmageddonPair(pair).getReserves();
                
                // Set tokens for checks
                IToken Token0 = IToken(token0);
                IToken Token1 = IToken(token1);
                
                // check for differences
                amount0 = Token0.balanceOf(pair) - _reserve0;
                amount1 = Token1.balanceOf(pair) - _reserve1;
          if (amount0 <= _MAX112 && amount1 <= _MAX112) { 
                // check for BNB differences
                if (amount0 > 0 && token1 == bnbAddress) {
                    bnb = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == bnbAddress) {
                    bnb = getAmountOut(amount1, _reserve1, _reserve0);
                }
                 // check for BUSD differences
                if (amount0 > 0 && token1 == busdAddress) {
                    busd = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && token0 == busdAddress) {
                    busd = getAmountOut(amount1, _reserve1, _reserve0);
                }
          }
           if (bnb > minBNB ) return (bnb, busd, pair);
           if (busd > minBUSD) return (bnb, busd, pair);
           
    }
    return ( 0,0,address(0));
    }


    function QuickCheckList(address[] calldata LPList) external view returns (uint256 out0, uint256 out1, address LPAddress, address tokenOut){   
        for (uint i = 0; i < LPList.length; i++) {
            address pair = LPList[i];
                
                address token0 = IFarmageddonPair(pair).token0();
                address token1 = IFarmageddonPair(pair).token1();
                (uint112 _reserve0, uint112 _reserve1,) = IFarmageddonPair(pair).getReserves();
                
                uint256 amount0 = IToken(token0).balanceOf(pair) - _reserve0;
                uint256 amount1 = IToken(token1).balanceOf(pair) - _reserve1;
                uint256 outPut0 = getAmountOut(amount0, _reserve0, _reserve1);
                uint256 outPut1 = getAmountOut(amount1, _reserve1, _reserve0);

           
            if (outPut0 > 0) return (outPut0, 0, pair, token0);
            
            if (outPut1 > 0) return (0, outPut1, pair, token1);
  
        }
        return ( 0,0,address(0), address(0));
    }

    function quickSwap(uint256 amount0Out, uint256 amount1Out, address pair) public {
        IFarmageddonPair LP = IFarmageddonPair(pair);
        LP.swap(amount0Out, amount1Out, treasury, new bytes(0));
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'FarmageddonLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'FarmageddonLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * 9975;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 10000 + amountInWithFee;
        amountOut = numerator / denominator;
    }

     function _swap(address[] memory path, address _to, address _pair) internal virtual {
        
            (address input, address output) = (path[0], path[1]);
            (address token0,) = FarmageddonLibrary.sortTokens(input, output);
            IFarmageddonPair pair = IFarmageddonPair(_pair);
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            pair.swap(amount0Out, amount1Out, _to, new bytes(0));
    }
    


        function _quickTake(address[] memory path, address LPAddress) external {

            (address input, address output) = (path[0], path[1]);
            (address token0,) = FarmageddonLibrary.sortTokens(input, output);
            IFarmageddonPair pair = IFarmageddonPair(LPAddress);
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            pair.swap(amount0Out, amount1Out, treasury, new bytes(0));      
    }



        function balanceCheck(address _Token) private view returns (uint256) {
                uint256 balance = IERC20(_Token).balanceOf(address(this));
                return balance;
        }

       function withdawlBNB() external onlyOwner {
            payable(msg.sender).transfer(address(this).balance);
        }

         function withdrawlBUSD() external onlyOwner {
            address busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
            uint256 Amount = balanceCheck(busd);
            IERC20(busd).transfer(address(msg.sender), Amount);
        }

         function withdrawlwbnb() external onlyOwner {
            uint256 Amount = balanceCheck(bnbAddress);
            IERC20(bnbAddress).transfer(address(msg.sender), Amount);
        }

        function withdrawlToken(address _tokenAddress) external onlyOwner {
            uint256 _tokenAmount = balanceCheck(_tokenAddress);
            IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        }  

    // to receive Eth From Router when Swapping
    receive() external payable {}
}