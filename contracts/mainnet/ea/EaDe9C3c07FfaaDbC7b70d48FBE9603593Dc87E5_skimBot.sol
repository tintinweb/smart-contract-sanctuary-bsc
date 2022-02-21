/**
 *Submitted for verification at BscScan.com on 2022-02-21
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

    address bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public factory = 0x04D6b20f805e2bd537DDe84482983AabF59536FF; //donkswap
    uint256 Fee  = 8000000000000000;
    IFactory public FA = IFactory(factory);
    
    // FA = IFactory(factory);
   
   
    function _changeFactory(address _factory) external onlyOwner {
        factory = _factory;
        FA = IFactory(factory);
    }

    function getLength() external view returns (uint256 AllPairsLength) {
        return FA.allPairsLength();
    }

    function _changeMinFee(uint256 _newFee) external onlyOwner{
        Fee = _newFee;
    }
    
    function _checkOne(uint PairNumberBack) external view returns (bool _hasbnb, uint256 BNBraw){
           uint amount0 = 0;
           uint amount1 = 0;
           uint256 bnb = 0;
            bool hasbnb = true;

        // check each pair for extra BNB
           uint j = FA.allPairsLength() - PairNumberBack;
                // find pair
                IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
                //get balance of tokens in LP
                IToken Token0 = IToken(LP.token0());
                IToken Token1 = IToken(LP.token1());

                amount0 = Token0.balanceOf(FA.allPairs(j)) - _reserve0;
                amount1 = Token1.balanceOf(FA.allPairs(j)) - _reserve1;
                if (amount0 > 0 && LP.token0() != bnbAddress) {
                    bnb = getAmountOut(amount0, _reserve0, _reserve1);
                } else if  (amount1 > 0 && LP.token1() != bnbAddress) {
                    bnb = getAmountOut(amount1, _reserve0, _reserve1);
                }
            if (LP.token0() != bnbAddress && LP.token1() != bnbAddress)  {
                hasbnb = false;
                bnb = 0;
                } 
           
           return (hasbnb, bnb);
    }

    function _SkimIt(uint PairNumberBack) external {
           uint j = FA.allPairsLength() - PairNumberBack;
            IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));
            LP.skim(address(this));
    }

    function _takeBNB(uint PairNumberBack) external {
            uint amount0 = 0;
            uint amount1 = 0;
            // uint256 bnb = 0;

            uint j = FA.allPairsLength() - PairNumberBack;
            IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));

            (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
            IToken Token0 = IToken(LP.token0());
            IToken Token1 = IToken(LP.token1());
            amount0 = Token0.balanceOf(FA.allPairs(j)) - _reserve0;
            amount1 = Token1.balanceOf(FA.allPairs(j)) - _reserve1;
            require (LP.token0() == bnbAddress || LP.token1() == bnbAddress, 'NOT A BNB PAIR');
            if (LP.token0() == bnbAddress) {
                    address[] memory path = new address[](2);
                        path[0] = LP.token1();
                        path[1] = bnbAddress;
                    _swap(path, address(this), FA.allPairs(j));
            } else if (LP.token1() == bnbAddress) {
                    address[] memory path = new address[](2);
                        path[0] = LP.token0();
                        path[1] = bnbAddress;
                    _swap(path, address(this), FA.allPairs(j));
            }
        
    }



    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'FarmageddonLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'FarmageddonLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn * 9950;
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
            require (amountOutput > Fee, 'NOT ENOUGH BNB');
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            pair.swap(amount0Out, amount1Out, _to, new bytes(0));
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