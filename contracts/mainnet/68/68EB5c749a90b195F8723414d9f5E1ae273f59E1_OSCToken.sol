/**
 *Submitted for verification at BscScan.com on 2022-10-09
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

    uint256 public BASE_RATIO = 10**18; 
    uint256 public SPY = 116;//0.0116;

    uint private _totalSupply;
    uint256 public extraSupply; 
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _liquidityFee=50;
    uint256 public _referrerFee=80;
    uint256 public _technologyFundFee=20;

    

    uint256 public _NFTFee=50;
    uint256 public _burnFee=20;
    uint256 public _publicityFundFee=20;
    uint256 public _bountyFee=10;


    uint256 public _marketingFee = 150;
    uint256 public numTokensToSell=10*10**18;
    uint256 public numTokensSellToNftDividendsFee=10*10**18;

    mapping(address => uint256) public lastUpdateTime; 
    

    mapping(address => address) public referralRelationships; // store referall relationship: referree > referrer
    mapping(address => bool) public alreadyBuy;
    mapping (address => bool) public _isExcludedFromFee;
    mapping(address=>bool) private isExcludedFromReferral;
    mapping(address => bool) public rewardBlacklist;


    bool inSwapAndLiquify;
    bool public swapAndSendEnabled = true;
    bool isCreatePair;

    address public usdtAddress=0x55d398326f99059fF775485246999027B3197955;
    address public NFTAddress=0xdAF4e3026858b50BAC0C04071542DB2970778115;
    address public marketingAddress=0x33a27888b1dd4c6E8889d7c17d83776c588C37CF;
    address public publicityFundAddress1=0xf114a59B7a2dcD08f2a0bb31F7B9E369A582B26e;
    address public publicityFundAddress2=0x1650b250A250e49DF3c9A3D69a1E81D9330d92A7;
    address public publicityFundAddress3=0x822Bca239BD08F6e7f660015Db95B7B51e64bC85;
    address public publicityFundAddress4=0x07AE0fDea35D647C10f6CaF1a15e490617f3814c;
    address public publicityFundAddress5=0x828364E66AAA03FCFA441D421aaceF54d6D72a78;
    address public technologyFundAddress=0x9F06bF9B93e0C772B161F8EdA9F9D56a083A38a6;
    address public bountyAddress=0xc1d8A211127fF25CEaD3D476B94a1B727Eb2084F;
    address public addLiquidityPool=0xF622d5ad1212142E7B7568FfAA6D0350629C556d;
    
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    bool public swapAndLiquifyEnabled = true;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping(address => bool) private _updated;
    uint256 currentIndex;  
    bool public openNftDividends=false;

    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[address(addLiquidityPool)] = true;
        _isExcludedFromFee[address(publicityFundAddress1)] = true;
        _isExcludedFromFee[address(publicityFundAddress2)] = true;
        _isExcludedFromFee[address(publicityFundAddress3)] = true;
        _isExcludedFromFee[address(publicityFundAddress4)] = true;
        _isExcludedFromFee[address(publicityFundAddress5)] = true;
        _isExcludedFromFee[address(technologyFundAddress)] = true;
        _isExcludedFromFee[address(bountyAddress)] = true;
        isExcludedFromReferral[owner()]=true;
        isExcludedFromReferral[marketingAddress]=true;
        isExcludedFromReferral[address(publicityFundAddress1)]=true;
        isExcludedFromReferral[address(publicityFundAddress2)]=true;
        isExcludedFromReferral[address(publicityFundAddress3)]=true;
        isExcludedFromReferral[address(publicityFundAddress4)]=true;
        isExcludedFromReferral[address(publicityFundAddress5)]=true;
        isExcludedFromReferral[address(technologyFundAddress)] = true;
        isExcludedFromReferral[address(bountyAddress)] = true;
        rewardBlacklist[address(this)]=true;
        rewardBlacklist[uniswapV2Pair]=true;
        rewardBlacklist[owner()]=true;
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
        return _totalSupply.add(extraSupply);
    }
    function balanceOf(address account) public view override returns (uint) {
         return _balances[account].add(getReward(account));
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


    modifier calculateReward(address account) {
        if (account != address(0)) {
            uint256 reward = getReward(account);
            if (reward > 0) {
                _balances[account] = _balances[account].add(reward);
                extraSupply = extraSupply.add(reward);
                
            }
            lastUpdateTime[account] = lastTime();
        }
        _;
    }

    function setRewardBlacklist(address account, bool enable) public onlyOwner {
        rewardBlacklist[account] = enable;
    }
 
    function getReward(address account) public view returns (uint256) {
       
        if (lastUpdateTime[account] == 0 || rewardBlacklist[account]) {
            return 0;
        }
        return
            _balances[account].mul(SPY).div(1000000).mul(
                (lastTime().sub(lastUpdateTime[account])).div(10 minutes)
            );
    }
  
    function lastTime() public view returns (uint256) {
        return block.timestamp;
        // return Math.min(block.timestamp, rewardEndTime);
    }

    function _transfer(address from,address to, uint256 amount) calculateReward(from) calculateReward(to) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        uint256 liquidityPoolBalance = balanceOf(address(addLiquidityPool));

        if (
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
           swapAndLiquify(liquidityPoolBalance);
        }

        if (from==uniswapV2Pair&&!alreadyBuy[to]){
            alreadyBuy[to]=true;
        }
        if (!address(from).isContract()&&!address(to).isContract()){
            _updateReferralRelationship(from,to);
        }
        bool takeFee = true;
 
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        uint256 totalFee;

        if (takeFee){
            if (from==uniswapV2Pair){
                totalFee=totalFee.add(calculateByBuy(from,to,amount));
   
            }else if (to==uniswapV2Pair){
                totalFee=totalFee.add(calculateBySell(from,amount));
            }else{
                totalFee=totalFee.add(calculateByTransfer(from,amount));
            }
        }

        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        uint256 trunAmount=amount.sub(totalFee);
        _balances[to] = _balances[to].add(trunAmount);
        emit Transfer(from, to, trunAmount);
        if(!address(from).isContract() && from != address(0) ) setShare(from);
        if(!address(to).isContract() && to != address(0) ) setShare(to);

        if(_balances[address(this)] >= numTokensSellToNftDividendsFee&&openNftDividends) {
             process(500000);
        }
        if (to==uniswapV2Pair&&!isCreatePair){
            require(from==owner());
            isCreatePair=true;
        }

    }

    function dividendsToReferrer(address from,uint256 Amount)private{
        uint8 i=1;
        address userAddress=from;
        while (true) {
            address referalAddress=referralRelationships[userAddress]; 
            if (i==11){
                break;
            }
            uint AmountDividend=getAmountDividend(Amount);
            if(referalAddress==address(0)){
                _balances[address(0xdead)] = _balances[address(0xdead)].add(AmountDividend);
                emit Transfer(from, address(0xdead), AmountDividend);
            }else{
                _balances[referalAddress] = _balances[referalAddress].add(AmountDividend);
                emit Transfer(from, referalAddress, AmountDividend);
            }
            userAddress =referalAddress;
            i++;
        }
    }

    function getAmountDividend(uint256 amount)private pure returns(uint256){
         return amount.mul(8).div(10);
    }

    function calculateByBuy(address from,address to,uint256 amount)internal returns(uint256 totalFee){
            uint256 LPFee=calculateLiquidityFee(amount);
            _takeLiquidityFee(from,LPFee);
            uint256 referrerFee=calculateReferrerFee(amount);
            _takeReferrerFee(to,referrerFee);
            uint256 technologyFundFee=calculateTechnologyFundFee(amount);
            _takeTechnologyFundFee(from,technologyFundFee);
            
            return totalFee=LPFee.add(referrerFee).add(technologyFundFee);
    }

    function calculateBySell(address from,uint256 amount)internal returns(uint256 totalFee){
            uint256 LPFee=calculateLiquidityFee(amount);
            _takeLiquidityFee(from,LPFee);
            uint256 NFTFee=calculateNFTFee(amount);
            _takeNFTFee(from,NFTFee);
            uint256 BurnFee=calculateBurnFee(amount);
            _takeBurnFee(from,BurnFee);
            uint256 PublicityFundFee=calculatePublicityFundFee(amount);
            _takePublicityFundFee(from,PublicityFundFee);
            uint256 BountyFee=calculateBountyFee(amount);
            _takeBountyFee(from,BountyFee);
            return totalFee=LPFee.add(NFTFee).add(BurnFee).add(PublicityFundFee).add(BountyFee);
    }
    function calculateByTransfer(address from,uint256 amount)internal returns(uint256 totalFee){
            uint256 MarketingFee=calculateMarketingFee(amount);
            _takeMarketingFee(from,MarketingFee);
            return MarketingFee;
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setNumTokensSellToNftDividendsFee(uint256 _num)public onlyOwner{
        numTokensSellToNftDividendsFee=_num;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {
        _marketingFee = marketingFee;
    }
    function setReferrerFeePercent(uint256 referrerFee) external onlyOwner() {
        _referrerFee = referrerFee;
    }
    function setPublicityFundFeePercent(uint256 publicityFundFee) external onlyOwner() {
        _publicityFundFee = publicityFundFee;
    }
    function setBountyFeePercent(uint256 bountyFee) external onlyOwner() {
        _bountyFee = bountyFee;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
    }

    function setBurnPercent(uint256 burnFee) external onlyOwner() {
        _burnFee = burnFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }

    function setTechnologyFundFeePercent(uint256 technologyFundFee) external onlyOwner() {
        _technologyFundFee = technologyFundFee;
    }

    

    function setAddLiquidityPool(address _addLiquidityPool) external onlyOwner() {
        addLiquidityPool = _addLiquidityPool;
    }

    function setNftAddress(address _addr)public onlyOwner{
        NFTAddress=_addr;
    }

    function setOpenNftDividends(bool _bool)public onlyOwner{
        openNftDividends=_bool;
    }


    function calculateNFTFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_NFTFee).div(
            10**3
        );
    }


    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**3
        );
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**3
        );
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**3
        );
    }
    function calculateTechnologyFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_technologyFundFee).div(
            10**3
        );
    }

    function calculatePublicityFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_publicityFundFee).div(
            10**3
        );
    }

    function calculateBountyFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_bountyFee).div(
            10**3
        );
    }

    function calculateReferrerFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_referrerFee).div(
            10**3
        );
    }


    function _takeMarketingFee(address from,uint256 MarketingFee) private {
        if (MarketingFee==0)return;
        _balances[address(marketingAddress)]= _balances[address(marketingAddress)].add(MarketingFee);
        emit Transfer(from, address(marketingAddress),MarketingFee);
    }
    function _takeNFTFee(address from,uint256 NFTFee) private {
        if (NFTFee==0)return;
        _balances[address(this)]= _balances[address(this)].add(NFTFee);
        emit Transfer(from, address(this),NFTFee);
    }


    function _takeLiquidityFee(address from,uint256 LiquidityFee) private {
        if(LiquidityFee==0)return;

        _balances[address(addLiquidityPool)] = _balances[address(addLiquidityPool)].add(LiquidityFee);  
        emit Transfer(from, address(addLiquidityPool),LiquidityFee);
        
    }

    function _takeTechnologyFundFee(address from,uint256 TechnologyFundFee) private {
        if(TechnologyFundFee==0)return;

        _balances[address(technologyFundAddress)] = _balances[address(technologyFundAddress)].add(TechnologyFundFee);  
        emit Transfer(from, address(technologyFundAddress),TechnologyFundFee);
        
    }
    function _takeBountyFee(address from,uint256 BountyFee) private {
        if(BountyFee==0)return;
        _balances[address(bountyAddress)] = _balances[address(bountyAddress)].add(BountyFee);  
        emit Transfer(from, address(bountyAddress),BountyFee);
    }

    function _takePublicityFundFee(address from,uint256 PublicityFundFee) private {
        if(PublicityFundFee==0)return;
        _balances[address(publicityFundAddress1)] = _balances[address(publicityFundAddress1)].add(PublicityFundFee.div(5));  
        _balances[address(publicityFundAddress2)] = _balances[address(publicityFundAddress2)].add(PublicityFundFee.div(5));  
        _balances[address(publicityFundAddress3)] = _balances[address(publicityFundAddress3)].add(PublicityFundFee.div(5));  
        _balances[address(publicityFundAddress4)] = _balances[address(publicityFundAddress4)].add(PublicityFundFee.div(5));  
        _balances[address(publicityFundAddress5)] = _balances[address(publicityFundAddress5)].add(PublicityFundFee.div(5));  
        emit Transfer(from, address(publicityFundAddress1),PublicityFundFee.div(5));
        emit Transfer(from, address(publicityFundAddress2),PublicityFundFee.div(5));
        emit Transfer(from, address(publicityFundAddress3),PublicityFundFee.div(5));
        emit Transfer(from, address(publicityFundAddress4),PublicityFundFee.div(5));
        emit Transfer(from, address(publicityFundAddress5),PublicityFundFee.div(5));
    }



    function _takeBurnFee(address from,uint256 BurnFee) private {
        if (BurnFee==0)return;
        _balances[address(0xdead)] = _balances[address(0xdead)].add(BurnFee);
        emit Transfer(from, address(0xdead),BurnFee);
    }

    function _takeReferrerFee(address from,uint256 ReferrerFee) private {

        dividendsToReferrer(from,ReferrerFee);
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }


   function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap{

        if(contractTokenBalance >= numTokensToSell){
            AddLiquidityPool(addLiquidityPool).swapAndLiquify(contractTokenBalance);

        }

    }


    function _updateReferralRelationship(address from, address to) internal {

        if (address(from).isContract()||address(to).isContract()){
            return;
        }

        if (alreadyBuy[to]==true){
          return;
        }
        if(isExcludedFromReferral[to]){
            return;
        }
        if (from== to) { // referrer cannot be user himself/herself
          return;
        }

        if (referralRelationships[to] != address(0)) { // referrer has been set
          return;
        }

        if (referralRelationships[from] == to) { 
          return;
        }

        referralRelationships[to] = from;

    }

    function getReferralRelationship(address user) public view returns(address){
        return referralRelationships[user];
    }
    function process(uint256 gas) private {
        
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _balances[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
                
            }
            uint256 amount = nowbanance.mul(IERC721(NFTAddress).balanceOf(shareholders[currentIndex])).div(IERC721(NFTAddress).totalSupply());

            if(_balances[address(this)] < amount)return;
                distributeDividend(shareholders[currentIndex],amount);
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
            _balances[address(this)] = _balances[address(this)].sub(amount);
            _balances[shareholder] = _balances[shareholder].add(amount);
             emit Transfer(address(this), shareholder, amount);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC721(NFTAddress).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC721(NFTAddress).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
      }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
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

contract OSCToken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  constructor () public ERC20("OSC Token", "OSC", 18,10000000*10**18) {
       _balances[msg.sender] = totalSupply();
        emit Transfer(address(0),msg.sender, totalSupply());
  }
}