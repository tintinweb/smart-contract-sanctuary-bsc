/**
 *Submitted for verification at BscScan.com on 2022-02-20
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


library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
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

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/KeeperBase.sol


pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/KeeperCompatible.sol


pragma solidity ^0.8.0;



abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: Keeper.sol


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
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function skim(address to) external;
    
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}


contract skimBot is /* KeeperCompatibleInterface, */ Ownable {
    using SafeMath  for uint;

    address bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address treasury = 0x2909F0F72fE53F41e093dE06aDEA2758680DeF46;
    uint256 Fee  = 20000000000000000;
    uint256 public checkhowmany = 1;
    IFactory public FA = IFactory(factory);
    
    // FA = IFactory(factory);
   
   
    function _changeFactory(address _factory) external onlyOwner {
        factory = _factory;
        FA = IFactory(factory);
    }

    function _changeMinFee(uint256 _newFee) external onlyOwner{
        Fee = _newFee;
    }

    function _changeCheckAmount(uint256 _newCheckAmount) external onlyOwner{
        checkhowmany = _newCheckAmount;
    }
    
    function _checkOne(uint PairNumberBack) external view returns (uint _amount0, uint _amount1){
           uint amount0;
           uint amount1;
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

           
           return (amount0, amount1);
    }


    function _check() public view returns (uint256 [] memory, uint256 [] memory){
           uint256 [] memory amount0;
           uint256 [] memory amount1;
        // check each pair for extra BNB
           for (uint j = FA.allPairsLength() - checkhowmany; j < FA.allPairsLength(); j++) {
                // find pair
                IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
                //get balance of tokens in LP
                IToken Token0 = IToken(LP.token0());
                IToken Token1 = IToken(LP.token1());

                amount0[j] = Token0.balanceOf(FA.allPairs(j)) - _reserve0;
                amount1[j] = Token1.balanceOf(FA.allPairs(j)) - _reserve1;

           }
           return (amount0, amount1);
    }

    function _takeMoneyOne(uint PairNumberBack) external {
        // check factory for quantity of pairs
           uint j = FA.allPairsLength() - PairNumberBack;
        // check each pair for extra BNB
                // find pair
                IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
                //get balance of tokens in LP
                IToken Token0 = IToken(LP.token0());
                IToken Token1 = IToken(LP.token1());
                
            if (LP.token0() == bnbAddress || LP.token1() == bnbAddress) {
                
                if (Token0.balanceOf(FA.allPairs(j)) > (_reserve0 + Fee) && LP.token0() == bnbAddress) {
                    try LP.skim(treasury){}catch{}
                }
                if (Token1.balanceOf(FA.allPairs(j)) > (_reserve1 + Fee) && LP.token1() == bnbAddress) {
                    try LP.skim(treasury){}catch{}
                } 
            }
    }

    function _takeMoney() external {
        // check factory for quantity of pairs
           uint256 pairs =  FA.allPairsLength();
        // check each pair for extra BNB
           for (uint j = pairs -1; j > pairs - checkhowmany; j--) {
                // find pair
                IFarmageddonPair LP = IFarmageddonPair(FA.allPairs(j));
                // get reserves for pair and setup tokens
                (uint112 _reserve0, uint112 _reserve1,) = LP.getReserves();
                //get balance of tokens in LP
                IToken Token0 = IToken(LP.token0());
                IToken Token1 = IToken(LP.token1());
                
            if (LP.token0() == bnbAddress || LP.token1() == bnbAddress) {
                
                if (Token0.balanceOf(FA.allPairs(j)) > (_reserve0 + Fee) && LP.token0() == bnbAddress) {
                    try LP.skim(treasury){}catch{}
                }
                if (Token1.balanceOf(FA.allPairs(j)) > (_reserve1 + Fee) && LP.token1() == bnbAddress) {
                    try LP.skim(treasury){}catch{}
                } 

               /* 
                if (Token0.balanceOf(FA.allPairs(j)) > _reserve0 && LP.token0() != bnbAddress) {
                    uint256 amountIn = Token0.balanceOf(FA.allPairs(j)) - _reserve0;
                    uint256 amount = getAmountOut(amountIn, _reserve0, _reserve1);
                if (amount > Fee) {
                    address[] memory path = new address[](2);
                        path[0] = LP.token0();
                        path[1] = bnbAddress;
                    _swap(path, address(this), FA.allPairs(j));
                    uint amountOut = IERC20(bnbAddress).balanceOf(address(this));
                    IWETH(bnbAddress).withdraw(amountOut);
                    TransferHelper.safeTransferETH(treasury, amountOut);
                }

                    
                }

                if (Token1.balanceOf(FA.allPairs(j)) > _reserve1 && LP.token1() != bnbAddress) {
                    uint256 amountIn = Token1.balanceOf(FA.allPairs(j)) - _reserve0;
                    uint256 amount = getAmountOut(amountIn, _reserve0, _reserve1);
                if (amount > Fee) {
                    address[] memory path = new address[](2);
                        path[0] = LP.token1();
                        path[1] = bnbAddress;
                    _swap(path, address(this), FA.allPairs(j));
                    uint amountOut = IERC20(bnbAddress).balanceOf(address(this));
                    IWETH(bnbAddress).withdraw(amountOut);
                    TransferHelper.safeTransferETH(treasury, amountOut);
                }

    
                } */
           }
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

    function _swap(address[] memory path, address _to, address Pair) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = FarmageddonLibrary.sortTokens(input, output);
            IFarmageddonPair pair = IFarmageddonPair(Pair);
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
    }

    

/*

    function checkUpkeep(bytes calldata) view external override returns (bool upkeepNeeded, bytes memory) {
        // perform upkeep when timestamp is equal or more than upkeepTime
        upkeepNeeded = block.timestamp >= upKeepTime && step > 0;
    }

    // Perform Tax changes
    function performUpkeep(bytes calldata ) external override {
        require (block.timestamp >= upKeepTime && step > 0, "UpKeep Not needed, or is stopped");

        uint256 combined = (Reflections + Burn + Treasury);

        if (step == 1) {
             // tax free day
            TokenAddress.updateFee(0, 0, 0);
            step = 2;
            upKeepTime += 86400;
            
        }
       
        else if (step == 2) {
             // Appreciation day
            TokenAddress.updateFee(combined, 0, 0);
            step = 3;
            upKeepTime += 86400;
        }

        else if (step == 3) {
            // Burn day
            TokenAddress.updateFee(0, combined, 0);
            step = 4;
            upKeepTime += 86400;
        }  

        else if (step == 4) {
            // Burn day
            TokenAddress.updateFee(Reflections, Burn, Treasury);
            step = 1;
            upKeepTime += 345600;
        }  

    }  */
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