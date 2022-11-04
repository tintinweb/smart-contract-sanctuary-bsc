/**
 *Submitted for verification at BscScan.com on 2022-11-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

pragma solidity ^0.7.0;

// SPDX-License-Identifier: Unlicensed

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
	function onTransferReceived(address operator, address from, uint256 value, bytes calldata data) external returns (bytes4);
}

interface RouterInterface {
	function WETH() external view returns (address);
    function factory() external view returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
	function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
}

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
}

interface FactoryInterface {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract BUSDManager {
	address mainC;
	ERC20Interface BUSD;

	constructor(ERC20Interface _busd) {
		mainC = msg.sender;
		BUSD = _busd;
	}
	
	function transfer(address to, uint256 tokens) public {
		require(msg.sender == mainC);
		BUSD.transfer(to, tokens);
	}
	
	function transferAll(address to) public {
		require(msg.sender == mainC);
		BUSD.transfer(to, BUSD.balanceOf(address(this)));
	}
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);
	event OwnershipRenounced();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
	
	function _chainId() internal pure returns (uint256) {
		uint256 id;
		assembly {
			id := chainid()
		}
		return id;
	}
	
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
	
	function renounceOwnership() public onlyOwner {
		owner = address(0);
		newOwner = address(0);
		emit OwnershipRenounced();
	}
}

contract FamilyToken is Owned {
	using SafeMath for uint256;
	
	struct TransferOut {
		uint256 amount;
		uint256 timestamp;
		uint256 balanceBefore;
	}
	
	struct Account {
		uint256 balance;
		mapping (address => uint256) allowances;
		uint256 staked;
		uint256 lastClaim;
        bool whitelisted;
        bool excluded;
		bool allowedToStake;
		TransferOut[] sent;
	}
	
	ERC20Interface public BUSD;
	
	mapping (address => Account) public accounts;
	mapping (address => bool) public whitelisters;
	address[] activeAccounts;
	
	uint256 public totalSupply;
	uint8 public decimals;
	string public name;
	string public symbol;
	
	address public marketingAddress;
	address public donationAddress;
	address public arbitrationAddress;
	
	bool public stakingEnabled;
	
	uint256 public buyFeeLp = 100;
	uint256 public buyFeeDonation = 100;
	uint256 public buyFeeMarketing = 100;
	uint256 public buyFeeBurn = 0;
	uint256 public buyFeeArbitration = 0;
	
	uint256 public sellFeeLp = 100;
	uint256 public sellFeeBurn = 300;
	uint256 public sellFeeDonation = 25;
	uint256 public sellFeeMarketing = 25;
	uint256 public sellFeeArbitration = 150;
	
	uint256 public penaltyFeeLP = 500;
	uint256 public penaltyFeeBurn = 1500;
	uint256 public penaltyFeeDonation = 500;
	uint256 public penaltyFeeMarketing = 500;
	uint256 public penaltyFeeArbitration = 1000;
	
	
	uint256 public antiWhaleThreshold = 2;
	
    address deployer;

	BUSDManager busdManager;

	uint256 initialSupply;
	bool lock;
	
	RouterInterface public router;
	address public pair;
	bool routerDefined;
	bool public initialized;
	
	uint256 toSwap;
	uint256 liquifiable;
	
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Whitelisted(address indexed acct);
	event Unwhitelisted(address indexed acct);
	event Excluded(address indexed acct);
	event Unexcluded(address indexed acct);
	event MarketingAddressChanged(address indexed oldAddress, address indexed newAddress);
	event DonationAddressChanged(address indexed oldAddress, address indexed newAddress);
	event ArbitrationAddressChanged(address indexed oldAddress, address indexed newAddress);
	
	event LpTaxChanged(uint256 indexed buyTax, uint256 indexed sellTax, uint256 indexed penaltyTax);
	event DonationTaxChanged(uint256 indexed buyTax, uint256 indexed sellTax, uint256 indexed penaltyTax);
	event MarketingTaxChanged(uint256 indexed buyTax, uint256 indexed sellTax, uint256 indexed penaltyTax);
	event BurnTaxChanged(uint256 indexed buyTax, uint256 indexed sellTax, uint256 indexed penaltyTax);
	event ArbitrationTaxChanged(uint256 indexed buyTax, uint256 indexed sellTax, uint256 indexed penaltyTax);

	event AntiwhaleThresholdChanged(uint256 indexed newThreshold);
	
	event AllowedToStake(address indexed user);
	event DisallowedToStake(address indexed user);
	
	modifier onlyWhitelister {
		require((msg.sender == owner) || (whitelisters[msg.sender]), "UNAUTHORIZED"); // allows either owner or an approved whitelisters
		_;
	}
	
	constructor(string memory _name, string memory _symbol, uint256 _supply, uint8 _decimals, address _marketingAddress, address _donationAddress, address _arbitrationAddress) {
		bool _testnet = (getChainID() == 97); // 97 is BSC testnet chainid, 56 is mainnet one
		address _routerAddress = (_testnet ? 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 : 0x10ED43C718714eb63d5aA57B78B54704E256024E);
		address busd = (_testnet ? 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee : 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
		marketingAddress = _marketingAddress;
		donationAddress = _donationAddress;
		arbitrationAddress = _arbitrationAddress;
        deployer = msg.sender;
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _supply;
		initialSupply = _supply;
		accounts[msg.sender].balance = _supply;
		
		accounts[address(this)].whitelisted = true;
		accounts[address(this)].excluded = true;
		
		accounts[marketingAddress].whitelisted = true;
		accounts[marketingAddress].excluded = true;
		
		accounts[msg.sender].whitelisted = true;
		accounts[msg.sender].excluded = true;
		
		BUSD = ERC20Interface(busd);
		busdManager = new BUSDManager(BUSD);
		if (_routerAddress != address(0)) {
			RouterInterface _router = RouterInterface(_routerAddress);
			router = _router;
			pair = FactoryInterface(_router.factory()).createPair(address(this), busd);
			accounts[pair].excluded = true;
			routerDefined = true;
		}
		
		emit Transfer(address(0), msg.sender, _supply);
	}
	
	function getChainID() public pure returns (uint256) {
		uint256 id;
		assembly {
			id := chainid()
		}
		return id;
	}

	
	// function init(uint256 BUSDAmount, uint256 tokenAmount) public payable {
		// require(!initialized, "ALREADY_INITIALIZED");
        // require(msg.sender == deployer, "Deployer: wth is going on here ?");
		// initialized = true;
		// if (routerDefined) {
			// lock = true;
			// BUSD.transferFrom(msg.sender, address(this), BUSDAmount);
			// _transfer(msg.sender, address(this), tokenAmount);
			// addLiquidity(balanceOf(address(this)), BUSDAmount);
			// lock = false;
		// }
	// }
	
	function balanceOf(address addr) public view returns (uint256) {
		return accounts[addr].balance;
	}
	
	function stakedOf(address addr) public view returns (uint256) {
		return accounts[addr].staked.add(pendingRewards(addr));
	}
	
	function allowance(address tokenOwner, address spender) public view returns (uint256) {
		return accounts[tokenOwner].allowances[spender];
	}
	
	function limitUsed(address addr) public view returns (uint256 maxAmt, uint256 total) {
		TransferOut[] memory sent = accounts[addr].sent;
		uint256 minTime = block.timestamp.sub(86400);
		TransferOut memory _tx;
		for (uint256 n = (sent.length); n > 0; n--) {
			_tx = sent[n-1];
			if (_tx.timestamp > minTime) {
				total += _tx.amount;
				maxAmt = _tx.balanceBefore.div(10);
			} else {
				break;
			}
		}
		if (maxAmt == 0) {
			maxAmt = balanceOf(addr).div(10);
		}
	}
	
	function swapForBNB(uint256 tokenAmt) private {
        accounts[address(this)].allowances[address(router)] = uint256(tokenAmt);
		address[] memory path = new address[](3);
		path[0] = address(this);
		path[1] = address(BUSD);
		path[2] = router.WETH();
		router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmt, 0, path, address(this), block.timestamp);
	}
	
	function swapForBUSD(uint256 tokenAmt, address recipient) private returns (uint256) {
		uint256 balanceBefore = BUSD.balanceOf(address(this));
//		uint256 tokenAmt = (_tokenAmt <= balanceOf(address(this))) ? _tokenAmt : balanceOf(address(this));
        accounts[address(this)].allowances[address(router)] = uint256(tokenAmt);
		address[] memory path = new address[](2);
		path[0] = address(this);
		path[1] = address(BUSD);
		if (recipient == address(this)) {
			router.swapExactTokensForTokens(tokenAmt, 0, path, address(busdManager), block.timestamp);
			busdManager.transferAll(address(this));
		} else {
			router.swapExactTokensForTokens(tokenAmt, 0, path, recipient, block.timestamp);
		}
		return BUSD.balanceOf(address(this)).sub(balanceBefore);
	}
	
	function addLiquidity(uint256 tokenAmt, uint256 BUSDAmt) private {
		uint256 _toApprove = uint256(2**256-1);
        accounts[address(this)].allowances[address(router)] = _toApprove;
		BUSD.approve(address(router), _toApprove);
		router.addLiquidity(address(BUSD), address(this), BUSDAmt, tokenAmt, 0, 0, address(this), block.timestamp);
	}
	
	function liquify(uint256 tokens) private {
		liquifiable = liquifiable.add(tokens);
		if (canSwap()) {
			uint256 half = liquifiable.div(2);
			uint256 otherHalf = liquifiable.sub(half);
			uint256 busdAmount = swapForBUSD(half, address(this));
			addLiquidity(otherHalf, busdAmount);
			liquifiable = 0;
		}
	}

	function getBurnFee(uint256 tokens, uint8 caseType) public view returns (uint256) {
		if (caseType == 2) {
			return tokens.mul(penaltyFeeBurn).div(10000);
		} else if (caseType == 1) {		
			return tokens.mul(sellFeeBurn).div(10000);
		} else {
			return tokens.mul(buyFeeBurn).div(10000);
		}
	}
	
	function getDonationFee(uint256 tokens, uint8 caseType) public view returns (uint256) {
		if (caseType == 2) {
			return tokens.mul(penaltyFeeDonation).div(10000);
		} else if (caseType == 1) {		
			return tokens.mul(sellFeeDonation).div(10000);
		} else {
			return tokens.mul(buyFeeDonation).div(10000);
		}
	}

	function getLiquidityFee(uint256 tokens, uint8 caseType) public view returns (uint256) {
		if (caseType == 2) {
			return tokens.mul(penaltyFeeLP).div(10000);
		} else if (caseType == 1) {		
			return tokens.mul(sellFeeLp).div(10000);
		} else {
			return tokens.mul(buyFeeLp).div(10000);
		}
	}

	function getArbitrationFee(uint256 tokens, uint8 caseType) public view returns (uint256) {
		if (caseType == 2) {
			return tokens.mul(penaltyFeeArbitration).div(10000);
		} else if (caseType == 1) {		
			return tokens.mul(sellFeeArbitration).div(10000);
		} else {
			return tokens.mul(buyFeeArbitration).div(10000);
		}
	}

	function getMarketingFee(uint256 tokens, uint8 caseType) public view returns (uint256) {
		if (caseType == 2) {
			return tokens.mul(penaltyFeeMarketing).div(10000);
		} else if (caseType == 1) {
			return tokens.mul(sellFeeMarketing).div(10000);
		} else {
			return tokens.mul(buyFeeMarketing).div(10000);
		}
	}
	
	function pendingRewards(address user) public view returns (uint256) {
		Account storage acct = accounts[user];
		uint256 deltaT = block.timestamp.sub(acct.lastClaim); // time elapsed since last claim
		return acct.staked.mul(4).mul(deltaT).div(3153600000); // 4% per year, multiplied by delta T, divided by total seconds in a year (so we get rewards per second)
	}
	
	function _compound(address user) private {
		Account storage acct = accounts[user];
		uint256 _rewards = pendingRewards(user);
		acct.lastClaim = block.timestamp;
		if (_rewards > 0) {
			acct.staked = acct.staked.add(_rewards);
			accounts[address(this)].balance = accounts[address(this)].balance.add(_rewards);
			totalSupply = totalSupply.add(_rewards);
			emit Transfer(address(0), address(this), _rewards);
		}
	}
	
	function compound() public {
		_compound(msg.sender);
	}
	
	function claim() public {
		Account storage acct = accounts[msg.sender];
		uint256 _rewards = pendingRewards(msg.sender);
		acct.lastClaim = block.timestamp;
		acct.balance = acct.balance.add(_rewards);
		totalSupply = totalSupply.add(_rewards);
		emit Transfer(address(0), msg.sender, _rewards);
	}
	
	function stake(uint256 tokens) public {
		require(stakingEnabled, "Staking not yet enabled");
		_compound(msg.sender);
		Account storage acct = accounts[msg.sender];
		require(acct.allowedToStake, "NOT_ALLOWED_TO_STAKE");
		
		acct.balance = acct.balance.sub(tokens, "INSUFFICIENT_BALANCE");
		accounts[address(this)].balance = accounts[address(this)].balance.add(tokens);
		acct.staked = acct.staked.add(tokens);
		
		emit Transfer(msg.sender, address(this), tokens);
	}
	
	function unstake(uint256 tokens) public {
		require(stakingEnabled, "Staking not yet enabled");
		_compound(msg.sender);
		Account storage acct = accounts[msg.sender];
		
		accounts[address(this)].balance = accounts[address(this)].balance.sub(tokens);
		acct.staked = acct.staked.sub(tokens, "INSUFFICIENT_STAKED");
		acct.balance = acct.balance.add(tokens);
		
		emit Transfer(address(this), msg.sender, tokens);
	}
	
	function canSwap() private view returns (bool) {
		return (msg.sender != pair);
	}
	
	function _distributeBUSD(uint256 LPAmt, uint256 marketingAmt, uint256 donationAmt, uint256 arbitrationAmt) private {
		if (routerDefined) {
			lock = true;
			liquify(LPAmt);
			toSwap = toSwap.add(marketingAmt.add(donationAmt).add(arbitrationAmt));
			if (canSwap()) {
				uint256 obtainedBUSD = swapForBUSD(toSwap, address(busdManager));
				busdManager.transfer(marketingAddress, obtainedBUSD.mul(marketingAmt).div(toSwap));
				busdManager.transfer(donationAddress, obtainedBUSD.mul(donationAmt).div(toSwap));
				busdManager.transfer(arbitrationAddress, obtainedBUSD.mul(arbitrationAmt).div(toSwap));
				toSwap = 0;
			}
			// swapForBUSD(marketingAmt, marketingAddress);
			// swapForBUSD(donationAmt, donationAddress);
			// swapForBUSD(arbitrationAmt, arbitrationAddress);
			lock = false;
		}
	}
	
	function _transfer(address from, address to, uint256 tokens) private returns (bool) {
		// require(initialized, "WAIT_FOR_INIT");
		Account storage acctFrom = accounts[from];
		Account storage acctTo = accounts[to];
		
		_compound(from);
		_compound(to);
		
		acctFrom.sent.push(TransferOut({amount: tokens, timestamp: block.timestamp, balanceBefore: acctFrom.balance}));
		
		acctFrom.balance = acctFrom.balance.sub(tokens, "INSUFFICIENT_BALANCE"); // removes them from sender balances
		require((((acctTo.balance + tokens) < totalSupply.mul(antiWhaleThreshold).div(100)) || acctTo.excluded), "BLOCKED_BY_ANTIWHALE");
		bool _lock = (lock || (acctFrom.whitelisted) || (acctTo.whitelisted));
		
		uint256 totalFees;
		uint256 toBurn;
		if (!(_lock)) {
			(uint256 maxAmt, uint256 totalSpent) = limitUsed(from);
			uint8 caseType = ((from == address(pair)) ? 0 : (((totalSpent + tokens) > maxAmt) ? 2 : 1));
			
			toBurn = getBurnFee(tokens, caseType);
			uint256 toMarketing = getMarketingFee(tokens, caseType);
			uint256 toDonation = getDonationFee(tokens, caseType);
			uint256 toLP = getLiquidityFee(tokens, caseType);
			uint256 toArbitration = getArbitrationFee(tokens, caseType);

			totalFees = toLP.add(toDonation).add(toMarketing).add(toArbitration);

			if (totalFees > 0) {
				accounts[address(this)].balance = accounts[address(this)].balance.add(totalFees);
			}
			if (toBurn > 0) {
				totalSupply = totalSupply.sub(toBurn);
			}
			_distributeBUSD(toLP, toMarketing, toDonation, toArbitration);
		}
		
		uint256 toRecipient = tokens.sub(totalFees).sub(toBurn);
		acctTo.balance = acctTo.balance.add(toRecipient);
		// accounts[marketingAddress].balance = accounts[marketingAddress].balance.add(toMarketing);
		
		emit Transfer(from, address(this), totalFees);
		emit Transfer(from, address(0), toBurn);
		emit Transfer(from, to, toRecipient);
        return true;
	}
	
	function transfer(address to, uint256 tokens) public returns (bool) {
		_transfer(msg.sender, to, tokens);
		return true;
	}
	
	function transferFrom(address from, address to, uint256 tokens) public returns (bool) {
		accounts[from].allowances[msg.sender] = accounts[from].allowances[msg.sender].sub(tokens, "INSUFFICIENT_ALLOWANCE");
		_transfer(from, to, tokens);
		return true;
	}
	
	function approve(address spender, uint256 tokens) public returns (bool) {
		accounts[msg.sender].allowances[spender] = accounts[msg.sender].allowances[spender].add(tokens);
		return true;
	}
	
    function approveAndCall(address spender, uint256 tokens, bytes memory data) public returns (bool success) {
		approve(spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
		return true;
    }
	
	function changeMarketingAddress(address newAddr) public onlyOwner {
		emit MarketingAddressChanged(marketingAddress, newAddr);
		marketingAddress = newAddr;
	}
	
	function changeDonationAddress(address newAddr) public onlyOwner {
		emit DonationAddressChanged(donationAddress, newAddr);
		donationAddress = newAddr;
	}

	function changeArbitrationAddress(address newAddr) public onlyOwner {
		emit ArbitrationAddressChanged(arbitrationAddress, newAddr);
		arbitrationAddress = newAddr;
	}

	function whitelistWallet(address addr) public onlyWhitelister {
		accounts[addr].whitelisted = true;
		emit Whitelisted(addr);
	}
	
	function unWhitelistWallet(address addr) public onlyWhitelister {
		accounts[addr].whitelisted = false;
		emit Unwhitelisted(addr);
	}
	
	function excludeWhale(address addr) public onlyOwner {
		accounts[addr].excluded = true;
		emit Excluded(addr);
	}
	
	function unexcludeWhale(address addr) public onlyOwner {
		accounts[addr].excluded = false;
		emit Unexcluded(addr);
	}
	
	function transferAnyERC20Token(address token, uint256 tokens) public onlyOwner {
		ERC20Interface(token).transfer(owner, tokens);
	}
	
	function setLPTax(uint256 buy, uint256 sell, uint256 penalty) public onlyOwner {
		buyFeeLp = buy;
		sellFeeLp = sell;
		penaltyFeeLP = penalty;
		emit LpTaxChanged(buyFeeLp, sellFeeLp, penaltyFeeLP);
	}

	function setMarketingTax(uint256 buy, uint256 sell, uint256 penalty) public onlyOwner {
		buyFeeMarketing = buy;
		sellFeeMarketing = sell;
		penaltyFeeMarketing = penalty;
		emit MarketingTaxChanged(buyFeeMarketing, sellFeeMarketing, penaltyFeeMarketing);
	}
	
	function setDonationTax(uint256 buy, uint256 sell, uint256 penalty) public onlyOwner {
		buyFeeDonation = buy;
		sellFeeDonation = sell;
		penaltyFeeDonation = penalty;
		emit DonationTaxChanged(buyFeeDonation, sellFeeDonation, penaltyFeeDonation);
	}
	
	function setBurnTax(uint256 buy, uint256 sell, uint256 penalty) public onlyOwner {
		buyFeeBurn = buy;
		sellFeeBurn = sell;
		penaltyFeeBurn = penalty;
		emit BurnTaxChanged(buyFeeBurn, sellFeeBurn, penaltyFeeBurn);
	}
	
	function setArbitrationTax(uint256 buy, uint256 sell, uint256 penalty) public onlyOwner {
		buyFeeArbitration = buy;
		sellFeeArbitration = sell;
		penaltyFeeArbitration = penalty;
		emit ArbitrationTaxChanged(buyFeeArbitration, sellFeeArbitration, penaltyFeeArbitration);
	}
	
	function setAntiwhaleThreshold(uint256 percent) public onlyOwner {
		antiWhaleThreshold = percent;
		emit AntiwhaleThresholdChanged(percent);
	}
	
	function enableStaking() public onlyOwner {
		stakingEnabled = true;
	}
	
	function allowStaking(address user) public onlyOwner {
		accounts[user].allowedToStake = true;
		emit AllowedToStake(user);
	}
	
	function disallowStaking(address user) public onlyOwner {
		accounts[user].allowedToStake = false;
		emit DisallowedToStake(user);
	}
	
	function setWhitelisterStatus(address addr, bool _status) public onlyOwner {
		whitelisters[addr] = _status;
	}
	
	receive() external payable {}
}