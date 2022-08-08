/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Math {
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
        // else z = 0 (default value)
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function waiveOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface IUniswapV2Pair {
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

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
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

contract DLDao is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "DL-Dao";
    string private _symbol = "DLDAO";
    uint8 private _decimals = 9;

    address public USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public OSKDAO = 0xC5db5aFee4C55DfAD5F2b8226C6ac882E6956a0A;
    address payable public marketingWalletAddress = payable(0x1040e006cc047cbBbcD6c51c1946ad24eee1176c); 
    address payable public NFTWalletAddress = payable(0xD00C0d549b49beC897c60A6E74E8DD29E446291a); 
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) public isExcludedFromFee;
    mapping (address => bool) public isMarketPair;
    mapping(address => bool) public isbotBlackList;

    bool private startPublicSell = false;
    mapping(address => bool) private ceoList;
    

    uint256 public _buyBurnFee = 1;
    uint256 public _buyLPFee = 2;
    uint256 public _buyMarketingFee = 2;
    uint256 public _buyNFTFee = 1;
    
    uint256 public _sellReflectionFee = 1;
    uint256 public _sellLPFee = 2;
    uint256 public _sellMarketingFee = 2;
    uint256 public _sellNFTFee = 1;

    uint256 public _lpShare = _buyLPFee.add(_sellLPFee);
    uint256 public _marketingShare = _buyMarketingFee.add(_sellMarketingFee);
    uint256 public _nftShare = _buyNFTFee.add(_sellNFTFee);

    uint256 public _totalTaxIfBuying;
    uint256 public _totalTaxIfSelling;
    uint256 public _totalDistributionShares;

    uint256 private _totalSupply = 55500 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = _totalSupply.div(10000); 

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    TokenDistributor _tokenDistributor;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public swapAndLiquifyByLimitOnly = false;
    bool public _enableDivedend = true;
    bool public tradeOpen = false;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
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
    
    constructor () {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), USDT);

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = uint(~uint256(0));
        IERC20(USDT).approve(address(uniswapV2Router), uint(~uint256(0)));

        _tokenDistributor =  new TokenDistributor(USDT,OSKDAO);

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        ceoList[owner()] = true;
        
        _totalTaxIfBuying = _buyLPFee.add(_buyMarketingFee).add(_buyNFTFee).add(_buyBurnFee);
        _totalTaxIfSelling = _sellLPFee.add(_sellMarketingFee).add(_sellNFTFee).add(_sellReflectionFee);
        _totalDistributionShares = _lpShare.add(_marketingShare).add(_nftShare).add(_buyBurnFee).add(_sellLPFee);

        isMarketPair[address(uniswapPair)] = true;

        areadyKnowContracts[address(uniswapPair)] =  true;
        areadyKnowContracts[address(this)] =  true;
        areadyKnowContracts[address(uniswapV2Router)] =  true; 

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketPairStatus(address account, bool newValue) public onlyOwner {
        isMarketPair[account] = newValue;
    }

    function setIsExcludedFromFee(address account, bool newValue) public onlyOwner {
        isExcludedFromFee[account] = newValue;
    }

    function multiSetIsExcludedFromFee(address[] memory accounts, bool newValue) public onlyOwner {
        for(uint8 i=0;i<accounts.length;i++){
            isExcludedFromFee[accounts[i]] = newValue;
        }

    }

    function setBuyTaxes(uint256 newLpTax, uint256 newMarketingTax, uint256 newTeamTax, uint256 newBurnTax) external onlyOwner() {
        _buyBurnFee = newBurnTax;
        _buyLPFee = newLpTax;
        _buyMarketingFee = newMarketingTax;
        _buyNFTFee = newTeamTax;

        _totalTaxIfBuying = _buyLPFee.add(_buyMarketingFee).add(_buyNFTFee);
    }

    function setSellTaxes(uint256 newLpTax, uint256 newMarketingTax, uint256 newTeamTax, uint256 newReflectionTax) external onlyOwner() {
        _sellReflectionFee =  newReflectionTax;
        _sellLPFee = newLpTax;
        _sellMarketingFee = newMarketingTax;
        _sellNFTFee = newTeamTax;

        _totalTaxIfSelling = _sellLPFee.add(_sellMarketingFee).add(_sellNFTFee);
    }
    
    function shareSettings(uint256 newLPShare, uint256 newMarketingShare, uint256 newNFTShare) external onlyOwner() {
        _lpShare = newLPShare;
        _marketingShare = newMarketingShare;
        _nftShare = newNFTShare;

        _totalDistributionShares = _lpShare.add(_marketingShare).add(_nftShare).add(_buyBurnFee).add(_sellReflectionFee);
    }
    
    function enableDividend(bool newValue) external onlyOwner {
       _enableDivedend = newValue;
    }

    function openTrade() external onlyOwner {
       tradeOpen = true;
    }

    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner() {
        minimumTokensBeforeSwap = newLimit;
    }

    function setMarketingWalletAddress(address newAddress) external onlyOwner() {
        marketingWalletAddress = payable(newAddress);
    }

    function setBuybackWalletAddress(address newAddress) external onlyOwner() {
        NFTWalletAddress = payable(newAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        swapAndLiquifyByLimitOnly = newValue;
    }
    
    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }

     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if(inSwapAndLiquify || isExcludedFromFee[sender] || isExcludedFromFee[recipient])
        { 
            return _basicTransfer(sender, recipient, amount); 
        }
        else
        {
            require(tradeOpen,"not open"); 

            if(isMarketPair[recipient]){
                if(!startPublicSell && ceoList[sender]){
                    startPublicSell =  true;
                }
                require(startPublicSell, "sell not open"); 
            }

            antiBot(sender, recipient);    

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
            
            if (overMinimumTokenBalance && !inSwapAndLiquify && !isMarketPair[sender] && swapAndLiquifyEnabled) 
            {
                if(swapAndLiquifyByLimitOnly)
                    contractTokenBalance = minimumTokensBeforeSwap;
                swapBack(contractTokenBalance);    
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
            uint256 finalAmount = takeFee(sender, amount);
            _balances[recipient] = _balances[recipient].add(finalAmount);


            if (sender != address(this)) {
                addHolder(sender);
                processReward(500000);
            }

            emit Transfer(sender, recipient, finalAmount);
            return true;
        }
    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function swapBack(uint256 amountToSwap) internal lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = USDT;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        uint256 amountBeforeTransfer = IERC20(USDT).balanceOf(address(this));
        IERC20(USDT).transferFrom(address(_tokenDistributor), address(this), IERC20(USDT).balanceOf(address(_tokenDistributor))); 
        uint256 amountUSDT = IERC20(USDT).balanceOf(address(this)) - amountBeforeTransfer;

        uint256 totalFee = _totalDistributionShares.sub(_buyBurnFee);
        uint256 amountUSDTNft = amountUSDT.mul(_nftShare).div(totalFee);
        uint256 amountUSDTMarketing = amountUSDT.mul(_marketingShare).div(totalFee);
        uint256 amountUSDTReflection = amountUSDT.mul(_sellReflectionFee).div(totalFee);
        if(amountUSDTMarketing > 0){
            IERC20(USDT).transfer(marketingWalletAddress,amountUSDTMarketing);
        }

        if(amountUSDTNft > 0){
            IERC20(USDT).transfer(NFTWalletAddress,amountUSDTNft);
        }

        if(amountUSDTReflection > 0 ){
            swapOSKDAO(amountUSDTReflection);
        }

    }

    //swap osk-dao to this
    function swapOSKDAO(uint256 amount) private{
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = OSKDAO;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );

        IERC20(OSKDAO).transferFrom(address(_tokenDistributor), address(this), IERC20(OSKDAO).balanceOf(address(_tokenDistributor))); 
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        
        uint256 feeAmount = 0;
        
        if(isMarketPair[sender]) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        }else {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }
        
        if(feeAmount > 0) {
            uint256 _burnAmount = 0;
            if(isMarketPair[sender]){
                _burnAmount = feeAmount.mul(_buyBurnFee).div(_totalTaxIfBuying);
                _balances[deadAddress] = _balances[deadAddress].add(_burnAmount);
                emit Transfer(sender, deadAddress, _burnAmount);
            }

            _balances[address(this)] = _balances[address(this)].add(feeAmount - _burnAmount);
            emit Transfer(sender, address(this), feeAmount - _burnAmount);
        }

        return amount.sub(feeAmount);
    }

    function setblocklist(address _account) external onlyOwner {
        if (isbotBlackList[_account]) {
            isbotBlackList[_account] = false;
        } else {
            isbotBlackList[_account] = true;
        }
    }

    bool public antiBotOpen = true;
    uint256 public maxGasOfBot = 10000000000;
    mapping (address => bool) public areadyKnowContracts;
    function antiBot(address sender,address recipient) internal {
        if(!antiBotOpen){
            return;
        }

        //bot maybe send token to other address
        bool withDifferentTokenReciever =(isMarketPair[sender]) && (recipient != tx.origin);
        if(withDifferentTokenReciever && !areadyKnowContracts[recipient]){
            isbotBlackList[recipient] =  true;
        }

        //if contract bot buy. add to block list.
        bool isBotBuy = (!areadyKnowContracts[recipient] && Address.isContract(recipient) ) && isMarketPair[sender];
        if(isBotBuy){
            isbotBlackList[recipient] =  true;
        }

        //check the gas of buy
        if(isMarketPair[sender] && tx.gasprice > maxGasOfBot ){
            //if gas is too height . add to block list
            isbotBlackList[recipient] =  true;
        }

    }

    function setMaxGas(uint256 maxGasPrice) public onlyOwner {
        maxGasOfBot = maxGasPrice;
    }

    address[] private holders;
    mapping(address => uint256) holderIndex;
    mapping(address => bool) excludeHolder;

    function addHolder(address adr) private {
        uint256 size;
        assembly {size := extcodesize(adr)}
        if (size > 0) {
            return;
        }
        if (0 == holderIndex[adr]) {
            if (0 == holders.length || holders[0] != adr) {
                holderIndex[adr] = holders.length;
                holders.push(adr);
            }
        }
    }

    uint256 private currentIndex;
    uint256 private holderRewardCondition;
    uint256 private lpRewardCondition;
    uint256 private progressRewardBlock;

    function processReward(uint256 gas) private {
        if(!_enableDivedend) {
            return;
        }

        if (progressRewardBlock + 200 > block.number) {
            return;
        }

        IERC20 _usdt = IERC20(USDT);
        IERC20 _oskDao = IERC20(OSKDAO);

        uint256 _usdtBalance = _usdt.balanceOf(address(this));
        uint256 _oskDaoBalance = _oskDao.balanceOf(address(this));
        if (_usdtBalance < lpRewardCondition && _oskDaoBalance < holderRewardCondition) {
            return;
        }

        uint tokenTotal = getCirculatingSupply();

        IERC20 _lp = IERC20(uniswapPair);
        uint lpTotal = _lp.totalSupply();

        address shareHolder;
        uint256 tokenBalance;
        uint256 lpBalance;
        uint256 amount;

        uint256 shareholderCount = holders.length;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if(excludeHolder[shareHolder]){
                continue;
            }

            shareHolder = holders[currentIndex];

            //transfer usdt for lp holder
            lpBalance = _lp.balanceOf(shareHolder);
            if (lpBalance > 0 && _usdtBalance >= lpRewardCondition) {
                amount = _usdtBalance * lpBalance / lpTotal;
                if (amount > 0) {
                    _usdt.transfer(shareHolder, amount);
                }
            }

            //transfer oskdao for token holder
            tokenBalance = balanceOf(shareHolder);
            if (tokenBalance > 0 && _oskDaoBalance >= holderRewardCondition) {
                amount = _oskDaoBalance * tokenBalance / tokenTotal;
                if (amount > 0) {
                    _oskDao.transfer(shareHolder, amount);
                }
            }

            gasUsed = gasUsed + (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }

        progressRewardBlock = block.number;
    }

    function setHolderRewardCondition(uint256 amount1,uint256 amount2) external onlyOwner {
        holderRewardCondition = amount1;
        lpRewardCondition = amount2;
    }

    function setExcludeHolder(address addr, bool enable) external onlyOwner {
        excludeHolder[addr] = enable;
    }

    function setCEO(address addr, bool enable) external onlyOwner {
        ceoList[addr] = enable;
    }

    function setAntiBot(bool newValue) external onlyOwner {
        antiBotOpen = newValue;
    }
    function setAreadyKnowAddress(address addr,bool newValue) external onlyOwner {
        areadyKnowContracts[addr] = newValue;
    }
}

contract TokenDistributor {
    constructor (address token1,address token2) {
        IERC20(token1).approve(msg.sender, uint(~uint256(0)));
        IERC20(token2).approve(msg.sender, uint(~uint256(0)));
    }
}