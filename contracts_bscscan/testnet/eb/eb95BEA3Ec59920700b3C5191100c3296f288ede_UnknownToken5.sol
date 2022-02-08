/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

// SPDX-License-Identifier: MIT
//Altered: marketing wallet, dev wallet, added 3 zeroes to supply and distribute
//And the addresses
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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
contract UnknownToken5 is Context {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private MarketMaker;
    mapping(address => bool) public ExcludedFromFees;
    mapping(address => bool) public ExcludedFromRefferal;
    mapping(address => address) public refferedFrom;
    mapping(address => bool) public isReffered;

    address contractOwner;
    address marketingWalletAddr = 0x5ddA5C00e7E9aB627566584a171B73B7469E0693;
    address devWalletAddr = 0xDe31fE1a92200B1c04D73E0E284b9027299b333c;

    bool Fees = true;

    IUniswapV2Router02 uniswapRouter;
    address WBNBPair;
    address WBNB;

    uint DistributeFeesAt = 100000 * (10 **18);

    uint8 LiquidityFee = 3;
    uint8 DevFee = 2;
    uint8 MarketingFee = 5;
    uint8 RefferalFee = 5;

    string public name = "NeverGonnaGiveYouUp5";
    string public symbol = "RickRoll5";
    uint public totalSupply = 10000000 * (10 ** 18);
    uint8 public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event RefferalBonus(address indexed feesTo , address indexed feesFrom , uint value);
    event Reffered(address indexed reffered,address indexed refferedFrom);

    constructor() {
        _balances[msg.sender] = totalSupply;
        contractOwner = msg.sender;
        uniswapRouter = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); //testnet
        WBNBPair = IUniswapV2Factory(uniswapRouter.factory()).createPair(uniswapRouter.WETH(),address(this));
        WBNB = uniswapRouter.WETH();
        MarketMaker[WBNBPair] = true;

        ExcludedFromFees[address(this)] = true;
        ExcludedFromFees[contractOwner] = true;
        //Added to testV2.0
        ExcludedFromFees[WBNBPair] = true;
        ExcludedFromFees[address(uniswapRouter)] = true;

        ExcludedFromRefferal[address(this)] = true;
        ExcludedFromRefferal[contractOwner] = true;
        ExcludedFromRefferal[WBNBPair] = true;
        ExcludedFromRefferal[address(uniswapRouter)] = true;
    }

    receive() external payable {}

    fallback() external {}

    modifier onlyOwner() {
        require(contractOwner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function ExcludeWalletFromFees(address addr , bool state) public onlyOwner {
        ExcludedFromFees[addr] = state;
    }

    function SetFees(bool state) public onlyOwner {
        Fees = state;
    }

    function ExcludeWalletFromRefferal(address addr , bool state) public onlyOwner {
        ExcludedFromRefferal[addr] = state;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function detectBuy(address from , address to) internal view returns(bool) {
        if(MarketMaker[from] || from == address(uniswapRouter)) {
            return true;
        } else {
            return false;
        }
    }

    function detectSell(address from, address to) internal view returns(bool) {
        if(MarketMaker[to] || to == address(uniswapRouter) ){  
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal  {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        bool buy = detectBuy(sender,recipient);
        bool sell = detectSell(sender,recipient);

        if(!sell && isReffered[recipient] == false && ExcludedFromRefferal[recipient] == false) {
            refferedFrom[recipient] = sender;
            isReffered[recipient] = true;
            emit Reffered(recipient,sender);
        }

        if(sender == contractOwner || (sender == address(uniswapRouter) && MarketMaker[recipient]) || (MarketMaker[sender] && recipient == address(uniswapRouter)) ){
            internalTransfer(sender,recipient,amount);
            return;
        }

        if(!sell && ExcludedFromRefferal[recipient] == false) {
            require(isReffered[recipient] == true,"Not Reffered");
        }

        bool takeFees = true;

        if(Fees){
            
            if(ExcludedFromFees[sender] == true){
                takeFees = false;
            }
            
            if(buy && ExcludedFromRefferal[recipient] == false){ //TODO: still need to identify buys
                amount = takeRefferalFees(recipient,amount);
            } 

            if(takeFees){
                amount = takeLiquidityFees(sender,amount);
                amount = takeMarketingFees(sender,amount);
                amount = takeDevFees(sender,amount);
            }
            
        }
        
        internalTransfer(sender,recipient,amount);

        if (balanceOf(address(this)) >= DistributeFeesAt && !buy && !sell) {
            uint balanceOfContract = balanceOf(address(this));
            uint devEth = DevFee * balanceOfContract / 100;
            uint marketingEth = MarketingFee * balanceOfContract / 100;
            swapAndSend(devEth,devWalletAddr);
            swapAndSend(marketingEth,marketingWalletAddr);
            addLp(balanceOf(address(this))); 
        }   



    }

    function addLp(uint256 tokens) private {
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half);
        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(otherHalf, newBalance);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapRouter), tokenAmount);
        uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            address(0),
            block.timestamp
        );

    }

    function swapTokensForEth(uint amount) internal {

        _approve(address(this),address(uniswapRouter),amount);

        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = uniswapRouter.WETH();
        
        uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(amount , 0 ,path,address(this), block.timestamp);

    }

    function takeRefferalFees(address from,uint256 amount) internal returns(uint) {
        uint refferalTokens = RefferalFee * amount / 100;
        internalTransfer(from,refferedFrom[from],refferalTokens);
        emit RefferalBonus(refferedFrom[from],from,refferalTokens);
        return amount - refferalTokens;
    }

    function takeLiquidityFees(address from, uint256 amount) internal returns(uint256){
        uint256 LiquidityTokens = LiquidityFee * amount / 100;
        internalTransfer(from,address(this),LiquidityTokens);
        return amount - LiquidityTokens;
    }

    function takeDevFees(address from , uint amount) internal returns(uint){
        uint256 DevTokens = DevFee * amount / 100;
        internalTransfer(from,address(this),DevTokens);
        return amount - DevTokens;
    }

    function takeMarketingFees(address from , uint amount) internal returns(uint){
        uint256 marketingTokens = MarketingFee * amount / 100;
        internalTransfer(from,address(this),marketingTokens);
        return amount - marketingTokens;
    }

    function swapAndSend(uint amount,address addr) internal {
        swapTokensForEth(amount);
        payable(addr).transfer(address(this).balance);
    }

    function internalTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal  {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}