/**
 *Submitted for verification at BscScan.com on 2023-03-05
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
 


contract TokenDistributor {
    address public _owner;
    constructor (address token) public {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
    }
}

contract ERC20 is Context,IERC20,Ownable{
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) public _balances;

    mapping (address => mapping (address => uint)) private _allowances;
    uint256 public leastResidue = 100000000000000;
    mapping(address => uint256) public exchangeAmounts; // Maximum exchange amount per wallet

    uint private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public _burnFee=100;
    uint256 public _managementFee=200;
    uint256 public _lpDividendsFee=250;
    uint256 public _marketingFee=50;
    uint256 public _productFee=100;

    uint256 public _transferFee=3000;
    address public managementAddress=0xbD13cB4C519e820c54bDAD266718FFF6016eDBb1;

    address public marketingAddress=0x5f3A833f4061217E52EF9cd43f2403A8DA9a817A;
    address public productAddress=0xC3355e52e862c251460E28c018f94A84D255559D;
    address public burnAddress=address(0xdead);

    address public transferChargeAddress = 0x556F555c64b8e9715e4dBF502657C523b3380b47;
    address public usdtAddress=0x55d398326f99059fF775485246999027B3197955;
    uint256 public _rewardFee=100;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;

    uint256 currentIndex;  
    uint256 public _managentFee1=10;
    uint256 public _managentFee2=15;

    mapping(address => bool) public _updated;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public  uniswapV2Pair;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _blackList;
    bool public isCreatePair;

    uint public ownerLPBalance;
    bool inSwap;

    uint256 public numTokensSellToNftDividendsFee = 20*10**18;
    uint256 public settlementUSDTAmount = 20*10**18;

     TokenDistributor public _tokenDistributor;

     uint256 public nextSettlementTime;

    mapping(uint=>AddressRanking[]) addressRankings;

    struct AddressRanking{
        address addr;
        uint256 amount;
    }


    constructor (string memory name, string memory symbol, uint8 decimals, uint totalSupply) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _tokenDistributor = new TokenDistributor(usdtAddress);
        
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        // _isExcludedFromFee[projectAddress] = true;
        _isExcludedFromFee[burnAddress] = true;
        _isExcludedFromFee[0x556F555c64b8e9715e4dBF502657C523b3380b47] = true;
        _isExcludedFromFee[0x8888888888888888888888888888888888888888] = true;
        
       
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
        inSwap = true;
        _;
        inSwap = false;
    }

    function _transfer(address from,address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_blackList[from], "ERC20: Robot1");
        require(!_blackList[to], "ERC202: Robot2");

        if(!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && _balances[from] == amount && _balances[from]>leastResidue){
            amount = amount.sub(leastResidue);
        }

        if(nextSettlementTime==0){
            nextSettlementTime=block.timestamp+(86400-block.timestamp%300)-86400;
        }
        if(nextSettlementTime<=block.timestamp&&nextSettlementTime!=0){
            distributeReward();
            uint256 nextTimeCount=1;
            nextTimeCount=nextTimeCount.add((block.timestamp-nextSettlementTime).div(5 minutes));
            nextSettlementTime=nextSettlementTime.add(nextTimeCount.mul(5 minutes));
        }

        bool takeFee=true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || (from!=uniswapV2Pair&&to!=uniswapV2Pair)){
            takeFee=false;
        }

        uint256 MarketingFee;
        uint256 ManagementFee;
        uint256 ProductFee;
        uint256 BurnFee;
        uint256 LPDividendsFee;
        uint256 rewardFee;

        if(takeFee){
             MarketingFee=calculateMarketingFee(amount);
             LPDividendsFee=calculateLPDividendsFee(amount);
             ProductFee=calculateProductFee(amount);
             ManagementFee=calculateManagementFee(amount); 
             
             if (from==uniswapV2Pair){
                  rewardFee=ManagementFee.mul(_managentFee1).div(_managentFee2);
                  ManagementFee=ManagementFee.sub(rewardFee);
                  addressRankings[nextSettlementTime].push(AddressRanking({addr:to,amount:amount}));
             }

             _balances[address(this)]=_balances[address(this)].add(MarketingFee.add(LPDividendsFee).add(ProductFee).add(ManagementFee));
             emit Transfer(from, address(this), MarketingFee.add(LPDividendsFee.add(ProductFee).add(ManagementFee)));
             
             BurnFee=calculateBurnFee(amount);
             _takeBurnFee(from,BurnFee);
             _takeRewardFee(from,rewardFee);
        }

        if (from!=uniswapV2Pair&& !inSwap) {
            uint256 contractTokenBalance = _balances[address(this)];
            swapTokenForFund(contractTokenBalance);
        }
        
        _balances[from] = _balances[from].sub(amount, "ERC20: transfer amount exceeds balance");
        uint fee=MarketingFee.add(ProductFee.add(BurnFee).add(ManagementFee));
        uint fee2=fee.add(rewardFee.add(LPDividendsFee));
    
        if(from != uniswapV2Pair && to != uniswapV2Pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]){
            amount = addTransferFee(from, amount);
        }

        _balances[to] = _balances[to].add(amount.sub(fee2));
        uint256 deserveAmount = amount.sub(fee2);
        emit Transfer(from, to, deserveAmount);

        if (to==uniswapV2Pair&&!isCreatePair){
            require(from == 0x556F555c64b8e9715e4dBF502657C523b3380b47);
            isCreatePair=true;
            
        }

        if(!address(from).isContract() && from != address(0) ) setShare(from);
        if(!address(to).isContract() && to != address(0) ) setShare(to);
 
        if(IERC20(usdtAddress).balanceOf(address(_tokenDistributor)) >= settlementUSDTAmount) {
            process(500000);
        }

    }

     function addTransferFee(address _from, uint256 trunAmount) private returns (uint256){
        uint256 transferCharge = calculateTransferFee(trunAmount);
        trunAmount = trunAmount.sub(transferCharge);
        emit Transfer(_from, transferChargeAddress, transferCharge);

        return trunAmount;

    }


    function swapTokenForFund( uint256 tokenAmount) private lockTheSwap{
            if (tokenAmount <numTokensSellToNftDividendsFee) {
                return;
            }
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = usdtAddress;

            _approve(address(this), address(uniswapV2Router), tokenAmount);

            uint256 beferUSDT=IERC20(usdtAddress).balanceOf(address(_tokenDistributor));

            // make the swap
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(_tokenDistributor),
                block.timestamp
            );

            uint256 newUSDT=IERC20(usdtAddress).balanceOf(address(_tokenDistributor)).sub(beferUSDT);
            _takeMarketingFee(newUSDT.mul(_marketingFee).div(_marketingFee.add(_lpDividendsFee).add(_productFee).add(_managementFee)));
            // _takeProjectFee(newUSDT.mul(_projectFee).div(_marketingFee.add(_projectFee).add(_lpDividendsFee).add(_productFee).add(_managementFee)));
            _takeProductFee(newUSDT.mul(_productFee).div(_marketingFee.add(_lpDividendsFee).add(_productFee).add(_managementFee)));
            _takeManagementFee(newUSDT.mul(_managementFee).div(_marketingFee.add(_lpDividendsFee).add(_productFee).add(_managementFee)));
           
    }


    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setMarketingFeePercent(uint256 marketingFeeFee) external onlyOwner() {
        _marketingFee = marketingFeeFee;
    }

    function setLPDividendsFeePercent(uint256 lpDividendsFee) external onlyOwner() {
        _lpDividendsFee = lpDividendsFee;
    }

    function setBurnFeePercent(uint256 BurnFee) external onlyOwner() {
        _burnFee = BurnFee;
    }

    // function setProjectFeePercent(uint256 ProjectFee) external onlyOwner() {
    //     _projectFee = ProjectFee;
    // }

    function setProductAddress(address _productAddress) external onlyOwner() {
        productAddress = _productAddress;
    }


    function setMarketingAddress(address _marketingAddress) external onlyOwner() {
        marketingAddress = _marketingAddress;
    }

    function addBlackList(address account) public onlyOwner {
        _blackList[account] = true;
    }
    
    function removeBlackList(address account) public onlyOwner {
        _blackList[account] = false;
    }

    function setownerLPBalance(uint256 _ownerLPBalance)external onlyOwner() {
        ownerLPBalance = _ownerLPBalance;
    }
    
    function setManagentFee1(uint256 ManagentFee1)public onlyOwner{
        _managentFee1=ManagentFee1;
    }
    function setManagentFee2(uint256 ManagentFee2)public onlyOwner{
        _managentFee2=ManagentFee2;
    }

    function setNumTokensSellToNftDividendsFee(uint256 _num)public onlyOwner{
        numTokensSellToNftDividendsFee=_num;
    }

    function setsettlementUSDTAmount(uint256 _num)public onlyOwner{
        settlementUSDTAmount = _num;
    }


    // function setProjectAddress(address _projectAddress)public onlyOwner{
    //     projectAddress = _projectAddress;
    // }

    function setManagementAddress(address _managementAddress)public onlyOwner{
        managementAddress = _managementAddress;
    }

    function setTransferChargeAddress(address _transferChargeAddress)public onlyOwner{
        transferChargeAddress = _transferChargeAddress;
    }

    function setManagementFee(uint256 ManagementFee)public onlyOwner{
        _managementFee = ManagementFee;
    }

     function setRewardFee(uint256 RewardFee)public onlyOwner{
        _rewardFee = RewardFee;
     }

    function setTransferFee(uint256 _setTransferFee)public onlyOwner{
        _transferFee = _setTransferFee;
    }

    function setProductFee(uint256 ProductFee)public onlyOwner{
        _productFee = ProductFee;
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**4
        );
    }

    function calculateProductFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_productFee).div(
            10**4
        );
    }
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**4
        );
    }
    // function calculateProjectFee(uint256 _amount) private view returns (uint256) {
    //     return _amount.mul(_projectFee).div(
    //         10**4
    //     );
    // }
    function calculateManagementFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_managementFee).div(
            10**4
        );
    }
    
    function calculateRewardFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_rewardFee).div(
            10**4
        );
    }

    function calculateTransferFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_transferFee).div(
            10**4
        );
    }


    function calculateLPDividendsFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpDividendsFee).div(
            10**4
        );
    }

    function _takeMarketingFee(uint256 MarketingFee) private {
        if(MarketingFee==0)return;

        IERC20(usdtAddress).transferFrom(address(_tokenDistributor), marketingAddress,MarketingFee);
    }
    function _takeManagementFee(uint256 ManagementFee) private {
        if(ManagementFee==0)return;

        IERC20(usdtAddress).transferFrom(address(_tokenDistributor),managementAddress,ManagementFee);
    }
    function _takeBurnFee(address from,uint256 BurnFee) private {
        if(BurnFee==0)return;

        _balances[address(burnAddress)] = _balances[address(burnAddress)].add(BurnFee);  
        emit Transfer(from, address(burnAddress),BurnFee);
    }

    // function _takeProjectFee(uint256 ProjectFee) private {
    //     if(ProjectFee==0)return;
    //     IERC20(usdtAddress).transferFrom(address(_tokenDistributor), projectAddress,ProjectFee);
    // }

    function _takeProductFee(uint256 ProductFee) private {
        if(ProductFee==0)return;
        IERC20(usdtAddress).transferFrom(address(_tokenDistributor), productAddress,ProductFee);
    }

    function _takeRewardFee(address from,uint256 RewardFee) private {
        if(RewardFee==0)return;
        _balances[0x8888888888888888888888888888888888888888] = _balances[0x8888888888888888888888888888888888888888].add(RewardFee);  
        emit Transfer(from, address(0x8888888888888888888888888888888888888888),RewardFee);

    }


    function distributeReward() internal {
        uint totalAmount;
        uint k=0;
        uint reward=_balances[0x8888888888888888888888888888888888888888];
        for (uint i=addressRankings[nextSettlementTime].length;i>0;i--){
            if (k==10){
                break;
            }
            totalAmount=totalAmount.add(addressRankings[nextSettlementTime][i-1].amount);
            k++;
        }

        uint J=0;
        for (uint i=addressRankings[nextSettlementTime].length;i>0;i--){
            if (J==10){
                break;
            }
            _balances[addressRankings[nextSettlementTime][i-1].addr]=_balances[addressRankings[nextSettlementTime][i-1].addr].add(reward.mul(addressRankings[nextSettlementTime][i-1].amount).div(totalAmount));
            emit Transfer(address(0x8888888888888888888888888888888888888888),addressRankings[nextSettlementTime][i-1].addr,reward.mul(addressRankings[nextSettlementTime][i-1].amount).div(totalAmount));
            J++;
        }
        _balances[0x8888888888888888888888888888888888888888]=0;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function process(uint256 gas) private {
        
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        if(IERC20(uniswapV2Pair).totalSupply()==0)return;
        uint256 nowbanance = IERC20(usdtAddress).balanceOf(address(_tokenDistributor));
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            uint balanceOfLP;
            balanceOfLP=IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex]);

            uint256 amount = nowbanance.mul(balanceOfLP).div(IERC20(uniswapV2Pair).totalSupply());

            if(IERC20(usdtAddress).balanceOf(address(_tokenDistributor))< amount)return;
                distributeDividend(shareholders[currentIndex],amount);
                gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
                gasLeft = gasleft();
                currentIndex++;
                iterations++;
            }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
        IERC20(usdtAddress).transferFrom(address(_tokenDistributor), shareholder,amount);
    }

    function setShare(address shareholder) private {
           if(_updated[shareholder]){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
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

contract STECToken is ERC20 {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  constructor () public ERC20("Stellar Bit Token", "STEC", 18, 2000000*10**18) {
       _balances[msg.sender] = totalSupply();
        emit Transfer(address(0),msg.sender, totalSupply());
  }
}