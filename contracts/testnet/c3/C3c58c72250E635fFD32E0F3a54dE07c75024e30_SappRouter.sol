pragma solidity =0.6.6;
import "./interfaces/IPancakeRouterv2.sol";
import "./interfaces/IERC20.sol";
import "./libraries/Ownable.sol";


contract SappRouter is Ownable{
    address private router;
    address private appToken;
    address private wallet;
    uint private appFee; // 1 ETH
    constructor(address _router, address _token, address _wallet, uint _appFee) public {
        router = _router;
        appToken = _token;
        wallet = _wallet;
        appFee = _appFee;
    }

    function setRouter (address _router) public onlyOwner returns(bool){
        _setRouter(_router);
        return true;
    }

    function setAppToken (address _token) public onlyOwner returns(bool){
        _setAppToken(_token);
        return true;
    }

    function setWallet(address _wallet) public onlyOwner returns(bool){
        _setWallet(_wallet);
        return true;
    }

    function setAppFee(uint _appFee) public onlyOwner returns(bool){
        _setAppFee(_appFee);
        return true;
    }

    // **** SWAP ****
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable    
    returns (uint[] memory amounts) {
        _chargeFee(path);
        (amounts) = IPancakeRouter02(router).swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable    
    returns (uint[] memory amounts) {
        _chargeFee(path);
        (amounts) = IPancakeRouter02(router).swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external payable  {
        _chargeFee(path);
        IPancakeRouter02(router).swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external    
    returns (uint[] memory amounts) {
        _chargeFee(path);
        _handleToken(path[0], amountIn);

        (amounts) = IPancakeRouter02(router).swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external {
        _chargeFee(path);
        _handleToken(path[0], amountIn);

        IPancakeRouter02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external returns (uint[] memory amounts) {
        _chargeFee(path);
        _handleToken(path[0], amountIn);

        (amounts) = IPancakeRouter02(router).swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
    ) external {
        _chargeFee(path);
        _handleToken(path[0], amountIn);

        IPancakeRouter02(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts) {
        _chargeFee(path);
        _handleToken(path[0], amountInMax);

        (amounts) = IPancakeRouter02(router).swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
    }

    function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
    ) external returns (uint[] memory amounts) {
        _chargeFee(path);
        _handleToken(path[0], amountInMax);

        (amounts) = IPancakeRouter02(router).swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
    }
    
    function _chargeFee(address[] memory path) internal {
        // Check case: BNB to app token
        if(address(path[0]) == IPancakeRouter02(router).WETH() && address(path[path.length - 1]) == address(appToken))
        {
            return;
        }

        // Setup app fee
        // Approve address(this) with appFee at appToken contract first
        // value is appFee
        // Or appFee + amountIn(or more) for case appToken === path[0];
        require(IERC20(appToken).transferFrom(msg.sender, wallet, appFee), "PAY_FEE_FIRST");
    }

    function _handleToken(address _token, uint _amount) internal {
        // Need to approve at path[0] token contract
        // value is _amount or more
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Transfer Failed");
        require(IERC20(_token).approve(address(router), _amount), "Approve Failed");
    }

    function _setRouter(address _router) internal {
        router = _router;
    }
    function _setAppToken(address _token) internal {
        appToken = _token;
    }
    function _setWallet(address _wallet) internal {
        wallet = _wallet;
    }
    function _setAppFee(uint _appFee) internal {
        appFee = _appFee;
    }

    function getRouter() public view returns (address) {
        return router;
    }
    function getAppToken() public view returns (address) {
        return appToken;
    }
    function getWallet() public view returns (address) {
        return wallet;
    }
    function getAppFee() public view returns (uint) {
        return appFee;
    }

}

pragma solidity =0.6.6;
import "./IPancakeRouter.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity =0.6.6;

//import the ERC20 interface

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

pragma solidity =0.6.6;
import "./Context.sol";
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
    constructor() public {
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

pragma solidity =0.6.6;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

pragma solidity =0.6.6;

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

    function _msgData() internal pure virtual returns (bytes memory) {
        return msg.data;
    }
}