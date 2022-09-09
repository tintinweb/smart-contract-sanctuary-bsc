/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

pragma solidity 0.5.8;

/**
 *
 * https://moonshots.farm
 * 
 * Want to own the next 1000x SHIB/DOGE/HEX token? Farm a new/trending moonshot every other day, automagically!
 *
 */

contract CakeKeyVault {
    using SafeMath for uint256;
    
    Keys public keys = Keys(0x0);
    FarmFomo public fomo = FarmFomo(0x0);

    ERC20 constant cake = ERC20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    ERC20 constant bones = ERC20(0x08426874d46f90e5E527604fA5E3e30486770Eb3);
    ERC20 constant wbnb = ERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    SyrupPool public cakePool = SyrupPool(0x8cBCf2f2be93D154be5135f465369Ee6dD84314B);
    UniswapV2 constant cakeV2 = UniswapV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    BonesStaking public bonesStaking = BonesStaking(0x57D3Ac2c209D9De02A80700C1D1C2cA4BC029b04);
    
    mapping(address => uint256) public shares;
    mapping(address => address) public referrers;
    mapping(address => mapping(address => uint256)) public refRewards;

    uint256 public totalShares;
	uint256 public pricePerShare = 10 ** 18;
	uint256 constant internal magnitude = 2 ** 64;
    
    mapping(address => mapping(address => int256)) public keysPayoutsTo;
    mapping(address => uint256) public keysProfitPerShare;
    
    uint256 public keysPerEpoch;
    uint256 public payoutEndTime;
    uint256 public lastDripTime;

    address blobby = msg.sender;
    address public yieldToken;
    address public pendingPool;
    uint256 public timelock;

    uint256 public pendingFeesAlloc;
	uint256 public cashoutTax = 20; // 0.2% withdraw fee to prevent abuse

    constructor() public {
        wbnb.approve(address(bonesStaking), 2 ** 255);
        wbnb.approve(address(cakeV2), 2 ** 255);
        cake.approve(address(cakePool), 2 ** 255);
    }
    
    function() payable external { /* Payable */ }

    function deposit(uint256 amount, address referrer) external {
        address farmer = msg.sender;
        require(farmer == tx.origin);
        require(cake.transferFrom(address(farmer), address(this), amount));
        dripKeys();

		cakePool.deposit(amount);

		uint256 sharesGained = (amount * (10 ** 18)) / pricePerShare;
		totalShares += sharesGained;
        shares[farmer] += sharesGained;
        keysPayoutsTo[address(keys)][farmer] += (int256) (keysProfitPerShare[address(keys)] * sharesGained);

        if (referrers[farmer] == address(0) && referrer != farmer) { 
            referrers[farmer] = referrer;
        }
    }

    function claimYield() public {
        address farmer = msg.sender;
        dripKeys();
        
        uint256 keysDividends = (uint256) ((int256)(keysProfitPerShare[address(keys)] * shares[farmer]) - keysPayoutsTo[address(keys)][farmer]) / magnitude;
        if (keysDividends > 0) {
            keysPayoutsTo[address(keys)][farmer] += (int256) (keysDividends * magnitude);
            address(keys).call(abi.encodePacked(keys.claimFarmKeys.selector, abi.encode(farmer, keysDividends)));
            
            address referrer = referrers[farmer];
            if (referrer != address(0)) {
                refRewards[address(keys)][referrer] += (keysDividends / 10);
            }
        }
    }
    
    function claimRefRewards() public {
        uint256 refs = refRewards[address(keys)][msg.sender];
        if (refs > 0) {
            refRewards[address(keys)][msg.sender] = 0;
            keys.claimFarmKeys(msg.sender, refs);
        }
    }

    function cashout(uint256 amount) external {
        address farmer = msg.sender;
        claimYield();

        uint256 sharesAmount = (amount * (10 ** 18)) / pricePerShare;
		totalShares = totalShares.sub(sharesAmount);

		shares[farmer] = shares[farmer].sub(sharesAmount);
        keysPayoutsTo[address(keys)][farmer] -= (int256) (keysProfitPerShare[address(keys)] * sharesAmount);
		cakePool.withdraw(amount);

		uint256 fee = (amount * cashoutTax) / 10000;
		pendingFeesAlloc += fee;
		require(cake.transfer(farmer, amount - fee));
    }
    
    function pullOutstandingDivs() public {
        if (totalShares > 0) {
			cakePool.withdraw(0);
		}
    }

    function swapPool(address newPool) external {
        require(msg.sender == blobby);
        pendingPool = newPool;
        timelock = now + 48 hours;
    }

    function swapPool() external {
        require(timelock < now);
        require(pendingPool != address(0));

        (uint256 amount,) = cakePool.userInfo(address(this));
        cakePool.withdraw(amount);
        cakePool = SyrupPool(pendingPool);
        cake.approve(address(cakePool), 2 ** 255);
        cakePool.deposit(amount);
        pendingPool = address(0);
    }

    function swapYieldToken(address token) external {
        require(msg.sender == blobby);
        yieldToken = token;
        ERC20(yieldToken).approve(address(cakeV2), 2 ** 255);
    }

    function sweepCake(uint256 minBNB, uint256 minBones) external {
		require(msg.sender == blobby);
        pullOutstandingDivs();

		address[] memory path = new address[](2);
        path[0] = address(yieldToken);
        path[1] = address(wbnb);
        
        uint256 amount = ERC20(yieldToken).balanceOf(address(this));
        cakeV2.swapExactTokensForTokens(amount, minBNB, path, address(this), 2 ** 255);

        uint256 bnb = wbnb.balanceOf(address(this));
        uint256 forStaking = (bnb * 5) / 100;
        bnb -= forStaking;
		bonesStaking.distributeDivs(forStaking);
        fomo.addWrappedBnb(minBones, (bnb * 30) / 100); // 30% to fomo pot

        path[0] = address(wbnb);
        path[1] = address(cake);
        
        amount = (bnb * 70) / 100; // 70% compounded to cake
        cakeV2.swapExactTokensForTokens(amount, minBNB, path, address(this), 2 ** 255);

        uint256 cakeGained = cake.balanceOf(address(this));
        cakePool.deposit(cakeGained);
        pricePerShare += cakeGained * (10 ** 18) / totalShares;
	}

    function sweepFees(address recipient, uint256 amount) external {
		require(msg.sender == blobby);
		pendingFeesAlloc = pendingFeesAlloc.sub(amount);
		cake.transfer(recipient, amount);
	}
    
    function setWeeksKeyRewards(uint256 amount) external {
        require(msg.sender == address(blobby));
        dripKeys();
        uint256 remainder;
        if (now < payoutEndTime) {
            remainder = keysPerEpoch * (payoutEndTime - now);
        }
        keysPerEpoch = (amount + remainder) / 7 days;
        payoutEndTime = now + 7 days;
    }
    
    function dripKeys() internal {
        if (lastDripTime + 5 minutes < now) {
            uint256 divs;
            if (now < payoutEndTime) {
                divs = keysPerEpoch * (now - lastDripTime);
            } else if (lastDripTime < payoutEndTime) {
                divs = keysPerEpoch * (payoutEndTime - lastDripTime);
            }
            lastDripTime = now;
    
            if (divs > 0) {
                keysProfitPerShare[address(keys)] += divs * magnitude / totalShares;
            }
        }
    }
    
    function updateFomo(address nextFomo) external {
        require(msg.sender == blobby);
        wbnb.approve(nextFomo, 2 ** 255);
        fomo = FarmFomo(nextFomo);
    }

    function updateBonesStaking(address newStaking) external {
		require(msg.sender == blobby);
		wbnb.approve(newStaking, 2 ** 255);
		bonesStaking = BonesStaking(newStaking);
	}
    
    function updateKeys(address nextKeys) external {
        require(msg.sender == blobby);
        keys = Keys(nextKeys);
        keysPerEpoch = 0;
        payoutEndTime = 0;
        lastDripTime = 0;
    }

    function updateCashoutFee(uint256 newAmount) external {
		require(msg.sender == blobby);
		require(newAmount <= 20); // 0.2% max
		cashoutTax = newAmount;
	}

    
    function outstandingGameCake() view public returns (uint256) {
        uint256 totalDivs = cakePool.pendingReward(address(this)) + ERC20(yieldToken).balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(yieldToken);
        path[1] = address(wbnb);
        return cakeV2.getAmountsOut((totalDivs * 285) / 1000, path)[1];
    }
    
    function cakeBalance(address farmer) view public returns (uint256) {
		return (shares[farmer] * pricePerShare) / (10 ** 18);
	}

	function totalCakeBalance() view public returns (uint256) {
		return (totalShares * pricePerShare) / (10 ** 18);
	}
    
    function keysDividendsOf(address farmer) view public returns (uint256) {
        uint256 totalProfitPerShare = keysProfitPerShare[address(keys)];
        uint256 divs;
        if (now < payoutEndTime) {
            divs = keysPerEpoch * (now - lastDripTime);
        } else if (lastDripTime < payoutEndTime) {
            divs = keysPerEpoch * (payoutEndTime - lastDripTime);
        }
        
        if (divs > 0) {
            totalProfitPerShare += divs * magnitude / totalShares;
        }
        return (uint256) ((int256)(totalProfitPerShare * shares[farmer]) - keysPayoutsTo[address(keys)][farmer]) / magnitude;
    }
}

interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function approveAndCall(address spender, uint tokens, bytes calldata data) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function burn(uint256 amount) external;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract FarmFomo {
    function addWrappedBnb(uint256 minBones, uint256 amount) external;
}

contract Keys is ERC20 {
    function claimFarmKeys(address player, uint256 amount) external;
}
 
interface BonesStaking {
	function depositFor(address player, uint256 amount) external;
	function distributeDivs(uint256 amount) external;
}

interface SyrupPool {
	function deposit(uint256 _amount) external;
	function withdraw(uint256 _amount) external;
	function emergencyWithdraw() external;
    function rewardToken() external view returns (address); 
	function pendingReward(address _user) external view returns (uint256); 
    function userInfo(address _user) external view returns (uint256, uint256); 
}


interface UniswapV2 {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}