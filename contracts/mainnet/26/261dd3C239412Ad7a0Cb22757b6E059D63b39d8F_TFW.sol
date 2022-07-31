/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;

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
        require(_owner == msg.sender , "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
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

interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

contract TFW is IERC20, Ownable {
    using SafeMath for uint256;
    using TransferHelper for address;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _blackList;

    uint256 public _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    //1% burn
    uint256 public _burnFee = 10;

    //1% rewards for add to liquidity
    uint256 public _liquidityFee = 10;

    //1% rewards for lp holder
    uint256 public _lpReflectionFee = 10;

    //1% Rewards for nft relection
    uint256 public _nftReflectionFee = 10;

    //2% Rewards for  node
    uint256 public _nodeFee = 20;

    //1% Rewards for  genesis nft holder
    uint256 public _genesisFee = 10;

    //5% Rewards for promoting users
    uint256 public _inviterFee = 50;
    uint256 public _inviterFather1Fee = 15;
    uint256 public _inviterFather2Fee = 10;
    uint256 public _inviterFather3To7Fee = 5;

    uint256 public _totalFee;

    //denominator
    uint256 public _denominatorOfFee = 1000;


    //Black hole address
    address private _burnAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _liquidityReciverAddress = address(0x197f6813D4D1F542f64976Aa14f177941FBE219e);
    address private _tokenReflectionAddress = address(0x0e659A62980425Fe9D483BA4E3045Fad28C31F1E);
    address private _lpReflectionAddress = address(0xF731f54d94179d8E0DA5D2A7322d08A03E788888);
    address private _nftReflectionAddress = address(0xE35DAc14d6cA80b78Eb8103E77599766A309dff8);
    address private _nodeRewardAddress = address(0x0b1E0f6EadD82611aEf8090aE079edB14Cb4eC07);
    address private _genesisRewardAddress = address(0x907183cD869475dE46a937E9d99e3359c258f675);

    mapping(address => address) private inviter;
    mapping(address => address[]) private inviterSuns;
    uint256 public startTime;
    uint256 public usdt_decimals = 18;

    uint256 public swapAt;
    bool public enableSwap = true;
    bool public swapByLimitOnly = false;

    IPancakeRouter02 public  _uniswapV2Router;
    address public uniswapV2Pair;

    //main
    address public pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public husdtTokenAddress = 0x55d398326f99059fF775485246999027B3197955;
    // // test
    // address public pancakeRouterAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // address public husdtTokenAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    bool inSwapAndLiquify;

    StorageTokenContract stc;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    constructor() {
        _name = "TFW";
        _symbol = "TFW";

        _decimals = 9;
        _totalSupply = 30000000 * 10**_decimals;
        swapAt = _totalSupply / 10000;

        _balance[msg.sender] = _totalSupply;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = msg.sender;
        startTime = block.timestamp.div(1 days).mul( 10000 days);

        _uniswapV2Router = IPancakeRouter02(pancakeRouterAddress);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), husdtTokenAddress);
        stc = new StorageTokenContract(address(this),husdtTokenAddress);

        _approve(address(this), address(_uniswapV2Router), uint(~uint256(0)));
        IERC20(husdtTokenAddress).approve(address(_uniswapV2Router), uint(~uint256(0)));

        _totalFee = _burnFee.add(_lpReflectionFee).add(_liquidityFee).add(_nftReflectionFee).add(_nodeFee).add(_genesisFee).add(_inviterFee);
        emit Transfer(address(0), msg.sender, _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
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

    function totalFees() public view returns (uint256) {
        return _totalFee;
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function getInviter(address user) public view returns (address) {
        return inviter[user];
    }

    function getInviterSunSize(address user) public view returns (uint256) {
        return inviterSuns[user].length;
    }

    function getInviterSun(address user,uint256 idx) public view returns (address) {
        return inviterSuns[user][idx];
    }


    function claimETH() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

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
        if(inSwapAndLiquify || _isExcludedFromFee[from] || _isExcludedFromFee[to]){ return _baseTransfer(from, to, amount); }

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(block.timestamp>=startTime,"The current time is less than the start time");
        require(!_blackList[from] && !_blackList[to]);

        mint();

        if(from != uniswapV2Pair && enableSwap ){
            swapAndAddLiquidity();
        }

        bool canInviter = from != uniswapV2Pair && balanceOf(to) == 0 && inviter[to] == address(0);

        if(from == uniswapV2Pair || to == uniswapV2Pair){
            takeFee(from, to, amount);
        }else{
            _baseTransfer(from, to, amount);
        }

        if(canInviter) {
            inviter[to] = from;
            inviterSuns[from].push(to);
        }
    }

    function takeFee (
        address sender,
        address recipient,
        uint256 amount
    ) private{
        _balance[sender] = _balance[sender].sub(amount);

        //inviter fee.
        _takeInviterFee(sender, recipient, amount);

        // other fees
        _takeTransfer(sender,_burnAddress,amount.div(_denominatorOfFee).mul(_burnFee));
        _takeTransfer(sender,address(this),amount.div(_denominatorOfFee).mul(_liquidityFee));
        _takeTransfer(sender,_lpReflectionAddress,amount.div(_denominatorOfFee).mul(_lpReflectionFee));
        _takeTransfer(sender,_nftReflectionAddress,amount.div(_denominatorOfFee).mul(_nftReflectionFee));
        _takeTransfer(sender,_nodeRewardAddress,amount.div(_denominatorOfFee).mul(_nodeFee));
        _takeTransfer(sender,_genesisRewardAddress,amount.div(_denominatorOfFee).mul(_genesisFee));

        uint256 recipientRate = _denominatorOfFee - _totalFee;
        _balance[recipient] = _balance[recipient].add(
            amount.div(_denominatorOfFee).mul(recipientRate)
        );

        emit Transfer(sender, recipient, amount.div(_denominatorOfFee).mul(recipientRate));
    }

    function swapAndAddLiquidity() lockTheSwap public {
        uint256 amount =  _balance[address(this)];
        if(amount < swapAt){
            return;
        }

        if(swapByLimitOnly){
            amount = swapAt;
        }

        uint256 usdtRewardBalance = swapTokensForCake(amount/2);
        if(usdtRewardBalance == 0){
            return;
        }

        _uniswapV2Router.addLiquidity(
            husdtTokenAddress,
            address(this),
            usdtRewardBalance,
            amount/2,
            0,
            0,
            _liquidityReciverAddress,
            block.timestamp
        );
    }

    function _baseTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balance[sender] = _balance[sender].sub(amount);
        _balance[recipient] = _balance[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 amount
    ) private {
        _balance[to] = _balance[to].add(amount);
        emit Transfer(sender, to, amount);
    }


    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        address cur;
        address receiver = address(this);
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }


        uint256 rate;
        for (int256 i = 0; i < 7; i++) {
            if(i == 0){
                rate = _inviterFather1Fee;
            }else if(i == 1){
                rate = _inviterFather2Fee;
            }else{
                rate = _inviterFather3To7Fee;
            }

            cur = inviter[cur];
            if (cur == address(0)) {
                receiver = address(this);
            }else{
                receiver = cur;
            }
            uint256 curAmount = amount.div(_denominatorOfFee).mul(rate);
            _balance[receiver] = _balance[receiver].add(curAmount);
            if(receiver==address(this)){
                continue;
            }

            emit Transfer(sender, receiver, curAmount);
        }
    }


    function _transferUsdt(address sender, uint256 Amount,uint256 currentFee) private {
        uint256 sendBalance = Amount.div(_totalFee.sub(_burnFee)).mul(currentFee);
        husdtTokenAddress.safeTransfer(sender,sendBalance);
    }

    uint256 totalMintAmount = 70000000 * 10**9;
    uint256 leftAmount = totalMintAmount;
    uint256 totalMintDays = 1000;
    uint256 blocksOfDays = 28800;
    uint256 public lastMintedBlock;
    uint256 public interval =  200;
    function mint() private{
        if(leftAmount ==0){
            return;
        }

        if(block.timestamp < startTime){
            return;
        }

        if(block.number <= lastMintedBlock + interval){
            return;
        }

        uint256 mintedAmountOfPreBlock = (totalMintAmount / totalMintDays)/ blocksOfDays;
        uint256 amount = mintedAmountOfPreBlock * (block.number - lastMintedBlock);
        if(amount > leftAmount){
            amount = leftAmount;
        }
        leftAmount -= amount;

        _takeTransfer(address(0),_lpReflectionAddress,amount*15/70);
        _takeTransfer(address(0),_nftReflectionAddress,amount*30/70);
        _takeTransfer(address(0),_nodeRewardAddress,amount*10/70);
        _takeTransfer(address(0),_genesisRewardAddress,amount*5/70);
        _takeTransfer(address(0),_tokenReflectionAddress,amount*10/70);

         lastMintedBlock = block.number;
    }


    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    function swapTokensForCake(uint256 tokenAmount) private returns(uint256){
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = husdtTokenAddress;

        // make the swap
        IERC20 UsdtToken = IERC20(husdtTokenAddress);
        uint256 beforeBalance = UsdtToken.balanceOf(address(this));
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(stc),
            block.timestamp
        );
        stc.transferToken();
        uint256 afterBalance = UsdtToken.balanceOf(address(this));
        return afterBalance.sub(beforeBalance);
    }


    function setBlack(address account, bool state) public onlyOwner {
        _blackList[account] = state;
    }
    function setExcludedFromFee(address account,bool state) public onlyOwner{
        _isExcludedFromFee[account] = state;
    }

    function setWalletAddrs(address liquidityReciver,address tokenReflectionAddress,address lpReflection,address _nftReflection,address _nodeReward,address _genesisReward) public onlyOwner{
        _liquidityReciverAddress = liquidityReciver;
        _tokenReflectionAddress = tokenReflectionAddress;
        _lpReflectionAddress = lpReflection;
        _nftReflectionAddress = _nftReflection;
        _nodeRewardAddress = _nodeReward;
        _genesisRewardAddress = _genesisReward;
    }

    function startTrade() external onlyOwner{
        startTime = block.timestamp;
        lastMintedBlock = block.number;
    }

    function setSwapConfig(uint256 _swapAt, bool _enableSwap,  bool _swapByLimitOnly) external onlyOwner{
        swapAt = _swapAt;
        enableSwap = _enableSwap;
        swapByLimitOnly = _swapByLimitOnly;
    }
}


contract StorageTokenContract is Ownable {
    using TransferHelper for address;
    address token;
    constructor(address tokenOwner,address _token) {
        _owner = tokenOwner;
        token = _token;
        _token.safeApprove(tokenOwner,~uint(0));
    }
    function transferToken() public onlyOwner {
        IERC20 tokenERC20 = IERC20(token);
        uint256 balance = tokenERC20.balanceOf(address(this));
        token.safeTransfer(_owner,balance);
    }
}