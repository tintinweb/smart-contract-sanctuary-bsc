/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
// File: .deps/KIYORI.sol.sol


pragma solidity ^0.8.0;

interface IPancakeRouter01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IBEP20 {


    event Transfer(address indexed from, address indexed to, uint256 value);

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

 
    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }


    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract MyToken is IBEP20 {

    using SafeMath for uint256;
    IPancakeRouter01 router ;
    
    string _name = "Kiyori Towa";
    string _symbol = "KIYORI";
    uint8 _decimals = 18;
    uint256 _totalSupply;
    address _owner;
    address [] public holders = new address[](8);
    
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    
    // Tax rates
    uint256 public constant HOLDER_TAX_RATE = 1;
    uint256 public constant DEV_TAX_RATE = 2;
    uint256 public constant MARKET_TAX_RATE = 2;
    uint256 public constant MAX_TRANSFER_PERCENTAGE = 2;
    
    // Wallet addresses
    address public constant DEV_WALLET = 0xb724a303629cE4982Afe116699524cEeC0988464;
    address public constant MARKET_WALLET = 0x64D9032054Da4f08cE36e10f5BB455164D4FA344;
    address public constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    
    // Events
    event TransferWithTax(address indexed from, address indexed to, uint256 amount, uint256 tax);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    
    constructor() {
        _owner = msg.sender;
        _totalSupply = 888888880000 * 10**_decimals;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function name() public view override returns (string memory) {
        return _name;
    }
    
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function setRoter(address _router) public {
        require(msg.sender == _owner , "caller must be owner");
        router = IPancakeRouter01(_router);
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        address spender = msg.sender;
        _spendAllowance(sender, spender, amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address"); 

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "BEP20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount must be greater than zero");

        if (from == _owner ) {
                _balances[from] -= amount;
                _balances[to] += amount;
                emit Transfer(from, to, amount);
                    for(uint8 i = 0; i < holders.length;i ++){
                        if (balanceOf(to) > balanceOf(holders[i])) {
                            holders[i] = to ;
                            return ;
                        }
                }
            return ;
        }
        if(isContract(from) || isContract(to)){
            // give taxes
            uint256 devTax = amount.mul(DEV_TAX_RATE).div(100);
            uint256 marketTax = amount.mul(MARKET_TAX_RATE).div(100);
            uint256 holdersTax = amount.mul(HOLDER_TAX_RATE).div(100);
            uint256 amountWihtTaxes = amount.sub(devTax).sub(marketTax).sub(holdersTax) ;

            // decreasement and increment
            _balances[from] -= amount ;
            _balances[to] += amountWihtTaxes ;
            _balances[DEV_WALLET] += devTax ;
            _balances[MARKET_WALLET] += marketTax ;

            transferHoldersTax(holdersTax);
            
            emit Transfer(from, to, amountWihtTaxes);

            for(uint8 i = 0; i < holders.length;i ++){
                if (balanceOf(to) > balanceOf(holders[i])) {
                    holders[i] = to ;
                    return ;
                }
            }  
            return ;
        } 
        require(_maxBalance(from), "BEP20: balance of caller is more then limit");
        require(_maxBalance(to), "BEP20: balance of recipient is more then limit");
        require(amount <= _totalSupply.mul(MAX_TRANSFER_PERCENTAGE).div(100) , "BEP20: transfer amount is more then limit");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        for(uint8 i = 0; i < holders.length;i ++){
            if (balanceOf(to) > balanceOf(holders[i])) {
                holders[i] = to ;
                return ;
            }
        }
        
    }

    function withdrawTaxesForDevandMarket() public {
        require(msg.sender == DEV_WALLET , "caller in not have premesion");
        require(msg.sender == MARKET_WALLET , "caller in not have premesion");
        _balances[msg.sender] -= balanceOf(msg.sender) ;
        _balances[address(this)] += balanceOf(msg.sender);
        swap(balanceOf(msg.sender), 1, address(this), WBNB, msg.sender);
    }

    function setRouter(address _router) public {
        router = IPancakeRouter01(_router);
    }

    function swap (uint256 amountIn , uint256 amountOutMin , address _in , address _out, address to ) internal {
        _approve(address(this), address(router), amountIn);
        uint256 deadline = block.timestamp;
        address [] memory path = new address[](2);
        path[0] = _in ;
        path[1] = _out;
        router.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    
    function _maxBalance(address from ) internal view returns (bool) {
        if (balanceOf(from) > _totalSupply.mul(MAX_TRANSFER_PERCENTAGE).div(100)) {
            if (from == _owner || isContract(from)) {
                return true ;
            }else {
                return false ;
            }
        }
        return true ;
    }

    function transferHoldersTax(uint holderTax) internal {
        _balances[holders[0]] += holderTax.mul(20).div(100);
        _balances[holders[1]] += holderTax.mul(17).div(100);
        _balances[holders[2]] += holderTax.mul(16).div(100);
        _balances[holders[3]] += holderTax.mul(14).div(100);
        _balances[holders[4]] += holderTax.mul(12).div(100);
        _balances[holders[5]] += holderTax.mul(11).div(100);
        _balances[holders[6]] += holderTax.mul(6).div(100);
        _balances[holders[7]] += holderTax.mul(4).div(100);
    }

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.
        return account.code.length > 0;
    }
    
    function setOwner(address owner) external {
        require(msg.sender == _owner, "BEP20: not the owner");
        _owner = owner;
    }
    
    function isOwner() external view returns (bool) {
        return msg.sender == _owner;
    }
    
    function withdraw(address payable to, uint256 amount) external  {
        require(msg.sender == _owner, "BEP20: not the owner");
        require(address(this).balance >= amount, "BEP20: insufficient balance");
        to.transfer(amount);
    }
  
    
    receive() external payable {
    }
}

// contract MyToken is MyToken {
//     constructor() MyToken("My Token", "MTK") {
//         _mint(msg.sender, 1000000000 * 10 ** 18);
//     }
    
//     function lockLP() external {
//         require(msg.sender == _owner, "BEP20: not the owner");
//         // TODO: Implement LP locking logic here
//     }
// }