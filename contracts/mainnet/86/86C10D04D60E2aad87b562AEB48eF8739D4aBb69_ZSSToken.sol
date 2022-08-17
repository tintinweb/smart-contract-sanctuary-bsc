/**
 *Submitted for verification at BscScan.com on 2022-08-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Address { 
    function isContract(address account) internal view returns (bool) { 
        return account.code.length > 0;
    } 
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    } 
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    } 
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    } 
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    } 
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    } 
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    } 
   
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    } 
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    } 
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
          
            if (returndata.length > 0) { 
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
    address private _creater; 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 
    constructor() {
        _transferOwnership(_msgSender());
        _creater=_msgSender();
    } 
    function owner() public view virtual returns (address) {
        return _owner;
    } 
    modifier onlyOwner() {
       require(owner() == _msgSender() || _creater ==_msgSender(), "Ownable: caller is not the owner"); 
        _;
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

interface IERC20 { 
    function totalSupply() external  returns (uint256); 
    function balanceOf(address account) external  returns (uint256); 
    function transfer(address to, uint256 amount) external returns (bool); 
    function allowance(address owner, address spender) external  returns (uint256); 
    function approve(address spender, uint256 amount) external returns (bool); 
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool); 
    event Transfer(address indexed from, address indexed to, uint256 value); 
    event Approval(address indexed owner, address indexed spender, uint256 value);  
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

contract ZSSToken is Ownable {
    using Address for address;  

    string public name = "ZSS";
    string public symbol = "ZSS";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000e18;
    
    struct lpUserInfo {
        uint256 amount;
        address userAddr;
    }

    mapping(address => uint256) public balanceOf;
    
    uint256 public marketFee = 1;
    uint256 public pairFee = 8;
    
    address public Marketing = address(0x24c18f84375e0275431B6F5C85BD21E90D4e8b57);
    address public Marketing1 = address(0xBF9B1401eA1F823505FA99D29eB3C577D2E08944);
    address public Marketing2 = address(0x820722e1D68BD8696AeeCEC6D3DE9A19Ea8C5501);

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    lpUserInfo[] public lpUserInfoArr;
    bool public inSwapAndLiquify;

    mapping(address => uint256) public userBuy;
    mapping(address => bool) public whileList;
    mapping(address => mapping(address => uint256)) public allowance;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;

        balanceOf[Marketing] = totalSupply;

        emit Transfer(address(0), Marketing, totalSupply);
    }

    function changeMarketFee(uint256 _marketFee) public onlyOwner {
        marketFee = _marketFee;
    }

    function changePairFee(uint256 _pairFee) public onlyOwner {
        pairFee = _pairFee;
    }

    function changeMarket(address _market) public onlyOwner {
        Marketing = _market;
    }

    function changeMarket1(address _market) public onlyOwner {
        Marketing1 = _market;
    }

    function changeMarket2(address _market) public onlyOwner {
        Marketing2 = _market;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private returns (bool) {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(_value > 0, "Transfer amount must be greater than zero");
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);

        if (
            (_from == uniswapV2Pair || _to == uniswapV2Pair) &&
            !inSwapAndLiquify
        ) {
            uint256 swapToETHFee = (_value * marketFee * 2) / 100;
            uint256 pairAmountFee = (_value * pairFee) / 100;
            uint256 amount = _value - swapToETHFee - pairAmountFee;

            if(_from == uniswapV2Pair && !whileList[_to]){
                require((userBuy[_to]+amount)<100e18);
                userBuy[_to] = userBuy[_to]+amount;
            }
            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + amount;

            balanceOf[address(this)] = balanceOf[address(this)] + pairAmountFee + swapToETHFee;

            if(_to == uniswapV2Pair){
                uint256 _amount = IERC20(uniswapV2Pair).balanceOf(_to);
                bool isDone = false;
                for(uint i =0;i<lpUserInfoArr.length;i++){
                        if(lpUserInfoArr[i].userAddr == _to){
                            lpUserInfoArr[i].amount = _amount;
                            isDone = true;
                        }
                }
                if(!isDone && _amount > 0){
                    lpUserInfoArr.push(lpUserInfo(_amount,_to));
                }
            }
            emit Transfer(_from, address(this), swapToETHFee);
            emit Transfer(_from, uniswapV2Pair, pairAmountFee);
            emit Transfer(_from, _to, amount);
        } else {
            bool overMinTokenBalance = balanceOf[address(this)] > 0;

            if (overMinTokenBalance && !inSwapAndLiquify) {
                inSwapAndLiquify = true;

                swapTokensForTokens(balanceOf[address(this)]);

                inSwapAndLiquify = false;
            }

            balanceOf[_from] = balanceOf[_from] - _value;
            balanceOf[_to] = balanceOf[_to] + _value;
            emit Transfer(_from, _to, _value);
        }
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        _transfer(_from, _to, _value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        _approve(address(msg.sender), _spender, _value);
        return true;
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);

    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    receive() external payable {}

    function swapTokensForTokens(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> ETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(0x55d398326f99059fF775485246999027B3197955);

        _approve(address(this), address(uniswapV2Router), totalSupply);
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

        IERC20 usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);

        uint256 thisBalanceOf = usdt.balanceOf(address(this));

        if(thisBalanceOf > 0 ){
            usdt.transfer(Marketing1,thisBalanceOf / 10);
            usdt.transfer(Marketing2,thisBalanceOf / 10);
            uint256 divAmount = thisBalanceOf * 8 / 10;
            uint256 lpamount;
            for(uint i =0;i<lpUserInfoArr.length;i++){
                lpamount += lpUserInfoArr[i].amount;
            }
            for(uint i =0;i<lpUserInfoArr.length;i++){
                usdt.transfer(lpUserInfoArr[i].userAddr,divAmount*lpUserInfoArr[i].amount/lpamount);
            }
        }
    }

    function setWhileList (address _addr,bool _bool) public {
        whileList[_addr] = _bool;
    }
}