/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT

    pragma solidity ^0.8.8;

    abstract contract Context {
        function _msgSender() internal view virtual returns (address) {
            return msg.sender;
        }

        function _msgData() internal view virtual returns (bytes memory) {
            this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
            return msg.data;
        }
    }

    interface IERC20 {
        
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }

    interface Discount_Interface {
    //Trade type: Buy = 1, Sell = 2 
    function Get_Project_Fee_Discount(uint256 trade_type, address account) external view returns (uint);
    }

    library SafeMath {

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            require(c >= a, "Aaddition overflow");

            return c;
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            return sub(a, b, "Subtraction overflow");
        }
        function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b <= a, errorMessage);
            uint256 c = a - b;
            return c;
        }
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) {
                return 0;
            }
            uint256 c = a * b;
            require(c / a == b, "Multiplication overflow");
            return c;
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
            return div(a, b, "Division by zero");
        }
        function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b > 0, errorMessage);
            uint256 c = a / b;
            // assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c;
        }
        function mod(uint256 a, uint256 b) internal pure returns (uint256) {
            return mod(a, b, "Modulo by zero");
        }
        function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
            require(b != 0, errorMessage);
            return a % b;
        }
    }

    library Address {

        function isContract(address account) internal view returns (bool) {
            // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
            // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
            // for accounts without code, i.e. `keccak256('')`
            bytes32 codehash;
            bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
            // solhint-disable-next-line no-inline-assembly
            assembly { codehash := extcodehash(account) }
            return (codehash != accountHash && codehash != 0x0);
        }
        function sendValue(address payable recipient, uint256 amount) internal {
            require(address(this).balance >= amount, "Insufficient balance");

            // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
            (bool success, ) = recipient.call{ value: amount }("");
            require(success, "Unable to send value, recipient may have reverted");
        }
        function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Low-level call failed");
        }
        function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
            return _functionCallWithValue(target, data, 0, errorMessage);
        }
        function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
            return functionCallWithValue(target, data, value, "Low-level call with value failed");
        }
        function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
            require(address(this).balance >= value, "Insufficient balance for call");
            return _functionCallWithValue(target, data, value, errorMessage);
        }
        function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
            require(isContract(target), "Call to non-contract");

            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
            if (success) {
                return returndata;
            } else {
                // Look for revert reason and bubble it up if present
                if (returndata.length > 0) {
                    // The easiest way to bubble the revert reason is using memory via assembly

                    // solhint-disable-next-line no-inline-assembly
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

    contract Ownable is Context {
        address internal CEO;
    
        mapping(address => bool) internal Security_Admin; 
        uint256 public Amount_Security_Admins;
        
        address public Security_Manager;

        event CEO_Changed(address indexed previousCEO, address indexed newCEO);
        event Changed_Security_Manager(address indexed previous_Security_Manager, address indexed new_Security_Manager);
        event Added_Security_Admin(address indexed account);
        event Removed_Security_Admin(address indexed account);

        constructor () {
            address msgSender = _msgSender();
            CEO = msgSender;
            emit CEO_Changed(address(0), msgSender);

            Security_Manager = _msgSender(); 
        }

            //****************************   IMPORTANT   ****************************//
            //
            //  SECURITY REQUIREMENTS - Steps To Do Upon Contract Deployment
            //
            //  The deploy will default assign the various roles (accounts)  
            //  to the CEO account. Follow these steps to update those roles: 
            // 
            //  1) CEO should not be Security Manager. 
            //     Therefore upon contract deploy CEO should change the Security 
            //     Manager. So that CEO and Security Manager are different accounts.
            //  
            //  2) The new Security Manager should add a Security Admin account.
            //     Maximum 2 Security Admins (accounts) are allowed and can be added.
            //
            //  3) Marketing and Blockchain Managers are usually not CEO. 
            //     If so then CEO should change those Managers to their accounts.    
            //
            //************************  ABOUT SECURITY MODEL  ***********************//  
            // 
            //    This contract doesn't use the typical security model 
            //    where the Owner (CEO) has full control of the token contract.

            //    Each role has limited permission / own control permissions:
            //
            //    - CEO                (Max 1 account / person is allowed)
            //    - Security Manager   (Max 1 account / person is allowed)
            //
            //    - Security Admin     (Max 2 accounts / persons are allowed)
            //    - Marketing Manager  (Max 2 accounts / persons are allowed)
            //    - Blockchain Manager (Max 2 accounts / persons are allowed)
            //
            //    The Security Admin and Security Manager have the highest permsissions.
            // 
            //***********************************************************************//

        modifier onlyCEO() {
            require(CEO == _msgSender());
            _;
        }
        // This contract is secured by the Security Admin
        // and Security Manager roles. These roles control     
        // most functionality and features in this contract.
        modifier onlySecurityAdmin() {
            require(Security_Admin[_msgSender()] || Security_Manager == _msgSender());
            _;
        }
        // Chief Security Officer
        modifier onlySecurityManager() {
            require(Security_Manager == _msgSender());
            _;
        }
        function CEO_Address() public view virtual returns (address) {
            return CEO;
        }
    }

    // pragma solidity >=0.5.0;

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

    // pragma solidity >=0.5.0;

    interface IUniswapV2Pair {
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

    // pragma solidity >=0.6.2;

    interface IUniswapV2Router01 {
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

    // pragma solidity >=0.6.2;

    interface IUniswapV2Router02 is IUniswapV2Router01 {
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

    contract META_50 is Context, IERC20, Ownable {
        using SafeMath for uint256;
        using Address for address;

        mapping (address => uint256) private _rOwned;
        mapping (address => uint256) private _tOwned;
        mapping (address => mapping (address => uint256)) private _allowances;

        mapping (address => bool) private isExcludedFromFees; // exempt from paying any fees
        mapping (address => bool) private isExcludedReflections; // exempt from receiving reflections
        address[] private _excluded;

        uint8 private _decimals = 2;
    
        uint256 private constant MAX = ~uint256(0);
        uint256 private _tTotal = 5000000 * 10**_decimals; // 500 Million
        uint256 private _rTotal = (MAX - (MAX % _tTotal));
        uint256 private _tFeeTotal;

        string private _name = "META_50";
        string private _symbol = "META_50";

        // Sell price impact tiers 
        //   (% multiplied by 100)
        uint256 private price_impact1;
        uint256 private price_impact2;

        // Fees for buy trades (%)
        uint256 private Buy_ProjectFee;
        uint256 private Buy_ReflectionsFee;

        // Fees for sell trades (%)
        uint256 private Sell_ProjectFee_If_Impacts_Not_Used; 
        uint256 private Sell_ReflectionsFee_If_Impacts_Not_Used;
        
        uint256 private Sell_ProjectFee_Under_Impact1;
        uint256 private Sell_ProjectFee_Above_Impact1;
        uint256 private Sell_ProjectFee_Above_Impact2;
        
        uint256 private Sell_ReflectionsFee_Under_Impact1;
        uint256 private Sell_ReflectionsFee_Above_Impact1;
        uint256 private Sell_ReflectionsFee_Above_Impact2;

        // Fees for normal transfers (%)
        uint256 private Transfer_ProjectFee;
        uint256 private Transfer_ReflectionsFee;

        // Internal. Takes the value of buy
        // sell and transfer fees, respectively
        uint256 private ProjectFee;
        uint256 private ReflectionsFee;

        uint256 private previous_ProjectFee;
        uint256 private previous_ReflectionsFee;   

        // Project Fee discount contract
        address private Discount_Contract;

        // Total Project funding fee split 
        // into portions (%) (total must be 100%) 
        uint256 private ProductDevelopmentFee; 
        uint256 private MarketingFee;          
        uint256 private BlockchainSupportFee;  
        uint256 private ReservaFee;

        // Waiting time between sells (in seconds)
        mapping(address => uint256) private sell_AllowedTime;
        bool private Impact2_Sell;

        uint256 private normal_waiting_time_between_sells;
        uint256 private waiting_time_to_sell_after_impact2;                             
        
        mapping(address => uint256) private Loyalty_StartTime;
        mapping(address => uint256) private Previous_SellTime;

        uint256 private Loyalty_Days_Loss_When_Sell_Or_Move_Tokens;

        address private productDevelopmentWallet;
        address private marketingWallet;
        address private blockchainSupportWallet;
        address private reservaWallet;
        address private communityBeneficialWallet; 

        mapping(address => bool) private isBlacklisted;
        mapping(address => bool) private BridgeOrExchange;
        mapping(address => uint256) private BridgeOrExchange_ProjectFee;
        mapping(address => uint256) private BridgeOrExchange_ReflectionsFee;

        // Marketing Manager. 
        // Has no control of the smart contract except do this:  
        // Can only manage the Marketing funds and wallet 
        mapping(address => bool) private Marketing_Manager;  
        
        // Blockchain Manager. 
        // Has no control of the smart contract except do this:  
        // Can only manage the Blockchain Support funds and wallet 
        mapping(address => bool) private Blockchain_Manager;
        
        uint256 private Marketing_Managers_Count;
        uint256 private Blockchain_Managers_Count;

        bool private Public_Trading_Enabled;
        bool private is_Buy_Trade;
        bool private is_Sell_Trade;

        bool private Project_Funding_Swap_Mode;    
        uint256 private minAmountTokens_ProjectFundingSwap =  10 * 10**_decimals; // 0.0002%


        IUniswapV2Router02 public immutable uniswapV2Router;
        address public immutable uniswapV2Pair;

        event Project_Funding_Done(
            uint256 tokensSwapped,
            uint256 amountBNB
        );
        event Transfer_Fee_Tokens_Sent_To_Community_Beneficial_Wallet(
            address indexed recipient,
            uint256 amount
        );
        event Impact2_Sell_Allowed_Time_Next_Sell(
            address indexed account, 
            uint256 next_time_can_sell
        );

        event Added_Marketing_Manager(address indexed account);
        event Removed_Marketing_Manager(address indexed account);

        event Added_Blockchain_Manager(address indexed account);
        event Removed_Blockchain_Manager(address indexed account);

        modifier lockTheSwap {
            Project_Funding_Swap_Mode = true;
            _;
            Project_Funding_Swap_Mode = false;
        }
        modifier onlyMarketingManager() {
            require(Marketing_Manager[msg.sender]);
            _;
        }
        modifier onlyBlockchainManager() {
            require(Blockchain_Manager[msg.sender]);
            _;
        }
                
        constructor () {
            _rOwned[_msgSender()] = _rTotal;
            
            // PancakeSwap V2 Router
            // IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
            
            // For testing in BSC Testnet
            IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); 

            // Create a pair for this new token
            uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

            // Set the rest of the contract variables
            uniswapV2Router = _uniswapV2Router;
            
            // Exclude owners and this contract from all fees
            isExcludedFromFees[CEO] = true;
            isExcludedFromFees[address(this)] = true;

            productDevelopmentWallet = msg.sender;
            marketingWallet = msg.sender;
            blockchainSupportWallet = msg.sender;
            reservaWallet = msg.sender;
            communityBeneficialWallet = msg.sender;

            ProductDevelopmentFee = 25; 
            MarketingFee = 25;          
            BlockchainSupportFee = 25;  
            ReservaFee = 25;

            emit Transfer(address(0), _msgSender(), _tTotal);
        }

        modifier ExceptAccounts(address account) {
            require(account != 0x10ED43C718714eb63d5aA57B78B54704E256024E); //PancakeSwap 
            require(account != address(this)); 
            require(account != address(0));    
            require(account != CEO);
            require(account != Security_Manager);
            require(!Security_Admin[account]);
            require(!Marketing_Manager[account]);
            require(!Blockchain_Manager[account]);
            require(account != productDevelopmentWallet);
            require(account != marketingWallet);	
            require(account != blockchainSupportWallet);
            require(account != reservaWallet);	
            require(account != communityBeneficialWallet);
            _;
        }

        function name() public view returns (string memory) {
            return _name;
        }
        function symbol() public view returns (string memory) {
            return _symbol;
        }
        function decimals() public view returns (uint8) {
            return _decimals;
        }
        function totalSupply() public view override returns (uint256) {
            return _tTotal;
        }
        function balanceOf(address account) public view override returns (uint256) {
            if (isExcludedReflections[account]) return _tOwned[account];
            return tokenFromReflection(_rOwned[account]);
        }
        function transfer(address recipient, uint256 amount) public override returns (bool) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
        function allowance(address owner, address spender) public view override returns (uint256) {
            return _allowances[owner][spender];
        }
        function approve(address spender, uint256 amount) public override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }
        function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
            return true;
        }
        function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
            return true;
        }
        function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "Decreased allowance below zero"));
            return true;
        }
        //
        // Disabled, as it is not useful / is not needed and  
        // to minimize the confusion with the total Project Fee
        //
        //function totalFees() public view returns (uint256) {
        //    return _tFeeTotal;
        //}
        function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
            require(tAmount <= _tTotal, "Amount must be less than supply");
            if (!deductTransferFee) {
                (uint256 rAmount,,,,,) = _getValues(tAmount);
                return rAmount;
            } else {
                (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
                return rTransferAmount;
            }
        }
        function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
            require(rAmount <= _rTotal, "Amount must be less than total reflections");
            uint256 currentRate =  _getRate();
            return rAmount.div(currentRate);
        }
        function _approve(address owner, address spender, uint256 amount) private {
            require(owner != address(0));
            require(spender != address(0));

            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
        function _transfer(
            address from,
            address to,
            uint256 amount
        ) private {
            require(from != address(0));
            require(to != address(0));
            require(amount > 0);
            require(!isBlacklisted[from]);
            require(!isBlacklisted[to]);
            require(from != Security_Manager || to != Security_Manager, "Security personnel is not allowed to trade");
            require(!Security_Admin[from] || !Security_Admin[to] , "Security personnel is not allowed to trade");
            require(Public_Trading_Enabled || 
                    isExcludedFromFees[from] || isExcludedFromFees[to], "Public Trading has not been enabled yet.");


            if (from != CEO && to != CEO && !isExcludedFromFees[from] && !isExcludedFromFees[to]) {

                if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                    ProjectFee = Buy_ProjectFee; 
                    ReflectionsFee  = Buy_ReflectionsFee;
                    is_Buy_Trade = true;

                } else if (to == uniswapV2Pair) {
                        require(!BridgeOrExchange[from]);
                        if (normal_waiting_time_between_sells > 0 || waiting_time_to_sell_after_impact2 > 0) {
                            require(block.timestamp > sell_AllowedTime[from]);
                        }

                        if (price_impact1 != 0){
                        
                            if (amount < balanceOf(uniswapV2Pair).div(10000).mul(price_impact1)) {
                                ProjectFee = Sell_ProjectFee_Under_Impact1;
                                ReflectionsFee  = Sell_ReflectionsFee_Under_Impact1;

                            } else if (price_impact2 == 0){
                                ProjectFee = Sell_ProjectFee_Above_Impact1;
                                ReflectionsFee  = Sell_ReflectionsFee_Above_Impact1;

                            } else if (amount < balanceOf(uniswapV2Pair).div(10000).mul(price_impact2 )) {
                                ProjectFee = Sell_ProjectFee_Above_Impact1;
                                ReflectionsFee  = Sell_ReflectionsFee_Above_Impact1;

                            } else {
                                ProjectFee = Sell_ProjectFee_Above_Impact2;
                                ReflectionsFee  = Sell_ReflectionsFee_Above_Impact2;
                                Impact2_Sell = true;
                            }

                        } else {
                            // If price impact1 is zero then the price impacts   
                            // feature is disabled. And default fees are used.   
                            ProjectFee = Sell_ProjectFee_If_Impacts_Not_Used;
                            ReflectionsFee  = Sell_ReflectionsFee_If_Impacts_Not_Used;
                    }
                    is_Sell_Trade = true;

                } else if (from != uniswapV2Pair && to != uniswapV2Pair) {

                    if (BridgeOrExchange[from]) {
                            ProjectFee = BridgeOrExchange_ProjectFee[from];
                            ReflectionsFee  = BridgeOrExchange_ReflectionsFee[from];
                    }
                    else if (BridgeOrExchange[to]) {
                            ProjectFee = BridgeOrExchange_ProjectFee[to];
                            ReflectionsFee  = BridgeOrExchange_ReflectionsFee[to];
                    }
                    else {
                            ProjectFee = Transfer_ProjectFee; 
                            ReflectionsFee  = Transfer_ReflectionsFee;

                            // To prevent evading the sell waiting time by sending tokens 
                            // to another wallet and then selling from the other wallet we
                            // set the (same) sell waiting time also for the other wallet.
                            if (normal_waiting_time_between_sells > 0 || waiting_time_to_sell_after_impact2 > 0)  {
                            sell_AllowedTime[to] = sell_AllowedTime[from];
                            }
                    }
                }
            }
            uint256 contractTokenBalance = balanceOf(address(this));

            // ProjectFundingSwap i.e. selling done by the token contract 
            // is purposely set not be executed during a buy trade. We have
            // observed that if/when the contract sells immediately after 
            // a buy trade it may look like there is a bot that is constantly
            // selling on people buys.    
            bool overMinTokenBalance = contractTokenBalance >= minAmountTokens_ProjectFundingSwap;
            if (
                overMinTokenBalance &&
                !Project_Funding_Swap_Mode && 
                from != uniswapV2Pair 
            ) {
                projectFundingSwap(contractTokenBalance);
            }        

            bool takeAllFees = true;
            
            if(isExcludedFromFees[from] || isExcludedFromFees[to]) {
                takeAllFees = false;
            }

            if (Discount_Contract != address(0)) {
                uint256 ProjectFee_Discount;
                if (is_Buy_Trade) {
                    ProjectFee_Discount = Discount_Interface(Discount_Contract).Get_Project_Fee_Discount(1, from);
                } else if (is_Sell_Trade && !Impact2_Sell) {
                    // Price impact2 gets no discount
                    ProjectFee_Discount = Discount_Interface(Discount_Contract).Get_Project_Fee_Discount(2, from);
                }
                if (ProjectFee >= ProjectFee_Discount) {
                ProjectFee = ProjectFee - ProjectFee_Discount;
                }
            }

            // If it is a new token holder, that is buying or 
            // is getting its first tokens by a normal transfer
            // then start the time for the Loyalty Points program
            if (balanceOf(from) == 0) {
                Loyalty_StartTime[from] = block.timestamp;
                Previous_SellTime[from] = block.timestamp;
            }
            else if (balanceOf(to) == 0 ) {
                Loyalty_StartTime[to] = block.timestamp;
                Previous_SellTime[to] = block.timestamp;
            }

            _tokenTransfer(from,to,amount,takeAllFees);
            restoreAllFees;

            if (is_Sell_Trade) {
                if (Impact2_Sell) {
                    uint256 New_Timestamp;
                    if (waiting_time_to_sell_after_impact2 > 0) {
                        New_Timestamp = block.timestamp + waiting_time_to_sell_after_impact2;
                    } else if (normal_waiting_time_between_sells > 0 ) {
                        New_Timestamp = block.timestamp + normal_waiting_time_between_sells; 
                    } else {
                        New_Timestamp = block.timestamp;
                    }
                    sell_AllowedTime[from]  = New_Timestamp;
                    // Also will not accumulate loyalty time
                    Previous_SellTime[from] = New_Timestamp;
                    Loyalty_StartTime[from] = New_Timestamp;
                    emit Impact2_Sell_Allowed_Time_Next_Sell(from, sell_AllowedTime[from]);
                    Impact2_Sell = false;
                }
                else if (normal_waiting_time_between_sells > 0 ) {
                    sell_AllowedTime[from] = block.timestamp + normal_waiting_time_between_sells;
                }                                                                                                                        
            }

            if (!is_Buy_Trade && !Impact2_Sell) {
                if (Loyalty_Days_Loss_When_Sell_Or_Move_Tokens != 0) {
                    uint256 Loyalty_Seconds_Loss = Loyalty_Days_Loss_When_Sell_Or_Move_Tokens * 86400;
                    uint256 Current_Loyalty_Seconds = block.timestamp - Previous_SellTime[from];
                    if (Current_Loyalty_Seconds < Loyalty_Seconds_Loss) {
                        Loyalty_StartTime[from] = Loyalty_StartTime[from] + Loyalty_Seconds_Loss;
                    }
                    Previous_SellTime[to] = block.timestamp;
                }
            }

            // Resetting these to make sure that _takeProjectFee works as  
            // intended for a non-trade transfer after a buy or a sell.
            if (is_Sell_Trade) { is_Sell_Trade = false;}
            else if (is_Buy_Trade) {is_Buy_Trade = false;}
        }

        function projectFundingSwap(uint256 contractTokenBalance) private lockTheSwap {
            
            // Check tokens in contract
            uint256 tokensbeforeSwap = contractTokenBalance;
            
            // Swap tokens for BNB
            swapTokensForBNB(tokensbeforeSwap);
            
            uint256 BalanceBNB = address(this).balance;

            // Calculate BNB for each Project funding wallet
            uint256 productDevelopmentBNB = BalanceBNB.div(100).mul(ProductDevelopmentFee);
            uint256 marketingBNB = BalanceBNB.div(100).mul(MarketingFee);
            uint256 blockchainSupportBNB = BalanceBNB.div(100).mul(BlockchainSupportFee);
            uint256 reservaBNB = BalanceBNB.div(100).mul(ReservaFee);     

        // Send BNB to Project funding wallets 
            payable(productDevelopmentWallet).transfer(productDevelopmentBNB);
            payable(marketingWallet).transfer(marketingBNB);
            payable(blockchainSupportWallet).transfer(blockchainSupportBNB); 
            payable(reservaWallet).transfer(reservaBNB); 

            emit Project_Funding_Done(tokensbeforeSwap, BalanceBNB);  
        }

        function swapTokensForBNB(uint256 tokenAmount) private {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            _approve(address(this), address(uniswapV2Router), tokenAmount);

            // make the swap
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0, // accept any amount of ETH
                path,
                address(this),
                block.timestamp
            );
        }
        function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
            // approve token transfer to cover all possible scenarios
            _approve(address(this), address(uniswapV2Router), tokenAmount);
            // add the liquidity
            uniswapV2Router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                CEO,
                block.timestamp
            );
        }
        function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeAllFees) private {
            if(!takeAllFees)
                removeAllFees();
            
            if (isExcludedReflections[sender] && !isExcludedReflections[recipient]) {
                _transferFromExcluded(sender, recipient, amount);
            } else if (!isExcludedReflections[sender] && isExcludedReflections[recipient]) {
                _transferToExcluded(sender, recipient, amount);
            } else if (!isExcludedReflections[sender] && !isExcludedReflections[recipient]) {
                _transferStandard(sender, recipient, amount);
            } else if (isExcludedReflections[sender] && isExcludedReflections[recipient]) {
                _transferBothExcluded(sender, recipient, amount);
            } else {
                _transferStandard(sender, recipient, amount);
            }
            
            if(!takeAllFees)
                restoreAllFees();
        }
        function _transferStandard(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
            _takeProjectFee(tLiquidity);
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }
        function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
            _takeProjectFee(tLiquidity);
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }
        function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
            _takeProjectFee(tLiquidity);
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }
        function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
            _takeProjectFee(tLiquidity);
            _reflectFee(rFee, tFee);
            emit Transfer(sender, recipient, tTransferAmount);
        }
        function _reflectFee(uint256 rFee, uint256 tFee) private {
            _rTotal = _rTotal.sub(rFee);
            _tFeeTotal = _tFeeTotal.add(tFee);
        }
        function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
            (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
            return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
        }
        function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
            uint256 tFee = calculateReflectionsFee(tAmount);
            uint256 tLiquidity = calculateProjectFee(tAmount);
            uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
            return (tTransferAmount, tFee, tLiquidity);
        }
        function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
            uint256 rAmount = tAmount.mul(currentRate);
            uint256 rFee = tFee.mul(currentRate);
            uint256 rLiquidity = tLiquidity.mul(currentRate);
            uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
            return (rAmount, rTransferAmount, rFee);
        }
        function _getRate() private view returns(uint256) {
            (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
            return rSupply.div(tSupply);
        }
        function _getCurrentSupply() private view returns(uint256, uint256) {
            uint256 rSupply = _rTotal;
            uint256 tSupply = _tTotal;      
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
                rSupply = rSupply.sub(_rOwned[_excluded[i]]);
                tSupply = tSupply.sub(_tOwned[_excluded[i]]);
            }
            if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
            return (rSupply, tSupply);
        }    
        function _takeProjectFee(uint256 tLiquidity) private {
            uint256 currentRate =  _getRate();
            uint256 rLiquidity = tLiquidity.mul(currentRate);
            if (is_Buy_Trade || is_Sell_Trade) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
                if(isExcludedReflections[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity); 
            } else {
                _rOwned[address(communityBeneficialWallet)] = _rOwned[address(communityBeneficialWallet)].add(rLiquidity);
                emit Transfer_Fee_Tokens_Sent_To_Community_Beneficial_Wallet(communityBeneficialWallet, rLiquidity);

                if(isExcludedReflections[address(communityBeneficialWallet)])
                _tOwned[address(communityBeneficialWallet)] = _tOwned[address(communityBeneficialWallet)].add(tLiquidity); 
                emit Transfer_Fee_Tokens_Sent_To_Community_Beneficial_Wallet(communityBeneficialWallet, tLiquidity);
            }
        }
        function calculateReflectionsFee(uint256 _amount) private view returns (uint256) {
            return _amount.mul(ReflectionsFee).div(100);
        }    
        function calculateProjectFee(uint256 _amount) private view returns (uint256) {
            return _amount.mul(ProjectFee).div(100);
        }    
        function removeAllFees() private {
            if(ReflectionsFee == 0 && ProjectFee == 0) return;
            
            previous_ReflectionsFee = ReflectionsFee;
            previous_ProjectFee = ProjectFee;
            
            ReflectionsFee = 0;
            ProjectFee = 0;
        }    
        function restoreAllFees() private {
            ReflectionsFee = previous_ReflectionsFee;
            ProjectFee = previous_ProjectFee;
        }

        //Enable BNB
        receive() external payable {}   


        function Is_Public_Trading_Enabled() public view returns (bool) {
            return Public_Trading_Enabled;
        }
        function Amount_Marketing_Managers() public view returns (uint256) {
            return Marketing_Managers_Count;
        }
        function Amount_Blockchain_Managers() public view returns (uint256) {
            return Blockchain_Managers_Count;
        }
        function Sell_Normal_Waiting_Time_Between_Sells() public view returns (uint256) {
            return normal_waiting_time_between_sells;
        }
        function Sell_Waiting_Time_After_Impact2() public view returns (uint256) {
            return waiting_time_to_sell_after_impact2;
        }
        function Sell_Price_Impact1__Multiplied_by_100() public view returns (uint256) {
            return price_impact1;
        }
        function Sell_Price_Impact2__Multiplied_by_100() public view returns (uint256) {
            return price_impact2;
        }
        function Transfer_Project_Fee_() public view returns (uint256) {
            return Transfer_ProjectFee;
        }
        function Buy_Project_Fee() public view returns (uint256) {
            return Buy_ProjectFee;
        }
        function Sell_Project_Fee_Under_Impact1() public view returns (uint256) {
            return Sell_ProjectFee_Under_Impact1;
        }
        function Sell_Project_Fee_Above_Impact1() public view returns (uint256) {
            return Sell_ProjectFee_Above_Impact1;
        }
        function Sell_Project_Fee_Above_Impact2() public view returns (uint256) {
            return Sell_ProjectFee_Above_Impact2;
        }
        function Sell_Project_Fee_If_Impacts_Not_Used() public view returns (uint256) {
            return Sell_ProjectFee_If_Impacts_Not_Used;
        }
        function Transfer_Reflections_Fee() public view returns (uint256) {
            return Transfer_ReflectionsFee;
        }
        function Buy_Reflections_Fee() public view returns (uint256) {
            return Buy_ReflectionsFee;
        }
        function Sell_Reflections_Fee_Under_Impact1() public view returns (uint256) {
            return Sell_ReflectionsFee_Under_Impact1;
        }
        function Sell_Reflections_Fee_Above_Impact1() public view returns (uint256) {
            return Sell_ReflectionsFee_Above_Impact1;
        }
        function Sell_Reflections_Fee_Above_Impact2() public view returns (uint256) {
            return Sell_ReflectionsFee_Above_Impact2;
        }
        function Sell_Reflections_Fee_If_Impacts_Not_Used() public view returns (uint256) {
            return Sell_ReflectionsFee_If_Impacts_Not_Used;
        }
        function Product_Development_Fee_Portion() public view returns (uint256) {
            return ProductDevelopmentFee;
        }
        function Marketing_Fee_Portion() public view returns (uint256) {
            return MarketingFee;
        }
        function Blockchain_Support_Fee_Portion() public view returns (uint256) {
            return BlockchainSupportFee;
        }
        function Reserva_Fee_Portion() public view returns (uint256) {
            return ReservaFee;
        }
        function Product_Development_Wallet() public view returns (address) {
            return productDevelopmentWallet;
        }
        function Marketing_Wallet() public view returns (address) {
            return marketingWallet;
        }
        function Blockchain_Support_Wallet() public view returns (address) {
            return blockchainSupportWallet;
        }
        function Reserva_Wallet() public view returns (address) {
            return reservaWallet;
        }    
        function Community_Beneficial_Wallet() public view returns (address) {
            return communityBeneficialWallet;
        }
        function Min_Amount_Tokens_for_Project_Funding_Swap() public view returns (uint256) {
            return minAmountTokens_ProjectFundingSwap;
        }
        function Loyalty_Days_Loss_If_Sell_Or_Move_Tokens() public view returns (uint256) {
            return Loyalty_Days_Loss_When_Sell_Or_Move_Tokens;
        }
        function Project_Fee_Discount_Contract() public view returns (address) {
            return Discount_Contract;
        }

        //***************  Show Loyalty Points  ***************//

        function A1_Show_Loyalty_Points(address account) public view returns(string memory, uint256, string memory, uint256, string memory, uint256) {
            require (balanceOf(account) > 0, "Account has no tokens / must own tokens");
            uint256 Loyalty_Duration_Seconds;
            uint256 Loyalty_Duration_Days;
            uint256 Loyalty_Points;
            string memory Message1 = "Loyalty Start Time (Unix Timestamp):";
            string memory Message2 = "Loyalty Days:";
            string memory Message3 = "Loyalty Points:"; 

            if (Loyalty_StartTime[account] < block.timestamp) {
                Loyalty_Duration_Seconds = block.timestamp - Loyalty_StartTime[account];
                Loyalty_Duration_Days = Loyalty_Duration_Seconds / 1 days;
                Loyalty_Points = Loyalty_Duration_Days * 1000;
            } else {
                Loyalty_Duration_Days = 0;
                Loyalty_Points = 0; 
            }
            return (Message1, Loyalty_StartTime[account], Message2, Loyalty_Duration_Days, Message3, Loyalty_Points);
        }

        //*******************  Security  *******************//

        function F01_Security_Check(address account) external view returns (bool) {
            // True - account is blacklisted
            // False -  account is not blacklisted   
            return isBlacklisted[account];
        }
        function F02_Blacklist_Malicious_Account(address account) external ExceptAccounts(account) onlySecurityAdmin {
            require(!isBlacklisted[account], "Address is already blacklisted");	
            isBlacklisted[account] = true;
        }
        function F03_Whitelist_Account(address account) external onlySecurityAdmin {
            require(isBlacklisted[account], "Address is already whitelisted");
            isBlacklisted[account] = false;
        }
        function F04_Add_Security_Admin(address account) external onlySecurityAdmin {
            // Maximum two accounts are allowed.
            // When adding the first Security Admin account 
            // or if e.g. both Security Admin accounts have  
            // been removed then use the Security Manager to 
            // add a Security Admin account.
            require(!Security_Admin[account],"Security Admin already added");
            require(account != CEO);
            require(account != Security_Manager);
            require(!Marketing_Manager[account]);
            require(!Blockchain_Manager[account]);
            require(Amount_Security_Admins < 2, "Max two accounts are allowed and have been already added");
            
            Security_Admin[account] = true;
            Amount_Security_Admins++;
            emit Added_Security_Admin(account);
        }
        function F05_Remove_Security_Admin(address account) external onlySecurityAdmin {
            require(Security_Admin[account],"The account is not registered in the contract");
            Security_Admin[account] = false;
            Amount_Security_Admins--;
            emit Removed_Security_Admin(account);
        }
        function F06_Check_if_is_Security_Admin(address account) external view returns (string memory, string memory, uint256) {   
            string memory Message1;
            string memory Message2;

            if (Security_Admin[account]) {
                Message1 =" The account is a Security Admin account";
            } else {
                Message1 =" The account is NOT a Security Admin account";
            }
            Message2 = " Current amount Security Admins (max 2 is allowed):";

            return (Message1, Message2, Amount_Security_Admins);
        }
        function F07_Change_Security_Manager(address New_Security_Manager)  public virtual onlySecurityManager {
            require(New_Security_Manager != address(0));
            require(New_Security_Manager != address(this)); 
            require(New_Security_Manager != CEO);
            require(!Security_Admin[New_Security_Manager]);
            address Previous_Security_Manager = Security_Manager;
            Security_Manager = New_Security_Manager;
            emit Changed_Security_Manager(Previous_Security_Manager, New_Security_Manager);
        }
        function F08_Change_CEO(address New_CEO) public virtual onlySecurityAdmin {
            require(New_CEO != address(0));
            require(New_CEO != address(this)); 
            require(New_CEO != Security_Manager);
            require(!Security_Admin[New_CEO]);
            address Previous_CEO = CEO;
            CEO = New_CEO;
            isExcludedFromFees[New_CEO] = true;
            isExcludedFromFees[Previous_CEO] = false;
            emit CEO_Changed(Previous_CEO, New_CEO);
        }

        //************  Enable or Disable Trading  ***************//
        
        function F09_Enable_Public_Trading() external onlySecurityAdmin {
            Public_Trading_Enabled = true;
        }
        function F10_Disable_Public_Trading() external onlySecurityAdmin {
            Public_Trading_Enabled = false;
        }

        //*************  Waiting times for sells  ***************//

        function F11_Check_When_Account_Can_Sell_Again(address account) external view returns (string memory, uint256) {
            // If the parameter "normal_waiting_time_between_sells" or 
            // "waiting_time_to_sell_after_impact2" is non zero 
            // then the waiting time between sells feature is enabled. 
            // If so then this function can be used then to check when
            // is the earliest time that an account can sell again.
            require (balanceOf(account) > 0, "Account has no tokens");  

            string memory Message;

            if ( block.timestamp >= sell_AllowedTime[account]) {
                    Message = " The account can sell anytime.";                  
            } else {
                    Message = " Be patient, please." 
                            " The account cannot sell until the time shown below."
                            " The time is in Unix format. Use free online time conversion"
                            " websites/services to convert to common Date and Time format";
            }
            return (Message, sell_AllowedTime[account]);
        }
        function F12_Shorten_Account_Waiting_Time_Before_Next_Sell(address account, uint256 unix_time) external onlySecurityAdmin {
            // Tips:  To allow selling immediately set --> unix_time = 0
            //
            //        When setting it to non zero then use free online 
            //        time conversion website/services to convert
            //        to Unix time the new allowed sell date and time.
            require (block.timestamp < sell_AllowedTime[account], 
                    "The account can already sell at any time"); 
            require (unix_time < sell_AllowedTime[account], 
                    "The time must be earlier than currently allowed sell time");
            sell_AllowedTime[account] = unix_time;
        }
        function F13_Set_Normal_Waiting_Time_Between_Sells(uint256 wait_seconds) external onlySecurityAdmin {
            // Examples: 
            // To have a 60 seconds wait --> wait_seconds = 60
            //
            // To disable this feature i.e. to have no waiting
            // time then set this to zero --> wait_seconds = 0
            require (wait_seconds <= waiting_time_to_sell_after_impact2 || waiting_time_to_sell_after_impact2 == 0,
                    "The normal waiting time cannot be larger than waiting time after price impact2");
            normal_waiting_time_between_sells = wait_seconds;
        }
        function F14_Set_Waiting_Time_For_Next_Sell_After_Impact2(uint256 wait_seconds) external onlySecurityAdmin {
            // Requires price_impact2 to be non zero. 
            // And a longer waiting time than the normal wating time  
            require (price_impact2 > 0,
                    "The waiting time after impact2 cannot be set when price_impact2 is 0");
            require (wait_seconds >= normal_waiting_time_between_sells,
                    "The waiting time after impact2 cannot be less than normal waiting time");
            //
            //Examples:   Must wait 3 days --> wait_seconds = 259200
            //                      7 days --> wait_seconds = 604800
            //
            // To disable this longer waiting time after a
            // sell with price impact2 then set this to zero --> wait_seconds = 0
            // 
            // If so then the normal waiting if it is non zero  
            // it will be used for all sells with price impact2. 
            waiting_time_to_sell_after_impact2 = wait_seconds;
        }

        //*************  Price impacts feature  ****************//

        function F15_Set_Sell_Price_Impact1__Multiplied_by_100(uint256 Price_impact1) external onlySecurityAdmin {
            require (Price_impact1 < price_impact2 || price_impact2 == 0, 
                    "Price impact1 cannot be larger than price impact2");
            // To support a percentage number with a decimal
            // the percentage is / must be multiplied by 100.
            //
            // Examples:  1% price impact --> Price_impact1 = 100
            //          0.5% price impact --> Price_impact1 =  50
            //
            price_impact1 = Price_impact1; 
            // 
            // If set to 0 then the price impact(s) feature will
            // be disabled entirely i.e. for both impact tiers 
            if (Price_impact1 == 0 && price_impact2 != 0){
                price_impact2 = 0;
                waiting_time_to_sell_after_impact2 = 0;
            }
        }
        function F16_Set_Sell_Price_Impact2__Multiplied_by_100(uint256 Price_impact2) external onlySecurityAdmin {
            // Price impact2 can be used only if 
            // price impact1 is non zero / is used.
            require (price_impact1 != 0 && Price_impact2 > price_impact1 || Price_impact2 == 0, 
                    "Price impact2 cannot be less than price impact1"); 
            //
            // Examples:  20% price impact --> Price_impact2 = 2000
            //            30% price impact --> Price_impact2 = 3000
            //
            // To disable the price impact2 tier --> Price_impact2 = 0
            price_impact2 = Price_impact2;       
            if (Price_impact2 == 0 && waiting_time_to_sell_after_impact2 != 0){
                waiting_time_to_sell_after_impact2 = 0;
            }
        }

        //***************  Total Project Fees  *****************//

        function F17_Set_Project_Fee_Discount_Contract(address external_contract) external onlySecurityAdmin {
            // To disable the discount feature 
            // use the zero contract address: 
            // external_contract = 0x0000000000000000000000000000000000000000
            //  
            Discount_Contract = external_contract;
        }
        function F18_Set_Project_Fee_For_Transfers(uint256 fee_percent) external onlySecurityAdmin {
            // Set Project fee for a (normal) transfer between two wallets.
            Transfer_ProjectFee = fee_percent;
        }
        function F19_Set_Project_Fee_For_Buys(uint256 fee_percent) external onlySecurityAdmin {
            Buy_ProjectFee = fee_percent;
        }
        function F20_Set_Project_Fee_For_Sells_Under_Impact1(uint256 fee_percent) external onlySecurityAdmin {
            require (fee_percent <= Sell_ProjectFee_Above_Impact1 || Sell_ProjectFee_Above_Impact1 == 0,
                    "The fee under price impact1 cannot be larger than the fee above price impact1");
            Sell_ProjectFee_Under_Impact1 = fee_percent;
            if (Sell_ProjectFee_Above_Impact1 == 0) {
            Sell_ProjectFee_Above_Impact1 = fee_percent;
            }
            if (Sell_ProjectFee_Above_Impact2 == 0) {
            Sell_ProjectFee_Above_Impact2 = fee_percent;
            }
        }
        function F21_Set_Project_Fee_For_Sells_Above_Impact1(uint256 fee_percent) external onlySecurityAdmin {
            require (fee_percent >= Sell_ProjectFee_Under_Impact1,
                    "The fee above price impact1 cannot be less than the fee under price impact1");
            require (fee_percent <= Sell_ProjectFee_Above_Impact2 || Sell_ProjectFee_Above_Impact2 == 0,
                    "The fee above price impact1 cannot more than the fee above price impact2");
            Sell_ProjectFee_Above_Impact1 = fee_percent;
            if (Sell_ProjectFee_Above_Impact2 == 0) {
                Sell_ProjectFee_Above_Impact2 = fee_percent;  
            }
        }
        function F22_Set_Project_Fee_For_Sells_Above_Impact2(uint256 fee_percent) external onlySecurityAdmin { 
            require (fee_percent >= Sell_ProjectFee_Above_Impact1,
                    "The fee above price impact2 can not be less than the fee above price impact1");  
            Sell_ProjectFee_Above_Impact2 = fee_percent;
        }
        function F23_Set_Project_Fee_For_Sells_if_Impacts_Not_Used(uint256 fee_percent) external onlySecurityAdmin {
            // The Total Project fee for sells  
            // if the price impacts feature is disabled 
            // (i.e. if price impact1 and price impact2 are zero) 
            Sell_ProjectFee_If_Impacts_Not_Used = fee_percent;
        }
            
        //************  Reflection fees  ***************//
        
        function F24_Set_Reflections_Fee_For_Transfers(uint256 fee_percent) external onlySecurityAdmin {
            // Set reflections fee for normal transfers between wallets
            Transfer_ReflectionsFee = fee_percent;
        }
        function F25_Set_Reflections_Fee_For_Buys(uint256 fee_percent) external onlySecurityAdmin {
            Buy_ReflectionsFee = fee_percent;
        }    
        function F26_Set_Reflections_Fee_For_Sells_Under_Impact1(uint256 fee_percent) external onlySecurityAdmin {
            require (fee_percent <= Sell_ReflectionsFee_Above_Impact1 || Sell_ReflectionsFee_Above_Impact1 == 0,
                    "The fee under price impact1 cannot be larger than the fee above price impact1");
            Sell_ReflectionsFee_Under_Impact1 = fee_percent;
            if (Sell_ReflectionsFee_Above_Impact1 == 0) {
            Sell_ReflectionsFee_Above_Impact1 = fee_percent;
            }
            if (Sell_ReflectionsFee_Above_Impact2 == 0) {
            Sell_ReflectionsFee_Above_Impact2 = fee_percent;
            }
        }
        function F27_Set_Reflections_Fee_For_Sells_Above_Impact1(uint256 fee_percent) external onlySecurityAdmin { 
            require (fee_percent >= Sell_ReflectionsFee_Under_Impact1,
                    "The fee above price impact1 cannot be less than the fee under price impact1");
            require (fee_percent <= Sell_ReflectionsFee_Above_Impact2 || Sell_ReflectionsFee_Above_Impact2 == 0,
                    "The fee above price impact1 cannot more than the fee above price impact2");
            Sell_ReflectionsFee_Above_Impact1 = fee_percent;
            if (Sell_ReflectionsFee_Above_Impact2 == 0) {
                Sell_ReflectionsFee_Above_Impact2 = fee_percent;
            }
        }
        function F28_Set_Reflections_Fee_For_Sells_Above_Impact2(uint256 fee_percent) external onlySecurityAdmin {
            require (fee_percent >= Sell_ReflectionsFee_Above_Impact1,
                    "The fee above price impact2 can not be less than the fee above price impact1");  
            Sell_ReflectionsFee_Above_Impact2 = fee_percent;
        }
        function F29_Set_Reflections_Fee_For_Sells_if_Impacts_Not_Used(uint256 fee_percent) external onlySecurityAdmin {
            // This Reflections fee is used if 
            // the price impacts feature is disabled 
            // (i.e. if price impact1 and price impact2 are zero)
            Sell_ReflectionsFee_If_Impacts_Not_Used = fee_percent;
        }

        //************  Total Project fee split in portions  **************// 
    
        function F30_Set_Product_Development_Fee_Portion(uint256 fee_percent) external onlyCEO {
            // Example: 25% of total Project Fee --> fee_percent = 25
            // IMPORTANT: 
            // ProductDevelopmentFee + MarketingFee + BlockchainSupportFee + ReservaFee = 100

            uint256 Total_All_Portions =  fee_percent + MarketingFee + BlockchainSupportFee + ReservaFee;
            require(Total_All_Portions <= 100, 
            "The sum of all fees portions must be less or equal 100");
            ProductDevelopmentFee = fee_percent;
        }
        function F31_Set_Marketing_Fee_Portion(uint256 fee_percent) external onlyMarketingManager {
            // Example: 25% of total Project Fee --> fee_percent = 25
            // IMPORTANT: 
            // ProductDevelopmentFee + MarketingFee + BlockchainSupportFee + ReservaFee = 100

            uint256 Total_All_Portions =  ProductDevelopmentFee + fee_percent + BlockchainSupportFee + ReservaFee;
            require(Total_All_Portions <= 100, 
            "The sum of all fees portions must be less or equal 100");
            MarketingFee = fee_percent;
        }
        function F32_Set_BlockchainSupport_Fee_Portion(uint256 fee_percent) external onlyBlockchainManager {
            // Example: 25% of total Project Fee --> fee_percent = 25
            // IMPORTANT: 
            // ProductDevelopmentFee + MarketingFee + BlockchainSupportFee + ReservaFee = 100

            uint256 Total_All_Portions =  ProductDevelopmentFee + MarketingFee + fee_percent + ReservaFee;
            require(Total_All_Portions <= 100,
            "The sum of all fees portions must be less or equal 100");
            BlockchainSupportFee = fee_percent;
        }
        function F33_Set_Reserva_Fee_Portion(uint256 fee_percent) external onlySecurityAdmin {
            // Example: 25% of total Project Fee --> fee_percent = 25
            // IMPORTANT: 
            // ProductDevelopmentFee + MarketingFee + BlockchainSupportFee + ReservaFee = 100   
            
            uint256 Total_All_Portions =  ProductDevelopmentFee + MarketingFee + BlockchainSupportFee + fee_percent;        
            require(Total_All_Portions <= 100, 
            "The sum of all fees portions must be less or equal 100");
            ReservaFee = fee_percent;
        }

        //****************************************************************//
        //               Must pay fees / exclude from fees                //
        //         Receive reflections / exclude from reflections         //
        //****************************************************************// 

        function F34_Enable_Account_Must_Pay_Fees(address account) external onlySecurityAdmin {
            // Enable that the account will be charged all fees
            // i.e. it will pay both Project and Reflections fees
            isExcludedFromFees[account] = false;
        }
        function F35_Exclude_Account_From_Paying_Fees(address account) external onlySecurityAdmin {
            // Exempt the account from paying any fees i.e. it
            // will pay 0% fee for both Project and Reflection fees 
            isExcludedFromFees[account] = true;
        }
        function F36_Check_if_Account_is_Excluded_from_Paying_Fees(address account) external view returns(bool) {
            // True  - Account is exemPublic_Trading_Enabledd from paying fees 
            //         i.e. it pays 0% fee for both Project and Reflection fees
            // False - Account is charged all fees 
            //         i.e. it pays both project and reflections fees
            return isExcludedFromFees[account];
        }
        function F37_Check_if_Account_is_Excluded_from_Receiving_Reflections(address account) external view returns (bool) {
            // True  - Account doesn't receive reflections 
            // False - Account receives reflections
            return isExcludedReflections[account];
        }
        function F38_Enable_Account_will_Receive_Reflections(address account) external onlySecurityAdmin {
            require(isExcludedReflections[account]);
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_excluded[i] == account) {
                    _excluded[i] = _excluded[_excluded.length - 1];
                    _tOwned[account] = 0;
                    isExcludedReflections[account] = false;
                    _excluded.pop();
                    break;
                }
            }
        }
        function F39_Exclude_Account_from_Receiving_Reflections(address account) external onlySecurityAdmin {
            // Account will not receive reflections
            require(!isExcludedReflections[account], "Account is already excluded");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            isExcludedReflections[account] = true;
                _excluded.push(account);
        }   

        //****************  Project specific wallets  ******************//

        function F40_Set_Product_Development_Wallet(address account) external onlyCEO {
            productDevelopmentWallet = account;
        }
        function F41_Set_Marketing_Wallet(address account) external onlyMarketingManager {
            marketingWallet = account;
        }
        function F42_Set_Blockchain_Support_Wallet(address account) external onlyBlockchainManager {
            blockchainSupportWallet = account;
        }
        function F43_Set_Reserva_Wallet(address account) external onlySecurityAdmin {
            // Use a Multisig wallet, e.g Gnosis Safe
            reservaWallet = account;
        }
        function F44_Set_Community_Beneficial_Wallet(address account) external onlyCEO {
            // The contract uses this wallet to send to this wallet    
            // tokens from the charged Project fee for normal transfers
            communityBeneficialWallet = account;
        }  

        //************  Marketing Manager account  *************//

        function F45_Add_Marketing_Manager(address account) external {
            require(!Security_Admin[account], "Security personnel cannot have other roles");
            require(account != Security_Manager, "Security personnel cannot have other roles");
            require(!Marketing_Manager[account],"Marketing Manager already added");   
            require(Marketing_Managers_Count < 2, "Max two accounts are allowed and have been already added");
            
            if (Marketing_Managers_Count == 0) {
                require(Security_Admin[msg.sender] || Security_Manager == msg.sender);
            }
            else {require(Marketing_Manager[msg.sender]);}
            
            Marketing_Manager[account] = true;
            Marketing_Managers_Count++;
            emit Added_Marketing_Manager(account);
        }
        function F46_Remove_Marketing_Manager(address account) external onlyMarketingManager {
            require(Marketing_Manager[account],"The account is not registered in the contract");
            Marketing_Manager[account] = false;
            Marketing_Managers_Count--;
            emit Removed_Marketing_Manager(account);
        }
        function F47_Check_if_is_Marketing_Manager(address account) external view returns (bool) {   
            return Marketing_Manager[account];
        }


        //*************  Blockchain Manager account  **************//

        function F48_Add_Blockchain_Manager(address account) external {
            require(!Security_Admin[account], "Security personnel cannot have other roles");
            require(account != Security_Manager, "Security personnel cannot have other roles");
            require(!Blockchain_Manager[account],"Blockchain Manager already added");   
            require(Blockchain_Managers_Count < 2, "Max two accounts are allowed and have been already added");

            if (Blockchain_Managers_Count == 0) {
                require(Security_Admin[msg.sender] || Security_Manager == msg.sender);
            }
            else {require(Blockchain_Manager[msg.sender]);}
            
            Blockchain_Manager[account] = true;
            Blockchain_Managers_Count++;
            emit Added_Blockchain_Manager(account);
        }
        function F49_Remove_Blockchain_Manager(address account) external onlyBlockchainManager {
            require(Blockchain_Manager[account],"The account is not registered in the contract");
            Blockchain_Manager[account] = false;
            Blockchain_Managers_Count--;
            emit Removed_Blockchain_Manager(account);
        }
        function F50_Check_if_is_Blockchain_Manager(address account) external view returns (bool) {   
            return Blockchain_Manager[account];
        }

        //***************  Bridges and Exchanges  ****************// 

        function F51_Add_Bridge_Or_Exchange(address account, uint256 proj_fee, uint256 reflections_fee) external ExceptAccounts(account) onlySecurityAdmin {
            BridgeOrExchange[account] = true;
            BridgeOrExchange_ProjectFee[account] = proj_fee;
            BridgeOrExchange_ReflectionsFee[account] = reflections_fee;
        }
        function F52_Remove_Bridge_Or_Exchange(address account) external onlySecurityAdmin {
            delete BridgeOrExchange[account];
            delete BridgeOrExchange_ProjectFee[account];
            delete BridgeOrExchange_ReflectionsFee[account];
        }
        function F53_Check_if_is_Bridge_Or_Exchange(address account) external view returns (bool) {
            return BridgeOrExchange[account];
        }
        function F54_Get_Project_Fee_For_Bridge_Or_Exchange(address account) external view returns (uint256) {
            return BridgeOrExchange_ProjectFee[account];
        }
        function F55_Get_Reflections_Fee_For_Bridge_Or_Exchange(address account) external view returns (uint256) {
            return BridgeOrExchange_ReflectionsFee[account];
        }

        //****************  Miscellaneous  ****************//

        function F56_Set_Min_Amount_Tokens_For_ProjectFundingSwap(uint256 amount) external onlySecurityAdmin {
            // Example: 10 tokens --> amount = 100000000 (i.e. 10 * 10**7 decimals) = 0.0002%
            minAmountTokens_ProjectFundingSwap = amount;
        }
        function F57_Rescue_Other_Tokens_Sent_To_This_Contract(IERC20 token, address receiver, uint256 amount) external {
            // This feature is very appreciated:
            // To be able to send back to a user other BEP20 tokens 
            // that the user have sent to this contract by mistake.
            require(CEO == msg.sender || Security_Admin[msg.sender] || Security_Manager == msg.sender);
            require(token != IERC20(address(this)), "Only other tokens can be rescued");
            require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
            require(receiver != address(this));
            require(receiver != address(0));
            token.transfer(receiver, amount);
        }
        function F58_Update_Amount_Loyalty_Days(address account, uint256 amount_days) external {
            require(CEO == msg.sender || Security_Admin[msg.sender] || Security_Manager == msg.sender);
            require (balanceOf(account) > 0, "Account has no tokens");
            uint256 Loyalty_Duration_Seconds = amount_days * 86400;
            uint256 New_Lotalty_Timestamp = block.timestamp - Loyalty_Duration_Seconds; 
            Previous_SellTime[account] = New_Lotalty_Timestamp;
            Loyalty_StartTime[account] = New_Lotalty_Timestamp;
        }
        function F59_Set_Loyalty_Days_Loss_When_Sell_Or_Move_Tokens(uint256 amount_days_loss) external {
            require(CEO == msg.sender || Security_Admin[msg.sender] || Security_Manager == msg.sender);
            Loyalty_Days_Loss_When_Sell_Or_Move_Tokens = amount_days_loss;
        }
    }