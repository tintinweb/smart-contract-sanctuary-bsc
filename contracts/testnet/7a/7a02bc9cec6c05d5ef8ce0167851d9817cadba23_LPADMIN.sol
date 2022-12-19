/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// File: interfaces/ISwapRouter.sol


pragma solidity 0.8.17;
interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
}
// File: interfaces/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.10;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    // function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: utils/Context.sol


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

// File: utils/Ownable.sol


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

// File: LPADMIN.sol



pragma solidity 0.8.17;




// interface IERC20 {

//     function balanceOf(address account) external view returns (uint256);

//     function transfer(address recipient, uint256 amount) external returns (bool);

//     function allowance(address owner, address spender) external view returns (uint256);

//     function approve(address spender, uint256 amount) external returns (bool);

//     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

//     event Transfer(address indexed from, address indexed to, uint256 value);
//     event Approval(address indexed owner, address indexed spender, uint256 value);
// }

// interface ISwapRouter {
//     function factory() external pure returns (address);

//     function swapExactTokensForTokensSupportingFeeOnTransferTokens(
//         uint amountIn,
//         uint amountOutMin,
//         address[] calldata path,
//         address to,
//         uint deadline
//     ) external;

//     function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint amountADesired,
//         uint amountBDesired,
//         uint amountAMin,
//         uint amountBMin,
//         address to,
//         uint deadline
//     ) external returns (uint amountA, uint amountB, uint liquidity);
// }


contract LPADMIN is Ownable{

    uint256 private constant MAX = ~uint256(0);
    address public usdt;
    address public swapRouter;
    address public _hive;
    address public operator;

    modifier onlyOwnerOrOperator() {
    require(owner() == _msgSender() || _msgSender() == operator, "Ownable: caller is not the owner or operator");
    _;
    }
  
    constructor(){
        usdt = address(0x758c3B41bc9Af877AFccD8e19e55bB0237E75b95);
        swapRouter = address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        IERC20(usdt).approve(address(swapRouter), MAX);
        
        IERC20(usdt).approve(address(swapRouter), MAX);
    }

    
    // 营销地址 添加流动性
    function doLiquidity() public onlyOwnerOrOperator {

        uint256 tokensToLiquify = IERC20(_hive).balanceOf(address(this));

        // 压在lp池的部分代币
        uint256 amountToLiquify = tokensToLiquify / 2;

        address[] memory path = new address[](2);

        // 初始化 swap路径
        path[0] = address(_hive);

        path[1] = address(usdt);

        // 做swap交易 换取 usdt
        ISwapRouter(swapRouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToLiquify,
            0,
            path,
            address(this),
            block.timestamp
        );


        uint256 amountUsdt = IERC20(usdt).balanceOf(address(this));

        // 添加流动性
        ISwapRouter(swapRouter).addLiquidity(
            _hive, 
            usdt, 
            amountToLiquify, 
            amountUsdt, 
            0, 
            0, 
            address(this), 
            block.timestamp
        );

        // emit AutoLiquify(amountETHLiquidity, amountToLiquify);
    }


    function _safeTransfer(address token, address to, uint value) private {
        // 在一个合约调用另一个合约中，可以通过接口合约调用
        // 没有接口合约的情况下，可以使用底层的call方法，
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        // 校验上面方法调用的结果
        // bool 为true && (data的长度为0 || abi反解码之后的bool = true)
        require(success && (data.length == 0 || abi.decode(data, (bool))), "LIQUDITYADMIN: TRANSFER_FAILED");
    }


    function setHive(address hive_)external onlyOwner{
        _hive = hive_;
        operator = hive_;
        IERC20(_hive).approve(address(swapRouter), MAX);
    }

    function withdrawToken(address token, address to)external onlyOwner{
        uint256 amount = IERC20(token).balanceOf(address(this));
        _safeTransfer(token, to, amount);
    }


}