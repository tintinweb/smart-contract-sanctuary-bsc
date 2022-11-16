/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
    }

    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        return account.code.length > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                
                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

library Constants {

  
  uint256 internal constant PERCENT_PRECISION = 1e4;
  uint256 public constant ADMIN_FEE_PERCENT = 10_00; 

  
  uint8 public constant PLANET_LEVELS_NUMBER = 50;
  uint8 public constant NEXT_PLANET_THRESHOLD = 30;

  
  uint256 public constant BUY_ENERGY_MIN_VALUE = 0.004 ether;
  uint256 public constant TOKENS_WITHDRAW_LIMIT = 150_00; 

  uint256 public constant ENERGY_FOR_BNB = 250_000;
  uint256 public constant ENERGY_FOR_CRYSTAL = 110_00; 

  
  uint256 public constant NFT_PRICE = 0.1 ether;
  uint256 public constant NFT_MAX_SUPPLY = 10_000;

}

library GameModels {

  uint8 public constant REF_LEVELS_NUMBER = 7;

  struct Player {
    address referrer;
    address[] referrals;
    uint256[REF_LEVELS_NUMBER] referralsNumber;
    uint256 turnover;
    uint256[REF_LEVELS_NUMBER] turnoverLines;

    uint256 invested;
    uint256 referralRewardFromBuyEnergy;
    uint256 referralRewardFromExchange;
    uint256 withdrawn;
    uint256 withdrawnCrystals;
    uint256[2][REF_LEVELS_NUMBER] referralRewards;

    
    uint256 xp;
    uint8 level;
  }

  struct PlayerBalance {
    uint256 energy;
    uint256 crystals;

    uint256 lastCollectionTime;
    uint256 lastRocketPushTime;
  }

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
}

interface IPancakePair {
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

interface ICommonInterface {

  

  function mint(address to, uint256 amount) external;

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

  

  function ownerOf(uint256 tokenId) external view returns (address);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  

  function level(uint256 tokenId) external view returns (uint8);

  function markAsUsed(address playerAddr, uint256 tokenId) external;

  function upgrade(address playerAddr, uint256 tokenId, uint8 toLevel) external;

  function BNB_RECEIVER_ADDRESS() external returns (address);

}

library Events {

  event Registration(
    address indexed playerAddr,
    address indexed referrerAddr,
    uint256 registrationNumber,
    uint256 timestamp
  );

  event BuyEnergy(
    address indexed playerAddr,
    uint256 bnbAmount,
    uint256 timestamp
  );

  event ExchangeCrystals(
    address indexed playerAddr,
    uint256 crystals,
    uint256 timestamp
  );

  event ReferralReward(
    address indexed receiverAddr,
    address indexed payerAddr,
    uint256 rewardAmount, 
    uint256 bnbAmount,
    uint8 rewardType, 
    uint256 timestamp
  );

  event UpgradePlanet(
    address indexed playerAddr,
    uint8 indexed planetIdx,
    uint8 boughtLevels,
    uint8 resultLevel,
    uint256 timestamp
  );

  event AttachCharacter(
    address indexed playerAddr,
    uint256 tokenId,
    uint256 timestamp
  );

  event DetachCharacter(
    address indexed playerAddr,
    uint256 tokenId,
    uint256 timestamp
  );

  event UpgradeCharacter(
    address indexed playerAddr,
    uint256 indexed chracterTokenId,
    uint8 toLevel
  );

  event RatingUpdate(
    address indexed playerAddr,
    uint256 rating,
    uint256 timestamp
  );

  event CollectResources(
    address indexed playerAddr,
    uint256 energy,
    uint256 crystals,
    uint256 timestamp
  );

  event WithdrawCrystals(
    address indexed playerAddr,
    uint256 crystals,
    uint256 bnbValue,
    uint256 timestamp
  );

  event PushRocket(
    address indexed playerAddr,
    uint256 timestamp
  );

  event CollectAchievementReward(
    address indexed playerAddr,
    uint8 indexed level,
    uint256 timestamp
  );

}

contract Stellum is Ownable, IERC721Receiver {

  uint8 public constant PLANETS_NUMBER = 8;
  uint256[PLANETS_NUMBER] public PLANET_LEVEL_PRICE = [
    1_000 ether,
    2_700 ether,
    7_500 ether,
    20_000 ether,
    55_000 ether,
    145_000 ether,
    400_000 ether,
    1_000_000 ether
  ];

  uint8 public constant ACHIEVEMENTS_NUMBER = 12;
  uint256[ACHIEVEMENTS_NUMBER] public ACHIEVEMENTS_XP = [
    0,
    50_000,
    200_000,
    500_000,
    1_350_000,
    3_225_000,
    5_725_000,
    8_850_000,
    12_725_000,
    23_500_000,
    45_000_000,
    80_000_000
  ];

  uint256[ACHIEVEMENTS_NUMBER] public ACHIEVEMENTS_REWARDS = [
    0,
    1_500 ether,
    6_000 ether,
    15_000 ether,
    40_000 ether,
    96_000 ether,
    171_000 ether,
    265_000 ether,
    381_000 ether,
    700_000 ether,
    1_300_000 ether,
    2_300_000 ether
  ];

  uint8 public constant CHARACTER_LEVELS = 20;
  uint256[CHARACTER_LEVELS] public CHARACTER_LEVEL_UPGARE_PRICE_BNB = [
    0.1 ether, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    1 ether, 0, 0, 0, 2 ether,
    0, 0, 0, 0, 5 ether
  ];
  uint256[CHARACTER_LEVELS] public CHARACTER_LEVEL_UPGARE_PRICE_CRYSTALS = [
    0, 6_200 ether, 9_300 ether, 12_300 ether, 15_400 ether,
    18_500 ether, 21_600 ether, 24_700 ether, 27_800 ether, 30_900 ether,
    0, 39_900 ether, 49_700 ether, 60_500 ether, 0,
    64_000 ether, 78_200 ether, 93_700 ether, 114_000 ether, 0
  ];

  uint8 public constant REFERRAL_LEVELS_NUMBER = 5;
  uint8 public constant MAX_REFERRAL_LEVELS_NUMBER = 7;
  uint256[MAX_REFERRAL_LEVELS_NUMBER] public REFERRAL_PERCENTS = [5_00, 2_00, 1_00, 1_00, 1_00, 1_00, 1_00]; 

  address immutable public DEFAULT_REFERRER;
  address immutable public PROMOTION_ADDRESS;
  address immutable public NFT_TOKEN_ADDRESS;
  address immutable public ERC20_TOKEN_ADDRESS;
  address public LP_TOKEN_ADDRESS; 
  address public PANCAKE_ROUTER_ADDRESS;

  mapping(address => GameModels.Player) public players;
  mapping(address => GameModels.PlayerBalance) public balances;
  mapping(address => uint8[PLANETS_NUMBER]) planets;
  mapping(address => uint256) characters;

  uint8 public TOKENS_BUY_BACK_PERCENT = 10;

  uint256 public totalUsers;
  uint256 public totalSpent;
  uint256[PLANETS_NUMBER] public unlockedPlanets;
  uint256[PLANETS_NUMBER] public unlockedPlanetLevels;
  uint256 public totalCrystalsWithdrawn;

  constructor(
    address defaultReferrerAddress,
    address promotionAddress,
    address nftTokenAddress,
    address erc20TokenAddress,
    address lpTokenContractAddress
  ) {
    require(defaultReferrerAddress != address(0x0), "Invalid default referrer address");
    require(Address.isContract(lpTokenContractAddress), "Invalid LP-token contract address");

    DEFAULT_REFERRER = defaultReferrerAddress;
    PROMOTION_ADDRESS = promotionAddress;

    NFT_TOKEN_ADDRESS = nftTokenAddress;

    ERC20_TOKEN_ADDRESS = erc20TokenAddress;
    LP_TOKEN_ADDRESS = lpTokenContractAddress;

    PANCAKE_ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  }

  receive() external payable {
    if (msg.value > 0) {
      payable(PROMOTION_ADDRESS).transfer(msg.value);
    }
  }

  function buyEnergy(address referrer) external payable {
    require(msg.value >= Constants.BUY_ENERGY_MIN_VALUE, "Minimal amount is 0.004 BNB");

    GameModels.Player storage player = players[msg.sender];
    
    if (player.referrer == address(0x0)) {
      if (referrer == address(0x0) || referrer == msg.sender || players[referrer].referrer == address(0x0)) {
        referrer = DEFAULT_REFERRER;
      }
      player.referrer = referrer;
      players[referrer].referrals.push(msg.sender);

      totalUsers++;

      emit Events.RatingUpdate(referrer, getRating(referrer), block.timestamp);

      emit Events.Registration(
        msg.sender, referrer, totalUsers, block.timestamp
      );
    }

    player.invested+= msg.value;
    balances[msg.sender].energy+= msg.value * Constants.ENERGY_FOR_BNB;

    totalSpent+= msg.value;

    
    uint256 xp = msg.value * Constants.ENERGY_FOR_BNB * Constants.PERCENT_PRECISION / 1 ether;
    player.xp+= xp * getXPMultiplier(msg.sender);
    emit Events.RatingUpdate(msg.sender, getRating(msg.sender), block.timestamp);

    
    uint256 tokensAmount = getTokensAmount(msg.value);
    address ref = player.referrer;
    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      if (i < REFERRAL_LEVELS_NUMBER || getReferralLevelsNumber(ref) > i) {
        uint256 tokensRewardAmount = tokensAmount * REFERRAL_PERCENTS[i] / Constants.PERCENT_PRECISION;
        uint256 bnbRewardAmount = msg.value * REFERRAL_PERCENTS[i] / Constants.PERCENT_PRECISION;

        ICommonInterface(ERC20_TOKEN_ADDRESS).mint(ref, tokensRewardAmount);
        players[ref].referralRewardFromBuyEnergy+= bnbRewardAmount;
        players[ref].referralRewards[i][0]+= bnbRewardAmount;

        emit Events.ReferralReward(
          ref,
          msg.sender,
          tokensRewardAmount,
          bnbRewardAmount,
          0,
          block.timestamp
        );
      }

      
      if (i == 0) {
        players[ref].xp+= xp * getXPMultiplier(ref) / 2;
        emit Events.RatingUpdate(ref, getRating(ref), block.timestamp);
      } else if (i == 1) {
        players[ref].xp+= xp * getXPMultiplier(ref) / 4;
        emit Events.RatingUpdate(ref, getRating(ref), block.timestamp);
      }

      
      players[ref].turnover+= msg.value;
      players[ref].turnoverLines[i]+= msg.value;

      players[ref].referralsNumber[i]++;

      ref = players[ref].referrer;
      if (ref == address(0x0)) {
        ref = DEFAULT_REFERRER;
      }
    }

    payable(owner()).transfer(msg.value * Constants.ADMIN_FEE_PERCENT / Constants.PERCENT_PRECISION);
    

    
    buyBackTokens(address(this).balance * uint256(TOKENS_BUY_BACK_PERCENT) / 100);
    addLiquidity(address(this).balance);

    emit Events.BuyEnergy(
      msg.sender, msg.value, block.timestamp
    );
  }

  function upgradePlanet(uint8 planetIdx, uint8 levelsToBuy) external {
    require(!Address.isContract(msg.sender), "Buyer shouldn't be a contract"); 
    require(planetIdx >= 0 && planetIdx < PLANETS_NUMBER, "Invalid planet index");
    require(planetIdx == 0 || planets[msg.sender][planetIdx - 1] >= Constants.NEXT_PLANET_THRESHOLD, "This planed is closed. Upgrade previous planet first.");
    require(levelsToBuy <= Constants.PLANET_LEVELS_NUMBER, "Invalid levels to buy amount");

    if (planets[msg.sender][planetIdx] + levelsToBuy > Constants.PLANET_LEVELS_NUMBER) {
      levelsToBuy = Constants.PLANET_LEVELS_NUMBER - planets[msg.sender][planetIdx];
    }
    require(levelsToBuy > 0, "Invalid levels to buy amount");

    collectCrystalsAndEnergy();

    uint256 energyAmount = levelsToBuy * PLANET_LEVEL_PRICE[planetIdx];
    require(balances[msg.sender].energy >= energyAmount, "Not enough energy on the balance");

    if (planets[msg.sender][planetIdx] == 0) {
      unlockedPlanets[planetIdx]++;
    }
    unlockedPlanetLevels[planetIdx]+= levelsToBuy;

    balances[msg.sender].energy-= energyAmount;
    planets[msg.sender][planetIdx]+= levelsToBuy;

    emit Events.UpgradePlanet(
      msg.sender, planetIdx, levelsToBuy, planets[msg.sender][planetIdx], block.timestamp
    );
  }

  function mayBeCollected(address playerAddr) public view returns (uint256 energy, uint256 crystals) {
    if (balances[playerAddr].lastCollectionTime == 0 || balances[playerAddr].lastCollectionTime == block.timestamp) {
      return (0 , 0);
    }

    GameModels.PlayerBalance memory balance = balances[playerAddr];
    uint256 startTime = balance.lastCollectionTime;
    uint256 endTime = block.timestamp;
    if (startTime < balance.lastRocketPushTime) {
      startTime = balance.lastRocketPushTime;
    }
    if (endTime > balance.lastRocketPushTime + getRocketFlightDuration(playerAddr)) {
      endTime = balance.lastRocketPushTime + getRocketFlightDuration(playerAddr);
    }

    if (startTime >= endTime) {
      return (0 , 0);
    }
    uint256 time = endTime - startTime;

    uint256 profit = 0;
    for (uint8 planetIdx = 0; planetIdx < PLANETS_NUMBER; planetIdx++) {
      if (planets[playerAddr][planetIdx] > 0) {
        profit+= PLANET_LEVEL_PRICE[planetIdx] * planets[playerAddr][planetIdx];
      } else {
        break;
      }
    }

    if (profit == 0) {
      return (0 , 0);
    }
    profit= profit * time / 30 days;
    crystals = profit * getPerformanceRatio(playerAddr) / Constants.PERCENT_PRECISION;

    return (profit - crystals, crystals);
  }

  function collectCrystalsAndEnergy() public {
    GameModels.PlayerBalance storage balance = balances[msg.sender];

    if (balance.lastCollectionTime == 0) {
      balance.lastCollectionTime = block.timestamp;
      balance.lastRocketPushTime = block.timestamp;

      return;
    }

    (uint256 energy, uint256 crystals) = mayBeCollected(msg.sender);
    if (energy == 0 || crystals == 0) {
      return;
    }

    balance.energy+= energy;
    balance.crystals+= crystals;
    balance.lastCollectionTime = block.timestamp;

    emit Events.CollectResources(
      msg.sender, energy, crystals, block.timestamp
    );
  }

  function instantBalance(address playerAddr) external view returns (uint256, uint256) {
    GameModels.PlayerBalance memory balance = balances[playerAddr];

    (uint256 energy, uint256 crystals) = mayBeCollected(playerAddr);

    return (balance.energy + energy, balance.crystals + crystals);
  }

  
  function changeCrystalsForEnergy(uint256 crystalsAmount) external {
    require(crystalsAmount > 0, "Invalid crystals amount");

    collectCrystalsAndEnergy();
    require(crystalsAmount <= balances[msg.sender].crystals, "Not enough crystals on the balance");

    balances[msg.sender].crystals-= crystalsAmount;
    balances[msg.sender].energy+= crystalsAmount * Constants.ENERGY_FOR_CRYSTAL / Constants.PERCENT_PRECISION;

    
    address ref = players[msg.sender].referrer;
    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      if (i < REFERRAL_LEVELS_NUMBER || getReferralLevelsNumber(ref) > i) {
        uint256 rewardAmount = crystalsAmount * REFERRAL_PERCENTS[i] / Constants.PERCENT_PRECISION;
        uint256 bnbRewardAmount = rewardAmount / Constants.ENERGY_FOR_BNB;

        balances[ref].energy+= rewardAmount;
        players[ref].referralRewardFromExchange+= bnbRewardAmount;
        players[ref].referralRewards[i][1]+= bnbRewardAmount;

        emit Events.ReferralReward(
          ref,
          msg.sender,
          rewardAmount,
          bnbRewardAmount,
          1,
          block.timestamp
        );
      }

      ref = players[ref].referrer;
      if (ref == address(0x0)) {
        ref = DEFAULT_REFERRER;
      }
    }

    emit Events.ExchangeCrystals(
      msg.sender, crystalsAmount, block.timestamp
    );
  }

  
  function withdrawCrystals(uint256 crystalsAmount) external {
    require(crystalsAmount > 0, "Invalid crystals amount");

    collectCrystalsAndEnergy();
    require(crystalsAmount <= balances[msg.sender].crystals, "Not enough crystals on the balance");

    uint256 tokensMayBeWithdrawn = mayBeWithdrawn(msg.sender);
    require(tokensMayBeWithdrawn > 0, "You have reached withdrawal limit");
    if (crystalsAmount > tokensMayBeWithdrawn) {
      crystalsAmount = tokensMayBeWithdrawn;
    }

    GameModels.Player storage player = players[msg.sender];
    uint256 value = getBNBAmount(crystalsAmount);

    player.withdrawn+= value;
    player.withdrawnCrystals+= crystalsAmount;
    totalCrystalsWithdrawn+= crystalsAmount;

    balances[msg.sender].crystals-= crystalsAmount;

    ICommonInterface(ERC20_TOKEN_ADDRESS).mint(msg.sender, crystalsAmount);

    emit Events.WithdrawCrystals(
      msg.sender, crystalsAmount, value, block.timestamp
    );
  }

  function mayBeWithdrawn(address playerAddr) public view returns (uint256) {
    GameModels.Player memory player = players[playerAddr];

    uint256 bnbAmount =
      (player.invested + player.referralRewardFromExchange) * Constants.TOKENS_WITHDRAW_LIMIT / Constants.PERCENT_PRECISION
      - player.withdrawn;

    return getTokensAmount(bnbAmount);
  }

  function attachCharacter(uint256 tokenId) external {
    require(characters[msg.sender] == 0, "You have already attached other character");
    require(ICommonInterface(NFT_TOKEN_ADDRESS).ownerOf(tokenId) == msg.sender, "You are not an owner of this NFT");

    collectCrystalsAndEnergy();

    ICommonInterface(NFT_TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), tokenId);
    characters[msg.sender] = tokenId;

    ICommonInterface(NFT_TOKEN_ADDRESS).markAsUsed(msg.sender, tokenId);

    emit Events.AttachCharacter(
      msg.sender, tokenId, block.timestamp
    );

    
    balances[msg.sender].lastRocketPushTime = block.timestamp;
  }

  function detachCharacter() external {
    require(characters[msg.sender] > 0, "You have no attached character");
    require(
      ICommonInterface(NFT_TOKEN_ADDRESS).ownerOf(characters[msg.sender]) == address(this),
      "We have no this NFT on the contract"
    );

    collectCrystalsAndEnergy();

    ICommonInterface(NFT_TOKEN_ADDRESS).safeTransferFrom(address(this), msg.sender, characters[msg.sender]);
    emit Events.DetachCharacter(
      msg.sender, characters[msg.sender], block.timestamp
    );
    characters[msg.sender] = 0;

    
    balances[msg.sender].lastRocketPushTime = block.timestamp;
  }

  function upgradeCharacter(uint8 toLevel) external payable {
    require(toLevel <= 20, "Invalid level value");
    require(characters[msg.sender] > 0, "You have no attached character");
    require(
      ICommonInterface(NFT_TOKEN_ADDRESS).ownerOf(characters[msg.sender]) == address(this),
      "Character NFT isn't attached to the game"
    );

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[msg.sender]);
    require(characterLvl < 20, "You have reached the maximum level");
    require(toLevel > characterLvl, "You can't downgrade character");

    collectCrystalsAndEnergy();

    uint256 upgradePriceBNB = 0;
    uint256 upgradePriceCrystals = 0;
    for (uint8 lvl = characterLvl; lvl < toLevel; lvl++) {
      upgradePriceBNB+= CHARACTER_LEVEL_UPGARE_PRICE_BNB[lvl];
      upgradePriceCrystals+= CHARACTER_LEVEL_UPGARE_PRICE_CRYSTALS[lvl];
    }

    if (upgradePriceBNB > 0) {
      require(msg.value == upgradePriceBNB, "Invalid upgrade BNB amount");

      payable(ICommonInterface(NFT_TOKEN_ADDRESS).BNB_RECEIVER_ADDRESS()).transfer(msg.value);
    }

    if (upgradePriceCrystals > 0) {
      require(
        balances[msg.sender].crystals >= upgradePriceCrystals,
        "Insufficient crystals balance"
      );

      balances[msg.sender].crystals-= upgradePriceCrystals;
    }
    ICommonInterface(NFT_TOKEN_ADDRESS).upgrade(msg.sender, characters[msg.sender], toLevel);

    emit Events.RatingUpdate(msg.sender, getRating(msg.sender), block.timestamp);

    emit Events.UpgradeCharacter(msg.sender, characters[msg.sender], toLevel);

    
    balances[msg.sender].lastRocketPushTime = block.timestamp;
  }

  function pushRocket() external {
    collectCrystalsAndEnergy();

    balances[msg.sender].lastRocketPushTime = block.timestamp;

    emit Events.PushRocket(msg.sender, block.timestamp);
  }

  
  function getRocketState(address playerAddr) external view returns (uint256 lastRocketPushTime, uint256 duration) {
    return (balances[playerAddr].lastRocketPushTime, getRocketFlightDuration(playerAddr));
  }

  function getBNBAmount(uint256 tokensAmount) public view returns(uint256) {
    (uint256 reserve0, uint256 reserve1, ) = IPancakePair(LP_TOKEN_ADDRESS).getReserves();

    return tokensAmount * reserve1 / reserve0;
  }

  function getTokensAmount(uint256 amount) public view returns(uint256) {
    (uint256 reserve0, uint256 reserve1, ) = IPancakePair(LP_TOKEN_ADDRESS).getReserves();

    return amount * reserve0 / reserve1;
  }

  function getTokenLiquidity() external view returns (
    uint256 liquidityBNB,
    uint256 liquiditySTM
  ) {
    (liquiditySTM, liquidityBNB, ) = IPancakePair(LP_TOKEN_ADDRESS).getReserves();
  }

  function buyBackTokens(uint256 bnbAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); 
    path[1] = ERC20_TOKEN_ADDRESS;

    IPancakeRouter(PANCAKE_ROUTER_ADDRESS).swapExactETHForTokens {value: bnbAmount} (
      0,
      path,
      PROMOTION_ADDRESS,
      block.timestamp + 5 minutes
    );

    
  }

  function addLiquidity(uint256 bnbAmount) private {
    uint256 amount = getTokensAmount(bnbAmount);

    ICommonInterface(ERC20_TOKEN_ADDRESS).mint(address(this), amount);
    ICommonInterface(ERC20_TOKEN_ADDRESS).increaseAllowance(PANCAKE_ROUTER_ADDRESS, amount);

    

    (uint256 amountToken, uint256 amountBNB, uint256 liquidity) = IPancakeRouter(PANCAKE_ROUTER_ADDRESS).addLiquidityETH {value: bnbAmount} (
      ERC20_TOKEN_ADDRESS,
      amount,
      0,
      0,
      address(this),
      block.timestamp + 5 minutes
    );

    

    
  }

  function addLiquidityManually(uint256 bnbAmount) external onlyOwner {
    addLiquidity(bnbAmount);
  }

  function changePancakeRouterAddress(address newAddr) external onlyOwner {
    require(newAddr != address(0x0) && Address.isContract(newAddr), "Invalid PancakeRouter address");
    require(newAddr != PANCAKE_ROUTER_ADDRESS, "Address is already setted");

    PANCAKE_ROUTER_ADDRESS = newAddr;
  }

  function changeTokensBuyBackPercent(uint8 percent) external onlyOwner {
    require(percent > 0 && percent <= 100, "Invalid percent value");

    TOKENS_BUY_BACK_PERCENT = percent;
  }

  function getReferralLevelsNumber(address playerAddr) public view returns (uint8 refLevelsNumber) {
    if (characters[playerAddr] == 0) {
      return REFERRAL_LEVELS_NUMBER;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);
    if (characterLvl >= 15) {
      return (REFERRAL_LEVELS_NUMBER + 2);
    } else if (characterLvl >= 11) {
      return (REFERRAL_LEVELS_NUMBER + 1);
    }

    return REFERRAL_LEVELS_NUMBER;
  }

  
  function getPerformanceRatio(address playerAddr) public view returns (uint256 performanceRatio) {
    if (characters[playerAddr] == 0) {
      return 40_00;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);

    return (40_00 + 1_00 * uint256(characterLvl));
  }

  function getRocketFlightDuration(address playerAddr) public view returns (uint256 rocketFlyDuration) {
    if (characters[playerAddr] == 0) {
      return (24 hours);
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);
    if (characterLvl >= 19) {
      return (24 hours + 240 hours);
    } else if (characterLvl >= 16) {
      return (24 hours + 144 hours);
    } else if (characterLvl >= 14) {
      return (24 hours + 120 hours);
    } else if (characterLvl >= 10) {
      return (24 hours + 96 hours);
    } else if (characterLvl >= 8) {
      return (24 hours + 72 hours);
    } else if (characterLvl >= 5) {
      return (24 hours + 48 hours);
    } else if (characterLvl >= 2) {
      return (24 hours + 24 hours);
    } else if (characterLvl == 1) {
      return (24 hours + 12 hours);
    }

    return (24 hours);
  }

  function getXPMultiplier(address playerAddr) public view returns (uint256 xpMultiplier) {
    if (characters[playerAddr] == 0) {
      return Constants.PERCENT_PRECISION;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);
    if (characterLvl >= 13) {
      return Constants.PERCENT_PRECISION + 30_00;
    } else if (characterLvl >= 11) {
      return Constants.PERCENT_PRECISION + 25_00;
    } else if (characterLvl >= 9) {
      return Constants.PERCENT_PRECISION + 20_00;
    } else if (characterLvl >= 7) {
      return Constants.PERCENT_PRECISION + 15_00;
    } else if (characterLvl >= 5) {
      return Constants.PERCENT_PRECISION + 10_00;
    } else if (characterLvl >= 3) {
      return Constants.PERCENT_PRECISION + 5_00;
    }

    return Constants.PERCENT_PRECISION;
  }

  function getRatingMultiplier(address playerAddr) public view returns (uint256 ratingMultiplier) {
    if (characters[playerAddr] == 0) {
      return Constants.PERCENT_PRECISION;
    }

    uint8 characterLvl = ICommonInterface(NFT_TOKEN_ADDRESS).level(characters[playerAddr]);

    return Constants.PERCENT_PRECISION + uint256(characterLvl) * 10_00;
  }

  function getRating(address playerAddr) public view returns (uint256 rating) {
    return (players[playerAddr].xp + players[playerAddr].referrals.length * 50_000 * Constants.PERCENT_PRECISION * Constants.PERCENT_PRECISION)
      * getRatingMultiplier(playerAddr) / Constants.PERCENT_PRECISION
      / Constants.PERCENT_PRECISION
      / Constants.PERCENT_PRECISION;
  }

  function collectAchievementReward() external {
    GameModels.Player storage player = players[msg.sender];

    uint8 lvl = player.level + 1;
    while (lvl < ACHIEVEMENTS_NUMBER) {
      if (player.xp >= ACHIEVEMENTS_XP[lvl] * Constants.PERCENT_PRECISION * Constants.PERCENT_PRECISION) {
        balances[msg.sender].energy+= ACHIEVEMENTS_REWARDS[lvl];
        lvl++;
      } else {
        break;
      }
    }

    player.level = lvl - 1;

    emit Events.CollectAchievementReward(msg.sender, player.level, block.timestamp);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure returns (bytes4) {
    return this.onERC721Received.selector; 
  }

  function referrals(address playerAddr) external view returns (address[] memory) {
    return players[playerAddr].referrals;
  }

  function commonReferralStats(address playerAddr) external view returns (
    address referrer,
    uint256 referralsCount,
    uint256 structureVolume,
    uint256 turnover,
    address[] memory referralsList,
    uint256[MAX_REFERRAL_LEVELS_NUMBER] memory referralsNumber,
    uint256[MAX_REFERRAL_LEVELS_NUMBER] memory turnoverLines
  ) {
    GameModels.Player memory player = players[playerAddr];

    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      structureVolume+= player.referralsNumber[i];
    }

    return (
      player.referrer,
      player.referrals.length,
      structureVolume,
      player.turnover,
      player.referrals,
      player.referralsNumber,
      player.turnoverLines
    );
  }

  function getReferralRewards(address playerAddr) external view returns (
    uint256[] memory referralRewardsFromBuyEnergy, uint256[] memory referralRewardsFromExchange
  ) {
    GameModels.Player memory player = players[playerAddr];

    referralRewardsFromBuyEnergy = new uint256[](MAX_REFERRAL_LEVELS_NUMBER);
    referralRewardsFromExchange = new uint256[](MAX_REFERRAL_LEVELS_NUMBER);

    for (uint8 i = 0; i < MAX_REFERRAL_LEVELS_NUMBER; i++) {
      referralRewardsFromBuyEnergy[i] = player.referralRewards[i][0];
      referralRewardsFromExchange[i] = player.referralRewards[i][1];
    }
  }

  function getPlanetsStats() external view returns (
    uint256[] memory unlockedPlanetsStats,
    uint256[] memory unlockedPlanetLevelsStats
  ) {
    unlockedPlanetsStats = new uint256[](PLANETS_NUMBER);
    unlockedPlanetLevelsStats = new uint256[](PLANETS_NUMBER);

    for (uint8 i = 0; i < PLANETS_NUMBER; i++) {
      unlockedPlanetsStats[i] = unlockedPlanets[i];
      unlockedPlanetLevelsStats[i] = unlockedPlanetLevels[i];
    }
  }

  function getPlayerPlanets(address playerAddr) external view returns (uint8[PLANETS_NUMBER] memory) {
    return planets[playerAddr];
  }

  function buyEnergy() external payable {
    payable(msg.sender).transfer(msg.value);

    
  }

}