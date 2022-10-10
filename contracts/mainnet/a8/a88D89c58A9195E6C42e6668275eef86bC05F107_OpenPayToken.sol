/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

/*

  ,ad8888ba,                                          88888888ba                            
 d8"'    `"8b                                         88      "8b                           
d8'        `8b                                        88      ,8P                           
88          88  8b,dPPYba,    ,adPPYba,  8b,dPPYba,   88aaaaaa8P'  ,adPPYYba,  8b       d8  
88          88  88P'    "8a  a8P_____88  88P'   `"8a  88""""""'    ""     `Y8  `8b     d8'  
Y8,        ,8P  88       d8  8PP"""""""  88       88  88           ,adPPPPP88   `8b   d8'   
 Y8a.    .a8P   88b,   ,a8"  "8b,   ,aa  88       88  88           88,    ,88    `8b,d8'    
  `"Y8888Y"'    88`YbbdP"'    `"Ybbd8"'  88       88  88           `"8bbdP"Y8      Y88'     
                88                                                                 d8'  

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IUniswapV2Factory {
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

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    address public _owner;
    address _tokenContract;

    string private _name;
    string private _symbol;

    IUniswapV2Router02 public  pcsV2Router;
    address public pcsV2Pair;

   //blacklist BOT/malicious addresses
    bool public _antiBotEnabled;
    mapping(address=>bool) public _isBot;    
    uint256 public _botFee = 10;

    event AddressAddToBotList(address indexed account, bool isBlackListed);
    event AddressRemovedFromBotList(address indexed account, bool isBlackListed);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
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
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        // early exit with no other logic if transfering 0 (to prevent 0 transfers from triggering other logic)
        if(amount == 0) {
           return;
        }

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 amountToTransfer = amount;

        if (_antiBotEnabled && _isBot[sender] && pcsV2Pair == recipient) {
            uint256 _botFeeAmount = _calculateBotFee(amount);
            amountToTransfer = amount - _botFeeAmount;
            // Add the fees to the contract token balance
            _balances[_tokenContract] = _balances[_tokenContract] + _botFeeAmount;

            emit Transfer(sender, _tokenContract, _botFeeAmount);
        }

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amountToTransfer;

        emit Transfer(sender, recipient, amountToTransfer);

        _afterTokenTransfer(sender, recipient, amountToTransfer);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _calculateBotFee(uint256 _botSellAmount) private view returns (uint256) {
        return (_botSellAmount * _botFee) / 100;
    }

}

contract OpenPayToken is ERC20 {

   address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
       
    constructor () ERC20("OpenPay", "ONPAY") 
    {    
        _mint(msg.sender, 250_000_000 * (10 ** 18));
        _owner = msg.sender;

        // Create a uniswap pair for this new token
        pcsV2Router = IUniswapV2Router02(router);
        pcsV2Pair = IUniswapV2Factory(pcsV2Router.factory()).createPair(address(this), pcsV2Router.WETH());

        _tokenContract = address(this);
       
    }

    // useful for buybacks or to reclaim any BNB on the contract in a way that helps holders.
    function buyBackTokens(uint256 bnbAmountInWei) external onlyOwner {
        // generate the pancakeswap pair path of weth -> BNB
        address[] memory path = new address[](2);
        path[0] = pcsV2Router.WETH();
        path[1] = address(this);

        // make the swap
        pcsV2Router.swapExactETHForTokens{value: bnbAmountInWei}(
            0, // accept any amount of BNB
            path,
            address(0xdead),
            block.timestamp
        );
    }

    function swapTokensForbnb(uint256 tokenAmount) external onlyOwner {
        
        // generate the pancakeswap pair path of weth -> BNB
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pcsV2Router.WETH();

        _approve(address(this), address(pcsV2Pair), tokenAmount);

        // make the swap
        pcsV2Router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
        
    }

    //Use this in case BNB are sent to the contract by mistake
    function rescueBNB(uint256 _weiAmount) external onlyOwner {
        require(address(this).balance >= _weiAmount, "Insufficient BNB balance");
        payable(msg.sender).transfer(_weiAmount);
    }

    function addBotToBlackList(address _botAddress) external onlyOwner {
        _isBot[_botAddress] = true;
        emit AddressAddToBotList(_botAddress, true);
    }    

    function removeBotFromBlackList(address _botAddress) external onlyOwner {
        _isBot[_botAddress] = false;
        emit AddressRemovedFromBotList(_botAddress, true);
    }  

    function setAntiBot(bool _value) external onlyOwner{
        _antiBotEnabled = _value;
    }
    
    function burnFromContract(uint256 amount) external onlyOwner {
        _burn(address(this), amount);
    }
    
    function updateBotFees(uint256 _botFee) external onlyOwner {
        require(_botFee <= 15, "Total bot penalty should not exceed 15%");
        _botFee = _botFee;
    }    

    // allow receiving BNB from pcsV2Router after swapping
    receive() external payable {}

}