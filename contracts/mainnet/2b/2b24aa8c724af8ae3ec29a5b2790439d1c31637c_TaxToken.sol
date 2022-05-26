/**
 *Submitted for verification at BscScan.com on 2022-05-26
*/

// File: contracts/ERC20.sol


pragma solidity ^0.8.6;

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

interface ITreasury {
    function updateTaxesAccrued(uint taxType, uint amt) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

struct Slot0 {
    // the current price
    uint160 sqrtPriceX96;
    // the current tick
    int24 tick;
    // the most-recently updated index of the observations array
    uint16 observationIndex;
    // the current maximum number of observations that are being stored
    uint16 observationCardinality;
    // the next maximum number of observations to store, triggered in observations.write
    uint16 observationCardinalityNext;
    // the current protocol fee as a percentage of the swap fee taken on withdrawal
    // represented as an integer denominator (1/x)%
    uint8 feeProtocol;
    // whether the pool is locked
    bool unlocked;
}

interface IUniPool {
    function slot0() external returns(Slot0 memory slot0);
    function liquidity() external returns(uint128 liquidity);
    function fee() external returns(uint24 fee);
    function token0() external returns(address token0);
    function token1() external returns(address token1);
    function tickSpacing() external returns(int24 tickSpacing);
    function tickBitmap(int16 i) external payable returns(uint256 o);
}


interface ILiquidityPoolV4 {

}

interface IDapperTri {
    function get_paid(
        address[3] memory _route, 
        uint8[3] memory _exchanges, 
        uint24[4] memory _poolFees, 
        address _borrow, 
        uint _borrowAmt
    ) external;
}

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
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
}

interface IUniswapQuoterV3 {
    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external view returns (uint256 amountOut);
}

interface IUniswapRouterV3 {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

// https://etherscan.io/address/0x2F9EC37d6CcFFf1caB21733BdaDEdE11c823cCB0#code
interface IBancorNetwork {
     function conversionPath(
         IERC20 _sourceToken, 
         IERC20 _targetToken
    ) external view returns (address[] memory);
    function convert(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn
    ) external payable returns (uint256);
    function convertByPath(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn,
        address payable beneficiary,
        address affiliate,
        uint256 affiliateFee
    ) external payable returns (uint256);
    function rateByPath(
        address[] memory path, 
        uint256 sourceAmount
    ) external view returns (uint256);
}

// https://etherscan.io/address/0x8301ae4fc9c624d1d396cbdaa1ed877821d7c511#code (ETH/CRV)
// https://etherscan.io/address/0xDC24316b9AE028F1497c275EB9192a3Ea0f67022#code (ETH/stETH)
interface ICRVMetaPool {
    // i = token_from
    // j = token_to
    // dx = token_from_change
    // min_dy = token_to_min_receive
    // function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256); 
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256); 
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external payable returns(uint256);
    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function add_liquidity(uint256[] memory amounts_in, uint256 min_mint_amount) external payable returns(uint256);
    function remove_liquidity(uint256 amount, uint256[] memory min_amounts_out) external returns(uint256[] memory);
}

interface ICRV {
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable; 
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external payable;
}

interface ICRV_PP_128_NP {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256);
}
interface ICRV_PP_256_NP {
    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external;
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256);
}
interface ICRV_PP_256_P {
    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256);
}
interface ICRV_MP_256 {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns(uint256);
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256);
}

interface ICRVSBTC {
    // i = token_from
    // j = token_to
    // dx = token_from_change
    // min_dy = token_to_min_receive
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256); 
    function add_liquidity(uint256[3] memory amounts_in, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts_out) external;
    function remove_liquidity_one_coin(uint256 token_amount, int128 index, uint min_amount) external;
}

interface ICRVSBTC_CRV {
    // i = token_from
    // j = token_to
    // dx = token_from_change
    // min_dy = token_to_min_receive
    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 
    // function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy, address _receiver) external; 
    function add_liquidity(uint256[3] memory amounts_in, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts_out) external;
    function remove_liquidity_one_coin(uint256 token_amount, int128 index, uint min_amount) external;
}

// https://etherscan.io/address/0xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f#code
interface ISushiRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

// https://etherscan.io/address/0x7f39c581f595b53c5cb19bd0b3f8da6c935e2ca0#code
interface IWSTETH {
    function wrap(uint256 _stETHAmount) external returns (uint256);
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
}

interface IVault {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

interface IWETH {
    function deposit() external payable;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// File: contracts/TaxToken.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


/// @dev    The TaxToken is responsible for supporting generic ERC20 functionality including ERC20Pausable functionality.
///         The TaxToken will generate taxes on transfer() and transferFrom() calls for non-whitelisted addresses.
///         The Admin can specify the tax fee in basis points for buys, sells, and transfers.
///         The TaxToken will forward all taxes generated to a Treasury
contract TaxToken {
 
    // ---------------
    // State Variables
    // ---------------

    // ERC20 Basic
    uint256 _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    // ERC20 Pausable
    bool private _paused;  // ERC20 Pausable state

    // Extras
    address public owner;
    address public treasury;
    address public UNIV2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public taxesRemoved;   /// @dev Once true, taxes are permanently set to 0 and CAN NOT be increased in the future.

    uint256 public maxWalletSize;
    uint256 public maxTxAmount;

    // ERC20 Mappings
    mapping(address => uint256) balances;                       // Track balances.
    mapping(address => mapping(address => uint256)) allowed;    // Track allowances.

    // Extras Mappings
    mapping(address => bool) public blacklist;          /// @dev If an address is blacklisted, they cannot perform transfer() or transferFrom().
    mapping(address => bool) public whitelist;          /// @dev Any transfer that involves a whitelisted address, will not incur a tax.
    mapping(address => uint) public senderTaxType;      /// @dev  Identifies tax type for msg.sender of transfer() call.
    mapping(address => uint) public receiverTaxType;    /// @dev  Identifies tax type for _to of transfer() call.
    mapping(uint => uint) public basisPointsTax;        /// @dev  Mapping between taxType and basisPoints (taxed).



    // -----------
    // Constructor
    // -----------

    /// @notice Initializes the TaxToken.
    /// @param  totalSupplyInput    The total supply of this token (this value is multipled by 10**decimals in constructor).
    /// @param  nameInput           The name of this token.
    /// @param  symbolInput         The symbol of this token.
    /// @param  decimalsInput       The decimal precision of this token.
    /// @param  maxWalletSizeInput  The maximum wallet size (this value is multipled by 10**decimals in constructor).
    /// @param  maxTxAmountInput    The maximum tx size (this value is multipled by 10**decimals in constructor).
    constructor(
        uint totalSupplyInput, 
        string memory nameInput, 
        string memory symbolInput, 
        uint8 decimalsInput,
        uint256 maxWalletSizeInput,
        uint256 maxTxAmountInput
    ) {
        _paused = false;    // ERC20 Pausable global state variable, initial state is not paused ("unpaused").
        _name = nameInput;
        _symbol = symbolInput;
        _decimals = decimalsInput;
        _totalSupply = totalSupplyInput * 10**_decimals;

        // Create a uniswap pair for this new token
        address UNISWAP_V2_PAIR = IUniswapV2Factory(
            IUniswapV2Router01(UNIV2_ROUTER).factory()
        ).createPair(address(this), IUniswapV2Router01(UNIV2_ROUTER).WETH());
 
        senderTaxType[UNISWAP_V2_PAIR] = 1;
        receiverTaxType[UNISWAP_V2_PAIR] = 2;

        owner = msg.sender;                                         // The "owner" is the "admin" of this contract.
        balances[msg.sender] = totalSupplyInput * 10**_decimals;    // Initial liquidity, allocated entirely to "owner".
        maxWalletSize = maxWalletSizeInput * 10**_decimals;
        maxTxAmount = maxTxAmountInput * 10**_decimals;      
    }

 

    // ---------
    // Modifiers
    // ---------

    /// @dev whenNotPausedUni() is used if the contract MUST be paused ("paused").
    modifier whenNotPausedUni(address a) {
        require(!paused() || whitelist[a], "ERR: Contract is currently paused.");
        _;
    }

    /// @dev whenNotPausedDual() is used if the contract MUST be paused ("paused").
    modifier whenNotPausedDual(address from, address to) {
        require(!paused() || whitelist[from] || whitelist[to], "ERR: Contract is currently paused.");
        _;
    }

    /// @dev whenNotPausedTri() is used if the contract MUST be paused ("paused").
    modifier whenNotPausedTri(address from, address to, address sender) {
        require(!paused() || whitelist[from] || whitelist[to] || whitelist[sender], "ERR: Contract is currently paused.");
        _;
    }

    /// @dev whenPaused() is used if the contract MUST NOT be paused ("unpaused").
    modifier whenPaused() {
        require(paused(), "ERR: Contract is not currently paused.");
        _;
    }
    
    /// @dev onlyOwner() is used if msg.sender MUST be owner.
    modifier onlyOwner {
       require(msg.sender == owner, "ERR: TaxToken.sol, onlyOwner()"); 
       _;
    }



    // ------
    // Events
    // ------

    event Paused(address account);          /// @dev Emitted when the pause is triggered by `account`.
    event Unpaused(address account);        /// @dev Emitted when the pause is lifted by `account`.

    /// @dev Emitted when approve() is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   
 
    /// @dev Emitted during transfer() or transferFrom().
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TransferTax(address indexed _from, address indexed _to, uint256 _value, uint256 _taxType);



    // ---------
    // Functions
    // ---------


    // ~ ERC20 View ~
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
 
    // ~ ERC20 transfer(), transferFrom(), approve() ~

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function transfer(address _to, uint256 _amount) public whenNotPausedDual(msg.sender, _to) returns (bool success) {  

        // taxType 0 => Xfer Tax
        // taxType 1 => Buy Tax
        // taxType 2 => Sell Tax
        uint _taxType;

        if (balances[msg.sender] >= _amount && (!blacklist[msg.sender] && !blacklist[_to])) {

            // Take a tax from them if neither party is whitelisted.
            if (!whitelist[_to] && !whitelist[msg.sender] && _amount <= maxTxAmount) {

                // Determine, if not the default 0, tax type of transfer.
                if (senderTaxType[msg.sender] != 0) {
                    _taxType = senderTaxType[msg.sender];
                }

                if (receiverTaxType[_to] != 0) {
                    _taxType = receiverTaxType[_to];
                }

                // Calculate taxAmt and sendAmt.
                uint _taxAmt = _amount * basisPointsTax[_taxType] / 10000;
                uint _sendAmt = _amount * (10000 - basisPointsTax[_taxType]) / 10000;

                if (balances[_to] + _sendAmt <= maxWalletSize) {

                    balances[msg.sender] -= _amount;
                    balances[_to] += _sendAmt;
                    balances[treasury] += _taxAmt;

                    require(_taxAmt + _sendAmt >= _amount * 999999999 / 1000000000, "Critical error, math.");
                
                    // Update accounting in Treasury.
                    ITreasury(treasury).updateTaxesAccrued(
                        _taxType, _taxAmt
                    );
                    
                    emit Transfer(msg.sender, _to, _sendAmt);
                    emit TransferTax(msg.sender, treasury, _taxAmt, _taxType);

                    return true;
                }

                else {
                    return false;
                }

            }

            else if (!whitelist[_to] && !whitelist[msg.sender] && _amount > maxTxAmount) {
                return false;
            }

            else {
                balances[msg.sender] -= _amount;
                balances[_to] += _amount;
                emit Transfer(msg.sender, _to, _amount);
                return true;
            }
        }
        else {
            return false;
        }
    }
 
    function transferFrom(address _from, address _to, uint256 _amount) public whenNotPausedTri(_from, _to, msg.sender) returns (bool success) {

        // taxType 0 => Xfer Tax
        // taxType 1 => Buy Tax
        // taxType 2 => Sell Tax
        uint _taxType;

        if (
            balances[_from] >= _amount && 
            allowed[_from][msg.sender] >= _amount && 
            _amount > 0 && balances[_to] + _amount > balances[_to] && 
            _amount <= maxTxAmount && (!blacklist[_from] && !blacklist[_to])
        ) {
            
            // Reduce allowance.
            allowed[_from][msg.sender] -= _amount;

            // Take a tax from them if neither party is whitelisted.
            if (!whitelist[_to] && !whitelist[_from] && _amount <= maxTxAmount) {

                // Determine, if not the default 0, tax type of transfer.
                if (senderTaxType[_from] != 0) {
                    _taxType = senderTaxType[_from];
                }

                if (receiverTaxType[_to] != 0) {
                    _taxType = receiverTaxType[_to];
                }

                // Calculate taxAmt and sendAmt.
                uint _taxAmt = _amount * basisPointsTax[_taxType] / 10000;
                uint _sendAmt = _amount * (10000 - basisPointsTax[_taxType]) / 10000;

                if (balances[_to] + _sendAmt <= maxWalletSize || _taxType == 2) {

                    balances[_from] -= _amount;
                    balances[_to] += _sendAmt;
                    balances[treasury] += _taxAmt;

                    require(_taxAmt + _sendAmt == _amount, "Critical error, math.");
                
                    // Update accounting in Treasury.
                    ITreasury(treasury).updateTaxesAccrued(
                        _taxType, _taxAmt
                    );
                    
                    emit Transfer(_from, _to, _sendAmt);
                    emit TransferTax(_from, treasury, _taxAmt, _taxType);

                    return true;
                }
                
                else {
                    return false;
                }

            }

            else if (!whitelist[_to] && !whitelist[_from] && _amount > maxTxAmount) {
                return false;
            }

            // Skip taxation if either party is whitelisted (_from or _to).
            else {
                balances[_from] -= _amount;
                balances[_to] += _amount;
                emit Transfer(_from, _to, _amount);
                return true;
            }

        }
        else {
            return false;
        }
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    // ~ ERC20 Pausable ~

    /// @notice Pause the contract, blocks transfer() and transferFrom().
    /// @dev    Contract MUST NOT be paused to call this, caller must be "owner".
    function pause() public onlyOwner whenNotPausedUni(msg.sender) {
        _paused = true;
        emit Paused(msg.sender);
    }

    /// @notice Unpause the contract.
    /// @dev    Contract MUST be puased to call this, caller must be "owner".
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /// @return _paused Indicates whether the contract is paused (true) or not paused (false).
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    
    // ~ TaxType & Fee Management ~

    /// @notice     Used to store the LP Pair to differ type of transaction. Will be used to mark a BUY.
    /// @dev        _taxType must be lower than 3 because there can only be 3 tax types; buy, sell, & send.
    /// @param      _sender This value is the PAIR address.
    /// @param      _taxType This value must be be 0, 1, or 2. Best to correspond value with the BUY tax type.
    function updateSenderTaxType(address _sender, uint _taxType) public onlyOwner {
        require(_taxType < 3, "err _taxType must be less than 3");
        senderTaxType[_sender] = _taxType;
    }

    /// @notice     Used to store the LP Pair to differ type of transaction. Will be used to mark a SELL.
    /// @dev        _taxType must be lower than 3 because there can only be 3 tax types; buy, sell, & send.
    /// @param      _receiver This value is the PAIR address.
    /// @param      _taxType This value must be be 0, 1, or 2. Best to correspond value with the SELL tax type.
    function updateReceiverTaxType(address _receiver, uint _taxType) public onlyOwner {
        require(_taxType < 3, "err _taxType must be less than 3");
        receiverTaxType[_receiver] = _taxType;
    }

    /// @notice     Used to map the tax type 0, 1 or 2 with it's corresponding tax percentage.
    /// @dev        Must be lower than 2000 which is equivalent to 20%.
    /// @param      _taxType This value is the tax type. Has to be 0, 1, or 2.
    /// @param      _bpt This is the corresponding percentage that is taken for royalties. 1200 = 12%.
    function adjustBasisPointsTax(uint _taxType, uint _bpt) public onlyOwner {
        require(_bpt <= 2000, "err TaxToken.sol _bpt > 2000 (20%)");
        require(!taxesRemoved, "err TaxToken.sol taxation has been removed");
        basisPointsTax[_taxType] = _bpt;
    }

    /// @notice Permanently remove taxes from this contract.
    /// @dev    An input is required here for sanity-check, given importance of this function call (and irreversible nature).
    /// @param  _key This value MUST equal 42 for function to execute.
    function permanentlyRemoveTaxes(uint _key) public onlyOwner {
        require(_key == 42, "err TaxToken.sol _key != 42");
        basisPointsTax[0] = 0;
        basisPointsTax[1] = 0;
        basisPointsTax[2] = 0;
        taxesRemoved = true;
    }


    // ~ Admin ~

    /// @notice This is used to change the owner's wallet address. Used to give ownership to another wallet.
    /// @param  _owner is the new owner address.
    function transferOwnership(address _owner) public onlyOwner {
        owner = _owner;
    }

    /// @notice Set the treasury (contract)) which receives taxes generated through transfer() and transferFrom().
    /// @param  _treasury is the contract address of the treasury.
    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
    }

    /// @notice Adjust maxTxAmount value (maximum amount transferrable in a single transaction).
    /// @dev    Does not affect whitelisted wallets.
    /// @param  _maxTxAmount is the max amount of tokens that can be transacted at one time for a non-whitelisted wallet.
    function updateMaxTxAmount(uint256 _maxTxAmount) public onlyOwner {
        maxTxAmount = (_maxTxAmount * 10**_decimals);
    }

    /// @notice This function is used to set the max amount of tokens a wallet can hold.
    /// @dev    Does not affect whitelisted wallets.
    /// @param  _maxWalletSize is the max amount of tokens that can be held on a non-whitelisted wallet.
    function updateMaxWalletSize(uint256 _maxWalletSize) public onlyOwner {
        maxWalletSize = (_maxWalletSize * 10**_decimals);
    }

    /// @notice This function is used to add wallets to the whitelist mapping.
    /// @dev    Whitelisted wallets are not affected by maxWalletSize, maxTxAmount, and taxes.
    /// @param  _wallet is the wallet address that will have their whitelist status modified.
    /// @param  _whitelist use True to whitelist a wallet, otherwise use False to remove wallet from whitelist.
    function modifyWhitelist(address _wallet, bool _whitelist) public onlyOwner {
        whitelist[_wallet] = _whitelist;
    }

    /// @notice This function is used to add or remove wallets from the blacklist.
    /// @dev    Blacklisted wallets cannot perform transfer() or transferFrom().
    /// @param  _wallet is the wallet address that will have their blacklist status modified.
    /// @param  _blacklist use True to blacklist a wallet, otherwise use False to remove wallet from blacklist.
    function modifyBlacklist(address _wallet, bool _blacklist) public onlyOwner {
        blacklist[_wallet] = _blacklist;
    }
    
}