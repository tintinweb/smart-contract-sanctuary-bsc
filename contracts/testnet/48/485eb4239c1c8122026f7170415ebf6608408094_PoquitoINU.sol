/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

//SPDX-License-Identifier:Unlicensed
pragma solidity 0.8.17;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address owner_) {
        _transferOwnership(owner_);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract PoquitoINU is Context, IERC20, Ownable{

    // ERC20 starts
    uint256 internal _totalSupply;
    mapping (address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private _name;
    string private _symbol;
    // ERC20 ends


    // tax starts
    uint256 private _taxRate;
    uint256 _tokensToSell;
    bool _sellStatus;
    bool public inSwapAndLiquify;
    mapping(address => bool) private _excludedFromFee;
    // tax ends

    // fee takers starts
    address payable _marketingWallet;
    address payable _teamWallet;
    // fee takers ends

    // uniswap starts
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public currentRouter;
    address public immutable uniswapV2Pair;
    // uniswap ends

    //events start
    event Log(string, uint256);
    event AuditLog(string, address);
    event SellStatusLog(string,bool);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapTokensForETH(uint256 amountIn, address[] path);
    // events ends



    constructor(
        
        uint256 totalSupply_,string memory name_,
        string memory symbol_,address owner_,uint256 taxRate_,uint256 tokensToSell_,
        address payable marketingWallet_,address payable teamWallet_,bool sellStatus_) Ownable(owner_
    ){

        // ERC20 starts
        _totalSupply = totalSupply_ * 10**18;
        _name = name_;
        _symbol = symbol_;
        _balances[owner_] = _totalSupply;
        // ERC20 ends

        // tax starts
        _taxRate = taxRate_;
        _tokensToSell = tokensToSell_ * 10**18;
        _excludedFromFee[owner_] = true;
        _sellStatus = sellStatus_;
        // tax ends

        // fee takers start
        _marketingWallet = payable(marketingWallet_);
        _teamWallet = payable(teamWallet_);
        // fee takers end

        // uniswap starts
        if (block.chainid == 56) {
            currentRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // PCS Router
        } else if (block.chainid == 97) {
            
            currentRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // PCS Testnet
        }

        else{

            revert();
        } 

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(currentRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
                        .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        // uniswap ends

        // events start
        emit Transfer(address(0), owner_, _totalSupply);
        // events ends
    }

    // swapAndLiquify starts
    modifier swapAndLiquifyReentrancyguard() {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }



    // swapAndLiquify ends

    // ERC20 starts

    function name() external view returns (string memory){

        return _name;
    }

    function symbol() external view returns (string memory){

        return _symbol;
    }

  
    function totalSupply() external view returns (uint256){

        return _totalSupply;
    }

    function decimals() external pure returns (uint8){

        return 18;
    }

    function balanceOf(address account) public view returns (uint256){

        return _balances[account];
        
    }

    function transfer(address to, uint256 amount) external returns (bool){

        _transfer(_msgSender(),to,amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256){

        return _allowances[owner][spender];

    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function burn(uint256 amount) external onlyOwner{

        address account = _msgSender();
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

    }

    // ERC20 ends


    // ERC20 helper functions start

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
        ) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(
            !inSwapAndLiquify && 
            _sellStatus &&
            from != uniswapV2Pair

        ){

            swapAndLiquify();
        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 caculatedAmount = caculateFees(from,to,amount);
        _balances[from] = fromBalance - amount;
        _balances[to] += caculatedAmount;

        emit Transfer(from, to, amount);

    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    
    function caculateFees(address from,address to,uint256 amount_) private returns(uint256) {

        if(_excludedFromFee[from] || _excludedFromFee[to]){

            return amount_;
        }

        if(_taxRate == 0){

            return amount_;
        }

        uint256 feeToTake = (amount_ * _taxRate) / 100;
        _balances[address(this)] += feeToTake;
        uint256 amountAfterFee = amount_ - feeToTake;
        return amountAfterFee;

    }

    // ERC20 helper functions end



    // tax starts


    function excludeFromFee(address account) external onlyOwner{

        _excludedFromFee[account] = true;
        emit AuditLog(
            "We have excluded the following wallet from paying tax",
            account
        );
        
    }

    function includeFee(address account) external onlyOwner{

        _excludedFromFee[account] = false;
        emit AuditLog("We have included the following wallet to pay tax", account);

    }

    function isExcludedFromFee(address account) external view returns(bool){

        return _excludedFromFee[account];

    }

    function tokensToSell() external view returns(uint256){

        return _tokensToSell;

    }

    function setTokensToSell(uint256 amount) external onlyOwner{

        _tokensToSell = amount * 10**18;
        emit Log(
            "tokens to sell has been updated",
            _tokensToSell
        );
        
    }

    function setTaxToZero() external onlyOwner{

        _taxRate = 0;
        emit Log("Tax Rate is now",_taxRate);
    }

    function setTaxToFive() external onlyOwner{

        _taxRate = 5;
        emit Log("Tax is now",_taxRate);
    }

    function setMarketingWallet(address wallet) external onlyOwner{

        require(
            wallet != address(0),
            "cannot be ZERO wallet"
        );
        _marketingWallet = payable(wallet);

        emit AuditLog("Marketing wallet updated", wallet);
    }

    function setTeamWallet(address wallet) external onlyOwner{

        require(
            wallet != address(0),
            "cannot be ZERO wallet"
        );
        _teamWallet = payable(wallet);

        emit AuditLog("Team wallet updated", wallet);
    }


    function taxRate() external view returns(uint256){

        return _taxRate;
    }

    function marketingWallet() external view returns(address){

        return _marketingWallet;

    }

    function teamWallet() external view returns(address){

        return _teamWallet;

    }

    function setSellStatus(bool status) external onlyOwner{

        _sellStatus = status;
        emit SellStatusLog("Token Selling status has changed to", status);
    }

    function sellStatus() external view returns(bool){

        return _sellStatus;
    }



    // tax ends


    // uniswap starts

    function swapAndLiquify() private swapAndLiquifyReentrancyguard{

        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 contractETHBalance = address(this).balance;
        uint256 minimumTokensToSell;

        if(contractTokenBalance == 0){

            minimumTokensToSell = 0;
            return;
        }

        if(contractTokenBalance >= _tokensToSell){

            minimumTokensToSell = _tokensToSell;

        }

        if(contractTokenBalance < _tokensToSell){

            minimumTokensToSell = contractTokenBalance;
        }



        uint256 tokensForLiquidity = (minimumTokensToSell * 20) / 100;

        uint256 halfTokensForLiquidity = tokensForLiquidity / 2;
        
        swapTokensForEth(halfTokensForLiquidity);
        
        uint256 ETHForLiquidity = address(this).balance - contractETHBalance;

        addLiquidity(halfTokensForLiquidity, ETHForLiquidity);
        emit SwapAndLiquify(
            halfTokensForLiquidity,
            ETHForLiquidity,
            halfTokensForLiquidity
        );

        uint256 remainingTokens = minimumTokensToSell - tokensForLiquidity; 

        swapTokensForEth(remainingTokens);

        uint256 remainingETH = address(this).balance;
       
        uint256 ETHForMarketingAndTeam = remainingETH / 2 ;
        
        transferToAddressETH(_marketingWallet, ETHForMarketingAndTeam);
        
        transferToAddressETH(_teamWallet, ETHForMarketingAndTeam);


    }

    function swapAndLiquifyExternal() external onlyOwner{

        swapAndLiquify();
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);


    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {


        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private{
        recipient.transfer(amount);
    }

    // uniswap ends

    // extract starts

    function ExtractContractTokens(address to, uint256 amount) external onlyOwner{

        require(amount > 0 , "amount must be greater than zero");
        _balances[address(this)] -= amount;
        _balances[to] += amount;
        emit Log("We have extracted the smart contract tokens", amount);

    }

    function ExtractOtherTokens(address tokenAddress,address to, uint256 amount) external onlyOwner{

        require(tokenAddress != address(this) , "use ExtractContractTokens to extract this contract's tokens");           
        IERC20(tokenAddress).transfer(to, amount);
        emit Log("We have extracted non smart contract tokens", amount);



    }

    receive() external payable {}
    function withdraw(address payable to) external payable onlyOwner {
        require(payable(to).send(address(this).balance));
    }

    // extract ends

    
    


}