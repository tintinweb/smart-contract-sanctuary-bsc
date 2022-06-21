/**
 *Submitted for verification at BscScan.com on 2022-06-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.10;

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
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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


interface IDexFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}


interface IDexRouter {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


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


contract BLACKSHEEP is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcludedFrommaxWalletLimit;
    mapping(address => bool) private _isExcludedFrommaxTransferLimit;

    string private _name = "BLACK SHEEP";
    string private _symbol = "BS";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 10**4 * 10**_decimals;
    
    uint256 public _Tax_On_Buy = 5;
    uint256 public _Tax_On_Sell = 5;

    uint256 private Percent_Marketing = 80;
    uint256 private Percent_Dev = 20;
    uint256 private Percent_Burn = 0;
    uint256 private Percent_AutoLP = 0;

    address payable private Wallet_Marketing = payable(0xC251213742FD35994E8936f34F752FC67226877a);
    address payable private Wallet_Dev = payable(0x6a58aD29686feB7CA344F4b041c80bcACba18741);
    address payable private Wallet_Burn = payable(0x000000000000000000000000000000000000dEaD);

    uint256 private _maxWalletToken = _totalSupply.div(20);
    uint256 private _maxTxToken = _totalSupply.div(100);

    IDexRouter public dexRouter; 
    address public dexPair;
    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;

    uint8 private txCount = 0;
    uint8 private swapTrigger = 5;
    
    event SwapAndLiquifyEnabledUpdated(bool true_or_false);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    receive() external payable {}

    constructor() {
        //mainnet
        //IDexRouter _dexRouter = IDexRouter(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        //);

        //Testnet
        IDexRouter _dexRouter = IDexRouter(
             0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );

        dexPair = IDexFactory(_dexRouter.factory()).createPair(
            address(this),
            _dexRouter.WETH()
        );
        dexRouter = _dexRouter;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[Wallet_Burn] = true;

        _isExcludedFrommaxTransferLimit[owner()] = true;
        _isExcludedFrommaxTransferLimit[address(this)] = true;

        _isExcludedFrommaxWalletLimit[owner()] = true;
        _isExcludedFrommaxWalletLimit[address(this)] = true;
        _isExcludedFrommaxWalletLimit[dexPair] = true;
        _isExcludedFrommaxWalletLimit[Wallet_Burn] = true;

        _balances[owner()] = _totalSupply;
        emit Transfer(address(0), owner(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address _account)
        public
        view
        override
        returns (uint256)
    {
        return _balances[_account];
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
            _allowances[sender][_msgSender()].sub(amount)
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
            _allowances[_msgSender()][spender].sub(subtractedValue)
        );
        return true;
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
        require(amount > 0, "ERC20: transfer amount must be greater than zero");

        if (!_isExcludedFrommaxTransferLimit[from]) {
            require(amount <= _maxWalletToken, "Over transaction limit");
        }

        if (!_isExcludedFrommaxWalletLimit[to]) {
            uint256 heldTokens = balanceOf(to);
            require((heldTokens.add(amount)) <= _maxWalletToken, "Over wallet limit");
        }

        if (
            txCount >= swapTrigger &&
            !inSwapAndLiquify &&
            from != dexPair
            && swapAndLiquifyEnabled
        ) {
            uint256 contractTokenBalance = balanceOf(address(this));
            if (contractTokenBalance > _maxTxToken) {
                contractTokenBalance = _maxTxToken;
            }

            txCount = 0;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        bool isBuy;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        } else {
            if (from == dexPair) {
                isBuy = true;
            }
            txCount++;
        }

        _tokenTransfer(from, to, amount, takeFee, isBuy);
    }

    function sendToWallet(address payable wallet, uint256 amount) private {
        wallet.transfer(amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 tokens_to_Burn = contractTokenBalance.mul(Percent_Burn).div(100);
        _balances[address(this)] = _balances[address(this)].sub(tokens_to_Burn);
        _balances[Wallet_Burn] = _balances[Wallet_Burn].add(tokens_to_Burn);

        uint256 tokens_to_M = contractTokenBalance.mul(Percent_Marketing).div(100);
        uint256 tokens_to_D = contractTokenBalance.mul(Percent_Dev).div(100);
        uint256 tokens_to_LP_Half = contractTokenBalance.mul(Percent_AutoLP).div(200);

        uint256 balanceBeforSwap = address(this).balance;
        swapTokensForBNB(tokens_to_M.add(tokens_to_D).add(tokens_to_LP_Half));
        uint256 BNB_Total = address(this).balance.sub(balanceBeforSwap);

        uint256 split_M = Percent_Marketing.mul(100).div(Percent_AutoLP.add(Percent_Marketing).add(Percent_Dev));
        uint256 BNB_M = BNB_Total.mul(split_M).div(100);

        uint256 split_D = Percent_Dev.mul(100).div(Percent_AutoLP.add(Percent_Marketing).add(Percent_Dev));
        uint256 BNB_D = BNB_Total.mul(split_D).div(100);

        addLiquidity(tokens_to_LP_Half, (BNB_Total.sub(BNB_M).sub(BNB_D)));
        emit SwapAndLiquify(tokens_to_LP_Half, (BNB_Total.sub(BNB_M).sub(BNB_D)), tokens_to_LP_Half);

        sendToWallet(Wallet_Marketing, BNB_M);

        BNB_Total = address(this).balance;
        sendToWallet(Wallet_Dev, BNB_Total);

    }

    function swapTokensForBNB(uint256 tokenAmount) private {
        address [] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 BNBAmount) private {
        _approve(address(this), address(dexRouter), tokenAmount);
        dexRouter.addLiquidityETH{value: BNBAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            Wallet_Dev,
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee, bool isBuy) private {
        if (!takeFee) {
            _balances[sender] = _balances[sender].sub(tAmount);
            _balances[recipient] = _balances[recipient].add(tAmount);
            //emit Transfer(sender, recipient, tAmount);
        } else if (isBuy) {
            uint256 buyFEE = tAmount.mul(_Tax_On_Buy).div(100);
            uint256 tTransferAmount = tAmount.sub(buyFEE);

            _balances[sender] = _balances[sender].sub(tAmount);
            _balances[recipient] = _balances[recipient].add(tTransferAmount);
            _balances[address(this)] = _balances[address(this)].add(buyFEE);

            //emit Transfer(sender, recipient, tTransferAmount);
        } else {
            uint256 sellFEE = tAmount.mul(_Tax_On_Sell).div(100);
            uint256 tTransferAmount = tAmount.sub(sellFEE);

            _balances[sender] = _balances[sender].sub(tAmount);
            _balances[recipient] = _balances[recipient].add(tTransferAmount);
            _balances[address(this)] = _balances[address(this)].add(sellFEE);

            //emit Transfer(sender, recipient, tTransferAmount);
        }
    }

    function setMaxTxToken() external onlyOwner {
        _maxTxToken = _totalSupply;
    }

}