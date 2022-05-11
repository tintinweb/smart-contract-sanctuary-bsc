/**
 *Submitted for verification at BscScan.com on 2022-05-11
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.10;

/*

CryptoHealt BSC Token is a pioneer for medical reimbursement, cryptodonations
and utilities centered around the medical field. Check us out:

Telegram: t.me/cryptohealth_official
Website: www.cryptohealth.life

*/

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

contract CRYPTOHEALTH is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned; //Tokens Reflected
    mapping(address => uint256) private _tOwned; //Tokens Owned
    mapping(address => mapping(address => uint256)) private _allowances;
    
    mapping(address => bool) public _isDonationRecipient; //Wallet with specific transfer requirements
    mapping(address => bool) private _isEmploymentWallet; //Employment Wallets
    mapping(address => bool) private _isTeamWallet; //Team Wallets
    mapping(address => bool) private _isSniper; //Sniper Wallets

    mapping(address => bool) private _isExcludedFromFee; //Does not pay taxes
    mapping(address => bool) private _isLimitExempt; //Wallet exempted from Hold limits
    mapping(address => bool) private _isExcluded; //Does not have reflections
    address[] private _excluded;

    mapping (address => uint256) private transferTime;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1* 10**9 * 10**9; //Total Supply = 1,000,000,000
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = "CRYPTOHEALTH";
    string private _symbol = "CHT";
    uint8 private _decimals = 9;

    struct BuyFee {
        uint16 developmentFee;
        uint16 treasuryFee;
        uint16 taxFee;
    }

    struct SellFee {
        uint16 developmentFee;
        uint16 treasuryFee;
        uint16 taxFee;
    }

    struct TransferFee {
        uint16 developmentFee;
        uint16 treasuryFee;
        uint16 taxFee;

    }

    BuyFee public buyFee;
    SellFee public sellFee;
    TransferFee public transferFee;

    uint16 private _taxFee;
    uint16 private _developmentFee;
    uint16 private _treasuryFee;

    IUniswapV2Router02 public uniswapV2Router;
    address private uniswapV2Pair;
    address private _burnWallet = 0x000000000000000000000000000000000000dEaD;

    //Multisignature wallets that will hold tokens to pay for Team, Marketing, and fund utilities
    //For Updating in final contract

    address public Wallet_Development = payable(address(0x74637837a5cf59735399F39B6Ca78f94AD1FB4D4));
    address public Wallet_Treasury = payable(address(0xc4b54255860fa541b49e20963B1514E9be27226a));
    address public Wallet_Prize = payable(address(0x74762D067EAe44a58a43FFA4A5C9527E19a5957f));

    //Multisignature wallets that will hold tokens for hiring expanded team
    //For Updating in final contract

    address public Wallet_Employment1 = 0xD033cD6e7b011617E6FA45Ca3d9E986E463B7D5B;
    address public Wallet_Employment2 = 0x43101946B7885C116e11492Da7863A5b82E710Aa;

    //Test Wallets - for Deletion in final contract
    address private Wallet_Sniper = 0xB5ceBCd0D521F75F97B4FF2F3f594b356af7d9B1;

    uint256 public _maxTxAmount = 1 * 10**7 * 10**9; //1% transaction limit
    uint256 private _maxHold = 3 * 10**7 * 10**9; //3% hold limit for Regular Wallets

    uint256 private _teamSellLimit = 5 * 10**5 * 10**9; //Team Wallet sell limits after unlock date
    uint256 private _teamSellStart = 	1749556800; //Team can sell units starting June 10, 2025 12:00:00 GMT
    uint256 private _presaleEnd = 	1657454400; //Remove from fee open until July 10, 2022 12:00:00 GMT

    uint256 private _employmentHold = 1 * 10**8 * 10**9; //Maximum hold limit of 10% of total supply for Team Wallets
    uint256 private _prizeHold = 1 * 10**7 * 10**9; //Maximum hold limit of 1% of total supply for Prize Wallet

    //For Donation Recipient Wallets
    uint256 private donationTransferMin = 999 * 10**2 * 10**9; //Sell 99,900 tokens at a time
    uint256 private donationTransferMax = 25 * 10**4 * 10**9; //Transfer 250,000 to Employment Wallet at a time
    uint256 private burnTransferAmt = 1 * 10**3 * 10**9; //Burn at most 1,000 at a time
    uint256 public _maxDonationRecipientHold = 25 * 10**5 * 10**9; //Hold 0.25% of the supply
    uint256 private _donationLimit1 = 1 * 10**4 * 10**9; //Donate 10,000 at a time
    uint256 private _donationLimit2 = 25 * 10**2 * 10**9; //Donate 2,500 at a time
    uint256 private _donationLimit3 = 1 * 10**5 * 10**9; //Donate 100,000 at a time
    uint256 private _donationLimit4 = 5 * 10**2 * 10**9; //Donate 500 at a time

    uint256 public _sniperSellLimit = 5 * 10*4 * 10**9; //Snipers can only sell 50,000 tokens at a time

    event isDonationReceiver(address account);
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);

    constructor() payable {

        _rOwned[_msgSender()] = _rTotal;

        buyFee.developmentFee = 3; //Marketing and Team Wallet
        buyFee.treasuryFee = 3; //Treasury Wallet
        buyFee.taxFee = 1; //Reflection

        sellFee.developmentFee = 4;
        sellFee.treasuryFee = 4;
        sellFee.taxFee = 4;

        transferFee.developmentFee = 12;
        transferFee.treasuryFee = 12;
        transferFee.taxFee = 4;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3 //For testing purposes only
         
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
        _isExcludedFromFee[Wallet_Treasury] = true;
        _isExcludedFromFee[Wallet_Development] = true;
        _isExcludedFromFee[Wallet_Prize] = true;
        _isExcludedFromFee[Wallet_Employment1] = true;
        _isExcludedFromFee[Wallet_Employment2] = true;

        // Wallet that are excluded from regular holding limits
        _isLimitExempt[owner()] = true;
        _isLimitExempt[address(this)] = true;
        _isLimitExempt[Wallet_Treasury] = true;
        _isLimitExempt[_burnWallet] = true;
        _isLimitExempt[uniswapV2Pair] = true;

        // Employment wallet mapped for separate holding limit
        _isEmploymentWallet[Wallet_Employment1] = true;
        _isEmploymentWallet[Wallet_Employment2] = true;

        // Test Wallets
        _isSniper[Wallet_Sniper] = true;

        // Exclude from Rewards
        _isExcluded[_burnWallet] = true;
        _isExcluded[uniswapV2Pair] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[Wallet_Development] = true;
        _isExcluded[Wallet_Treasury] = true;
        _isExcluded[Wallet_Prize] = true;

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
        (uint256 rAmount, , , , ) = _getValues(tAmount);
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
            (uint256 rAmount, , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , ) = _getValues(tAmount);
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
        require (block.timestamp <= _presaleEnd,
            "Owner cannot exclude after predetermined date.");
        _isExcludedFromFee[account] = true;
    }

    //Set as Donation Recipients
    function includeForDonation(address account) external onlyOwner {
        _isDonationRecipient[account] = true;

        emit isDonationReceiver (account);
    }

    function excludeForDonation(address account) external onlyOwner {
        _isDonationRecipient[account] = false;
        
    }

    //Set as Team Wallet
    function includeForTeamWallet(address account) external onlyOwner {
        _isTeamWallet[account] = true;
        _isExcluded[account] = true;
    }

    // Maximum buy fee canot not be set over 10%
    function setBuyFee(uint16 develop, uint16 treasury, uint16 tax) external onlyOwner {
        require(develop + treasury + tax <= 10, "Fees are capped at 10%"); 
        
        buyFee.developmentFee = develop;
        buyFee.treasuryFee = treasury;
        buyFee.taxFee = tax;
    }

    // Maximum sell fee canot not be set over 15%
    function setSellFee(uint16 develop, uint16 treasury, uint16 tax) external onlyOwner {
        require(develop + treasury + tax <= 15, "Fees are capped at 10%"); 

        sellFee.developmentFee = develop;
        sellFee.treasuryFee = treasury;
        sellFee.taxFee = tax;
    }

    // Maximum transfer fee canot not be set over 40%
    // Transfers are highly discouraged!
    function setTransferFee(uint16 develop, uint16 treasury, uint16 tax) external onlyOwner {
        require(develop + treasury + tax <= 40, "Fees are capped at 40%"); 

        transferFee.developmentFee = develop;
        transferFee.treasuryFee = treasury;
        transferFee.taxFee = tax;
    }

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
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTreasury,
            uint256 tDevelopment
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tTreasury,
            tDevelopment,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tTreasury = calculateTreasuryFee(tAmount);
        uint256 tDevelopment = calculateDevelopmentFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee);
        tTransferAmount = tTransferAmount.sub(tTreasury).sub(tDevelopment);
        return (tTransferAmount, tFee, tTreasury, tDevelopment);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
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
        uint256 rTreasury = tTreasury.mul(currentRate);
        uint256 rDevelopment = tDevelopment.mul(currentRate);
        uint256 rTransferAmount = rAmount
            .sub(rFee)
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

    function _takeTreasuryAndDevelopment(uint256 tTreasury, uint256 tDevelopment)
        private
    {
        uint256 currentRate = _getRate();
        uint256 rTreasury = tTreasury.mul(currentRate);
        uint256 rDevelopment = tDevelopment.mul(currentRate);

        _rOwned[Wallet_Treasury] = _rOwned[Wallet_Treasury].add(rTreasury);
        _rOwned[Wallet_Development] = _rOwned[Wallet_Development].add(rDevelopment);

        _tOwned[Wallet_Treasury] = _tOwned[Wallet_Treasury].add(tTreasury);
        _tOwned[Wallet_Development] = _tOwned[Wallet_Development].add(tDevelopment);

    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
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
        _treasuryFee = 0;
        _developmentFee = 0;
    }

    function setBuy() private {
        _taxFee = buyFee.taxFee;
        _treasuryFee = buyFee.treasuryFee;
        _developmentFee = buyFee.developmentFee;
    }

    function setSell() private {
        _taxFee = sellFee.taxFee;
        _treasuryFee = sellFee.treasuryFee;
        _developmentFee = sellFee.developmentFee;
    }

    function setTransfer() private {
        _taxFee = transferFee.taxFee;
        _treasuryFee = transferFee.treasuryFee;
        _developmentFee = transferFee.developmentFee;
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

        // Please do not bot unless you want to get burned
        if (_isSniper[from])
            {
            if (block.timestamp <= 1844251200) { // Will be allowed transfer until June 10, 2028 12:00:00 GMT
            require ((to == uniswapV2Pair
                    && amount <= _sniperSellLimit) // Can sell 50,000 tokens at a time
                    || ((to == Wallet_Treasury || to == Wallet_Development)
                    && amount <= donationTransferMax) // Transfer 250,000 buy back at half price
                    && (block.timestamp >= transferTime[from] + 2 weeks), // Can only transfer every 2 weeks
                    "Account tagged as Sniper, with limited capacity to send."
            );
            transferTime[from] = block.timestamp;

            }
                else {
                require (to == _burnWallet && amount <= _maxTxAmount,
                        "No option but to burn, buyback for 1/5th of current price."); // Treasury will manually buy back
            }
            
        }

        // Team Wallet sending limits, buyer protection for misuse of lack of fees. Limits as follows:
        if (_isTeamWallet[from])
            {
            require (_isExcluded[to] // Can only sell or burn, cannot transfer to others
                    && amount <= _teamSellLimit // Can only sell 500K tokens at a time
                    && block.timestamp >= _teamSellStart // Can only sell after predetermined period
                    && block.timestamp >= transferTime[from] + 2 minutes, // Can only transfer every 2 minutes
                    "Team Wallet has transfer limitations."
            );
            transferTime[from] = block.timestamp;
        }

        // Prize Wallet Limits
        if (to == Wallet_Prize)
            {
            uint256 heldTokens = balanceOf(to);
            require ((from == owner() || from == Wallet_Treasury) // Can only receive tokens from Treasury."
                    && (heldTokens + amount) <= _maxHold,
                    "Prize Wallet can only receive from Treasury Wallet."
             );        
        }

        // Prize Wallet Limits
        if (from == Wallet_Prize) 
            {
            require (!_isExcluded[to] || !_isDonationRecipient[to],
                    "Prize Wallet can only transfer to Regular Holders."
            );

        }
        
        // Employment Wallet Limits
        if (_isEmploymentWallet[to])
            {
            uint256 heldTokens = balanceOf(to);
            require (_isDonationRecipient[from] || from == Wallet_Treasury // Can only receive tokens from Treasury and Donation Recipients."
                    && (heldTokens + amount) <= _employmentHold, // Can only hold at most 10% of the supply"
                    "Employment Wallet can only receive from certain wallets."
             );        
        }

        // Employment Wallet Limits
        if (_isEmploymentWallet[from]) 
            {
            require (to == Wallet_Treasury || to == uniswapV2Pair // Can only sell or transfer to Treasury
                    && amount <= _teamSellLimit // Can only transfer at most 250K tokens at a time
                    && block.timestamp > transferTime[from] + 7 days, // Can only sell once every week after unlock
                    "Employment Wallet has transfer limitations."
            );
            transferTime[from] = block.timestamp;
        }

        // Donation Wallet receiving limits

        if (_isDonationRecipient[to])
            {
            uint256 heldTokens = balanceOf(to);
            require (((heldTokens + amount) <= _maxDonationRecipientHold) 
                    && 
                    ((amount == _donationLimit1 // Can only donate 10K tokens at a time
                    && block.timestamp > transferTime[to] + 36 hours) // 36 hour donation cooldown
                    ||
                    (amount == _donationLimit2 // Can only donate 2500 tokens at a time
                    && block.timestamp > transferTime[to] + 8 hours) // 8 hour donation cooldown
                    ||
                    (amount == _donationLimit4 // Can only donate 500 tokens at a time
                    && block.timestamp > transferTime[to] + 60 minutes) // 1 hour donation cooldown
                    ||
                    (amount == _donationLimit3 // Can only donate 100K tokens at a time
                    && block.timestamp > transferTime[to] + 20 days)), // 20 days donation cooldown
                    "Donation cooldown times as follows: Donate 100K (20d), 10K (36h), 2500 (8h), 500 (1h)."
            );
            transferTime[to] = block.timestamp;
            
        }

        // Donation Wallet transfer and sell limits, buyer protection for misuse of lack of fees
        if (_isDonationRecipient[from]) 
            {
            require ((amount == donationTransferMax && _isEmploymentWallet[to]) // Send 250,000 tokens to Employment Wallet
                    || ((amount == donationTransferMin && to == uniswapV2Pair)
                       && (block.timestamp > transferTime[to] + 7 days)) // Sell 99,900 tokens every 7 days
                    || (amount <= burnTransferAmt && to == _burnWallet), // Burn at most 1,000 tokens at a time
                    "Donation Recipient Wallet have transfer limitations."
            );
            transferTime[from] = block.timestamp;

        }

        // Regular Wallet Limit
        if (!_isLimitExempt[to] && !_isEmploymentWallet[to] && !_isDonationRecipient[to] && from != owner())
            {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxHold, 
                "Wallet cannot exceed maximum hold limit."
            );
        }

        if (from != owner() && to != owner()) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maximum transaction amount."
            );
}

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        //Team wallets have locked tokens and cannot buy more tokens
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] 
            || _isDonationRecipient[from] || _isDonationRecipient[to] 
            || _isEmploymentWallet[from] || _isEmploymentWallet[to]
            || _isTeamWallet[from] || _isTeamWallet[to]) {
            takeFee = false;
        }

        //transfer amount, it will take tax, treasury, prize fee
        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if(!takeFee)
        removeAllFee();

        if (takeFee) {
            if (sender == uniswapV2Pair) {
                setBuy();
            }
                else if (recipient == uniswapV2Pair) {
                setSell();

            }  
                else {
                setTransfer();
            } 

        }
         
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
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
            uint256 tFee

        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
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
            uint256 tFee

        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
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
            uint256 tFee

        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
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
            uint256 tFee

        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTreasuryAndDevelopment(
            calculateTreasuryFee(tAmount),
            calculateDevelopmentFee(tAmount)

        );
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

}

// Token developed by tokens_by_me (Fiverr)
// Stay SAFU, say no to rugs, and always DYOR