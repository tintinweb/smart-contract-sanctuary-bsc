/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.17;

interface IERC20{
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
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

contract Token{
    string public name = "Tentacle Token";
    string public symbol = "TENTACLE";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10 ** uint256(decimals);
    uint256 public inittotalSupply = 1000000 * 10 ** uint256(decimals);
    uint256 public TxFee = 25;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => uint256) public lockTime;

    address public owner;
    address public boss;
    address private USDT = address(0x55d398326f99059fF775485246999027B3197955);
    address private uniswapV2RouterAddr = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IUniswapV2Router02 public immutable uniswapV2Router;

    bool public initAddLiquidity;
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Destroy(address,uint256);
    event ActiveBurn(address indexed,uint256,uint256);

    constructor(){
        owner = msg.sender;
        boss = address(0xF8F268E67538afd09dD700c96E53420f1ec13c81);
        isExcludedFromFee[address(owner)] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[address(0x0159EC6b4aaD43A8d3aCcd7e3F55A20833d82d5f)] = true;
        isExcludedFromFee[address(0xE539aea7DFB5fdA6a7F6AF9af78651e23Dc8f4cc)] = true;
        isExcludedFromFee[address(boss)] = true;
        balanceOf[address(owner)] = 350000 * 10 ** uint256(decimals);
        balanceOf[address(0x0159EC6b4aaD43A8d3aCcd7e3F55A20833d82d5f)] = 150000 * 10 ** uint256(decimals);
        balanceOf[address(0xE539aea7DFB5fdA6a7F6AF9af78651e23Dc8f4cc)] = 150000 * 10 ** uint256(decimals);
        balanceOf[address(boss)] = 250000 * 10 ** uint256(decimals);
        balanceOf[address(this)] = 100000 * 10 ** uint256(decimals);

        emit Transfer(address(0), address(owner), 350000 * 10 ** uint256(decimals));
        emit Transfer(address(0), address(0x0159EC6b4aaD43A8d3aCcd7e3F55A20833d82d5f), 150000 * 10 ** uint256(decimals));
        emit Transfer(address(0), address(0xE539aea7DFB5fdA6a7F6AF9af78651e23Dc8f4cc), 150000 * 10 ** uint256(decimals));
        emit Transfer(address(0), address(boss), 250000 * 10 ** uint256(decimals));
        emit Transfer(address(0), address(this), 100000 * 10 ** uint256(decimals));

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddr);
        uniswapV2Router = _uniswapV2Router;
        IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), address(USDT));


        _lockToken(address(owner),2592000);
        _lockToken(address(0x0159EC6b4aaD43A8d3aCcd7e3F55A20833d82d5f),2592000);
        _lockToken(address(0xE539aea7DFB5fdA6a7F6AF9af78651e23Dc8f4cc),2592000);
        _lockToken(address(boss),2592000);
    }
    
    function transfer(address _to, uint256 _value) external returns(bool) {
        _transfer(msg.sender,_to,_value);
        return true;
    }
    
    function _transfer(address _from,address _to, uint256 _value) private returns(bool) {
        require(_to != address(0x0));
        require(_to != address(0x000000000000000000000000000000000000dEaD));
		require(_value > 0);
        require(balanceOf[_from] >= _value);  
        require(balanceOf[_to] + _value > balanceOf[_to]); 
        require(lockTime[_from] <= block.timestamp);
        if(isExcludedFromFee[_from] || isExcludedFromFee[_to]){
            balanceOf[_from] -=  _value;
            balanceOf[_to] += _value;
            emit Transfer(_from, _to, _value);
        }else{
            uint256 TxFees = (_value * TxFee / 100);
            balanceOf[_from] -=  _value;
            balanceOf[_to] += (_value - TxFees);
            totalSupply -= TxFees;
            emit Transfer(_from, address(0), TxFees);
            emit Transfer(_from, _to, _value - TxFees);
        }
        return true;
     }
    
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require (_value <= allowance[_from][msg.sender]); 
        _transfer(_from,_to,_value);
        allowance[_from][msg.sender] -=  _value;
        return true;
    }
    
    function approve(address _spender, uint256 _value) external returns (bool success) {
        _approve(address(msg.sender),_spender,_value);
        return true;
    }
    
    function _approve(address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    
    function activeBurn(uint256 _value) external returns(bool){
        require(tx.origin == msg.sender);
        require(_value > 0 && balanceOf[msg.sender] >= _value);
        uint256 ContractBNBBalance = address(this).balance;
        uint256 BNB_amount = _value * ContractBNBBalance / totalSupply;
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        payable(msg.sender).transfer(BNB_amount);
        emit ActiveBurn(msg.sender,_value,BNB_amount);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
    
    function getUnderpinningPrice() external view returns(uint256){
        uint256 ContractBNBBalance = address(this).balance;
        return ContractBNBBalance * (10 ** uint256(decimals)) / totalSupply;
    }
    
    function BurnAmount() external view returns(uint256){
        return inittotalSupply - totalSupply;
    }

    function destroy(uint256 _value) external returns(bool){
        require(_value > 0 && balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Destroy(msg.sender,_value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    modifier onlyOwner{
        require(tx.origin == owner);
        _;
    }

    function SetExcludeFromFee(address account) external onlyOwner {
        if(isExcludedFromFee[account]){
            isExcludedFromFee[account] = false;
        }else{
            isExcludedFromFee[account] = true;
        }
    }

    function setSellFee(uint256 _TxFee) external onlyOwner {
        TxFee = _TxFee;
    }

    receive() external payable {
    }

    function swapTokensForEth(uint256 tokenAmount) external {
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = address(uniswapV2Router.WETH());

        IERC20(USDT).approve(address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function RemoveOwner() external onlyOwner{
        owner = address(0);
    }

    function withdrawToken(address _con,uint256 amount) external onlyOwner {
        IERC20(_con).transfer(owner,amount);
	}

    function lockToken(uint256 _addtime) external {
        _lockToken(msg.sender,_addtime);
    }

    function _lockToken(address _addr ,uint256 _addtime) private {
        require(lockTime[_addr] <= block.timestamp);
        lockTime[_addr] = block.timestamp + _addtime;
    }
    
    function _addLiquidity() external {
        require(!initAddLiquidity);
        initAddLiquidity = true;
        _approve(address(this), address(uniswapV2Router), 100000 * (10 ** 18));
        IERC20(USDT).approve(address(uniswapV2Router), 100 * (10 ** 18));

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(USDT),
            50000 * (10 ** 18),
            50 * (10 ** 18),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(owner),
            block.timestamp
        );

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            address(USDT),
            50000 * (10 ** 18),
            50 * (10 ** 18),
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(boss),
            block.timestamp
        );
        
    }

    function getUsdtPrice() external view returns (uint256){
        address[] memory path = new address[](2);
        uint256[] memory amount;
        path[0] = address(this);
        path[1] = USDT;
        amount = uniswapV2Router.getAmountsOut(1 ether,path); 
        return amount[2];
    }

}