/**
 *Submitted for verification at BscScan.com on 2022-09-04
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

//Safemath for uint256
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

//Authentication
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

//Contains everything about the fees
abstract contract AllTheFees is Auth {
    using SafeMath for uint256;
    mapping (address => bool) public isFeeExempt;

    function changeIsFeeExempt(address holder, bool exempt) external authorized{
        isFeeExempt[holder] = exempt;
    }

    //BUY fees
    uint256 BuyFeeLP = 1;            // LP fee 1-2%
    function ActualFeeOfBuyLP() external view returns (uint256) { return BuyFeeLP; }

    uint256 BuyFeeMarketing = 1;     // Marketing fee 1-2%
    function ActualFeeOfBuyFeeMarketing() external view returns (uint256) { return BuyFeeMarketing; }

    uint256 BuyFeeBB = 1;            // Buyback and burn 1-2%
    function ActualFeeOfBuyFeeBB() external view returns (uint256) { return BuyFeeBB; }

    uint256 BuyFeeWinnersReward = 1; // Winner's reward 1-4%
    function ActualFeeOfBuyFeeWinnersReward() external view returns (uint256) { return BuyFeeWinnersReward; }

    uint256 BuyFeeJackpotReward = 1; // Jackpot reward FIX 1%
    function ActualFeeOfBuyFeeJackpotReward() external view returns (uint256) { return BuyFeeJackpotReward; }

    uint256 BuyFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    function ActualFeeOfBuyFeeLuckyShares() external view returns (uint256) { return BuyFeeLuckyShares; }

    uint256 BuyFeeNewcomerShares = 1;      // NewComer FIX 1%
    function ActualFeeOfBuyFeeNewcomerShares() external view returns (uint256) { return BuyFeeNewcomerShares; }

    uint256 BuyFeeHouse = 1;         // Fee of the house FIX 1%
    function ActualFeeOfBuyFeeHouse() external view returns (uint256) { return BuyFeeHouse; }

    uint256 totalBuyFee = BuyFeeMarketing.add(BuyFeeLP).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeNewcomerShares).add(BuyFeeHouse);
    
    //Total 9-15%

    function changeBuyFees(
        uint256 newBuyFeeLP, 
        uint256 newBuyFeeMarketing, 
        uint256 newBuyFeeBB, 
        uint256 newBuyFeeWinnersReward,
        uint256 newBuyFeeJackpotReward, 
        uint256 newBuyFeeLuckyShares, 
        uint256 newBuyFeeNewcomerShares,
        uint256 newBuyFeeHouse
        ) external authorized {
        BuyFeeLP = newBuyFeeLP;
        BuyFeeMarketing = newBuyFeeMarketing;
        BuyFeeBB = newBuyFeeBB;
        BuyFeeWinnersReward = newBuyFeeWinnersReward;
		BuyFeeJackpotReward = newBuyFeeJackpotReward;
        BuyFeeLuckyShares = newBuyFeeLuckyShares;
        BuyFeeNewcomerShares = newBuyFeeNewcomerShares;
        BuyFeeHouse = newBuyFeeHouse;
        
        totalBuyFee = BuyFeeLP.add(BuyFeeMarketing).add(BuyFeeBB).add(BuyFeeWinnersReward).add(BuyFeeJackpotReward).add(BuyFeeLuckyShares).add(BuyFeeNewcomerShares).add(BuyFeeHouse);
		require(totalBuyFee <= 15);
    }



    
    //Sell fees
    uint256 SellFeeLP = 2;            // LP fee 2-4%
    function ActualFeeOfSellFeeLP() external view returns (uint256) { return SellFeeLP; }

    uint256 SellFeeMarketing = 2;     // Marketing fee 2-4%
    function ActualFeeOfSellFeeMarketing() external view returns (uint256) { return SellFeeMarketing; }

    uint256 SellFeeBB = 2;            // Buyback and burn 2-4%
    function ActualFeeOfSellFeeBB() external view returns (uint256) { return SellFeeBB; }

    uint256 SellFeeWinnersReward = 2; // Winner's reward 2-6%
    function ActualFeeOfSellFeeWinnersReward() external view returns (uint256) { return SellFeeWinnersReward; }

    uint256 SellFeeJackpotReward = 2; // Jackpot reward FIX 2%
    function ActualFeeOfSellFeeJackpotReward() external view returns (uint256) { return SellFeeJackpotReward; }

    uint256 SellFeeLuckyShares = 2;   // Lucky Shares FIX 2%
    function ActualFeeOfSellFeeLuckyShares() external view returns (uint256) { return SellFeeLuckyShares; }

    uint256 SellFeeNewcomerShares = 1;      // NewComer FIX 1%
    function ActualFeeOfSellFeeNewcomerShares() external view returns (uint256) { return SellFeeNewcomerShares; }


    uint256 QuittersPenalty = 2;      // Quitters Penalty 2-6% If someone sells more than 90% of their tokens, some extra fee is applied to the sell! (Don't leave us if you wanna become rich)
    function ActualFeeOfQuittersPenalty() external view returns (uint256) { return QuittersPenalty; }

    //This should be implemented in the trade function, it is not added to the TotalSellFee for now!!
    
    uint256 SellFeeHouse = 1;         // Fee of the house FIX 1%
    function ActualFeeOfSellFeeHouse() external view returns (uint256) { return SellFeeHouse; }

    uint256 totalSellFee = SellFeeMarketing.add(SellFeeLP).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeNewcomerShares).add(SellFeeHouse);

    //Total 16-30%

    
    function changeSellFees(
        uint256 newSellFeeLP, 
        uint256 newSellFeeMarketing, 
        uint256 newSellFeeBB, 
        uint256 newSellFeeWinnersReward,
        uint256 newSellFeeJackpotReward, 
        uint256 newSellFeeLuckyShares, 
        uint256 newSellFeeNewcomerShares,
        uint256 newQuittersPenalty,
        uint256 newSellFeeHouse
        ) external authorized {
        SellFeeLP = newSellFeeLP;
        SellFeeMarketing = newSellFeeMarketing;
        SellFeeBB = newSellFeeBB;
        SellFeeWinnersReward = newSellFeeWinnersReward;
		SellFeeJackpotReward = newSellFeeJackpotReward;
        SellFeeLuckyShares = newSellFeeLuckyShares;
        SellFeeNewcomerShares = newSellFeeNewcomerShares;
        QuittersPenalty = newQuittersPenalty;
        SellFeeHouse = newSellFeeHouse;
        
        totalSellFee = SellFeeLP.add(SellFeeMarketing).add(SellFeeBB).add(SellFeeWinnersReward).add(SellFeeJackpotReward).add(SellFeeLuckyShares).add(SellFeeNewcomerShares).add(QuittersPenalty).add(SellFeeHouse);
		require(totalSellFee <= 30);
    }

	uint256 unSwappedBuyFee = 0;
	uint256 unSwappedSellFee = 0;

    constructor(){
        isFeeExempt[msg.sender] = true;
        isFeeExempt[address(this)] = true;
    }

    function ActualFeeOfBuy() external view returns (uint256) { return totalBuyFee; }
    function ActualFeeOfSell() external view returns (uint256) { return totalSellFee; }
}

//Contains the basic stuff about the contract
abstract contract Token is Auth, IBEP20, AllTheFees {
    using SafeMath for uint256;

    IPancakeRouter public router;
    address public pair;
    address routerAddress = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    //address routerAddressForMainnet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address marketingwallet = 0x0000000000000000000000000000000000000000; //Wallet of marketing fee
    address burnandbuybackwallet = 0x0000000000000000000000000000000000000000; //Wallet of burn and buyback fee
    address housewallet = 0x0000000000000000000000000000000000000000; //Wallet of development fee
	address public autoLiquidityReceiver;
	

    function changeFeeReceiverWallets(address Marketing, address BuybackAndBurn, address House) external authorized {
        marketingwallet = Marketing;
        burnandbuybackwallet = BuybackAndBurn;
        housewallet = House;
    }

    string constant _name = "LuckToken1";
    string constant _symbol = "LUCK1";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 1000000000 * (10 ** _decimals);
    uint256 public _maxTxAmount = _totalSupply / 2 / 100;
    uint256 public _walletMax = _totalSupply / 2 / 100;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

	bool addLPstatus;

    constructor() Auth(msg.sender) {
		addLPstatus = true;
        router = IPancakeRouter(routerAddress);
        pair = IPancakeFactory(router.factory()).createPair(router.WETH(), address(this));
		autoLiquidityReceiver = msg.sender;

        _allowances[address(this)][address(router)] = type(uint256).max;

        _balances[owner] = _totalSupply; // Transfers all tokens to owner
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    receive() external payable { }
}

//Contains basic functios from IBEP20, Auth and Token.
contract LuckToken1 is Token {
    using SafeMath for uint256;
	
	bool public swapTokensAndLiquifyEnabled = true;
	uint256 public swapThreshold = _totalSupply / 200; //If contract has 5m+ tokens, swap them
	
	
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

    function transfer(address _to, uint256 _value) external override returns (bool success) {
	
		if(msg.sender == pair){
			return _transferFrom(msg.sender, _to, _value);
		}

        require(_to != address(0), "Receiver address invalid");
        require(_value >= 0, "Value must be greater or equal to 0");
        require(_balances[msg.sender] > _value, "Not enough balance");

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        
        if(_allowances[sender][msg.sender] != type(uint256).max){
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount, "Insufficient Allowance");
        }

        return _transferFrom(sender, recipient, amount);
    }
	
    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
	
		//Swapping tokens on contract to BNB / BUSD / whatever
		if(msg.sender != pair && swapTokensAndLiquifyEnabled && _balances[address(this)] >= swapThreshold){ swapTokens(); }
	
	
		_balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
		
		bool exemptbuysell = false;
		if(pair == sender && isFeeExempt[recipient] ) { exemptbuysell = true; }
		if(pair == recipient && isFeeExempt[sender] ) { exemptbuysell = true; }
		
		uint256 finalAmount = !exemptbuysell ? takeFee(sender, recipient, amount) : amount;
		
        _balances[recipient] = _balances[recipient].add(finalAmount);
        emit Transfer(sender, recipient, finalAmount);
        return true;
    }
	
	function changeSwapBackSettings(bool enableSwapBack, uint256 newSwapBackLimit) external authorized {
        swapTokensAndLiquifyEnabled  = enableSwapBack;
        swapThreshold = newSwapBackLimit;
    }
	
	
	function calculatingLP(uint256 contractHoldings) internal returns (uint256) {
		uint256 totalTokensTheContractHoldsBeforeSwap = contractHoldings;
		
		uint256 TokensToLpInPercentage = 0;
		TokensToLpInPercentage += BuyFeeLP.div(totalBuyFee);
		TokensToLpInPercentage += SellFeeLP.div(totalSellFee);
		TokensToLpInPercentage = TokensToLpInPercentage.div(2);
		uint256 TokensToLp = totalTokensTheContractHoldsBeforeSwap.mul(TokensToLpInPercentage);
		
		uint256 amountToLiquify = TokensToLp.div(2);
		uint256 amountToSwap = totalTokensTheContractHoldsBeforeSwap.sub(amountToLiquify);
		
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );
	
		uint256 amountBNB = address(this).balance;
		
		uint256 percentageOfTokens = amountToSwap.mul(100).div(totalTokensTheContractHoldsBeforeSwap);
		uint256 amountofBNBtoCalculate = amountBNB.mul(100).div(percentageOfTokens);
		
		uint256 percentageOfLP = amountToLiquify.div(amountToSwap);
		uint256 amountBNBToLP = percentageOfLP.mul(amountBNB).div(100);
		
		if(TokensToLp > 0){
            router.addLiquidityETH{value: amountBNBToLP}(
                address(this),
                TokensToLp,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBToLP, TokensToLp);
        }
		
		return amountofBNBtoCalculate;
	}
	
    struct Fees {
        uint256 TokensToMarketingInPercentage;
        uint256 TokensToBBInPercentage;
		uint256 TokensToWinnersRewardInPercentage;
		uint256 TokensToJackpotRewardInPercentage;
		uint256 TokensToLuckySharesInPercentage;
		uint256 TokensToNewcomerSharesInPercentage;
		uint256 TokensToHouseInPercentage;
    }
	
	function calculatingMoreFees(uint256 amountofBNBtoCalculate) internal returns (bool success){
		
		uint256 BNBToCalculateWith = amountofBNBtoCalculate;
        BNBToCalculateWith = 0;
		
        Fees memory fees;
        fees.TokensToMarketingInPercentage = 0;
		fees.TokensToMarketingInPercentage.add(BuyFeeMarketing.div(totalBuyFee));
		fees.TokensToMarketingInPercentage.add(SellFeeMarketing.div(totalSellFee));
		fees.TokensToMarketingInPercentage.div(2);
		
		fees.TokensToBBInPercentage = 0;
		fees.TokensToBBInPercentage.add(BuyFeeBB.div(totalBuyFee));
		fees.TokensToBBInPercentage.add(SellFeeBB.div(totalSellFee));
		fees.TokensToBBInPercentage.div(2);
		
		fees.TokensToWinnersRewardInPercentage = 0;
		fees.TokensToWinnersRewardInPercentage.add(BuyFeeWinnersReward.div(totalBuyFee));
		fees.TokensToWinnersRewardInPercentage.add(SellFeeWinnersReward.div(totalSellFee));
		fees.TokensToWinnersRewardInPercentage.div(2);
		
		fees.TokensToJackpotRewardInPercentage = 0;
		fees.TokensToJackpotRewardInPercentage.add(BuyFeeJackpotReward.div(totalBuyFee));
		fees.TokensToJackpotRewardInPercentage.add(SellFeeJackpotReward.div(totalSellFee));
		fees.TokensToJackpotRewardInPercentage.div(2);
		
		fees.TokensToLuckySharesInPercentage = 0;
		fees.TokensToLuckySharesInPercentage.add(BuyFeeLuckyShares.div(totalBuyFee));
		fees.TokensToLuckySharesInPercentage.add(SellFeeLuckyShares.div(totalSellFee));
		fees.TokensToLuckySharesInPercentage.div(2);
		
		fees.TokensToNewcomerSharesInPercentage = 0;
		fees.TokensToNewcomerSharesInPercentage.add(BuyFeeNewcomerShares.div(totalBuyFee));
		fees.TokensToNewcomerSharesInPercentage.add(SellFeeNewcomerShares.div(totalSellFee));
		fees.TokensToNewcomerSharesInPercentage.div(2);
		
		fees.TokensToHouseInPercentage = 0;
		fees.TokensToHouseInPercentage.add(BuyFeeHouse.div(totalBuyFee));
		fees.TokensToHouseInPercentage.add(SellFeeHouse.div(totalSellFee));
		fees.TokensToHouseInPercentage.div(2);
		
		uint256 amountBNBToMarketing = amountofBNBtoCalculate.mul(fees.TokensToMarketingInPercentage);
		uint256 amountBNBToBB = amountofBNBtoCalculate.mul(fees.TokensToBBInPercentage);
		uint256 amountBNBToHouse = amountofBNBtoCalculate.mul(fees.TokensToHouseInPercentage);
		
		//uint256 amountBNBToLuckyShares = amountofBNBtoCalculate.mul(fees.TokensToLuckySharesInPercentage);
		//uint256 amountBNBToNewcomerShares = amountofBNBtoCalculate.mul(fees.TokensToNewcomerSharesInPercentage);
		
		//uint256 amountBNBToWinnersReward = amountofBNBtoCalculate.mul(fees.TokensToWinnersRewardInPercentage);
		//uint256 amountBNBToJackpotReward = amountofBNBtoCalculate.mul(fees.TokensToJackpotRewardInPercentage);
		
		(bool tmpSuccess,) = payable(marketingwallet).call{value: amountBNBToMarketing, gas: 30000}("");
		(bool tmpSuccess1,) = payable(burnandbuybackwallet).call{value: amountBNBToBB, gas: 30000}("");
		(bool tmpSuccess2,) = payable(housewallet).call{value: amountBNBToHouse, gas: 30000}("");
		//only to supress warning msg
        tmpSuccess = false;
        tmpSuccess1 = false;
		tmpSuccess2 = false;
        return true;
	}
	
	function swapTokens() internal {
		uint256 totalTokensTheContractHolds = _balances[address(this)];
		uint256 amountofBNBtoCalculate = calculatingLP(totalTokensTheContractHolds);
		calculatingMoreFees(amountofBNBtoCalculate);
	}

	event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
	
	function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        uint256 buyorsell = pair == recipient ? totalSellFee : totalBuyFee;
		uint256 taxToPay = amount.mul(buyorsell).div(100);
		
		_balances[address(this)] = _balances[address(this)].add(taxToPay);
		emit Transfer(sender, address(this), taxToPay);
		return amount.sub(taxToPay);
    }

	function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
}