//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./ERC20.sol";
import "./Taxable.sol";
import "./AccessControl.sol";
import "./ReentrancyGuard.sol";
import "./IUniswapV2Router02.sol";
import "./IUniswapV2Factory.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/*
NOTES:
 • Taxes stored as uint256 in points, which are 2 decimals of percentages and 4 decimals of a factor. (10000 points = 100.00% = 1.0000x)
 • To use this contract for your own ERC20 token, perform the following tasks:
   - In addition to this and the ERC20 contract, import ReentrancyGuard.sol and AccessControl for security reasons:
*/

contract ELSE is ReentrancyGuard, ERC20, AccessControl, Taxable, Ownable {
    

    using SafeMath for uint256;
    address public currentLiqPair;
    uint256 public  maxAmount = 20000000000000 * (10 ** decimals());
    uint256 public taxAmount;


//    - Add the PRESIDENT_ROLE, GOVERNOR_ROLE, and EXCLUDED_ROLE vars inside the contract as public constants:

	bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
	bytes32 public constant PRESIDENT_ROLE = keccak256("PRESIDENT_ROLE");
	bytes32 public constant EXCLUDED_ROLE = keccak256("EXCLUDED_ROLE"); 	

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    // event _transfer(address from, address to, uint amount);
    // event _transferFrom(address from, address to, uint amount);

    mapping (address => bool) public automatedMarketMakerPairs;
    


//    - In addition to the standard admin role, add the PRESIDENT_ROLE, GOVERNOR_ROLE, and EXCLUDED_ROLE roles to the standard ERC20 constructor:

	constructor() ERC20("CupidInu", "CUPID") {
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(GOVERNOR_ROLE, msg.sender);
		_grantRole(PRESIDENT_ROLE, msg.sender);
		_grantRole(EXCLUDED_ROLE, msg.sender);
        _mint(msg.sender, 1000000000000 * 10 ** decimals());


        // Uniswap testnet address
        // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

        // Pancakeswap Router Mainnet v2    
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

          // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        currentLiqPair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        }

    receive() external payable {

    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "CupidInu: The router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

      function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "CupidInu: The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

        function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "TsetToken: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

//   - Add the public functions for the GOVERNOR_ROLE to enable, disable, an update the tax:

	function enableTax() public onlyRole(GOVERNOR_ROLE) { _taxon(); }
    function disableTax() public onlyRole(GOVERNOR_ROLE) { _taxoff(); }
    function updateTax(uint newtax) public onlyRole(GOVERNOR_ROLE) { _updatetax(newtax); }

//  - Add the public function for the PRESIDENT_ROLE to update the tax destination address:
    function updateTaxDestination(address newdestination) public onlyRole(PRESIDENT_ROLE) { _updatetaxdestination(newdestination); }

  

//    - Override the _transfer() function to perform the necessary tax functions:
    function _transfer(address from, address to, uint256 amount) internal virtual override(ERC20) nonReentrant {

        if(hasRole(EXCLUDED_ROLE, from) || hasRole(EXCLUDED_ROLE, to) || !taxed()) { // If to/from a tax excluded address or if tax is off...
            super._transfer(from, to, amount); // Transfers 100% of amount to recipient.
            } else { // If not to/from a tax excluded address & tax is on...
                require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance"); // Makes sure sender has the required token amount for the total.
                // If the above requirement is not met, then it is possible that the sender could pay the tax but not the recipient, which is bad...
                if (to != uniswapV2Pair) {
                    if(balanceOf(to).add((amount) - (amount * (thetax()/10000))) > maxAmount) {
                    revert("Amount exceeds the limit of maximum tokens allowed.");
                    } else { 
                    super._transfer(from, taxdestination(), amount*thetax()/10000); // Transfers tax to the tax destination address.
                    super._transfer(from, to, amount*(10000-thetax())/10000); // Transfers the remainder to the recipient.
                    }
                } else { 
                    super._transfer(from, taxdestination(), amount*thetax()/10000); // Transfers tax to the tax destination address.
                    super._transfer(from, to, amount*(10000-thetax())/10000); // Transfers the remainder to the recipient.
            }
        }
    }
    
 

    function addLiquidity(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens");
        // transfer tokens to uniswapV2Pair
        super._transfer(msg.sender, uniswapV2Pair, amount);
    }

    function removeLiquidity(uint256 amount) public {
        require(balanceOf(uniswapV2Pair) >= amount, "Not enough liquidity");
        // transfer tokens back to msg.sender
        super._transfer(uniswapV2Pair, msg.sender, amount);
    }
}