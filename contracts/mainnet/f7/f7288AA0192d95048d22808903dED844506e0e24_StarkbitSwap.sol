/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
    * @dev Returns the decimals.
    */
    function decimals() external view returns (uint256);
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
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IROUTER {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] memory path)
        external
        view
    returns (uint[] memory amounts);
    
    function WETH() external pure returns (address);
}

interface IRouterPair {
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

contract StarkbitSwap is Ownable {
    IROUTER router;
    uint public swapETHToTokensFee;

    constructor (address _router, uint _swapETHToTokensFee) {
        router = IROUTER(_router); // Router adress
        swapETHToTokensFee = _swapETHToTokensFee; // Eth to Token Fee
    }

    function swapExactETHForTokens (
        address tokenToSwap,
        uint256 amountOutMin //slip page
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenToSwap;
        uint256 ammountInWithTax = msg.value * (1000 - swapETHToTokensFee) / 1000;
        router.swapExactETHForTokens{value: ammountInWithTax}(amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    // Supporting fee transfer token
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address tokenToSwap,
        uint256 amountOutMin //slip page
    ) external payable {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = tokenToSwap;
        uint256 ammountInWithTax = msg.value * (1000 - swapETHToTokensFee) / 1000;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ammountInWithTax}(amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    function swapExactTokensForETH(
        address token,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();
        // Transfer value to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        router.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    // Supporting fee transfer token
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address token,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = router.WETH();
        // Transfer value to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    
    function swapExactTokensForTokens (
        address token,
        address tokenToSwap,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenToSwap;
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        // Transfer value to this contract
        router.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }
    
    // Supporting fee transfer token
    function swapExactTokensForTokensSupportingFeeOnTransferTokens (
        address token,
        address tokenToSwap,
        uint256 amountIn,
        uint256 amountOutMin //Slip page
    ) external {
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = tokenToSwap;
        IERC20(token).transferFrom(msg.sender, address(this), amountIn);
    
        //next we need to allow the router router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the router contract to spend the tokens in this contract 
        IERC20(token).approve(address(router), amountIn);
        // Transfer value to this contract
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, msg.sender, block.timestamp + (1000 * 60 *60 * 100));
    }

    // calculate price based on pair reserves
   function getTokenPrice(address token, address pair, uint amountIn) public view returns(uint[] memory){
        address[] memory path = new address[](2);
        path[0] = token;
        path[1] = pair;
       return router.getAmountsOut(amountIn, path);
    }

    function setFee(uint _swapETHToTokensFee) external {
        swapETHToTokensFee = _swapETHToTokensFee; // Eth to Token Fee
    }

    function setRouterAddress(address _router) external {
        router = IROUTER(_router); 
    }
    
    function wethAddress() public view returns (address)  {
        return router.WETH();
    }

    function contractAddress() public view returns (address)  {
        return address(this);
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}