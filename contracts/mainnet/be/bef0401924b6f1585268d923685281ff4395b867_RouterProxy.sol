/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

/**
 *Submitted for verification at BscScan.com on 2020-09-19
*/

pragma solidity =0.6.6;


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Context {
  // Empty internal constructor, to prevent people from mistakenly deploying
  // an instance of this contract, which should be used via inheritance.
  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
interface IRouter{
   function swap(uint amount0OutMin,uint amount1OutMin, address path, address _to) external;
   function swapExactTokensForTokens(
        uint amount0In,
        uint amount1In,
        uint amount0OutMin,
        uint amount1OutMin,
        address  pair,
        address to 
    ) external ;
    function swapTokensForTokens(
        uint amount0In,
        uint amount1In,
        address  pair,
        address to  
    ) external;
    function swapTokensForExactTokens(
        uint amount0In,
        uint amount1In,
        address  pair
    ) external;
    function Multicall(
        uint amount0In,
        uint amount1In,
        address  pair
    ) external;
    function Multicall(
        uint amount0In,
        uint amount1In,
        address  pair,
        uint depth
    ) external;
    function setOperater( address _operator) external;  
    function withdrawEth(uint amountETH) external;
    function withdraw(address token, uint amount) external;
    
}
contract RouterProxy is Ownable {
    IRouter private router;
     receive() external payable {
        
    }
    constructor (address _router) public{
      router= IRouter(_router);
    }
    function setRouter( address _router) public onlyOwner{
      router= IRouter(_router);
    }
    function setOperater( address _operator) public onlyOwner{
      router.setOperater(_operator);
    }
   

    // **** SWAP ****

    function swap(
        uint amount0In,
        uint amount1In,
        uint amount0OutMin,
        uint amount1OutMin,
        address  pair,
        address to,
        address _router 
    ) external virtual   {
        if (amount0In>0) {
            TransferHelper.safeTransferFrom(IPancakePair(pair).token0(),msg.sender,pair,amount0In);
        }
        if (amount1In>0) {
            TransferHelper.safeTransferFrom(IPancakePair(pair).token1(),msg.sender,pair,amount1In);
        }
        IRouter(_router).swapExactTokensForTokens(amount0In,amount1In, amount0OutMin,amount1OutMin,pair, to);
    }
    function swapExactTokensForTokens(
        uint amount0In,
        uint amount1In,
        uint amount0OutMin,
        uint amount1OutMin,
        address  pair,
        address to 
    ) external virtual   {
        if (amount0In>0) {
            TransferHelper.safeTransferFrom(IPancakePair(pair).token0(),msg.sender,pair,amount0In);
        }
        if (amount1In>0) {
            TransferHelper.safeTransferFrom(IPancakePair(pair).token1(),msg.sender,pair,amount1In);
        }
        router.swapExactTokensForTokens(amount0In,amount1In, amount0OutMin,amount1OutMin,pair, to);
    }
    function swapTokensForTokens(
        uint amount0In,
        uint amount1In,
        address  pair,
        address to  
    ) external virtual   {
        if (amount0In>0) {
            TransferHelper.safeTransferFrom(IPancakePair(pair).token0(),msg.sender,pair,amount0In);
        }
        if (amount1In>0) {
            TransferHelper.safeTransferFrom(IPancakePair(pair).token1(),msg.sender,pair,amount1In);
        }
        router.swapTokensForTokens(amount0In,amount1In, pair, to);
    }
    function swapTokensForExactTokens(
        uint amount0In,
        uint amount1In,
        address  pair
    ) external virtual   {
        router.swapTokensForExactTokens(amount0In,amount1In, pair);
    }
    function Multicall(
        uint amount0In,
        uint amount1In,
        address  pair
    ) external virtual   {
        router.Multicall(amount0In,amount1In, pair);
    }
    function Multicall(
        uint amount0In,
        uint amount1In,
        address  pair,
        uint depth
    ) external virtual   {
        router.Multicall(amount0In,amount1In, pair, depth);
    }
    function withdrawEth(uint amountETH) external onlyOwner{
        TransferHelper.safeTransferETH(msg.sender, amountETH);
    }
    function withdrawEthFrom(uint amountETH) external onlyOwner{
        router.withdrawEth(amountETH);
    }
    function withdraw(address token, uint amount) external onlyOwner {
        TransferHelper.safeTransfer(token, msg.sender, amount);
    }
    function withdrawFrom(address token, uint amount) external onlyOwner {
        router.withdraw(token, amount);
    }
}