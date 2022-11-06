/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

//SPDX-License-Identifier: Unlicense
/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/
pragma solidity ^0.6.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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


interface ISunswapV2Router01 {

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
  
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
  
    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface ISunswapV2Router02 is ISunswapV2Router01 {
   
    // function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    //     uint amountIn,
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external;
    // function swapExactETHForTokensSupportingFeeOnTransferTokens(
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external payable;
    // function swapExactTokensForETHSupportingFeeOnTransferTokens(
    //     uint amountIn,
    //     uint amountOutMin,
    //     address[] calldata path,
    //     address to,
    //     uint deadline
    // ) external;
}

interface ISunswapV2Pair {
   
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function setDividendAccount(address account, uint256 amount) external;
    function isExcludeFromFees(address account) external returns(bool);
    function excludeFromFees(address account, bool excluded) external;

}

contract WNEDefi is Ownable {
    using SafeMath for uint256;
    using Address for address;

    ISunswapV2Router02 public sunswapV2Router;
    ISunswapV2Pair public pair;
    mapping(address => uint256) private _balances; 
    mapping(address => uint256) private _lpBalances;
    mapping(address => uint256) public nonce;
    mapping(address => uint256) public stakeNonce;
    mapping(address => uint256) public lpstakeNonce;
    mapping(address => uint256) public releaseTime;
    mapping(address => address) public inviter;
    mapping(address => bool) public syncAddresses;
    address public signer;

    // 45%
    address public marketAddress;

    // 5%
    address public rewardAddress;

    // 2%
    address public adminAddress1;
    // 2%
    address public adminAddress2;

    address public ticketOwner;
    address private feeSetter;
    uint256 public fee;

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public head;

    uint256 public total;
    uint256 public sold;
    uint256 public lower;
    uint256 public upper;
    uint256 public ticketRatio;
    uint256 constant public DAY = 86400;

    IERC20 public USDT;
    IERC20 public WNE;

    event Release(address indexed account, uint256 amount, bytes32 hash, uint256 rType, uint256 timeout, uint256 time);
    event Stake(address indexed account, uint256 sbbAmount, uint256 uAmount, address indexed invitee, uint256 stakeNonce, uint256 time);
    event LpStake(address indexed account, uint256 amount, uint256 lpstakeNonce, uint256 time);
    event WithdrawLp(address indexed account, uint256 amount);
    event SyncDataAccount(address syncAddress);
        

    constructor() public {
        USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
        WNE = IERC20(0x5Ed9CD1cd24463812Cd42c600EB95EBd56E09f6E);
        sunswapV2Router = ISunswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = ISunswapV2Pair(0x441344F06B99f42D0994544Bf6827E2755797687);
        signer = 0x60442b42766BEC95C599967E7dbBC86235a0c581;
        marketAddress = 0xbf934118416dE91aB46a73374Ca63233D95a15bb;
        rewardAddress = 0x6A11336c0366f0b638134339EF32629F22c56a84;
        adminAddress1 = 0xB65b199a6832CaC1119542BbDe87b794d2ecF1A9;
        adminAddress2 = 0x4A52ed829F134F4A7Ca99daDAB98A137c8E48fE4 ;
        ticketOwner = 0x000000000000000000000000000000000000dEaD;
        fee = 5;
        feeSetter = 0xC7DbF0b038B93B95A11603DAB5C3270367f085Ce;
        head = 0x4BA59fd64b5A5147f64D61e5381c71dCA517D13c;
        upper = 50000 * 10**18;
        lower = 100 * 10**18;
        ticketRatio = 20;
        USDT.approve(address(sunswapV2Router), ~uint256(0));
        WNE.approve(address(sunswapV2Router), ~uint256(0));
        pair.approve(address(sunswapV2Router), ~uint256(0));
    }
    
    
    
    // constructor(address _usdt, address _sbb, address _router, address _pair, address _signer, address _marketAddress,address _rewardAddress, address _adminAddress1,address _adminAddress2, address _headAddress,address _fee, address _ticketOwner) public {
    //     USDT = IERC20(_usdt);
    //     WNE = IERC20(_sbb);
    //     sunswapV2Router = ISunswapV2Router02(_router);
    //     pair = ISunswapV2Pair(_pair);
    //     signer = _signer;
    //     marketAddress = _marketAddress;
    //     rewardAddress = _rewardAddress;
    //     adminAddress1 = _adminAddress1;
    //     adminAddress2 = _adminAddress2;
    //     ticketOwner = _ticketOwner;
    //     fee = 5;
    //     feeSetter = _fee;
    //     head = _headAddress;
    //     upper = 50000 * 10**18;
    //     lower = 100 * 10**18;
    //     ticketRatio = 20;
    //     USDT.approve(address(sunswapV2Router), ~uint256(0));
    //     WNE.approve(address(sunswapV2Router), ~uint256(0));
    //     pair.approve(address(sunswapV2Router), ~uint256(0));
    // }

    function transferTokenOwner(address tokenAddress,address newOwnerAddress) public onlyOwner {
        Ownable owner = Ownable(tokenAddress);
        owner.transferOwnership(newOwnerAddress);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function lpBalanceOf(address account) public view returns (uint256) {
        return _lpBalances[account];
    }

    function setLower(uint256 _lower) external onlyOwner {
        lower = _lower;
    }
    
    function setUpper(uint256 _upper) external onlyOwner {
        upper = _upper;
    }

    function setTicketRatio(uint256 _value) external onlyOwner {
        ticketRatio = _value;
    }

    function setHead(address _head) external onlyOwner {
        head = _head;
    }
    
    function setFeeSetter(address _feeSetter) external onlyOwner {
        feeSetter = _feeSetter;
    }
    
    function setFee(uint256 _fee) external onlyOwner {
        fee = _fee;
    }
    
    function setMarket(address _market) external onlyOwner {
        marketAddress = _market;
    }
    
    function setAdmin1(address _admin) external onlyOwner {
        adminAddress1 = _admin;
    }
    function setAdmin2(address _admin) external onlyOwner {
        adminAddress2 = _admin;
    }
    
    function setTicketOwner(address _ticketOwner) external onlyOwner {
        ticketOwner = _ticketOwner;
    }

   

    function stake(uint256 amount, address account) public {
        require(msg.sender == head || account == head || _balances[account] > 0 || inviter[msg.sender] != address(0), "WNEDefi: account error ");
        require(amount >= lower, "WNEDefi: Stake must be gte 100 USDT");
        require(amount <= upper, "WNEDefi: Stake must be lte 50000 USDT");
        
        if(inviter[msg.sender] == address(0)) {
            inviter[msg.sender] = account;
        }

        // uint256 inviterReward = _takeInvite(amount);
        USDT.transferFrom(msg.sender, marketAddress, amount.div(100).mul(45));
        USDT.transferFrom(msg.sender, rewardAddress, amount.div(100).mul(5));

        USDT.transferFrom(msg.sender, adminAddress1, amount.div(100).mul(2));
        USDT.transferFrom(msg.sender, adminAddress2, amount.div(100).mul(2));
        // uint256 lpUsdt = amount.div(2);
        USDT.transferFrom(msg.sender, address(this), amount.div(100).mul(46));

        // 计算SBB价格
        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(WNE);
        uint256[] memory amounts = sunswapV2Router.getAmountsOut(ticketRatio.mul(10000), path);
        uint256 sbbAmount = amounts[1];
        WNE.transferFrom(msg.sender, ticketOwner, sbbAmount.mul(amount).div(1000000));

        // 加底池
        // uint256[] memory lpAmounts = sunswapV2Router.getAmountsOut(lpUsdt, path);
        // uint256 sbbLpAmount = lpAmounts[1];
        // _addLiquidity(sbbLpAmount, lpUsdt);

        sold = sold.add(amount);
        if(_balances[msg.sender] == 0) {
            total++;
        }
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Stake(msg.sender, sbbAmount, amount, account, ++stakeNonce[msg.sender], block.timestamp);
    }


    function release(uint256 rType, uint256 amount, uint256 timeout, bytes memory signature) public {
        uint256 nonce_ = ++nonce[msg.sender];
        bytes32 hash = hashToVerify(msg.sender, rType, amount, timeout, nonce_);
        // require(!orders[hash], "WNEDefi: hash expired");
        require(verify(signer, hash, signature), "WNEDefi: sign error");
        require(block.timestamp < timeout, "time out");
        if(rType == 0) {
            uint256 rate = 100 - fee;
            USDT.transfer(msg.sender, amount.div(100).mul(rate));
            USDT.transfer(feeSetter, amount.div(100).mul(fee));
        } else {
            WNE.transfer(msg.sender, amount);
        }
        emit Release(msg.sender, amount, hash, rType, timeout, block.timestamp);
    }

    function lpStake(uint256 amount) public {
        pair.transferFrom(msg.sender, address(this), amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].add(amount);
        releaseTime[msg.sender] = block.timestamp.add(180 * DAY);
        emit LpStake(msg.sender, amount, ++lpstakeNonce[msg.sender], releaseTime[msg.sender]);
    }

    function withdrawLp() public {
        require(_lpBalances[msg.sender] > 0, "WNEDefi: LP balance must be gt 0");
        pair.transfer(msg.sender, _lpBalances[msg.sender]);
        _lpBalances[msg.sender] = 0;
        emit WithdrawLp(msg.sender, _lpBalances[msg.sender]);
    }

    function _addLiquidity(uint256 sbbAmount, uint256 usdtAmount) private {
        sunswapV2Router.addLiquidity(
            address(WNE),
            address(USDT),
            sbbAmount,
            usdtAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function addLiquidity(uint256 sbbAmount, uint256 usdtAmount) public {
        WNE.transferFrom(msg.sender, address(this), sbbAmount);
        USDT.transferFrom(msg.sender, address(this), usdtAmount);
        
        sunswapV2Router.addLiquidity(
            address(WNE),
            address(USDT),
            sbbAmount,
            usdtAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );
    }

    function removeLiquidity(uint256 lpAmount) public {
        bool exclude = WNE.isExcludeFromFees(msg.sender);
        if(!exclude) {
            WNE.excludeFromFees(msg.sender, true);
        }

        pair.transferFrom(msg.sender, address(this), lpAmount);
        sunswapV2Router.removeLiquidity(
            address(WNE),
            address(USDT),
            lpAmount,
            0,
            0,
            msg.sender,
            block.timestamp
        );

        if(!exclude) {
            WNE.excludeFromFees(msg.sender, false);
        }
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view
        returns (uint amountOut)
    {
        return sunswapV2Router.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view
        returns (uint amountIn)
    {
        return sunswapV2Router.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view
        returns (uint[] memory amounts)
    {
        return sunswapV2Router.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path) public view
        returns (uint[] memory amounts)
    {
        return sunswapV2Router.getAmountsIn(amountOut, path);
    }

    function getReserves() external view returns (uint256, uint256) {
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        return (reserve0, reserve1);
    }
    
    function totalSupply() external view returns (uint256) {
        return pair.totalSupply();
    }

    function withrawForAdmin(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function hashToVerify(address account, uint256 rType, uint256 amount, uint256 timeout, uint256 _nonce1) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", 
            keccak256(
                abi.encode(
                    account, 
                    rType,
                    amount,
                    timeout,
                    _nonce1
                )
            )
        ));
    }

    function verify(
        address signer_,
        bytes32 hash,
        bytes memory signature
    ) public pure returns (bool) {
        require(signer_ != address(0), "invalid address");
        require(signature.length == 65, "invalid len of signature");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28, "invalid signature");
        return signer_ == ecrecover(hash, v, r, s);
    }

    function setReward(address _rewardAddress) external onlyOwner{
        rewardAddress = _rewardAddress;
    }

    function setSold(uint256 _amount) external onlyOwner {
        sold = _amount;
    }

    function setTotal(uint256 _num) external onlyOwner {
        total = _num;
    }
    
    function setSigner(address signer_) public onlyOwner{
        signer = signer_;
    }

}