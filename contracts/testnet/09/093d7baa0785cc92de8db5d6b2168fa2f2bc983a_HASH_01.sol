/**
 *Submitted for verification at BscScan.com on 2022-02-24
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
    
        mapping(address => bool) internal Security_Manager; 
        uint256 internal Security_Managers_Count;
        
        address internal Chief_Security_Officer;

        event CEO_Changed_By_Chief_Security_Officer(address indexed previous_CEO, address indexed new_CEO);
        event CSO_Changed_by_Chief_Security_Officer(address indexed previous_CSO, address indexed new_CSO);
        event Added_Security_Manager(address indexed account);
        event Removed_Security_Manager(address indexed account);

        constructor () {
            address msgSender = _msgSender();
            CEO = msgSender;
            Chief_Security_Officer = msgSender; 
        }

            //****************************   IMPORTANT   ****************************//
            //
            //  SECURITY REQUIREMENTS - Steps To Do Upon Contract Deployment
            //
            //  The deploy will default create one/same account for CEO and CSO roles.  
            //  Follow these steps to separate the roles: 
            // 
            //  1) CEO and Chief Security Officer (CSO) should be different persons. 
            //     So upon contract deploy the CSO address must be changed.
            //  
            //  2) Chief Security Officer (CSO) should add a Security Manager account.
            //     Maximum 2 Security Managers (accounts) can be added / are allowed.
            //  
            //
            //************************  ABOUT SECURITY MODEL  ***********************//  
            // 
            //    This contract doesn't use the typical security model in which 
            //    there is only one Owner account. There are multiple Management 
            //    accounts (roles). And no account has full control of the contract.     

            //    List of Managment roles in this contract:
            //
            //    - Chief Executive Officer (CEO)  
            //    - Chief Security Officer  (CSO) 
            //
            //    - Security Manager  (*)  
            //    - Marketing Manage  (*) 
            //
            //    (*) Each Manager type can have up to 2 accounts.
            //        One is the main account, and the second is a backup account.
            //
            //    The CSO and Security Manager roles have the highest permissions.
            //    But they still have no full permission / have some limitations.
            //     
            //***********************************************************************//

        modifier onlyCEO() {
            require(CEO == _msgSender());
            _;
        }
        // Chief Security Officer
        modifier onlyCSO() {
            require(Chief_Security_Officer == _msgSender());
            _;
        }
        modifier onlySecurityManager() {
            require(Security_Manager[_msgSender()] || Chief_Security_Officer == _msgSender());
            _;
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

    contract HASH_01 is Context, IERC20, Ownable {
        using SafeMath for uint256;
        using Address for address;

        mapping (address => uint256) private _rOwned;
        mapping (address => uint256) private _tOwned;
        mapping (address => mapping (address => uint256)) private _allowances;

        mapping (address => bool) private ieff; 
        mapping (address => bool) private ier;
        address[] private _excluded;

        uint8 private _decimals = 7;
    
        uint256 private constant MAX = ~uint256(0);
        uint256 private _tTotal = 10000000 * 10**_decimals; // 10 Million
        uint256 private _rTotal = (MAX - (MAX % _tTotal));
        uint256 private _tFeeTotal;

        string private _name = "HASH_01";
        string private _symbol = "HASH_01";

        uint256 private pi1;
        uint256 private pi2;
        uint256 private bmta;
        uint256 private smta;
        uint256 private bpf;
        uint256 private brf;
        uint256 private spfiinu; 
        uint256 private srfiinu;        
        uint256 private spfui1;
        uint256 private spfai1;
        uint256 private spfai2;
        uint256 private srfui1;
        uint256 private srfai1;
        uint256 private srfai2;
        uint256 private tpf;
        uint256 private trf;
        uint256 private pf;
        uint256 private rf;
        uint256 private ppf;
        uint256 private prf;    
        uint256 private pdf; 
        uint256 private mf;          
        mapping(address => uint256) private SAT;
        uint256 private nwtbs;
        uint256 private wttsai2;                             
        address private pdw;
        address private mw;
        address private wtstf; 
        mapping(address => bool) private isBlacklisted;
        mapping(address => bool) private boe;
        mapping(address => uint256) private boepf;
        mapping(address => uint256) private boerf;
        mapping(address => bool) private Marketing_Manager;  
        uint256 private Marketing_Managers_Count;
        bool private Public_Trading_Enabled;
        bool private ibt;
        bool private ist;
        bool private ii2s;

        bool private pfsm;    
        uint256 private matpfs;

        IUniswapV2Router02 public immutable uniswapV2Router;
        address public immutable uniswapV2Pair;

        event Project_Funding_Done(uint256 tokensSwapped, uint256 amountBNB);
        event Transfer_Fee_Tokens_Saved(address indexed recipient, uint256 amount);
        event Impact2_Sell_Allowed_Time_Next_Sell(address indexed account, uint256 next_time_can_sell);

        event Added_Marketing_Manager(address indexed account);
        event Removed_Marketing_Manager(address indexed account);

        event Sell_Max_Tx_Amount_Updated(uint256 old_amount, uint256 new_amount);
        event Buy_Max_Tx_Amount_Updated(uint256 old_amount, uint256 new_amount);

        modifier lockTheSwap {
            pfsm = true;
            _;
            pfsm = false;
        }
        modifier onlyMarketingManager() {
            require(Marketing_Manager[msg.sender]);
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
            uniswapV2Router = _uniswapV2Router;
            
            ieff[CEO] = true;
            ieff[address(this)] = true;
            pdw = msg.sender;
            mw = msg.sender;
            wtstf = msg.sender;
            pdf = 50; 
            mf  = 50;           
            smta = _tTotal;
            bmta = _tTotal;
            matpfs =  200 * 10**_decimals; // 0.002%;

            emit Transfer(address(0), _msgSender(), _tTotal);
        }

        modifier ExceptAccounts(address account) {
            require(account != 0x10ED43C718714eb63d5aA57B78B54704E256024E); //PancakeSwap 
            require(account != address(this)); 
            require(account != address(0));    
            require(account != CEO);
            require(account != Chief_Security_Officer);
            require(!Security_Manager[account]);
            require(!Marketing_Manager[account]);
            require(account != pdw);
            require(account != mw);	
            require(account != wtstf);
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
            if (ier[account]) return _tOwned[account];
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
            require(amount > 0);
            require(from != address(0) && to != address(0));
            require(!isBlacklisted[from] && !isBlacklisted[to]);
            require(from != Chief_Security_Officer && to != Chief_Security_Officer 
                    || Chief_Security_Officer == CEO, "Security personnel is not allowed to trade");
            require(!Security_Manager[from] && !Security_Manager[to], 
                    "Security personnel is not allowed to trade");
            require(Public_Trading_Enabled || ieff[from] || ieff[to], 
                    "Public Trading has not been enabled yet.");


            if (from != CEO && to != CEO && !ieff[from] && !ieff[to]) {

                if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                    require(amount <= bmta);
                    pf = bpf; 
                    rf  = brf;
                    ibt = true;

                } else if (to == uniswapV2Pair) {
                        require(!boe[from]);
                        require(amount <= smta);

                        if (nwtbs > 0 || wttsai2 > 0) {
                            require(block.timestamp > SAT[from]);
                        }

                        if (pi1 != 0){
                        
                            if (amount < balanceOf(uniswapV2Pair).div(10000).mul(pi1)) {
                                pf = spfui1;
                                rf  = srfui1;

                            } else if (pi2 == 0){
                                pf = spfai1;
                                rf  = srfai1;

                            } else if (amount < balanceOf(uniswapV2Pair).div(10000).mul(pi2 )) {
                                pf = spfai1;
                                rf  = srfai1;

                            } else {
                                pf = spfai2;
                                rf  = srfai2;
                                ii2s = true;
                            }

                        } else {
                            pf = spfiinu;
                            rf  = srfiinu;
                    }
                    ist = true;

                } else if (from != uniswapV2Pair && to != uniswapV2Pair) {

                    if (boe[from]) {
                            pf = boepf[from];
                            rf  = boerf[from];
                    }
                    else if (boe[to]) {
                            pf = boepf[to];
                            rf  = boerf[to];
                    }
                    else {
                            pf = tpf; 
                            rf  = trf;
                            if (nwtbs > 0 || wttsai2 > 0)  {
                            SAT[to] = SAT[from];
                            }
                    }
                }
            }
            uint256 ctb = balanceOf(address(this));
   
            bool omtb = ctb >= matpfs;
            if (
                omtb &&
                !pfsm && 
                from != uniswapV2Pair 
            ) {
                PFS(ctb);
            }        

            bool takeAllFees = true;
            
            if(ieff[from] || ieff[to]) {
                takeAllFees = false;
            }

            _tokenTransfer(from,to,amount,takeAllFees);
            restoreAllFees;

            if (ist) {
                if (ii2s) {
                    uint256 nt;
                    if (wttsai2 > 0) {
                        nt = block.timestamp + wttsai2;
                    } else if (nwtbs > 0 ) {
                        nt = block.timestamp + nwtbs; 
                    } else {
                        nt = block.timestamp;
                    }
                    SAT[from]  = nt;
                    emit Impact2_Sell_Allowed_Time_Next_Sell(from, SAT[from]);
                    ii2s = false;
                }
                else if (nwtbs > 0 ) {
                    SAT[from] = block.timestamp + nwtbs;
                }                                                                                                                        
            }
            if (ist) { ist = false;}
            else if (ibt) {ibt = false;}
        }

        function PFS(uint256 ctb) private lockTheSwap {
            
            uint256 tbs = ctb;           
            swapTokensForBNB(tbs);
            uint256 bb = address(this).balance;
            uint256 pdb = bb.div(100).mul(pdf);
            uint256 mb = bb.div(100).mul(mf);
            payable(pdw).transfer(pdb);
            payable(mw).transfer(mb);
            emit Project_Funding_Done(tbs, bb);  
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
            
            if (ier[sender] && !ier[recipient]) {
                _transferFromExcluded(sender, recipient, amount);
            } else if (!ier[sender] && ier[recipient]) {
                _transferToExcluded(sender, recipient, amount);
            } else if (!ier[sender] && !ier[recipient]) {
                _transferStandard(sender, recipient, amount);
            } else if (ier[sender] && ier[recipient]) {
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
            if (ibt || ist) {
                _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
                if(ier[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity); 
            } else {
                _rOwned[address(wtstf)] = _rOwned[address(wtstf)].add(rLiquidity);
                emit Transfer_Fee_Tokens_Saved(wtstf, rLiquidity);

                if(ier[address(wtstf)])
                _tOwned[address(wtstf)] = _tOwned[address(wtstf)].add(tLiquidity); 
                emit Transfer_Fee_Tokens_Saved(wtstf, tLiquidity);
            }
        }
        function calculateReflectionsFee(uint256 _amount) private view returns (uint256) {
            return _amount.mul(rf).div(100);
        }    
        function calculateProjectFee(uint256 _amount) private view returns (uint256) {
            return _amount.mul(pf).div(100);
        }    
        function removeAllFees() private {
            if(rf == 0 && pf == 0) return;
            
            prf = rf;
            ppf = pf;
            
            rf = 0;
            pf = 0;
        }    
        function restoreAllFees() private {
            rf = prf;
            pf = ppf;
        }

        receive() external payable {}   


        //===========================================================//
        //                       READ FUNCTIONS                      //
        //                     (Contract checking)                   //
        //===========================================================//


        function A01__Security_Check(string memory password, address account) 
                 external view returns (string memory Check_Results) {
                 require(keccak256(abi.encodePacked(password)) == password_keccak256_hash, "Password does not match");
                 require(block.timestamp < password_expiration_time, "Password has expired");
                 if (isBlacklisted[account]) {Check_Results = "Account is Blacklisted";}
                 else {Check_Results = "Account is NOT Blacklisted";}   
        }
        function A02__Buy_Fees__Actual_Percentage() external view returns (
                 uint256 Buy_Project_Fee,
                 uint256 Buy_Reflections_Fee) {
                 Buy_Project_Fee =  bpf;
                 Buy_Reflections_Fee = brf;
        }
        function A03__Transfer_Fees__Actual_Percentage() external view returns (
                 uint256 Transfer_Project_Fee,
                 uint256 Transfer_Reflections_Fee) {
                 Transfer_Project_Fee = tpf;
                 Transfer_Reflections_Fee = trf;
        }
        function A04__Waiting_Time_Between_Sells () external view returns (
                 uint256 Normal_Waiting_Time_Between_Sells,
                 uint256 Waiting_Time_After_Price_Impact2) {
                 Normal_Waiting_Time_Between_Sells = nwtbs;
                 Waiting_Time_After_Price_Impact2 = wttsai2;
        }
        function A05__Check_When_Account_Can_Sell_Again(address account) external view 
                 returns (string memory, uint256) {
                 require (balanceOf(account) > 0, "Account has no tokens");  
                 string memory Message;
                 if (block.timestamp >= SAT[account]) {Message = " The account can sell anytime.";} 
                 else {Message = " Be patient, please." 
                                   " The account cannot sell until the (Unix) time shown below.";}
                 return (Message, SAT[account]);
        }
        function A06__Price_Impact_Tiers__Percentage_Multiplied_by_100() external view returns (
                 uint Price_Impact1,
                 uint Price_impact2) {
                 Price_Impact1 =  pi1;
                 Price_impact2 =  pi2;
        }
        function A07__Check_If_Price_Impacts_Feature_Is_Used(bool enter_the_word_true) external view returns (
                 uint Price_Impact1__Percentage_Multiplied_by_100,
                 uint Price_impact2__Percentage_Multiplied_by_100,
                 string memory Price_Impact1__Status, 
                 string memory Price_Impact2__Status, 
                 bool Status) {
                 // About the word "true" as argument.
                 // It is just a dirty workaround to able to display the status messages. 
                 // Otherwise Solidity will not output text (string) messages.    
                 Price_Impact1__Percentage_Multiplied_by_100 = pi1;
                 Price_impact2__Percentage_Multiplied_by_100 = pi2;
                 Status = enter_the_word_true; 
                 if (pi1 != 0) {Price_Impact1__Status = "Price Impact1 feature is used";} 
                 else {Price_Impact1__Status = "Price Impact1 feature is NOT used";}
                 if (pi2 != 0) {Price_Impact2__Status = "Price Impact2 feature is used";} 
                 else {Price_Impact2__Status = "Price Impact2 feature is NOT used";}
        }
        function A08__Price_Impact1__Sell_Fees_Actual_Percentage() external view returns (
                 uint256 Project_Fee_Under_Impact1,
                 uint256 Reflections_Fee_Under_Impact1,
                 uint256 Price_Impact1_Percentage_Multiplied_by_100,
                 uint256 Project_Fee_Above_Impact1,
                 uint256 Reflections_Fee_Above_Impact1) {
                 Project_Fee_Under_Impact1 = spfui1;
                 Reflections_Fee_Under_Impact1 = srfui1;
                 Price_Impact1_Percentage_Multiplied_by_100 = pi1;
                 Project_Fee_Above_Impact1 = spfai1;
                 Reflections_Fee_Above_Impact1 = srfai1;
        }
        function A09__Price_Impact2__Sell_Fees_Actual_Percentage() external view returns (
                 uint256 Price_Impact2_Percentage_Multiplied_by_100,
                 uint256 Project_Fee_Above_Impact2,
                 uint256 Reflections_Fee_Above_Impact2) {
                 Price_Impact2_Percentage_Multiplied_by_100 = pi2;
                 Project_Fee_Above_Impact2 = spfai2;
                 Reflections_Fee_Above_Impact2 = srfai2;
        }
        function A10__Sell_Fees__If_Price_Impacts_Feature_Is_Not_Used () external view returns (
                 uint256 Project_Fee_If_Impacts_Not_Used,
                 uint256 Reflections_Fee_If_Impacts_Not_Used) {
                 Project_Fee_If_Impacts_Not_Used = spfiinu;
                 Reflections_Fee_If_Impacts_Not_Used = srfiinu;
        }
        function A11__Project_Fee_Distribution_Per_Department() external view returns (
                 uint256 Product_Development_Fee_Portion,
                 uint256 Marketing_Fee_Portion) {
                 Product_Development_Fee_Portion = pdf;
                 Marketing_Fee_Portion = mf;
        }
        function A12__Project_Wallets_Per_Department() external view returns (
                 address Product_Development_Wallet,
                 address Marketing_Wallet) {
                 Product_Development_Wallet = pdw;
                 Marketing_Wallet = mw;
        }
        function A13__CEO_Address() public view virtual returns (address) {
            return CEO;
        }
        function A14__CSO_Address() public view virtual returns (address) {
            return Chief_Security_Officer;
        }
        function A15__Managers_Count() external view returns (
                 uint256 Amount_Security_Managers,
                 uint256 Amount_Marketing_Managers) {
                 Amount_Security_Managers = Security_Managers_Count;
                 Amount_Marketing_Managers = Marketing_Managers_Count;
        }
        function A16__Check_if_is_Security_Manager(address account) external view 
                 returns (string memory Check_Results, uint256 Amount_Security_Managers) { 
                 if (Security_Manager[account]) { Check_Results =" The Account is a Security Manager account";} 
                 else { Check_Results =" The account is NOT a Security Manager account";}
                 Amount_Security_Managers = Security_Managers_Count;
        }
        function A17__Check_if_is_Marketing_Manager(address account) external view 
                 returns (string memory Check_Results, uint256 Amount_Marketing_Managers) { 
                 if (Marketing_Manager[account]) { Check_Results =" The Account is a Marketing Manager account";} 
                 else { Check_Results =" The account is NOT a Marketing Manager account";}
                 Amount_Marketing_Managers = Marketing_Managers_Count;
        }
        function A18__Is_Public_Trading_Enabled() external view returns (bool) {
                 return Public_Trading_Enabled;
        }
        function A19__Check_if_Account_is_Excluded_from_Paying_Fees(address account) external view returns(bool) {
                 return ieff[account];
        }
        function A20__Check_if_Account_is_Excluded_from_Receiving_Reflections(address account) external view returns (bool) {
                 return ier[account];
        }
        function A21__Check_Bridge_Or_Exchange_Project_And_Reflection_Fees(string memory password, address account) 
                 external view returns (bool, uint256, uint256) {
                 require(keccak256(abi.encodePacked(password)) == password_keccak256_hash, "Password does not match");
                 require(block.timestamp < password_expiration_time, "Password has expired");
                 return (boe[account], boepf[account],boerf[account]);
        }
        function A22__Wallet_To_Save_Transfer_Fees() external view returns (address) {
                 return wtstf;
        }
        function A23__Min_Amount_Tokens_for_Project_Funding_Swap() external view returns (uint256) {
                 return matpfs;
        }
        function A24__Max_Tx_Amounts() external view returns (
                 uint256 Buy__Max_Tx_Amount,
                 uint256 Sell_Max_Tx_Amount) {
                 Buy__Max_Tx_Amount = bmta;
                 Sell_Max_Tx_Amount = smta;
        }



        //==========================================================//
        //                   WRITE FUNCTIONS                        //
        //                  (Contract update)                       //
        //==========================================================//

        function F01_Blacklist_Malicious_Account(address account) external ExceptAccounts(account) {
            require(CEO == msg.sender || Security_Manager[msg.sender] || Chief_Security_Officer == msg.sender);
            require(!isBlacklisted[account], "Address is already blacklisted");	
            isBlacklisted[account] = true;
        }
        function F02_Whitelist_Account(address account) external onlySecurityManager {
            require(isBlacklisted[account], "Address is already whitelisted");
            isBlacklisted[account] = false;
        }        
        function F03__Enable_Public_Trading() external onlySecurityManager {
            Public_Trading_Enabled = true;
        }
        function F04__Disable_Public_Trading() external onlySecurityManager {
            Public_Trading_Enabled = false;
        }
        function F05__Update_When_Account_Can_Sell_Again(address account, uint256 unix_time) external onlySecurityManager {
            // Tips: 
            // To allow selling immediately:  unix_time = 0
            SAT[account] = unix_time;
        }
        function F06__Set_Normal_Waiting_Time_Between_Sells(uint256 wait_seconds) external onlySecurityManager {
            // Example: 
            // 60 seconds waiting time:  wait_seconds = 60
            //
            // To disable the waiting time: wait_seconds = 0  
            require (wait_seconds <= wttsai2 || 
                    wttsai2 == 0,
                    "The normal waiting time cannot be larger than waiting time after price impact2");
            nwtbs = wait_seconds;
            if (pi2 != 0 && wttsai2 == 0) {
                wttsai2 = wait_seconds;
            }
        }
        function F07__Set_Waiting_Time_For_Next_Sell_After_Impact2(uint256 wait_seconds) external onlySecurityManager {
            //Examples:   Must wait 3 days:  wait_seconds = 259200
            //                      7 days:  wait_seconds = 604800
            //
            // Requires pi2 to be enabled (to be more than zero) 
            require (pi2 != 0,
                    "The waiting time after impact2 cannot be set when pi2 is 0");
            // Must be at least same but usually longer 
            // waiting time than the normal waiting time  
            require (wait_seconds >= nwtbs,
                    "The waiting time after impact2 cannot be less than the normal waiting time");
            wttsai2 = wait_seconds;
        }
        function F08__Set_Sell_Price_Impact1__Multiplied_by_100(uint256 Price_impact1) external onlySecurityManager {
            // To support a percentage number with a decimal
            // the percentage is / must be multiplied by 100.
            //
            // Examples:  1% price impact:  Price_impact1 = 100
            //          0.5% price impact:  Price_impact1 =  50
            require (Price_impact1 < pi2 || pi2 == 0, 
                    "Price impact1 cannot be larger than price impact2");
            if (spfui1 == 0) {
                spfui1 = spfiinu;
                spfai1 = spfiinu; 
            }
            if (Price_impact1 == 0){
                pi1 = 0;
                pi2 = 0;
                spfui1 = 0;
                spfai1 = 0;
                spfai2 = 0;
                srfui1 = 0;
                srfai1 = 0;
                srfai2 = 0;
                wttsai2 = 0;
            } else {
                pi1 = Price_impact1;
            }
        }
        function F09__Set_Sell_Price_Impact2__Multiplied_by_100(uint256 Price_impact2) external onlySecurityManager {
            // Examples:  20% price impact:  Price_impact2 = 2000
            //            30% price impact:  Price_impact2 = 3000
            require (pi1 != 0 && Price_impact2 > pi1 || Price_impact2 == 0, 
                    "Price impact2 cannot be less than price impact1"); 
            if (Price_impact2 == 0) {
                pi2 = 0;
                spfai2 = 0;
                srfai2 = 0;
                wttsai2 = 0;
            } else {
                pi2 = Price_impact2;
            }
        }        
        function F10_Set_Sell_Max_Tx_Amount(uint256 percent_of_total_supply_or_tokens_amount) 
                 external onlySecurityManager() {

                 uint256 old_smta = smta;
                 if (percent_of_total_supply_or_tokens_amount <= 100) {
                    smta = _tTotal.mul(percent_of_total_supply_or_tokens_amount).div(100);    
                 } else {
                    smta = percent_of_total_supply_or_tokens_amount;
                 }
                 emit Sell_Max_Tx_Amount_Updated(old_smta, smta);
        }
        function F11_Set_Buy_Max_Tx_Amount(uint256 percent_of_total_supply_or_tokens_amount) 
                 external onlySecurityManager() {

                 uint256 old_bmta = bmta;
                 if (percent_of_total_supply_or_tokens_amount <= 100) {
                    bmta = _tTotal.mul(percent_of_total_supply_or_tokens_amount).div(100);    
                 } else {
                    bmta = percent_of_total_supply_or_tokens_amount;
                 }
                 emit Buy_Max_Tx_Amount_Updated(old_bmta, bmta);
        }
        function F11__Set_Fees_For_Transfers(
            uint256 project_fee_percent, uint256 reflections_fee_percent) external onlySecurityManager {
            // Project fee for (normal) transfers between wallets.
            tpf = project_fee_percent;
            trf = reflections_fee_percent;
        }
        function F12__Set_Fees_For_Buys(
            uint256 project_fee_percent, uint256 reflections_fee_percent) external onlySecurityManager {
            bpf = project_fee_percent;
            brf = reflections_fee_percent;
        }
        function F13__Set_Fees_For_Sells_With_Price_Impact1(
            uint256 project_fee_under_impact1,
            uint256 project_fee_above_impact1,
            uint256 reflections_fee_under_impact1, 
            uint256 reflections_fee_above_impact1
            ) external onlySecurityManager {
            //The fees are a percentage number 
            require(pi1 != 0, "Cannot set price impact1 fees when impact1 is 0");
            require(project_fee_under_impact1 <= project_fee_above_impact1,
            "The project fee under price impact1 cannot be larger than the fee above price impact1");
            require(reflections_fee_under_impact1 <= reflections_fee_above_impact1,
            "The reflections fee under price impact1 cannot be larger than the fee above price impact1");
            if (pi2 != 0) {
                if (spfai2 == 0) {
                    spfai2 = project_fee_above_impact1;
                } else {
                    require(project_fee_above_impact1 <= spfai2);
                }
                if (srfai2 == 0) {
                    srfai2 = reflections_fee_above_impact1;
                } else {
                    require(reflections_fee_above_impact1 <= srfai2);
                }
            } 
            spfui1 = project_fee_under_impact1;
            spfai1 = project_fee_above_impact1; 
            srfui1 = reflections_fee_under_impact1;
            srfai1 = reflections_fee_above_impact1;          
        }
        function F14__Set_Fees_For_Sells_Above_Impact2(
            uint256 project_fee_above_impact2,
            uint256 reflections_fee_above_impact2) external onlySecurityManager {
            //The fees are a percentage number  
            require(pi2 != 0, "Cannot set price impact2 fees when impact2 is 0");
            require(project_fee_above_impact2 >= spfai1 || 
                    project_fee_above_impact2 == 0,
                    "The fee above price impact2 can not be less than the fee above price impact1"); 
            require(reflections_fee_above_impact2 >= srfai1,
                    "The fee above price impact2 can not be less than the fee above price impact1");  
            if (project_fee_above_impact2 == 0) {
                pi2 = 0;
                spfai2 = 0;
                srfai2 = 0;
                wttsai2 = 0;
            } else {
                spfai2 = project_fee_above_impact2;
                srfai2 = reflections_fee_above_impact2;
            }
        }
        function F15__Set_Fees_For_Sells_if_Price_Impacts_Not_Used(
            uint256 project_fee_percent, uint256 reflections_fee_percent) external onlySecurityManager {
            spfiinu = project_fee_percent;
            srfiinu = reflections_fee_percent;
        }
        function F16__Set_Product_Development_Fee_Portion(uint256 fee_percent) external onlyCEO {
            // Example: 25% of total Project Fee --> fee_percent = 25
            // IMPORTANT: 
            // pdf + mf = 100
            uint256 Total_All_Portions =  fee_percent + mf;
            require(Total_All_Portions <= 100, 
            "The sum of all fees portions must be less or equal 100");
            pdf = fee_percent;
        }
        function F17__Set_Marketing_Fee_Portion(uint256 fee_percent) external onlyMarketingManager {
            // Example: 25% of total Project Fee --> fee_percent = 25
            // IMPORTANT: 
            // pdf + mf = 100
            uint256 Total_All_Portions =  pdf + fee_percent;
            require(Total_All_Portions <= 100, 
            "The sum of all fees portions must be less or equal 100");
            mf = fee_percent;
        }
        function F18__Set_Product_Development_Wallet(address account) external onlyCEO {
            pdw = account;
        }
        function F19__Set_Marketing_Wallet(address account) external onlyMarketingManager {
            mw = account;
        }
        function F20__Set_Wallet_To_Save_Transfer_Fees(address account) external onlyCEO {
            // The Project Fee charged during a normal transfer is not
            // converted to BNB i.e. is not used for funding the project. 
            // So the contract needs to know which wallet it can/will use     
            // to send to it the tokens from the charged transfer fee 
            wtstf = account;
        }  
        function F21__Exclude_Account_From_Paying_Fees(address account) external onlySecurityManager {
            ieff[account] = true;
        }
        function F22__Enable_Account_Must_Pay_Fees(address account) external onlySecurityManager {
            ieff[account] = false;
        }
        function F23__Exclude_Account_from_Receiving_Reflections(address account) external onlySecurityManager {
            // Account will not receive reflections
            require(!ier[account], "Account is already excluded");
            if(_rOwned[account] > 0) {
                _tOwned[account] = tokenFromReflection(_rOwned[account]);
            }
            ier[account] = true;
                _excluded.push(account);
        }   
        function F24__Enable_Account_will_Receive_Reflections(address account) external onlySecurityManager {
            require(ier[account]);
            for (uint256 i = 0; i < _excluded.length; i++) {
                if (_excluded[i] == account) {
                    _excluded[i] = _excluded[_excluded.length - 1];
                    _tOwned[account] = 0;
                    ier[account] = false;
                    _excluded.pop();
                    break;
                }
            }
        }
        function F25__CEO_Change__By_Chief_Security_Officer(address New_CEO) public virtual onlyCSO {
            //CEO can be changed only by CSO
            require(New_CEO != address(0));
            require(New_CEO != address(this)); 
            require(New_CEO != Chief_Security_Officer);
            require(!Security_Manager[New_CEO]);
            require(!Marketing_Manager[New_CEO]);
            address Previous_CEO = CEO;
            CEO = New_CEO;
            ieff[New_CEO] = true;
            ieff[Previous_CEO] = false;
            emit CEO_Changed_By_Chief_Security_Officer(Previous_CEO, New_CEO);
        }
        function F26__CSO_Change__By_Chief_Security_Officer(address New_CSO)  public virtual onlyCSO {
            //CSO can be changed only by CSO
            require(New_CSO != address(0));
            require(New_CSO != address(this)); 
            require(New_CSO != CEO);
            require(!Security_Manager[New_CSO]);
            require(!Marketing_Manager[New_CSO]);
            address Previous_CSO = Chief_Security_Officer;
            Chief_Security_Officer = New_CSO;
            emit CSO_Changed_by_Chief_Security_Officer(Previous_CSO, New_CSO);
        }
        function F27__Add_Security_Manager(address account) external onlySecurityManager {
            require(account != CEO);
            require(!Security_Manager[account],"Security Manager already added");
            require(account != Chief_Security_Officer);
            require(!Marketing_Manager[account]);
            require(Security_Managers_Count < 2, "Max two accounts are allowed and have been already added");
            
            Security_Manager[account] = true;
            Security_Managers_Count++;
            emit Added_Security_Manager(account);
        }
        function F28__Remove_Security_Manager(address account) external onlySecurityManager {
            require(Security_Manager[account],"The account is not in the contract");
            Security_Manager[account] = false;
            Security_Managers_Count--;
            emit Removed_Security_Manager(account);
        }
        function F29__Add_Marketing_Manager(address account) external {
            require(!Security_Manager[account], "Security personnel cannot have other roles");
            require(account != Chief_Security_Officer, "Security personnel cannot have other roles");
            require(!Marketing_Manager[account],"Marketing Manager already added");   
            require(Marketing_Managers_Count < 2, "Max two accounts are allowed and have been already added");
            
            if (Marketing_Managers_Count == 0) {
                require(Security_Manager[msg.sender] || Chief_Security_Officer == msg.sender);
            }
            else {require(Marketing_Manager[msg.sender]);}
            
            Marketing_Manager[account] = true;
            Marketing_Managers_Count++;
            emit Added_Marketing_Manager(account);
        }
        function F30__Remove_Marketing_Manager(address account) external onlyMarketingManager {
            require(Marketing_Manager[account],"The account is not a Marketing Manager account");
            Marketing_Manager[account] = false;
            Marketing_Managers_Count--;
            emit Removed_Marketing_Manager(account);
        }
        function F31__Add_Bridge_Or_Exchange(
                address account, 
                uint256 proj_fee, 
                uint256 reflections_fee
                ) external ExceptAccounts(account) onlySecurityManager {
            
                boe[account] = true;
                boepf[account] = proj_fee;
                boerf[account] = reflections_fee;
        }
        function F32__Remove_Bridge_Or_Exchange(address account) external onlySecurityManager {
                delete boe[account];
                delete boepf[account];
                delete boerf[account];
        }
        function F33__Set_Min_Amount_Tokens_For_ProjectFundingSwap(uint256 amount) external onlySecurityManager {
            // Example: 10 tokens --> amount = 100000000 (i.e. 10 * 10**7 decimals) = 0.0002%
            matpfs = amount;
        }
        function F34__Rescue_Other_Tokens_Sent_To_This_Contract(IERC20 token, address receiver, uint256 amount) external {
            // This feature is very appreciated:
            // To be able to send back to a user other BEP20 tokens 
            // that the user have sent to this contract by mistake.
            require(CEO == msg.sender || Security_Manager[msg.sender] || Chief_Security_Officer == msg.sender);
            require(token != IERC20(address(this)), "Only other tokens can be rescued");
            require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
            require(receiver != address(this));
            require(receiver != address(0));
            token.transfer(receiver, amount);
        }


        //========================   Protecting View Functions with Password   ========================//


        bytes32 internal password_keccak256_hash;
        uint256 internal password_expiration_time;

        // Online Password Hash Generator: https://keccak-256.cloxy.net/
        // Need to add 0x in front of the hash

        function F35__Set_Security_Password_Hash(bytes32 password_hash_with_0x, uint256 validity_duration_secs) external onlySecurityManager {
                 password_keccak256_hash = password_hash_with_0x;
                 password_expiration_time = block.timestamp + validity_duration_secs;
        }

        function Show_Password_Settings() external view returns(
            bytes32 Password_Keccak256_Hash,
            uint256 Password_Expiration_Unix_Time,
            uint256 Password_Validity_Duration_In_Seconds) {

            Password_Keccak256_Hash = password_keccak256_hash;
            Password_Expiration_Unix_Time = password_expiration_time;

            if (block.timestamp < password_expiration_time) {
                Password_Validity_Duration_In_Seconds = password_expiration_time - block.timestamp;
            } else {
                Password_Validity_Duration_In_Seconds = 0;
            }
        }
    }