/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity 0.5.8;

/**
 *
 * https://moonshots.farm
 * 
 * Want to own the next 1000x SHIB/DOGE/HEX token? Farm a new/trending moonshot every other day, automagically!
 *
 */
 
contract FarmFomo {
    
    ERC20 constant bones = ERC20(0x08426874d46f90e5E527604fA5E3e30486770Eb3);
    ERC20 constant wbnb = ERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    UniswapV2 constant cakeV2 = UniswapV2(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    MoonshotGovernance constant governance = MoonshotGovernance(0x7cE91cEa92e6934ec2AAA577C94a13E27c8a4F21);
    
    ERC20 keysLP;
    FomoKey keysToken;
    address blobby = msg.sender;
    
    mapping(uint256 => Purchases[]) public keyPurchases;
    
    uint256 public currentRoundNumber;
    uint256 public potTimer;
    
    uint256 public maxTimer = 24 hours;
    uint256 public incPerKey;
    
    uint256 public bonesPrize;
    uint256 public previousBonesPrize;
    
    struct Purchases {
        address player;
        uint256 keysBought;
    }
    
    constructor() public {
        wbnb.approve(address(cakeV2), 2 ** 255);
    }
    
    function receiveApproval(address player, uint256 amount, address, bytes calldata) external {
        require(msg.sender == address(keysToken));   
        uint256 keysBought = amount / (10 ** 18); // Round down
        uint256 keySpent = keysBought * (10 ** 18);
        keysToken.transferFrom(player, address(this), keySpent);
        buyKeysInternal(player, keysBought);
    }

    function buyKeysInternal(address player, uint256 keysBought) internal {
        require(keysBought > 0);
        require(now < potTimer);
        keyPurchases[currentRoundNumber].push(Purchases(player, keysBought));
        
        uint256 newTimer = potTimer + (incPerKey * keysBought);
        if (newTimer - now > maxTimer) {
            potTimer = now + maxTimer;
        } else {
            potTimer = newTimer;
        }
    }
    
    function setupRound(address newKeys, address newKeysLP) external {
        require(msg.sender == address(blobby));
        keysToken = FomoKey(newKeys);
        keysLP = ERC20(newKeysLP);
        keysLP.transferFrom(blobby, address(this), keysLP.balanceOf(blobby));
        keysLP.approve(address(cakeV2), 2 ** 255);
    }
    
    function startRound() external {
        require(msg.sender == blobby);
        require(potTimer == 0);
        require(address(keysToken) != address(0));
        governance.pullWeeklyRewards();
        bonesPrize = bones.balanceOf(address(this));
        potTimer = now + maxTimer;
        incPerKey = 60 minutes;
    }
    
    function addBones(uint256 amount) external {
        require(bones.transferFrom(msg.sender, address(this), amount));
        require(potTimer > 0); // Round started
        bonesPrize += (amount * 99) / 100;
    }
    
    function addWrappedBnb(uint256 minBones, uint256 amount) external {
        require(wbnb.transferFrom(msg.sender, address(this), amount));

        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(bones);
        
        uint256 beforeBalance = bones.balanceOf(address(this));
        cakeV2.swapExactTokensForTokens(amount, minBones, path, address(this), 2 ** 255);
        bonesPrize += bones.balanceOf(address(this)) - beforeBalance;
    }

    function burnSpentKeys() external {
        require(msg.sender == blobby);
        keysToken.burn(keysToken.balanceOf(address(this)));
    }
    
    function reduceIncPerKey(uint256 newInc) external {
        require(msg.sender == blobby);
        require(newInc < incPerKey);
        require(newInc >= 5 minutes);
        incPerKey = newInc;
    }
    
    function endRound() external {
        require(potTimer > 0 && now >= potTimer);
        
        uint256 length = keyPurchases[currentRoundNumber].length;
        uint256 results = length;
        if (results > 3) {
            results = 3;
        }

        uint256 keysInGroup;
        for (uint256 i = 0; i < results; i++) {
            Purchases memory purchase = keyPurchases[currentRoundNumber][length - i - 1];
            keysInGroup += (purchase.keysBought);
        }

        for (uint256 j = 0; j < results; j++) {
            Purchases memory winner = keyPurchases[currentRoundNumber][length - j - 1];
            if (winner.player != address(0)) {
                uint256 bonesSplit = (bonesPrize * winner.keysBought) / keysInGroup;
                bones.transfer(winner.player, bonesSplit);
            }
        }
        
        previousBonesPrize = bonesPrize;
        
        potTimer = 0;
        bonesPrize = 0;
        currentRoundNumber++;
        
        cakeV2.removeLiquidityETH(address(keysToken), keysLP.balanceOf(address(this)), 1, 1, blobby, 2 ** 255);
        keysToken = FomoKey(0x0);
    }
    
    function getLatestBuys() public view returns (address[] memory, uint256[] memory) {
        uint256 length = keyPurchases[currentRoundNumber].length;
        uint256 results = length;
        if (results > 3) {
            results = 3;
        }

        address[] memory players = new address[](results);
        uint256[] memory keysPurchased = new uint256[](results);

        for (uint256 i = 0; i < results; i++) {
            Purchases memory purchase = keyPurchases[currentRoundNumber][length - i - 1];
            players[i] = purchase.player;
            keysPurchased[i] = purchase.keysBought;
        }
        
        return (players, keysPurchased);
    }
    
    function getPreviousWinners() public view returns (address[] memory, uint256[] memory, uint256) {
        if (currentRoundNumber == 0) {
            return (new address[](0), new uint256[](0), 0);
        }

        uint256 length = keyPurchases[currentRoundNumber-1].length;
        uint256 results = length;
        if (results > 3) {
            results = 3;
        }

        address[] memory players = new address[](results);
        uint256[] memory keysPurchased = new uint256[](results);

        for (uint256 i = 0; i < results; i++) {
            Purchases memory purchase = keyPurchases[currentRoundNumber-1][length - i - 1];
            players[i] = purchase.player;
            keysPurchased[i] = purchase.keysBought;
        }
        return (players, keysPurchased, previousBonesPrize);
    }
     
}

interface BonesStaking {
    function distributeDivs(uint256 amount) external;
}

interface MoonshotGovernance {
	function pullWeeklyRewards() external;
}

interface UniswapV2 {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function removeLiquidityETH(address token, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function addLiquidityETH(address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface WBNB {
    function withdraw(uint wad) external;
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

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
}

contract FomoKey is ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    string public constant name = "Keys#01";
    string public constant symbol = "KEYS#01";
    uint8 public constant decimals = 18;
    
    address constant CAKE_FARM = address(0x67833cf5e213aE148Fb037327585e2Bc377ab34A);
    
    uint256 totalKeys = 200 * (10 ** 18);
    
    constructor() public {
        balances[msg.sender] = totalKeys;
    }

    function totalSupply() public view returns (uint256) {
        return totalKeys;
    }

    function balanceOf(address player) public view returns (uint256) {
        return balances[player];
    }

    function allowance(address player, address spender) public view returns (uint256) {
        return allowed[player][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender]);
        require(to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function approveAndCall(address spender, uint256 tokens, bytes calldata data) external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    
    function burn(uint256 amount) external {
        if (amount > 0) {
            totalKeys = totalKeys.sub(amount);
            balances[msg.sender] = balances[msg.sender].sub(amount);
            emit Transfer(msg.sender, address(0), amount);
        }
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        require(to != address(0));

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, value);
        return true;
    }
    
    function claimFarmKeys(address player, uint256 amount) external {
        require(msg.sender == CAKE_FARM);
        balances[player] = balances[player].add(amount);
        totalKeys = totalKeys.add(amount);
        emit Transfer(address(0), player, amount);
    }
    
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}