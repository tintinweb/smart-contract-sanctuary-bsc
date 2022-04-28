/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: MIT

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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

//////import the uniswap router
//the contract needs to use swapExactTokensForTokens
//this will allow us to import swapExactTokensForTokens into our contract

interface IUniswapV2Router {
    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        //amount of tokens we are sending in
        uint256 amountIn,
        //the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
        //list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
        //this is the address we are going to send the output tokens to
        address to,
        //the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUniswapV2Factory {
    function getPair(address token0, address token1) external returns (address);
}

contract AirdropEVOC is Ownable {
    //address of the uniswap v2 router
    address private constant UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //address of WETH token.  This is needed because some times it is better to trade through WETH.
    //you might get a better price using WETH.
    //example trading from token A to WETH then WETH to token B might result in a better price
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public tokenToBuy; // Evocardano.
    address public baseToken; // ADA
    address public wallet;
    uint256 public minAmountToSwap;

    event MinAmountToSwapUpdated(uint256 prevAmount, uint256 newAmount);
    event TokenToBuyUpdated(address prevToken, address newToken);
    event BaseTokenUpdated(address prevToken, address newToken);
    event WalletUpdated(address prevWallet, address newWallet);

    receive() external payable {}

    // {_wallet} It's where the funds will go
    constructor(
        address _wallet
    ) {

        wallet = _wallet;
        minAmountToSwap = 0;
        tokenToBuy = 0x086CC8e468B3cB5494F18a7aBc2De1321306aF12;
        baseToken = 0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47;

    }

    // Update the minimum amount of {baseToken} that is required to make the exchange. Set to zero to have no limit.
    function updateMinAmountToSwap(uint256 newAmount) external onlyOwner {
        emit MinAmountToSwapUpdated(minAmountToSwap, newAmount);
        minAmountToSwap = newAmount;
    }

    // Update the token to be purchased.
    function updateTokenToBuy(address newTokenToBuy) external onlyOwner {
        require(
            newTokenToBuy != address(0),
            "New Token to buy is Address Zero."
        );
        require(newTokenToBuy != tokenToBuy, "Cannot be the same Token.");

        // Safety check.
        IERC20(newTokenToBuy).balanceOf(address(this));

        emit TokenToBuyUpdated(tokenToBuy, newTokenToBuy);
        tokenToBuy = newTokenToBuy;
    }

    // Update the {baseToken} with which the purchase is made.
    function updateBaseToken(address newBaseToken) external onlyOwner {
        require(newBaseToken != address(0), "New base Token is Address Zero.");
        require(newBaseToken != baseToken, "Cannot be the same Token.");

        // Safety check.
        IERC20(newBaseToken).balanceOf(address(this));

        emit BaseTokenUpdated(tokenToBuy, newBaseToken);
        baseToken = newBaseToken;
    }

    // Update the {wallet} where the balances obtained will be sent.
    // Passing {True} as the second parameter, the balance of {baseToken} that has so far is sent.
    function updateWallet(address newWallet, bool sendCurrentBalance)
        external
        onlyOwner
    {
        require(newWallet != address(0), "New Wallet is Address Zero.");

        // silences reentry warning.
        address oldWallet = wallet;
        wallet = newWallet;

        if (sendCurrentBalance) {
            uint256 bal = IERC20(baseToken).balanceOf(address(this));
            require(
                IERC20(baseToken).transfer(oldWallet, bal),
                "TOKENSWAP::Transfer Failed"
            );
        }

        emit WalletUpdated(oldWallet, newWallet);
    }

    // You can send the amount that will be debited from your account and get the job done.
    function fund(uint256 amount) external {
        // ADA pre approval by msg.sender is required.
        require(
            IERC20(baseToken).transferFrom(msg.sender, address(this), amount),
            "TOKENSWAP::Transfer failed"
        );

        work();
    }

    // It works with the balance of {baseToken} in the contract.
    function work() public {
        uint256 bal = IERC20(baseToken).balanceOf(address(this));

        if (bal <= 0) return;

        uint256 amountToSwap = (bal * 80) / 100;

        if (amountToSwap < minAmountToSwap) return;

        swap(baseToken, tokenToBuy, amountToSwap, 0, wallet);

        uint256 newAmount = IERC20(baseToken).balanceOf(address(this));

        require(
            IERC20(baseToken).transfer(wallet, newAmount),
            "Base token could not be transferred"
        );
    }


    function clearBalance(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(this), "Cannot be this token");

        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));

        IERC20(tokenAddress).transfer(wallet, amount);
    }

        /* Airdrop Begins */

    function airdrop(address[] calldata addresses, uint256[] calldata tokens) external onlyOwner {
        uint256 SCCC = 0;
        uint256 bal = IERC20(tokenToBuy).balanceOf(address(this));
        require(addresses.length == tokens.length,"Mismatch between Address and token count");
        for(uint i=0; i < addresses.length; i++){
            SCCC = SCCC + tokens[i];
        }

        require(bal >= SCCC, "Not enough tokens to airdrop");

        for(uint i=0; i < addresses.length; i++){
            IERC20(tokenToBuy).transfer(addresses[i], tokens[i] * (10**18));
        }

    }

    function multiTransfer_fixed( address[] calldata addresses, uint256 tokens) external onlyOwner {

        require(addresses.length < 2001,"GAS Error: max airdrop limit is 2000 addresses"); // to prevent overflow

        uint256 SCCC = tokens * addresses.length;

        uint256 bal = IERC20(tokenToBuy).balanceOf(address(this));

        require(bal >= SCCC, "Not enough tokens in wallet");

        for(uint i=0; i < addresses.length; i++){
            IERC20(tokenToBuy).transfer(addresses[i], tokens * (10**18));
            
        }    
    }

    //this swap function is used to trade from one token to another
    //the inputs are self explainatory
    //token in = the token address you want to trade out of
    //token out = the token address you want as the output of this trade
    //amount in = the amount of tokens you are sending in
    //amount out Min = the minimum amount of tokens you want out of the trade
    //to = the address you want the tokens to be sent to

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) internal {
        //first we need to transfer the amount in tokens from the msg.sender to this contract
        //this contract will have the amount of in tokens
        // IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        //next we need to allow the uniswapv2 router to spend the token we just sent to this contract
        //by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract
        if (
            IERC20(_tokenIn).allowance(address(this), UNISWAP_V2_ROUTER) <
            _amountIn
        ) {
            require(
                IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, type(uint256).max),
                "TOKENSWAP::Approve failed"
            );
        }

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }
        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        IUniswapV2Router(UNISWAP_V2_ROUTER)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amountIn,
                _amountOutMin,
                path,
                _to,
                block.timestamp
            );
    }

    //this function will return the minimum amount from a swap
    //input the 3 parameters below and it will return the minimum amount out
    //this is needed for the swap function above
    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view returns (uint256) {
        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (_tokenIn == WETH || _tokenOut == WETH) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WETH;
            path[2] = _tokenOut;
        }

        uint256[] memory amountOutMins = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .getAmountsOut(_amountIn, path);
        return amountOutMins[path.length - 1];
    }

    // The owner can withdraw tokens that have been sent to the contract.
    function withdrawTokenStuck(address token) external onlyOwner {
        if (token != address(0)) {
            uint256 bal = IERC20(token).balanceOf(address(this));
            require(
                IERC20(token).transfer(msg.sender, bal),
                "TOKENSWAP::Withdraw Failed"
            );
        } else {
            uint256 bal = payable(this).balance;
            payable(msg.sender).transfer(bal);
        }
    }

}