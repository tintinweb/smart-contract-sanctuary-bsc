/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

// This is TebTest No. 5
// Telegram: t.me/tebtest
// Twitter: twitter.com/tebtest
// Website: tebtest.com

pragma solidity >=0.6.2;

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

pragma solidity >=0.6.2;

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

pragma solidity >=0.5.0;

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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

pragma solidity ^0.8.1;

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

pragma solidity ^0.8.0;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {

            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

pragma solidity ^0.8.0;

interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract TEBTEST is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned; //Tokens Reflected
    mapping(address => uint256) private _tOwned; //Tokens Owned
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee; //Does not pay taxes
    mapping(address => bool) private _isLimitExempt; //Wallet exempted from Hold limits
    mapping(address => bool) public _isDonationRecipient; //Wallet with specific transfer requirements
    mapping(address => bool) private _isEmploymentWallet; //Employment Wallets
    mapping(address => bool) private _isTeamWallet; //Team Wallets
    mapping(address => uint256) TokenReceive; //For Team Token Lock within Contract 
    mapping(address => uint256) TokenTransfer; //For Team and Employment Wallet sell limits

    mapping(address => bool) private _isExcluded; //Does not have reflections
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1* 10**9 * 10**9; //Total Supply = 1,000,000,000
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "TEBTEST5";
    string private _symbol = "TEB5";
    uint8 private _decimals = 9;

    struct BuyFee {
        uint16 liquidityFee;
        uint16 developmentFee;
        uint16 treasuryFee;
        uint16 taxFee;
    }

    struct SellFee {
        uint16 liquidityFee;
        uint16 developmentFee;
        uint16 treasuryFee;
        uint16 taxFee;
    }

    struct TransferFee {
        uint16 liquidityFee;
        uint16 developmentFee;
        uint16 treasuryFee;
        uint16 taxFee;
    }


    BuyFee public buyFee;
    SellFee public sellFee;
    TransferFee public transferFee;

    uint16 private _taxFee;
    uint16 private _liquidityFee;
    uint16 private _developmentFee;
    uint16 private _treasuryFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public constant _burnWallet = 0x000000000000000000000000000000000000dEaD;

    address public Wallet_Development = payable(address(0x74637837a5cf59735399F39B6Ca78f94AD1FB4D4));
    address public Wallet_Treasury = payable(address(0xc4b54255860fa541b49e20963B1514E9be27226a));

    //Multisignature wallets that will receive funding for project utilities

    address public Wallet_Research = 0xe9289e707CFe73433fe2878Ee8732Aa2170F7A20;
    address public Wallet_Scholarship = 0xB5ceBCd0D521F75F97B4FF2F3f594b356af7d9B1;
    address public Wallet_OneHealth = 0x2aF06333382CfC4189CF749C5b4a163fbE7F5672;
    address public Wallet_Prize = 0xeB6781ac4f7e2D5827f4CC4E989DDA73Ff99Ed8b;

    //Multisignature wallets that will hold tokens to fund compensation for expanded team, exempt from fees

    address public Wallet_Employment1 = 0xD033cD6e7b011617E6FA45Ca3d9E986E463B7D5B;
    address public Wallet_Employment2 = 0x43101946B7885C116e11492Da7863A5b82E710Aa;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxHold = 3 * 10**7 * 10**9; //Maximum hold limit of 3% of total supply
    uint256 public _maxDonationRecipientHold = 1 * 10**6 * 10**9; //Maximum hold limit of 0.1% of total supply
    uint256 public _employmentHold = 1 * 10**8 * 10**9; //Maximum hold limit of 7.5% of total supply for team expansion
    uint256 public _maxTxAmount = 1 * 10**7 * 10**9;
    uint256 public _donationLimit = 1 * 10**4 * 10**9;
    uint256 private numTokensSellToAddToLiquidity = 1 * 10**5 * 10**9;

    event updated_donation_limit(uint256 _donationLimit);

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() payable {

        _rOwned[_msgSender()] = _rTotal;

        buyFee.liquidityFee = 1;
        buyFee.developmentFee = 2; //Marketing and Team Wallet
        buyFee.treasuryFee = 5; //Treasury Wallet
        buyFee.taxFee = 2; //Reflection

        sellFee.liquidityFee = 0;
        sellFee.developmentFee = 2;
        sellFee.treasuryFee = 6;
        sellFee.taxFee = 2;

        transferFee.liquidityFee = 2;
        transferFee.developmentFee = 2;
        transferFee.treasuryFee = 6;
        transferFee.taxFee = 0;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_burnWallet] = true;
        _isExcludedFromFee[Wallet_Employment1] = true;
        _isExcludedFromFee[Wallet_Employment2] = true;

        // Wallet that are excluded from regular holding limits
        _isLimitExempt[owner()] = true;
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[_burnWallet] = true;
        _isLimitExempt[uniswapV2Pair] = true;

        // Employment wallet mapped for separate holding limit
        _isEmploymentWallet[Wallet_Employment1] = true;
        _isEmploymentWallet[Wallet_Employment2] = true;

        // Exclude from Rewards
        _isExcluded[_burnWallet] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[Wallet_Development] = true;
        _isExcluded[Wallet_Treasury] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        // require(account != 0xD99D1c33F9fC3444f8101754aBC46c52416550D1, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    //Set as Donation Recipients
    function includeForDonation(address account) external onlyOwner {
        _isDonationRecipient[account] = true;
    }

    function excludeForDonation(address account) external onlyOwner {
        _isDonationRecipient[account] = false;
    }

    //Set as Team Wallet
    function includeForTeamWallet(address account) external onlyOwner {
        _isTeamWallet[account] = true;
    }

    function excludeForTeamWallet(address account) external onlyOwner {
        _isTeamWallet[account] = false;
    }

    // Maximum buy fee canot not be set over 10%
    function setBuyFee(uint16 liq, uint16 develop, uint16 treasury, uint16 tax) external onlyOwner {
        require(liq + develop + treasury + tax <= 10, "Fees are capped at 10%"); 
        
        buyFee.liquidityFee = liq;
        buyFee.developmentFee = develop;
        buyFee.treasuryFee = treasury;
        buyFee.taxFee = tax;
    }

    // Maximum sell fee canot not be set over 15%
    function setSellFee(uint16 liq, uint16 develop, uint16 treasury, uint16 tax) external onlyOwner {
        require(liq + develop + treasury + tax <= 15, "Fees are capped at 10%"); 

        sellFee.liquidityFee = liq;
        sellFee.developmentFee = develop;
        sellFee.treasuryFee = treasury;
        sellFee.taxFee = tax;
    }

    // Maximum transfer fee canot not be set over 10%
    function setTransferFee(uint16 liq, uint16 develop, uint16 treasury, uint16 tax) external onlyOwner {
        require(liq + develop + treasury + tax <= 15, "Fees are capped at 10%"); 

        transferFee.liquidityFee = liq;
        transferFee.developmentFee = develop;
        transferFee.treasuryFee = treasury;
        transferFee.taxFee = tax;
    }

    function setNumTokensSellToAddToLiquidity(uint256 numTokens)
        external
        onlyOwner
    {
        numTokensSellToAddToLiquidity = numTokens;
    }

    function updateRouter(address newAddress) external onlyOwner {
        require(
            newAddress != address(uniswapV2Router),
            "TOKEN: The router already has that address"
        );
        uniswapV2Router = IUniswapV2Router02(newAddress);
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Pair = _uniswapV2Pair;
    }

    function setMaxTx(uint256 maxTx) external onlyOwner {
        require (maxTx >= 5 * 10**5 * 10**9); //Protect buyers from too low of transaction limits
        _maxTxAmount = maxTx;
    }

    function setDonationLimit(uint256 donationLimit) external onlyOwner {
        _donationLimit = donationLimit;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function claimStuckTokens(address _token) external onlyOwner {
        require(_token != address(this), "No rug pulls :)");

        if (_token == address(0x0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }

        IERC20 erc20token = IERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner(), balance);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity,
            uint256 tTreasury,
            uint256 tDevelopment
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            tTreasury,
            tDevelopment,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTreasury = calculateTreasuryFee(tAmount);
        uint256 tDevelopment = calculateDevelopmentFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        tTransferAmount = tTransferAmount.sub(tTreasury).sub(tDevelopment);
        return (tTransferAmount, tFee, tLiquidity, tTreasury, tDevelopment);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tTreasury,
        uint256 tDevelopment,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTreasury = tTreasury.mul(currentRate);
        uint256 rDevelopment = tDevelopment.mul(currentRate);
        uint256 rTransferAmount = rAmount
            .sub(rFee)
            .sub(rLiquidity)
            .sub(rTreasury)
            .sub(rDevelopment);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeTreasuryAndDevelopment(uint256 tTreasury, uint256 tDevelopment)
        private
    {
        uint256 currentRate = _getRate();
        uint256 rTreasury = tTreasury.mul(currentRate);
        uint256 rDevelopment = tDevelopment.mul(currentRate);

        _rOwned[Wallet_Treasury] = _rOwned[Wallet_Treasury].add(rTreasury);
        _rOwned[address(this)] = _rOwned[address(this)].add(rDevelopment);

        _tOwned[Wallet_Treasury] = _tOwned[Wallet_Treasury].add(tTreasury);
        _tOwned[address(this)] = _tOwned[address(this)].add(tDevelopment);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_liquidityFee).div(10**2);
    }

    function calculateTreasuryFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_treasuryFee).div(10**2);
    }

    function calculateDevelopmentFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return _amount.mul(_developmentFee).div(10**2);
    }

    function removeAllFee() private {
        _taxFee = 0;
        _liquidityFee = 0;
        _treasuryFee = 0;
        _developmentFee = 0;
    }

    function setBuy() private {
        _taxFee = buyFee.taxFee;
        _liquidityFee = buyFee.liquidityFee;
        _treasuryFee = buyFee.treasuryFee;
        _developmentFee = buyFee.developmentFee;
    }

    function setSell() private {
        _taxFee = sellFee.taxFee;
        _liquidityFee = sellFee.liquidityFee;
        _treasuryFee = sellFee.treasuryFee;
        _developmentFee = sellFee.developmentFee;
    }

    function setTransfer() private {
        _taxFee = transferFee.taxFee;
        _liquidityFee = transferFee.liquidityFee;
        _treasuryFee = transferFee.treasuryFee;
        _developmentFee = transferFee.developmentFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isDonationRecipient(address account) public view returns (bool) {
        return _isDonationRecipient[account];
    }

    function isTeamWallet(address account) public view returns (bool) {
        return _isTeamWallet[account];
    }

    function updateTokenReceive(address to) internal {
        TokenReceive[to] = block.timestamp;
    }

    function updateTokenTransfer(address from) internal {
        TokenTransfer[from] = block.timestamp;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Team Wallet receiving limits, buyer protection for misuse of lack of fees
        if (_isTeamWallet[to])
            {

            require (from == owner(), "Team Wallet cannot buy or receive tokens from non-owner."
            );
            TokenReceive[to] = block.timestamp;
        }

        // Team Wallet sending limits, buyer protection for misuse of lack of fees
        if (_isTeamWallet[from] && !_isExcluded[to])
            {

            require (amount >= 0, "Team Wallet can only sell or burn, cannot transfer to others."
            );
        }

        // Team Wallet transfer limits, buyer protection for misuse of lack of fees
        if (_isTeamWallet[from] && _isExcluded[to])
            {
            require (amount <= 1 * 10**6 * 10**9,
                        "Team Wallet can only sell up to 0.1% of the total supply."
            );

            require (block.timestamp >= TokenReceive[to] + 900,
                        "Team Wallet can only sell 10 minutes after deploy."
            );
            require (block.timestamp > TokenTransfer[from] + 900 && TokenTransfer[from] > 0,
                        "Team Wallet can only use transfer once every 15 minutes."
            );
            TokenTransfer[from] = block.timestamp;
        }

        // Employment Wallet Limits
        if (_isEmploymentWallet[to])
            {

            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _employmentHold,
                "Employment wallet can only hold at most 10% of the supply"
             );
            
        }

        // Employment Wallet sending limits, buyer protection for misuse of lack of fees
        if (_isEmploymentWallet[from]) 
            {
            require (!_isExcluded[to], "Employment wallet cannot transfer to regular holders."
            );
        }


        // Donation Wallet receiving limits
        if (_isDonationRecipient[to] && from != owner())
            {
            require(amount == _donationLimit,
                "Donation recipients can only receive a limited amount of tokens"
            );
        
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxDonationRecipientHold, 
                "Donation recipients cannot exceed maximum hold limit."
            );

        }

        // Donation Wallet transfer limits, buyer protection for misuse of lack of fees
        if (_isDonationRecipient[from]) 
            {
            require (!_isExcluded[to], "Donation wallet cannot transfer to regular holders."
            );
        }

        // Regular Wallet Limit
        if (!_isLimitExempt[to] && _isEmploymentWallet[to] && !_isDonationRecipient[to] && from != owner())
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxHold, 
                "Wallet cannot exceed maximum hold limit."
            );
        }

        if (from != owner() && to != owner()) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            uint256 forDevelopment = contractTokenBalance
                .mul(buyFee.developmentFee + sellFee.developmentFee + transferFee.developmentFee)
                .div(
                    buyFee.developmentFee +
                        sellFee.developmentFee +
                        transferFee.developmentFee +
                        buyFee.liquidityFee +
                        sellFee.liquidityFee +
                        transferFee.liquidityFee
                );
            swapAndSendFee(forDevelopment);

            swapAndLiquify(contractTokenBalance - forDevelopment);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to the following, then remove the fee
        //Team wallets have locked tokens and cannot buy more tokens
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] 
            || _isDonationRecipient[from] || _isDonationRecipient[to] 
            || _isEmploymentWallet[from] || _isEmploymentWallet[to]
            || _isTeamWallet[from] || _isTeamWallet[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, treasury, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapAndSendFee(uint256 amount) private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(amount);
        uint256 newBalance = address(this).balance.sub(initialBalance);

        payable(Wallet_Development).transfer(newBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
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
            owner(),
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        removeAllFee();

        if (takeFee) {
            if (sender == uniswapV2Pair) {
                setBuy();
            }
            if (recipient == uniswapV2Pair) {
                setSell();
            }
            if (!_isExcluded[sender] && !_isExcluded[recipient]) {
                setTransfer();
            }
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeTreasuryAndDevelopment(
            calculateTreasuryFee(tAmount),
            calculateDevelopmentFee(tAmount)
        );
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeTreasuryAndDevelopment(
            calculateTreasuryFee(tAmount),
            calculateDevelopmentFee(tAmount)
        );
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeTreasuryAndDevelopment(
            calculateTreasuryFee(tAmount),
            calculateDevelopmentFee(tAmount)
        );
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeTreasuryAndDevelopment(
            calculateTreasuryFee(tAmount),
            calculateDevelopmentFee(tAmount)
        );
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
}