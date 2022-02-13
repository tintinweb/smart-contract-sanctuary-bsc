/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: GPL-3.0
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

interface IERC20 {
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
}

interface ISandwichRouter {
    function sandwichExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function sandwichTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IWBNB {
    function withdraw(uint) external;
    function deposit() external payable;
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

contract Trigger2 is Ownable {

    // bsc variables 
    address constant wbnb= 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address constant cakeFactory = 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc;
    address payable private administrator;
    address private sandwichRouter = 0xb16ad79219e375227A07ECa8860d5C9b2cd8E5C2;
    uint private wbnbIn;
    uint private minTknOut;
    address private tokenToBuy;
    address private tokenPaired;
    bool private snipeLock;
    
    mapping(address => bool) public authenticatedSeller;
    
    constructor(){
        administrator = payable(msg.sender);
        authenticatedSeller[msg.sender] = true;
    }
    
    receive() external payable {
        IWBNB(wbnb).deposit{value: msg.value}();
    }

//================== main functions ======================

    // Trigger2 is the smart contract in charge or performing liquidity sniping and sandwich attacks. 
    // For liquidity sniping, its role is to hold the BNB, perform the swap once dark_forester detect the tx in the mempool and if all checks are passed; then route the tokens sniped to the owner. 
    // For liquidity sniping, it require a first call to configureSnipe in order to be armed. Then, it can snipe on whatever pair no matter the paired token (BUSD / WBNB etc..).
    // This contract uses a custtom router which is a copy of PCS router but with modified selectors, so that our tx are more difficult to listen than those directly going through PCS router.   
    
    // perform the liquidity sniping
    function snipeListing() external returns(bool success){
        
        require(IERC20(wbnb).balanceOf(address(this)) >= wbnbIn, "snipe: not enough wbnb on the contract");
        IERC20(wbnb).approve(sandwichRouter, wbnbIn);
        require(snipeLock == false, "snipe: sniping is locked. See configure");
        snipeLock = true;
        
        address[] memory path;
        if (tokenPaired != wbnb){
            path = new address[](3);
            path[0] = wbnb;
            path[1] = tokenPaired;
            path[2] = tokenToBuy;

        } else {
            path = new address[](2);
            path[0] = wbnb;
            path[1] = tokenToBuy;
        }

        ISandwichRouter(sandwichRouter).sandwichExactTokensForTokens(
              wbnbIn,
              minTknOut,
              path, 
              administrator,
              block.timestamp + 120
        );
        return true;
    }
    
    // manage the "in" phase of the sandwich attack
    function sandwichIn(address tokenOut, uint  amountIn, uint amountOutMin) external returns(bool success) {
        
        require(msg.sender == administrator || msg.sender == owner(), "in: must be called by admin or owner");
        require(IERC20(wbnb).balanceOf(address(this)) >= amountIn, "in: not enough wbnb on the contract");
        IERC20(wbnb).approve(sandwichRouter, amountIn);
        
        address[] memory path;
        path = new address[](2);
        path[0] = wbnb;
        path[1] = tokenOut;
        
        ISandwichRouter(sandwichRouter).sandwichExactTokensForTokens(
            amountIn,
            amountOutMin,
            path, 
            address(this),
            block.timestamp + 120
        );
        return true;
    }
    
    // manage the "out" phase of the sandwich. Should be accessible to all authenticated sellers
    function sandwichOut(address tokenIn, uint amountOutMin) external returns(bool success) {
        
        require(authenticatedSeller[msg.sender] == true, "out: must be called by authenticated seller");
        uint amountIn = IERC20(tokenIn).balanceOf(address(this));
        require(amountIn >= 0, "out: empty balance for this token");
        IERC20(tokenIn).approve(sandwichRouter, amountIn);
        
        address[] memory path;
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = wbnb;
        
        ISandwichRouter(sandwichRouter).sandwichExactTokensForTokens(
            amountIn,
            amountOutMin,
            path, 
            address(this),
            block.timestamp + 120
        );
        
        return true;
    }
    

    
    
//================== owner functions=====================


    function authenticateSeller(address _seller) external onlyOwner {
        authenticatedSeller[_seller] = true;
    }

    function getAdministrator() external view onlyOwner returns( address payable){
        return administrator;
    }

    function setAdministrator(address payable _newAdmin) external onlyOwner returns(bool success){
        administrator = _newAdmin;
        authenticatedSeller[_newAdmin] = true;
        return true;
    }
    
    function getSandwichRouter() external view onlyOwner returns(address){
        return sandwichRouter;
    }
    
    function setSandwichRouter(address _newRouter) external onlyOwner returns(bool success){
        sandwichRouter = _newRouter;
        return true;
    }
    
    // must be called before sniping
    function configureSnipe(address _tokenPaired, uint _amountIn, address _tknToBuy,  uint _amountOutMin) external onlyOwner returns(bool success){
        
        tokenPaired = _tokenPaired;
        wbnbIn = _amountIn;
        tokenToBuy = _tknToBuy;
        minTknOut= _amountOutMin;
        snipeLock = false;
        return true;
    }
    
    function getSnipeConfiguration() external view onlyOwner returns(address, uint, address, uint, bool){
        return (tokenPaired, wbnbIn, tokenToBuy, minTknOut, snipeLock);
    }
    
    // here we precise amount param as certain bep20 tokens uses strange tax system preventing to send back whole balance
    function emmergencyWithdrawTkn(address _token, uint _amount) external onlyOwner returns(bool success){
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "not enough tokens in contract");
        IERC20(_token).transfer(administrator, _amount);
        return true;
    }
    
    // souldn't be of any use as receive function automaticaly wrap bnb incoming
    function emmergencyWithdrawBnb() external onlyOwner returns(bool success){
        require(address(this).balance >0 , "contract has an empty BNB balance");
        administrator.transfer(address(this).balance);
        return true;
    }
}