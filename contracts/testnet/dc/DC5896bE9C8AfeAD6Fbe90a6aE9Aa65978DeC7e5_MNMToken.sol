/**
 *Submitted for verification at BscScan.com on 2022-09-28
*/

pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Context {

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// pragma solidity >=0.5.0;

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


// pragma solidity >=0.5.0;

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

// pragma solidity >=0.6.2;

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



// pragma solidity >=0.6.2;

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

pragma solidity 0.6.12;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

pragma solidity 0.6.12;


interface IERC721 is IERC165 {
   
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    

   
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

   
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

   
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint);

  
    function ownerOf(uint256 tokenId) external view returns (address owner);
    

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);

 
    function setApprovalForAll(address operator, bool _approved) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface AddLiquidityPool{
    function swapAndLiquify(uint256 tokenAmount)external;
}
 
contract ERC20 is Context,IERC20,Ownable{
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) private _allowances;



    uint private _totalSupply;

    uint256 public startingPrice;
    uint public nextUpdateTime;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _liquidityFee=50;
 
    uint256 public _benefitnftDividendsFee=30;

    uint256 public _shareholderNftDividendsFee1=40;

    uint256 public _shareholderNftDividendsFee2=30;

    uint256 public _marketingFee = 50;

    uint256 public _burnFeeOfBuy=50;

    uint256 public _burnFeeOfSell=30;

    uint256 public _burnFeeOfTransfer=60;
    uint256 public _burnFeeOfRiot=150;

    uint256 public positionTokensToReferrerDividends=1000*10**18;
    uint256 public numOfMinimumInvitation=10;


    bool inSwapAndLiquify;
    bool public swapAndSendEnabled = true;
    bool isCreatePair;



    address public BenefitNftAddress=0x647CEb4d459b49940C0718Ebee97f99810968cBB;
    address public ShareholderNftAddress=0x71fCA6Bb1F786c2C09420a49f0d0379604f64942;
    address public usdtAddress=0xC0186d19d05Ca1986bc3587cB7B172CA0934F8b4;
    address public marketingAddress=0x11d1CE75b3cd511a01a150dac88Af94Ba2364f20;
    address public ShareholderNftPool=0xC517Ae00Cc5f35dc9C8896b216b99d79388FeA87;
    address public BenefitNftAddressPool=0xcaBcB1d9C77fc9Bd5929bc180985ca43f8E96442;

    address public addLiquidityPool=0x28Fb64E36224c42cA33a555FE6B1f79d08C45D66;
    
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    mapping (address => bool) public _isExcludedFromFee;

    bool public swapAndLiquifyEnabled = true;

    uint256 public numTokensSellToDividendsFee = 10*10**18;

    uint256 public numTokensToSell=10*10**18;

    
    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), 0xC0186d19d05Ca1986bc3587cB7B172CA0934F8b4);

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[address(addLiquidityPool)] = true;
        _isExcludedFromFee[address(ShareholderNftPool)] = true;
        _isExcludedFromFee[address(BenefitNftAddressPool)] = true;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view  override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    function _transfer(address from,address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        uint256 thisBalance = balanceOf(address(this));
        uint256 liquidityPoolBalance = balanceOf(address(addLiquidityPool));

        if (
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
           swapAndLiquify(liquidityPoolBalance,thisBalance);
        }
        uint256 priceNow;
        if(isCreatePair){
            if(block.timestamp>=nextUpdateTime){
                nextUpdateTime=block.timestamp+(3600-block.timestamp%3600);
                startingPrice=getPriceOfUSDT();
            }
            priceNow=getPriceOfUSDT();
        }
        bool takeFee = true;
 
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        uint256 totalFee;

        if (takeFee){
            if (from==uniswapV2Pair){
                totalFee=totalFee.add(calculateByBuy(from,amount));
   
            }else if (to==uniswapV2Pair){
                require(amount<=100000*10**18,"Sell ​​limit exceeded");
                if(priceNow<startingPrice){
                    uint spread=startingPrice.sub(priceNow);
                    if(spread.mul(10**18).div(startingPrice)>=1*10**17){
                        uint BurnFee=calculateBurnFeeOfRiot(amount);
                        _takeBurnFee(from,BurnFee);
                        totalFee=totalFee.add(BurnFee);
                    }
                }
                totalFee=totalFee.add(calculateBySell(from,amount));
            }else{
                totalFee=totalFee.add(calculateByTransfer(from,amount));
            }
        }

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        uint256 trunAmount=amount.sub(totalFee);
        _balances[to] = _balances[to].add(trunAmount);
        emit Transfer(from, to, trunAmount);

        if (to==uniswapV2Pair&&!isCreatePair){
            require(from==owner());
            nextUpdateTime=block.timestamp+(3600-block.timestamp%3600);
            isCreatePair=true;
            startingPrice=getPriceOfUSDT();
        }

    }
    function calculateByBuy(address from,uint256 amount)internal returns(uint256 totalFee){
            uint256 BurnFee=calculateBurnFeeOfBuy(amount);
            _takeBurnFee(from,BurnFee);
            uint256 LiquidityFee=calculateLiquidityFee(amount);
            _takeLiquidityFee(from,LiquidityFee);
            return totalFee=BurnFee.add(LiquidityFee);
    }

    function calculateBySell(address from,uint256 amount)internal returns(uint256 totalFee){
            uint256 MarketingFee=calculateMarketingFee(amount);
            _takeMarketingFee(from,MarketingFee);
            uint256 ShareholderNftDividendsFee=calculateShareholderNftDividendsFee1(amount);
            _takeShareholderNftDividendsFee(from,ShareholderNftDividendsFee);
            uint256 BenefitNftDividendsFee=calculateBenefitNftDividendsFee(amount);
            _takeBenefitNftDividendsFee(from,BenefitNftDividendsFee);
            uint256 BurnFee=calculateBurnFeeOfSell(amount);
            _takeBurnFee(from,BurnFee);
            return totalFee=MarketingFee.add(ShareholderNftDividendsFee).add(BurnFee).add(BenefitNftDividendsFee);
    }
    function calculateByTransfer(address from,uint256 amount)internal returns(uint256 totalFee){
            uint256 BurnFee=calculateBurnFeeOfTransfer(amount);
            _takeBurnFee(from,BurnFee);
            return BurnFee;
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
  

    function setShareholderNftDividendsPercent(uint256 nftDividendsFee1,uint256 nftDividendsFee2) external onlyOwner() {
        _shareholderNftDividendsFee1 = nftDividendsFee1;
        _shareholderNftDividendsFee2 = nftDividendsFee2;
    }

    function setPositionTokensToReferrerDividends(uint256 num) external onlyOwner(){
        positionTokensToReferrerDividends=num;
    }

    function setNumOfMinimumInvitation(uint256 num) external onlyOwner(){
        numOfMinimumInvitation=num;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {
        _marketingFee = marketingFee;
    }


    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setBurnPercent(uint256[4] memory burnFee) external onlyOwner() {
        _burnFeeOfBuy = burnFee[0];
        _burnFeeOfSell = burnFee[1];
        _burnFeeOfTransfer=burnFee[2];
        _burnFeeOfRiot=burnFee[3];
    }

    function setLiquidityFeePercent(uint256 liquidityFeeFee) external onlyOwner() {
        _liquidityFee = liquidityFeeFee;
    }

    function setAddLiquidityPool(address _addLiquidityPool) external onlyOwner() {
        addLiquidityPool = _addLiquidityPool;
    }

    function setNumTokensSellToNftDividendsFee(uint256 _num)public onlyOwner{
        numTokensSellToDividendsFee=_num;
    }

    function setNumTokensToSell(uint256 _num)public onlyOwner{
        numTokensToSell=_num;
    }

    function setBenefitNftAddress(address _addr)public onlyOwner{
        BenefitNftAddress=_addr;
    }

    function setShareholderNftAddress(address _addr)public onlyOwner{
        ShareholderNftAddress=_addr;
    }



    function calculateBenefitNftDividendsFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_benefitnftDividendsFee).div(
            10**3
        );
    }

    function calculateShareholderNftDividendsFee1(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_shareholderNftDividendsFee1).div(
            10**3
        );
    }
    function calculateShareholderNftDividendsFee2(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_shareholderNftDividendsFee2).div(
            10**3
        );
    }


    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**3
        );
    }

    function calculateBurnFeeOfBuy(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFeeOfBuy).div(
            10**3
        );
    }

    function calculateBurnFeeOfSell(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFeeOfSell).div(
            10**3
        );
    }



    function calculateBurnFeeOfTransfer(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFeeOfTransfer).div(
            10**3
        );
 
    }

    function calculateBurnFeeOfRiot(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFeeOfRiot).div(
            10**3
        );
 
    }

    

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**3
        );
    }


    function _takeShareholderNftDividendsFee(address from,uint256 ShareholderNftDividendsFee) private {
        if (ShareholderNftDividendsFee==0)return;

        _balances[address(ShareholderNftPool)] = _balances[address(ShareholderNftPool)].add(ShareholderNftDividendsFee);

        emit Transfer(from, address(ShareholderNftPool),ShareholderNftDividendsFee);
    }

    function _takeBenefitNftDividendsFee(address from,uint256 BenefitNftDividendsFee) private {
        if (BenefitNftDividendsFee==0)return;

        _balances[address(BenefitNftAddressPool)] = _balances[address(BenefitNftAddressPool)].add(BenefitNftDividendsFee);

        emit Transfer(from, address(BenefitNftAddressPool),BenefitNftDividendsFee);
    }



    function _takeMarketingFee(address from,uint256 MarketingFee) private {
        if (MarketingFee==0)return;
        _balances[address(this)]= _balances[address(this)].add(MarketingFee);
        emit Transfer(from, address(this),MarketingFee);
    }

    function _takeLiquidityFee(address from,uint256 LiquidityFee) private {
        if(LiquidityFee==0)return;

        _balances[address(addLiquidityPool)] = _balances[address(addLiquidityPool)].add(LiquidityFee);  
        emit Transfer(from, address(addLiquidityPool),LiquidityFee);
        
    }


    function _takeBurnFee(address from,uint256 BurnFee) private {
        if (BurnFee==0)return;
        _balances[address(0xdead)] = _balances[address(0xdead)].add(BurnFee);
        emit Transfer(from, address(0xdead),BurnFee);
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }




   function swapAndLiquify(uint256 contractTokenBalance,uint256 tokenAmount) private lockTheSwap{

        if(contractTokenBalance >= numTokensToSell){
            AddLiquidityPool(addLiquidityPool).swapAndLiquify(contractTokenBalance);

        }

        if(tokenAmount>= numTokensToSell){
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdtAddress;

            _approve(address(this), address(uniswapV2Router), tokenAmount);

            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                marketingAddress,
                block.timestamp
            );

        }
        

    }

    function  getPriceOfUSDT() public view returns (uint256 price){
        uint256 balancePath1= IERC20(usdtAddress).balanceOf(uniswapV2Pair);
        uint256 balancePath2= IERC20(address(this)).balanceOf(uniswapV2Pair);
        uint256 path1Decimals=IERC20(usdtAddress).decimals();
        uint256 path2Decimals=IERC20(address(this)).decimals();
        price=(balancePath1*10**18/10**path1Decimals)/(balancePath2/10**path2Decimals);
    }


    receive() external payable {}
}


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    
    
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract MNMToken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  constructor () public ERC20("MNM Token", "MNM", 18,1000000000*10**18) {
       _balances[msg.sender] = totalSupply();
        emit Transfer(address(0),msg.sender, totalSupply());
  }
}