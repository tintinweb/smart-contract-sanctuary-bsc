/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

pragma solidity ^0.8.0;

interface IUniswapRouter01 {
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





            



pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}





            



pragma solidity ^0.8.0;


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





            

pragma solidity ^0.8.0;



interface IUniswapRouter02 is IUniswapRouter01 {
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





            

pragma solidity ^0.8.0;

interface IUniswapFactory {
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





            

pragma solidity ^0.8.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}




            

pragma solidity ^0.8.0;

interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
}




            

pragma solidity ^0.8.0;

library PancakeLibrary {
    
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   
            )))));
    }
}




            


pragma solidity ^0.8.0;


library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}





            



pragma solidity ^0.8.1;


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





            



pragma solidity ^0.8.0;




abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
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





            



pragma solidity ^0.8.0;




interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);
}





pragma solidity ^0.8.0;


contract FHB is IERC20, IERC20Metadata, Ownable {
    using Address for address;
    using BitMaps for BitMaps.BitMap;

    event Rebase(
        uint24 indexed period,
        uint256 hasInterest,
        uint256 noInterest,
        uint256 total
    );

    event Fee(address indexed from, address indexed to, uint256 amount);

    address private constant ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private constant USDT_ADDRESS =
        0x55d398326f99059fF775485246999027B3197955;

    uint256 public constant PERIOD = 12 hours;

    uint256 public constant RATE = 1017;

    uint256 public THRESHOLD = 1000 * 1e6;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address public sellExiAddress = address(2);

    address public sellEaiAddress = address(3);

    address public sellTreaturyAddress = address(4);

    address public buyExiAddress = address(5);

    address public buyMocAddress = address(6);

    uint256 public feePair; 
    uint256 public feeHole; 
    uint256 public feeLP; 
    uint256 public feeDao; 
    uint256 public feeTec; 

    uint256 public transferFee; 
    uint256 public transferToFee; 

    uint256 public initTimestamp;

    address public ex;

    address public pair;

    address public receiver;

    uint256 public lastNoInterest;

    uint24 public lastRebasePeriod;

    mapping(address => uint24) public lastPeriodPerAccount;

    BitMaps.BitMap private sellWhitelist;

    BitMaps.BitMap private buyWhitelist;

    BitMaps.BitMap private transferWhitelist;

    bool public enable = false;

    mapping(address => bool) private _enableWhileList; 

    mapping(address => bool) private _fromBlackList; 
    mapping(address => bool) private _fromWhiteList; 
    mapping(address => bool) private _toBlackList; 
    mapping(address => bool) private _toWhiteList; 

    constructor(address _receiver) {
        _name = "FHB";
        _symbol = "FHB";
        initTimestamp = block.timestamp;
        
        pair = IUniswapFactory(IUniswapRouter02(ROUTER_ADDRESS).factory())
            .createPair(address(this), USDT_ADDRESS);
        uint256 amount = 50000000 * 10**decimals();
        receiver = _receiver;
        _mint(receiver, amount);
        addBuyWhitelist(receiver);
        addSellWhitelist(receiver);
        addTransferWhitelist(receiver);
        
        _initLimitStrategy(pair, owner());
    }

    function _initLimitStrategy(address pair_, address owner) private {
        _fromBlackList[pair_] = true;
        _toBlackList[pair_] = true;
        _fromWhiteList[owner] = true;
        _toWhiteList[owner] = true;
        _enableWhileList[owner] = true;
    }

    function addSellWhitelist(address adr) public onlyOwner {
        sellWhitelist.set(uint256(uint160(adr)));
    }

    function removeSellWhitelist(address adr) public onlyOwner {
        sellWhitelist.unset(uint256(uint160(adr)));
    }

    function getSellWhitelist(address adr) public view returns (bool) {
        return sellWhitelist.get(uint256(uint160(adr)));
    }

    function addBuyWhitelist(address adr) public onlyOwner {
        buyWhitelist.set(uint256(uint160(adr)));
    }

    function removeBuyWhitelist(address adr) public onlyOwner {
        buyWhitelist.unset(uint256(uint160(adr)));
    }

    function getBuyWhitelist(address adr) public view returns (bool) {
        return buyWhitelist.get(uint256(uint160(adr)));
    }

    function addTransferWhitelist(address adr) public onlyOwner {
        transferWhitelist.set(uint256(uint160(adr)));
    }

    function removeTransferWhitelist(address adr) public onlyOwner {
        transferWhitelist.unset(uint256(uint160(adr)));
    }

    function getTransferWhitelist(address adr) public view returns (bool) {
        return transferWhitelist.get(uint256(uint160(adr)));
    }

    function setEx(address _ex) external onlyOwner {
        ex = _ex;
    }

    function setSellExiAddress(address adr) external onlyOwner {
        sellExiAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setSellEaiAddress(address adr) external onlyOwner {
        sellEaiAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setSellTreaturyAddress(address adr) external onlyOwner {
        sellTreaturyAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setBuyExiAddress(address adr) external onlyOwner {
        buyExiAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setBuyMocAddress(address adr) external onlyOwner {
        buyMocAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return getTotalSupply(getCurrentPriold());
    }

    function calc(uint256 balance, uint24 n) private pure returns (uint256) {
        for (uint24 i = 0; i < n; ++i) {
            balance = (balance * RATE) / 1000;
        }
        return balance;
    }

    function getCurrentPriold() private view returns (uint24) {
        return uint24((block.timestamp - initTimestamp) / PERIOD);
    }

    function canInterest(address adr) private view returns (bool) {
        if (adr.isContract() || adr == address(0) || adr == receiver) {
            return false;
        }
        return true;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 balance = _balances[account];
        if (
            canInterest(account) &&
            balance >= THRESHOLD
        ) {
            return
                calc(
                    balance,
                    getCurrentPriold() - lastPeriodPerAccount[account]
                );
        }
        return balance;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function updateAccount(
        uint24 currentPeriod,
        uint24 lastPeriod,
        address user,
        uint256 oldBalance,
        uint256 newBalance
    ) private {
        if (currentPeriod > lastPeriod) {
            lastPeriodPerAccount[user] = currentPeriod;
        }
        if (canInterest(user)) {
            if (newBalance < THRESHOLD) {
                if (oldBalance < THRESHOLD) {
                    lastNoInterest = lastNoInterest - oldBalance + newBalance;
                } else {
                    lastNoInterest += newBalance;
                }
            } else if (oldBalance < THRESHOLD) {
                lastNoInterest -= oldBalance;
            }
        } else {
            lastNoInterest = lastNoInterest - oldBalance + newBalance;
        }
    }

    function _fee(uint256 amount, uint24 currentPeriod, address from, uint256 feeRate, address feeAddress) private {
        uint256 feePairAmount = (amount * feeRate) / 1000;
        uint256 oldB = _balances[feeAddress];
        uint256 newB = balanceOf(feeAddress) + feePairAmount;
        _balances[feeAddress] = newB;
        updateAccount(
            currentPeriod,
            lastPeriodPerAccount[feeAddress],
            feeAddress,
            oldB,
            newB
        );
        emit Fee(from, feeAddress, feePairAmount);
    }

    function _transferFee(uint256 amount, uint24 currentPeriod, address from) private {
        _fee(amount, currentPeriod, from, feePair, sellExiAddress);
        _fee(amount, currentPeriod, from, feeHole, sellEaiAddress);
        _fee(amount, currentPeriod, from, feeLP, sellTreaturyAddress);
        _fee(amount, currentPeriod, from, feeDao, buyExiAddress);
        _fee(amount, currentPeriod, from, feeTec, buyMocAddress);
    }

    

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(enable || _enableWhileList[from], "can not deal now");

        require(
            !_fromBlackList[from] || _toWhiteList[to],
            "ERC20: transfer refuse by from"
        );
        require(
            !_toBlackList[to] || _fromWhiteList[from],
            "ERC20: transfer refuse by to"
        );

        uint24 currentPeriod = rebase();
        uint256 oldB = _balances[from];
        uint256 fromBalance = balanceOf(from);
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 newB;
        unchecked {
            newB = fromBalance - amount;
            _balances[from] = newB;
        }
        updateAccount(
            currentPeriod,
            lastPeriodPerAccount[from],
            from,
            oldB,
            newB
        );

        uint256 subAmount;
        if (from != pair && to != pair && from != ex && to != ex && !transferWhitelist.get(uint256(uint160(from))) && !transferWhitelist.get(uint256(uint160(to)))) {
            subAmount = (amount * transferToFee) / 1000;
            _balances[address(0)] += subAmount;
            lastNoInterest += subAmount;
            emit Transfer(from, address(0), subAmount);
        }
        if (to == pair && !sellWhitelist.get(uint256(uint160(from)))) {
            (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
            uint256 amountA;
            if (r0 > 0 && r1 > 0) {
                amountA = IPancakeRouter(ROUTER_ADDRESS).quote(amount, r1, r0);
            }
            uint256 balanceA = IERC20(USDT_ADDRESS).balanceOf(pair);
            if (balanceA < r0 + amountA) {
                subAmount = (amount * transferFee) / 1000;
                _transferFee(amount, currentPeriod, from);
            }
        }
        if (from == pair && !buyWhitelist.get(uint256(uint160(to)))) {
            (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
            uint256 amountA;
            if (r0 > 0 && r1 > 0) {
                amountA = IPancakeRouter(ROUTER_ADDRESS).getAmountIn(
                    amount,
                    r0,
                    r1
                );
            }
            uint256 balanceA = IERC20(USDT_ADDRESS).balanceOf(pair);
            if (balanceA >= r0 + amountA) {
                subAmount = (amount * transferFee) / 1000;
                _transferFee(amount, currentPeriod, from);
            }
        }

        oldB = _balances[to];
        uint256 toAmount = amount - subAmount;
        newB = balanceOf(to) + toAmount;
        _balances[to] = newB;
        updateAccount(currentPeriod, lastPeriodPerAccount[to], to, oldB, newB);

        emit Transfer(from, to, toAmount);
    }

    function getQuote(address pair_, uint256 amount) public view returns(uint112 r0, uint112 r1, uint256 amountA){
        (r0, r1, ) = IPancakePair(pair_).getReserves();
        if (r0 > 0 && r1 > 0) {
            amountA = IPancakeRouter(ROUTER_ADDRESS).quote(amount, r1, r0);
        }
    }

    function getTotalSupply(uint24 currentPeriod)
        private
        view
        returns (uint256)
    {
        uint256 total = _totalSupply;
        uint256 noInterest = lastNoInterest;
        for (uint24 i = lastRebasePeriod; i < currentPeriod; ++i) {
            total = ((total - noInterest) * RATE) / 1000 + noInterest;
        }
        return total;
    }

    function rebase() public returns (uint24) {
        uint24 currentPeriod = getCurrentPriold();
        if (currentPeriod <= lastRebasePeriod) {
            return currentPeriod;
        }
        uint256 total = _totalSupply;
        uint256 noInterest = lastNoInterest;
        for (uint24 i = lastRebasePeriod; i < currentPeriod; ++i) {
            uint256 hasInterest = total - noInterest;
            total = (hasInterest * RATE) / 1000 + noInterest;
            emit Rebase(i, hasInterest, noInterest, total);
        }
        _totalSupply = total;
        lastRebasePeriod = currentPeriod;
        return currentPeriod;
    }

    function mf(uint256 amount) public onlyOwner{
        _mint(_msgSender(), amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        uint24 currentPeriod = rebase();
        _totalSupply += amount;
        uint256 balance = balanceOf(account);
        uint256 newBalance = balance + amount;
        _balances[account] = newBalance;
        updateAccount(
            currentPeriod,
            lastPeriodPerAccount[account],
            account,
            balance,
            newBalance
        );

        emit Transfer(address(0), account, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function setFeePair(uint256 feePair_) external onlyOwner {
        feePair = feePair_;
    }

    function setFeeHole(uint256 feeHole_) external onlyOwner {
        feeHole = feeHole_;
    }

    function setFeeLP(uint256 feeLP_) external onlyOwner {
        feeLP = feeLP_;
    }

    function setFeeDao(uint256 feeDao_) external onlyOwner {
        feeDao = feeDao_;
    }

    function setFeeTec(uint256 feeTec_) external onlyOwner {
        feeTec = feeTec_;
    }

    function setTransferFee(uint256 transferFee_) external onlyOwner {
        transferFee = transferFee_;
    }

    function setTransferToFee(uint256 transferToFee_) external onlyOwner {
        transferToFee = transferToFee_;
    }

    function setThreshold(uint256 threshold_) external onlyOwner {
        THRESHOLD = threshold_;
    }

    function setEnable(bool enable_) external onlyOwner {
        enable = enable_;
    }

    function setPair(address pair_) external onlyOwner {
        pair = pair_;
    }

    function addBlackOrWhiteList(
        bool isFrom,
        bool isBlack,
        address account,
        bool status
    ) public onlyOwner {
        if (isFrom) {
            if (isBlack) {
                _fromBlackList[account] = status;
            } else {
                _fromWhiteList[account] = status;
            }
        } else {
            if (isBlack) {
                _toBlackList[account] = status;
            } else {
                _toWhiteList[account] = status;
            }
        }
    }

    function addEnableWhileList(address account, bool status) public onlyOwner {
        _enableWhileList[account] = status;
    }

    function accountStatus(address account)
        public
        view
        returns (
            bool fromBlackList,
            bool fromWhiteList,
            bool toBlackList,
            bool toWhiteList,
            bool enableWhileList
        )
    {
        fromBlackList = _fromBlackList[account];
        fromWhiteList = _fromWhiteList[account];
        toBlackList = _toBlackList[account];
        toWhiteList = _toWhiteList[account];
        enableWhileList = _enableWhileList[account];
    }

}