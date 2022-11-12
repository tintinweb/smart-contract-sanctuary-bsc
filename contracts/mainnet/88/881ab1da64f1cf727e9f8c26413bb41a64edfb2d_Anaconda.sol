// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import 'IERC20.sol';
import 'IUniswapV2Pair.sol';
import 'IUniswapV2Router01.sol';
import 'Address.sol';
import 'IUniswapV2Factory.sol';
import 'IUniswapV2Router02.sol';
import 'SafeMath.sol';
import 'Context.sol';
import 'Ownable.sol';


contract Anaconda is Context, IERC20, Ownable {

  
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping(address => bool) public isExitTxFee;
    
    uint256 private _totalSupply = 1e9 * 10**9;  // Total supply * Decimals
   
    string private _name = "Anaconda";
    string private _symbol = "Anaconda";
    uint8 private _decimals = 9;

    bool isActiveFee = true;

    uint8 liquidityFee = 35; // => 55/1000 
    uint8 marketingFee = 10;
    uint8 devFee = 10;

    address public routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public ownerAddress = 0xf7Beb48F8366f2C91a5d563b14e9Af13b1C6D6c3;
    address public marketingAddress = 0x2db2f17cA7158e4FBa5Db0B929b625f2d4732c22;
    address public devAddress = 0xEbcbAC84DA7AF29D67Ca166AAFd7220D5875264c;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    // stops all transfers in a possible attack
    bool public isHack = false;
   

    uint256 private numTokensSellToAddToLiquidity = 200000 * 10**9;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor () {
        _balances[msg.sender] = _totalSupply;
        transferOwnership(ownerAddress);
        isExitTxFee[msg.sender] = true;
        isExitTxFee[address(0)] = true;
        isExitTxFee[ownerAddress] = true;
        isExitTxFee[devAddress] = true;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(routerAddress);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
       
        emit Transfer(address(0), msg.sender, totalSupply());
       
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
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

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function changeLiquifyAmount(uint256 amount) public onlyOwner {
        numTokensSellToAddToLiquidity = amount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    // if there is an attack this function stops all transfers or reactivate

    function changeTransferStatus() public onlyOwner returns(bool){
        return (isHack = !isHack);
    }
    

    function _burn(address sender, uint amount) private {
        _balances[sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(sender, address(0), amount);
    }
    
    function burn(uint amount) public returns(bool) {
        require(amount <= balanceOf(msg.sender), "insufficient amount");
        require(amount > 0, "must be greater than 0");
        
        _burn(msg.sender, amount);
        
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(isHack != true, "Is hack now...");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");     
        
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 newTransferAmount;
        isActiveFee ? (newTransferAmount = calculateFee(from,to,amount)) : ( newTransferAmount = amount);

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }
        _balances[from] -= newTransferAmount;
        _balances[to] += newTransferAmount;
        emit Transfer(from, to, newTransferAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function calculateFee(address from, address to, uint amount) private returns(uint){
        if(isExitTxFee[from] || isExitTxFee[to]){
            return amount;
        }
        uint liquidityFeeAmount = amount * liquidityFee /1000;
        uint devFeeAmount = amount * devFee / 1000;
        uint marketingFeeAmount = amount * marketingFee / 1000;
        emit Transfer(from, address(this), liquidityFeeAmount);
        emit Transfer(from, address(this), devFeeAmount);
        emit Transfer(from, address(this), marketingFeeAmount);
        uint totalFee = liquidityFeeAmount + devFeeAmount + marketingFeeAmount;
        return (amount - totalFee); 
        
    }
      
    
    function changeStatusAllFee() public onlyOwner{
        isActiveFee= !isActiveFee;
    }

    function changeRouterAddress(address _newAd) public onlyOwner{
        routerAddress = _newAd;
    }


    function withdrawAnyToken(address _recipient, address _ERC20address, uint256 _amount) public onlyOwner returns(bool) {
        require(_ERC20address != uniswapV2Pair, "Can't transfer out LP tokens!");
        require(_ERC20address != address(this), "Can't transfer out contract tokens!");
        IERC20(_ERC20address).transfer(_recipient, _amount); //use of the _ERC20 traditional transfer
        return true;
    }

    function withdrawContractBal(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
    }

}