/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract ForWinCoin is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isBot;
    mapping(address => bool) private _isBuyAllowed;
    mapping(address => bool) private _isLPToken;

    bool public tradingEnabled;
    bool public isPublicBuy;

    IRouter public router;
    address public pair;
    address public pairBUSD;

    uint8 private constant _decimals = 18;
    uint256 private _tTotal = 0;
    uint256 private _initialPool = 6000000000000000000000000000;

    address public treasuryAddress = 0xdb25999ad4b0508dBE1ede7125c0F0D25e933a82;
    address public burnAddress = 0x000000000000000000000000000000000000dEaD;

    address public BUSD = 0x55d398326f99059fF775485246999027B3197955;
    address public constant deadAddress =
        0x000000000000000000000000000000000000dEaD;

    string private constant _name = "ForWinCoin";
    string private constant _symbol = "FWC";

    struct feeRatesStruct {
        uint256 burns;
        uint256 treasury;
    }
    
    feeRatesStruct public feeRates = feeRatesStruct({
        burns: 0,
        treasury: 0
    });

    feeRatesStruct public sellFeeRates = feeRatesStruct({
        burns: 0,
        treasury: 0
    });

    struct valuesFromGetValues {
        uint256 tTransferAmount;
        uint256 tBurns;
        uint256 tTreasury;
    }

    event FeesChanged();
    event TradingEnabled(uint256 startDate);

    constructor(address routerAddress) {
        IRouter _router = IRouter(routerAddress);
        address _pair = IFactory(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        address _pairBUSD = IFactory(_router.factory()).createPair(
            address(this),
            BUSD
        );

        pair = _pair;
        pairBUSD = _pairBUSD;
        router = _router;
        

        _balances[owner()] = _initialPool;
        _tTotal += _initialPool;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[treasuryAddress] = true;
        _isBuyAllowed[owner()] = true;
        _isLPToken[_pair] = true;
        _isLPToken[_pairBUSD] = true;

        emit Transfer(address(0), owner(), _initialPool);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
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
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            amount <= balanceOf(sender),
            "You are trying to transfer more than your balance"
        );
        require(!_isBot[sender] && !_isBot[recipient], "Fuck you Bots");

        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            require(tradingEnabled, "Trading is not enabled yet");
        }

        bool isSale;
        if (_isLPToken[recipient] == true) {
            isSale = true;
        }

        if (_isLPToken[sender]) {
            isSalesBuy(recipient);
        }

        _tokenTransfer(
            sender,
            recipient,
            amount,
            !(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]),
            isSale
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isSale
    ) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee, isSale);

        _balances[sender] = _balances[sender].sub(
            tAmount,
            "BEP20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(s.tTransferAmount);

        if (s.tBurns > 0) {
            _takeBurn(s.tBurns);
            emit Transfer(sender, burnAddress, s.tBurns);
        }

        if (s.tTreasury > 0) {
            _takeTreasury(s.tTreasury);
            emit Transfer(sender, treasuryAddress, s.tTreasury);
        }

        emit Transfer(sender, recipient, s.tTransferAmount);

    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _tTotal = _tTotal.sub(amount);
        emit Transfer(account, deadAddress, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }

    function _takeBurn(uint256 tBurns) private {

        if(_isExcludedFromFee[burnAddress]){
            _balances[burnAddress] = _balances[burnAddress].add(tBurns);
        }

    }

    function _takeTreasury(uint256 tTreasury) private {

        if (_isExcludedFromFee[treasuryAddress]) {
            _balances[treasuryAddress] = _balances[treasuryAddress].add(tTreasury);
        }

    }

    function _getValues(
        uint256 tAmount,
        bool takeFee,
        bool isSale
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, isSale);
        return to_return;
    }

    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        bool isSale
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }

        if (isSale) {
            s.tBurns = tAmount.mul(sellFeeRates.burns).div(1000);
            s.tTreasury = tAmount.mul(sellFeeRates.treasury).div(1000);
        } else {
            s.tBurns = tAmount.mul(feeRates.burns).div(1000);
            s.tTreasury = tAmount.mul(feeRates.treasury).div(1000);
        }
        s.tTransferAmount = tAmount.sub(s.tBurns).sub(s.tTreasury);
        return s;
    }

    function updateBuyStatus(address _addr, bool _status) public onlyOwner {
        _isBuyAllowed[_addr] = _status;
    }

    function updatePublicBuy(bool _status) public onlyOwner {
        isPublicBuy = _status;
    }

    function isSalesBuy(address _recipient)
        private
        view
        returns (bool _status)
    {
        require(
            (isPublicBuy == true || _isBuyAllowed[_recipient] == true),
            "Only Whitelisted Address Buy"
        );
        return true;
    }

    function setFeeRates(uint256 _burns, uint _treasury) external onlyOwner {
        feeRates.burns = _burns;
        feeRates.treasury = _treasury;
        emit FeesChanged();
    }

    function setSellFeeRates(uint256 _burns, uint _treasury) external onlyOwner {

        sellFeeRates.burns = _burns;
        sellFeeRates.treasury = _treasury;
        emit FeesChanged();
    }

    function updateLPTokenAddress(address _router, address _totoken)
        external
        onlyOwner
    {
        IRouter _newRouter = IRouter(_router);
        address get_pair = IFactory(_newRouter.factory()).getPair(
            address(this),
            _totoken
        );
        if (get_pair == address(0)) {
            get_pair = IFactory(_newRouter.factory()).createPair(
                address(this),
                _totoken
            );
        }
        _isLPToken[get_pair] = true;
    }

    function updateBurnAddress(address _addr) external onlyOwner {
        require(_addr != burnAddress);
        burnAddress = _addr;
        _isExcludedFromFee[_addr] = true;
    }

    function updateTreasuryAddress(address _addr) external onlyOwner {
        require(_addr != treasuryAddress);
        treasuryAddress = _addr;
        _isExcludedFromFee[_addr] = true;
    }

    function addWhitelist(address _addr, bool _status) public onlyOwner {
        _isExcludedFromFee[_addr] = _status;
    }

    function setAntibot(address _addr, bool _bot) external onlyOwner {
        require(_isBot[_addr] != _bot, "Value already set");
        _isBot[_addr] = _bot;
    }

    function isBot(address _addr) public view returns (bool) {
        return _isBot[_addr];
    }

    function startTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabled(block.timestamp);
    }

    function setRouterAddress(address newRouter) external onlyOwner {
        require(newRouter != address(router));
        IRouter _newRouter = IRouter(newRouter);
        address get_pair = IFactory(_newRouter.factory()).getPair(address(this), _newRouter.WETH());
        if (get_pair == address(0)) {
            pair = IFactory(_newRouter.factory()).createPair(address(this), _newRouter.WETH());
        }
        else {
            pair = get_pair;
        }
        router = _newRouter;
    }

    receive() external payable {}
}