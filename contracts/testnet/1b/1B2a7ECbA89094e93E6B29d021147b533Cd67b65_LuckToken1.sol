/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeFactory {
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

interface IPancakeRouter {
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

//This interface is for authorized wallet only, to set fees and limits!!! It is automated in Python!
interface AboutFeesAndLimits {

    //It is changed by a Python code automatically every 1-3 hours.
    function changeBuyFees(
        uint256 Marketing, 
        uint256 LP, 
        uint256 BuybackAndBurn, 
        uint256 WinnersReward, 
        uint256 JackpotReward, 
        uint256 LuckyShares, 
        uint256 NewComer, 
        uint256 House
    ) external;

    //It is changed by a Python code automatically every 1-3 hours.
    function changeSellFees(
        uint256 Marketing, 
        uint256 LP, 
        uint256 BuybackAndBurn, 
        uint256 WinnersReward, 
        uint256 JackpotReward, 
        uint256 LuckyShares, 
        uint256 NewComer, 
        uint256 QuittersPenalty,
        uint256 House
    ) external;

    //Only authorised wallet can change the receiving wallets.
    function changeFeeReceiverWallets(address Marketing, address BuybackAndBurn, address House) external;

    //Change if a wallet is exempt from paying fees. (Applies to both buy and sell)
    function changeIsFeeExempt(address holder, bool exempt) external;
	
    //Same as previous, but only sell.
	function changeIsFeeExemptSell(address holder, bool exempt) external;
	
    //Same as previous, but only buy.
	function changeIsFeeExemptBuy(address holder, bool exempt) external;


    //OPTIONALS

    //Change if a wallet is exempt from max wallet. With NFT, max wallet can be increased.
    function changeIfWalletIsMaxWalletLimitExempt(address holder, bool exempt) external;
    //Change if a wallet has max wallet fix. With NFT, max wallet can be fixed.
    function changeIfWalletIsMaxWalletLimitFixed(address holder, bool exempt) external;

    //Check if wallet has Winner's increase.
    function checkIfWinnersIncreaseIsActive(address holder, bool exempt) external;
    //Check if wallet has Loser's decrease.
    function checkIfLosersDecreaseIsActive(address holder, bool exempt) external;
    //Check if wallet has Lucky Shares increase.
    function checkIfLuckySharesIncreaseIsActive(address holder, bool exempt) external;
}

//This interface is also automated by Python, at given times the dice is rolled, and the chanche to win is open!!
interface RollTheDices {

    /*
        Every 1-3 hours 5-15% of all 0.001%+ holders are chosen to be winners,
        and 5-15% of all 0.001%+ holders are chosen to be losers (10-30% of all holders altogether).
        Winners will receive the losers’ tokens (only 5-10% of it).
        If a winner is already holding more than the actual max wallet, he is simply removed from the winner team and a new winner is selected.
        If a loser has less than 0.1%, this wallet is also removed from the loser team (other losers will NOT lose more).
        Winners also get the “winners’ reward” fee in BUSD (10% - 70%) of it. (30% will always remain on the contract, so the reward will increase overtime).
        If the roll is successfull, it should return True.
    */
    function ChooseTheWinnersAndLoosers() external returns (bool);

    /*
        The dice is rolled, and if it hits 6, jackpot will be payed out. (random number between and including 1-6). If its 1-5, reward will keep increasing, if its 6, jackpot will be sent out to the winners.
        1 to 10 wallets will receive the full amount, shared equally between them.
        If the roll is successfull, it should return True.
    */
    function RollTheJackpot() external returns (bool);

    /*
        Lucky shares are for holders that holds above the half of the actual maximum wallet amount. (If the actual maximum wallet is 1% ~ 10.000.000 tokens, then every wallet holding more than 5.000.000 tokens are eligible to this share). It is sent out every 24 hours, exactly when the jackpot is rolled.
        Lucky share limit can be divided by 2 on bscscan, so if we hit much higher market cap, we can decrease the necessary holding amount for lucky shares. (For 0.001%+ holders only)
        If the roll is successfull, it should return True.
    */
    function ChooseEligibleWalletsForLuckyShares() external returns (bool);
    //Set new limit for the eligible wallets for the lucky shares. It is given as percent of the half of the actual max wallet.
    function ChangeLuckySharesLimit() external returns (bool);

    /*
        Newcomer’s fee is for small wallets. If you come late, or can’t afford to buy big, do not be afraid. Just hold your token, and you’ll be eligible for this share. Wallets above 0.001% hold are eligible, up to the Lucky shares limit.
        Basically if you hold long term, you will change your tier from Newcomer to Lucky shares.
        If the number of Lucky share eligible wallets are less than Newcomer share eligible wallets, the half of the Newcomer share will go to the Lucky share eligible wallets!!! (If there are a lot of small wallets, it won’t pay them more than the Lucky share)
    */
    function ChooseEligibleWalletsForNewcomerShares() external returns (bool);

}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Auth {
    using SafeMath for uint256;

    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Transfer ownership to new address. Caller must be owner. Leaves old owner authorized
     */
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

abstract contract Token is Auth, IBEP20 {
    using SafeMath for uint256;

    IPancakeRouter public router;
    address public pair;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //address routerAddressForMainnet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string constant _name = "LuckToken1";
    string constant _symbol = "LUCK1";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply / 2 / 100;
    uint256 public _walletMax = _totalSupply / 2 / 100;

    uint256 public TotalFeePayed;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    mapping (address => bool) public isFeeExempt;

    uint256 public BuyFeeMarketing = 1;     // Marketing fee 1-2%
    uint256 public BuyFeeLP = 1;            // LP fee 1-2%
    uint256 public BuyFeeBB = 1;            // Buyback and burn 1-2%
    uint256 public BuyFeeWinnersReward = 1; // Winner's reward 1-4%
    uint256 public BuyFeeJackpotReward = 1; // Jackpot reward FIX 1%
    uint256 public BuyFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    uint256 public BuyFeeNewComer = 1;      // NewComer FIX 1%
    uint256 public BuyFeeHouse = 1;         // Fee of the house FIX 1%
    //Total 9-15%

    uint256 public totalBuyFee = BuyFeeMarketing.add(BuyFeeLP).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeNewComer).add(BuyFeeHouse);

    uint256 public SellFeeMarketing = 2;     // Marketing fee 2-4%
    uint256 public SellFeeLP = 2;            // LP fee 2-4%
    uint256 public SellFeeBB = 2;            // Buyback and burn 2-4%
    uint256 public SellFeeWinnersReward = 2; // Winner's reward 2-6%
    uint256 public SellFeeJackpotReward = 2; // Jackpot reward FIX 2%
    uint256 public SellFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    uint256 public SellFeeNewComer = 1;      // NewComer FIX 1%

    uint256 public QuittersPenalty = 2;      // Quitters Penalty 2-6% If someone sells more than 90% of their tokens, some extra fee is pallied to the sell! (Don't leave us if you wanna become rich)
    //This should be implemented in the trade function, it is not added to the TotalSellFee for now!!
    
    uint256 public SellFeeHouse = 1;         // Fee of the house FIX 1%
    //Total 16-30%

    uint256 public totalSellFee = SellFeeMarketing.add(SellFeeLP).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeNewComer).add(SellFeeHouse);

    


    constructor() Auth(msg.sender) {
        router = IPancakeRouter(routerAddress);
        pair = IPancakeFactory(router.factory()).createPair(router.WETH(), address(this));

        _allowances[address(this)][address(router)] = type(uint256).max;


        _balances[owner] = _totalSupply; // Transfers all tokens to owner
        TotalFeePayed = 0;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
}

//Contains basic functios from IBEP20, Auth and Token.
contract LuckToken1 is Token {
    using SafeMath for uint256;
    function totalSupply() external view override returns (uint256) { return _totalSupply; }
    function decimals() external pure override returns (uint8) { return _decimals; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function name() external pure override returns (string memory) { return _name; }
    function getOwner() external view override returns (address) { return owner; }
    function balanceOf(address account) external view override returns (uint256) { return _balances[account]; }

    

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender]; }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(amount > 0, "Value must be greater than 0");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(_balances[msg.sender] > _value, "Not enough balance");

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function TotalFeeAmount() public view returns (uint256 totalFee) {return TotalFeePayed;}

}